BEGIN;

ALTER TABLE public."Booking"
  ADD COLUMN IF NOT EXISTS "KhuyenMaiDaTru" boolean NOT NULL DEFAULT false;

CREATE OR REPLACE FUNCTION public.set_booking_promotion(
  p_bookingid bigint,
  p_makhuyenmai text
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO ''
AS $$
DECLARE
  customer_id bigint := (SELECT private.current_customer_id());
  booking_row public."Booking"%ROWTYPE;
  promotion public."KhuyenMai"%ROWTYPE;
BEGIN
  IF (SELECT auth.uid()) IS NULL OR customer_id IS NULL THEN
    RAISE EXCEPTION 'An active customer account is required';
  END IF;

  SELECT *
  INTO booking_row
  FROM public."Booking"
  WHERE "BookingID" = p_bookingid
    AND "KhachHangID" = customer_id
  FOR UPDATE;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Booking not found';
  END IF;

  SELECT *
  INTO promotion
  FROM public."KhuyenMai"
  WHERE upper("MaKhuyenMai") = upper(btrim(p_makhuyenmai))
  FOR UPDATE;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Promotion code does not exist';
  END IF;

  IF booking_row."KhuyenMaiID" IS NOT NULL THEN
    IF booking_row."KhuyenMaiID" = promotion."KhuyenMaiID" THEN
      RETURN;
    END IF;
    RAISE EXCEPTION 'A promotion has already been reserved for this booking';
  END IF;

  IF booking_row."TrangThai" <> 'ChoTiepNhan'
     OR EXISTS (
       SELECT 1
       FROM public."DonHang"
       WHERE "BookingID" = p_bookingid
     ) THEN
    RAISE EXCEPTION 'Only pending bookings can use a promotion';
  END IF;

  IF EXISTS (
    SELECT 1
    FROM public."Booking" AS existing_booking
    WHERE existing_booking."KhachHangID" = customer_id
      AND existing_booking."KhuyenMaiID" = promotion."KhuyenMaiID"
      AND existing_booking."TrangThai" <> 'DaHuy'
  ) THEN
    RAISE EXCEPTION 'Promotion has already been used by this customer';
  END IF;

  IF promotion."TrangThai" <> 'Hoạt động'
     OR promotion."NgayBatDau" > current_date
     OR promotion."NgayKetThuc" < current_date
     OR (
       promotion."SoLuongSuDung" IS NOT NULL
       AND promotion."SoLuongSuDung" <= 0
     ) THEN
    RAISE EXCEPTION 'Promotion code is invalid, expired, or unavailable';
  END IF;

  IF promotion."SoLuongSuDung" IS NOT NULL THEN
    UPDATE public."KhuyenMai"
    SET "SoLuongSuDung" = "SoLuongSuDung" - 1
    WHERE "KhuyenMaiID" = promotion."KhuyenMaiID"
      AND "SoLuongSuDung" > 0;

    IF NOT FOUND THEN
      RAISE EXCEPTION 'Promotion code is no longer available';
    END IF;
  END IF;

  UPDATE public."Booking"
  SET "KhuyenMaiID" = promotion."KhuyenMaiID",
      "KhuyenMaiDaTru" = promotion."SoLuongSuDung" IS NOT NULL
  WHERE "BookingID" = p_bookingid;
END;
$$;

REVOKE ALL ON FUNCTION public.set_booking_promotion(bigint, text) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.set_booking_promotion(bigint, text) TO authenticated;

CREATE OR REPLACE FUNCTION public.submit_laundry_booking_request(
  p_items jsonb,
  p_hinhthucnhando text,
  p_diachinhan text,
  p_ngayhen date,
  p_giohen time without time zone,
  p_ghichu text,
  p_idempotency_key uuid,
  p_use_points boolean,
  p_makhuyenmai text DEFAULT NULL
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO ''
AS $$
DECLARE
  booking_result jsonb;
BEGIN
  IF p_items IS NULL THEN
    booking_result := public.submit_laundry_booking_without_details(
      p_hinhthucnhando,
      p_diachinhan,
      p_ngayhen,
      p_giohen,
      p_ghichu,
      p_idempotency_key
    );
  ELSIF coalesce(p_use_points, false) THEN
    booking_result := public.submit_laundry_order_cart_with_points(
      p_items,
      p_hinhthucnhando,
      p_diachinhan,
      p_ngayhen,
      p_giohen,
      p_ghichu,
      p_idempotency_key,
      true
    );
  ELSE
    booking_result := public.submit_laundry_order_cart(
      p_items,
      p_hinhthucnhando,
      p_diachinhan,
      p_ngayhen,
      p_giohen,
      p_ghichu,
      p_idempotency_key
    );
  END IF;

  IF nullif(btrim(p_makhuyenmai), '') IS NOT NULL THEN
    PERFORM public.set_booking_promotion(
      (booking_result->>'bookingid')::bigint,
      p_makhuyenmai
    );
  END IF;

  RETURN booking_result;
END;
$$;

REVOKE ALL ON FUNCTION public.submit_laundry_booking_request(
  jsonb, text, text, date, time without time zone, text, uuid, boolean, text
) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.submit_laundry_booking_request(
  jsonb, text, text, date, time without time zone, text, uuid, boolean, text
) TO authenticated;

CREATE OR REPLACE FUNCTION public.cancel_laundry_booking(p_bookingid bigint)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO ''
AS $$
DECLARE
  customer_id bigint := (SELECT private.current_customer_id());
  booking_row public."Booking"%ROWTYPE;
  customer_name text;
BEGIN
  IF (SELECT auth.uid()) IS NULL OR customer_id IS NULL THEN
    RAISE EXCEPTION 'An active customer account is required';
  END IF;

  SELECT *
  INTO booking_row
  FROM public."Booking"
  WHERE "BookingID" = p_bookingid
    AND "KhachHangID" = customer_id
  FOR UPDATE;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Booking not found';
  END IF;

  IF booking_row."TrangThai" <> 'ChoTiepNhan'
     OR EXISTS (SELECT 1 FROM public."DonHang" WHERE "BookingID" = p_bookingid) THEN
    RAISE EXCEPTION 'Only pending bookings can be canceled';
  END IF;

  UPDATE public."Booking"
  SET "TrangThai" = 'DaHuy',
      "NgayCapNhat" = now()
  WHERE "BookingID" = p_bookingid;

  IF booking_row."KhuyenMaiDaTru"
     AND booking_row."KhuyenMaiID" IS NOT NULL THEN
    UPDATE public."KhuyenMai"
    SET "SoLuongSuDung" = "SoLuongSuDung" + 1
    WHERE "KhuyenMaiID" = booking_row."KhuyenMaiID"
      AND "SoLuongSuDung" IS NOT NULL;
  END IF;

  SELECT "HoTen"
  INTO customer_name
  FROM public."KhachHang"
  WHERE "KhachHangID" = customer_id;

  INSERT INTO public."ThongBao" (
    "TaiKhoanID", "TieuDe", "NoiDung", "ThoiGianGui", "DaDoc", "DonHangID", "LoaiThongBao"
  )
  SELECT DISTINCT
    account_role."TaiKhoanID",
    'Yêu cầu đặt giặt bị hủy',
    'Khách hàng ' || coalesce(customer_name, 'Khách hàng') ||
      ' vừa hủy yêu cầu ' || booking_row."MaBooking" || '.',
    now(),
    false,
    NULL::integer,
    'booking_cancelled'
  FROM public."TaiKhoan_VaiTro" AS account_role
  JOIN public."VaiTro" AS role
    ON role."VaiTroID" = account_role."VaiTroID"
  JOIN public."TaiKhoan" AS account
    ON account."TaiKhoanID" = account_role."TaiKhoanID"
  WHERE role."TenVaiTro" IN ('Nhân viên', 'Quản lý', 'Chủ cửa hàng')
    AND role."TrangThai" = 'Hoạt động'
    AND account."TrangThai" = 'Hoạt động';
END;
$$;

REVOKE ALL ON FUNCTION public.cancel_laundry_booking(bigint) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.cancel_laundry_booking(bigint) TO authenticated;

CREATE OR REPLACE FUNCTION public.get_customer_loyalty()
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO ''
AS $$
DECLARE
  customer_id bigint := (SELECT private.current_customer_id());
  current_points integer;
  active_vouchers jsonb;
BEGIN
  IF customer_id IS NULL THEN
    RAISE EXCEPTION 'An active customer account is required';
  END IF;

  SELECT coalesce(points."DiemHienTai", 0)
  INTO current_points
  FROM public."DiemTichLuy" AS points
  WHERE points."KhachHangID" = customer_id;

  SELECT coalesce(
    jsonb_agg(
      jsonb_build_object(
        'khuyenmaiid', promotion."KhuyenMaiID",
        'makhuyenmai', promotion."MaKhuyenMai",
        'tenkhuyenmai', promotion."TenKhuyenMai",
        'loaikhuyenmai', promotion."LoaiKhuyenMai",
        'giatrigiam', promotion."GiaTriGiam",
        'giatridontoithieu', promotion."GiaTriDonToiThieu",
        'mucgiamtoida', promotion."MucGiamToiDa",
        'dieukienapdung', promotion."DieuKienApDung"
      )
      ORDER BY promotion."NgayKetThuc"
    ),
    '[]'::jsonb
  )
  INTO active_vouchers
  FROM public."KhuyenMai" AS promotion
  WHERE promotion."TrangThai" = 'Hoạt động'
    AND promotion."NgayBatDau" <= current_date
    AND promotion."NgayKetThuc" >= current_date
    AND (
      promotion."SoLuongSuDung" IS NULL
      OR promotion."SoLuongSuDung" > 0
    )
    AND NOT EXISTS (
      SELECT 1
      FROM public."Booking" AS booking
      WHERE booking."KhachHangID" = customer_id
        AND booking."KhuyenMaiID" = promotion."KhuyenMaiID"
        AND booking."TrangThai" <> 'DaHuy'
    );

  RETURN jsonb_build_object(
    'points', coalesce(current_points, 0),
    'vouchers', active_vouchers
  );
END;
$$;

REVOKE ALL ON FUNCTION public.get_customer_loyalty() FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.get_customer_loyalty() TO authenticated;

CREATE OR REPLACE FUNCTION private.apply_booking_promotion_to_order()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO ''
AS $$
DECLARE
  booking_row public."Booking"%ROWTYPE;
  promotion public."KhuyenMai"%ROWTYPE;
  discount_amount numeric(18,2);
BEGIN
  IF NEW."BookingID" IS NULL THEN
    RETURN NEW;
  END IF;

  SELECT *
  INTO booking_row
  FROM public."Booking"
  WHERE "BookingID" = NEW."BookingID";

  IF NOT FOUND OR booking_row."KhuyenMaiID" IS NULL THEN
    RETURN NEW;
  END IF;

  SELECT *
  INTO promotion
  FROM public."KhuyenMai"
  WHERE "KhuyenMaiID" = booking_row."KhuyenMaiID";

  IF NOT FOUND THEN
    RETURN NEW;
  END IF;

  IF promotion."GiaTriDonToiThieu" IS NOT NULL
     AND NEW."TongTien" < promotion."GiaTriDonToiThieu" THEN
    IF booking_row."KhuyenMaiDaTru" THEN
      UPDATE public."KhuyenMai"
      SET "SoLuongSuDung" = "SoLuongSuDung" + 1
      WHERE "KhuyenMaiID" = booking_row."KhuyenMaiID"
        AND "SoLuongSuDung" IS NOT NULL;
    END IF;

    UPDATE public."Booking"
    SET "KhuyenMaiID" = NULL,
        "KhuyenMaiDaTru" = false
    WHERE "BookingID" = NEW."BookingID";
    NEW."KhuyenMaiID" := NULL;
    NEW."TienGiamKhuyenMai" := 0;
    NEW."ThanhTien" := greatest(
      NEW."TongTien" + NEW."PhiGiaoHang" - NEW."TienGiamDoDiem",
      0
    );
    RETURN NEW;
  END IF;

  discount_amount := CASE
    WHEN promotion."LoaiKhuyenMai" = 'Phần trăm'
      THEN NEW."TongTien" * promotion."GiaTriGiam" / 100
    ELSE promotion."GiaTriGiam"
  END;

  IF promotion."MucGiamToiDa" IS NOT NULL THEN
    discount_amount := least(discount_amount, promotion."MucGiamToiDa");
  END IF;

  NEW."KhuyenMaiID" := booking_row."KhuyenMaiID";
  NEW."TienGiamKhuyenMai" := greatest(least(discount_amount, NEW."TongTien"), 0);
  NEW."ThanhTien" := greatest(
    NEW."TongTien" + NEW."PhiGiaoHang" - NEW."TienGiamDoDiem" - NEW."TienGiamKhuyenMai",
    0
  );
  RETURN NEW;
END;
$$;

NOTIFY pgrst, 'reload schema';
COMMIT;
