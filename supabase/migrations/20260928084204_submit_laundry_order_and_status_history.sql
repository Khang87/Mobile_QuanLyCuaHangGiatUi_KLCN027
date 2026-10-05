BEGIN;

ALTER TABLE public.donhang
	ADD COLUMN IF NOT EXISTS idempotency_key uuid;

CREATE UNIQUE INDEX IF NOT EXISTS donhang_idempotency_key_unique_idx
	ON public.donhang (idempotency_key)
	WHERE idempotency_key IS NOT NULL;

CREATE TABLE public.donhang_trangthai (
	donhang_trangthaiid bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	donhangid bigint NOT NULL REFERENCES public.donhang (donhangid) ON DELETE CASCADE,
	taikhoanid bigint REFERENCES public.taikhoan (taikhoanid) ON DELETE SET NULL,
	trangthaicu character varying(30),
	trangthaimoi character varying(30) NOT NULL,
	lydo character varying(500),
	thoigian timestamp with time zone NOT NULL DEFAULT now()
);

ALTER TABLE public.donhang_trangthai ENABLE ROW LEVEL SECURITY;
GRANT SELECT ON public.donhang_trangthai TO authenticated;

CREATE POLICY donhang_trangthai_order_access_read
	ON public.donhang_trangthai FOR SELECT TO authenticated
	USING ((SELECT private.can_access_order(donhangid)));

CREATE OR REPLACE FUNCTION private.record_order_status_change()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
BEGIN
	IF TG_OP = 'INSERT' THEN
		INSERT INTO public.donhang_trangthai (
			donhangid,
			taikhoanid,
			trangthaicu,
			trangthaimoi
		) VALUES (
			NEW.donhangid,
			(SELECT private.current_account_id()),
			NULL,
			NEW.trangthai
		);
	ELSIF OLD.trangthai IS DISTINCT FROM NEW.trangthai THEN
		INSERT INTO public.donhang_trangthai (
			donhangid,
			taikhoanid,
			trangthaicu,
			trangthaimoi
		) VALUES (
			NEW.donhangid,
			(SELECT private.current_account_id()),
			OLD.trangthai,
			NEW.trangthai
		);
	END IF;

	RETURN NEW;
END;
$$;

REVOKE ALL ON FUNCTION private.record_order_status_change()
	FROM PUBLIC, anon, authenticated, service_role;

CREATE TRIGGER donhang_record_initial_status
	AFTER INSERT ON public.donhang
	FOR EACH ROW EXECUTE FUNCTION private.record_order_status_change();

CREATE TRIGGER donhang_record_status_change
	AFTER UPDATE OF trangthai ON public.donhang
	FOR EACH ROW EXECUTE FUNCTION private.record_order_status_change();

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
	existing_order public.donhang%ROWTYPE;
	price_row record;
	measurement numeric(10,2);
	line_total numeric(18,2);
	booking_id bigint;
	order_id bigint;
	order_number text;
	pickup_at timestamp with time zone;
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

	SELECT * INTO existing_order
	FROM public.donhang AS order_record
	WHERE order_record.idempotency_key = p_idempotency_key;

	IF FOUND THEN
		IF existing_order.khachhangid <> customer_id THEN
			RAISE EXCEPTION 'Idempotency key is already in use';
		END IF;
		RETURN jsonb_build_object(
			'donhangid', existing_order.donhangid,
			'madonhang', existing_order.madonhang,
			'bookingid', existing_order.bookingid,
			'tongtien', existing_order.tongtien,
			'phigiaohang', existing_order.phigiaohang,
			'thanhtien', existing_order.thanhtien
		);
	END IF;

	IF p_measurement IS NULL
		 OR p_measurement <= 0
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
	JOIN public.dichvu AS service
		ON service.dichvuid = price.dichvuid
	JOIN public.loaidogiat AS item_type
		ON item_type.loaidogiatid = price.loaidogiatid
	JOIN public.donvitinh AS unit
		ON unit.donvitinhid = price.donvitinhid
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

	INSERT INTO public.booking (
		mabooking,
		khachhangid,
		hinhthucnhando,
		diachinhan,
		ngayhen,
		giohen,
		ghichu
	) VALUES (
		'BK-' || to_char(clock_timestamp(), 'YYYYMMDDHH24MISS') || '-' ||
			substr(replace(gen_random_uuid()::text, '-', ''), 1, 8),
		customer_id,
		p_hinhthucnhando,
		nullif(btrim(p_diachinhan), ''),
		p_ngayhen,
		p_giohen,
		nullif(btrim(p_ghichu), '')
	) RETURNING bookingid INTO booking_id;

	order_number := 'DH-' || to_char(clock_timestamp(), 'YYYYMMDDHH24MISS') || '-' ||
		substr(replace(gen_random_uuid()::text, '-', ''), 1, 8);

	INSERT INTO public.donhang (
		madonhang,
		bookingid,
		khachhangid,
		trangthai,
		tongtien,
		phigiaohang,
		thanhtien,
		ghichu,
		idempotency_key
	) VALUES (
		order_number,
		booking_id,
		customer_id,
		'Chờ tiếp nhận',
		line_total,
		0,
		line_total,
		nullif(btrim(p_ghichu), ''),
		p_idempotency_key
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
		price_row.dichvuid,
		price_row.loaidogiatid,
		price_row.donvitinhid,
		quantity,
		weight_kg,
		price_row.dongia,
		line_total,
		nullif(btrim(p_ghichu), '')
	);

	IF p_hinhthucnhando = 'Tại nhà' THEN
		pickup_at := (p_ngayhen + p_giohen) AT TIME ZONE 'Asia/Ho_Chi_Minh';
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
			btrim(p_diachinhan),
			pickup_at,
			'Chờ thực hiện'
		);
	END IF;

	RETURN jsonb_build_object(
		'donhangid', order_id,
		'madonhang', order_number,
		'bookingid', booking_id,
		'tongtien', line_total,
		'phigiaohang', 0,
		'thanhtien', line_total
	);
END;
$$;

REVOKE ALL ON FUNCTION public.submit_laundry_order(
	bigint, numeric, text, text, date, time without time zone, text, uuid
) FROM PUBLIC, anon, authenticated, service_role;
GRANT EXECUTE ON FUNCTION public.submit_laundry_order(
	bigint, numeric, text, text, date, time without time zone, text, uuid
) TO authenticated;

COMMIT;
