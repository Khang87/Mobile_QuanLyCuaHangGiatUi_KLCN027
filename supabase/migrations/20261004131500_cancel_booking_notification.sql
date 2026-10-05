BEGIN;

CREATE OR REPLACE FUNCTION public.cancel_laundry_booking (
  p_bookingid bigint
)
  RETURNS void
  LANGUAGE plpgsql
  SECURITY DEFINER
  SET search_path TO ''
  AS $$
DECLARE
    customer_id bigint :=
        (SELECT private.current_customer_id());

    booking_row public."Booking"%ROWTYPE;
    
    v_staff_id bigint;
    v_staff_cursor cursor for
      select distinct tvr."TaiKhoanID"
      from public."TaiKhoan_VaiTro" tvr
      join public."VaiTro" vr on tvr."VaiTroID" = vr."VaiTroID"
      where vr."TenVaiTro" in ('Nhân viên', 'Quản lý', 'Chủ cửa hàng')
      and tvr."TrangThai" = 'Hoạt động';
      
    v_customer_name text;
BEGIN

    -- Kiểm tra khách hàng đăng nhập
    IF (SELECT auth.uid()) IS NULL
       OR customer_id IS NULL THEN

        RAISE EXCEPTION
            'An active customer account is required';

    END IF;


    -- Khóa Booking để tránh cập nhật đồng thời
    SELECT *
    INTO booking_row
    FROM public."Booking"
    WHERE "BookingID" = p_bookingid
      AND "KhachHangID" = customer_id
    FOR UPDATE;


    IF NOT FOUND THEN

        RAISE EXCEPTION
            'Booking not found';

    END IF;


    -- Chỉ Booking đang chờ tiếp nhận mới được hủy
    IF booking_row."TrangThai" <> 'ChoTiepNhan'
       OR EXISTS (
            SELECT 1
            FROM public."DonHang"
            WHERE "BookingID" = p_bookingid
       ) THEN

        RAISE EXCEPTION
            'Only pending bookings can be canceled';

    END IF;


    UPDATE public."Booking"
    SET
        "TrangThai" = 'DaHuy',
        "NgayCapNhat" = now()
    WHERE "BookingID" = p_bookingid;

    -- Lấy tên khách hàng
    SELECT "HoTen" INTO v_customer_name
    FROM public."TaiKhoan"
    WHERE "TaiKhoanID" = customer_id;

    -- Gửi thông báo cho nhân viên
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
        'Có đơn đặt giặt bị hủy',
        'Khách hàng ' || coalesce(v_customer_name, 'Khách hàng') || ' vừa hủy lịch giặt ' || booking_row."MaBooking" || '.',
        now(),
        false,
        p_bookingid,
        'booking_cancelled'
      );
    end loop;
    close v_staff_cursor;

END;
$$;

COMMIT;
