BEGIN;

DO $migration$
BEGIN
  IF to_regclass('public.taikhoan') IS NOT NULL THEN
    ALTER TABLE public.taikhoan
      ADD COLUMN IF NOT EXISTS userauthid uuid;
    ALTER TABLE public.taikhoan
      ALTER COLUMN matkhau DROP NOT NULL;
    ALTER TABLE public.khachhang
      ALTER COLUMN sodienthoai DROP NOT NULL;
    CREATE UNIQUE INDEX IF NOT EXISTS taikhoan_userauthid_unique_idx
      ON public.taikhoan (userauthid)
      WHERE userauthid IS NOT NULL;
  ELSIF to_regclass('public."TaiKhoan"') IS NOT NULL THEN
    ALTER TABLE public."TaiKhoan"
      ADD COLUMN IF NOT EXISTS "UserAuthId" uuid;
    ALTER TABLE public."TaiKhoan"
      ALTER COLUMN "MatKhau" DROP NOT NULL;
    ALTER TABLE public."KhachHang"
      ALTER COLUMN "SoDienThoai" DROP NOT NULL;
    CREATE UNIQUE INDEX IF NOT EXISTS "TaiKhoan_UserAuthId_unique_idx"
      ON public."TaiKhoan" ("UserAuthId")
      WHERE "UserAuthId" IS NOT NULL;
  ELSE
    RAISE EXCEPTION 'Neither supported account table exists';
  END IF;
END;
$migration$;

CREATE OR REPLACE FUNCTION public.complete_google_customer_profile(
  p_full_name text DEFAULT NULL
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
DECLARE
  current_user_id uuid := (SELECT auth.uid());
  verified_email text;
  customer_name text;
  customer_id bigint;
  account_id bigint;
  customer_role_id bigint;
BEGIN
  IF current_user_id IS NULL THEN
    RAISE EXCEPTION 'Authentication is required';
  END IF;

  SELECT users.email,
    coalesce(
      nullif(btrim(p_full_name), ''),
      nullif(btrim(users.raw_user_meta_data ->> 'full_name'), ''),
      nullif(btrim(users.raw_user_meta_data ->> 'name'), ''),
      users.email
    )
  INTO verified_email, customer_name
  FROM auth.users AS users
  WHERE users.id = current_user_id;

  IF verified_email IS NULL THEN
    RAISE EXCEPTION 'A verified Google email is required';
  END IF;

  IF to_regclass('public.taikhoan') IS NOT NULL THEN
    SELECT account.taikhoanid, account.khachhangid
    INTO account_id, customer_id
    FROM public.taikhoan AS account
    WHERE account.userauthid = current_user_id
      AND account.trangthai = 'Hoạt động';

    IF account_id IS NOT NULL THEN
      UPDATE public.khachhang
      SET hoten = customer_name, email = verified_email
      WHERE khachhangid = customer_id;
      RETURN;
    END IF;

    SELECT customer.khachhangid INTO customer_id
    FROM public.khachhang AS customer
    WHERE lower(customer.email) = lower(verified_email)
    LIMIT 1;

    IF customer_id IS NULL THEN
      INSERT INTO public.khachhang (hoten, sodienthoai, email)
      VALUES (customer_name, NULL, verified_email)
      RETURNING khachhangid INTO customer_id;
    ELSE
      UPDATE public.khachhang
      SET hoten = customer_name, email = verified_email
      WHERE khachhangid = customer_id;
    END IF;

    INSERT INTO public.taikhoan (
      tendangnhap, matkhau, email, sodienthoai, khachhangid, userauthid
    ) VALUES (
      'auth-' || current_user_id::text, NULL, verified_email, NULL,
      customer_id, current_user_id
    )
    RETURNING taikhoanid INTO account_id;

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
  ELSE
    SELECT account."TaiKhoanID", account."KhachHangID"
    INTO account_id, customer_id
    FROM public."TaiKhoan" AS account
    WHERE account."UserAuthId" = current_user_id
      AND account."TrangThai" = 'Hoạt động';

    IF account_id IS NOT NULL THEN
      UPDATE public."KhachHang"
      SET "HoTen" = customer_name, "Email" = verified_email
      WHERE "KhachHangID" = customer_id;
      RETURN;
    END IF;

    SELECT customer."KhachHangID" INTO customer_id
    FROM public."KhachHang" AS customer
    WHERE lower(customer."Email") = lower(verified_email)
    LIMIT 1;

    IF customer_id IS NULL THEN
      INSERT INTO public."KhachHang" ("HoTen", "SoDienThoai", "Email")
      VALUES (customer_name, NULL, verified_email)
      RETURNING "KhachHangID" INTO customer_id;
    ELSE
      UPDATE public."KhachHang"
      SET "HoTen" = customer_name, "Email" = verified_email
      WHERE "KhachHangID" = customer_id;
    END IF;

    INSERT INTO public."TaiKhoan" (
      "TenDangNhap", "MatKhau", "Email", "SoDienThoai",
      "KhachHangID", "UserAuthId"
    ) VALUES (
      'auth-' || current_user_id::text, NULL, verified_email, NULL,
      customer_id, current_user_id
    )
    RETURNING "TaiKhoanID" INTO account_id;

    SELECT role."VaiTroID" INTO customer_role_id
    FROM public."VaiTro" AS role
    WHERE role."TenVaiTro" = 'Khách hàng'
      AND role."TrangThai" = 'Hoạt động';

    IF customer_role_id IS NULL THEN
      RAISE EXCEPTION 'The active customer role is not configured';
    END IF;

    INSERT INTO public."TaiKhoan_VaiTro" ("TaiKhoanID", "VaiTroID")
    VALUES (account_id, customer_role_id)
    ON CONFLICT DO NOTHING;
  END IF;
END;
$$;

CREATE OR REPLACE FUNCTION public.get_current_roles()
RETURNS text[]
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
SET search_path = ''
AS $$
DECLARE
  current_user_id uuid := (SELECT auth.uid());
  account_roles text[];
BEGIN
  IF current_user_id IS NULL THEN
    RETURN ARRAY[]::text[];
  END IF;

  IF to_regclass('public.taikhoan') IS NOT NULL THEN
    SELECT coalesce(array_agg(role.tenvaitro), ARRAY[]::text[])
    INTO account_roles
    FROM public.taikhoan AS account
    JOIN public.taikhoan_vaitro AS account_role
      ON account_role.taikhoanid = account.taikhoanid
    JOIN public.vaitro AS role ON role.vaitroid = account_role.vaitroid
    WHERE account.userauthid = current_user_id
      AND account.trangthai = 'Hoạt động'
      AND role.trangthai = 'Hoạt động';
  ELSE
    SELECT coalesce(array_agg(role."TenVaiTro"), ARRAY[]::text[])
    INTO account_roles
    FROM public."TaiKhoan" AS account
    JOIN public."TaiKhoan_VaiTro" AS account_role
      ON account_role."TaiKhoanID" = account."TaiKhoanID"
    JOIN public."VaiTro" AS role
      ON role."VaiTroID" = account_role."VaiTroID"
    WHERE account."UserAuthId" = current_user_id
      AND account."TrangThai" = 'Hoạt động'
      AND role."TrangThai" = 'Hoạt động';
  END IF;

  RETURN coalesce(account_roles, ARRAY[]::text[]);
END;
$$;

REVOKE ALL ON FUNCTION public.complete_google_customer_profile(text)
  FROM PUBLIC, anon, authenticated, service_role;
GRANT EXECUTE ON FUNCTION public.complete_google_customer_profile(text)
  TO authenticated;
REVOKE ALL ON FUNCTION public.get_current_roles()
  FROM PUBLIC, anon, authenticated, service_role;
GRANT EXECUTE ON FUNCTION public.get_current_roles()
  TO authenticated;

COMMIT;