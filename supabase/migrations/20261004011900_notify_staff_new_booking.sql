-- Create RPC function to notify staff of new bookings
create or replace function notify_staff_new_booking(
  p_bookingid bigint,
  p_booking_number varchar,
  p_customer_name varchar
)
returns void as $$
declare
  v_staff_id bigint;
  v_staff_cursor cursor for
    select distinct tvr.taikhoanid
    from taikhoan_vaitro tvr
    join vaitro vr on tvr.vaitroid = vr.vaitroid
    where vr.tenvaitro in ('Nhân viên', 'Quản lý', 'Chủ cửa hàng')
    and tvr.trangthai = 'Hoạt động';
begin
  open v_staff_cursor;
  loop
    fetch v_staff_cursor into v_staff_id;
    exit when not found;
    
    insert into thongbao (
      taikhoanid,
      tieude,
      noidung,
      thoigiangui,
      dadoc,
      donhangid,
      loaithongbao
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
end;
$$ language plpgsql;
