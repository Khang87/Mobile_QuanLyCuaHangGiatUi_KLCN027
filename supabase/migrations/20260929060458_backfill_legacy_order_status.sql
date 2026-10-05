DO $migration$
BEGIN
	IF to_regclass('public."DonHang"') IS NOT NULL
			AND to_regclass('public.donhang_trangthai') IS NOT NULL THEN
		INSERT INTO public.donhang_trangthai (
			donhangid, taikhoanid, trangthaicu, trangthaimoi, thoigian
		)
		SELECT order_record."DonHangID", NULL, NULL, order_record."TrangThai",
			COALESCE(order_record."NgayTao"::timestamptz, now())
		FROM public."DonHang" AS order_record
		WHERE NOT EXISTS (
			SELECT 1 FROM public.donhang_trangthai AS event
			WHERE event.donhangid = order_record."DonHangID"
		);
	END IF;
END;
$migration$;
