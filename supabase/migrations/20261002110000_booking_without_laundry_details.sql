-- Allow customers to create a pickup booking before they know its laundry items.
-- Staff will inspect the laundry and add the final order details during processing.

CREATE OR REPLACE FUNCTION public.submit_laundry_booking_without_details(
  p_hinhthucnhando text,
  p_diachinhan text,
  p_ngayhen date,
  p_giohen time without time zone,
  p_ghichu text,
  p_idempotency_key uuid
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO ''
AS $function$
DECLARE
  customer_id bigint := (SELECT private.current_customer_id());
  existing_booking record;
  booking_id bigint;
  booking_number text;
BEGIN
  IF customer_id IS NULL THEN
    RAISE EXCEPTION 'Authentication required';
  END IF;

  SELECT * INTO existing_booking
  FROM public."Booking"
  WHERE "IdempotencyKey" = p_idempotency_key
    AND "KhachHangID" = customer_id;

  IF FOUND THEN
    RETURN jsonb_build_object(
      'bookingid', existing_booking."BookingID",
      'mabooking', existing_booking."MaBooking",
      'trangthai', existing_booking."TrangThai",
      'thanhtien', 0,
      'itemcount', 0
    );
  END IF;

  booking_number := 'BK-' || to_char(clock_timestamp(), 'YYYYMMDDHH24MISS') ||
    '-' || substr(replace(gen_random_uuid()::text, '-', ''), 1, 8);

  INSERT INTO public."Booking" (
    "MaBooking", "KhachHangID", "HinhThucNhanDo", "DiaChiNhan",
    "NgayHen", "GioHen", "GhiChu", "TrangThai", "IdempotencyKey"
  ) VALUES (
    booking_number, customer_id, p_hinhthucnhando,
    nullif(btrim(p_diachinhan), ''), p_ngayhen, p_giohen,
    nullif(btrim(p_ghichu), ''), 'ChoTiepNhan', p_idempotency_key
  ) RETURNING "BookingID" INTO booking_id;

  RETURN jsonb_build_object(
    'bookingid', booking_id,
    'mabooking', booking_number,
    'trangthai', 'ChoTiepNhan',
    'thanhtien', 0,
    'itemcount', 0
  );
END;
$function$;

-- This fallback is deliberately restricted to bookings without customer-supplied
-- details. Bookings with details continue using confirm_laundry_booking.
CREATE OR REPLACE FUNCTION public.confirm_laundry_booking_without_details(
  p_bookingid bigint
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO ''
AS $function$
DECLARE
  booking_row public."Booking"%ROWTYPE;
  order_id bigint;
  order_number text;
  current_employee bigint := (SELECT private.current_employee_id());
  pickup_at timestamptz;
BEGIN
  IF (SELECT auth.uid()) IS NULL
    OR NOT (SELECT private.is_staff())
    OR (current_employee IS NULL
        AND NOT (SELECT private.has_role('Quản lý'))
        AND NOT (SELECT private.has_role('Chủ cửa hàng'))) THEN
    RAISE EXCEPTION 'An active staff account is required';
  END IF;

  SELECT * INTO booking_row
  FROM public."Booking"
  WHERE "BookingID" = p_bookingid
  FOR UPDATE;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Booking not found';
  END IF;

  SELECT "DonHangID" INTO order_id
  FROM public."DonHang"
  WHERE "BookingID" = p_bookingid;
  IF order_id IS NOT NULL THEN
    RETURN jsonb_build_object('donhangid', order_id, 'bookingid', p_bookingid);
  END IF;

  IF booking_row."TrangThai" <> 'ChoTiepNhan' THEN
    RAISE EXCEPTION 'Only pending bookings can be confirmed';
  END IF;

  IF EXISTS (
    SELECT 1 FROM public."ChiTietBooking"
    WHERE "BookingID" = p_bookingid
  ) THEN
    RAISE EXCEPTION 'Booking already contains laundry details';
  END IF;

  order_number := 'DH-' || to_char(clock_timestamp(), 'YYYYMMDDHH24MISS') ||
    '-' || substr(replace(gen_random_uuid()::text, '-', ''), 1, 8);

  INSERT INTO public."DonHang" (
    "MaDonHang", "BookingID", "KhachHangID", "NhanVienID", "TrangThai",
    "TongTien", "PhiGiaoHang", "ThanhTien", "GhiChu"
  ) VALUES (
    order_number, p_bookingid, booking_row."KhachHangID", current_employee,
    'Đã tiếp nhận', 0, 0, 0,
    coalesce(booking_row."GhiChu" || E'\n', '') ||
      'Khách hàng yêu cầu cửa hàng kiểm nhận và báo giá.'
  ) RETURNING "DonHangID" INTO order_id;

  IF booking_row."HinhThucNhanDo" = 'Tại nhà' THEN
    pickup_at := (booking_row."NgayHen" + booking_row."GioHen")
      AT TIME ZONE 'Asia/Ho_Chi_Minh';
    INSERT INTO public."GiaoNhan" (
      "DonHangID", "LoaiGiaoNhan", "HinhThuc", "DiaChi",
      "ThoiGianDuKien", "TrangThai"
    ) VALUES (
      order_id, 'NHAN_DO', 'Tại nhà', booking_row."DiaChiNhan", pickup_at,
      'Chờ thực hiện'
    );
  END IF;

  UPDATE public."Booking"
  SET "TrangThai" = 'DaXacNhan',
      "NhanVienXacNhanID" = current_employee,
      "ThoiGianXacNhan" = now(),
      "NgayCapNhat" = now()
  WHERE "BookingID" = p_bookingid;

  RETURN jsonb_build_object(
    'donhangid', order_id,
    'madonhang', order_number,
    'bookingid', p_bookingid,
    'trangthai', 'Đã tiếp nhận',
    'tongtien', 0,
    'sochitiet', 0
  );
END;
$function$;

GRANT EXECUTE ON FUNCTION public.submit_laundry_booking_without_details TO authenticated;
GRANT EXECUTE ON FUNCTION public.confirm_laundry_booking_without_details TO authenticated;
