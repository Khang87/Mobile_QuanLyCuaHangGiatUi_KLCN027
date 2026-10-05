INSERT INTO public.vaitro (tenvaitro, trangthai)
SELECT seed.role_name, 'Hoạt động'
FROM (VALUES
  ('Chủ cửa hàng'),
  ('Quản lý'),
  ('Nhân viên'),
  ('Khách hàng')
) AS seed(role_name)
WHERE NOT EXISTS (
  SELECT 1 FROM public.vaitro AS role WHERE role.tenvaitro = seed.role_name
);

INSERT INTO public.loaidichvu (tenloaidichvu, trangthai)
SELECT seed.category_name, 'Hoạt động'
FROM (VALUES ('Giặt'), ('Giặt khô'), ('Sấy'), ('Ủi')) AS seed(category_name)
WHERE NOT EXISTS (
  SELECT 1 FROM public.loaidichvu AS category
  WHERE category.tenloaidichvu = seed.category_name
);

INSERT INTO public.loaidogiat (tenloaidogiat, trangthai)
SELECT seed.item_name, 'Hoạt động'
FROM (VALUES
  ('Quần áo'),
  ('Chăn'),
  ('Ga giường'),
  ('Giày'),
  ('Gấu bông'),
  ('Áo dài')
) AS seed(item_name)
WHERE NOT EXISTS (
  SELECT 1 FROM public.loaidogiat AS item_type
  WHERE item_type.tenloaidogiat = seed.item_name
);

INSERT INTO public.donvitinh (tendonvitinh, kyhieu, trangthai)
SELECT seed.unit_name, seed.unit_symbol, 'Hoạt động'
FROM (VALUES
  ('Kilogram', 'kg'),
  ('Cái', 'cái'),
  ('Đôi', 'đôi'),
  ('Bộ', 'bộ')
) AS seed(unit_name, unit_symbol)
WHERE NOT EXISTS (
  SELECT 1 FROM public.donvitinh AS unit
  WHERE unit.tendonvitinh = seed.unit_name
);

INSERT INTO public.dichvu (loaidichvuid, tendichvu, trangthai)
SELECT category.loaidichvuid, seed.service_name, 'Hoạt động'
FROM (VALUES
  ('Giặt', 'Giặt thường'),
  ('Giặt', 'Giặt kỹ'),
  ('Giặt khô', 'Giặt khô'),
  ('Sấy', 'Sấy khô'),
  ('Ủi', 'Ủi thường')
) AS seed(category_name, service_name)
JOIN public.loaidichvu AS category
  ON category.tenloaidichvu = seed.category_name
WHERE NOT EXISTS (
  SELECT 1 FROM public.dichvu AS service
  WHERE service.loaidichvuid = category.loaidichvuid
    AND service.tendichvu = seed.service_name
);

INSERT INTO public.banggia (
  dichvuid,
  loaidogiatid,
  donvitinhid,
  dongia,
  ngayapdung,
  trangthai
)
SELECT service.dichvuid, item_type.loaidogiatid, unit.donvitinhid,
       seed.unit_price, DATE '2026-01-01', 'Hoạt động'
FROM (VALUES
  ('Giặt thường', 'Quần áo', 'Kilogram', 10000::numeric),
  ('Giặt kỹ', 'Quần áo', 'Kilogram', 15000::numeric),
  ('Sấy khô', 'Quần áo', 'Kilogram', 10000::numeric),
  ('Ủi thường', 'Quần áo', 'Cái', 10000::numeric),
  ('Giặt thường', 'Chăn', 'Cái', 22000::numeric),
  ('Giặt thường', 'Ga giường', 'Cái', 22000::numeric),
  ('Giặt thường', 'Giày', 'Đôi', 50000::numeric),
  ('Giặt thường', 'Gấu bông', 'Cái', 30000::numeric),
  ('Giặt khô', 'Áo dài', 'Bộ', 80000::numeric),
  ('Ủi thường', 'Áo dài', 'Bộ', 30000::numeric)
) AS seed(service_name, item_name, unit_name, unit_price)
JOIN public.dichvu AS service
  ON service.tendichvu = seed.service_name
JOIN public.loaidogiat AS item_type
  ON item_type.tenloaidogiat = seed.item_name
JOIN public.donvitinh AS unit
  ON unit.tendonvitinh = seed.unit_name
WHERE NOT EXISTS (
  SELECT 1 FROM public.banggia AS price
  WHERE price.dichvuid = service.dichvuid
    AND price.loaidogiatid = item_type.loaidogiatid
    AND price.donvitinhid = unit.donvitinhid
    AND price.ngayapdung = DATE '2026-01-01'
);