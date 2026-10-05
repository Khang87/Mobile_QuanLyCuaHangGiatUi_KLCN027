BEGIN;

CREATE TABLE public.khachhang_diachi (
	diachiid bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	khachhangid bigint NOT NULL
		REFERENCES public.khachhang (khachhangid) ON DELETE CASCADE,
	tennguoinhan character varying(100) NOT NULL,
	sodienthoai character varying(15) NOT NULL,
	diachi character varying(500) NOT NULL,
	ghichu character varying(500),
	macdinh boolean NOT NULL DEFAULT false,
	ngaytao timestamp with time zone NOT NULL DEFAULT now(),
	CONSTRAINT khachhang_diachi_sodienthoai_check
		CHECK (length(btrim(sodienthoai)) >= 8),
	CONSTRAINT khachhang_diachi_diachi_check
		CHECK (length(btrim(diachi)) > 0)
);

CREATE INDEX khachhang_diachi_khachhangid_idx
	ON public.khachhang_diachi (khachhangid);
CREATE UNIQUE INDEX khachhang_diachi_one_default_idx
	ON public.khachhang_diachi (khachhangid)
	WHERE macdinh;

ALTER TABLE public.khachhang_diachi ENABLE ROW LEVEL SECURITY;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.khachhang_diachi
	TO authenticated;
GRANT USAGE ON SEQUENCE public.khachhang_diachi_diachiid_seq
	TO authenticated;

CREATE POLICY khachhang_diachi_owner_select
	ON public.khachhang_diachi FOR SELECT TO authenticated
	USING (khachhangid = (SELECT private.current_customer_id()));
CREATE POLICY khachhang_diachi_owner_insert
	ON public.khachhang_diachi FOR INSERT TO authenticated
	WITH CHECK (khachhangid = (SELECT private.current_customer_id()));
CREATE POLICY khachhang_diachi_owner_update
	ON public.khachhang_diachi FOR UPDATE TO authenticated
	USING (khachhangid = (SELECT private.current_customer_id()))
	WITH CHECK (khachhangid = (SELECT private.current_customer_id()));
CREATE POLICY khachhang_diachi_owner_delete
	ON public.khachhang_diachi FOR DELETE TO authenticated
	USING (khachhangid = (SELECT private.current_customer_id()));

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
	IF nullif(btrim(p_tennguoinhan), '') IS NULL
		 OR nullif(btrim(p_sodienthoai), '') IS NULL
		 OR nullif(btrim(p_diachi), '') IS NULL THEN
		RAISE EXCEPTION 'Recipient, phone, and address are required';
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
			btrim(p_tennguoinhan),
			btrim(p_sodienthoai),
			btrim(p_diachi),
			nullif(btrim(p_ghichu), ''),
			false
		) RETURNING diachiid INTO address_id;
	ELSE
		UPDATE public.khachhang_diachi
		SET tennguoinhan = btrim(p_tennguoinhan),
				sodienthoai = btrim(p_sodienthoai),
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

REVOKE ALL ON FUNCTION public.save_customer_address(
	bigint, text, text, text, text, boolean
) FROM PUBLIC, anon, authenticated, service_role;
GRANT EXECUTE ON FUNCTION public.save_customer_address(
	bigint, text, text, text, text, boolean
) TO authenticated;

COMMIT;
