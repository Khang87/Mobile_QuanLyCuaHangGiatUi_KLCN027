DO $migration$
DECLARE
	item record;
	legacy_table oid;
	projection text;
BEGIN
	IF to_regclass('public."BangGia"') IS NULL
			OR to_regclass('public."DonHang"') IS NULL
			OR to_regclass('public."TaiKhoan"') IS NULL THEN
		RETURN;
	END IF;

	ALTER TABLE public."DonHang"
		ADD COLUMN IF NOT EXISTS "IdempotencyKey" uuid;
	CREATE UNIQUE INDEX IF NOT EXISTS "DonHang_IdempotencyKey_unique_idx"
		ON public."DonHang" ("IdempotencyKey")
		WHERE "IdempotencyKey" IS NOT NULL;
	CREATE UNIQUE INDEX IF NOT EXISTS "TaiKhoan_UserAuthId_unique_idx"
		ON public."TaiKhoan" ("UserAuthId")
		WHERE "UserAuthId" IS NOT NULL;
	ALTER TABLE public."TaiKhoan"
		ALTER COLUMN "MatKhau" DROP NOT NULL;
	ALTER TABLE public."KhachHang"
		ALTER COLUMN "SoDienThoai" DROP NOT NULL;

	FOR item IN
		SELECT * FROM (VALUES
			('BangGia', 'banggia'),
			('Booking', 'booking'),
			('ChiTietDonHang', 'chitietdonhang'),
			('DanhGia', 'danhgia'),
			('DichVu', 'dichvu'),
			('DiemTichLuy', 'diemtichluy'),
			('DonHang', 'donhang'),
			('DonViTinh', 'donvitinh'),
			('GiaoNhan', 'giaonhan'),
			('HoaDon', 'hoadon'),
			('KhachHang', 'khachhang'),
			('KhuyenMai', 'khuyenmai'),
			('LichSuThayDoiHoaDon', 'lichsuthaydoihoadon'),
			('LoaiDichVu', 'loaidichvu'),
			('LoaiDoGiat', 'loaidogiat'),
			('NhanVien', 'nhanvien'),
			('Quyen', 'quyen'),
			('TaiKhoan', 'taikhoan'),
			('TaiKhoan_VaiTro', 'taikhoan_vaitro'),
			('ThanhToan', 'thanhtoan'),
			('ThongBao', 'thongbao'),
			('TinNhan', 'tinnhan'),
			('VaiTro', 'vaitro'),
			('VaiTro_Quyen', 'vaitro_quyen')
		) AS names(legacy_name, api_name)
	LOOP
		legacy_table := to_regclass(format('public.%I', item.legacy_name));
		IF legacy_table IS NULL THEN
			CONTINUE;
		END IF;

		EXECUTE format(
			'ALTER TABLE public.%I ENABLE ROW LEVEL SECURITY',
			item.legacy_name
		);
		EXECUTE format(
			'GRANT SELECT ON TABLE public.%I TO authenticated',
			item.legacy_name
		);
		IF to_regclass(format('public.%I', item.api_name)) IS NULL THEN
			SELECT string_agg(
				format('%I AS %I', column_name,
					CASE WHEN column_name = 'IdempotencyKey'
						THEN 'idempotency_key' ELSE lower(column_name) END),
				', ' ORDER BY ordinal_position
			)
			INTO projection
			FROM information_schema.columns
			WHERE table_schema = 'public'
				AND table_name = item.legacy_name;

			EXECUTE format(
				'CREATE VIEW public.%I WITH (security_invoker = true) AS '
				|| 'SELECT %s FROM public.%I',
				item.api_name, projection, item.legacy_name
			);
		END IF;
		EXECUTE format('GRANT SELECT ON public.%I TO authenticated', item.api_name);
	END LOOP;

	CREATE TABLE IF NOT EXISTS public.khachhang_diachi (
		diachiid bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
		khachhangid bigint NOT NULL
			REFERENCES public."KhachHang" ("KhachHangID") ON DELETE CASCADE,
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
	CREATE INDEX IF NOT EXISTS khachhang_diachi_khachhangid_idx
		ON public.khachhang_diachi (khachhangid);
	CREATE UNIQUE INDEX IF NOT EXISTS khachhang_diachi_one_default_idx
		ON public.khachhang_diachi (khachhangid) WHERE macdinh;

	CREATE TABLE IF NOT EXISTS public.donhang_trangthai (
		donhang_trangthaiid bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
		donhangid bigint NOT NULL
			REFERENCES public."DonHang" ("DonHangID") ON DELETE CASCADE,
		taikhoanid bigint
			REFERENCES public."TaiKhoan" ("TaiKhoanID") ON DELETE SET NULL,
		trangthaicu character varying(30),
		trangthaimoi character varying(30) NOT NULL,
		lydo character varying(500),
		thoigian timestamp with time zone NOT NULL DEFAULT now()
	);
	CREATE INDEX IF NOT EXISTS donhang_trangthai_donhangid_idx
		ON public.donhang_trangthai (donhangid, thoigian);

	INSERT INTO public.khachhang_diachi (
		khachhangid, tennguoinhan, sodienthoai, diachi, macdinh
	)
	SELECT customer."KhachHangID", customer."HoTen",
		customer."SoDienThoai", customer."DiaChi", true
	FROM public."KhachHang" AS customer
	WHERE nullif(btrim(customer."DiaChi"), '') IS NOT NULL
		AND nullif(btrim(customer."SoDienThoai"), '') IS NOT NULL
		AND NOT EXISTS (
			SELECT 1 FROM public.khachhang_diachi AS saved
			WHERE saved.khachhangid = customer."KhachHangID"
		);

	CREATE SCHEMA IF NOT EXISTS private;
	REVOKE ALL ON SCHEMA private FROM PUBLIC, anon;
	GRANT USAGE ON SCHEMA private TO authenticated;
	EXECUTE $function$
		CREATE OR REPLACE FUNCTION private.normalize_phone(phone_number text)
		RETURNS text LANGUAGE sql IMMUTABLE SET search_path = ''
		AS $body$
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
		$body$
	$function$;
	REVOKE ALL ON FUNCTION private.normalize_phone(text)
		FROM PUBLIC, anon, authenticated;
	EXECUTE $function$
		CREATE OR REPLACE FUNCTION private.current_account_id()
		RETURNS bigint LANGUAGE sql STABLE SECURITY DEFINER SET search_path = ''
		AS $body$
			SELECT account.taikhoanid FROM public.taikhoan AS account
			WHERE account.userauthid = (SELECT auth.uid())
				AND account.trangthai = 'Hoạt động';
		$body$
	$function$;
	EXECUTE $function$
		CREATE OR REPLACE FUNCTION private.current_customer_id()
		RETURNS bigint LANGUAGE sql STABLE SECURITY DEFINER SET search_path = ''
		AS $body$
			SELECT account.khachhangid FROM public.taikhoan AS account
			JOIN public.khachhang AS customer
				ON customer.khachhangid = account.khachhangid
			WHERE account.userauthid = (SELECT auth.uid())
				AND account.trangthai = 'Hoạt động'
				AND customer.trangthai = 'Hoạt động';
		$body$
	$function$;
	EXECUTE $function$
		CREATE OR REPLACE FUNCTION private.current_employee_id()
		RETURNS bigint LANGUAGE sql STABLE SECURITY DEFINER SET search_path = ''
		AS $body$
			SELECT account.nhanvienid FROM public.taikhoan AS account
			JOIN public.nhanvien AS employee
				ON employee.nhanvienid = account.nhanvienid
			WHERE account.userauthid = (SELECT auth.uid())
				AND account.trangthai = 'Hoạt động'
				AND employee.trangthai = 'Hoạt động';
		$body$
	$function$;
	EXECUTE $function$
		CREATE OR REPLACE FUNCTION private.has_role(role_name text)
		RETURNS boolean LANGUAGE sql STABLE SECURITY DEFINER SET search_path = ''
		AS $body$
			SELECT EXISTS (
				SELECT 1 FROM public.taikhoan AS account
				JOIN public.taikhoan_vaitro AS account_role
					ON account_role.taikhoanid = account.taikhoanid
				JOIN public.vaitro AS app_role
					ON app_role.vaitroid = account_role.vaitroid
				WHERE account.userauthid = (SELECT auth.uid())
					AND account.trangthai = 'Hoạt động'
					AND app_role.tenvaitro = role_name
					AND app_role.trangthai = 'Hoạt động'
			);
		$body$
	$function$;
	EXECUTE $function$
		CREATE OR REPLACE FUNCTION private.is_staff()
		RETURNS boolean LANGUAGE sql STABLE SECURITY DEFINER SET search_path = ''
		AS $body$
			SELECT (SELECT private.has_role('Nhân viên'))
				OR (SELECT private.has_role('Quản lý'))
				OR (SELECT private.has_role('Chủ cửa hàng'));
		$body$
	$function$;
	EXECUTE $function$
		CREATE OR REPLACE FUNCTION private.can_access_order(order_id bigint)
		RETURNS boolean LANGUAGE sql STABLE SECURITY DEFINER SET search_path = ''
		AS $body$
			SELECT (SELECT auth.uid()) IS NOT NULL AND EXISTS (
				SELECT 1 FROM public.donhang AS order_record
				WHERE order_record.donhangid = order_id
					AND (order_record.khachhangid = (SELECT private.current_customer_id())
						OR (SELECT private.is_staff()))
			);
		$body$
	$function$;

	REVOKE ALL ON FUNCTION private.current_account_id() FROM PUBLIC, anon, authenticated;
	REVOKE ALL ON FUNCTION private.current_customer_id() FROM PUBLIC, anon, authenticated;
	REVOKE ALL ON FUNCTION private.current_employee_id() FROM PUBLIC, anon, authenticated;
	REVOKE ALL ON FUNCTION private.has_role(text) FROM PUBLIC, anon, authenticated;
	REVOKE ALL ON FUNCTION private.is_staff() FROM PUBLIC, anon, authenticated;
	REVOKE ALL ON FUNCTION private.can_access_order(bigint) FROM PUBLIC, anon, authenticated;
	GRANT EXECUTE ON FUNCTION private.current_account_id() TO authenticated;
	GRANT EXECUTE ON FUNCTION private.current_customer_id() TO authenticated;
	GRANT EXECUTE ON FUNCTION private.current_employee_id() TO authenticated;
	GRANT EXECUTE ON FUNCTION private.has_role(text) TO authenticated;
	GRANT EXECUTE ON FUNCTION private.is_staff() TO authenticated;
	GRANT EXECUTE ON FUNCTION private.can_access_order(bigint) TO authenticated;

	ALTER TABLE public.khachhang_diachi ENABLE ROW LEVEL SECURITY;
	ALTER TABLE public.donhang_trangthai ENABLE ROW LEVEL SECURITY;
	GRANT SELECT, DELETE ON public.khachhang_diachi TO authenticated;
	GRANT SELECT ON public.donhang_trangthai TO authenticated;
	GRANT SELECT ON public.banggia, public.booking, public.chitietdonhang,
		public.danhgia, public.dichvu, public.diemtichluy, public.donhang,
		public.donvitinh, public.giaonhan, public.hoadon, public.khachhang,
		public.khuyenmai, public.lichsuthaydoihoadon, public.loaidichvu,
		public.loaidogiat, public.nhanvien, public.quyen, public.taikhoan,
		public.taikhoan_vaitro, public.thanhtoan, public.thongbao,
		public.tinnhan, public.vaitro, public.vaitro_quyen TO authenticated;
	GRANT SELECT ON public.banggia, public.dichvu, public.donvitinh,
		public.loaidogiat, public.loaidichvu, public.khuyenmai TO anon;
	GRANT SELECT ON public."BangGia", public."DichVu", public."DonViTinh",
		public."LoaiDoGiat", public."LoaiDichVu", public."KhuyenMai" TO anon;
	GRANT SELECT ON public.banggia, public.dichvu, public.donvitinh,
		public.loaidogiat, public.loaidichvu, public.khuyenmai TO authenticated;
	GRANT UPDATE (hoten, email, diachi) ON public.khachhang TO authenticated;
	GRANT UPDATE (dadoc) ON public.thongbao TO authenticated;
	GRANT UPDATE ("HoTen", "Email", "DiaChi") ON public."KhachHang" TO authenticated;
	GRANT UPDATE ("DaDoc") ON public."ThongBao" TO authenticated;

	DROP POLICY IF EXISTS laundry_compat_catalog_price ON public."BangGia";
	CREATE POLICY laundry_compat_catalog_price ON public."BangGia"
		FOR SELECT TO anon, authenticated USING (
			"TrangThai" = 'Hoạt động' AND "NgayApDung" <= current_date
			AND ("NgayKetThuc" IS NULL OR "NgayKetThuc" >= current_date)
		);
	DROP POLICY IF EXISTS laundry_compat_catalog_service ON public."DichVu";
	CREATE POLICY laundry_compat_catalog_service ON public."DichVu"
		FOR SELECT TO anon, authenticated USING ("TrangThai" = 'Hoạt động');
	DROP POLICY IF EXISTS laundry_compat_catalog_item_type ON public."LoaiDoGiat";
	CREATE POLICY laundry_compat_catalog_item_type ON public."LoaiDoGiat"
		FOR SELECT TO anon, authenticated USING ("TrangThai" = 'Hoạt động');
	DROP POLICY IF EXISTS laundry_compat_catalog_unit ON public."DonViTinh";
	CREATE POLICY laundry_compat_catalog_unit ON public."DonViTinh"
		FOR SELECT TO anon, authenticated USING ("TrangThai" = 'Hoạt động');
	DROP POLICY IF EXISTS laundry_compat_catalog_service_type ON public."LoaiDichVu";
	CREATE POLICY laundry_compat_catalog_service_type ON public."LoaiDichVu"
		FOR SELECT TO anon, authenticated USING ("TrangThai" = 'Hoạt động');
	DROP POLICY IF EXISTS laundry_compat_catalog_promotion ON public."KhuyenMai";
	CREATE POLICY laundry_compat_catalog_promotion ON public."KhuyenMai"
		FOR SELECT TO anon, authenticated USING (
			"TrangThai" = 'Hoạt động' AND "NgayBatDau" <= current_date
			AND "NgayKetThuc" >= current_date
			AND ("SoLuongSuDung" IS NULL OR "SoLuongSuDung" > 0)
		);

	DROP POLICY IF EXISTS laundry_compat_account_read ON public."TaiKhoan";
	CREATE POLICY laundry_compat_account_read ON public."TaiKhoan"
		FOR SELECT TO authenticated USING (
			"TaiKhoanID" = (SELECT private.current_account_id())
			OR (SELECT private.has_role('Quản lý'))
			OR (SELECT private.has_role('Chủ cửa hàng'))
		);
	DROP POLICY IF EXISTS laundry_compat_customer_read ON public."KhachHang";
	CREATE POLICY laundry_compat_customer_read ON public."KhachHang"
		FOR SELECT TO authenticated USING (
			"KhachHangID" = (SELECT private.current_customer_id())
			OR (SELECT private.is_staff())
		);
	DROP POLICY IF EXISTS laundry_compat_customer_update ON public."KhachHang";
	CREATE POLICY laundry_compat_customer_update ON public."KhachHang"
		FOR UPDATE TO authenticated
		USING ("KhachHangID" = (SELECT private.current_customer_id()))
		WITH CHECK ("KhachHangID" = (SELECT private.current_customer_id()));
	DROP POLICY IF EXISTS laundry_compat_employee_read ON public."NhanVien";
	CREATE POLICY laundry_compat_employee_read ON public."NhanVien"
		FOR SELECT TO authenticated USING (
			"NhanVienID" = (SELECT private.current_employee_id())
			OR (SELECT private.has_role('Quản lý'))
			OR (SELECT private.has_role('Chủ cửa hàng'))
		);

	DROP POLICY IF EXISTS laundry_compat_booking_read ON public."Booking";
	CREATE POLICY laundry_compat_booking_read ON public."Booking"
		FOR SELECT TO authenticated USING (
			"KhachHangID" = (SELECT private.current_customer_id())
			OR (SELECT private.is_staff())
		);
	DROP POLICY IF EXISTS laundry_compat_order_read ON public."DonHang";
	CREATE POLICY laundry_compat_order_read ON public."DonHang"
		FOR SELECT TO authenticated USING (
			"KhachHangID" = (SELECT private.current_customer_id())
			OR (SELECT private.is_staff())
		);
	DROP POLICY IF EXISTS laundry_compat_order_detail_read ON public."ChiTietDonHang";
	CREATE POLICY laundry_compat_order_detail_read ON public."ChiTietDonHang"
		FOR SELECT TO authenticated USING (
			(SELECT private.can_access_order("DonHangID"))
		);
	DROP POLICY IF EXISTS laundry_compat_loyalty_read ON public."DiemTichLuy";
	CREATE POLICY laundry_compat_loyalty_read ON public."DiemTichLuy"
		FOR SELECT TO authenticated USING (
			"KhachHangID" = (SELECT private.current_customer_id())
			OR (SELECT private.is_staff())
		);
	DROP POLICY IF EXISTS laundry_compat_delivery_read ON public."GiaoNhan";
	CREATE POLICY laundry_compat_delivery_read ON public."GiaoNhan"
		FOR SELECT TO authenticated USING (
			(SELECT private.can_access_order("DonHangID"))
		);
	DROP POLICY IF EXISTS laundry_compat_invoice_read ON public."HoaDon";
	CREATE POLICY laundry_compat_invoice_read ON public."HoaDon"
		FOR SELECT TO authenticated USING (
			(SELECT private.can_access_order("DonHangID"))
		);
	DROP POLICY IF EXISTS laundry_compat_payment_read ON public."ThanhToan";
	CREATE POLICY laundry_compat_payment_read ON public."ThanhToan"
		FOR SELECT TO authenticated USING (
			(SELECT private.can_access_order("DonHangID"))
		);
	DROP POLICY IF EXISTS laundry_compat_invoice_history_read ON public."LichSuThayDoiHoaDon";
	CREATE POLICY laundry_compat_invoice_history_read
		ON public."LichSuThayDoiHoaDon" FOR SELECT TO authenticated USING (
			EXISTS (
				SELECT 1 FROM public."HoaDon" AS invoice
				WHERE invoice."HoaDonID" = "LichSuThayDoiHoaDon"."HoaDonID"
					AND (SELECT private.can_access_order(invoice."DonHangID"))
			)
		);
	DROP POLICY IF EXISTS laundry_compat_notification_read ON public."ThongBao";
	CREATE POLICY laundry_compat_notification_read ON public."ThongBao"
		FOR SELECT TO authenticated USING (
			"TaiKhoanID" = (SELECT private.current_account_id())
		);
	DROP POLICY IF EXISTS laundry_compat_notification_update ON public."ThongBao";
	CREATE POLICY laundry_compat_notification_update ON public."ThongBao"
		FOR UPDATE TO authenticated
		USING ("TaiKhoanID" = (SELECT private.current_account_id()))
		WITH CHECK ("TaiKhoanID" = (SELECT private.current_account_id()));
	DROP POLICY IF EXISTS laundry_compat_message_read ON public."TinNhan";
	CREATE POLICY laundry_compat_message_read ON public."TinNhan"
		FOR SELECT TO authenticated USING (
			"NguoiGuiID" = (SELECT private.current_account_id())
			OR "NguoiNhanID" = (SELECT private.current_account_id())
			OR (
				"DonHangID" IS NOT NULL
				AND (SELECT private.is_staff())
				AND (SELECT private.can_access_order("DonHangID"))
			)
		);
	DROP POLICY IF EXISTS laundry_compat_review_read ON public."DanhGia";
	CREATE POLICY laundry_compat_review_read ON public."DanhGia"
		FOR SELECT TO authenticated USING (
			"KhachHangID" = (SELECT private.current_customer_id())
			OR (SELECT private.is_staff())
		);
	DROP POLICY IF EXISTS laundry_compat_review_insert ON public."DanhGia";
	CREATE POLICY laundry_compat_review_insert ON public."DanhGia"
		FOR INSERT TO authenticated WITH CHECK (
			"KhachHangID" = (SELECT private.current_customer_id())
			AND EXISTS (
				SELECT 1 FROM public."DonHang" AS order_record
				WHERE order_record."DonHangID" = "DanhGia"."DonHangID"
					AND order_record."KhachHangID" = (SELECT private.current_customer_id())
					AND order_record."TrangThai" IN ('Đã giao', 'Đã thanh toán')
			)
		);
	DROP POLICY IF EXISTS laundry_compat_role_read ON public."VaiTro";
	CREATE POLICY laundry_compat_role_read ON public."VaiTro"
		FOR SELECT TO authenticated USING (
			"TrangThai" = 'Hoạt động'
			AND (SELECT private.current_account_id()) IS NOT NULL
		);
	DROP POLICY IF EXISTS laundry_compat_permission_read ON public."Quyen";
	CREATE POLICY laundry_compat_permission_read ON public."Quyen"
		FOR SELECT TO authenticated USING (
			(SELECT private.current_account_id()) IS NOT NULL
		);
	DROP POLICY IF EXISTS laundry_compat_account_role_read ON public."TaiKhoan_VaiTro";
	CREATE POLICY laundry_compat_account_role_read ON public."TaiKhoan_VaiTro"
		FOR SELECT TO authenticated USING (
			"TaiKhoanID" = (SELECT private.current_account_id())
			OR (SELECT private.has_role('Quản lý'))
			OR (SELECT private.has_role('Chủ cửa hàng'))
		);
	DROP POLICY IF EXISTS laundry_compat_role_permission_read ON public."VaiTro_Quyen";
	CREATE POLICY laundry_compat_role_permission_read ON public."VaiTro_Quyen"
		FOR SELECT TO authenticated USING (
			(SELECT private.current_account_id()) IS NOT NULL
		);

	DROP POLICY IF EXISTS laundry_compat_address_read ON public.khachhang_diachi;
	CREATE POLICY laundry_compat_address_read ON public.khachhang_diachi
		FOR SELECT TO authenticated USING (
			khachhangid = (SELECT private.current_customer_id())
		);
	DROP POLICY IF EXISTS laundry_compat_address_delete ON public.khachhang_diachi;
	CREATE POLICY laundry_compat_address_delete ON public.khachhang_diachi
		FOR DELETE TO authenticated USING (
			khachhangid = (SELECT private.current_customer_id())
		);
	DROP POLICY IF EXISTS laundry_compat_order_status_read ON public.donhang_trangthai;
	CREATE POLICY laundry_compat_order_status_read ON public.donhang_trangthai
		FOR SELECT TO authenticated USING (
			(SELECT private.can_access_order(donhangid))
		);

	EXECUTE $function$
		CREATE OR REPLACE FUNCTION private.record_legacy_order_status_change()
		RETURNS trigger LANGUAGE plpgsql SECURITY DEFINER SET search_path = ''
		AS $body$
		BEGIN
			IF TG_OP = 'INSERT' THEN
				INSERT INTO public.donhang_trangthai (
					donhangid, taikhoanid, trangthaicu, trangthaimoi
				) VALUES (
					NEW."DonHangID", (SELECT private.current_account_id()),
					NULL, NEW."TrangThai"
				);
			ELSIF OLD."TrangThai" IS DISTINCT FROM NEW."TrangThai" THEN
				INSERT INTO public.donhang_trangthai (
					donhangid, taikhoanid, trangthaicu, trangthaimoi
				) VALUES (
					NEW."DonHangID", (SELECT private.current_account_id()),
					OLD."TrangThai", NEW."TrangThai"
				);
			END IF;
			RETURN NEW;
		END;
		$body$
	$function$;
	REVOKE ALL ON FUNCTION private.record_legacy_order_status_change()
		FROM PUBLIC, anon, authenticated, service_role;
	DROP TRIGGER IF EXISTS laundry_compat_record_order_insert ON public."DonHang";
	DROP TRIGGER IF EXISTS laundry_compat_record_order_status ON public."DonHang";
	CREATE TRIGGER laundry_compat_record_order_insert
		AFTER INSERT ON public."DonHang"
		FOR EACH ROW EXECUTE FUNCTION private.record_legacy_order_status_change();
	CREATE TRIGGER laundry_compat_record_order_status
		AFTER UPDATE OF "TrangThai" ON public."DonHang"
		FOR EACH ROW EXECUTE FUNCTION private.record_legacy_order_status_change();
	NOTIFY pgrst, 'reload schema';
END;
$migration$;
