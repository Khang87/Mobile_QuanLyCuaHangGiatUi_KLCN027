BEGIN;

ALTER TABLE public.taikhoan
	ALTER COLUMN matkhau DROP NOT NULL;

CREATE OR REPLACE FUNCTION private.normalize_phone(phone_number text)
RETURNS text
LANGUAGE sql
IMMUTABLE
SET search_path = ''
AS $$
	WITH digits AS (
		SELECT regexp_replace(coalesce(phone_number, ''), '[^0-9]', '', 'g') AS value
	)
	SELECT CASE
		WHEN value = '' THEN NULL
		WHEN value LIKE '84%' THEN '+' || value
		WHEN value LIKE '0%' THEN '+84' || substr(value, 2)
		ELSE '+' || value
	END
	FROM digits;
$$;

CREATE OR REPLACE FUNCTION public.complete_customer_profile(p_full_name text DEFAULT NULL)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
DECLARE
	current_user_id uuid := (SELECT auth.uid());
	verified_phone text;
	normalized_phone text;
	verified_email text;
	customer_name text := nullif(btrim(p_full_name), '');
	customer_id bigint;
	account_id bigint;
	account_count integer;
	customer_count integer;
	customer_role_id bigint;
BEGIN
	IF current_user_id IS NULL THEN
		RAISE EXCEPTION 'Authentication is required';
	END IF;

	SELECT users.phone, users.email
		INTO verified_phone, verified_email
	FROM auth.users AS users
	WHERE users.id = current_user_id
		AND users.phone_confirmed_at IS NOT NULL;

	IF verified_phone IS NULL THEN
		RAISE EXCEPTION 'A verified phone number is required';
	END IF;

	normalized_phone := private.normalize_phone(verified_phone);
	IF normalized_phone IS NULL THEN
		RAISE EXCEPTION 'A valid phone number is required';
	END IF;

	SELECT account.taikhoanid, account.khachhangid
		INTO account_id, customer_id
	FROM public.taikhoan AS account
	WHERE account.userauthid = current_user_id
		AND account.trangthai = 'Hoạt động';

	IF account_id IS NOT NULL THEN
		IF customer_id IS NOT NULL AND customer_name IS NOT NULL THEN
			UPDATE public.khachhang
			SET hoten = customer_name,
					email = coalesce(verified_email, email)
			WHERE khachhangid = customer_id;
		END IF;
		RETURN;
	END IF;

	SELECT count(*)::integer, min(account.taikhoanid)
		INTO account_count, account_id
	FROM public.taikhoan AS account
	WHERE private.normalize_phone(account.sodienthoai) = normalized_phone;

	IF account_count > 1 THEN
		RAISE EXCEPTION 'Multiple accounts use this phone number';
	END IF;

	IF account_id IS NOT NULL THEN
		SELECT account.khachhangid
			INTO customer_id
		FROM public.taikhoan AS account
		WHERE account.taikhoanid = account_id
		FOR UPDATE;

		IF customer_id IS NULL THEN
			RAISE EXCEPTION 'Staff accounts must be linked by a manager';
		END IF;

		UPDATE public.taikhoan
		SET userauthid = current_user_id,
			email = coalesce(verified_email, email)
		WHERE taikhoanid = account_id
			AND (userauthid IS NULL OR userauthid = current_user_id)
			AND trangthai = 'Hoạt động';

		IF NOT FOUND THEN
			RAISE EXCEPTION 'This customer account cannot be linked';
		END IF;

		IF customer_name IS NOT NULL THEN
			UPDATE public.khachhang
			SET hoten = customer_name,
				email = coalesce(verified_email, email)
			WHERE khachhangid = customer_id;
		END IF;
	ELSE
		SELECT count(*)::integer, min(customer.khachhangid)
			INTO customer_count, customer_id
		FROM public.khachhang AS customer
		WHERE private.normalize_phone(customer.sodienthoai) = normalized_phone;

		IF customer_count > 1 THEN
			RAISE EXCEPTION 'Multiple customer profiles use this phone number';
		END IF;

		IF customer_id IS NULL THEN
			IF customer_name IS NULL THEN
				RAISE EXCEPTION 'A full name is required to create a customer profile';
			END IF;

			INSERT INTO public.khachhang (hoten, sodienthoai, email)
			VALUES (customer_name, verified_phone, verified_email)
			RETURNING khachhangid INTO customer_id;
		ELSIF customer_name IS NOT NULL THEN
			UPDATE public.khachhang
			SET hoten = customer_name,
					email = coalesce(verified_email, email)
			WHERE khachhangid = customer_id;
		END IF;

		SELECT count(*)::integer, min(account.taikhoanid)
			INTO account_count, account_id
		FROM public.taikhoan AS account
		WHERE account.khachhangid = customer_id;

		IF account_count > 1 THEN
			RAISE EXCEPTION 'Multiple accounts are attached to this customer profile';
		END IF;

		IF account_id IS NULL THEN
			INSERT INTO public.taikhoan (
				tendangnhap,
				matkhau,
				email,
				sodienthoai,
				khachhangid,
				userauthid
			) VALUES (
				'auth-' || current_user_id::text,
				NULL,
				verified_email,
				verified_phone,
				customer_id,
				current_user_id
			)
			RETURNING taikhoanid INTO account_id;
		ELSE
			UPDATE public.taikhoan
			SET userauthid = current_user_id,
					email = coalesce(verified_email, email)
			WHERE taikhoanid = account_id
				AND userauthid IS NULL;

			IF NOT FOUND THEN
				RAISE EXCEPTION 'This customer profile is already linked to another account';
			END IF;
		END IF;
	END IF;

	IF customer_id IS NOT NULL THEN
		SELECT role.vaitroid INTO customer_role_id
		FROM public.vaitro AS role
		WHERE role.tenvaitro = 'Khách hàng'
			AND role.trangthai = 'Hoạt động';

		IF customer_role_id IS NULL THEN
			RAISE EXCEPTION 'The active customer role is not configured';
		END IF;

		INSERT INTO public.taikhoan_vaitro (taikhoanid, vaitroid)
		VALUES (account_id, customer_role_id)
		ON CONFLICT DO NOTHING;
	END IF;
END;
$$;

REVOKE ALL ON FUNCTION public.complete_customer_profile(text)
	FROM PUBLIC, anon, authenticated, service_role;
GRANT EXECUTE ON FUNCTION public.complete_customer_profile(text)
	TO authenticated;

COMMIT;
