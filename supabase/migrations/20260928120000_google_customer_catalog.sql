BEGIN;

ALTER TABLE public.khachhang
  ALTER COLUMN sodienthoai DROP NOT NULL;

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

  SELECT
    users.email,
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

  SELECT account.taikhoanid, account.khachhangid
  INTO account_id, customer_id
  FROM public.taikhoan AS account
  WHERE account.userauthid = current_user_id
    AND account.trangthai = 'Hoạt động';

  IF account_id IS NOT NULL THEN
    UPDATE public.khachhang
    SET hoten = customer_name,
        email = verified_email
    WHERE khachhangid = customer_id;
    RETURN;
  END IF;

  SELECT customer.khachhangid
  INTO customer_id
  FROM public.khachhang AS customer
  WHERE lower(customer.email) = lower(verified_email)
  LIMIT 1;

  IF customer_id IS NULL THEN
    INSERT INTO public.khachhang (hoten, sodienthoai, email)
    VALUES (customer_name, NULL, verified_email)
    RETURNING khachhangid INTO customer_id;
  ELSE
    UPDATE public.khachhang
    SET hoten = customer_name,
        email = verified_email
    WHERE khachhangid = customer_id;
  END IF;

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
    NULL,
    customer_id,
    current_user_id
  )
  RETURNING taikhoanid INTO account_id;

  SELECT role.vaitroid
  INTO customer_role_id
  FROM public.vaitro AS role
  WHERE role.tenvaitro = 'Khách hàng'
    AND role.trangthai = 'Hoạt động';

  IF customer_role_id IS NULL THEN
    RAISE EXCEPTION 'The active customer role is not configured';
  END IF;

  INSERT INTO public.taikhoan_vaitro (taikhoanid, vaitroid)
  VALUES (account_id, customer_role_id)
  ON CONFLICT DO NOTHING;
END;
$$;

REVOKE ALL ON FUNCTION public.complete_google_customer_profile(text)
  FROM PUBLIC, anon, authenticated, service_role;
GRANT EXECUTE ON FUNCTION public.complete_google_customer_profile(text)
  TO authenticated;

CREATE OR REPLACE FUNCTION public.get_customer_loyalty()
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
DECLARE
  customer_id bigint := (SELECT private.current_customer_id());
  current_points integer;
  active_vouchers jsonb;
BEGIN
  IF customer_id IS NULL THEN
    RAISE EXCEPTION 'An active customer account is required';
  END IF;

  SELECT coalesce(points.diemhientai, 0)
  INTO current_points
  FROM public.diemtichluy AS points
  WHERE points.khachhangid = customer_id;

  SELECT coalesce(jsonb_agg(jsonb_build_object(
    'khuyenmaiid', promotion.khuyenmaiid,
    'makhuyenmai', promotion.makhuyenmai,
    'tenkhuyenmai', promotion.tenkhuyenmai,
    'loaikhuyenmai', promotion.loaikhuyenmai,
    'giatrigiam', promotion.giatrigiam,
    'giatridontoithieu', promotion.giatridontoithieu,
    'mucgiamtoida', promotion.mucgiamtoida,
    'dieukienapdung', promotion.dieukienapdung
  ) ORDER BY promotion.ngayketthuc), '[]'::jsonb)
  INTO active_vouchers
  FROM public.khuyenmai AS promotion
  WHERE promotion.trangthai = 'Hoạt động'
    AND promotion.ngaybatdau <= current_date
    AND promotion.ngayketthuc >= current_date
    AND (promotion.soluongsudung IS NULL OR promotion.soluongsudung > 0);

  RETURN jsonb_build_object(
    'points', coalesce(current_points, 0),
    'vouchers', active_vouchers
  );
END;
$$;

REVOKE ALL ON FUNCTION public.get_customer_loyalty()
  FROM PUBLIC, anon, authenticated, service_role;
GRANT EXECUTE ON FUNCTION public.get_customer_loyalty() TO authenticated;

INSERT INTO public.vaitro (tenvaitro, mota, trangthai)
SELECT 'Khách hàng', 'Tài khoản khách hàng sử dụng ứng dụng', 'Hoạt động'
WHERE NOT EXISTS (
  SELECT 1 FROM public.vaitro WHERE tenvaitro = 'Khách hàng'
);

INSERT INTO public.khuyenmai (
  makhuyenmai, tenkhuyenmai, loaikhuyenmai, giatrigiam,
  giatridontoithieu, mucgiamtoida, dieukienapdung,
  ngaybatdau, ngayketthuc, trangthai
)
SELECT promotion.code, promotion.title, promotion.discount_type,
       promotion.discount_value, promotion.minimum_order,
       promotion.maximum_discount, promotion.condition,
       current_date, current_date + 365, 'Hoạt động'
FROM (VALUES
  ('WELCOME30', 'Giảm 30.000đ cho khách hàng mới', 'Tiền mặt', 30000::numeric, 100000::numeric, NULL::numeric, 'Áp dụng cho đơn đầu tiên'),
  ('FREESHIP', 'Miễn phí giao nhận', 'Tiền mặt', 15000::numeric, 150000::numeric, 15000::numeric, 'Áp dụng cho đơn lấy tận nơi'),
  ('SAVE10', 'Giảm 10% dịch vụ giặt ủi', 'Phần trăm', 10::numeric, 200000::numeric, 50000::numeric, 'Áp dụng cho đơn từ 200.000đ')
) AS promotion(code, title, discount_type, discount_value, minimum_order, maximum_discount, condition)
WHERE NOT EXISTS (
  SELECT 1 FROM public.khuyenmai AS existing
  WHERE existing.makhuyenmai = promotion.code
);

INSERT INTO public.loaidichvu (tenloaidichvu, mota, trangthai)
SELECT 'Giặt ủi', 'Các dịch vụ giặt, sấy và chăm sóc đồ dùng', 'Hoạt động'
WHERE NOT EXISTS (
  SELECT 1 FROM public.loaidichvu WHERE tenloaidichvu = 'Giặt ủi'
);

INSERT INTO public.donvitinh (tendonvitinh, kyhieu, trangthai)
SELECT 'Kilogram', 'kg', 'Hoạt động'
WHERE NOT EXISTS (
  SELECT 1 FROM public.donvitinh WHERE kyhieu = 'kg'
);

INSERT INTO public.donvitinh (tendonvitinh, kyhieu, trangthai)
SELECT 'Cái', 'cái', 'Hoạt động'
WHERE NOT EXISTS (
  SELECT 1 FROM public.donvitinh WHERE kyhieu = 'cái'
);

INSERT INTO public.loaidogiat (tenloaidogiat, mota, trangthai)
SELECT 'Quần áo thường', 'Quần áo sử dụng hằng ngày', 'Hoạt động'
WHERE NOT EXISTS (
  SELECT 1 FROM public.loaidogiat WHERE tenloaidogiat = 'Quần áo thường'
);

INSERT INTO public.loaidogiat (tenloaidogiat, mota, trangthai)
SELECT 'Áo sơ mi', 'Áo sơ mi và áo mỏng cần chăm sóc riêng', 'Hoạt động'
WHERE NOT EXISTS (
  SELECT 1 FROM public.loaidogiat WHERE tenloaidogiat = 'Áo sơ mi'
);

INSERT INTO public.loaidogiat (tenloaidogiat, mota, trangthai)
SELECT 'Chăn mền gia đình', 'Chăn, mền và đồ gia dụng cỡ lớn', 'Hoạt động'
WHERE NOT EXISTS (
  SELECT 1 FROM public.loaidogiat WHERE tenloaidogiat = 'Chăn mền gia đình'
);

INSERT INTO public.dichvu (loaidichvuid, tendichvu, mota, thoigiandukien, trangthai)
SELECT service_type.loaidichvuid, service_name.name, service_name.description,
       service_name.duration_hours, 'Hoạt động'
FROM public.loaidichvu AS service_type
CROSS JOIN (VALUES
  ('Giặt thường', 'Giặt, sấy và xếp gọn quần áo thường', 24),
  ('Giặt khô', 'Chăm sóc áo quần cần giặt khô', 48),
  ('Giặt chăn mền', 'Giặt và sấy chăn mền gia đình', 72)
) AS service_name(name, description, duration_hours)
WHERE service_type.tenloaidichvu = 'Giặt ủi'
  AND NOT EXISTS (
    SELECT 1 FROM public.dichvu AS service
    WHERE service.tendichvu = service_name.name
  );

INSERT INTO public.banggia (
  dichvuid, loaidogiatid, donvitinhid, dongia, ngayapdung, trangthai
)
SELECT service.dichvuid, item_type.loaidogiatid, unit.donvitinhid,
       price.amount, current_date, 'Hoạt động'
FROM (VALUES
  ('Giặt thường', 'Quần áo thường', 'kg', 25000::numeric),
  ('Giặt khô', 'Áo sơ mi', 'cái', 30000::numeric),
  ('Giặt chăn mền', 'Chăn mền gia đình', 'cái', 120000::numeric)
) AS price(service_name, item_name, unit_symbol, amount)
JOIN public.dichvu AS service ON service.tendichvu = price.service_name
JOIN public.loaidogiat AS item_type ON item_type.tenloaidogiat = price.item_name
JOIN public.donvitinh AS unit ON unit.kyhieu = price.unit_symbol
WHERE NOT EXISTS (
  SELECT 1
  FROM public.banggia AS existing
  WHERE existing.dichvuid = service.dichvuid
    AND existing.loaidogiatid = item_type.loaidogiatid
    AND existing.donvitinhid = unit.donvitinhid
    AND existing.trangthai = 'Hoạt động'
);

COMMIT;
