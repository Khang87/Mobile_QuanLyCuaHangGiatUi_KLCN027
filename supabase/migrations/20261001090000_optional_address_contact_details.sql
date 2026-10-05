BEGIN;

ALTER TABLE public.khachhang_diachi
	ALTER COLUMN tennguoinhan DROP NOT NULL,
	ALTER COLUMN sodienthoai DROP NOT NULL,
	DROP CONSTRAINT khachhang_diachi_sodienthoai_check,
	ADD CONSTRAINT khachhang_diachi_sodienthoai_check
		CHECK (sodienthoai IS NULL OR length(btrim(sodienthoai)) >= 8);

CREATE OR REPLACE FUNCTION public.save_customer_address(
	p_diachiid bigint,
	p_tennguoinhan text,
	p_sodienthoai text,
	p_diachi text,
	p_ghichu text,
	p_macdinh boolean
)
RETURNS bigint
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
DECLARE
	customer_id bigint := (SELECT private.current_customer_id());
	address_id bigint;
BEGIN
	IF (SELECT auth.uid()) IS NULL OR customer_id IS NULL THEN
		RAISE EXCEPTION 'An active customer account is required';
	END IF;
	IF nullif(btrim(p_diachi), '') IS NULL THEN
		RAISE EXCEPTION 'Address is required';
	END IF;

	IF p_diachiid IS NULL THEN
		INSERT INTO public.khachhang_diachi (
			khachhangid,
			tennguoinhan,
			sodienthoai,
			diachi,
			ghichu,
			macdinh
		) VALUES (
			customer_id,
			nullif(btrim(p_tennguoinhan), ''),
			nullif(btrim(p_sodienthoai), ''),
			btrim(p_diachi),
			nullif(btrim(p_ghichu), ''),
			false
		) RETURNING diachiid INTO address_id;
	ELSE
		UPDATE public.khachhang_diachi
		SET tennguoinhan = nullif(btrim(p_tennguoinhan), ''),
			sodienthoai = nullif(btrim(p_sodienthoai), ''),
			diachi = btrim(p_diachi),
			ghichu = nullif(btrim(p_ghichu), '')
		WHERE diachiid = p_diachiid
			AND khachhangid = customer_id
		RETURNING diachiid INTO address_id;

		IF address_id IS NULL THEN
			RAISE EXCEPTION 'Address not found';
		END IF;
	END IF;

	IF coalesce(p_macdinh, false) THEN
		UPDATE public.khachhang_diachi
		SET macdinh = false
		WHERE khachhangid = customer_id
			AND macdinh;

		UPDATE public.khachhang_diachi
		SET macdinh = true
		WHERE diachiid = address_id
			AND khachhangid = customer_id;
	END IF;

	RETURN address_id;
END;
$$;

COMMIT;