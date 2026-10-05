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
	order_record public.donhang%ROWTYPE;
	valid_transition boolean := false;
	current_employee bigint := (SELECT private.current_employee_id());
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
	FROM public.donhang
	WHERE donhangid = p_donhangid
	FOR UPDATE;

	IF NOT FOUND THEN
		RAISE EXCEPTION 'Order not found';
	END IF;

	valid_transition := CASE order_record.trangthai
		WHEN 'Chờ tiếp nhận' THEN p_trangthaimoi IN ('Đã tiếp nhận', 'Đã hủy')
		WHEN 'Đã tiếp nhận' THEN p_trangthaimoi IN ('Đang giặt', 'Đã hủy')
		WHEN 'Đang giặt' THEN p_trangthaimoi = 'Hoàn thành giặt'
		WHEN 'Hoàn thành giặt' THEN p_trangthaimoi IN ('Đang giao', 'Đã giao')
		WHEN 'Đang giao' THEN p_trangthaimoi = 'Đã giao'
		ELSE false
	END;

	IF NOT valid_transition THEN
		RAISE EXCEPTION 'Invalid order status transition: % -> %',
			order_record.trangthai, p_trangthaimoi;
	END IF;

	IF p_trangthaimoi = 'Đã hủy'
		 AND nullif(btrim(p_lydo), '') IS NULL THEN
		RAISE EXCEPTION 'A cancellation reason is required';
	END IF;

	UPDATE public.donhang
	SET trangthai = p_trangthaimoi,
		  nhanvienid = coalesce(current_employee, nhanvienid),
			ngaycapnhat = now()
	WHERE donhangid = p_donhangid;

	IF p_lydo IS NOT NULL AND btrim(p_lydo) <> '' THEN
		UPDATE public.donhang_trangthai
		SET lydo = left(btrim(p_lydo), 500)
		WHERE donhangid = p_donhangid
			AND trangthaimoi = p_trangthaimoi
			AND trangthaicu = order_record.trangthai
			AND thoigian = (
				SELECT max(event.thoigian)
				FROM public.donhang_trangthai AS event
				WHERE event.donhangid = p_donhangid
			);
	END IF;
END;
$$;

REVOKE ALL ON FUNCTION public.transition_laundry_order(bigint, text, text)
	FROM PUBLIC, anon, authenticated, service_role;
GRANT EXECUTE ON FUNCTION public.transition_laundry_order(bigint, text, text)
	TO authenticated;

COMMIT;
