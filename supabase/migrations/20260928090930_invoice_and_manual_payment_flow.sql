BEGIN;

ALTER TABLE public.thanhtoan
	ADD COLUMN IF NOT EXISTS idempotency_key uuid;

CREATE UNIQUE INDEX IF NOT EXISTS thanhtoan_idempotency_key_unique_idx
	ON public.thanhtoan (idempotency_key)
	WHERE idempotency_key IS NOT NULL;

CREATE OR REPLACE FUNCTION private.create_order_invoice()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
BEGIN
	INSERT INTO public.hoadon (
		mahoadon,
		donhangid,
		tongtien,
		giamgia,
		phigiaohang,
		thanhtien,
		trangthai
	) VALUES (
		'HD-' || to_char(clock_timestamp(), 'YYYYMMDDHH24MISS') || '-' ||
			substr(replace(gen_random_uuid()::text, '-', ''), 1, 8),
		NEW.donhangid,
		NEW.tongtien,
		NEW.tiengiamdodiem + NEW.tiengiamkhuyenmai,
		NEW.phigiaohang,
		NEW.thanhtien,
		'Chưa thanh toán'
	);
	RETURN NEW;
END;
$$;

REVOKE ALL ON FUNCTION private.create_order_invoice()
	FROM PUBLIC, anon, authenticated, service_role;

CREATE TRIGGER donhang_create_invoice
	AFTER INSERT ON public.donhang
	FOR EACH ROW EXECUTE FUNCTION private.create_order_invoice();

CREATE OR REPLACE FUNCTION public.request_order_payment(
	p_donhangid bigint,
	p_phuongthuc text,
	p_idempotency_key uuid
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
DECLARE
	customer_id bigint := (SELECT private.current_customer_id());
	order_record public.donhang%ROWTYPE;
	invoice public.hoadon%ROWTYPE;
	existing_payment public.thanhtoan%ROWTYPE;
	amount_due numeric(18,2);
	payment_id bigint;
BEGIN
	IF (SELECT auth.uid()) IS NULL OR customer_id IS NULL THEN
		RAISE EXCEPTION 'An active customer account is required';
	END IF;
	IF p_phuongthuc NOT IN ('Tiền mặt', 'Chuyển khoản') THEN
		RAISE EXCEPTION 'Unsupported payment method';
	END IF;
	IF p_idempotency_key IS NULL THEN
		RAISE EXCEPTION 'An idempotency key is required';
	END IF;

	PERFORM pg_catalog.pg_advisory_xact_lock(
		pg_catalog.hashtextextended(p_idempotency_key::text, 0)
	);

	SELECT * INTO existing_payment
	FROM public.thanhtoan
	WHERE idempotency_key = p_idempotency_key;
	IF FOUND THEN
		IF NOT EXISTS (
			SELECT 1 FROM public.donhang AS order_row
			WHERE order_row.donhangid = existing_payment.donhangid
				AND order_row.khachhangid = customer_id
		) THEN
			RAISE EXCEPTION 'Idempotency key is already in use';
		END IF;
		RETURN jsonb_build_object(
			'thanhtoanid', existing_payment.thanhtoanid,
			'sotien', existing_payment.sotien,
			'trangthai', existing_payment.trangthai,
			'phuongthuc', existing_payment.phuongthuc
		);
	END IF;

	SELECT * INTO order_record
	FROM public.donhang
	WHERE donhangid = p_donhangid
		AND khachhangid = customer_id
	FOR UPDATE;
	IF NOT FOUND THEN
		RAISE EXCEPTION 'Order not found';
	END IF;
	IF order_record.trangthai NOT IN ('Đã giao', 'Đã thanh toán') THEN
		RAISE EXCEPTION 'Payment is available after the order is delivered';
	END IF;

	SELECT * INTO invoice
	FROM public.hoadon
	WHERE donhangid = p_donhangid
	FOR UPDATE;
	IF NOT FOUND OR invoice.trangthai <> 'Chưa thanh toán' THEN
		RAISE EXCEPTION 'No unpaid invoice is available';
	END IF;

	SELECT greatest(
		invoice.thanhtien - coalesce(sum(payment.sotien) FILTER (
			WHERE payment.trangthai = 'Thành công'
		), 0),
		0
	) INTO amount_due
	FROM public.thanhtoan AS payment
	WHERE payment.donhangid = p_donhangid;

	IF amount_due <= 0 THEN
		RAISE EXCEPTION 'The invoice has no remaining balance';
	END IF;

	INSERT INTO public.thanhtoan (
		donhangid,
		phuongthuc,
		sotien,
		trangthai,
		idempotency_key,
		ghichu
	) VALUES (
		p_donhangid,
		p_phuongthuc,
		amount_due,
		'Chờ thanh toán',
		p_idempotency_key,
		CASE WHEN p_phuongthuc = 'Chuyển khoản'
			THEN 'Khách chọn chuyển khoản; chờ cửa hàng đối soát.'
			ELSE 'Khách chọn tiền mặt; chờ cửa hàng thu tiền.'
		END
	) RETURNING thanhtoanid INTO payment_id;

	RETURN jsonb_build_object(
		'thanhtoanid', payment_id,
		'sotien', amount_due,
		'trangthai', 'Chờ thanh toán',
		'phuongthuc', p_phuongthuc
	);
END;
$$;

CREATE OR REPLACE FUNCTION public.confirm_order_payment(
	p_thanhtoanid bigint,
	p_success boolean,
	p_ghichu text DEFAULT NULL
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
DECLARE
	current_employee bigint := (SELECT private.current_employee_id());
	payment public.thanhtoan%ROWTYPE;
	order_record public.donhang%ROWTYPE;
	invoice public.hoadon%ROWTYPE;
	paid_total numeric(18,2);
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

	SELECT * INTO payment
	FROM public.thanhtoan
	WHERE thanhtoanid = p_thanhtoanid
	FOR UPDATE;
	IF NOT FOUND OR payment.trangthai <> 'Chờ thanh toán' THEN
		RAISE EXCEPTION 'Pending payment not found';
	END IF;

	SELECT * INTO order_record
	FROM public.donhang
	WHERE donhangid = payment.donhangid
	FOR UPDATE;
	SELECT * INTO invoice
	FROM public.hoadon
	WHERE donhangid = payment.donhangid
	FOR UPDATE;

	IF p_success THEN
		UPDATE public.thanhtoan
		SET trangthai = 'Thành công',
				ghichu = left(coalesce(nullif(btrim(p_ghichu), ''), ghichu), 500)
		WHERE thanhtoanid = p_thanhtoanid;

		SELECT coalesce(sum(sotien), 0) INTO paid_total
		FROM public.thanhtoan
		WHERE donhangid = payment.donhangid
			AND trangthai = 'Thành công';

		IF paid_total >= invoice.thanhtien THEN
			UPDATE public.hoadon
			SET trangthai = 'Đã thanh toán'
			WHERE hoadonid = invoice.hoadonid;
			UPDATE public.donhang
			SET trangthai = 'Đã thanh toán', ngaycapnhat = now()
			WHERE donhangid = order_record.donhangid
				AND trangthai = 'Đã giao';
		END IF;
	ELSE
		UPDATE public.thanhtoan
		SET trangthai = 'Thất bại',
				ghichu = left(coalesce(nullif(btrim(p_ghichu), ''), ghichu), 500)
		WHERE thanhtoanid = p_thanhtoanid;
	END IF;
END;
$$;

REVOKE ALL ON FUNCTION public.request_order_payment(bigint, text, uuid)
	FROM PUBLIC, anon, authenticated, service_role;
GRANT EXECUTE ON FUNCTION public.request_order_payment(bigint, text, uuid)
	TO authenticated;
REVOKE ALL ON FUNCTION public.confirm_order_payment(bigint, boolean, text)
	FROM PUBLIC, anon, authenticated, service_role;
GRANT EXECUTE ON FUNCTION public.confirm_order_payment(bigint, boolean, text)
	TO authenticated;

COMMIT;
