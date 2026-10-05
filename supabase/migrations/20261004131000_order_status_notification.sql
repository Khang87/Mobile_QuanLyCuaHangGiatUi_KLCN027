BEGIN;

CREATE OR REPLACE FUNCTION public.transition_laundry_order(
	p_donhangid bigint,
	p_trangthaimoi text,
	p_lydo text DEFAULT NULL
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
DECLARE
	order_record public."DonHang"%ROWTYPE;
	valid_transition boolean := false;
	current_employee bigint := (SELECT private.current_employee_id());
    v_customer_id bigint;
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

	SELECT * INTO order_record
	FROM public."DonHang"
	WHERE "DonHangID" = p_donhangid
	FOR UPDATE;

	IF NOT FOUND THEN
		RAISE EXCEPTION 'Order not found';
	END IF;

    -- Get customer ID from booking
    SELECT "KhachHangID" INTO v_customer_id
    FROM public."Booking"
    WHERE "BookingID" = order_record."BookingID";

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

	IF p_trangthaimoi = 'Đã hủy'
		 AND nullif(btrim(p_lydo), '') IS NULL THEN
		RAISE EXCEPTION 'A cancellation reason is required';
	END IF;

	UPDATE public."DonHang"
	SET "TrangThai" = p_trangthaimoi,
		  "NhanVienID" = coalesce(current_employee, "NhanVienID"),
			"NgayCapNhat" = now()
	WHERE "DonHangID" = p_donhangid;

	IF p_lydo IS NOT NULL AND btrim(p_lydo) <> '' THEN
		UPDATE public."DonHang_TrangThai"
		SET "LyDo" = left(btrim(p_lydo), 500)
		WHERE "DonHangID" = p_donhangid
			AND "TrangThaiMoi" = p_trangthaimoi
			AND "TrangThaiCu" = order_record."TrangThai"
			AND "ThoiGian" = (
				SELECT max(event."ThoiGian")
				FROM public."DonHang_TrangThai" AS event
				WHERE event."DonHangID" = p_donhangid
			);
	END IF;

    -- Send notification to customer
    IF v_customer_id IS NOT NULL THEN
        INSERT INTO public."ThongBao" (
            "TaiKhoanID", "TieuDe", "NoiDung", "DonHangID", "LoaiThongBao"
        ) VALUES (
            v_customer_id,
            'Cập nhật trạng thái đơn hàng',
            'Đơn hàng ' || coalesce(order_record."MaDonHang", '') || ' của bạn đã được cập nhật sang: ' || p_trangthaimoi,
            p_donhangid,
            'status_update'
        );
    END IF;
END;
$$;

COMMIT;
