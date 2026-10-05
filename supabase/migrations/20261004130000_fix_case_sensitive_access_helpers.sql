CREATE OR REPLACE FUNCTION private.current_account_id()
RETURNS bigint
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path TO ''
AS $$
  SELECT account."TaiKhoanID"
  FROM public."TaiKhoan" AS account
  WHERE account."UserAuthId" = (SELECT auth.uid())
    AND account."TrangThai" = 'Hoạt động';
$$;

CREATE OR REPLACE FUNCTION private.current_customer_id()
RETURNS bigint
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path TO ''
AS $$
  SELECT account."KhachHangID"
  FROM public."TaiKhoan" AS account
  JOIN public."KhachHang" AS customer
    ON customer."KhachHangID" = account."KhachHangID"
  WHERE account."UserAuthId" = (SELECT auth.uid())
    AND account."TrangThai" = 'Hoạt động'
    AND customer."TrangThai" = 'Hoạt động';
$$;

CREATE OR REPLACE FUNCTION private.current_employee_id()
RETURNS bigint
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path TO ''
AS $$
  SELECT account."NhanVienID"
  FROM public."TaiKhoan" AS account
  JOIN public."NhanVien" AS employee
    ON employee."NhanVienID" = account."NhanVienID"
  WHERE account."UserAuthId" = (SELECT auth.uid())
    AND account."TrangThai" = 'Hoạt động'
    AND employee."TrangThai" = 'Hoạt động';
$$;

CREATE OR REPLACE FUNCTION private.has_role(role_name text)
RETURNS boolean
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path TO ''
AS $$
  SELECT EXISTS (
    SELECT 1
    FROM public."TaiKhoan" AS account
    JOIN public."TaiKhoan_VaiTro" AS account_role
      ON account_role."TaiKhoanID" = account."TaiKhoanID"
    JOIN public."VaiTro" AS app_role
      ON app_role."VaiTroID" = account_role."VaiTroID"
    WHERE account."UserAuthId" = (SELECT auth.uid())
      AND account."TrangThai" = 'Hoạt động'
      AND app_role."TenVaiTro" = role_name
      AND app_role."TrangThai" = 'Hoạt động'
  );
$$;

CREATE OR REPLACE FUNCTION private.can_access_order(order_id bigint)
RETURNS boolean
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path TO ''
AS $$
  SELECT (SELECT auth.uid()) IS NOT NULL
    AND EXISTS (
      SELECT 1
      FROM public."DonHang" AS order_record
      WHERE order_record."DonHangID" = order_id
        AND (
          order_record."KhachHangID" = (SELECT private.current_customer_id())
          OR (SELECT private.is_staff())
        )
    );
$$;

REVOKE ALL ON FUNCTION private.current_account_id()
  FROM PUBLIC, anon, authenticated;
REVOKE ALL ON FUNCTION private.current_customer_id()
  FROM PUBLIC, anon, authenticated;
REVOKE ALL ON FUNCTION private.current_employee_id()
  FROM PUBLIC, anon, authenticated;
REVOKE ALL ON FUNCTION private.has_role(text)
  FROM PUBLIC, anon, authenticated;
REVOKE ALL ON FUNCTION private.can_access_order(bigint)
  FROM PUBLIC, anon, authenticated;

GRANT EXECUTE ON FUNCTION private.current_account_id() TO authenticated;
GRANT EXECUTE ON FUNCTION private.current_customer_id() TO authenticated;
GRANT EXECUTE ON FUNCTION private.current_employee_id() TO authenticated;
GRANT EXECUTE ON FUNCTION private.has_role(text) TO authenticated;
GRANT EXECUTE ON FUNCTION private.can_access_order(bigint) TO authenticated;