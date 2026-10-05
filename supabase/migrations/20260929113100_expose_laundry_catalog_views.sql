BEGIN;

DO $migration$
BEGIN
  IF to_regclass('public."BangGia"') IS NOT NULL
      AND to_regclass('public."DichVu"') IS NOT NULL
      AND to_regclass('public."LoaiDoGiat"') IS NOT NULL
      AND to_regclass('public."DonViTinh"') IS NOT NULL
      AND to_regclass('public.banggia') IS NULL
      AND to_regclass('public.dichvu') IS NULL
      AND to_regclass('public.loaidogiat') IS NULL
      AND to_regclass('public.donvitinh') IS NULL THEN
    EXECUTE $statement$
      CREATE POLICY mobile_active_prices_read
        ON public."BangGia" FOR SELECT TO anon, authenticated
        USING (
          "TrangThai" = 'Hoạt động'
          AND "NgayApDung" <= current_date
          AND ("NgayKetThuc" IS NULL OR "NgayKetThuc" >= current_date)
        )
    $statement$;
    EXECUTE $statement$
      CREATE POLICY mobile_active_services_read
        ON public."DichVu" FOR SELECT TO anon, authenticated
        USING ("TrangThai" = 'Hoạt động')
    $statement$;
    EXECUTE $statement$
      CREATE POLICY mobile_active_item_types_read
        ON public."LoaiDoGiat" FOR SELECT TO anon, authenticated
        USING ("TrangThai" = 'Hoạt động')
    $statement$;
    EXECUTE $statement$
      CREATE POLICY mobile_active_units_read
        ON public."DonViTinh" FOR SELECT TO anon, authenticated
        USING ("TrangThai" = 'Hoạt động')
    $statement$;

    EXECUTE $statement$
      CREATE VIEW public.banggia
      WITH (security_invoker = true)
      AS SELECT
        "BangGiaID" AS banggiaid,
        "DichVuID" AS dichvuid,
        "LoaiDoGiatID" AS loaidogiatid,
        "DonViTinhID" AS donvitinhid,
        "DonGia" AS dongia,
        "NgayApDung" AS ngayapdung,
        "NgayKetThuc" AS ngayketthuc,
        "TrangThai" AS trangthai
      FROM public."BangGia"
    $statement$;
    EXECUTE $statement$
      CREATE VIEW public.dichvu
      WITH (security_invoker = true)
      AS SELECT
        "DichVuID" AS dichvuid,
        "LoaiDichVuID" AS loaidichvuid,
        "TenDichVu" AS tendichvu,
        "MoTa" AS mota,
        "ThoiGianDuKien" AS thoigiandukien,
        "TrangThai" AS trangthai,
        "NgayTao" AS ngaytao
      FROM public."DichVu"
    $statement$;
    EXECUTE $statement$
      CREATE VIEW public.loaidogiat
      WITH (security_invoker = true)
      AS SELECT
        "LoaiDoGiatID" AS loaidogiatid,
        "TenLoaiDoGiat" AS tenloaidogiat,
        "MoTa" AS mota,
        "TrangThai" AS trangthai
      FROM public."LoaiDoGiat"
    $statement$;
    EXECUTE $statement$
      CREATE VIEW public.donvitinh
      WITH (security_invoker = true)
      AS SELECT
        "DonViTinhID" AS donvitinhid,
        "TenDonViTinh" AS tendonvitinh,
        "KyHieu" AS kyhieu,
        "TrangThai" AS trangthai
      FROM public."DonViTinh"
    $statement$;

    GRANT SELECT ON public."BangGia", public."DichVu",
      public."LoaiDoGiat", public."DonViTinh" TO anon, authenticated;
    GRANT SELECT ON public.banggia, public.dichvu,
      public.loaidogiat, public.donvitinh TO anon, authenticated;
    NOTIFY pgrst, 'reload schema';
  END IF;
END;
$migration$;

COMMIT;