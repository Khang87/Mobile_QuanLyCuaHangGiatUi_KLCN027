BEGIN;
CREATE OR REPLACE FUNCTION public.notify_staff_new_booking(
  p_bookingid bigint,
  p_booking_number varchar,
  p_customer_name varchar
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
DECLARE
  v_staff_id bigint;
  v_staff_cursor cursor for
    select distinct tvr."TaiKhoanID"
    from public."TaiKhoan_VaiTro" tvr
    join public."VaiTro" vr on tvr."VaiTroID" = vr."VaiTroID"
    where vr."TenVaiTro" in ('Nhân viên', 'Quản lý', 'Chủ cửa hàng')
    and tvr."TrangThai" = 'Hoạt động';
BEGIN
  open v_staff_cursor;
  loop
    fetch v_staff_cursor into v_staff_id;
    exit when not found;
    
    insert into public."ThongBao" (
      "TaiKhoanID",
      "TieuDe",
      "NoiDung",
      "ThoiGianGui",
      "DaDoc",
      "DonHangID",
      "LoaiThongBao"
    ) values (
      v_staff_id,
      'Có đơn đặt giặt mới',
      'Khách hàng ' || p_customer_name || ' vừa đặt lịch giặt ' || p_booking_number || '. Vui lòng xem và xác nhận.',
      now(),
      false,
      p_bookingid,
      'new_booking'
    );
  end loop;
  close v_staff_cursor;
END;
$$;
COMMIT;
