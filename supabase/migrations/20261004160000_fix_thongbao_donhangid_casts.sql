BEGIN;

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
    "TaiKhoanID", "TieuDe", "NoiDung", "ThoiGianGui", "DaDoc", "DonHangID", "LoaiThongBao"
  )
  SELECT DISTINCT
    account_role."TaiKhoanID"::integer,
    'Có yêu cầu đặt giặt mới'::varchar,
    ('Khách hàng ' || coalesce(nullif(btrim(p_customer_name), ''), 'Khách hàng') ||
      ' vừa gửi yêu cầu ' || coalesce(nullif(btrim(p_booking_number), ''), '#' || p_bookingid::text) || '.')::varchar,
    now()::timestamp,
    false,
    NULL::integer,
    'new_booking'::varchar
  FROM public."TaiKhoan_VaiTro" AS account_role
  JOIN public."VaiTro" AS role
    ON role."VaiTroID" = account_role."VaiTroID"
  JOIN public."TaiKhoan" AS account
    ON account."TaiKhoanID" = account_role."TaiKhoanID"
  WHERE role."TenVaiTro" IN ('Nhân viên', 'Quản lý', 'Chủ cửa hàng')
    AND role."TrangThai" = 'Hoạt động'
    AND account."TrangThai" = 'Hoạt động'
    AND NOT EXISTS (
      SELECT 1
      FROM public."ThongBao" AS notification
      WHERE notification."TaiKhoanID" = account_role."TaiKhoanID"
        AND notification."LoaiThongBao" = 'new_booking'
        AND notification."DonHangID" IS NULL
        AND notification."NoiDung" LIKE '%' || coalesce(nullif(btrim(p_booking_number), ''), '#' || p_bookingid::text) || '%'
    );
END;
$$;

CREATE OR REPLACE FUNCTION private.notify_booking_created()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO ''
AS $$
DECLARE
  customer_account_id bigint;
  customer_name text;
BEGIN
  customer_account_id := private.account_id_for_customer(NEW."KhachHangID");

  SELECT "HoTen"
  INTO customer_name
  FROM public."KhachHang"
  WHERE "KhachHangID" = NEW."KhachHangID";

  IF customer_account_id IS NOT NULL THEN
    INSERT INTO public."ThongBao" (
      "TaiKhoanID", "TieuDe", "NoiDung", "ThoiGianGui", "DaDoc", "DonHangID", "LoaiThongBao"
    )
    SELECT
      customer_account_id::integer,
      'Yêu cầu đặt giặt đã gửi'::varchar,
      ('Yêu cầu ' || NEW."MaBooking" || ' đã được gửi. Cửa hàng sẽ tiếp nhận trong thời gian sớm nhất.')::varchar,
      now()::timestamp,
      false,
      NULL::integer,
      'order_created'::varchar
    WHERE NOT EXISTS (
      SELECT 1
      FROM public."ThongBao" AS notification
      WHERE notification."TaiKhoanID" = customer_account_id
        AND notification."LoaiThongBao" = 'order_created'
        AND notification."DonHangID" IS NULL
        AND notification."NoiDung" LIKE '%' || NEW."MaBooking" || '%'
    );
  END IF;

  PERFORM public.notify_staff_new_booking(
    NEW."BookingID",
    NEW."MaBooking",
    customer_name
  );

  RETURN NEW;
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
      account."TaiKhoanID"::integer,
      'Có khuyến mãi mới'::varchar,
      ('Khuyến mãi ' || NEW."TenKhuyenMai" || ' (' || NEW."MaKhuyenMai" || ') đã sẵn sàng để sử dụng.')::varchar,
      now()::timestamp,
      false,
      NULL::integer,
      'promotion'::varchar
    FROM public."TaiKhoan" AS account
    JOIN public."KhachHang" AS customer
      ON customer."KhachHangID" = account."KhachHangID"
    WHERE account."TrangThai" = 'Hoạt động'
      AND customer."TrangThai" = 'Hoạt động';
  END IF;

  RETURN NEW;
END;
$$;

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

  RETURN booking_result || jsonb_build_object(
    'thanhtien', total_amount,
    'diemsudung', booking_row."DiemSuDung",
    'tiengiamdodiem', booking_row."TienGiamDoDiem",
    'thanhtoan', GREATEST(total_amount - booking_row."TienGiamDoDiem", 0),
    'diemconlai', COALESCE(remaining_points, 0)
  );
END;
$$;

COMMIT;
