BEGIN;

DO $booking_schema$
DECLARE
	booking_is_view boolean := (
		SELECT relation.relkind = 'v'
		FROM pg_catalog.pg_class AS relation
		WHERE relation.oid = pg_catalog.to_regclass('public.booking')
	);
BEGIN
	IF booking_is_view THEN
		ALTER TABLE public."Booking"
			ADD COLUMN IF NOT EXISTS "IdempotencyKey" uuid,
			ADD COLUMN IF NOT EXISTS "DichVuID" integer
				REFERENCES public."DichVu" ("DichVuID"),
			ADD COLUMN IF NOT EXISTS "LoaiDoGiatID" integer
				REFERENCES public."LoaiDoGiat" ("LoaiDoGiatID"),
			ADD COLUMN IF NOT EXISTS "DonViTinhID" integer
				REFERENCES public."DonViTinh" ("DonViTinhID"),
			ADD COLUMN IF NOT EXISTS "SoLuong" numeric(10,2),
			ADD COLUMN IF NOT EXISTS "KhoiLuong" numeric(10,2),
			ADD COLUMN IF NOT EXISTS "DonGia" numeric(18,2),
			ADD COLUMN IF NOT EXISTS "ThanhTien" numeric(18,2);

		CREATE UNIQUE INDEX IF NOT EXISTS booking_idempotency_key_unique_idx
			ON public."Booking" ("IdempotencyKey")
			WHERE "IdempotencyKey" IS NOT NULL;
		CREATE UNIQUE INDEX IF NOT EXISTS donhang_bookingid_unique_idx
			ON public."DonHang" ("BookingID")
			WHERE "BookingID" IS NOT NULL;

		ALTER TABLE public."Booking"
			DROP CONSTRAINT IF EXISTS "Booking_TrangThai_check",
			ALTER COLUMN "TrangThai" SET DEFAULT 'ChoTiepNhan';

		CREATE OR REPLACE VIEW public.booking
			WITH (security_invoker = true)
		AS
		SELECT
			"BookingID" AS bookingid,
			"MaBooking" AS mabooking,
			"KhachHangID" AS khachhangid,
			"HinhThucNhanDo" AS hinhthucnhando,
			"DiaChiNhan" AS diachinhan,
			"NgayHen" AS ngayhen,
			"GioHen" AS giohen,
			"GhiChu" AS ghichu,
			"TrangThai" AS trangthai,
			"NgayTao" AS ngaytao,
			"NgayCapNhat" AS ngaycapnhat,
			"IdempotencyKey" AS idempotency_key,
			"DichVuID" AS dichvuid,
			"LoaiDoGiatID" AS loaidogiatid,
			"DonViTinhID" AS donvitinhid,
			"SoLuong" AS soluong,
			"KhoiLuong" AS khoiluong,
			"DonGia" AS dongia,
			"ThanhTien" AS thanhtien
		FROM public."Booking";
	ELSE
		ALTER TABLE public.booking
			ADD COLUMN IF NOT EXISTS idempotency_key uuid,
			ADD COLUMN IF NOT EXISTS dichvuid bigint
				REFERENCES public.dichvu (dichvuid),
			ADD COLUMN IF NOT EXISTS loaidogiatid bigint
				REFERENCES public.loaidogiat (loaidogiatid),
			ADD COLUMN IF NOT EXISTS donvitinhid bigint
				REFERENCES public.donvitinh (donvitinhid),
			ADD COLUMN IF NOT EXISTS soluong numeric(10,2),
			ADD COLUMN IF NOT EXISTS khoiluong numeric(10,2),
			ADD COLUMN IF NOT EXISTS dongia numeric(18,2),
			ADD COLUMN IF NOT EXISTS thanhtien numeric(18,2);

		CREATE UNIQUE INDEX IF NOT EXISTS booking_idempotency_key_unique_idx
			ON public.booking (idempotency_key)
			WHERE idempotency_key IS NOT NULL;

		ALTER TABLE public.booking
			DROP CONSTRAINT IF EXISTS booking_trangthai_check,
			ALTER COLUMN trangthai SET DEFAULT 'ChoTiepNhan';
	END IF;
END;
$booking_schema$;

UPDATE public.booking AS booking
SET idempotency_key = order_record.idempotency_key
FROM public.donhang AS order_record
WHERE order_record.bookingid = booking.bookingid
	AND order_record.idempotency_key IS NOT NULL
	AND booking.idempotency_key IS NULL;

UPDATE public.booking AS booking
SET trangthai = CASE
	WHEN booking.trangthai IN ('Đã hủy', 'DaHuy')
		OR EXISTS (
			SELECT 1 FROM public.donhang AS order_record
			WHERE order_record.bookingid = booking.bookingid
				AND order_record.trangthai = 'Đã hủy'
		) THEN 'DaHuy'
	WHEN booking.trangthai IN ('Hoàn thành', 'HoanThanh') THEN 'HoanThanh'
	WHEN booking.trangthai IN ('Đã xác nhận', 'DaXacNhan')
		OR EXISTS (
			SELECT 1 FROM public.donhang AS order_record
			WHERE order_record.bookingid = booking.bookingid
		) THEN 'DaXacNhan'
	ELSE 'ChoTiepNhan'
END;

DO $booking_constraints$
DECLARE
	booking_is_view boolean := (
		SELECT relation.relkind = 'v'
		FROM pg_catalog.pg_class AS relation
		WHERE relation.oid = pg_catalog.to_regclass('public.booking')
	);
BEGIN
	IF booking_is_view THEN
		ALTER TABLE public."Booking"
			ADD CONSTRAINT booking_trangthai_check
				CHECK ("TrangThai" IN ('ChoTiepNhan', 'DaXacNhan', 'DaHuy', 'HoanThanh')),
			ADD CONSTRAINT booking_service_snapshot_check CHECK (
				(
					"DichVuID" IS NULL AND "LoaiDoGiatID" IS NULL
					AND "DonViTinhID" IS NULL AND "SoLuong" IS NULL
					AND "KhoiLuong" IS NULL AND "DonGia" IS NULL
					AND "ThanhTien" IS NULL
				)
				OR (
					"DichVuID" IS NOT NULL AND "LoaiDoGiatID" IS NOT NULL
					AND "DonViTinhID" IS NOT NULL AND "DonGia" IS NOT NULL
					AND "ThanhTien" IS NOT NULL AND "DonGia" >= 0
					AND "ThanhTien" >= 0
					AND (
						("SoLuong" > 0 AND "KhoiLuong" IS NULL)
						OR ("KhoiLuong" > 0 AND "SoLuong" IS NULL)
					)
				)
			);
	ELSE
		ALTER TABLE public.booking
			ADD CONSTRAINT booking_trangthai_check
				CHECK (trangthai IN ('ChoTiepNhan', 'DaXacNhan', 'DaHuy', 'HoanThanh')),
			ADD CONSTRAINT booking_service_snapshot_check CHECK (
				(
					dichvuid IS NULL AND loaidogiatid IS NULL AND donvitinhid IS NULL
					AND soluong IS NULL AND khoiluong IS NULL
					AND dongia IS NULL AND thanhtien IS NULL
				)
				OR (
					dichvuid IS NOT NULL AND loaidogiatid IS NOT NULL
					AND donvitinhid IS NOT NULL AND dongia IS NOT NULL AND thanhtien IS NOT NULL
					AND dongia >= 0 AND thanhtien >= 0
					AND (
						(soluong > 0 AND khoiluong IS NULL)
						OR (khoiluong > 0 AND soluong IS NULL)
					)
				)
			);
	END IF;
END;
$booking_constraints$;

CREATE OR REPLACE FUNCTION public.submit_laundry_order(
	p_banggiaid bigint,
	p_measurement numeric,
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
SET search_path = ''
AS $$
DECLARE
	customer_id bigint := (SELECT private.current_customer_id());
	existing_booking public.booking%ROWTYPE;
	price_row record;
	measurement numeric(10,2);
	line_total numeric(18,2);
	booking_id bigint;
	booking_number text;
	quantity numeric(10,2);
	weight_kg numeric(10,2);
BEGIN
	IF (SELECT auth.uid()) IS NULL OR customer_id IS NULL THEN
		RAISE EXCEPTION 'An active customer account is required';
	END IF;
	IF p_idempotency_key IS NULL THEN
		RAISE EXCEPTION 'An idempotency key is required';
	END IF;

	PERFORM pg_catalog.pg_advisory_xact_lock(
		pg_catalog.hashtextextended(p_idempotency_key::text, 0)
	);

	SELECT * INTO existing_booking
	FROM public.booking AS booking
	WHERE booking.idempotency_key = p_idempotency_key;

	IF FOUND THEN
		IF existing_booking.khachhangid <> customer_id THEN
			RAISE EXCEPTION 'Idempotency key is already in use';
		END IF;
		RETURN jsonb_build_object(
			'bookingid', existing_booking.bookingid,
			'mabooking', existing_booking.mabooking,
			'trangthai', existing_booking.trangthai,
			'thanhtien', coalesce(
				existing_booking.thanhtien,
				(SELECT order_record.thanhtien
				 FROM public.donhang AS order_record
				 WHERE order_record.bookingid = existing_booking.bookingid),
				0
			)
		);
	END IF;

	IF p_measurement IS NULL OR p_measurement <= 0
			OR p_measurement > 99999999.99
			OR p_measurement <> round(p_measurement, 2) THEN
		RAISE EXCEPTION 'Measurement must be positive and have at most two decimals';
	END IF;
	IF p_hinhthucnhando NOT IN ('Tại cửa hàng', 'Tại nhà') THEN
		RAISE EXCEPTION 'Unsupported pickup method';
	END IF;
	IF p_ngayhen IS NULL OR p_ngayhen < current_date
			OR p_ngayhen > current_date + 30 OR p_giohen IS NULL THEN
		RAISE EXCEPTION 'Pickup appointment must be within the next 30 days';
	END IF;
	IF p_hinhthucnhando = 'Tại nhà'
			AND nullif(btrim(p_diachinhan), '') IS NULL THEN
		RAISE EXCEPTION 'A pickup address is required';
	END IF;

	SELECT
		price.dichvuid,
		price.loaidogiatid,
		price.donvitinhid,
		price.dongia,
		unit.tendonvitinh,
		unit.kyhieu
	INTO price_row
	FROM public.banggia AS price
	JOIN public.dichvu AS service ON service.dichvuid = price.dichvuid
	JOIN public.loaidogiat AS item_type
		ON item_type.loaidogiatid = price.loaidogiatid
	JOIN public.donvitinh AS unit ON unit.donvitinhid = price.donvitinhid
	WHERE price.banggiaid = p_banggiaid
		AND price.trangthai = 'Hoạt động'
		AND price.ngayapdung <= current_date
		AND (price.ngayketthuc IS NULL OR price.ngayketthuc >= current_date)
		AND service.trangthai = 'Hoạt động'
		AND item_type.trangthai = 'Hoạt động'
		AND unit.trangthai = 'Hoạt động'
	FOR SHARE OF price;

	IF NOT FOUND THEN
		RAISE EXCEPTION 'The selected price is no longer available';
	END IF;

	measurement := p_measurement::numeric(10,2);
	line_total := round(price_row.dongia * measurement, 2);
	IF lower(coalesce(price_row.kyhieu, price_row.tendonvitinh)) IN ('kg', 'kilogram') THEN
		weight_kg := measurement;
		quantity := NULL;
	ELSE
		quantity := measurement;
		weight_kg := NULL;
	END IF;

	booking_number := 'BK-' || to_char(clock_timestamp(), 'YYYYMMDDHH24MISS') || '-' ||
		substr(replace(gen_random_uuid()::text, '-', ''), 1, 8);

	INSERT INTO public.booking (
		mabooking,
		khachhangid,
		hinhthucnhando,
		diachinhan,
		ngayhen,
		giohen,
		ghichu,
		trangthai,
		idempotency_key,
		dichvuid,
		loaidogiatid,
		donvitinhid,
		soluong,
		khoiluong,
		dongia,
		thanhtien
	) VALUES (
		booking_number,
		customer_id,
		p_hinhthucnhando,
		nullif(btrim(p_diachinhan), ''),
		p_ngayhen,
		p_giohen,
		nullif(btrim(p_ghichu), ''),
		'ChoTiepNhan',
		p_idempotency_key,
		price_row.dichvuid,
		price_row.loaidogiatid,
		price_row.donvitinhid,
		quantity,
		weight_kg,
		price_row.dongia,
		line_total
	) RETURNING bookingid INTO booking_id;

	RETURN jsonb_build_object(
		'bookingid', booking_id,
		'mabooking', booking_number,
		'trangthai', 'ChoTiepNhan',
		'thanhtien', line_total
	);
END;
$$;

CREATE OR REPLACE FUNCTION public.confirm_laundry_booking(p_bookingid bigint)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
DECLARE
	booking_row public.booking%ROWTYPE;
	order_id bigint;
	order_number text;
	current_employee bigint := (SELECT private.current_employee_id());
	pickup_at timestamp with time zone;
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

	SELECT * INTO booking_row
	FROM public.booking
	WHERE bookingid = p_bookingid
	FOR UPDATE;
	IF NOT FOUND THEN
		RAISE EXCEPTION 'Booking not found';
	END IF;

	IF booking_row.trangthai = 'DaXacNhan' THEN
		SELECT donhangid INTO order_id
		FROM public.donhang
		WHERE bookingid = p_bookingid;
		IF order_id IS NOT NULL THEN
			RETURN jsonb_build_object('donhangid', order_id, 'bookingid', p_bookingid);
		END IF;
	END IF;

	IF booking_row.trangthai <> 'ChoTiepNhan' THEN
		RAISE EXCEPTION 'Only pending bookings can be confirmed';
	END IF;
	IF booking_row.dichvuid IS NULL OR booking_row.loaidogiatid IS NULL
			OR booking_row.donvitinhid IS NULL OR booking_row.dongia IS NULL
			OR booking_row.thanhtien IS NULL THEN
		RAISE EXCEPTION 'Booking service details are incomplete';
	END IF;

	order_number := 'DH-' || to_char(clock_timestamp(), 'YYYYMMDDHH24MISS') || '-' ||
		substr(replace(gen_random_uuid()::text, '-', ''), 1, 8);

	INSERT INTO public.donhang (
		madonhang,
		bookingid,
		khachhangid,
		nhanvienid,
		trangthai,
		tongtien,
		phigiaohang,
		thanhtien,
		ghichu
	) VALUES (
		order_number,
		p_bookingid,
		booking_row.khachhangid,
		current_employee,
		'Đã tiếp nhận',
		booking_row.thanhtien,
		0,
		booking_row.thanhtien,
		booking_row.ghichu
	) RETURNING donhangid INTO order_id;

	INSERT INTO public.chitietdonhang (
		donhangid,
		dichvuid,
		loaidogiatid,
		donvitinhid,
		soluong,
		khoiluong,
		dongia,
		thanhtien,
		ghichu
	) VALUES (
		order_id,
		booking_row.dichvuid,
		booking_row.loaidogiatid,
		booking_row.donvitinhid,
		booking_row.soluong,
		booking_row.khoiluong,
		booking_row.dongia,
		booking_row.thanhtien,
		booking_row.ghichu
	);

	IF booking_row.hinhthucnhando = 'Tại nhà' THEN
		pickup_at := (booking_row.ngayhen + booking_row.giohen)
			AT TIME ZONE 'Asia/Ho_Chi_Minh';
		INSERT INTO public.giaonhan (
			donhangid,
			loaigiaonhan,
			hinhthuc,
			diachi,
			thoigiandukien,
			trangthai
		) VALUES (
			order_id,
			'NHAN_DO',
			'Tại nhà',
			booking_row.diachinhan,
			pickup_at,
			'Chờ thực hiện'
		);
	END IF;

	UPDATE public.booking
	SET trangthai = 'DaXacNhan', ngaycapnhat = now()
	WHERE bookingid = p_bookingid;

	RETURN jsonb_build_object('donhangid', order_id, 'bookingid', p_bookingid);
END;
$$;

CREATE OR REPLACE FUNCTION public.cancel_laundry_booking(p_bookingid bigint)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
DECLARE
	customer_id bigint := (SELECT private.current_customer_id());
	booking_row public.booking%ROWTYPE;
BEGIN
	IF (SELECT auth.uid()) IS NULL OR customer_id IS NULL THEN
		RAISE EXCEPTION 'An active customer account is required';
	END IF;

	SELECT * INTO booking_row
	FROM public.booking
	WHERE bookingid = p_bookingid AND khachhangid = customer_id
	FOR UPDATE;
	IF NOT FOUND THEN
		RAISE EXCEPTION 'Booking not found';
	END IF;
	IF booking_row.trangthai <> 'ChoTiepNhan'
			OR EXISTS (
				SELECT 1 FROM public.donhang
				WHERE bookingid = p_bookingid
			) THEN
		RAISE EXCEPTION 'Only pending bookings can be canceled';
	END IF;

	UPDATE public.booking
	SET trangthai = 'DaHuy', ngaycapnhat = now()
	WHERE bookingid = p_bookingid;
END;
$$;

REVOKE ALL ON FUNCTION public.submit_laundry_order(
	bigint, numeric, text, text, date, time without time zone, text, uuid
) FROM PUBLIC, anon, authenticated, service_role;
GRANT EXECUTE ON FUNCTION public.submit_laundry_order(
	bigint, numeric, text, text, date, time without time zone, text, uuid
) TO authenticated;

REVOKE ALL ON FUNCTION public.confirm_laundry_booking(bigint)
	FROM PUBLIC, anon, authenticated, service_role;
GRANT EXECUTE ON FUNCTION public.confirm_laundry_booking(bigint)
	TO authenticated;

REVOKE ALL ON FUNCTION public.cancel_laundry_booking(bigint)
	FROM PUBLIC, anon, authenticated, service_role;
GRANT EXECUTE ON FUNCTION public.cancel_laundry_booking(bigint)
	TO authenticated;

NOTIFY pgrst, 'reload schema';

COMMIT;