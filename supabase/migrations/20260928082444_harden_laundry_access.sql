BEGIN;

CREATE SCHEMA IF NOT EXISTS private;
REVOKE ALL ON SCHEMA private FROM PUBLIC, anon;
GRANT USAGE ON SCHEMA private TO authenticated;

CREATE UNIQUE INDEX IF NOT EXISTS taikhoan_userauthid_unique_idx
	ON public.taikhoan (userauthid)
	WHERE userauthid IS NOT NULL;

CREATE OR REPLACE FUNCTION private.current_account_id()
RETURNS bigint
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = ''
AS $$
	SELECT account.taikhoanid
	FROM public.taikhoan AS account
	WHERE account.userauthid = (SELECT auth.uid())
		AND account.trangthai = 'Hoạt động';
$$;

CREATE OR REPLACE FUNCTION private.current_customer_id()
RETURNS bigint
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = ''
AS $$
	SELECT account.khachhangid
	FROM public.taikhoan AS account
	JOIN public.khachhang AS customer
		ON customer.khachhangid = account.khachhangid
	WHERE account.userauthid = (SELECT auth.uid())
		AND account.trangthai = 'Hoạt động'
		AND customer.trangthai = 'Hoạt động';
$$;

CREATE OR REPLACE FUNCTION private.current_employee_id()
RETURNS bigint
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = ''
AS $$
	SELECT account.nhanvienid
	FROM public.taikhoan AS account
	JOIN public.nhanvien AS employee
		ON employee.nhanvienid = account.nhanvienid
	WHERE account.userauthid = (SELECT auth.uid())
		AND account.trangthai = 'Hoạt động'
		AND employee.trangthai = 'Hoạt động';
$$;

CREATE OR REPLACE FUNCTION private.has_role(role_name text)
RETURNS boolean
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = ''
AS $$
	SELECT EXISTS (
		SELECT 1
		FROM public.taikhoan AS account
		JOIN public.taikhoan_vaitro AS account_role
			ON account_role.taikhoanid = account.taikhoanid
		JOIN public.vaitro AS app_role
			ON app_role.vaitroid = account_role.vaitroid
		WHERE account.userauthid = (SELECT auth.uid())
			AND account.trangthai = 'Hoạt động'
			AND app_role.tenvaitro = role_name
			AND app_role.trangthai = 'Hoạt động'
	);
$$;

CREATE OR REPLACE FUNCTION private.is_staff()
RETURNS boolean
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = ''
AS $$
	SELECT (SELECT private.has_role('Nhân viên'))
			OR (SELECT private.has_role('Quản lý'))
			OR (SELECT private.has_role('Chủ cửa hàng'));
$$;

CREATE OR REPLACE FUNCTION private.can_access_order(order_id bigint)
RETURNS boolean
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = ''
AS $$
	SELECT (SELECT auth.uid()) IS NOT NULL
		AND EXISTS (
			SELECT 1
			FROM public.donhang AS order_record
			WHERE order_record.donhangid = order_id
				AND (
					order_record.khachhangid = (SELECT private.current_customer_id())
					OR (SELECT private.is_staff())
				)
		);
$$;

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

REVOKE ALL PRIVILEGES ON ALL TABLES IN SCHEMA public FROM PUBLIC, anon, authenticated;
REVOKE ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public FROM PUBLIC, anon, authenticated;
REVOKE ALL PRIVILEGES ON ALL FUNCTIONS IN SCHEMA public FROM PUBLIC, anon, authenticated;

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public
	REVOKE ALL ON TABLES FROM anon, authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public
	REVOKE ALL ON SEQUENCES FROM anon, authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public
	REVOKE ALL ON FUNCTIONS FROM anon, authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public
	REVOKE EXECUTE ON FUNCTIONS FROM PUBLIC;

ALTER TABLE public.banggia ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.booking ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.chitietdonhang ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.danhgia ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.dichvu ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.diemtichluy ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.donhang ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.donvitinh ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.giaonhan ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.hoadon ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.khachhang ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.khuyenmai ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.lichsuthaydoihoadon ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.loaidichvu ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.loaidogiat ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.nhanvien ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.quyen ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.taikhoan ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.taikhoan_vaitro ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.thanhtoan ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.thongbao ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tinnhan ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.vaitro ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.vaitro_quyen ENABLE ROW LEVEL SECURITY;

GRANT SELECT ON public.loaidichvu, public.dichvu, public.donvitinh,
	public.loaidogiat, public.banggia, public.khuyenmai
	TO anon, authenticated;

GRANT SELECT ON public.khachhang, public.nhanvien, public.booking,
	public.chitietdonhang, public.diemtichluy, public.donhang,
	public.giaonhan, public.hoadon, public.lichsuthaydoihoadon,
	public.taikhoan_vaitro, public.thanhtoan, public.thongbao,
	public.tinnhan, public.danhgia, public.vaitro, public.vaitro_quyen,
	public.quyen
	TO authenticated;
GRANT SELECT (taikhoanid, khachhangid, nhanvienid, email, ngaytao,
	sodienthoai, tendangnhap, trangthai, userauthid)
	ON public.taikhoan TO authenticated;
GRANT UPDATE (hoten, email, diachi) ON public.khachhang TO authenticated;
GRANT UPDATE (dadoc) ON public.thongbao TO authenticated;
GRANT INSERT (donhangid, khachhangid, sosao, binhluan)
	ON public.danhgia TO authenticated;
GRANT USAGE ON SEQUENCE public.danhgia_danhgiaid_seq TO authenticated;

CREATE POLICY loaidichvu_active_read
	ON public.loaidichvu FOR SELECT TO anon, authenticated
	USING (trangthai = 'Hoạt động');
CREATE POLICY dichvu_active_read
	ON public.dichvu FOR SELECT TO anon, authenticated
	USING (trangthai = 'Hoạt động');
CREATE POLICY donvitinh_active_read
	ON public.donvitinh FOR SELECT TO anon, authenticated
	USING (trangthai = 'Hoạt động');
CREATE POLICY loaidogiat_active_read
	ON public.loaidogiat FOR SELECT TO anon, authenticated
	USING (trangthai = 'Hoạt động');
CREATE POLICY banggia_current_read
	ON public.banggia FOR SELECT TO anon, authenticated
	USING (
		trangthai = 'Hoạt động'
		AND ngayapdung <= current_date
		AND (ngayketthuc IS NULL OR ngayketthuc >= current_date)
	);
CREATE POLICY khuyenmai_current_read
	ON public.khuyenmai FOR SELECT TO anon, authenticated
	USING (
		trangthai = 'Hoạt động'
		AND ngaybatdau <= current_date
		AND ngayketthuc >= current_date
		AND (soluongsudung IS NULL OR soluongsudung > 0)
	);

CREATE POLICY vaitro_active_read
	ON public.vaitro FOR SELECT TO authenticated
	USING (trangthai = 'Hoạt động' AND (SELECT private.current_account_id()) IS NOT NULL);
CREATE POLICY quyen_linked_read
	ON public.quyen FOR SELECT TO authenticated
	USING ((SELECT private.current_account_id()) IS NOT NULL);
CREATE POLICY vaitro_quyen_linked_read
	ON public.vaitro_quyen FOR SELECT TO authenticated
	USING ((SELECT private.current_account_id()) IS NOT NULL);

CREATE POLICY taikhoan_self_or_manager_read
	ON public.taikhoan FOR SELECT TO authenticated
	USING (
		taikhoanid = (SELECT private.current_account_id())
		OR (SELECT private.has_role('Quản lý'))
		OR (SELECT private.has_role('Chủ cửa hàng'))
	);
CREATE POLICY taikhoan_vaitro_self_or_manager_read
	ON public.taikhoan_vaitro FOR SELECT TO authenticated
	USING (
		taikhoanid = (SELECT private.current_account_id())
		OR (SELECT private.has_role('Quản lý'))
		OR (SELECT private.has_role('Chủ cửa hàng'))
	);
CREATE POLICY khachhang_self_or_staff_read
	ON public.khachhang FOR SELECT TO authenticated
	USING (
		khachhangid = (SELECT private.current_customer_id())
		OR (SELECT private.is_staff())
	);
CREATE POLICY khachhang_self_update
	ON public.khachhang FOR UPDATE TO authenticated
	USING (khachhangid = (SELECT private.current_customer_id()))
	WITH CHECK (khachhangid = (SELECT private.current_customer_id()));
CREATE POLICY nhanvien_self_or_manager_read
	ON public.nhanvien FOR SELECT TO authenticated
	USING (
		nhanvienid = (SELECT private.current_employee_id())
		OR (SELECT private.has_role('Quản lý'))
		OR (SELECT private.has_role('Chủ cửa hàng'))
	);

CREATE POLICY booking_owner_or_staff_read
	ON public.booking FOR SELECT TO authenticated
	USING (
		khachhangid = (SELECT private.current_customer_id())
		OR (SELECT private.is_staff())
	);
CREATE POLICY donhang_owner_or_staff_read
	ON public.donhang FOR SELECT TO authenticated
	USING (
		khachhangid = (SELECT private.current_customer_id())
		OR (SELECT private.is_staff())
	);
CREATE POLICY chitietdonhang_order_access_read
	ON public.chitietdonhang FOR SELECT TO authenticated
	USING ((SELECT private.can_access_order(donhangid)));
CREATE POLICY diemtichluy_owner_or_staff_read
	ON public.diemtichluy FOR SELECT TO authenticated
	USING (
		khachhangid = (SELECT private.current_customer_id())
		OR (SELECT private.is_staff())
	);
CREATE POLICY giaonhan_order_access_read
	ON public.giaonhan FOR SELECT TO authenticated
	USING ((SELECT private.can_access_order(donhangid)));
CREATE POLICY hoadon_order_access_read
	ON public.hoadon FOR SELECT TO authenticated
	USING ((SELECT private.can_access_order(donhangid)));
CREATE POLICY thanhtoan_order_access_read
	ON public.thanhtoan FOR SELECT TO authenticated
	USING ((SELECT private.can_access_order(donhangid)));
CREATE POLICY lichsuthaydoihoadon_order_access_read
	ON public.lichsuthaydoihoadon FOR SELECT TO authenticated
	USING (
		EXISTS (
			SELECT 1
			FROM public.hoadon AS invoice
			WHERE invoice.hoadonid = lichsuthaydoihoadon.hoadonid
				AND (SELECT private.can_access_order(invoice.donhangid))
		)
	);
CREATE POLICY thongbao_owner_read
	ON public.thongbao FOR SELECT TO authenticated
	USING (taikhoanid = (SELECT private.current_account_id()));
CREATE POLICY thongbao_owner_update
	ON public.thongbao FOR UPDATE TO authenticated
	USING (taikhoanid = (SELECT private.current_account_id()))
	WITH CHECK (taikhoanid = (SELECT private.current_account_id()));
CREATE POLICY tinnhan_participant_or_staff_read
	ON public.tinnhan FOR SELECT TO authenticated
	USING (
		nguoiguiid = (SELECT private.current_account_id())
		OR nguoinhanid = (SELECT private.current_account_id())
		OR (
			donhangid IS NOT NULL
			AND (SELECT private.is_staff())
			AND (SELECT private.can_access_order(donhangid))
		)
	);
CREATE POLICY danhgia_owner_or_staff_read
	ON public.danhgia FOR SELECT TO authenticated
	USING (
		khachhangid = (SELECT private.current_customer_id())
		OR (SELECT private.is_staff())
	);
CREATE POLICY danhgia_completed_order_insert
	ON public.danhgia FOR INSERT TO authenticated
	WITH CHECK (
		khachhangid = (SELECT private.current_customer_id())
		AND EXISTS (
			SELECT 1
			FROM public.donhang AS order_record
			WHERE order_record.donhangid = danhgia.donhangid
				AND order_record.khachhangid = (SELECT private.current_customer_id())
				AND order_record.trangthai IN ('Đã giao', 'Đã thanh toán')
		)
	);

COMMIT;
