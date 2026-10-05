BEGIN;

ALTER TABLE public."Booking"
  ADD COLUMN IF NOT EXISTS "DiemSuDung" integer NOT NULL DEFAULT 0,
  ADD COLUMN IF NOT EXISTS "TienGiamDoDiem" numeric(18,2) NOT NULL DEFAULT 0,
  ADD COLUMN IF NOT EXISTS "DiemDaTru" boolean NOT NULL DEFAULT false;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint
    WHERE conname = 'Booking_DiemSuDung_check'
      AND conrelid = 'public."Booking"'::regclass
  ) THEN
    ALTER TABLE public."Booking"
      ADD CONSTRAINT "Booking_DiemSuDung_check" CHECK ("DiemSuDung" >= 0);
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint
    WHERE conname = 'Booking_TienGiamDoDiem_check'
      AND conrelid = 'public."Booking"'::regclass
  ) THEN
    ALTER TABLE public."Booking"
      ADD CONSTRAINT "Booking_TienGiamDoDiem_check" CHECK ("TienGiamDoDiem" >= 0);
  END IF;
END $$;

CREATE OR REPLACE FUNCTION private.account_id_for_customer(p_khachhangid bigint)
RETURNS bigint
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path TO ''
AS $$
  SELECT account."TaiKhoanID"
  FROM public."TaiKhoan" AS account
  WHERE account."KhachHangID" = p_khachhangid
    AND account."TrangThai" = 'Hoạt động'
  ORDER BY account."TaiKhoanID"
  LIMIT 1;
$$;

CREATE OR REPLACE FUNCTION public.notify_staff_new_booking(
  p_bookingid bigint,
  p_booking_number text,
  p_customer_name text
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO ''
AS $$
BEGIN
  INSERT INTO public."ThongBao" (
    "TaiKhoanID",
    "TieuDe",
    "NoiDung",
    "ThoiGianGui",
    "DaDoc",
    "DonHangID",
    "LoaiThongBao"
  )
  SELECT DISTINCT
    account_role."TaiKhoanID",
    'Có yêu cầu đặt giặt mới',
    'Khách hàng ' || coalesce(nullif(btrim(p_customer_name), ''), 'Khách hàng') ||
      ' vừa gửi yêu cầu ' || coalesce(nullif(btrim(p_booking_number), ''), '#' || p_bookingid::text) || '.',
    now(),
    false,
    NULL,
    'new_booking'
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

REVOKE ALL ON FUNCTION public.notify_staff_new_booking(bigint, text, text) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.notify_staff_new_booking(bigint, text, text) TO authenticated;

CREATE OR REPLACE FUNCTION public.submit_laundry_order_cart_with_points(
  p_items jsonb,
  p_hinhthucnhando text,
  p_diachinhan text,
  p_ngayhen date,
  p_giohen time without time zone,
  p_ghichu text,
  p_idempotency_key uuid,
  p_use_points boolean DEFAULT false
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO ''
AS $$
DECLARE
  customer_id bigint := (SELECT private.current_customer_id());
  customer_account_id bigint;
  customer_name text;
  booking_result jsonb;
  booking_id bigint;
  booking_row public."Booking"%ROWTYPE;
  available_points integer := 0;
  points_to_use integer := 0;
  points_discount numeric(18,2) := 0;
  total_amount numeric(18,2) := 0;
  remaining_points integer := 0;
BEGIN
  IF customer_id IS NULL THEN
    RAISE EXCEPTION 'Authentication required';
  END IF;

  customer_account_id := private.account_id_for_customer(customer_id);

  SELECT "HoTen"
  INTO customer_name
  FROM public."KhachHang"
  WHERE "KhachHangID" = customer_id;

  booking_result := public.submit_laundry_order_cart(
    p_items,
    p_hinhthucnhando,
    p_diachinhan,
    p_ngayhen,
    p_giohen,
    p_ghichu,
    p_idempotency_key
  );
  booking_id := (booking_result->>'bookingid')::bigint;

  SELECT *
  INTO booking_row
  FROM public."Booking"
  WHERE "BookingID" = booking_id
    AND "KhachHangID" = customer_id
  FOR UPDATE;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Booking not found';
  END IF;

  SELECT COALESCE(SUM("ThanhTien"), 0)
  INTO total_amount
  FROM public."ChiTietBooking"
  WHERE "BookingID" = booking_id;

  IF NOT booking_row."DiemDaTru" THEN
    IF COALESCE(p_use_points, false) THEN
      SELECT "DiemHienTai"
      INTO available_points
      FROM public."DiemTichLuy"
      WHERE "KhachHangID" = customer_id
      FOR UPDATE;

      IF FOUND THEN
        points_to_use := LEAST(available_points::numeric, FLOOR(total_amount / 10))::integer;
        points_discount := points_to_use * 10;

        IF points_to_use > 0 THEN
          UPDATE public."DiemTichLuy"
          SET "DiemHienTai" = "DiemHienTai" - points_to_use,
              "NgayCapNhat" = now()
          WHERE "KhachHangID" = customer_id;
        END IF;
      END IF;
    END IF;

    UPDATE public."Booking"
    SET "DiemSuDung" = points_to_use,
        "TienGiamDoDiem" = points_discount,
        "DiemDaTru" = true
    WHERE "BookingID" = booking_id;
  END IF;

  SELECT COALESCE("DiemHienTai", 0)
  INTO remaining_points
  FROM public."DiemTichLuy"
  WHERE "KhachHangID" = customer_id;

  SELECT *
  INTO booking_row
  FROM public."Booking"
  WHERE "BookingID" = booking_id;

  IF customer_account_id IS NOT NULL THEN
    INSERT INTO public."ThongBao" (
      "TaiKhoanID", "TieuDe", "NoiDung", "ThoiGianGui", "DaDoc", "DonHangID", "LoaiThongBao"
    ) VALUES (
      customer_account_id,
      'Yêu cầu đặt giặt đã gửi',
      'Yêu cầu ' || booking_row."MaBooking" || ' đã được gửi. Cửa hàng sẽ tiếp nhận trong thời gian sớm nhất.',
      now(),
      false,
      NULL,
      'order_created'
    );
  END IF;

  PERFORM public.notify_staff_new_booking(
    booking_id,
    booking_row."MaBooking",
    customer_name
  );

  RETURN booking_result || jsonb_build_object(
    'thanhtien', total_amount,
    'diemsudung', booking_row."DiemSuDung",
    'tiengiamdodiem', booking_row."TienGiamDoDiem",
    'thanhtoan', GREATEST(total_amount - booking_row."TienGiamDoDiem", 0),
    'diemconlai', COALESCE(remaining_points, 0)
  );
END;
$$;

REVOKE ALL ON FUNCTION public.submit_laundry_order_cart_with_points(
  jsonb, text, text, date, time without time zone, text, uuid, boolean
) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.submit_laundry_order_cart_with_points(
  jsonb, text, text, date, time without time zone, text, uuid, boolean
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
    NULL,
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

CREATE OR REPLACE FUNCTION public.transition_laundry_order(
  p_donhangid bigint,
  p_trangthaimoi text,
  p_lydo text DEFAULT NULL
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO ''
AS $$
DECLARE
  order_record public."DonHang"%ROWTYPE;
  valid_transition boolean := false;
  current_employee bigint := (SELECT private.current_employee_id());
  current_account bigint := (
    SELECT "TaiKhoanID"
    FROM public."TaiKhoan"
    WHERE "UserAuthId" = (SELECT auth.uid())
    LIMIT 1
  );
  customer_account_id bigint;
BEGIN
  IF (SELECT auth.uid()) IS NULL
     OR NOT (SELECT private.is_staff())
     OR (
       current_employee IS NULL
       AND NOT (SELECT private.has_role('Quản lý'))
       AND NOT (SELECT private.has_role('Chủ cửa hàng'))
     ) THEN
    RAISE EXCEPTION 'An active staff account is required';
  END IF;

  SELECT *
  INTO order_record
  FROM public."DonHang"
  WHERE "DonHangID" = p_donhangid
  FOR UPDATE;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Order not found';
  END IF;

  valid_transition := CASE order_record."TrangThai"
    WHEN 'Chờ tiếp nhận' THEN p_trangthaimoi IN ('Đã tiếp nhận', 'Đã hủy')
    WHEN 'Đã tiếp nhận' THEN p_trangthaimoi IN ('Đang giặt', 'Đã hủy')
    WHEN 'Đang giặt' THEN p_trangthaimoi = 'Hoàn thành giặt'
    WHEN 'Hoàn thành giặt' THEN p_trangthaimoi IN ('Đang giao', 'Đã giao')
    WHEN 'Đang giao' THEN p_trangthaimoi = 'Đã giao'
    ELSE false
  END;

  IF NOT valid_transition THEN
    RAISE EXCEPTION 'Invalid order status transition: % -> %',
      order_record."TrangThai", p_trangthaimoi;
  END IF;

  IF p_trangthaimoi = 'Đã hủy' AND nullif(btrim(p_lydo), '') IS NULL THEN
    RAISE EXCEPTION 'A cancellation reason is required';
  END IF;

  UPDATE public."DonHang"
  SET "TrangThai" = p_trangthaimoi,
      "NhanVienID" = coalesce(current_employee, "NhanVienID"),
      "NgayCapNhat" = now()
  WHERE "DonHangID" = p_donhangid;

  INSERT INTO public."NhatKyHeThong" (
    "TaiKhoanID", "HanhDong", "BangDuLieu", "BanGhiID",
    "DuLieuCu", "DuLieuMoi", "LyDo", "ThoiGian"
  ) VALUES (
    current_account,
    'Thay đổi trạng thái đơn hàng',
    'DonHang',
    p_donhangid,
    jsonb_build_object('TrangThai', order_record."TrangThai"),
    jsonb_build_object('TrangThai', p_trangthaimoi),
    nullif(left(btrim(p_lydo), 500), ''),
    now()
  );

  customer_account_id := private.account_id_for_customer(order_record."KhachHangID");

  IF customer_account_id IS NOT NULL THEN
    INSERT INTO public."ThongBao" (
      "TaiKhoanID", "TieuDe", "NoiDung", "ThoiGianGui", "DaDoc", "DonHangID", "LoaiThongBao"
    ) VALUES (
      customer_account_id,
      CASE WHEN p_trangthaimoi = 'Đã hủy'
        THEN 'Đơn hàng đã bị hủy'
        ELSE 'Cập nhật trạng thái đơn hàng'
      END,
      'Đơn hàng ' || order_record."MaDonHang" || ' đã chuyển sang trạng thái: ' || p_trangthaimoi || '.',
      now(),
      false,
      p_donhangid,
      CASE WHEN p_trangthaimoi = 'Đã hủy' THEN 'order_cancelled' ELSE 'status_update' END
    );
  END IF;
END;
$$;

CREATE OR REPLACE FUNCTION private.notify_customers_new_promotion()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO ''
AS $$
BEGIN
  IF NEW."TrangThai" = 'Hoạt động'
     AND NEW."NgayBatDau" <= CURRENT_DATE
     AND NEW."NgayKetThuc" >= CURRENT_DATE THEN
    INSERT INTO public."ThongBao" (
      "TaiKhoanID", "TieuDe", "NoiDung", "ThoiGianGui", "DaDoc", "DonHangID", "LoaiThongBao"
    )
    SELECT
      account."TaiKhoanID",
      'Có khuyến mãi mới',
      'Khuyến mãi ' || NEW."TenKhuyenMai" || ' (' || NEW."MaKhuyenMai" || ') đã sẵn sàng để sử dụng.',
      now(),
      false,
      NULL,
      'promotion'
    FROM public."TaiKhoan" AS account
    JOIN public."KhachHang" AS customer
      ON customer."KhachHangID" = account."KhachHangID"
    WHERE account."TrangThai" = 'Hoạt động'
      AND customer."TrangThai" = 'Hoạt động';
  END IF;

  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS notify_customers_new_promotion ON public."KhuyenMai";
CREATE TRIGGER notify_customers_new_promotion
  AFTER INSERT ON public."KhuyenMai"
  FOR EACH ROW
  EXECUTE FUNCTION private.notify_customers_new_promotion();

COMMIT;
