BEGIN;

CREATE OR REPLACE FUNCTION private.create_legacy_order_invoice()
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
		NEW."DonHangID",
		NEW."TongTien",
		NEW."TienGiamDoDiem" + NEW."TienGiamKhuyenMai",
		NEW."PhiGiaoHang",
		NEW."ThanhTien",
		'Chưa thanh toán'
	);
	RETURN NEW;
END;
$$;

REVOKE ALL ON FUNCTION private.create_legacy_order_invoice()
	FROM PUBLIC, anon, authenticated, service_role;

DO $legacy_invoice_trigger$
BEGIN
	IF EXISTS (
		SELECT 1
		FROM pg_catalog.pg_class AS relation
		WHERE relation.oid = pg_catalog.to_regclass('public.donhang')
			AND relation.relkind = 'v'
	) AND pg_catalog.to_regclass('public."DonHang"') IS NOT NULL THEN
		EXECUTE 'DROP TRIGGER IF EXISTS laundry_compat_create_order_invoice '
			|| 'ON public."DonHang"';
		EXECUTE 'CREATE TRIGGER laundry_compat_create_order_invoice '
			|| 'AFTER INSERT ON public."DonHang" '
			|| 'FOR EACH ROW EXECUTE FUNCTION private.create_legacy_order_invoice()';
	END IF;
END;
$legacy_invoice_trigger$;

COMMIT;