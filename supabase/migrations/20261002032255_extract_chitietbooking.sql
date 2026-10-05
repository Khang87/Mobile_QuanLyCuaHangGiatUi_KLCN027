SET local check_function_bodies = off;

REVOKE ALL ON FUNCTION "public"."transition_laundry_order"(bigint, text, text) FROM "authenticated";

DROP POLICY "danhgia_completed_order_insert" ON "public"."danhgia";

DROP POLICY "khachhang_diachi_owner_delete" ON "public"."khachhang_diachi";

DROP POLICY "khachhang_diachi_owner_insert" ON "public"."khachhang_diachi";

DROP POLICY "khachhang_diachi_owner_select" ON "public"."khachhang_diachi";

DROP POLICY "khachhang_diachi_owner_update" ON "public"."khachhang_diachi";

DROP POLICY "lichsuthaydoihoadon_order_access_read" ON "public"."lichsuthaydoihoadon";

ALTER TABLE "public"."banggia"
  DROP CONSTRAINT "banggia_dichvuid_fkey";

ALTER TABLE "public"."banggia"
  DROP CONSTRAINT "banggia_donvitinhid_fkey";

ALTER TABLE "public"."banggia"
  DROP CONSTRAINT "banggia_loaidogiatid_fkey";

ALTER TABLE "public"."booking"
  DROP CONSTRAINT "booking_dichvuid_fkey";

ALTER TABLE "public"."booking"
  DROP CONSTRAINT "booking_donvitinhid_fkey";

ALTER TABLE "public"."booking"
  DROP CONSTRAINT "booking_khachhangid_fkey";

ALTER TABLE "public"."booking"
  DROP CONSTRAINT "booking_loaidogiatid_fkey";

ALTER TABLE "public"."chitietdonhang"
  DROP CONSTRAINT "chitietdonhang_dichvuid_fkey";

ALTER TABLE "public"."chitietdonhang"
  DROP CONSTRAINT "chitietdonhang_donhangid_fkey";

ALTER TABLE "public"."chitietdonhang"
  DROP CONSTRAINT "chitietdonhang_donvitinhid_fkey";

ALTER TABLE "public"."chitietdonhang"
  DROP CONSTRAINT "chitietdonhang_loaidogiatid_fkey";

ALTER TABLE "public"."danhgia"
  DROP CONSTRAINT "danhgia_donhangid_fkey";

ALTER TABLE "public"."danhgia"
  DROP CONSTRAINT "danhgia_khachhangid_fkey";

ALTER TABLE "public"."dichvu"
  DROP CONSTRAINT "dichvu_loaidichvuid_fkey";

ALTER TABLE "public"."diemtichluy"
  DROP CONSTRAINT "diemtichluy_khachhangid_fkey";

ALTER TABLE "public"."donhang"
  DROP CONSTRAINT "donhang_bookingid_fkey";

ALTER TABLE "public"."donhang"
  DROP CONSTRAINT "donhang_khachhangid_fkey";

ALTER TABLE "public"."donhang"
  DROP CONSTRAINT "donhang_khuyenmaiid_fkey";

ALTER TABLE "public"."donhang"
  DROP CONSTRAINT "donhang_nhanvienid_fkey";

ALTER TABLE "public"."donhang_trangthai"
  DROP CONSTRAINT "donhang_trangthai_donhangid_fkey";

ALTER TABLE "public"."donhang_trangthai"
  DROP CONSTRAINT "donhang_trangthai_taikhoanid_fkey";

ALTER TABLE "public"."giaonhan"
  DROP CONSTRAINT "giaonhan_donhangid_fkey";

ALTER TABLE "public"."giaonhan"
  DROP CONSTRAINT "giaonhan_nhanvienid_fkey";

ALTER TABLE "public"."hoadon"
  DROP CONSTRAINT "hoadon_donhangid_fkey";

ALTER TABLE "public"."khachhang_diachi"
  DROP CONSTRAINT "khachhang_diachi_khachhangid_fkey";

ALTER TABLE "public"."lichsuthaydoihoadon"
  DROP CONSTRAINT "lichsuthaydoihoadon_hoadonid_fkey";

ALTER TABLE "public"."lichsuthaydoihoadon"
  DROP CONSTRAINT "lichsuthaydoihoadon_taikhoanid_fkey";

ALTER TABLE "public"."taikhoan"
  DROP CONSTRAINT "taikhoan_khachhangid_fkey";

ALTER TABLE "public"."taikhoan"
  DROP CONSTRAINT "taikhoan_nhanvienid_fkey";

ALTER TABLE "public"."taikhoan"
  DROP CONSTRAINT "taikhoan_userauthid_fkey";

ALTER TABLE "public"."taikhoan_vaitro"
  DROP CONSTRAINT "taikhoan_vaitro_taikhoanid_fkey";

ALTER TABLE "public"."taikhoan_vaitro"
  DROP CONSTRAINT "taikhoan_vaitro_vaitroid_fkey";

ALTER TABLE "public"."thanhtoan"
  DROP CONSTRAINT "thanhtoan_donhangid_fkey";

ALTER TABLE "public"."thongbao"
  DROP CONSTRAINT "thongbao_donhangid_fkey";

ALTER TABLE "public"."thongbao"
  DROP CONSTRAINT "thongbao_taikhoanid_fkey";

ALTER TABLE "public"."tinnhan"
  DROP CONSTRAINT "tinnhan_donhangid_fkey";

ALTER TABLE "public"."tinnhan"
  DROP CONSTRAINT "tinnhan_nguoiguiid_fkey";

ALTER TABLE "public"."tinnhan"
  DROP CONSTRAINT "tinnhan_nguoinhanid_fkey";

ALTER TABLE "public"."vaitro_quyen"
  DROP CONSTRAINT "vaitro_quyen_quyenid_fkey";

ALTER TABLE "public"."vaitro_quyen"
  DROP CONSTRAINT "vaitro_quyen_vaitroid_fkey";

DROP TABLE "public"."banggia";

DROP TABLE "public"."booking";

DROP TABLE "public"."chitietdonhang";

DROP TABLE "public"."danhgia";

DROP TABLE "public"."dichvu";

DROP TABLE "public"."diemtichluy";

DROP TABLE "public"."donhang_trangthai";

DROP TABLE "public"."donhang";

DROP TABLE "public"."donvitinh";

DROP TABLE "public"."giaonhan";

DROP TABLE "public"."hoadon";

DROP TABLE "public"."khachhang";

DROP TABLE "public"."khuyenmai";

DROP TABLE "public"."lichsuthaydoihoadon";

DROP TABLE "public"."loaidichvu";

DROP TABLE "public"."loaidogiat";

DROP TABLE "public"."nhanvien";

DROP TABLE "public"."quyen";

DROP TABLE "public"."taikhoan_vaitro";

DROP TABLE "public"."taikhoan";

DROP TABLE "public"."thanhtoan";

DROP TABLE "public"."thongbao";

DROP TABLE "public"."tinnhan";

DROP TABLE "public"."vaitro_quyen";

DROP TABLE "public"."vaitro";

CREATE SEQUENCE "public"."BangGia_BangGiaID_seq" AS integer INCREMENT BY 1 MINVALUE 1 MAXVALUE 2147483647 START WITH 1 CACHE 1 NO CYCLE;

REVOKE ALL ON SEQUENCE "public"."BangGia_BangGiaID_seq" FROM "anon", "authenticated";

CREATE SEQUENCE "public"."Booking_BookingID_seq" AS integer INCREMENT BY 1 MINVALUE 1 MAXVALUE 2147483647 START WITH 1 CACHE 1 NO CYCLE;

REVOKE ALL ON SEQUENCE "public"."Booking_BookingID_seq" FROM "anon", "authenticated";

CREATE SEQUENCE "public"."ChiTietDonHang_ChiTietDonHangID_seq" AS integer INCREMENT BY 1 MINVALUE 1 MAXVALUE 2147483647 START WITH 1 CACHE 1 NO CYCLE;

REVOKE ALL ON SEQUENCE "public"."ChiTietDonHang_ChiTietDonHangID_seq" FROM "anon", "authenticated";

CREATE SEQUENCE "public"."DanhGia_DanhGiaID_seq" AS integer INCREMENT BY 1 MINVALUE 1 MAXVALUE 2147483647 START WITH 1 CACHE 1 NO CYCLE;

REVOKE ALL ON SEQUENCE "public"."DanhGia_DanhGiaID_seq" FROM "anon", "authenticated";

CREATE SEQUENCE "public"."DichVu_DichVuID_seq" AS integer INCREMENT BY 1 MINVALUE 1 MAXVALUE 2147483647 START WITH 1 CACHE 1 NO CYCLE;

REVOKE ALL ON SEQUENCE "public"."DichVu_DichVuID_seq" FROM "anon", "authenticated";

CREATE SEQUENCE "public"."DiemTichLuy_DiemTichLuyID_seq" AS integer INCREMENT BY 1 MINVALUE 1 MAXVALUE 2147483647 START WITH 1 CACHE 1 NO CYCLE;

REVOKE ALL ON SEQUENCE "public"."DiemTichLuy_DiemTichLuyID_seq" FROM "anon", "authenticated";

CREATE SEQUENCE "public"."DonHang_DonHangID_seq" AS integer INCREMENT BY 1 MINVALUE 1 MAXVALUE 2147483647 START WITH 1 CACHE 1 NO CYCLE;

REVOKE ALL ON SEQUENCE "public"."DonHang_DonHangID_seq" FROM "anon", "authenticated";

CREATE SEQUENCE "public"."DonViTinh_DonViTinhID_seq" AS integer INCREMENT BY 1 MINVALUE 1 MAXVALUE 2147483647 START WITH 1 CACHE 1 NO CYCLE;

REVOKE ALL ON SEQUENCE "public"."DonViTinh_DonViTinhID_seq" FROM "anon", "authenticated";

CREATE SEQUENCE "public"."GiaoNhan_GiaoNhanID_seq" AS integer INCREMENT BY 1 MINVALUE 1 MAXVALUE 2147483647 START WITH 1 CACHE 1 NO CYCLE;

REVOKE ALL ON SEQUENCE "public"."GiaoNhan_GiaoNhanID_seq" FROM "anon", "authenticated";

CREATE SEQUENCE "public"."HoaDon_HoaDonID_seq" AS integer INCREMENT BY 1 MINVALUE 1 MAXVALUE 2147483647 START WITH 1 CACHE 1 NO CYCLE;

REVOKE ALL ON SEQUENCE "public"."HoaDon_HoaDonID_seq" FROM "anon", "authenticated";

CREATE SEQUENCE "public"."KhachHang_KhachHangID_seq" AS integer INCREMENT BY 1 MINVALUE 1 MAXVALUE 2147483647 START WITH 1 CACHE 1 NO CYCLE;

REVOKE ALL ON SEQUENCE "public"."KhachHang_KhachHangID_seq" FROM "anon", "authenticated";

CREATE SEQUENCE "public"."KhuyenMai_KhuyenMaiID_seq" AS integer INCREMENT BY 1 MINVALUE 1 MAXVALUE 2147483647 START WITH 1 CACHE 1 NO CYCLE;

REVOKE ALL ON SEQUENCE "public"."KhuyenMai_KhuyenMaiID_seq" FROM "anon", "authenticated";

CREATE SEQUENCE "public"."LichSuThayDoiHoaDon_LichSuID_seq" AS integer INCREMENT BY 1 MINVALUE 1 MAXVALUE 2147483647 START WITH 1 CACHE 1 NO CYCLE;

REVOKE ALL ON SEQUENCE "public"."LichSuThayDoiHoaDon_LichSuID_seq" FROM "anon", "authenticated";

CREATE SEQUENCE "public"."LoaiDichVu_LoaiDichVuID_seq" AS integer INCREMENT BY 1 MINVALUE 1 MAXVALUE 2147483647 START WITH 1 CACHE 1 NO CYCLE;

REVOKE ALL ON SEQUENCE "public"."LoaiDichVu_LoaiDichVuID_seq" FROM "anon", "authenticated";

CREATE SEQUENCE "public"."LoaiDoGiat_LoaiDoGiatID_seq" AS integer INCREMENT BY 1 MINVALUE 1 MAXVALUE 2147483647 START WITH 1 CACHE 1 NO CYCLE;

REVOKE ALL ON SEQUENCE "public"."LoaiDoGiat_LoaiDoGiatID_seq" FROM "anon", "authenticated";

CREATE SEQUENCE "public"."NhanVien_NhanVienID_seq" AS integer INCREMENT BY 1 MINVALUE 1 MAXVALUE 2147483647 START WITH 1 CACHE 1 NO CYCLE;

REVOKE ALL ON SEQUENCE "public"."NhanVien_NhanVienID_seq" FROM "anon", "authenticated";

CREATE SEQUENCE "public"."Quyen_QuyenID_seq" AS integer INCREMENT BY 1 MINVALUE 1 MAXVALUE 2147483647 START WITH 1 CACHE 1 NO CYCLE;

REVOKE ALL ON SEQUENCE "public"."Quyen_QuyenID_seq" FROM "anon", "authenticated";

CREATE SEQUENCE "public"."TaiKhoan_TaiKhoanID_seq" AS integer INCREMENT BY 1 MINVALUE 1 MAXVALUE 2147483647 START WITH 1 CACHE 1 NO CYCLE;

REVOKE ALL ON SEQUENCE "public"."TaiKhoan_TaiKhoanID_seq" FROM "anon", "authenticated";

CREATE SEQUENCE "public"."ThanhToan_ThanhToanID_seq" AS integer INCREMENT BY 1 MINVALUE 1 MAXVALUE 2147483647 START WITH 1 CACHE 1 NO CYCLE;

REVOKE ALL ON SEQUENCE "public"."ThanhToan_ThanhToanID_seq" FROM "anon", "authenticated";

CREATE SEQUENCE "public"."ThongBao_ThongBaoID_seq" AS integer INCREMENT BY 1 MINVALUE 1 MAXVALUE 2147483647 START WITH 1 CACHE 1 NO CYCLE;

REVOKE ALL ON SEQUENCE "public"."ThongBao_ThongBaoID_seq" FROM "anon", "authenticated";

CREATE SEQUENCE "public"."TinNhan_TinNhanID_seq" AS integer INCREMENT BY 1 MINVALUE 1 MAXVALUE 2147483647 START WITH 1 CACHE 1 NO CYCLE;

REVOKE ALL ON SEQUENCE "public"."TinNhan_TinNhanID_seq" FROM "anon", "authenticated";

CREATE SEQUENCE "public"."VaiTro_VaiTroID_seq" AS integer INCREMENT BY 1 MINVALUE 1 MAXVALUE 2147483647 START WITH 1 CACHE 1 NO CYCLE;

REVOKE ALL ON SEQUENCE "public"."VaiTro_VaiTroID_seq" FROM "anon", "authenticated";

CREATE TABLE "public"."BangGia" (
  "BangGiaID"    integer               NOT NULL DEFAULT nextval('public."BangGia_BangGiaID_seq"'::regclass),
  "DichVuID"     integer               NOT NULL,
  "LoaiDoGiatID" integer               NOT NULL,
  "DonViTinhID"  integer               NOT NULL,
  "DonGia"       numeric(18,2)         NOT NULL,
  "NgayApDung"   date                  NOT NULL,
  "NgayKetThuc"  date,
  "TrangThai"    character varying(30) NOT NULL DEFAULT 'Hoạt động'::character varying,
  CONSTRAINT "BangGia_DonGia_check" CHECK (("DonGia" >= (0)::numeric)),
  CONSTRAINT "BangGia_TrangThai_check"
    CHECK ((("TrangThai")::text = ANY ((ARRAY['Hoạt động'::character varying, 'Hết hiệu lực'::character varying, 'Tạm ngưng'::character varying])::text[]))),
  CONSTRAINT "BangGia_pkey" PRIMARY KEY ("BangGiaID"),
  CONSTRAINT "CK_BangGia_Ngay" CHECK ((("NgayKetThuc" IS NULL) OR ("NgayKetThuc" >= "NgayApDung")))
);

ALTER TABLE "public"."BangGia"
  ENABLE ROW LEVEL SECURITY;

CREATE TABLE "public"."Booking" (
  "BookingID"         integer                     NOT NULL DEFAULT nextval('public."Booking_BookingID_seq"'::regclass),
  "MaBooking"         character varying(30)       NOT NULL,
  "KhachHangID"       integer                     NOT NULL,
  "HinhThucNhanDo"    character varying(30)       NOT NULL,
  "DiaChiNhan"        character varying(255),
  "NgayHen"           date                        NOT NULL,
  "GioHen"            time without time zone      NOT NULL,
  "GhiChu"            character varying(500),
  "TrangThai"         character varying(30)       NOT NULL DEFAULT 'ChoTiepNhan'::character varying,
  "NgayTao"           timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "NgayCapNhat"       timestamp without time zone,
  "IdempotencyKey"    uuid,
  "NhanVienID"        integer,
  "NhanVienXacNhanID" integer,
  "ThoiGianXacNhan"   timestamp without time zone,
  CONSTRAINT "Booking_HinhThucNhanDo_check" CHECK ((("HinhThucNhanDo")::text = ANY ((ARRAY['Tại cửa hàng'::character varying, 'Tại nhà'::character varying])::text[]))),
  CONSTRAINT "Booking_MaBooking_key" UNIQUE ("MaBooking"),
  CONSTRAINT "Booking_pkey" PRIMARY KEY ("BookingID"),
  CONSTRAINT "booking_trangthai_check"
    CHECK
    ((("TrangThai")::text = ANY ((ARRAY['ChoTiepNhan'::character varying, 'DaXacNhan'::character varying, 'DaHuy'::character varying, 'HoanThanh'::character varying])::text[])))
);

ALTER TABLE "public"."Booking"
  ENABLE ROW LEVEL SECURITY;

REVOKE ALL ON TABLE "public"."Booking" FROM "anon";

CREATE TABLE "public"."ChiTietBooking" (
  "ChiTietBookingID" integer           GENERATED BY DEFAULT AS IDENTITY NOT NULL,
  "BookingID"        integer           NOT NULL,
  "DichVuID"         integer           NOT NULL,
  "LoaiDoGiatID"     integer           NOT NULL,
  "DonViTinhID"      integer           NOT NULL,
  "SoLuong"          numeric,
  "KhoiLuong"        numeric,
  "DonGia"           numeric           NOT NULL DEFAULT 0,
  "ThanhTien"        numeric           NOT NULL DEFAULT 0,
  "GhiChu"           character varying,
  CONSTRAINT "ChiTietBooking_DonGia_check" CHECK (("DonGia" >= (0)::numeric)),
  CONSTRAINT "ChiTietBooking_KhoiLuong_check" CHECK ((("KhoiLuong" IS NULL) OR ("KhoiLuong" > (0)::numeric))),
  CONSTRAINT "ChiTietBooking_SoLuong_check" CHECK ((("SoLuong" IS NULL) OR ("SoLuong" > (0)::numeric))),
  CONSTRAINT "ChiTietBooking_ThanhTien_check" CHECK (("ThanhTien" >= (0)::numeric)),
  CONSTRAINT "ChiTietBooking_measurement_check" CHECK (((("SoLuong" IS NOT NULL) AND ("KhoiLuong" IS NULL)) OR (("SoLuong" IS NULL) AND ("KhoiLuong" IS NOT NULL)))),
  CONSTRAINT "ChiTietBooking_pkey" PRIMARY KEY ("ChiTietBookingID")
);

ALTER TABLE "public"."ChiTietBooking"
  ENABLE ROW LEVEL SECURITY;

REVOKE ALL ON TABLE "public"."ChiTietBooking" FROM "anon";

CREATE TABLE "public"."ChiTietDonHang" (
  "ChiTietDonHangID" integer                NOT NULL DEFAULT nextval('public."ChiTietDonHang_ChiTietDonHangID_seq"'::regclass),
  "DonHangID"        integer                NOT NULL,
  "DichVuID"         integer                NOT NULL,
  "LoaiDoGiatID"     integer                NOT NULL,
  "DonViTinhID"      integer                NOT NULL,
  "SoLuong"          numeric(10,2),
  "KhoiLuong"        numeric(10,2),
  "DonGia"           numeric(18,2)          NOT NULL,
  "ThanhTien"        numeric(18,2)          NOT NULL,
  "GhiChu"           character varying(500),
  CONSTRAINT "CK_CTDH_SoLuongKhoiLuong" CHECK (((("SoLuong" IS NOT NULL) AND ("SoLuong" > (0)::numeric)) OR (("KhoiLuong" IS NOT NULL) AND ("KhoiLuong" > (0)::numeric)))),
  CONSTRAINT "ChiTietDonHang_DonGia_check" CHECK (("DonGia" >= (0)::numeric)),
  CONSTRAINT "ChiTietDonHang_ThanhTien_check" CHECK (("ThanhTien" >= (0)::numeric)),
  CONSTRAINT "ChiTietDonHang_pkey" PRIMARY KEY ("ChiTietDonHangID")
);

ALTER TABLE "public"."ChiTietDonHang"
  ENABLE ROW LEVEL SECURITY;

REVOKE ALL ON TABLE "public"."ChiTietDonHang" FROM "anon";

CREATE TABLE "public"."DanhGia" (
  "DanhGiaID"   integer                     NOT NULL DEFAULT nextval('public."DanhGia_DanhGiaID_seq"'::regclass),
  "DonHangID"   integer                     NOT NULL,
  "KhachHangID" integer                     NOT NULL,
  "SoSao"       integer                     NOT NULL,
  "BinhLuan"    character varying(1000),
  "NgayDanhGia" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "TrangThai"   character varying(30)       NOT NULL DEFAULT 'Hiển thị'::character varying,
  CONSTRAINT "DanhGia_DonHangID_key" UNIQUE ("DonHangID"),
  CONSTRAINT "DanhGia_SoSao_check" CHECK ((("SoSao" >= 1) AND ("SoSao" <= 5))),
  CONSTRAINT "DanhGia_TrangThai_check" CHECK ((("TrangThai")::text = ANY ((ARRAY['Hiển thị'::character varying, 'Ẩn'::character varying])::text[]))),
  CONSTRAINT "DanhGia_pkey" PRIMARY KEY ("DanhGiaID")
);

ALTER TABLE "public"."DanhGia"
  ENABLE ROW LEVEL SECURITY;

REVOKE ALL ON TABLE "public"."DanhGia" FROM "anon";

CREATE TABLE "public"."DichVu" (
  "DichVuID"       integer                     NOT NULL DEFAULT nextval('public."DichVu_DichVuID_seq"'::regclass),
  "LoaiDichVuID"   integer                     NOT NULL,
  "TenDichVu"      character varying(150)      NOT NULL,
  "MoTa"           character varying(500),
  "ThoiGianDuKien" integer,
  "TrangThai"      character varying(30)       NOT NULL DEFAULT 'Hoạt động'::character varying,
  "NgayTao"        timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT "DichVu_TrangThai_check" CHECK ((("TrangThai")::text = ANY ((ARRAY['Hoạt động'::character varying, 'Tạm ngưng'::character varying])::text[]))),
  CONSTRAINT "DichVu_pkey" PRIMARY KEY ("DichVuID")
);

ALTER TABLE "public"."DichVu"
  ENABLE ROW LEVEL SECURITY;

CREATE TABLE "public"."DiemTichLuy" (
  "DiemTichLuyID" integer                     NOT NULL DEFAULT nextval('public."DiemTichLuy_DiemTichLuyID_seq"'::regclass),
  "KhachHangID"   integer                     NOT NULL,
  "DiemHienTai"   integer                     NOT NULL DEFAULT 0,
  "NgayCapNhat"   timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT "DiemTichLuy_DiemHienTai_check" CHECK (("DiemHienTai" >= 0)),
  CONSTRAINT "DiemTichLuy_KhachHangID_key" UNIQUE ("KhachHangID"),
  CONSTRAINT "DiemTichLuy_pkey" PRIMARY KEY ("DiemTichLuyID")
);

ALTER TABLE "public"."DiemTichLuy"
  ENABLE ROW LEVEL SECURITY;

REVOKE ALL ON TABLE "public"."DiemTichLuy" FROM "anon";

CREATE TABLE "public"."DonHang" (
  "DonHangID"         integer                     NOT NULL DEFAULT nextval('public."DonHang_DonHangID_seq"'::regclass),
  "MaDonHang"         character varying(30)       NOT NULL,
  "BookingID"         integer,
  "KhachHangID"       integer                     NOT NULL,
  "NhanVienID"        integer,
  "TrangThai"         character varying(30)       NOT NULL DEFAULT 'Chờ tiếp nhận'::character varying,
  "TongTien"          numeric(18,2)               NOT NULL DEFAULT 0,
  "DiemSuDung"        integer                     NOT NULL DEFAULT 0,
  "TienGiamDoDiem"    numeric(18,2)               NOT NULL DEFAULT 0,
  "KhuyenMaiID"       integer,
  "TienGiamKhuyenMai" numeric(18,2)               NOT NULL DEFAULT 0,
  "PhiGiaoHang"       numeric(18,2)               NOT NULL DEFAULT 0,
  "ThanhTien"         numeric(18,2)               NOT NULL DEFAULT 0,
  "GhiChu"            character varying(500),
  "NgayTao"           timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "NgayCapNhat"       timestamp without time zone,
  "IdempotencyKey"    uuid,
  CONSTRAINT "DonHang_DiemSuDung_check" CHECK (("DiemSuDung" >= 0)),
  CONSTRAINT "DonHang_MaDonHang_key" UNIQUE ("MaDonHang"),
  CONSTRAINT "DonHang_PhiGiaoHang_check" CHECK (("PhiGiaoHang" >= (0)::numeric)),
  CONSTRAINT "DonHang_ThanhTien_check" CHECK (("ThanhTien" >= (0)::numeric)),
  CONSTRAINT "DonHang_TienGiamDoDiem_check" CHECK (("TienGiamDoDiem" >= (0)::numeric)),
  CONSTRAINT "DonHang_TienGiamKhuyenMai_check" CHECK (("TienGiamKhuyenMai" >= (0)::numeric)),
  CONSTRAINT "DonHang_TongTien_check" CHECK (("TongTien" >= (0)::numeric)),
  CONSTRAINT "DonHang_TrangThai_check"
    CHECK
    ((("TrangThai")::text = ANY ((ARRAY['Chờ tiếp nhận'::character varying, 'Đã tiếp nhận'::character varying, 'Đang giặt'::character varying, 'Hoàn thành giặt'::character varying,
    'Đang giao'::character varying, 'Đã giao'::character varying, 'Đã thanh toán'::character varying, 'Đã hủy'::character varying])::text[]))),
  CONSTRAINT "DonHang_pkey" PRIMARY KEY ("DonHangID")
);

ALTER TABLE "public"."DonHang"
  ENABLE ROW LEVEL SECURITY;

REVOKE ALL ON TABLE "public"."DonHang" FROM "anon";

CREATE TABLE "public"."DonViTinh" (
  "DonViTinhID"  integer               NOT NULL DEFAULT nextval('public."DonViTinh_DonViTinhID_seq"'::regclass),
  "TenDonViTinh" character varying(50) NOT NULL,
  "KyHieu"       character varying(20),
  "TrangThai"    character varying(30) NOT NULL DEFAULT 'Hoạt động'::character varying,
  CONSTRAINT "DonViTinh_TenDonViTinh_key" UNIQUE ("TenDonViTinh"),
  CONSTRAINT "DonViTinh_TrangThai_check" CHECK ((("TrangThai")::text = ANY ((ARRAY['Hoạt động'::character varying, 'Tạm ngưng'::character varying])::text[]))),
  CONSTRAINT "DonViTinh_pkey" PRIMARY KEY ("DonViTinhID")
);

ALTER TABLE "public"."DonViTinh"
  ENABLE ROW LEVEL SECURITY;

CREATE TABLE "public"."GiaoNhan" (
  "GiaoNhanID"     integer                     NOT NULL DEFAULT nextval('public."GiaoNhan_GiaoNhanID_seq"'::regclass),
  "DonHangID"      integer                     NOT NULL,
  "NhanVienID"     integer,
  "LoaiGiaoNhan"   character varying(30)       NOT NULL,
  "HinhThuc"       character varying(30)       NOT NULL,
  "DiaChi"         character varying(255),
  "ThoiGianDuKien" timestamp without time zone,
  "ThoiGianThucTe" timestamp without time zone,
  "PhiGiaoNhan"    numeric(18,2)               NOT NULL DEFAULT 0,
  "TrangThai"      character varying(30)       NOT NULL DEFAULT 'Chờ thực hiện'::character varying,
  "GhiChu"         character varying(500),
  CONSTRAINT "GiaoNhan_HinhThuc_check" CHECK ((("HinhThuc")::text = ANY ((ARRAY['Tại cửa hàng'::character varying, 'Tại nhà'::character varying])::text[]))),
  CONSTRAINT "GiaoNhan_LoaiGiaoNhan_check" CHECK ((("LoaiGiaoNhan")::text = ANY ((ARRAY['NHAN_DO'::character varying, 'GIAO_DO'::character varying])::text[]))),
  CONSTRAINT "GiaoNhan_PhiGiaoNhan_check" CHECK (("PhiGiaoNhan" >= (0)::numeric)),
  CONSTRAINT "GiaoNhan_TrangThai_check"
    CHECK
    ((("TrangThai")::text = ANY ((ARRAY['Chờ thực hiện'::character varying, 'Đang thực hiện'::character varying, 'Hoàn thành'::character varying, 'Đã hủy'::character
    varying])::text[]))),
  CONSTRAINT "GiaoNhan_pkey" PRIMARY KEY ("GiaoNhanID")
);

ALTER TABLE "public"."GiaoNhan"
  ENABLE ROW LEVEL SECURITY;

REVOKE ALL ON TABLE "public"."GiaoNhan" FROM "anon";

CREATE TABLE "public"."HoaDon" (
  "HoaDonID"    integer                     NOT NULL DEFAULT nextval('public."HoaDon_HoaDonID_seq"'::regclass),
  "MaHoaDon"    character varying(30)       NOT NULL,
  "DonHangID"   integer                     NOT NULL,
  "TongTien"    numeric(18,2)               NOT NULL,
  "GiamGia"     numeric(18,2)               NOT NULL DEFAULT 0,
  "PhiGiaoHang" numeric(18,2)               NOT NULL DEFAULT 0,
  "ThanhTien"   numeric(18,2)               NOT NULL,
  "NgayLap"     timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "TrangThai"   character varying(30)       NOT NULL DEFAULT 'Chưa thanh toán'::character varying,
  CONSTRAINT "HoaDon_DonHangID_key" UNIQUE ("DonHangID"),
  CONSTRAINT "HoaDon_GiamGia_check" CHECK (("GiamGia" >= (0)::numeric)),
  CONSTRAINT "HoaDon_MaHoaDon_key" UNIQUE ("MaHoaDon"),
  CONSTRAINT "HoaDon_PhiGiaoHang_check" CHECK (("PhiGiaoHang" >= (0)::numeric)),
  CONSTRAINT "HoaDon_ThanhTien_check" CHECK (("ThanhTien" >= (0)::numeric)),
  CONSTRAINT "HoaDon_TongTien_check" CHECK (("TongTien" >= (0)::numeric)),
  CONSTRAINT "HoaDon_TrangThai_check"
    CHECK ((("TrangThai")::text = ANY ((ARRAY['Chưa thanh toán'::character varying, 'Đã thanh toán'::character varying, 'Đã hủy'::character varying])::text[]))),
  CONSTRAINT "HoaDon_pkey" PRIMARY KEY ("HoaDonID")
);

ALTER TABLE "public"."HoaDon"
  ENABLE ROW LEVEL SECURITY;

REVOKE ALL ON TABLE "public"."HoaDon" FROM "anon";

CREATE TABLE "public"."KhachHang" (
  "KhachHangID" integer                     NOT NULL DEFAULT nextval('public."KhachHang_KhachHangID_seq"'::regclass),
  "HoTen"       character varying(100)      NOT NULL,
  "SoDienThoai" character varying(15),
  "Email"       character varying(150),
  "DiaChi"      character varying(255),
  "NgayTao"     timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "TrangThai"   character varying(30)       NOT NULL DEFAULT 'Hoạt động'::character varying,
  CONSTRAINT "KhachHang_SoDienThoai_key" UNIQUE ("SoDienThoai"),
  CONSTRAINT "KhachHang_TrangThai_check"
    CHECK ((("TrangThai")::text = ANY ((ARRAY['Hoạt động'::character varying, 'Khóa'::character varying, 'Ngừng hoạt động'::character varying])::text[]))),
  CONSTRAINT "KhachHang_pkey" PRIMARY KEY ("KhachHangID")
);

ALTER TABLE "public"."KhachHang"
  ENABLE ROW LEVEL SECURITY;

REVOKE ALL ON TABLE "public"."KhachHang" FROM "anon";

CREATE TABLE "public"."KhuyenMai" (
  "KhuyenMaiID"       integer                NOT NULL DEFAULT nextval('public."KhuyenMai_KhuyenMaiID_seq"'::regclass),
  "MaKhuyenMai"       character varying(50)  NOT NULL,
  "TenKhuyenMai"      character varying(150) NOT NULL,
  "LoaiKhuyenMai"     character varying(30)  NOT NULL,
  "GiaTriGiam"        numeric(18,2)          NOT NULL,
  "GiaTriDonToiThieu" numeric(18,2),
  "MucGiamToiDa"      numeric(18,2),
  "SoLuongSuDung"     integer,
  "DieuKienApDung"    character varying(500),
  "NgayBatDau"        date                   NOT NULL,
  "NgayKetThuc"       date                   NOT NULL,
  "TrangThai"         character varying(30)  NOT NULL DEFAULT 'Hoạt động'::character varying,
  CONSTRAINT "CK_KhuyenMai_Ngay" CHECK (("NgayKetThuc" >= "NgayBatDau")),
  CONSTRAINT "KhuyenMai_GiaTriGiam_check" CHECK (("GiaTriGiam" >= (0)::numeric)),
  CONSTRAINT "KhuyenMai_LoaiKhuyenMai_check" CHECK ((("LoaiKhuyenMai")::text = ANY ((ARRAY['Phần trăm'::character varying, 'Tiền mặt'::character varying])::text[]))),
  CONSTRAINT "KhuyenMai_MaKhuyenMai_key" UNIQUE ("MaKhuyenMai"),
  CONSTRAINT "KhuyenMai_TrangThai_check"
    CHECK ((("TrangThai")::text = ANY ((ARRAY['Hoạt động'::character varying, 'Tạm ngưng'::character varying, 'Hết hạn'::character varying])::text[]))),
  CONSTRAINT "KhuyenMai_pkey" PRIMARY KEY ("KhuyenMaiID")
);

ALTER TABLE "public"."KhuyenMai"
  ENABLE ROW LEVEL SECURITY;

CREATE TABLE "public"."LichSuThayDoiHoaDon" (
  "LichSuID"      integer                     NOT NULL DEFAULT nextval('public."LichSuThayDoiHoaDon_LichSuID_seq"'::regclass),
  "HoaDonID"      integer                     NOT NULL,
  "TaiKhoanID"    integer                     NOT NULL,
  "ThoiGian"      timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "TruongThayDoi" character varying(100)      NOT NULL,
  "GiaTriCu"      character varying(500),
  "GiaTriMoi"     character varying(500),
  "LyDo"          character varying(500),
  CONSTRAINT "LichSuThayDoiHoaDon_pkey" PRIMARY KEY ("LichSuID")
);

ALTER TABLE "public"."LichSuThayDoiHoaDon"
  ENABLE ROW LEVEL SECURITY;

REVOKE ALL ON TABLE "public"."LichSuThayDoiHoaDon" FROM "anon";

CREATE TABLE "public"."LoaiDichVu" (
  "LoaiDichVuID"  integer                NOT NULL DEFAULT nextval('public."LoaiDichVu_LoaiDichVuID_seq"'::regclass),
  "TenLoaiDichVu" character varying(100) NOT NULL,
  "MoTa"          character varying(255),
  "TrangThai"     character varying(30)  NOT NULL DEFAULT 'Hoạt động'::character varying,
  CONSTRAINT "LoaiDichVu_TenLoaiDichVu_key" UNIQUE ("TenLoaiDichVu"),
  CONSTRAINT "LoaiDichVu_TrangThai_check" CHECK ((("TrangThai")::text = ANY ((ARRAY['Hoạt động'::character varying, 'Tạm ngưng'::character varying])::text[]))),
  CONSTRAINT "LoaiDichVu_pkey" PRIMARY KEY ("LoaiDichVuID")
);

ALTER TABLE "public"."LoaiDichVu"
  ENABLE ROW LEVEL SECURITY;

CREATE TABLE "public"."LoaiDoGiat" (
  "LoaiDoGiatID"  integer                NOT NULL DEFAULT nextval('public."LoaiDoGiat_LoaiDoGiatID_seq"'::regclass),
  "TenLoaiDoGiat" character varying(150) NOT NULL,
  "MoTa"          character varying(255),
  "TrangThai"     character varying(30)  NOT NULL DEFAULT 'Hoạt động'::character varying,
  CONSTRAINT "LoaiDoGiat_TenLoaiDoGiat_key" UNIQUE ("TenLoaiDoGiat"),
  CONSTRAINT "LoaiDoGiat_TrangThai_check" CHECK ((("TrangThai")::text = ANY ((ARRAY['Hoạt động'::character varying, 'Tạm ngưng'::character varying])::text[]))),
  CONSTRAINT "LoaiDoGiat_pkey" PRIMARY KEY ("LoaiDoGiatID")
);

ALTER TABLE "public"."LoaiDoGiat"
  ENABLE ROW LEVEL SECURITY;

CREATE TABLE "public"."NhanVien" (
  "NhanVienID"  integer                NOT NULL DEFAULT nextval('public."NhanVien_NhanVienID_seq"'::regclass),
  "HoTen"       character varying(100) NOT NULL,
  "SoDienThoai" character varying(15)  NOT NULL,
  "Email"       character varying(150),
  "DiaChi"      character varying(255),
  "ChucDanh"    character varying(100),
  "NgayVaoLam"  date,
  "TrangThai"   character varying(30)  NOT NULL DEFAULT 'Hoạt động'::character varying,
  CONSTRAINT "NhanVien_SoDienThoai_key" UNIQUE ("SoDienThoai"),
  CONSTRAINT "NhanVien_TrangThai_check"
    CHECK ((("TrangThai")::text = ANY ((ARRAY['Hoạt động'::character varying, 'Khóa'::character varying, 'Ngừng hoạt động'::character varying])::text[]))),
  CONSTRAINT "NhanVien_pkey" PRIMARY KEY ("NhanVienID")
);

ALTER TABLE "public"."NhanVien"
  ENABLE ROW LEVEL SECURITY;

REVOKE ALL ON TABLE "public"."NhanVien" FROM "anon";

CREATE TABLE "public"."NhatKyHeThong" (
  "NhatKyID"   bigint                      GENERATED BY DEFAULT AS IDENTITY NOT NULL,
  "TaiKhoanID" integer,
  "HanhDong"   character varying           NOT NULL,
  "BangDuLieu" character varying           NOT NULL,
  "BanGhiID"   bigint,
  "DuLieuCu"   jsonb,
  "DuLieuMoi"  jsonb,
  "LyDo"       character varying,
  "ThoiGian"   timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "IPAddress"  character varying,
  "UserAgent"  character varying,
  CONSTRAINT "NhatKyHeThong_pkey" PRIMARY KEY ("NhatKyID")
);

ALTER TABLE "public"."NhatKyHeThong"
  ENABLE ROW LEVEL SECURITY;

REVOKE ALL ON TABLE "public"."NhatKyHeThong" FROM "anon";

CREATE TABLE "public"."Quyen" (
  "QuyenID"   integer                NOT NULL DEFAULT nextval('public."Quyen_QuyenID_seq"'::regclass),
  "MaQuyen"   character varying(100) NOT NULL,
  "TenQuyen"  character varying(150) NOT NULL,
  "MoTa"      character varying(255),
  "TrangThai" character varying(30)  NOT NULL DEFAULT 'Hoạt động'::character varying,
  CONSTRAINT "Quyen_MaQuyen_key" UNIQUE ("MaQuyen"),
  CONSTRAINT "Quyen_TrangThai_check" CHECK ((("TrangThai")::text = ANY ((ARRAY['Hoạt động'::character varying, 'Ngừng hoạt động'::character varying])::text[]))),
  CONSTRAINT "Quyen_pkey" PRIMARY KEY ("QuyenID")
);

ALTER TABLE "public"."Quyen"
  ENABLE ROW LEVEL SECURITY;

REVOKE ALL ON TABLE "public"."Quyen" FROM "anon";

CREATE TABLE "public"."TaiKhoan_VaiTro" (
  "TaiKhoanID" integer NOT NULL,
  "VaiTroID"   integer NOT NULL,
  CONSTRAINT "TaiKhoan_VaiTro_pkey" PRIMARY KEY ("TaiKhoanID", "VaiTroID")
);

ALTER TABLE "public"."TaiKhoan_VaiTro"
  ENABLE ROW LEVEL SECURITY;

REVOKE ALL ON TABLE "public"."TaiKhoan_VaiTro" FROM "anon";

CREATE TABLE "public"."TaiKhoan" (
  "TaiKhoanID"  integer                     NOT NULL DEFAULT nextval('public."TaiKhoan_TaiKhoanID_seq"'::regclass),
  "TenDangNhap" character varying(100)      NOT NULL,
  "MatKhau"     character varying(255),
  "Email"       character varying(150),
  "SoDienThoai" character varying(15),
  "NhanVienID"  integer,
  "KhachHangID" integer,
  "TrangThai"   character varying(30)       NOT NULL DEFAULT 'Hoạt động'::character varying,
  "NgayTao"     timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "UserAuthId"  uuid,
  CONSTRAINT "CK_TaiKhoan_DoiTuong" CHECK (((("NhanVienID" IS NOT NULL) AND ("KhachHangID" IS NULL)) OR (("NhanVienID" IS NULL) AND ("KhachHangID" IS NOT NULL)))),
  CONSTRAINT "TaiKhoan_TenDangNhap_key" UNIQUE ("TenDangNhap"),
  CONSTRAINT "TaiKhoan_TrangThai_check"
    CHECK ((("TrangThai")::text = ANY ((ARRAY['Hoạt động'::character varying, 'Khóa'::character varying, 'Ngừng hoạt động'::character varying])::text[]))),
  CONSTRAINT "TaiKhoan_pkey" PRIMARY KEY ("TaiKhoanID")
);

ALTER TABLE "public"."TaiKhoan"
  ENABLE ROW LEVEL SECURITY;

REVOKE ALL ON TABLE "public"."TaiKhoan" FROM "anon";

CREATE TABLE "public"."ThanhToan" (
  "ThanhToanID" integer                     NOT NULL DEFAULT nextval('public."ThanhToan_ThanhToanID_seq"'::regclass),
  "DonHangID"   integer                     NOT NULL,
  "SoTien"      numeric(18,2)               NOT NULL,
  "PhuongThuc"  character varying(30)       NOT NULL,
  "MaGiaoDich"  character varying(100),
  "ThoiGian"    timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "TrangThai"   character varying(30)       NOT NULL DEFAULT 'Chờ thanh toán'::character varying,
  "GhiChu"      character varying(500),
  CONSTRAINT "ThanhToan_PhuongThuc_check" CHECK ((("PhuongThuc")::text = ANY ((ARRAY['Tiền mặt'::character varying, 'Chuyển khoản'::character varying])::text[]))),
  CONSTRAINT "ThanhToan_SoTien_check" CHECK (("SoTien" > (0)::numeric)),
  CONSTRAINT "ThanhToan_TrangThai_check"
    CHECK
    ((("TrangThai")::text = ANY ((ARRAY['Chờ thanh toán'::character varying, 'Thành công'::character varying, 'Thất bại'::character varying, 'Đã hoàn tiền'::character
    varying])::text[]))),
  CONSTRAINT "ThanhToan_pkey" PRIMARY KEY ("ThanhToanID")
);

ALTER TABLE "public"."ThanhToan"
  ENABLE ROW LEVEL SECURITY;

REVOKE ALL ON TABLE "public"."ThanhToan" FROM "anon";

CREATE TABLE "public"."ThongBao" (
  "ThongBaoID"   integer                     NOT NULL DEFAULT nextval('public."ThongBao_ThongBaoID_seq"'::regclass),
  "TaiKhoanID"   integer                     NOT NULL,
  "DonHangID"    integer,
  "LoaiThongBao" character varying(50),
  "TieuDe"       character varying(200)      NOT NULL,
  "NoiDung"      character varying(1000)     NOT NULL,
  "ThoiGianGui"  timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "DaDoc"        boolean                     NOT NULL DEFAULT false,
  CONSTRAINT "ThongBao_pkey" PRIMARY KEY ("ThongBaoID")
);

ALTER TABLE "public"."ThongBao"
  ENABLE ROW LEVEL SECURITY;

REVOKE ALL ON TABLE "public"."ThongBao" FROM "anon";

CREATE TABLE "public"."TinNhan" (
  "TinNhanID"   integer                     NOT NULL DEFAULT nextval('public."TinNhan_TinNhanID_seq"'::regclass),
  "NguoiGuiID"  integer                     NOT NULL,
  "NguoiNhanID" integer                     NOT NULL,
  "DonHangID"   integer,
  "NoiDung"     character varying(1000)     NOT NULL,
  "ThoiGianGui" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "TrangThai"   character varying(30)       NOT NULL DEFAULT 'Đã gửi'::character varying,
  CONSTRAINT "TinNhan_TrangThai_check"
    CHECK ((("TrangThai")::text = ANY ((ARRAY['Đã gửi'::character varying, 'Đã nhận'::character varying, 'Đã đọc'::character varying])::text[]))),
  CONSTRAINT "TinNhan_pkey" PRIMARY KEY ("TinNhanID")
);

ALTER TABLE "public"."TinNhan"
  ENABLE ROW LEVEL SECURITY;

REVOKE ALL ON TABLE "public"."TinNhan" FROM "anon";

CREATE TABLE "public"."VaiTro_Quyen" (
  "VaiTroID" integer NOT NULL,
  "QuyenID"  integer NOT NULL,
  CONSTRAINT "VaiTro_Quyen_pkey" PRIMARY KEY ("VaiTroID", "QuyenID")
);

ALTER TABLE "public"."VaiTro_Quyen"
  ENABLE ROW LEVEL SECURITY;

REVOKE ALL ON TABLE "public"."VaiTro_Quyen" FROM "anon";

CREATE TABLE "public"."VaiTro" (
  "VaiTroID"  integer                NOT NULL DEFAULT nextval('public."VaiTro_VaiTroID_seq"'::regclass),
  "TenVaiTro" character varying(100) NOT NULL,
  "MoTa"      character varying(255),
  "TrangThai" character varying(30)  NOT NULL DEFAULT 'Hoạt động'::character varying,
  CONSTRAINT "VaiTro_TenVaiTro_key" UNIQUE ("TenVaiTro"),
  CONSTRAINT "VaiTro_TrangThai_check" CHECK ((("TrangThai")::text = ANY ((ARRAY['Hoạt động'::character varying, 'Ngừng hoạt động'::character varying])::text[]))),
  CONSTRAINT "VaiTro_pkey" PRIMARY KEY ("VaiTroID")
);

ALTER TABLE "public"."VaiTro"
  ENABLE ROW LEVEL SECURITY;

REVOKE ALL ON TABLE "public"."VaiTro" FROM "anon";

CREATE TABLE "public"."sessions" (
  "id"            character varying(255) NOT NULL,
  "user_id"       bigint,
  "ip_address"    character varying(45),
  "user_agent"    text,
  "payload"       text                   NOT NULL,
  "last_activity" integer                NOT NULL,
  CONSTRAINT "sessions_pkey" PRIMARY KEY (id)
);

REVOKE ALL ON TABLE "public"."sessions" FROM "anon", "authenticated";

ALTER SEQUENCE "public"."BangGia_BangGiaID_seq" OWNED BY "public"."BangGia"."BangGiaID";

ALTER SEQUENCE "public"."Booking_BookingID_seq" OWNED BY "public"."Booking"."BookingID";

ALTER SEQUENCE "public"."ChiTietDonHang_ChiTietDonHangID_seq" OWNED BY "public"."ChiTietDonHang"."ChiTietDonHangID";

ALTER SEQUENCE "public"."DanhGia_DanhGiaID_seq" OWNED BY "public"."DanhGia"."DanhGiaID";

ALTER SEQUENCE "public"."DichVu_DichVuID_seq" OWNED BY "public"."DichVu"."DichVuID";

ALTER SEQUENCE "public"."DiemTichLuy_DiemTichLuyID_seq" OWNED BY "public"."DiemTichLuy"."DiemTichLuyID";

ALTER SEQUENCE "public"."DonHang_DonHangID_seq" OWNED BY "public"."DonHang"."DonHangID";

ALTER SEQUENCE "public"."DonViTinh_DonViTinhID_seq" OWNED BY "public"."DonViTinh"."DonViTinhID";

ALTER SEQUENCE "public"."GiaoNhan_GiaoNhanID_seq" OWNED BY "public"."GiaoNhan"."GiaoNhanID";

ALTER SEQUENCE "public"."HoaDon_HoaDonID_seq" OWNED BY "public"."HoaDon"."HoaDonID";

ALTER SEQUENCE "public"."KhachHang_KhachHangID_seq" OWNED BY "public"."KhachHang"."KhachHangID";

ALTER SEQUENCE "public"."KhuyenMai_KhuyenMaiID_seq" OWNED BY "public"."KhuyenMai"."KhuyenMaiID";

ALTER SEQUENCE "public"."LichSuThayDoiHoaDon_LichSuID_seq" OWNED BY "public"."LichSuThayDoiHoaDon"."LichSuID";

ALTER SEQUENCE "public"."LoaiDichVu_LoaiDichVuID_seq" OWNED BY "public"."LoaiDichVu"."LoaiDichVuID";

ALTER SEQUENCE "public"."LoaiDoGiat_LoaiDoGiatID_seq" OWNED BY "public"."LoaiDoGiat"."LoaiDoGiatID";

ALTER SEQUENCE "public"."NhanVien_NhanVienID_seq" OWNED BY "public"."NhanVien"."NhanVienID";

ALTER SEQUENCE "public"."Quyen_QuyenID_seq" OWNED BY "public"."Quyen"."QuyenID";

ALTER SEQUENCE "public"."TaiKhoan_TaiKhoanID_seq" OWNED BY "public"."TaiKhoan"."TaiKhoanID";

ALTER SEQUENCE "public"."ThanhToan_ThanhToanID_seq" OWNED BY "public"."ThanhToan"."ThanhToanID";

ALTER SEQUENCE "public"."ThongBao_ThongBaoID_seq" OWNED BY "public"."ThongBao"."ThongBaoID";

ALTER SEQUENCE "public"."TinNhan_TinNhanID_seq" OWNED BY "public"."TinNhan"."TinNhanID";

ALTER SEQUENCE "public"."VaiTro_VaiTroID_seq" OWNED BY "public"."VaiTro"."VaiTroID";

CREATE OR REPLACE FUNCTION private.can_access_order (
  order_id bigint
)
  RETURNS boolean
  LANGUAGE sql
  STABLE
  SECURITY DEFINER
  SET search_path TO ''
  AS $function$
			SELECT (SELECT auth.uid()) IS NOT NULL AND EXISTS (
				SELECT 1 FROM public.donhang AS order_record
				WHERE order_record.donhangid = order_id
					AND (order_record.khachhangid = (SELECT private.current_customer_id())
						OR (SELECT private.is_staff()))
			);
		$function$;

CREATE OR REPLACE FUNCTION private.current_account_id()
  RETURNS bigint
  LANGUAGE sql
  STABLE
  SECURITY DEFINER
  SET search_path TO ''
  AS $function$
			SELECT account.taikhoanid FROM public.taikhoan AS account
			WHERE account.userauthid = (SELECT auth.uid())
				AND account.trangthai = 'Hoạt động';
		$function$;

CREATE OR REPLACE FUNCTION private.current_customer_id()
  RETURNS bigint
  LANGUAGE sql
  STABLE
  SECURITY DEFINER
  SET search_path TO ''
  AS $function$
			SELECT account.khachhangid FROM public.taikhoan AS account
			JOIN public.khachhang AS customer
				ON customer.khachhangid = account.khachhangid
			WHERE account.userauthid = (SELECT auth.uid())
				AND account.trangthai = 'Hoạt động'
				AND customer.trangthai = 'Hoạt động';
		$function$;

CREATE OR REPLACE FUNCTION private.current_employee_id()
  RETURNS bigint
  LANGUAGE sql
  STABLE
  SECURITY DEFINER
  SET search_path TO ''
  AS $function$
			SELECT account.nhanvienid FROM public.taikhoan AS account
			JOIN public.nhanvien AS employee
				ON employee.nhanvienid = account.nhanvienid
			WHERE account.userauthid = (SELECT auth.uid())
				AND account.trangthai = 'Hoạt động'
				AND employee.trangthai = 'Hoạt động';
		$function$;

CREATE OR REPLACE FUNCTION private.has_role (
  role_name text
)
  RETURNS boolean
  LANGUAGE sql
  STABLE
  SECURITY DEFINER
  SET search_path TO ''
  AS $function$
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
		$function$;

CREATE OR REPLACE FUNCTION private.is_staff()
  RETURNS boolean
  LANGUAGE sql
  STABLE
  SECURITY DEFINER
  SET search_path TO ''
  AS $function$
			SELECT (SELECT private.has_role('Nhân viên'))
				OR (SELECT private.has_role('Quản lý'))
				OR (SELECT private.has_role('Chủ cửa hàng'));
		$function$;

CREATE OR REPLACE FUNCTION private.normalize_phone (
  phone_number text
)
  RETURNS text
  LANGUAGE sql
  IMMUTABLE
  SET search_path TO ''
  AS $function$
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
		$function$;

CREATE OR REPLACE FUNCTION private.record_legacy_order_status_change()
  RETURNS TRIGGER
  LANGUAGE plpgsql
  SECURITY DEFINER
  SET search_path TO ''
  AS $function$
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
		$function$;

CREATE OR REPLACE FUNCTION public.cancel_laundry_booking (
  p_bookingid bigint
)
  RETURNS void
  LANGUAGE plpgsql
  SECURITY DEFINER
  SET search_path TO ''
  AS $function$
DECLARE
    customer_id bigint :=
        (SELECT private.current_customer_id());

    booking_row public."Booking"%ROWTYPE;
BEGIN

    -- Kiểm tra khách hàng đăng nhập
    IF (SELECT auth.uid()) IS NULL
       OR customer_id IS NULL THEN

        RAISE EXCEPTION
            'An active customer account is required';

    END IF;


    -- Khóa Booking để tránh cập nhật đồng thời
    SELECT *
    INTO booking_row
    FROM public."Booking"
    WHERE "BookingID" = p_bookingid
      AND "KhachHangID" = customer_id
    FOR UPDATE;


    IF NOT FOUND THEN

        RAISE EXCEPTION
            'Booking not found';

    END IF;


    -- Chỉ Booking đang chờ tiếp nhận mới được hủy
    IF booking_row."TrangThai" <> 'ChoTiepNhan'
       OR EXISTS (
            SELECT 1
            FROM public."DonHang"
            WHERE "BookingID" = p_bookingid
       ) THEN

        RAISE EXCEPTION
            'Only pending bookings can be canceled';

    END IF;


    UPDATE public."Booking"
    SET
        "TrangThai" = 'DaHuy',
        "NgayCapNhat" = now()
    WHERE "BookingID" = p_bookingid;

END;
$function$;

CREATE OR REPLACE FUNCTION public.confirm_laundry_booking (
  p_bookingid bigint
)
  RETURNS jsonb
  LANGUAGE plpgsql
  SECURITY DEFINER
  SET search_path TO ''
  AS $function$

DECLARE

    booking_row public."Booking"%ROWTYPE;

    order_id bigint;
    order_number text;

    current_employee bigint :=
        (SELECT private.current_employee_id());

    pickup_at timestamp with time zone;

    total_amount numeric(18,2);

    detail_count integer;

BEGIN

    -- =====================================================
    -- 1. Kiểm tra quyền nhân viên
    -- =====================================================

    IF (SELECT auth.uid()) IS NULL
       OR NOT (SELECT private.is_staff())
       OR (
           current_employee IS NULL
           AND NOT (SELECT private.has_role('Quản lý'))
           AND NOT (SELECT private.has_role('Chủ cửa hàng'))
       ) THEN

        RAISE EXCEPTION
            'An active staff account is required';

    END IF;


    -- =====================================================
    -- 2. Khóa Booking
    -- =====================================================

    SELECT *
    INTO booking_row
    FROM public."Booking"
    WHERE "BookingID" = p_bookingid
    FOR UPDATE;


    IF NOT FOUND THEN

        RAISE EXCEPTION
            'Booking not found';

    END IF;


    -- =====================================================
    -- 3. Idempotent:
    -- Nếu Booking đã xác nhận và đã có Order
    -- thì trả Order cũ
    -- =====================================================

    IF booking_row."TrangThai" = 'DaXacNhan' THEN

        SELECT "DonHangID"
        INTO order_id
        FROM public."DonHang"
        WHERE "BookingID" = p_bookingid;


        IF order_id IS NOT NULL THEN

            RETURN jsonb_build_object(
                'donhangid',
                order_id,

                'bookingid',
                p_bookingid
            );

        END IF;

    END IF;


    -- =====================================================
    -- 4. Chỉ Booking đang chờ tiếp nhận
    -- mới được xác nhận
    -- =====================================================

    IF booking_row."TrangThai" <> 'ChoTiepNhan' THEN

        RAISE EXCEPTION
            'Only pending bookings can be confirmed';

    END IF;


    -- =====================================================
    -- 5. Booking phải có ít nhất 1 ChiTietBooking
    -- =====================================================

    SELECT
        COUNT(*),
        COALESCE(
            SUM("ThanhTien"),
            0
        )

    INTO
        detail_count,
        total_amount

    FROM public."ChiTietBooking"

    WHERE "BookingID" = p_bookingid;


    IF detail_count = 0 THEN

        RAISE EXCEPTION
            'Booking must contain at least one detail';

    END IF;


    -- =====================================================
    -- 6. Sinh mã đơn hàng
    -- =====================================================

    order_number :=
        'DH-' ||
        to_char(
            clock_timestamp(),
            'YYYYMMDDHH24MISS'
        ) ||
        '-' ||
        substr(
            replace(
                gen_random_uuid()::text,
                '-',
                ''
            ),
            1,
            8
        );


    -- =====================================================
    -- 7. Tạo DonHang chính thức
    -- =====================================================

    INSERT INTO public."DonHang" (
        "MaDonHang",
        "BookingID",
        "KhachHangID",
        "NhanVienID",
        "TrangThai",
        "TongTien",
        "PhiGiaoHang",
        "ThanhTien",
        "GhiChu"
    )

    VALUES (
        order_number,
        p_bookingid,
        booking_row."KhachHangID",
        current_employee,
        'Đã tiếp nhận',
        total_amount,
        0,
        total_amount,
        booking_row."GhiChu"
    )

    RETURNING "DonHangID"
    INTO order_id;


    -- =====================================================
    -- 8. Copy tất cả ChiTietBooking
    -- -> ChiTietDonHang
    -- =====================================================

    INSERT INTO public."ChiTietDonHang" (
        "DonHangID",
        "DichVuID",
        "LoaiDoGiatID",
        "DonViTinhID",
        "SoLuong",
        "KhoiLuong",
        "DonGia",
        "ThanhTien",
        "GhiChu"
    )

    SELECT
        order_id,
        cb."DichVuID",
        cb."LoaiDoGiatID",
        cb."DonViTinhID",
        cb."SoLuong",
        cb."KhoiLuong",
        cb."DonGia",
        cb."ThanhTien",
        cb."GhiChu"

    FROM public."ChiTietBooking" AS cb

    WHERE cb."BookingID" = p_bookingid

    ORDER BY cb."ChiTietBookingID";


    -- =====================================================
    -- 9. Nếu nhận đồ tại nhà
    -- -> tạo GiaoNhan NHAN_DO
    -- =====================================================

    IF booking_row."HinhThucNhanDo" = 'Tại nhà' THEN

        pickup_at :=
            (
                booking_row."NgayHen" +
                booking_row."GioHen"
            )
            AT TIME ZONE 'Asia/Ho_Chi_Minh';


        INSERT INTO public."GiaoNhan" (
            "DonHangID",
            "LoaiGiaoNhan",
            "HinhThuc",
            "DiaChi",
            "ThoiGianDuKien",
            "TrangThai"
        )

        VALUES (
            order_id,
            'NHAN_DO',
            'Tại nhà',
            booking_row."DiaChiNhan",
            pickup_at,
            'Chờ thực hiện'
        );

    END IF;


    -- =====================================================
    -- 10. Cập nhật Booking
    -- =====================================================

    UPDATE public."Booking"

    SET
        "TrangThai" = 'DaXacNhan',

        "NhanVienXacNhanID" = current_employee,

        "ThoiGianXacNhan" = now(),

        "NgayCapNhat" = now()

    WHERE "BookingID" = p_bookingid;


    -- =====================================================
    -- 11. Trả kết quả
    -- =====================================================

    RETURN jsonb_build_object(

        'donhangid',
        order_id,

        'madonhang',
        order_number,

        'bookingid',
        p_bookingid,

        'trangthai',
        'Đã tiếp nhận',

        'tongtien',
        total_amount,

        'sochitiet',
        detail_count

    );

END;
$function$;

CREATE OR REPLACE FUNCTION public.confirm_order_payment (
  p_thanhtoanid bigint,
  p_success     boolean,
  p_ghichu      text    DEFAULT NULL::text
)
  RETURNS void
  LANGUAGE plpgsql
  SECURITY DEFINER
  SET search_path TO ''
  AS $function$
DECLARE

    current_employee bigint :=
        (SELECT private.current_employee_id());

    payment public."ThanhToan"%ROWTYPE;

    order_record public."DonHang"%ROWTYPE;

    invoice public."HoaDon"%ROWTYPE;

    paid_total numeric(18,2);

BEGIN

    -- =====================================================
    -- 1. Kiểm tra quyền nhân viên
    -- =====================================================

    IF (SELECT auth.uid()) IS NULL
       OR NOT (SELECT private.is_staff())
       OR (
           current_employee IS NULL
           AND NOT (SELECT private.has_role('Quản lý'))
           AND NOT (SELECT private.has_role('Chủ cửa hàng'))
       ) THEN

        RAISE EXCEPTION
            'An active staff account is required';

    END IF;


    -- =====================================================
    -- 2. Lấy và khóa Payment
    -- =====================================================

    SELECT *
    INTO payment

    FROM public."ThanhToan"

    WHERE "ThanhToanID" = p_thanhtoanid

    FOR UPDATE;


    IF NOT FOUND
       OR payment."TrangThai" <> 'Chờ thanh toán' THEN

        RAISE EXCEPTION
            'Pending payment not found';

    END IF;


    -- =====================================================
    -- 3. Lấy và khóa Order
    -- =====================================================

    SELECT *
    INTO order_record

    FROM public."DonHang"

    WHERE "DonHangID" = payment."DonHangID"

    FOR UPDATE;


    IF NOT FOUND THEN

        RAISE EXCEPTION
            'Order not found';

    END IF;


    -- =====================================================
    -- 4. Lấy và khóa Invoice
    -- =====================================================

    SELECT *
    INTO invoice

    FROM public."HoaDon"

    WHERE "DonHangID" = payment."DonHangID"

    FOR UPDATE;


    IF NOT FOUND THEN

        RAISE EXCEPTION
            'Invoice not found';

    END IF;


    -- =====================================================
    -- 5. Thanh toán thành công
    -- =====================================================

    IF p_success THEN

        UPDATE public."ThanhToan"

        SET
            "TrangThai" = 'Thành công',

            "GhiChu" =
                left(
                    coalesce(
                        nullif(
                            btrim(p_ghichu),
                            ''
                        ),
                        "GhiChu"
                    ),
                    500
                )

        WHERE "ThanhToanID" = p_thanhtoanid;


        -- Tổng tiền đã thanh toán thành công
        SELECT
            coalesce(
                sum("SoTien"),
                0
            )

        INTO paid_total

        FROM public."ThanhToan"

        WHERE "DonHangID" = payment."DonHangID"

          AND "TrangThai" = 'Thành công';


        -- Nếu đã thanh toán đủ
        IF paid_total >= invoice."ThanhTien" THEN

            UPDATE public."HoaDon"

            SET
                "TrangThai" = 'Đã thanh toán'

            WHERE "HoaDonID" = invoice."HoaDonID";


            -- Chỉ chuyển Order sang Đã thanh toán
            -- nếu hiện tại đang Đã giao
            UPDATE public."DonHang"

            SET
                "TrangThai" = 'Đã thanh toán',

                "NgayCapNhat" = now()

            WHERE "DonHangID" = order_record."DonHangID"

              AND "TrangThai" = 'Đã giao';

        END IF;


    -- =====================================================
    -- 6. Thanh toán thất bại
    -- =====================================================

    ELSE

        UPDATE public."ThanhToan"

        SET
            "TrangThai" = 'Thất bại',

            "GhiChu" =
                left(
                    coalesce(
                        nullif(
                            btrim(p_ghichu),
                            ''
                        ),
                        "GhiChu"
                    ),
                    500
                )

        WHERE "ThanhToanID" = p_thanhtoanid;

    END IF;

END;
$function$;

CREATE OR REPLACE FUNCTION public.get_customer_loyalty()
  RETURNS jsonb
  LANGUAGE plpgsql
  SECURITY DEFINER
  SET search_path TO ''
  AS $function$
DECLARE
  customer_id bigint := (SELECT private.current_customer_id());
  current_points integer;
  active_vouchers jsonb;
BEGIN
  IF customer_id IS NULL THEN
    RAISE EXCEPTION 'An active customer account is required';
  END IF;

  SELECT coalesce(points."DiemHienTai", 0)
  INTO current_points
  FROM public."DiemTichLuy" AS points
  WHERE points."KhachHangID" = customer_id;

  SELECT coalesce(
    jsonb_agg(
      jsonb_build_object(
        'khuyenmaiid', promotion."KhuyenMaiID",
        'makhuyenmai', promotion."MaKhuyenMai",
        'tenkhuyenmai', promotion."TenKhuyenMai",
        'loaikhuyenmai', promotion."LoaiKhuyenMai",
        'giatrigiam', promotion."GiaTriGiam",
        'giatridontoithieu', promotion."GiaTriDonToiThieu",
        'mucgiamtoida', promotion."MucGiamToiDa",
        'dieukienapdung', promotion."DieuKienApDung"
      )
      ORDER BY promotion."NgayKetThuc"
    ),
    '[]'::jsonb
  )
  INTO active_vouchers
  FROM public."KhuyenMai" AS promotion
  WHERE promotion."TrangThai" = 'Hoạt động'
    AND promotion."NgayBatDau" <= current_date
    AND promotion."NgayKetThuc" >= current_date
    AND (
      promotion."SoLuongSuDung" IS NULL
      OR promotion."SoLuongSuDung" > 0
    );

  RETURN jsonb_build_object(
    'points', coalesce(current_points, 0),
    'vouchers', active_vouchers
  );
END;
$function$;

CREATE OR REPLACE FUNCTION public.request_order_payment (
  p_donhangid       bigint,
  p_phuongthuc      text,
  p_idempotency_key uuid
)
  RETURNS jsonb
  LANGUAGE plpgsql
  SECURITY DEFINER
  SET search_path TO ''
  AS $function$
DECLARE

    customer_id bigint :=
        (SELECT private.current_customer_id());

    order_record public."DonHang"%ROWTYPE;

    invoice public."HoaDon"%ROWTYPE;

    existing_payment public."ThanhToan"%ROWTYPE;

    amount_due numeric(18,2);

    payment_id bigint;

BEGIN

    -- =====================================================
    -- 1. Kiểm tra khách hàng
    -- =====================================================

    IF (SELECT auth.uid()) IS NULL
       OR customer_id IS NULL THEN

        RAISE EXCEPTION
            'An active customer account is required';

    END IF;


    -- =====================================================
    -- 2. Kiểm tra phương thức thanh toán
    -- =====================================================

    IF p_phuongthuc NOT IN (
        'Tiền mặt',
        'Chuyển khoản'
    ) THEN

        RAISE EXCEPTION
            'Unsupported payment method';

    END IF;


    -- =====================================================
    -- 3. Kiểm tra Idempotency
    -- =====================================================

    IF p_idempotency_key IS NULL THEN

        RAISE EXCEPTION
            'An idempotency key is required';

    END IF;


    PERFORM pg_catalog.pg_advisory_xact_lock(
        pg_catalog.hashtextextended(
            p_idempotency_key::text,
            0
        )
    );


    -- =====================================================
    -- 4. Kiểm tra Payment đã tạo trước đó
    -- =====================================================

    SELECT *
    INTO existing_payment

    FROM public."ThanhToan"

    WHERE "IdempotencyKey" =
          p_idempotency_key;


    IF FOUND THEN

        IF NOT EXISTS (

            SELECT 1

            FROM public."DonHang" AS order_row

            WHERE order_row."DonHangID" =
                  existing_payment."DonHangID"

              AND order_row."KhachHangID" =
                  customer_id

        ) THEN

            RAISE EXCEPTION
                'Idempotency key is already in use';

        END IF;


        RETURN jsonb_build_object(

            'thanhtoanid',
            existing_payment."ThanhToanID",

            'sotien',
            existing_payment."SoTien",

            'trangthai',
            existing_payment."TrangThai",

            'phuongthuc',
            existing_payment."PhuongThuc"

        );

    END IF;


    -- =====================================================
    -- 5. Lấy và khóa Order
    -- =====================================================

    SELECT *
    INTO order_record

    FROM public."DonHang"

    WHERE "DonHangID" = p_donhangid

      AND "KhachHangID" = customer_id

    FOR UPDATE;


    IF NOT FOUND THEN

        RAISE EXCEPTION
            'Order not found';

    END IF;


    -- Chỉ thanh toán sau khi giao
    IF order_record."TrangThai" NOT IN (
        'Đã giao',
        'Đã thanh toán'
    ) THEN

        RAISE EXCEPTION
            'Payment is available after the order is delivered';

    END IF;


    -- =====================================================
    -- 6. Lấy Invoice
    -- =====================================================

    SELECT *
    INTO invoice

    FROM public."HoaDon"

    WHERE "DonHangID" = p_donhangid

    FOR UPDATE;


    IF NOT FOUND
       OR invoice."TrangThai" <> 'Chưa thanh toán' THEN

        RAISE EXCEPTION
            'No unpaid invoice is available';

    END IF;


    -- =====================================================
    -- 7. Tính số tiền còn phải trả
    -- =====================================================

    SELECT
        greatest(
            invoice."ThanhTien"
            -
            coalesce(
                sum(payment."SoTien")
                FILTER (
                    WHERE payment."TrangThai" =
                          'Thành công'
                ),
                0
            ),
            0
        )

    INTO amount_due

    FROM public."ThanhToan" AS payment

    WHERE payment."DonHangID" =
          p_donhangid;


    IF amount_due <= 0 THEN

        RAISE EXCEPTION
            'The invoice has no remaining balance';

    END IF;


    -- =====================================================
    -- 8. Tạo Payment
    -- =====================================================

    INSERT INTO public."ThanhToan" (

        "DonHangID",
        "PhuongThuc",
        "SoTien",
        "TrangThai",
        "IdempotencyKey",
        "GhiChu"

    )

    VALUES (

        p_donhangid,

        p_phuongthuc,

        amount_due,

        'Chờ thanh toán',

        p_idempotency_key,

        CASE
            WHEN p_phuongthuc = 'Chuyển khoản'
            THEN
                'Khách chọn chuyển khoản; chờ cửa hàng đối soát.'

            ELSE
                'Khách chọn tiền mặt; chờ cửa hàng thu tiền.'
        END

    )

    RETURNING "ThanhToanID"
    INTO payment_id;


    -- =====================================================
    -- 9. Trả kết quả
    -- =====================================================

    RETURN jsonb_build_object(

        'thanhtoanid',
        payment_id,

        'sotien',
        amount_due,

        'trangthai',
        'Chờ thanh toán',

        'phuongthuc',
        p_phuongthuc

    );

END;
$function$;

CREATE OR REPLACE FUNCTION public.submit_laundry_order (
  p_banggiaid       bigint,
  p_measurement     numeric,
  p_hinhthucnhando  text,
  p_diachinhan      text,
  p_ngayhen         date,
  p_giohen          time without time zone,
  p_ghichu          text,
  p_idempotency_key uuid
)
  RETURNS jsonb
  LANGUAGE plpgsql
  SECURITY DEFINER
  SET search_path TO ''
  AS $function$

DECLARE

    customer_id bigint :=
        (SELECT private.current_customer_id());

    existing_booking public."Booking"%ROWTYPE;

    price_row record;

    measurement numeric(10,2);
    line_total numeric(18,2);

    booking_id bigint;
    booking_number text;

    quantity numeric(10,2);
    weight_kg numeric(10,2);

    detail_id bigint;

BEGIN

    -- =====================================================
    -- 1. Kiểm tra khách hàng đăng nhập
    -- =====================================================

    IF (SELECT auth.uid()) IS NULL
       OR customer_id IS NULL THEN

        RAISE EXCEPTION
            'An active customer account is required';

    END IF;


    IF p_idempotency_key IS NULL THEN

        RAISE EXCEPTION
            'An idempotency key is required';

    END IF;


    -- =====================================================
    -- 2. Khóa theo idempotency key
    -- =====================================================

    PERFORM pg_catalog.pg_advisory_xact_lock(
        pg_catalog.hashtextextended(
            p_idempotency_key::text,
            0
        )
    );


    -- =====================================================
    -- 3. Kiểm tra Booking đã tạo trước đó
    -- =====================================================

    SELECT *
    INTO existing_booking

    FROM public."Booking" AS booking

    WHERE booking."IdempotencyKey" =
          p_idempotency_key;


    IF FOUND THEN

        IF existing_booking."KhachHangID" <> customer_id THEN

            RAISE EXCEPTION
                'Idempotency key is already in use';

        END IF;


        RETURN jsonb_build_object(

            'bookingid',
            existing_booking."BookingID",

            'mabooking',
            existing_booking."MaBooking",

            'trangthai',
            existing_booking."TrangThai",

            'thanhtien',
            COALESCE(
                (
                    SELECT SUM(cb."ThanhTien")

                    FROM public."ChiTietBooking" AS cb

                    WHERE cb."BookingID" =
                          existing_booking."BookingID"
                ),
                0
            )

        );

    END IF;


    -- =====================================================
    -- 4. Validate số lượng / khối lượng
    -- =====================================================

    IF p_measurement IS NULL
       OR p_measurement <= 0
       OR p_measurement > 99999999.99
       OR p_measurement <> round(p_measurement, 2) THEN

        RAISE EXCEPTION
            'Measurement must be positive and have at most two decimals';

    END IF;


    -- =====================================================
    -- 5. Validate hình thức nhận đồ
    -- =====================================================

    IF p_hinhthucnhando NOT IN (
        'Tại cửa hàng',
        'Tại nhà'
    ) THEN

        RAISE EXCEPTION
            'Unsupported pickup method';

    END IF;


    -- =====================================================
    -- 6. Validate lịch hẹn
    -- =====================================================

    IF p_ngayhen IS NULL
       OR p_ngayhen < current_date
       OR p_ngayhen > current_date + 30
       OR p_giohen IS NULL THEN

        RAISE EXCEPTION
            'Pickup appointment must be within the next 30 days';

    END IF;


    -- =====================================================
    -- 7. Nếu nhận tại nhà thì bắt buộc có địa chỉ
    -- =====================================================

    IF p_hinhthucnhando = 'Tại nhà'
       AND nullif(
            btrim(p_diachinhan),
            ''
       ) IS NULL THEN

        RAISE EXCEPTION
            'A pickup address is required';

    END IF;


    -- =====================================================
    -- 8. Lấy bảng giá đang hoạt động
    -- =====================================================

    SELECT
        price."DichVuID",
        price."LoaiDoGiatID",
        price."DonViTinhID",
        price."DonGia",
        unit."Ten",
        unit."KyHieu"

    INTO price_row

    FROM public."BangGia" AS price

    JOIN public."DichVu" AS service
        ON service."DichVuID" =
           price."DichVuID"

    JOIN public."LoaiDoGiat" AS item_type
        ON item_type."LoaiDoGiatID" =
           price."LoaiDoGiatID"

    JOIN public."DonViTinh" AS unit
        ON unit."DonViTinhID" =
           price."DonViTinhID"

    WHERE price."BangGiaID" =
          p_banggiaid

      AND price."TrangThai" = 'Hoạt động'

      AND price."NgayApDung" <= current_date

      AND (
          price."NgayKetThuc" IS NULL
          OR price."NgayKetThuc" >= current_date
      )

      AND service."TrangThai" = 'Hoạt động'

      AND item_type."TrangThai" = 'Hoạt động'

      AND unit."TrangThai" = 'Hoạt động'

    FOR SHARE OF price;


    IF NOT FOUND THEN

        RAISE EXCEPTION
            'The selected price is no longer available';

    END IF;


    -- =====================================================
    -- 9. Tính số lượng / khối lượng
    -- =====================================================

    measurement :=
        p_measurement::numeric(10,2);


    line_total :=
        round(
            price_row."DonGia" * measurement,
            2
        );


    IF lower(
        coalesce(
            price_row."KyHieu",
            price_row."Ten"
        )
    ) IN ('kg', 'kilogram') THEN

        weight_kg := measurement;
        quantity := NULL;

    ELSE

        quantity := measurement;
        weight_kg := NULL;

    END IF;


    -- =====================================================
    -- 10. Sinh mã Booking
    -- =====================================================

    booking_number :=
        'BK-' ||
        to_char(
            clock_timestamp(),
            'YYYYMMDDHH24MISS'
        ) ||
        '-' ||
        substr(
            replace(
                gen_random_uuid()::text,
                '-',
                ''
            ),
            1,
            8
        );


    -- =====================================================
    -- 11. Tạo Booking
    -- =====================================================

    INSERT INTO public."Booking" (

        "MaBooking",
        "KhachHangID",
        "HinhThucNhanDo",
        "DiaChiNhan",
        "NgayHen",
        "GioHen",
        "GhiChu",
        "TrangThai",
        "IdempotencyKey"

    )

    VALUES (

        booking_number,
        customer_id,
        p_hinhthucnhando,

        nullif(
            btrim(p_diachinhan),
            ''
        ),

        p_ngayhen,
        p_giohen,

        nullif(
            btrim(p_ghichu),
            ''
        ),

        'ChoTiepNhan',
        p_idempotency_key

    )

    RETURNING "BookingID"
    INTO booking_id;


    -- =====================================================
    -- 12. Tạo ChiTietBooking
    -- =====================================================

    INSERT INTO public."ChiTietBooking" (

        "BookingID",
        "DichVuID",
        "LoaiDoGiatID",
        "DonViTinhID",
        "SoLuong",
        "KhoiLuong",
        "DonGia",
        "ThanhTien",
        "GhiChu"

    )

    VALUES (

        booking_id,

        price_row."DichVuID",

        price_row."LoaiDoGiatID",

        price_row."DonViTinhID",

        quantity,

        weight_kg,

        price_row."DonGia",

        line_total,

        nullif(
            btrim(p_ghichu),
            ''
        )

    )

    RETURNING "ChiTietBookingID"
    INTO detail_id;


    -- =====================================================
    -- 13. Trả kết quả
    -- =====================================================

    RETURN jsonb_build_object(

        'bookingid',
        booking_id,

        'mabooking',
        booking_number,

        'chitietbookingid',
        detail_id,

        'trangthai',
        'ChoTiepNhan',

        'thanhtien',
        line_total

    );

END;
$function$;

CREATE OR REPLACE FUNCTION public.transition_laundry_order (
  p_donhangid    bigint,
  p_trangthaimoi text,
  p_lydo         text   DEFAULT NULL::text
)
  RETURNS void
  LANGUAGE plpgsql
  SECURITY DEFINER
  SET search_path TO ''
  AS $function$

DECLARE

    order_record public."DonHang"%ROWTYPE;

    valid_transition boolean := false;

    current_employee bigint :=
        (SELECT private.current_employee_id());

    current_account bigint :=
        (
            SELECT "TaiKhoanID"
            FROM public."TaiKhoan"
            WHERE "UserAuthId" = (SELECT auth.uid())
            LIMIT 1
        );

BEGIN

    -- =====================================================
    -- 1. Kiểm tra quyền nhân viên
    -- =====================================================

    IF (SELECT auth.uid()) IS NULL
       OR NOT (SELECT private.is_staff())
       OR (
           current_employee IS NULL
           AND NOT (SELECT private.has_role('Quản lý'))
           AND NOT (SELECT private.has_role('Chủ cửa hàng'))
       ) THEN

        RAISE EXCEPTION
            'An active staff account is required';

    END IF;


    -- =====================================================
    -- 2. Lấy và khóa Order
    -- =====================================================

    SELECT *
    INTO order_record

    FROM public."DonHang"

    WHERE "DonHangID" = p_donhangid

    FOR UPDATE;


    IF NOT FOUND THEN

        RAISE EXCEPTION
            'Order not found';

    END IF;


    -- =====================================================
    -- 3. Kiểm tra chuyển trạng thái
    -- =====================================================

    valid_transition :=
        CASE order_record."TrangThai"

            WHEN 'Chờ tiếp nhận'
                THEN p_trangthaimoi IN (
                    'Đã tiếp nhận',
                    'Đã hủy'
                )

            WHEN 'Đã tiếp nhận'
                THEN p_trangthaimoi IN (
                    'Đang giặt',
                    'Đã hủy'
                )

            WHEN 'Đang giặt'
                THEN p_trangthaimoi =
                     'Hoàn thành giặt'

            WHEN 'Hoàn thành giặt'
                THEN p_trangthaimoi IN (
                    'Đang giao',
                    'Đã giao'
                )

            WHEN 'Đang giao'
                THEN p_trangthaimoi =
                     'Đã giao'

            ELSE false

        END;


    IF NOT valid_transition THEN

        RAISE EXCEPTION
            'Invalid order status transition: % -> %',
            order_record."TrangThai",
            p_trangthaimoi;

    END IF;


    -- =====================================================
    -- 4. Hủy đơn bắt buộc có lý do
    -- =====================================================

    IF p_trangthaimoi = 'Đã hủy'
       AND nullif(
            btrim(p_lydo),
            ''
       ) IS NULL THEN

        RAISE EXCEPTION
            'A cancellation reason is required';

    END IF;


    -- =====================================================
    -- 5. Cập nhật Order
    -- =====================================================

    UPDATE public."DonHang"

    SET
        "TrangThai" = p_trangthaimoi,

        "NhanVienID" =
            coalesce(
                current_employee,
                "NhanVienID"
            ),

        "NgayCapNhat" = now()

    WHERE "DonHangID" = p_donhangid;


    -- =====================================================
    -- 6. Ghi lịch sử vào NhatKyHeThong
    -- =====================================================

    INSERT INTO public."NhatKyHeThong" (
        "TaiKhoanID",
        "HanhDong",
        "BangDuLieu",
        "BanGhiID",
        "DuLieuCu",
        "DuLieuMoi",
        "LyDo",
        "ThoiGian"
    )
    VALUES (
        current_account,

        'Thay đổi trạng thái đơn hàng',

        'DonHang',

        p_donhangid,

        jsonb_build_object(
            'TrangThai',
            order_record."TrangThai"
        ),

        jsonb_build_object(
            'TrangThai',
            p_trangthaimoi
        ),

        nullif(
            left(
                btrim(p_lydo),
                500
            ),
            ''
        ),

        now()
    );

END;

$function$;

ALTER TABLE "public"."ChiTietBooking"
  ADD CONSTRAINT "ChiTietBooking_BookingID_fkey" FOREIGN KEY ("BookingID") REFERENCES public."Booking"("BookingID") ON DELETE CASCADE;

ALTER TABLE "public"."BangGia"
  ADD CONSTRAINT "BangGia_DichVuID_fkey" FOREIGN KEY ("DichVuID") REFERENCES public."DichVu"("DichVuID");

ALTER TABLE "public"."ChiTietBooking"
  ADD CONSTRAINT "ChiTietBooking_DichVuID_fkey" FOREIGN KEY ("DichVuID") REFERENCES public."DichVu"("DichVuID");

ALTER TABLE "public"."ChiTietDonHang"
  ADD CONSTRAINT "ChiTietDonHang_DichVuID_fkey" FOREIGN KEY ("DichVuID") REFERENCES public."DichVu"("DichVuID");

ALTER TABLE "public"."DonHang"
  ADD CONSTRAINT "DonHang_BookingID_fkey" FOREIGN KEY ("BookingID") REFERENCES public."Booking"("BookingID");

ALTER TABLE "public"."ChiTietDonHang"
  ADD CONSTRAINT "ChiTietDonHang_DonHangID_fkey" FOREIGN KEY ("DonHangID") REFERENCES public."DonHang"("DonHangID");

ALTER TABLE "public"."DanhGia"
  ADD CONSTRAINT "DanhGia_DonHangID_fkey" FOREIGN KEY ("DonHangID") REFERENCES public."DonHang"("DonHangID");

ALTER TABLE "public"."BangGia"
  ADD CONSTRAINT "BangGia_DonViTinhID_fkey" FOREIGN KEY ("DonViTinhID") REFERENCES public."DonViTinh"("DonViTinhID");

ALTER TABLE "public"."ChiTietBooking"
  ADD CONSTRAINT "ChiTietBooking_DonViTinhID_fkey" FOREIGN KEY ("DonViTinhID") REFERENCES public."DonViTinh"("DonViTinhID");

ALTER TABLE "public"."ChiTietDonHang"
  ADD CONSTRAINT "ChiTietDonHang_DonViTinhID_fkey" FOREIGN KEY ("DonViTinhID") REFERENCES public."DonViTinh"("DonViTinhID");

ALTER TABLE "public"."GiaoNhan"
  ADD CONSTRAINT "GiaoNhan_DonHangID_fkey" FOREIGN KEY ("DonHangID") REFERENCES public."DonHang"("DonHangID");

ALTER TABLE "public"."HoaDon"
  ADD CONSTRAINT "HoaDon_DonHangID_fkey" FOREIGN KEY ("DonHangID") REFERENCES public."DonHang"("DonHangID");

ALTER TABLE "public"."Booking"
  ADD CONSTRAINT "Booking_KhachHangID_fkey" FOREIGN KEY ("KhachHangID") REFERENCES public."KhachHang"("KhachHangID");

ALTER TABLE "public"."DanhGia"
  ADD CONSTRAINT "DanhGia_KhachHangID_fkey" FOREIGN KEY ("KhachHangID") REFERENCES public."KhachHang"("KhachHangID");

ALTER TABLE "public"."DiemTichLuy"
  ADD CONSTRAINT "DiemTichLuy_KhachHangID_fkey" FOREIGN KEY ("KhachHangID") REFERENCES public."KhachHang"("KhachHangID");

ALTER TABLE "public"."DonHang"
  ADD CONSTRAINT "DonHang_KhachHangID_fkey" FOREIGN KEY ("KhachHangID") REFERENCES public."KhachHang"("KhachHangID");

ALTER TABLE "public"."DonHang"
  ADD CONSTRAINT "DonHang_KhuyenMaiID_fkey" FOREIGN KEY ("KhuyenMaiID") REFERENCES public."KhuyenMai"("KhuyenMaiID");

ALTER TABLE "public"."LichSuThayDoiHoaDon"
  ADD CONSTRAINT "LichSuThayDoiHoaDon_HoaDonID_fkey" FOREIGN KEY ("HoaDonID") REFERENCES public."HoaDon"("HoaDonID");

ALTER TABLE "public"."DichVu"
  ADD CONSTRAINT "DichVu_LoaiDichVuID_fkey" FOREIGN KEY ("LoaiDichVuID") REFERENCES public."LoaiDichVu"("LoaiDichVuID");

ALTER TABLE "public"."BangGia"
  ADD CONSTRAINT "BangGia_LoaiDoGiatID_fkey" FOREIGN KEY ("LoaiDoGiatID") REFERENCES public."LoaiDoGiat"("LoaiDoGiatID");

ALTER TABLE "public"."ChiTietBooking"
  ADD CONSTRAINT "ChiTietBooking_LoaiDoGiatID_fkey" FOREIGN KEY ("LoaiDoGiatID") REFERENCES public."LoaiDoGiat"("LoaiDoGiatID");

ALTER TABLE "public"."ChiTietDonHang"
  ADD CONSTRAINT "ChiTietDonHang_LoaiDoGiatID_fkey" FOREIGN KEY ("LoaiDoGiatID") REFERENCES public."LoaiDoGiat"("LoaiDoGiatID");

ALTER TABLE "public"."Booking"
  ADD CONSTRAINT "Booking_NhanVienID_fkey" FOREIGN KEY ("NhanVienID") REFERENCES public."NhanVien"("NhanVienID") ON DELETE SET NULL;

ALTER TABLE "public"."Booking"
  ADD CONSTRAINT "Booking_NhanVienXacNhanID_fkey" FOREIGN KEY ("NhanVienXacNhanID") REFERENCES public."NhanVien"("NhanVienID");

ALTER TABLE "public"."DonHang"
  ADD CONSTRAINT "DonHang_NhanVienID_fkey" FOREIGN KEY ("NhanVienID") REFERENCES public."NhanVien"("NhanVienID");

ALTER TABLE "public"."GiaoNhan"
  ADD CONSTRAINT "GiaoNhan_NhanVienID_fkey" FOREIGN KEY ("NhanVienID") REFERENCES public."NhanVien"("NhanVienID");

ALTER TABLE "public"."TaiKhoan"
  ADD CONSTRAINT "TaiKhoan_KhachHangID_fkey" FOREIGN KEY ("KhachHangID") REFERENCES public."KhachHang"("KhachHangID");

ALTER TABLE "public"."TaiKhoan"
  ADD CONSTRAINT "TaiKhoan_NhanVienID_fkey" FOREIGN KEY ("NhanVienID") REFERENCES public."NhanVien"("NhanVienID");

ALTER TABLE "public"."LichSuThayDoiHoaDon"
  ADD CONSTRAINT "LichSuThayDoiHoaDon_TaiKhoanID_fkey" FOREIGN KEY ("TaiKhoanID") REFERENCES public."TaiKhoan"("TaiKhoanID");

ALTER TABLE "public"."NhatKyHeThong"
  ADD CONSTRAINT "NhatKyHeThong_TaiKhoanID_fkey" FOREIGN KEY ("TaiKhoanID") REFERENCES public."TaiKhoan"("TaiKhoanID");

ALTER TABLE "public"."TaiKhoan_VaiTro"
  ADD CONSTRAINT "TaiKhoan_VaiTro_TaiKhoanID_fkey" FOREIGN KEY ("TaiKhoanID") REFERENCES public."TaiKhoan"("TaiKhoanID");

ALTER TABLE "public"."ThanhToan"
  ADD CONSTRAINT "ThanhToan_DonHangID_fkey" FOREIGN KEY ("DonHangID") REFERENCES public."DonHang"("DonHangID");

ALTER TABLE "public"."ThongBao"
  ADD CONSTRAINT "ThongBao_DonHangID_fkey" FOREIGN KEY ("DonHangID") REFERENCES public."DonHang"("DonHangID");

ALTER TABLE "public"."ThongBao"
  ADD CONSTRAINT "ThongBao_TaiKhoanID_fkey" FOREIGN KEY ("TaiKhoanID") REFERENCES public."TaiKhoan"("TaiKhoanID");

ALTER TABLE "public"."TinNhan"
  ADD CONSTRAINT "TinNhan_DonHangID_fkey" FOREIGN KEY ("DonHangID") REFERENCES public."DonHang"("DonHangID");

ALTER TABLE "public"."TinNhan"
  ADD CONSTRAINT "TinNhan_NguoiGuiID_fkey" FOREIGN KEY ("NguoiGuiID") REFERENCES public."TaiKhoan"("TaiKhoanID");

ALTER TABLE "public"."TinNhan"
  ADD CONSTRAINT "TinNhan_NguoiNhanID_fkey" FOREIGN KEY ("NguoiNhanID") REFERENCES public."TaiKhoan"("TaiKhoanID");

ALTER TABLE "public"."TaiKhoan_VaiTro"
  ADD CONSTRAINT "TaiKhoan_VaiTro_VaiTroID_fkey" FOREIGN KEY ("VaiTroID") REFERENCES public."VaiTro"("VaiTroID");

ALTER TABLE "public"."VaiTro_Quyen"
  ADD CONSTRAINT "VaiTro_Quyen_QuyenID_fkey" FOREIGN KEY ("QuyenID") REFERENCES public."Quyen"("QuyenID");

ALTER TABLE "public"."VaiTro_Quyen"
  ADD CONSTRAINT "VaiTro_Quyen_VaiTroID_fkey" FOREIGN KEY ("VaiTroID") REFERENCES public."VaiTro"("VaiTroID");

ALTER TABLE "public"."khachhang_diachi"
  ADD CONSTRAINT "khachhang_diachi_khachhangid_fkey" FOREIGN KEY (khachhangid) REFERENCES public."KhachHang"("KhachHangID") ON DELETE CASCADE;

CREATE VIEW "public"."banggia" WITH (security_invoker=true) AS  SELECT "BangGiaID" AS banggiaid,
    "DichVuID" AS dichvuid,
    "LoaiDoGiatID" AS loaidogiatid,
    "DonViTinhID" AS donvitinhid,
    "DonGia" AS dongia,
    "NgayApDung" AS ngayapdung,
    "NgayKetThuc" AS ngayketthuc,
    "TrangThai" AS trangthai
   FROM public."BangGia";

CREATE VIEW "public"."danhgia" WITH (security_invoker=true) AS  SELECT "DanhGiaID" AS danhgiaid,
    "DonHangID" AS donhangid,
    "KhachHangID" AS khachhangid,
    "SoSao" AS sosao,
    "BinhLuan" AS binhluan,
    "NgayDanhGia" AS ngaydanhgia,
    "TrangThai" AS trangthai
   FROM public."DanhGia";

REVOKE ALL ON TABLE "public"."danhgia" FROM "anon";

CREATE VIEW "public"."dichvu" WITH (security_invoker=true) AS  SELECT "DichVuID" AS dichvuid,
    "LoaiDichVuID" AS loaidichvuid,
    "TenDichVu" AS tendichvu,
    "MoTa" AS mota,
    "ThoiGianDuKien" AS thoigiandukien,
    "TrangThai" AS trangthai,
    "NgayTao" AS ngaytao
   FROM public."DichVu";

CREATE VIEW "public"."donvitinh" WITH (security_invoker=true) AS  SELECT "DonViTinhID" AS donvitinhid,
    "TenDonViTinh" AS tendonvitinh,
    "KyHieu" AS kyhieu,
    "TrangThai" AS trangthai
   FROM public."DonViTinh";

CREATE VIEW "public"."hoadon" WITH (security_invoker=true) AS  SELECT "HoaDonID" AS hoadonid,
    "MaHoaDon" AS mahoadon,
    "DonHangID" AS donhangid,
    "TongTien" AS tongtien,
    "GiamGia" AS giamgia,
    "PhiGiaoHang" AS phigiaohang,
    "ThanhTien" AS thanhtien,
    "NgayLap" AS ngaylap,
    "TrangThai" AS trangthai
   FROM public."HoaDon";

REVOKE ALL ON TABLE "public"."hoadon" FROM "anon";

CREATE VIEW "public"."khachhang" WITH (security_invoker=true) AS  SELECT "KhachHangID" AS khachhangid,
    "HoTen" AS hoten,
    "SoDienThoai" AS sodienthoai,
    "Email" AS email,
    "DiaChi" AS diachi,
    "NgayTao" AS ngaytao,
    "TrangThai" AS trangthai
   FROM public."KhachHang";

REVOKE ALL ON TABLE "public"."khachhang" FROM "anon";

CREATE VIEW "public"."lichsuthaydoihoadon" WITH (security_invoker=true) AS  SELECT "LichSuID" AS lichsuid,
    "HoaDonID" AS hoadonid,
    "TaiKhoanID" AS taikhoanid,
    "ThoiGian" AS thoigian,
    "TruongThayDoi" AS truongthaydoi,
    "GiaTriCu" AS giatricu,
    "GiaTriMoi" AS giatrimoi,
    "LyDo" AS lydo
   FROM public."LichSuThayDoiHoaDon";

REVOKE ALL ON TABLE "public"."lichsuthaydoihoadon" FROM "anon";

CREATE VIEW "public"."loaidichvu" WITH (security_invoker=true) AS  SELECT "LoaiDichVuID" AS loaidichvuid,
    "TenLoaiDichVu" AS tenloaidichvu,
    "MoTa" AS mota,
    "TrangThai" AS trangthai
   FROM public."LoaiDichVu";

CREATE VIEW "public"."loaidogiat" WITH (security_invoker=true) AS  SELECT "LoaiDoGiatID" AS loaidogiatid,
    "TenLoaiDoGiat" AS tenloaidogiat,
    "MoTa" AS mota,
    "TrangThai" AS trangthai
   FROM public."LoaiDoGiat";

CREATE VIEW "public"."nhanvien" WITH (security_invoker=true) AS  SELECT "NhanVienID" AS nhanvienid,
    "HoTen" AS hoten,
    "SoDienThoai" AS sodienthoai,
    "Email" AS email,
    "DiaChi" AS diachi,
    "ChucDanh" AS chucdanh,
    "NgayVaoLam" AS ngayvaolam,
    "TrangThai" AS trangthai
   FROM public."NhanVien";

REVOKE ALL ON TABLE "public"."nhanvien" FROM "anon";

CREATE VIEW "public"."quyen" WITH (security_invoker=true) AS  SELECT "QuyenID" AS quyenid,
    "MaQuyen" AS maquyen,
    "TenQuyen" AS tenquyen,
    "MoTa" AS mota,
    "TrangThai" AS trangthai
   FROM public."Quyen";

REVOKE ALL ON TABLE "public"."quyen" FROM "anon";

CREATE VIEW "public"."taikhoan_vaitro" WITH (security_invoker=true) AS  SELECT "TaiKhoanID" AS taikhoanid,
    "VaiTroID" AS vaitroid
   FROM public."TaiKhoan_VaiTro";

REVOKE ALL ON TABLE "public"."taikhoan_vaitro" FROM "anon";

CREATE VIEW "public"."taikhoan" WITH (security_invoker=true) AS  SELECT "TaiKhoanID" AS taikhoanid,
    "TenDangNhap" AS tendangnhap,
    "MatKhau" AS matkhau,
    "Email" AS email,
    "SoDienThoai" AS sodienthoai,
    "NhanVienID" AS nhanvienid,
    "KhachHangID" AS khachhangid,
    "TrangThai" AS trangthai,
    "NgayTao" AS ngaytao,
    "UserAuthId" AS userauthid
   FROM public."TaiKhoan";

REVOKE ALL ON TABLE "public"."taikhoan" FROM "anon";

CREATE VIEW "public"."thanhtoan" WITH (security_invoker=true) AS  SELECT "ThanhToanID" AS thanhtoanid,
    "DonHangID" AS donhangid,
    "SoTien" AS sotien,
    "PhuongThuc" AS phuongthuc,
    "MaGiaoDich" AS magiaodich,
    "ThoiGian" AS thoigian,
    "TrangThai" AS trangthai,
    "GhiChu" AS ghichu
   FROM public."ThanhToan";

REVOKE ALL ON TABLE "public"."thanhtoan" FROM "anon";

CREATE VIEW "public"."thongbao" WITH (security_invoker=true) AS  SELECT "ThongBaoID" AS thongbaoid,
    "TaiKhoanID" AS taikhoanid,
    "DonHangID" AS donhangid,
    "LoaiThongBao" AS loaithongbao,
    "TieuDe" AS tieude,
    "NoiDung" AS noidung,
    "ThoiGianGui" AS thoigiangui,
    "DaDoc" AS dadoc
   FROM public."ThongBao";

REVOKE ALL ON TABLE "public"."thongbao" FROM "anon";

CREATE VIEW "public"."tinnhan" WITH (security_invoker=true) AS  SELECT "TinNhanID" AS tinnhanid,
    "NguoiGuiID" AS nguoiguiid,
    "NguoiNhanID" AS nguoinhanid,
    "DonHangID" AS donhangid,
    "NoiDung" AS noidung,
    "ThoiGianGui" AS thoigiangui,
    "TrangThai" AS trangthai
   FROM public."TinNhan";

REVOKE ALL ON TABLE "public"."tinnhan" FROM "anon";

CREATE VIEW "public"."vaitro_quyen" WITH (security_invoker=true) AS  SELECT "VaiTroID" AS vaitroid,
    "QuyenID" AS quyenid
   FROM public."VaiTro_Quyen";

REVOKE ALL ON TABLE "public"."vaitro_quyen" FROM "anon";

CREATE VIEW "public"."vaitro" WITH (security_invoker=true) AS  SELECT "VaiTroID" AS vaitroid,
    "TenVaiTro" AS tenvaitro,
    "MoTa" AS mota,
    "TrangThai" AS trangthai
   FROM public."VaiTro";

REVOKE ALL ON TABLE "public"."vaitro" FROM "anon";

CREATE UNIQUE INDEX "DonHang_IdempotencyKey_unique_idx" ON public."DonHang" USING btree ("IdempotencyKey")
  WHERE ("IdempotencyKey" IS NOT NULL);

CREATE INDEX "IX_Booking_KhachHangID" ON public."Booking" USING btree ("KhachHangID");

CREATE INDEX "IX_ChiTietDonHang_DonHangID" ON public."ChiTietDonHang" USING btree ("DonHangID");

CREATE INDEX "IX_DonHang_KhachHangID" ON public."DonHang" USING btree ("KhachHangID");

CREATE INDEX "IX_DonHang_NhanVienID" ON public."DonHang" USING btree ("NhanVienID");

CREATE INDEX "IX_DonHang_TrangThai" ON public."DonHang" USING btree ("TrangThai");

CREATE INDEX "IX_GiaoNhan_DonHangID" ON public."GiaoNhan" USING btree ("DonHangID");

CREATE INDEX "IX_ThanhToan_DonHangID" ON public."ThanhToan" USING btree ("DonHangID");

CREATE UNIQUE INDEX "TaiKhoan_UserAuthId_unique_idx" ON public."TaiKhoan" USING btree ("UserAuthId")
  WHERE ("UserAuthId" IS NOT NULL);

CREATE UNIQUE INDEX "UX_DonHang_BookingID" ON public."DonHang" USING btree ("BookingID")
  WHERE ("BookingID" IS NOT NULL);

CREATE UNIQUE INDEX booking_idempotency_key_unique_idx ON public."Booking" USING btree ("IdempotencyKey")
  WHERE ("IdempotencyKey" IS NOT NULL);

CREATE UNIQUE INDEX donhang_bookingid_unique_idx ON public."DonHang" USING btree ("BookingID")
  WHERE ("BookingID" IS NOT NULL);

CREATE INDEX "idx_ChiTietBooking_BookingID" ON public."ChiTietBooking" USING btree ("BookingID");

CREATE INDEX "idx_ChiTietBooking_DichVuID" ON public."ChiTietBooking" USING btree ("DichVuID");

CREATE INDEX "idx_ChiTietBooking_LoaiDoGiatID" ON public."ChiTietBooking" USING btree ("LoaiDoGiatID");

CREATE INDEX "idx_NhatKyHeThong_BangDuLieu_BanGhiID" ON public."NhatKyHeThong" USING btree ("BangDuLieu", "BanGhiID");

CREATE INDEX "idx_NhatKyHeThong_TaiKhoanID" ON public."NhatKyHeThong" USING btree ("TaiKhoanID");

CREATE INDEX "idx_NhatKyHeThong_ThoiGian" ON public."NhatKyHeThong" USING btree ("ThoiGian");

CREATE INDEX sessions_last_activity_index ON public.sessions USING btree (last_activity);

CREATE INDEX sessions_user_id_index ON public.sessions USING btree (user_id);

CREATE UNIQUE INDEX "ux_DonHang_BookingID_not_null" ON public."DonHang" USING btree ("BookingID")
  WHERE ("BookingID" IS NOT NULL);

CREATE TRIGGER laundry_compat_create_order_invoice
  AFTER INSERT ON public."DonHang"
  FOR EACH ROW
  EXECUTE FUNCTION private.create_legacy_order_invoice();

CREATE TRIGGER laundry_compat_record_order_insert
  AFTER INSERT ON public."DonHang"
  FOR EACH ROW
  EXECUTE FUNCTION private.record_legacy_order_status_change();

CREATE TRIGGER laundry_compat_record_order_status
  AFTER UPDATE OF "TrangThai" ON public."DonHang"
  FOR EACH ROW
  EXECUTE FUNCTION private.record_legacy_order_status_change();

CREATE POLICY "laundry_compat_catalog_price" ON "public"."BangGia"
  FOR SELECT
  TO "anon", "authenticated"
  USING (((("TrangThai")::text = 'Hoạt động'::text) AND ("NgayApDung" <= CURRENT_DATE) AND (("NgayKetThuc" IS NULL) OR ("NgayKetThuc" >= CURRENT_DATE))));

CREATE POLICY "mobile_active_prices_read" ON "public"."BangGia"
  FOR SELECT
  TO "anon", "authenticated"
  USING (((("TrangThai")::text = 'Hoạt động'::text) AND ("NgayApDung" <= CURRENT_DATE) AND (("NgayKetThuc" IS NULL) OR ("NgayKetThuc" >= CURRENT_DATE))));

CREATE POLICY "laundry_compat_booking_read" ON "public"."Booking"
  FOR SELECT
  TO "authenticated"
  USING ((("KhachHangID" = ( SELECT private.current_customer_id() AS current_customer_id)) OR ( SELECT private.is_staff() AS is_staff)));

CREATE POLICY "laundry_compat_order_detail_read" ON "public"."ChiTietDonHang"
  FOR SELECT
  TO "authenticated"
  USING (( SELECT private.can_access_order(("ChiTietDonHang"."DonHangID")::bigint) AS can_access_order));

CREATE POLICY "laundry_compat_review_insert" ON "public"."DanhGia"
  FOR INSERT
  TO "authenticated"
  WITH CHECK ((("KhachHangID" = ( SELECT private.current_customer_id() AS current_customer_id)) AND (EXISTS ( SELECT 1
   FROM public."DonHang" order_record
  WHERE
    ((order_record."DonHangID" = "DanhGia"."DonHangID") AND (order_record."KhachHangID" = ( SELECT private.current_customer_id() AS current_customer_id)) AND
    ((order_record."TrangThai")::text = ANY ((ARRAY['Đã giao'::character varying, 'Đã thanh toán'::character varying])::text[])))))));

CREATE POLICY "laundry_compat_review_read" ON "public"."DanhGia"
  FOR SELECT
  TO "authenticated"
  USING ((("KhachHangID" = ( SELECT private.current_customer_id() AS current_customer_id)) OR ( SELECT private.is_staff() AS is_staff)));

CREATE POLICY "laundry_compat_catalog_service" ON "public"."DichVu"
  FOR SELECT
  TO "anon", "authenticated"
  USING ((("TrangThai")::text = 'Hoạt động'::text));

CREATE POLICY "mobile_active_services_read" ON "public"."DichVu"
  FOR SELECT
  TO "anon", "authenticated"
  USING ((("TrangThai")::text = 'Hoạt động'::text));

CREATE POLICY "laundry_compat_loyalty_read" ON "public"."DiemTichLuy"
  FOR SELECT
  TO "authenticated"
  USING ((("KhachHangID" = ( SELECT private.current_customer_id() AS current_customer_id)) OR ( SELECT private.is_staff() AS is_staff)));

CREATE POLICY "laundry_compat_order_read" ON "public"."DonHang"
  FOR SELECT
  TO "authenticated"
  USING ((("KhachHangID" = ( SELECT private.current_customer_id() AS current_customer_id)) OR ( SELECT private.is_staff() AS is_staff)));

CREATE POLICY "laundry_compat_catalog_unit" ON "public"."DonViTinh"
  FOR SELECT
  TO "anon", "authenticated"
  USING ((("TrangThai")::text = 'Hoạt động'::text));

CREATE POLICY "mobile_active_units_read" ON "public"."DonViTinh"
  FOR SELECT
  TO "anon", "authenticated"
  USING ((("TrangThai")::text = 'Hoạt động'::text));

CREATE POLICY "laundry_compat_delivery_read" ON "public"."GiaoNhan"
  FOR SELECT
  TO "authenticated"
  USING (( SELECT private.can_access_order(("GiaoNhan"."DonHangID")::bigint) AS can_access_order));

CREATE POLICY "laundry_compat_invoice_read" ON "public"."HoaDon"
  FOR SELECT
  TO "authenticated"
  USING (( SELECT private.can_access_order(("HoaDon"."DonHangID")::bigint) AS can_access_order));

CREATE POLICY "laundry_compat_customer_read" ON "public"."KhachHang"
  FOR SELECT
  TO "authenticated"
  USING ((("KhachHangID" = ( SELECT private.current_customer_id() AS current_customer_id)) OR ( SELECT private.is_staff() AS is_staff)));

CREATE POLICY "laundry_compat_customer_update" ON "public"."KhachHang"
  FOR UPDATE
  TO "authenticated"
  USING (("KhachHangID" = ( SELECT private.current_customer_id() AS current_customer_id)))
  WITH CHECK (("KhachHangID" = ( SELECT private.current_customer_id() AS current_customer_id)));

CREATE POLICY "laundry_compat_catalog_promotion" ON "public"."KhuyenMai"
  FOR SELECT
  TO "anon", "authenticated"
  USING
    (((("TrangThai")::text = 'Hoạt động'::text) AND ("NgayBatDau" <= CURRENT_DATE) AND ("NgayKetThuc" >= CURRENT_DATE) AND (("SoLuongSuDung" IS NULL) OR ("SoLuongSuDung" > 0))));

CREATE POLICY "laundry_compat_invoice_history_read" ON "public"."LichSuThayDoiHoaDon"
  FOR SELECT
  TO "authenticated"
  USING ((EXISTS ( SELECT 1
   FROM public."HoaDon" invoice
  WHERE ((invoice."HoaDonID" = "LichSuThayDoiHoaDon"."HoaDonID") AND ( SELECT private.can_access_order((invoice."DonHangID")::bigint) AS can_access_order)))));

CREATE POLICY "laundry_compat_catalog_service_type" ON "public"."LoaiDichVu"
  FOR SELECT
  TO "anon", "authenticated"
  USING ((("TrangThai")::text = 'Hoạt động'::text));

CREATE POLICY "laundry_compat_catalog_item_type" ON "public"."LoaiDoGiat"
  FOR SELECT
  TO "anon", "authenticated"
  USING ((("TrangThai")::text = 'Hoạt động'::text));

CREATE POLICY "mobile_active_item_types_read" ON "public"."LoaiDoGiat"
  FOR SELECT
  TO "anon", "authenticated"
  USING ((("TrangThai")::text = 'Hoạt động'::text));

CREATE POLICY "laundry_compat_employee_read" ON "public"."NhanVien"
  FOR SELECT
  TO "authenticated"
  USING
    ((("NhanVienID" = ( SELECT private.current_employee_id() AS current_employee_id)) OR ( SELECT private.has_role('Quản lý'::text) AS has_role) OR ( SELECT
    private.has_role('Chủ cửa hàng'::text) AS has_role)));

CREATE POLICY "laundry_compat_permission_read" ON "public"."Quyen"
  FOR SELECT
  TO "authenticated"
  USING ((( SELECT private.current_account_id() AS current_account_id) IS NOT NULL));

CREATE POLICY "laundry_compat_account_read" ON "public"."TaiKhoan"
  FOR SELECT
  TO "authenticated"
  USING
    ((("TaiKhoanID" = ( SELECT private.current_account_id() AS current_account_id)) OR ( SELECT private.has_role('Quản lý'::text) AS has_role) OR ( SELECT
    private.has_role('Chủ cửa hàng'::text) AS has_role)));

CREATE POLICY "laundry_compat_account_role_read" ON "public"."TaiKhoan_VaiTro"
  FOR SELECT
  TO "authenticated"
  USING
    ((("TaiKhoanID" = ( SELECT private.current_account_id() AS current_account_id)) OR ( SELECT private.has_role('Quản lý'::text) AS has_role) OR ( SELECT
    private.has_role('Chủ cửa hàng'::text) AS has_role)));

CREATE POLICY "laundry_compat_payment_read" ON "public"."ThanhToan"
  FOR SELECT
  TO "authenticated"
  USING (( SELECT private.can_access_order(("ThanhToan"."DonHangID")::bigint) AS can_access_order));

CREATE POLICY "laundry_compat_notification_delete" ON "public"."ThongBao"
  FOR DELETE
  TO "authenticated"
  USING (("TaiKhoanID" = ( SELECT private.current_account_id() AS current_account_id)));

CREATE POLICY "laundry_compat_notification_read" ON "public"."ThongBao"
  FOR SELECT
  TO "authenticated"
  USING (("TaiKhoanID" = ( SELECT private.current_account_id() AS current_account_id)));

CREATE POLICY "laundry_compat_notification_update" ON "public"."ThongBao"
  FOR UPDATE
  TO "authenticated"
  USING (("TaiKhoanID" = ( SELECT private.current_account_id() AS current_account_id)))
  WITH CHECK (("TaiKhoanID" = ( SELECT private.current_account_id() AS current_account_id)));

CREATE POLICY "laundry_compat_message_read" ON "public"."TinNhan"
  FOR SELECT
  TO "authenticated"
  USING
    ((("NguoiGuiID" = ( SELECT private.current_account_id() AS current_account_id)) OR ("NguoiNhanID" = ( SELECT private.current_account_id() AS current_account_id)) OR
    (("DonHangID" IS NOT NULL) AND ( SELECT private.is_staff() AS is_staff) AND ( SELECT private.can_access_order(("TinNhan"."DonHangID")::bigint) AS can_access_order))));

CREATE POLICY "laundry_compat_role_read" ON "public"."VaiTro"
  FOR SELECT
  TO "authenticated"
  USING (((("TrangThai")::text = 'Hoạt động'::text) AND (( SELECT private.current_account_id() AS current_account_id) IS NOT NULL)));

CREATE POLICY "laundry_compat_role_permission_read" ON "public"."VaiTro_Quyen"
  FOR SELECT
  TO "authenticated"
  USING ((( SELECT private.current_account_id() AS current_account_id) IS NOT NULL));

CREATE POLICY "laundry_compat_address_delete" ON "public"."khachhang_diachi"
  FOR DELETE
  TO "authenticated"
  USING ((khachhangid = ( SELECT private.current_customer_id() AS current_customer_id)));

CREATE POLICY "laundry_compat_address_read" ON "public"."khachhang_diachi"
  FOR SELECT
  TO "authenticated"
  USING ((khachhangid = ( SELECT private.current_customer_id() AS current_customer_id)));

REVOKE ALL ON FUNCTION "private"."normalize_phone"(text) FROM PUBLIC;

REVOKE ALL ON FUNCTION "private"."record_legacy_order_status_change"() FROM PUBLIC;

GRANT EXECUTE ON FUNCTION "private"."record_legacy_order_status_change"() TO "postgres";

REVOKE ALL ON FUNCTION "public"."transition_laundry_order"(bigint, text, text) FROM PUBLIC;

GRANT EXECUTE ON FUNCTION "public"."transition_laundry_order"(bigint, text, text) TO PUBLIC;

REVOKE ALL ON FUNCTION "public"."transition_laundry_order"(bigint, text, text) FROM "service_role";

GRANT EXECUTE ON FUNCTION "public"."transition_laundry_order"(bigint, text, text) TO "service_role";

GRANT SELECT, UPDATE, USAGE ON SEQUENCE "public"."BangGia_BangGiaID_seq" TO "postgres", "service_role";

GRANT SELECT, UPDATE, USAGE ON SEQUENCE "public"."Booking_BookingID_seq" TO "postgres", "service_role";

GRANT SELECT, UPDATE, USAGE ON SEQUENCE "public"."ChiTietDonHang_ChiTietDonHangID_seq" TO "postgres", "service_role";

GRANT SELECT, UPDATE, USAGE ON SEQUENCE "public"."DanhGia_DanhGiaID_seq" TO "postgres", "service_role";

GRANT SELECT, UPDATE, USAGE ON SEQUENCE "public"."DichVu_DichVuID_seq" TO "postgres", "service_role";

GRANT SELECT, UPDATE, USAGE ON SEQUENCE "public"."DiemTichLuy_DiemTichLuyID_seq" TO "postgres", "service_role";

GRANT SELECT, UPDATE, USAGE ON SEQUENCE "public"."DonHang_DonHangID_seq" TO "postgres", "service_role";

GRANT SELECT, UPDATE, USAGE ON SEQUENCE "public"."DonViTinh_DonViTinhID_seq" TO "postgres", "service_role";

GRANT SELECT, UPDATE, USAGE ON SEQUENCE "public"."GiaoNhan_GiaoNhanID_seq" TO "postgres", "service_role";

GRANT SELECT, UPDATE, USAGE ON SEQUENCE "public"."HoaDon_HoaDonID_seq" TO "postgres", "service_role";

GRANT SELECT, UPDATE, USAGE ON SEQUENCE "public"."KhachHang_KhachHangID_seq" TO "postgres", "service_role";

GRANT SELECT, UPDATE, USAGE ON SEQUENCE "public"."KhuyenMai_KhuyenMaiID_seq" TO "postgres", "service_role";

GRANT SELECT, UPDATE, USAGE ON SEQUENCE "public"."LichSuThayDoiHoaDon_LichSuID_seq" TO "postgres", "service_role";

GRANT SELECT, UPDATE, USAGE ON SEQUENCE "public"."LoaiDichVu_LoaiDichVuID_seq" TO "postgres", "service_role";

GRANT SELECT, UPDATE, USAGE ON SEQUENCE "public"."LoaiDoGiat_LoaiDoGiatID_seq" TO "postgres", "service_role";

GRANT SELECT, UPDATE, USAGE ON SEQUENCE "public"."NhanVien_NhanVienID_seq" TO "postgres", "service_role";

GRANT SELECT, UPDATE, USAGE ON SEQUENCE "public"."Quyen_QuyenID_seq" TO "postgres", "service_role";

GRANT SELECT, UPDATE, USAGE ON SEQUENCE "public"."TaiKhoan_TaiKhoanID_seq" TO "postgres", "service_role";

GRANT SELECT, UPDATE, USAGE ON SEQUENCE "public"."ThanhToan_ThanhToanID_seq" TO "postgres", "service_role";

GRANT SELECT, UPDATE, USAGE ON SEQUENCE "public"."ThongBao_ThongBaoID_seq" TO "postgres", "service_role";

GRANT SELECT, UPDATE, USAGE ON SEQUENCE "public"."TinNhan_TinNhanID_seq" TO "postgres", "service_role";

GRANT SELECT, UPDATE, USAGE ON SEQUENCE "public"."VaiTro_VaiTroID_seq" TO "postgres", "service_role";

REVOKE ALL ON TABLE "public"."BangGia" FROM "anon";

GRANT SELECT ON TABLE "public"."BangGia" TO "anon";

REVOKE ALL ON TABLE "public"."BangGia" FROM "authenticated";

GRANT SELECT ON TABLE "public"."BangGia" TO "authenticated";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."BangGia" TO "postgres", "service_role";

REVOKE ALL ON TABLE "public"."Booking" FROM "authenticated";

GRANT SELECT ON TABLE "public"."Booking" TO "authenticated";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."Booking" TO "postgres", "service_role";

REVOKE ALL ON TABLE "public"."ChiTietBooking" FROM "authenticated";

GRANT DELETE, INSERT, SELECT, UPDATE ON TABLE "public"."ChiTietBooking" TO "authenticated";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."ChiTietBooking" TO "postgres", "service_role";

REVOKE ALL ON TABLE "public"."ChiTietDonHang" FROM "authenticated";

GRANT SELECT ON TABLE "public"."ChiTietDonHang" TO "authenticated";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."ChiTietDonHang" TO "postgres", "service_role";

REVOKE ALL ON TABLE "public"."DanhGia" FROM "authenticated";

GRANT SELECT ON TABLE "public"."DanhGia" TO "authenticated";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."DanhGia" TO "postgres", "service_role";

REVOKE ALL ON TABLE "public"."DichVu" FROM "anon";

GRANT SELECT ON TABLE "public"."DichVu" TO "anon";

REVOKE ALL ON TABLE "public"."DichVu" FROM "authenticated";

GRANT SELECT ON TABLE "public"."DichVu" TO "authenticated";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."DichVu" TO "postgres", "service_role";

REVOKE ALL ON TABLE "public"."DiemTichLuy" FROM "authenticated";

GRANT SELECT ON TABLE "public"."DiemTichLuy" TO "authenticated";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."DiemTichLuy" TO "postgres", "service_role";

REVOKE ALL ON TABLE "public"."DonHang" FROM "authenticated";

GRANT SELECT ON TABLE "public"."DonHang" TO "authenticated";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."DonHang" TO "postgres", "service_role";

REVOKE ALL ON TABLE "public"."DonViTinh" FROM "anon";

GRANT SELECT ON TABLE "public"."DonViTinh" TO "anon";

REVOKE ALL ON TABLE "public"."DonViTinh" FROM "authenticated";

GRANT SELECT ON TABLE "public"."DonViTinh" TO "authenticated";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."DonViTinh" TO "postgres", "service_role";

REVOKE ALL ON TABLE "public"."GiaoNhan" FROM "authenticated";

GRANT SELECT ON TABLE "public"."GiaoNhan" TO "authenticated";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."GiaoNhan" TO "postgres", "service_role";

REVOKE ALL ON TABLE "public"."HoaDon" FROM "authenticated";

GRANT SELECT ON TABLE "public"."HoaDon" TO "authenticated";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."HoaDon" TO "postgres", "service_role";

REVOKE ALL ("DiaChi") ON TABLE "public"."KhachHang" FROM "authenticated";

GRANT UPDATE ("DiaChi") ON TABLE "public"."KhachHang" TO "authenticated";

REVOKE ALL ("Email") ON TABLE "public"."KhachHang" FROM "authenticated";

GRANT UPDATE ("Email") ON TABLE "public"."KhachHang" TO "authenticated";

REVOKE ALL ("HoTen") ON TABLE "public"."KhachHang" FROM "authenticated";

GRANT UPDATE ("HoTen") ON TABLE "public"."KhachHang" TO "authenticated";

REVOKE ALL ON TABLE "public"."KhachHang" FROM "authenticated";

GRANT SELECT ON TABLE "public"."KhachHang" TO "authenticated";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."KhachHang" TO "postgres", "service_role";

REVOKE ALL ON TABLE "public"."KhuyenMai" FROM "anon";

GRANT SELECT ON TABLE "public"."KhuyenMai" TO "anon";

REVOKE ALL ON TABLE "public"."KhuyenMai" FROM "authenticated";

GRANT SELECT ON TABLE "public"."KhuyenMai" TO "authenticated";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."KhuyenMai" TO "postgres", "service_role";

REVOKE ALL ON TABLE "public"."LichSuThayDoiHoaDon" FROM "authenticated";

GRANT SELECT ON TABLE "public"."LichSuThayDoiHoaDon" TO "authenticated";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."LichSuThayDoiHoaDon" TO "postgres", "service_role";

REVOKE ALL ON TABLE "public"."LoaiDichVu" FROM "anon";

GRANT SELECT ON TABLE "public"."LoaiDichVu" TO "anon";

REVOKE ALL ON TABLE "public"."LoaiDichVu" FROM "authenticated";

GRANT SELECT ON TABLE "public"."LoaiDichVu" TO "authenticated";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."LoaiDichVu" TO "postgres", "service_role";

REVOKE ALL ON TABLE "public"."LoaiDoGiat" FROM "anon";

GRANT SELECT ON TABLE "public"."LoaiDoGiat" TO "anon";

REVOKE ALL ON TABLE "public"."LoaiDoGiat" FROM "authenticated";

GRANT SELECT ON TABLE "public"."LoaiDoGiat" TO "authenticated";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."LoaiDoGiat" TO "postgres", "service_role";

REVOKE ALL ON TABLE "public"."NhanVien" FROM "authenticated";

GRANT SELECT ON TABLE "public"."NhanVien" TO "authenticated";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."NhanVien" TO "postgres", "service_role";

REVOKE ALL ON TABLE "public"."NhatKyHeThong" FROM "authenticated";

GRANT INSERT, SELECT ON TABLE "public"."NhatKyHeThong" TO "authenticated";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."NhatKyHeThong" TO "postgres", "service_role";

REVOKE ALL ON TABLE "public"."Quyen" FROM "authenticated";

GRANT SELECT ON TABLE "public"."Quyen" TO "authenticated";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."Quyen" TO "postgres", "service_role";

REVOKE ALL ON TABLE "public"."TaiKhoan" FROM "authenticated";

GRANT SELECT ON TABLE "public"."TaiKhoan" TO "authenticated";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."TaiKhoan" TO "postgres", "service_role";

REVOKE ALL ON TABLE "public"."TaiKhoan_VaiTro" FROM "authenticated";

GRANT SELECT ON TABLE "public"."TaiKhoan_VaiTro" TO "authenticated";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."TaiKhoan_VaiTro" TO "postgres", "service_role";

REVOKE ALL ON TABLE "public"."ThanhToan" FROM "authenticated";

GRANT SELECT ON TABLE "public"."ThanhToan" TO "authenticated";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."ThanhToan" TO "postgres", "service_role";

REVOKE ALL ("DaDoc") ON TABLE "public"."ThongBao" FROM "authenticated";

GRANT UPDATE ("DaDoc") ON TABLE "public"."ThongBao" TO "authenticated";

REVOKE ALL ON TABLE "public"."ThongBao" FROM "authenticated";

GRANT DELETE, SELECT ON TABLE "public"."ThongBao" TO "authenticated";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."ThongBao" TO "postgres", "service_role";

REVOKE ALL ON TABLE "public"."TinNhan" FROM "authenticated";

GRANT SELECT ON TABLE "public"."TinNhan" TO "authenticated";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."TinNhan" TO "postgres", "service_role";

REVOKE ALL ON TABLE "public"."VaiTro" FROM "authenticated";

GRANT SELECT ON TABLE "public"."VaiTro" TO "authenticated";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."VaiTro" TO "postgres", "service_role";

REVOKE ALL ON TABLE "public"."VaiTro_Quyen" FROM "authenticated";

GRANT SELECT ON TABLE "public"."VaiTro_Quyen" TO "authenticated";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."VaiTro_Quyen" TO "postgres", "service_role";

REVOKE ALL ON TABLE "public"."khachhang_diachi" FROM "authenticated";

GRANT DELETE, SELECT ON TABLE "public"."khachhang_diachi" TO "authenticated";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."sessions" TO "postgres", "service_role";

REVOKE ALL ON TABLE "public"."banggia" FROM "anon";

GRANT SELECT ON TABLE "public"."banggia" TO "anon";

REVOKE ALL ON TABLE "public"."banggia" FROM "authenticated";

GRANT SELECT ON TABLE "public"."banggia" TO "authenticated";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."banggia" TO "postgres", "service_role";

REVOKE ALL ON TABLE "public"."danhgia" FROM "authenticated";

GRANT SELECT ON TABLE "public"."danhgia" TO "authenticated";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."danhgia" TO "postgres", "service_role";

REVOKE ALL ON TABLE "public"."dichvu" FROM "anon";

GRANT SELECT ON TABLE "public"."dichvu" TO "anon";

REVOKE ALL ON TABLE "public"."dichvu" FROM "authenticated";

GRANT SELECT ON TABLE "public"."dichvu" TO "authenticated";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."dichvu" TO "postgres", "service_role";

REVOKE ALL ON TABLE "public"."donvitinh" FROM "anon";

GRANT SELECT ON TABLE "public"."donvitinh" TO "anon";

REVOKE ALL ON TABLE "public"."donvitinh" FROM "authenticated";

GRANT SELECT ON TABLE "public"."donvitinh" TO "authenticated";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."donvitinh" TO "postgres", "service_role";

REVOKE ALL ON TABLE "public"."hoadon" FROM "authenticated";

GRANT SELECT ON TABLE "public"."hoadon" TO "authenticated";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."hoadon" TO "postgres", "service_role";

REVOKE ALL ON TABLE "public"."khachhang" FROM "authenticated";

GRANT SELECT ON TABLE "public"."khachhang" TO "authenticated";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."khachhang" TO "postgres", "service_role";

REVOKE ALL ON TABLE "public"."lichsuthaydoihoadon" FROM "authenticated";

GRANT SELECT ON TABLE "public"."lichsuthaydoihoadon" TO "authenticated";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."lichsuthaydoihoadon" TO "postgres", "service_role";

REVOKE ALL ON TABLE "public"."loaidichvu" FROM "anon";

GRANT SELECT ON TABLE "public"."loaidichvu" TO "anon";

REVOKE ALL ON TABLE "public"."loaidichvu" FROM "authenticated";

GRANT SELECT ON TABLE "public"."loaidichvu" TO "authenticated";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."loaidichvu" TO "postgres", "service_role";

REVOKE ALL ON TABLE "public"."loaidogiat" FROM "anon";

GRANT SELECT ON TABLE "public"."loaidogiat" TO "anon";

REVOKE ALL ON TABLE "public"."loaidogiat" FROM "authenticated";

GRANT SELECT ON TABLE "public"."loaidogiat" TO "authenticated";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."loaidogiat" TO "postgres", "service_role";

REVOKE ALL ON TABLE "public"."nhanvien" FROM "authenticated";

GRANT SELECT ON TABLE "public"."nhanvien" TO "authenticated";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."nhanvien" TO "postgres", "service_role";

REVOKE ALL ON TABLE "public"."quyen" FROM "authenticated";

GRANT SELECT ON TABLE "public"."quyen" TO "authenticated";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."quyen" TO "postgres", "service_role";

REVOKE ALL ON TABLE "public"."taikhoan" FROM "authenticated";

GRANT SELECT ON TABLE "public"."taikhoan" TO "authenticated";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."taikhoan" TO "postgres", "service_role";

REVOKE ALL ON TABLE "public"."taikhoan_vaitro" FROM "authenticated";

GRANT SELECT ON TABLE "public"."taikhoan_vaitro" TO "authenticated";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."taikhoan_vaitro" TO "postgres", "service_role";

REVOKE ALL ON TABLE "public"."thanhtoan" FROM "authenticated";

GRANT SELECT ON TABLE "public"."thanhtoan" TO "authenticated";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."thanhtoan" TO "postgres", "service_role";

REVOKE ALL ON TABLE "public"."thongbao" FROM "authenticated";

GRANT DELETE, SELECT ON TABLE "public"."thongbao" TO "authenticated";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."thongbao" TO "postgres", "service_role";

REVOKE ALL ON TABLE "public"."tinnhan" FROM "authenticated";

GRANT SELECT ON TABLE "public"."tinnhan" TO "authenticated";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."tinnhan" TO "postgres", "service_role";

REVOKE ALL ON TABLE "public"."vaitro" FROM "authenticated";

GRANT SELECT ON TABLE "public"."vaitro" TO "authenticated";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."vaitro" TO "postgres", "service_role";

REVOKE ALL ON TABLE "public"."vaitro_quyen" FROM "authenticated";

GRANT SELECT ON TABLE "public"."vaitro_quyen" TO "authenticated";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."vaitro_quyen" TO "postgres", "service_role";
