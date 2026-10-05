DO $restore$
DECLARE
	item record;
	legacy_table oid;
	projection text;
BEGIN
	IF to_regclass('public."BangGia"') IS NULL THEN
		RETURN;
	END IF;

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

		EXECUTE format(
			'GRANT SELECT ON public.%I TO authenticated', item.api_name
		);
	END LOOP;

	GRANT SELECT ON public."BangGia", public."DichVu", public."LoaiDoGiat",
		public."DonViTinh", public."LoaiDichVu", public."KhuyenMai" TO anon;
	GRANT SELECT ON public.banggia, public.dichvu, public.loaidogiat,
		public.donvitinh, public.loaidichvu, public.khuyenmai TO anon;
	GRANT UPDATE ("HoTen", "Email", "DiaChi")
		ON public."KhachHang" TO authenticated;
	GRANT UPDATE ("DaDoc") ON public."ThongBao" TO authenticated;
	GRANT UPDATE (hoten, email, diachi) ON public.khachhang TO authenticated;
	GRANT UPDATE (dadoc) ON public.thongbao TO authenticated;
	NOTIFY pgrst, 'reload schema';
END;
$restore$;
