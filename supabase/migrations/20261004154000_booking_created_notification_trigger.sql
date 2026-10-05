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
      customer_account_id,
      'Yêu cầu đặt giặt đã gửi',
      'Yêu cầu ' || NEW."MaBooking" || ' đã được gửi. Cửa hàng sẽ tiếp nhận trong thời gian sớm nhất.',
      now(),
      false,
      NULL,
      'order_created'
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

DROP TRIGGER IF EXISTS notify_booking_created ON public."Booking";
CREATE TRIGGER notify_booking_created
  AFTER INSERT ON public."Booking"
  FOR EACH ROW
  EXECUTE FUNCTION private.notify_booking_created();

COMMIT;
