


SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;


COMMENT ON SCHEMA "public" IS 'standard public schema';



CREATE EXTENSION IF NOT EXISTS "pg_stat_statements" WITH SCHEMA "extensions";






CREATE EXTENSION IF NOT EXISTS "pgcrypto" WITH SCHEMA "extensions";






CREATE EXTENSION IF NOT EXISTS "supabase_vault" WITH SCHEMA "vault";






CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA "extensions";





SET default_tablespace = '';

SET default_table_access_method = "heap";


CREATE TABLE IF NOT EXISTS "public"."banggia" (
    "banggiaid" bigint NOT NULL,
    "dichvuid" bigint NOT NULL,
    "loaidogiatid" bigint NOT NULL,
    "donvitinhid" bigint NOT NULL,
    "dongia" numeric(18,2) NOT NULL,
    "ngayapdung" "date" NOT NULL,
    "ngayketthuc" "date",
    "trangthai" character varying(30) DEFAULT 'Hoạt động'::character varying NOT NULL,
    CONSTRAINT "banggia_dongia_check" CHECK (("dongia" >= (0)::numeric)),
    CONSTRAINT "ck_banggia_ngay" CHECK ((("ngayketthuc" IS NULL) OR ("ngayketthuc" >= "ngayapdung"))),
    CONSTRAINT "ck_banggia_trangthai" CHECK ((("trangthai")::"text" = ANY ((ARRAY['Hoạt động'::character varying, 'Hết hiệu lực'::character varying, 'Tạm ngưng'::character varying])::"text"[])))
);


ALTER TABLE "public"."banggia" OWNER TO "postgres";


ALTER TABLE "public"."banggia" ALTER COLUMN "banggiaid" ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME "public"."banggia_banggiaid_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);



CREATE TABLE IF NOT EXISTS "public"."booking" (
    "bookingid" bigint NOT NULL,
    "mabooking" character varying(30) NOT NULL,
    "khachhangid" bigint NOT NULL,
    "hinhthucnhando" character varying(30) NOT NULL,
    "diachinhan" character varying(255),
    "ngayhen" "date" NOT NULL,
    "giohen" time without time zone NOT NULL,
    "ghichu" character varying(500),
    "trangthai" character varying(30) DEFAULT 'Chờ xác nhận'::character varying NOT NULL,
    "ngaytao" timestamp with time zone DEFAULT "now"() NOT NULL,
    "ngaycapnhat" timestamp with time zone,
    CONSTRAINT "booking_hinhthucnhando_check" CHECK ((("hinhthucnhando")::"text" = ANY ((ARRAY['Tại cửa hàng'::character varying, 'Tại nhà'::character varying])::"text"[]))),
    CONSTRAINT "booking_trangthai_check" CHECK ((("trangthai")::"text" = ANY ((ARRAY['Chờ xác nhận'::character varying, 'Đã xác nhận'::character varying, 'Đã hủy'::character varying, 'Hoàn thành'::character varying])::"text"[])))
);


ALTER TABLE "public"."booking" OWNER TO "postgres";


ALTER TABLE "public"."booking" ALTER COLUMN "bookingid" ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME "public"."booking_bookingid_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);



CREATE TABLE IF NOT EXISTS "public"."chitietdonhang" (
    "chitietdonhangid" bigint NOT NULL,
    "donhangid" bigint NOT NULL,
    "dichvuid" bigint NOT NULL,
    "loaidogiatid" bigint NOT NULL,
    "donvitinhid" bigint NOT NULL,
    "soluong" numeric(10,2),
    "khoiluong" numeric(10,2),
    "dongia" numeric(18,2) NOT NULL,
    "thanhtien" numeric(18,2) NOT NULL,
    "ghichu" character varying(500),
    CONSTRAINT "chitietdonhang_dongia_check" CHECK (("dongia" >= (0)::numeric)),
    CONSTRAINT "chitietdonhang_thanhtien_check" CHECK (("thanhtien" >= (0)::numeric)),
    CONSTRAINT "ck_ctdh_soluongkhoiluong" CHECK (((("soluong" IS NOT NULL) AND ("soluong" > (0)::numeric)) OR (("khoiluong" IS NOT NULL) AND ("khoiluong" > (0)::numeric))))
);


ALTER TABLE "public"."chitietdonhang" OWNER TO "postgres";


ALTER TABLE "public"."chitietdonhang" ALTER COLUMN "chitietdonhangid" ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME "public"."chitietdonhang_chitietdonhangid_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);



CREATE TABLE IF NOT EXISTS "public"."danhgia" (
    "danhgiaid" bigint NOT NULL,
    "donhangid" bigint NOT NULL,
    "khachhangid" bigint NOT NULL,
    "sosao" integer NOT NULL,
    "binhluan" character varying(1000),
    "ngaydanhgia" timestamp with time zone DEFAULT "now"() NOT NULL,
    "trangthai" character varying(30) DEFAULT 'Hiển thị'::character varying NOT NULL,
    CONSTRAINT "danhgia_sosao_check" CHECK ((("sosao" >= 1) AND ("sosao" <= 5))),
    CONSTRAINT "danhgia_trangthai_check" CHECK ((("trangthai")::"text" = ANY ((ARRAY['Hiển thị'::character varying, 'Ẩn'::character varying])::"text"[])))
);


ALTER TABLE "public"."danhgia" OWNER TO "postgres";


ALTER TABLE "public"."danhgia" ALTER COLUMN "danhgiaid" ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME "public"."danhgia_danhgiaid_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);



CREATE TABLE IF NOT EXISTS "public"."dichvu" (
    "dichvuid" bigint NOT NULL,
    "loaidichvuid" bigint NOT NULL,
    "tendichvu" character varying(150) NOT NULL,
    "mota" character varying(500),
    "thoigiandukien" integer,
    "trangthai" character varying(30) DEFAULT 'Hoạt động'::character varying NOT NULL,
    "ngaytao" timestamp with time zone DEFAULT "now"() NOT NULL,
    CONSTRAINT "ck_dichvu_trangthai" CHECK ((("trangthai")::"text" = ANY ((ARRAY['Hoạt động'::character varying, 'Tạm ngưng'::character varying])::"text"[])))
);


ALTER TABLE "public"."dichvu" OWNER TO "postgres";


ALTER TABLE "public"."dichvu" ALTER COLUMN "dichvuid" ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME "public"."dichvu_dichvuid_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);



CREATE TABLE IF NOT EXISTS "public"."diemtichluy" (
    "diemtichluyid" bigint NOT NULL,
    "khachhangid" bigint NOT NULL,
    "diemhientai" integer DEFAULT 0 NOT NULL,
    "ngaycapnhat" timestamp with time zone DEFAULT "now"() NOT NULL,
    CONSTRAINT "diemtichluy_diemhientai_check" CHECK (("diemhientai" >= 0))
);


ALTER TABLE "public"."diemtichluy" OWNER TO "postgres";


ALTER TABLE "public"."diemtichluy" ALTER COLUMN "diemtichluyid" ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME "public"."diemtichluy_diemtichluyid_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);



CREATE TABLE IF NOT EXISTS "public"."donhang" (
    "donhangid" bigint NOT NULL,
    "madonhang" character varying(30) NOT NULL,
    "bookingid" bigint,
    "khachhangid" bigint NOT NULL,
    "nhanvienid" bigint,
    "trangthai" character varying(30) DEFAULT 'Chờ tiếp nhận'::character varying NOT NULL,
    "tongtien" numeric(18,2) DEFAULT 0 NOT NULL,
    "diemsudung" integer DEFAULT 0 NOT NULL,
    "tiengiamdodiem" numeric(18,2) DEFAULT 0 NOT NULL,
    "khuyenmaiid" bigint,
    "tiengiamkhuyenmai" numeric(18,2) DEFAULT 0 NOT NULL,
    "phigiaohang" numeric(18,2) DEFAULT 0 NOT NULL,
    "thanhtien" numeric(18,2) DEFAULT 0 NOT NULL,
    "ghichu" character varying(500),
    "ngaytao" timestamp with time zone DEFAULT "now"() NOT NULL,
    "ngaycapnhat" timestamp with time zone,
    CONSTRAINT "donhang_diemsudung_check" CHECK (("diemsudung" >= 0)),
    CONSTRAINT "donhang_phigiaohang_check" CHECK (("phigiaohang" >= (0)::numeric)),
    CONSTRAINT "donhang_thanhtien_check" CHECK (("thanhtien" >= (0)::numeric)),
    CONSTRAINT "donhang_tiengiamdodiem_check" CHECK (("tiengiamdodiem" >= (0)::numeric)),
    CONSTRAINT "donhang_tiengiamkhuyenmai_check" CHECK (("tiengiamkhuyenmai" >= (0)::numeric)),
    CONSTRAINT "donhang_tongtien_check" CHECK (("tongtien" >= (0)::numeric)),
    CONSTRAINT "donhang_trangthai_check" CHECK ((("trangthai")::"text" = ANY ((ARRAY['Chờ tiếp nhận'::character varying, 'Đã tiếp nhận'::character varying, 'Đang giặt'::character varying, 'Hoàn thành giặt'::character varying, 'Đang giao'::character varying, 'Đã giao'::character varying, 'Đã thanh toán'::character varying, 'Đã hủy'::character varying])::"text"[])))
);


ALTER TABLE "public"."donhang" OWNER TO "postgres";


ALTER TABLE "public"."donhang" ALTER COLUMN "donhangid" ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME "public"."donhang_donhangid_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);



CREATE TABLE IF NOT EXISTS "public"."donvitinh" (
    "donvitinhid" bigint NOT NULL,
    "tendonvitinh" character varying(50) NOT NULL,
    "kyhieu" character varying(20),
    "trangthai" character varying(30) DEFAULT 'Hoạt động'::character varying NOT NULL,
    CONSTRAINT "ck_donvitinh_trangthai" CHECK ((("trangthai")::"text" = ANY ((ARRAY['Hoạt động'::character varying, 'Tạm ngưng'::character varying])::"text"[])))
);


ALTER TABLE "public"."donvitinh" OWNER TO "postgres";


ALTER TABLE "public"."donvitinh" ALTER COLUMN "donvitinhid" ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME "public"."donvitinh_donvitinhid_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);



CREATE TABLE IF NOT EXISTS "public"."giaonhan" (
    "giaonhanid" bigint NOT NULL,
    "donhangid" bigint NOT NULL,
    "nhanvienid" bigint,
    "loaigiaonhan" character varying(30) NOT NULL,
    "hinhthuc" character varying(30) NOT NULL,
    "diachi" character varying(255),
    "thoigiandukien" timestamp with time zone,
    "thoigianthucte" timestamp with time zone,
    "phigiaonhan" numeric(18,2) DEFAULT 0 NOT NULL,
    "trangthai" character varying(30) DEFAULT 'Chờ thực hiện'::character varying NOT NULL,
    "ghichu" character varying(500),
    CONSTRAINT "giaonhan_hinhthuc_check" CHECK ((("hinhthuc")::"text" = ANY ((ARRAY['Tại cửa hàng'::character varying, 'Tại nhà'::character varying])::"text"[]))),
    CONSTRAINT "giaonhan_loaigiaonhan_check" CHECK ((("loaigiaonhan")::"text" = ANY ((ARRAY['NHAN_DO'::character varying, 'GIAO_DO'::character varying])::"text"[]))),
    CONSTRAINT "giaonhan_phigiaonhan_check" CHECK (("phigiaonhan" >= (0)::numeric)),
    CONSTRAINT "giaonhan_trangthai_check" CHECK ((("trangthai")::"text" = ANY ((ARRAY['Chờ thực hiện'::character varying, 'Đang thực hiện'::character varying, 'Hoàn thành'::character varying, 'Đã hủy'::character varying])::"text"[])))
);


ALTER TABLE "public"."giaonhan" OWNER TO "postgres";


ALTER TABLE "public"."giaonhan" ALTER COLUMN "giaonhanid" ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME "public"."giaonhan_giaonhanid_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);



CREATE TABLE IF NOT EXISTS "public"."hoadon" (
    "hoadonid" bigint NOT NULL,
    "mahoadon" character varying(30) NOT NULL,
    "donhangid" bigint NOT NULL,
    "tongtien" numeric(18,2) NOT NULL,
    "giamgia" numeric(18,2) DEFAULT 0 NOT NULL,
    "phigiaohang" numeric(18,2) DEFAULT 0 NOT NULL,
    "thanhtien" numeric(18,2) NOT NULL,
    "ngaylap" timestamp with time zone DEFAULT "now"() NOT NULL,
    "trangthai" character varying(30) DEFAULT 'Chưa thanh toán'::character varying NOT NULL,
    CONSTRAINT "hoadon_giamgia_check" CHECK (("giamgia" >= (0)::numeric)),
    CONSTRAINT "hoadon_phigiaohang_check" CHECK (("phigiaohang" >= (0)::numeric)),
    CONSTRAINT "hoadon_thanhtien_check" CHECK (("thanhtien" >= (0)::numeric)),
    CONSTRAINT "hoadon_tongtien_check" CHECK (("tongtien" >= (0)::numeric)),
    CONSTRAINT "hoadon_trangthai_check" CHECK ((("trangthai")::"text" = ANY ((ARRAY['Chưa thanh toán'::character varying, 'Đã thanh toán'::character varying, 'Đã hủy'::character varying])::"text"[])))
);


ALTER TABLE "public"."hoadon" OWNER TO "postgres";


ALTER TABLE "public"."hoadon" ALTER COLUMN "hoadonid" ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME "public"."hoadon_hoadonid_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);



CREATE TABLE IF NOT EXISTS "public"."khachhang" (
    "khachhangid" bigint NOT NULL,
    "hoten" character varying(100) NOT NULL,
    "sodienthoai" character varying(15) NOT NULL,
    "email" character varying(150),
    "diachi" character varying(255),
    "ngaytao" timestamp with time zone DEFAULT "now"() NOT NULL,
    "trangthai" character varying(30) DEFAULT 'Hoạt động'::character varying NOT NULL,
    CONSTRAINT "ck_khachhang_trangthai" CHECK ((("trangthai")::"text" = ANY ((ARRAY['Hoạt động'::character varying, 'Khóa'::character varying, 'Ngừng hoạt động'::character varying])::"text"[])))
);


ALTER TABLE "public"."khachhang" OWNER TO "postgres";


ALTER TABLE "public"."khachhang" ALTER COLUMN "khachhangid" ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME "public"."khachhang_khachhangid_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);



CREATE TABLE IF NOT EXISTS "public"."khuyenmai" (
    "khuyenmaiid" bigint NOT NULL,
    "makhuyenmai" character varying(50) NOT NULL,
    "tenkhuyenmai" character varying(150) NOT NULL,
    "loaikhuyenmai" character varying(30) NOT NULL,
    "giatrigiam" numeric(18,2) NOT NULL,
    "giatridontoithieu" numeric(18,2),
    "mucgiamtoida" numeric(18,2),
    "soluongsudung" integer,
    "dieukienapdung" character varying(500),
    "ngaybatdau" "date" NOT NULL,
    "ngayketthuc" "date" NOT NULL,
    "trangthai" character varying(30) DEFAULT 'Hoạt động'::character varying NOT NULL,
    CONSTRAINT "ck_khuyenmai_trangthai" CHECK ((("trangthai")::"text" = ANY ((ARRAY['Hoạt động'::character varying, 'Tạm ngưng'::character varying, 'Hết hạn'::character varying])::"text"[]))),
    CONSTRAINT "khuyenmai_check" CHECK (("ngayketthuc" >= "ngaybatdau")),
    CONSTRAINT "khuyenmai_giatrigiam_check" CHECK (("giatrigiam" >= (0)::numeric)),
    CONSTRAINT "khuyenmai_loaikhuyenmai_check" CHECK ((("loaikhuyenmai")::"text" = ANY ((ARRAY['Phần trăm'::character varying, 'Tiền mặt'::character varying])::"text"[])))
);


ALTER TABLE "public"."khuyenmai" OWNER TO "postgres";


ALTER TABLE "public"."khuyenmai" ALTER COLUMN "khuyenmaiid" ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME "public"."khuyenmai_khuyenmaiid_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);



CREATE TABLE IF NOT EXISTS "public"."lichsuthaydoihoadon" (
    "lichsuid" bigint NOT NULL,
    "hoadonid" bigint NOT NULL,
    "taikhoanid" bigint NOT NULL,
    "thoigian" timestamp with time zone DEFAULT "now"() NOT NULL,
    "truongthaydoi" character varying(100) NOT NULL,
    "giatricu" character varying(500),
    "giatrimoi" character varying(500),
    "lydo" character varying(500)
);


ALTER TABLE "public"."lichsuthaydoihoadon" OWNER TO "postgres";


ALTER TABLE "public"."lichsuthaydoihoadon" ALTER COLUMN "lichsuid" ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME "public"."lichsuthaydoihoadon_lichsuid_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);



CREATE TABLE IF NOT EXISTS "public"."loaidichvu" (
    "loaidichvuid" bigint NOT NULL,
    "tenloaidichvu" character varying(100) NOT NULL,
    "mota" character varying(255),
    "trangthai" character varying(30) DEFAULT 'Hoạt động'::character varying NOT NULL,
    CONSTRAINT "ck_loaidichvu_trangthai" CHECK ((("trangthai")::"text" = ANY ((ARRAY['Hoạt động'::character varying, 'Tạm ngưng'::character varying])::"text"[])))
);


ALTER TABLE "public"."loaidichvu" OWNER TO "postgres";


ALTER TABLE "public"."loaidichvu" ALTER COLUMN "loaidichvuid" ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME "public"."loaidichvu_loaidichvuid_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);



CREATE TABLE IF NOT EXISTS "public"."loaidogiat" (
    "loaidogiatid" bigint NOT NULL,
    "tenloaidogiat" character varying(150) NOT NULL,
    "mota" character varying(255),
    "trangthai" character varying(30) DEFAULT 'Hoạt động'::character varying NOT NULL,
    CONSTRAINT "ck_loaidogiat_trangthai" CHECK ((("trangthai")::"text" = ANY ((ARRAY['Hoạt động'::character varying, 'Tạm ngưng'::character varying])::"text"[])))
);


ALTER TABLE "public"."loaidogiat" OWNER TO "postgres";


ALTER TABLE "public"."loaidogiat" ALTER COLUMN "loaidogiatid" ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME "public"."loaidogiat_loaidogiatid_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);



CREATE TABLE IF NOT EXISTS "public"."nhanvien" (
    "nhanvienid" bigint NOT NULL,
    "hoten" character varying(100) NOT NULL,
    "sodienthoai" character varying(15) NOT NULL,
    "email" character varying(150),
    "diachi" character varying(255),
    "chucdanh" character varying(100),
    "ngayvaolam" "date",
    "trangthai" character varying(30) DEFAULT 'Hoạt động'::character varying NOT NULL,
    CONSTRAINT "ck_nhanvien_trangthai" CHECK ((("trangthai")::"text" = ANY ((ARRAY['Hoạt động'::character varying, 'Khóa'::character varying, 'Ngừng hoạt động'::character varying])::"text"[])))
);


ALTER TABLE "public"."nhanvien" OWNER TO "postgres";


ALTER TABLE "public"."nhanvien" ALTER COLUMN "nhanvienid" ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME "public"."nhanvien_nhanvienid_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);



CREATE TABLE IF NOT EXISTS "public"."quyen" (
    "quyenid" bigint NOT NULL,
    "maquyen" character varying(100) NOT NULL,
    "tenquyen" character varying(150) NOT NULL,
    "mota" character varying(255),
    "trangthai" character varying(30) DEFAULT 'Hoạt động'::character varying NOT NULL,
    CONSTRAINT "ck_quyen_trangthai" CHECK ((("trangthai")::"text" = ANY ((ARRAY['Hoạt động'::character varying, 'Ngừng hoạt động'::character varying])::"text"[])))
);


ALTER TABLE "public"."quyen" OWNER TO "postgres";


ALTER TABLE "public"."quyen" ALTER COLUMN "quyenid" ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME "public"."quyen_quyenid_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);



CREATE TABLE IF NOT EXISTS "public"."taikhoan" (
    "taikhoanid" bigint NOT NULL,
    "userauthid" "uuid",
    "tendangnhap" character varying(100) NOT NULL,
    "matkhau" character varying(255) NOT NULL,
    "email" character varying(150),
    "sodienthoai" character varying(15),
    "nhanvienid" bigint,
    "khachhangid" bigint,
    "trangthai" character varying(30) DEFAULT 'Hoạt động'::character varying NOT NULL,
    "ngaytao" timestamp with time zone DEFAULT "now"() NOT NULL,
    CONSTRAINT "ck_taikhoan_doituong" CHECK (((("nhanvienid" IS NOT NULL) AND ("khachhangid" IS NULL)) OR (("nhanvienid" IS NULL) AND ("khachhangid" IS NOT NULL)))),
    CONSTRAINT "ck_taikhoan_trangthai" CHECK ((("trangthai")::"text" = ANY ((ARRAY['Hoạt động'::character varying, 'Khóa'::character varying, 'Ngừng hoạt động'::character varying])::"text"[])))
);


ALTER TABLE "public"."taikhoan" OWNER TO "postgres";


ALTER TABLE "public"."taikhoan" ALTER COLUMN "taikhoanid" ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME "public"."taikhoan_taikhoanid_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);



CREATE TABLE IF NOT EXISTS "public"."taikhoan_vaitro" (
    "taikhoanid" bigint NOT NULL,
    "vaitroid" bigint NOT NULL
);


ALTER TABLE "public"."taikhoan_vaitro" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."thanhtoan" (
    "thanhtoanid" bigint NOT NULL,
    "donhangid" bigint NOT NULL,
    "sotien" numeric(18,2) NOT NULL,
    "phuongthuc" character varying(30) NOT NULL,
    "magiaodich" character varying(100),
    "thoigian" timestamp with time zone DEFAULT "now"() NOT NULL,
    "trangthai" character varying(30) DEFAULT 'Chờ thanh toán'::character varying NOT NULL,
    "ghichu" character varying(500),
    CONSTRAINT "thanhtoan_phuongthuc_check" CHECK ((("phuongthuc")::"text" = ANY ((ARRAY['Tiền mặt'::character varying, 'Chuyển khoản'::character varying])::"text"[]))),
    CONSTRAINT "thanhtoan_sotien_check" CHECK (("sotien" > (0)::numeric)),
    CONSTRAINT "thanhtoan_trangthai_check" CHECK ((("trangthai")::"text" = ANY ((ARRAY['Chờ thanh toán'::character varying, 'Thành công'::character varying, 'Thất bại'::character varying, 'Đã hoàn tiền'::character varying])::"text"[])))
);


ALTER TABLE "public"."thanhtoan" OWNER TO "postgres";


ALTER TABLE "public"."thanhtoan" ALTER COLUMN "thanhtoanid" ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME "public"."thanhtoan_thanhtoanid_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);



CREATE TABLE IF NOT EXISTS "public"."thongbao" (
    "thongbaoid" bigint NOT NULL,
    "taikhoanid" bigint NOT NULL,
    "donhangid" bigint,
    "loaithongbao" character varying(50),
    "tieude" character varying(200) NOT NULL,
    "noidung" character varying(1000) NOT NULL,
    "thoigiangui" timestamp with time zone DEFAULT "now"() NOT NULL,
    "dadoc" boolean DEFAULT false NOT NULL
);


ALTER TABLE "public"."thongbao" OWNER TO "postgres";


ALTER TABLE "public"."thongbao" ALTER COLUMN "thongbaoid" ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME "public"."thongbao_thongbaoid_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);



CREATE TABLE IF NOT EXISTS "public"."tinnhan" (
    "tinnhanid" bigint NOT NULL,
    "nguoiguiid" bigint NOT NULL,
    "nguoinhanid" bigint NOT NULL,
    "donhangid" bigint,
    "noidung" character varying(1000) NOT NULL,
    "thoigiangui" timestamp with time zone DEFAULT "now"() NOT NULL,
    "trangthai" character varying(30) DEFAULT 'Đã gửi'::character varying NOT NULL,
    CONSTRAINT "tinnhan_trangthai_check" CHECK ((("trangthai")::"text" = ANY ((ARRAY['Đã gửi'::character varying, 'Đã nhận'::character varying, 'Đã đọc'::character varying])::"text"[])))
);


ALTER TABLE "public"."tinnhan" OWNER TO "postgres";


ALTER TABLE "public"."tinnhan" ALTER COLUMN "tinnhanid" ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME "public"."tinnhan_tinnhanid_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);



CREATE TABLE IF NOT EXISTS "public"."vaitro" (
    "vaitroid" bigint NOT NULL,
    "tenvaitro" character varying(100) NOT NULL,
    "mota" character varying(255),
    "trangthai" character varying(30) DEFAULT 'Hoạt động'::character varying NOT NULL,
    CONSTRAINT "ck_vaitro_trangthai" CHECK ((("trangthai")::"text" = ANY ((ARRAY['Hoạt động'::character varying, 'Ngừng hoạt động'::character varying])::"text"[])))
);


ALTER TABLE "public"."vaitro" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."vaitro_quyen" (
    "vaitroid" bigint NOT NULL,
    "quyenid" bigint NOT NULL
);


ALTER TABLE "public"."vaitro_quyen" OWNER TO "postgres";


ALTER TABLE "public"."vaitro" ALTER COLUMN "vaitroid" ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME "public"."vaitro_vaitroid_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);



ALTER TABLE ONLY "public"."banggia"
    ADD CONSTRAINT "banggia_pkey" PRIMARY KEY ("banggiaid");



ALTER TABLE ONLY "public"."booking"
    ADD CONSTRAINT "booking_mabooking_key" UNIQUE ("mabooking");



ALTER TABLE ONLY "public"."booking"
    ADD CONSTRAINT "booking_pkey" PRIMARY KEY ("bookingid");



ALTER TABLE ONLY "public"."chitietdonhang"
    ADD CONSTRAINT "chitietdonhang_pkey" PRIMARY KEY ("chitietdonhangid");



ALTER TABLE ONLY "public"."danhgia"
    ADD CONSTRAINT "danhgia_donhangid_key" UNIQUE ("donhangid");



ALTER TABLE ONLY "public"."danhgia"
    ADD CONSTRAINT "danhgia_pkey" PRIMARY KEY ("danhgiaid");



ALTER TABLE ONLY "public"."dichvu"
    ADD CONSTRAINT "dichvu_pkey" PRIMARY KEY ("dichvuid");



ALTER TABLE ONLY "public"."diemtichluy"
    ADD CONSTRAINT "diemtichluy_khachhangid_key" UNIQUE ("khachhangid");



ALTER TABLE ONLY "public"."diemtichluy"
    ADD CONSTRAINT "diemtichluy_pkey" PRIMARY KEY ("diemtichluyid");



ALTER TABLE ONLY "public"."donhang"
    ADD CONSTRAINT "donhang_bookingid_key" UNIQUE ("bookingid");



ALTER TABLE ONLY "public"."donhang"
    ADD CONSTRAINT "donhang_madonhang_key" UNIQUE ("madonhang");



ALTER TABLE ONLY "public"."donhang"
    ADD CONSTRAINT "donhang_pkey" PRIMARY KEY ("donhangid");



ALTER TABLE ONLY "public"."donvitinh"
    ADD CONSTRAINT "donvitinh_pkey" PRIMARY KEY ("donvitinhid");



ALTER TABLE ONLY "public"."donvitinh"
    ADD CONSTRAINT "donvitinh_tendonvitinh_key" UNIQUE ("tendonvitinh");



ALTER TABLE ONLY "public"."giaonhan"
    ADD CONSTRAINT "giaonhan_pkey" PRIMARY KEY ("giaonhanid");



ALTER TABLE ONLY "public"."hoadon"
    ADD CONSTRAINT "hoadon_donhangid_key" UNIQUE ("donhangid");



ALTER TABLE ONLY "public"."hoadon"
    ADD CONSTRAINT "hoadon_mahoadon_key" UNIQUE ("mahoadon");



ALTER TABLE ONLY "public"."hoadon"
    ADD CONSTRAINT "hoadon_pkey" PRIMARY KEY ("hoadonid");



ALTER TABLE ONLY "public"."khachhang"
    ADD CONSTRAINT "khachhang_pkey" PRIMARY KEY ("khachhangid");



ALTER TABLE ONLY "public"."khachhang"
    ADD CONSTRAINT "khachhang_sodienthoai_key" UNIQUE ("sodienthoai");



ALTER TABLE ONLY "public"."khuyenmai"
    ADD CONSTRAINT "khuyenmai_makhuyenmai_key" UNIQUE ("makhuyenmai");



ALTER TABLE ONLY "public"."khuyenmai"
    ADD CONSTRAINT "khuyenmai_pkey" PRIMARY KEY ("khuyenmaiid");



ALTER TABLE ONLY "public"."lichsuthaydoihoadon"
    ADD CONSTRAINT "lichsuthaydoihoadon_pkey" PRIMARY KEY ("lichsuid");



ALTER TABLE ONLY "public"."loaidichvu"
    ADD CONSTRAINT "loaidichvu_pkey" PRIMARY KEY ("loaidichvuid");



ALTER TABLE ONLY "public"."loaidichvu"
    ADD CONSTRAINT "loaidichvu_tenloaidichvu_key" UNIQUE ("tenloaidichvu");



ALTER TABLE ONLY "public"."loaidogiat"
    ADD CONSTRAINT "loaidogiat_pkey" PRIMARY KEY ("loaidogiatid");



ALTER TABLE ONLY "public"."loaidogiat"
    ADD CONSTRAINT "loaidogiat_tenloaidogiat_key" UNIQUE ("tenloaidogiat");



ALTER TABLE ONLY "public"."nhanvien"
    ADD CONSTRAINT "nhanvien_pkey" PRIMARY KEY ("nhanvienid");



ALTER TABLE ONLY "public"."nhanvien"
    ADD CONSTRAINT "nhanvien_sodienthoai_key" UNIQUE ("sodienthoai");



ALTER TABLE ONLY "public"."quyen"
    ADD CONSTRAINT "quyen_maquyen_key" UNIQUE ("maquyen");



ALTER TABLE ONLY "public"."quyen"
    ADD CONSTRAINT "quyen_pkey" PRIMARY KEY ("quyenid");



ALTER TABLE ONLY "public"."taikhoan"
    ADD CONSTRAINT "taikhoan_pkey" PRIMARY KEY ("taikhoanid");



ALTER TABLE ONLY "public"."taikhoan"
    ADD CONSTRAINT "taikhoan_tendangnhap_key" UNIQUE ("tendangnhap");



ALTER TABLE ONLY "public"."taikhoan_vaitro"
    ADD CONSTRAINT "taikhoan_vaitro_pkey" PRIMARY KEY ("taikhoanid", "vaitroid");



ALTER TABLE ONLY "public"."thanhtoan"
    ADD CONSTRAINT "thanhtoan_pkey" PRIMARY KEY ("thanhtoanid");



ALTER TABLE ONLY "public"."thongbao"
    ADD CONSTRAINT "thongbao_pkey" PRIMARY KEY ("thongbaoid");



ALTER TABLE ONLY "public"."tinnhan"
    ADD CONSTRAINT "tinnhan_pkey" PRIMARY KEY ("tinnhanid");



ALTER TABLE ONLY "public"."vaitro"
    ADD CONSTRAINT "vaitro_pkey" PRIMARY KEY ("vaitroid");



ALTER TABLE ONLY "public"."vaitro_quyen"
    ADD CONSTRAINT "vaitro_quyen_pkey" PRIMARY KEY ("vaitroid", "quyenid");



ALTER TABLE ONLY "public"."vaitro"
    ADD CONSTRAINT "vaitro_tenvaitro_key" UNIQUE ("tenvaitro");



ALTER TABLE ONLY "public"."banggia"
    ADD CONSTRAINT "banggia_dichvuid_fkey" FOREIGN KEY ("dichvuid") REFERENCES "public"."dichvu"("dichvuid");



ALTER TABLE ONLY "public"."banggia"
    ADD CONSTRAINT "banggia_donvitinhid_fkey" FOREIGN KEY ("donvitinhid") REFERENCES "public"."donvitinh"("donvitinhid");



ALTER TABLE ONLY "public"."banggia"
    ADD CONSTRAINT "banggia_loaidogiatid_fkey" FOREIGN KEY ("loaidogiatid") REFERENCES "public"."loaidogiat"("loaidogiatid");



ALTER TABLE ONLY "public"."booking"
    ADD CONSTRAINT "booking_khachhangid_fkey" FOREIGN KEY ("khachhangid") REFERENCES "public"."khachhang"("khachhangid");



ALTER TABLE ONLY "public"."chitietdonhang"
    ADD CONSTRAINT "chitietdonhang_dichvuid_fkey" FOREIGN KEY ("dichvuid") REFERENCES "public"."dichvu"("dichvuid");



ALTER TABLE ONLY "public"."chitietdonhang"
    ADD CONSTRAINT "chitietdonhang_donhangid_fkey" FOREIGN KEY ("donhangid") REFERENCES "public"."donhang"("donhangid");



ALTER TABLE ONLY "public"."chitietdonhang"
    ADD CONSTRAINT "chitietdonhang_donvitinhid_fkey" FOREIGN KEY ("donvitinhid") REFERENCES "public"."donvitinh"("donvitinhid");



ALTER TABLE ONLY "public"."chitietdonhang"
    ADD CONSTRAINT "chitietdonhang_loaidogiatid_fkey" FOREIGN KEY ("loaidogiatid") REFERENCES "public"."loaidogiat"("loaidogiatid");



ALTER TABLE ONLY "public"."danhgia"
    ADD CONSTRAINT "danhgia_donhangid_fkey" FOREIGN KEY ("donhangid") REFERENCES "public"."donhang"("donhangid");



ALTER TABLE ONLY "public"."danhgia"
    ADD CONSTRAINT "danhgia_khachhangid_fkey" FOREIGN KEY ("khachhangid") REFERENCES "public"."khachhang"("khachhangid");



ALTER TABLE ONLY "public"."dichvu"
    ADD CONSTRAINT "dichvu_loaidichvuid_fkey" FOREIGN KEY ("loaidichvuid") REFERENCES "public"."loaidichvu"("loaidichvuid");



ALTER TABLE ONLY "public"."diemtichluy"
    ADD CONSTRAINT "diemtichluy_khachhangid_fkey" FOREIGN KEY ("khachhangid") REFERENCES "public"."khachhang"("khachhangid");



ALTER TABLE ONLY "public"."donhang"
    ADD CONSTRAINT "donhang_bookingid_fkey" FOREIGN KEY ("bookingid") REFERENCES "public"."booking"("bookingid");



ALTER TABLE ONLY "public"."donhang"
    ADD CONSTRAINT "donhang_khachhangid_fkey" FOREIGN KEY ("khachhangid") REFERENCES "public"."khachhang"("khachhangid");



ALTER TABLE ONLY "public"."donhang"
    ADD CONSTRAINT "donhang_khuyenmaiid_fkey" FOREIGN KEY ("khuyenmaiid") REFERENCES "public"."khuyenmai"("khuyenmaiid");



ALTER TABLE ONLY "public"."donhang"
    ADD CONSTRAINT "donhang_nhanvienid_fkey" FOREIGN KEY ("nhanvienid") REFERENCES "public"."nhanvien"("nhanvienid");



ALTER TABLE ONLY "public"."giaonhan"
    ADD CONSTRAINT "giaonhan_donhangid_fkey" FOREIGN KEY ("donhangid") REFERENCES "public"."donhang"("donhangid");



ALTER TABLE ONLY "public"."giaonhan"
    ADD CONSTRAINT "giaonhan_nhanvienid_fkey" FOREIGN KEY ("nhanvienid") REFERENCES "public"."nhanvien"("nhanvienid");



ALTER TABLE ONLY "public"."hoadon"
    ADD CONSTRAINT "hoadon_donhangid_fkey" FOREIGN KEY ("donhangid") REFERENCES "public"."donhang"("donhangid");



ALTER TABLE ONLY "public"."lichsuthaydoihoadon"
    ADD CONSTRAINT "lichsuthaydoihoadon_hoadonid_fkey" FOREIGN KEY ("hoadonid") REFERENCES "public"."hoadon"("hoadonid");



ALTER TABLE ONLY "public"."lichsuthaydoihoadon"
    ADD CONSTRAINT "lichsuthaydoihoadon_taikhoanid_fkey" FOREIGN KEY ("taikhoanid") REFERENCES "public"."taikhoan"("taikhoanid");



ALTER TABLE ONLY "public"."taikhoan"
    ADD CONSTRAINT "taikhoan_khachhangid_fkey" FOREIGN KEY ("khachhangid") REFERENCES "public"."khachhang"("khachhangid");



ALTER TABLE ONLY "public"."taikhoan"
    ADD CONSTRAINT "taikhoan_nhanvienid_fkey" FOREIGN KEY ("nhanvienid") REFERENCES "public"."nhanvien"("nhanvienid");



ALTER TABLE ONLY "public"."taikhoan"
    ADD CONSTRAINT "taikhoan_userauthid_fkey" FOREIGN KEY ("userauthid") REFERENCES "auth"."users"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."taikhoan_vaitro"
    ADD CONSTRAINT "taikhoan_vaitro_taikhoanid_fkey" FOREIGN KEY ("taikhoanid") REFERENCES "public"."taikhoan"("taikhoanid") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."taikhoan_vaitro"
    ADD CONSTRAINT "taikhoan_vaitro_vaitroid_fkey" FOREIGN KEY ("vaitroid") REFERENCES "public"."vaitro"("vaitroid") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."thanhtoan"
    ADD CONSTRAINT "thanhtoan_donhangid_fkey" FOREIGN KEY ("donhangid") REFERENCES "public"."donhang"("donhangid");



ALTER TABLE ONLY "public"."thongbao"
    ADD CONSTRAINT "thongbao_donhangid_fkey" FOREIGN KEY ("donhangid") REFERENCES "public"."donhang"("donhangid");



ALTER TABLE ONLY "public"."thongbao"
    ADD CONSTRAINT "thongbao_taikhoanid_fkey" FOREIGN KEY ("taikhoanid") REFERENCES "public"."taikhoan"("taikhoanid");



ALTER TABLE ONLY "public"."tinnhan"
    ADD CONSTRAINT "tinnhan_donhangid_fkey" FOREIGN KEY ("donhangid") REFERENCES "public"."donhang"("donhangid");



ALTER TABLE ONLY "public"."tinnhan"
    ADD CONSTRAINT "tinnhan_nguoiguiid_fkey" FOREIGN KEY ("nguoiguiid") REFERENCES "public"."taikhoan"("taikhoanid");



ALTER TABLE ONLY "public"."tinnhan"
    ADD CONSTRAINT "tinnhan_nguoinhanid_fkey" FOREIGN KEY ("nguoinhanid") REFERENCES "public"."taikhoan"("taikhoanid");



ALTER TABLE ONLY "public"."vaitro_quyen"
    ADD CONSTRAINT "vaitro_quyen_quyenid_fkey" FOREIGN KEY ("quyenid") REFERENCES "public"."quyen"("quyenid") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."vaitro_quyen"
    ADD CONSTRAINT "vaitro_quyen_vaitroid_fkey" FOREIGN KEY ("vaitroid") REFERENCES "public"."vaitro"("vaitroid") ON DELETE CASCADE;





ALTER PUBLICATION "supabase_realtime" OWNER TO "postgres";


GRANT USAGE ON SCHEMA "public" TO "postgres";
GRANT USAGE ON SCHEMA "public" TO "anon";
GRANT USAGE ON SCHEMA "public" TO "authenticated";
GRANT USAGE ON SCHEMA "public" TO "service_role";





































































































































































GRANT ALL ON TABLE "public"."banggia" TO "anon";
GRANT ALL ON TABLE "public"."banggia" TO "authenticated";
GRANT ALL ON TABLE "public"."banggia" TO "service_role";



GRANT ALL ON SEQUENCE "public"."banggia_banggiaid_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."banggia_banggiaid_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."banggia_banggiaid_seq" TO "service_role";



GRANT ALL ON TABLE "public"."booking" TO "anon";
GRANT ALL ON TABLE "public"."booking" TO "authenticated";
GRANT ALL ON TABLE "public"."booking" TO "service_role";



GRANT ALL ON SEQUENCE "public"."booking_bookingid_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."booking_bookingid_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."booking_bookingid_seq" TO "service_role";



GRANT ALL ON TABLE "public"."chitietdonhang" TO "anon";
GRANT ALL ON TABLE "public"."chitietdonhang" TO "authenticated";
GRANT ALL ON TABLE "public"."chitietdonhang" TO "service_role";



GRANT ALL ON SEQUENCE "public"."chitietdonhang_chitietdonhangid_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."chitietdonhang_chitietdonhangid_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."chitietdonhang_chitietdonhangid_seq" TO "service_role";



GRANT ALL ON TABLE "public"."danhgia" TO "anon";
GRANT ALL ON TABLE "public"."danhgia" TO "authenticated";
GRANT ALL ON TABLE "public"."danhgia" TO "service_role";



GRANT ALL ON SEQUENCE "public"."danhgia_danhgiaid_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."danhgia_danhgiaid_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."danhgia_danhgiaid_seq" TO "service_role";



GRANT ALL ON TABLE "public"."dichvu" TO "anon";
GRANT ALL ON TABLE "public"."dichvu" TO "authenticated";
GRANT ALL ON TABLE "public"."dichvu" TO "service_role";



GRANT ALL ON SEQUENCE "public"."dichvu_dichvuid_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."dichvu_dichvuid_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."dichvu_dichvuid_seq" TO "service_role";



GRANT ALL ON TABLE "public"."diemtichluy" TO "anon";
GRANT ALL ON TABLE "public"."diemtichluy" TO "authenticated";
GRANT ALL ON TABLE "public"."diemtichluy" TO "service_role";



GRANT ALL ON SEQUENCE "public"."diemtichluy_diemtichluyid_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."diemtichluy_diemtichluyid_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."diemtichluy_diemtichluyid_seq" TO "service_role";



GRANT ALL ON TABLE "public"."donhang" TO "anon";
GRANT ALL ON TABLE "public"."donhang" TO "authenticated";
GRANT ALL ON TABLE "public"."donhang" TO "service_role";



GRANT ALL ON SEQUENCE "public"."donhang_donhangid_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."donhang_donhangid_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."donhang_donhangid_seq" TO "service_role";



GRANT ALL ON TABLE "public"."donvitinh" TO "anon";
GRANT ALL ON TABLE "public"."donvitinh" TO "authenticated";
GRANT ALL ON TABLE "public"."donvitinh" TO "service_role";



GRANT ALL ON SEQUENCE "public"."donvitinh_donvitinhid_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."donvitinh_donvitinhid_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."donvitinh_donvitinhid_seq" TO "service_role";



GRANT ALL ON TABLE "public"."giaonhan" TO "anon";
GRANT ALL ON TABLE "public"."giaonhan" TO "authenticated";
GRANT ALL ON TABLE "public"."giaonhan" TO "service_role";



GRANT ALL ON SEQUENCE "public"."giaonhan_giaonhanid_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."giaonhan_giaonhanid_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."giaonhan_giaonhanid_seq" TO "service_role";



GRANT ALL ON TABLE "public"."hoadon" TO "anon";
GRANT ALL ON TABLE "public"."hoadon" TO "authenticated";
GRANT ALL ON TABLE "public"."hoadon" TO "service_role";



GRANT ALL ON SEQUENCE "public"."hoadon_hoadonid_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."hoadon_hoadonid_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."hoadon_hoadonid_seq" TO "service_role";



GRANT ALL ON TABLE "public"."khachhang" TO "anon";
GRANT ALL ON TABLE "public"."khachhang" TO "authenticated";
GRANT ALL ON TABLE "public"."khachhang" TO "service_role";



GRANT ALL ON SEQUENCE "public"."khachhang_khachhangid_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."khachhang_khachhangid_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."khachhang_khachhangid_seq" TO "service_role";



GRANT ALL ON TABLE "public"."khuyenmai" TO "anon";
GRANT ALL ON TABLE "public"."khuyenmai" TO "authenticated";
GRANT ALL ON TABLE "public"."khuyenmai" TO "service_role";



GRANT ALL ON SEQUENCE "public"."khuyenmai_khuyenmaiid_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."khuyenmai_khuyenmaiid_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."khuyenmai_khuyenmaiid_seq" TO "service_role";



GRANT ALL ON TABLE "public"."lichsuthaydoihoadon" TO "anon";
GRANT ALL ON TABLE "public"."lichsuthaydoihoadon" TO "authenticated";
GRANT ALL ON TABLE "public"."lichsuthaydoihoadon" TO "service_role";



GRANT ALL ON SEQUENCE "public"."lichsuthaydoihoadon_lichsuid_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."lichsuthaydoihoadon_lichsuid_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."lichsuthaydoihoadon_lichsuid_seq" TO "service_role";



GRANT ALL ON TABLE "public"."loaidichvu" TO "anon";
GRANT ALL ON TABLE "public"."loaidichvu" TO "authenticated";
GRANT ALL ON TABLE "public"."loaidichvu" TO "service_role";



GRANT ALL ON SEQUENCE "public"."loaidichvu_loaidichvuid_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."loaidichvu_loaidichvuid_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."loaidichvu_loaidichvuid_seq" TO "service_role";



GRANT ALL ON TABLE "public"."loaidogiat" TO "anon";
GRANT ALL ON TABLE "public"."loaidogiat" TO "authenticated";
GRANT ALL ON TABLE "public"."loaidogiat" TO "service_role";



GRANT ALL ON SEQUENCE "public"."loaidogiat_loaidogiatid_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."loaidogiat_loaidogiatid_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."loaidogiat_loaidogiatid_seq" TO "service_role";



GRANT ALL ON TABLE "public"."nhanvien" TO "anon";
GRANT ALL ON TABLE "public"."nhanvien" TO "authenticated";
GRANT ALL ON TABLE "public"."nhanvien" TO "service_role";



GRANT ALL ON SEQUENCE "public"."nhanvien_nhanvienid_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."nhanvien_nhanvienid_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."nhanvien_nhanvienid_seq" TO "service_role";



GRANT ALL ON TABLE "public"."quyen" TO "anon";
GRANT ALL ON TABLE "public"."quyen" TO "authenticated";
GRANT ALL ON TABLE "public"."quyen" TO "service_role";



GRANT ALL ON SEQUENCE "public"."quyen_quyenid_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."quyen_quyenid_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."quyen_quyenid_seq" TO "service_role";



GRANT ALL ON TABLE "public"."taikhoan" TO "anon";
GRANT ALL ON TABLE "public"."taikhoan" TO "authenticated";
GRANT ALL ON TABLE "public"."taikhoan" TO "service_role";



GRANT ALL ON SEQUENCE "public"."taikhoan_taikhoanid_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."taikhoan_taikhoanid_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."taikhoan_taikhoanid_seq" TO "service_role";



GRANT ALL ON TABLE "public"."taikhoan_vaitro" TO "anon";
GRANT ALL ON TABLE "public"."taikhoan_vaitro" TO "authenticated";
GRANT ALL ON TABLE "public"."taikhoan_vaitro" TO "service_role";



GRANT ALL ON TABLE "public"."thanhtoan" TO "anon";
GRANT ALL ON TABLE "public"."thanhtoan" TO "authenticated";
GRANT ALL ON TABLE "public"."thanhtoan" TO "service_role";



GRANT ALL ON SEQUENCE "public"."thanhtoan_thanhtoanid_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."thanhtoan_thanhtoanid_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."thanhtoan_thanhtoanid_seq" TO "service_role";



GRANT ALL ON TABLE "public"."thongbao" TO "anon";
GRANT ALL ON TABLE "public"."thongbao" TO "authenticated";
GRANT ALL ON TABLE "public"."thongbao" TO "service_role";



GRANT ALL ON SEQUENCE "public"."thongbao_thongbaoid_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."thongbao_thongbaoid_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."thongbao_thongbaoid_seq" TO "service_role";



GRANT ALL ON TABLE "public"."tinnhan" TO "anon";
GRANT ALL ON TABLE "public"."tinnhan" TO "authenticated";
GRANT ALL ON TABLE "public"."tinnhan" TO "service_role";



GRANT ALL ON SEQUENCE "public"."tinnhan_tinnhanid_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."tinnhan_tinnhanid_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."tinnhan_tinnhanid_seq" TO "service_role";



GRANT ALL ON TABLE "public"."vaitro" TO "anon";
GRANT ALL ON TABLE "public"."vaitro" TO "authenticated";
GRANT ALL ON TABLE "public"."vaitro" TO "service_role";



GRANT ALL ON TABLE "public"."vaitro_quyen" TO "anon";
GRANT ALL ON TABLE "public"."vaitro_quyen" TO "authenticated";
GRANT ALL ON TABLE "public"."vaitro_quyen" TO "service_role";



GRANT ALL ON SEQUENCE "public"."vaitro_vaitroid_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."vaitro_vaitroid_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."vaitro_vaitroid_seq" TO "service_role";









ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "service_role";






ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "service_role";






ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "service_role";































drop extension if exists "pg_net";

alter table "public"."banggia" drop constraint "ck_banggia_trangthai";

alter table "public"."booking" drop constraint "booking_hinhthucnhando_check";

alter table "public"."booking" drop constraint "booking_trangthai_check";

alter table "public"."danhgia" drop constraint "danhgia_trangthai_check";

alter table "public"."dichvu" drop constraint "ck_dichvu_trangthai";

alter table "public"."donhang" drop constraint "donhang_trangthai_check";

alter table "public"."donvitinh" drop constraint "ck_donvitinh_trangthai";

alter table "public"."giaonhan" drop constraint "giaonhan_hinhthuc_check";

alter table "public"."giaonhan" drop constraint "giaonhan_loaigiaonhan_check";

alter table "public"."giaonhan" drop constraint "giaonhan_trangthai_check";

alter table "public"."hoadon" drop constraint "hoadon_trangthai_check";

alter table "public"."khachhang" drop constraint "ck_khachhang_trangthai";

alter table "public"."khuyenmai" drop constraint "ck_khuyenmai_trangthai";

alter table "public"."khuyenmai" drop constraint "khuyenmai_loaikhuyenmai_check";

alter table "public"."loaidichvu" drop constraint "ck_loaidichvu_trangthai";

alter table "public"."loaidogiat" drop constraint "ck_loaidogiat_trangthai";

alter table "public"."nhanvien" drop constraint "ck_nhanvien_trangthai";

alter table "public"."quyen" drop constraint "ck_quyen_trangthai";

alter table "public"."taikhoan" drop constraint "ck_taikhoan_trangthai";

alter table "public"."thanhtoan" drop constraint "thanhtoan_phuongthuc_check";

alter table "public"."thanhtoan" drop constraint "thanhtoan_trangthai_check";

alter table "public"."tinnhan" drop constraint "tinnhan_trangthai_check";

alter table "public"."vaitro" drop constraint "ck_vaitro_trangthai";

alter table "public"."banggia" add constraint "ck_banggia_trangthai" CHECK (((trangthai)::text = ANY ((ARRAY['Hoạt động'::character varying, 'Hết hiệu lực'::character varying, 'Tạm ngưng'::character varying])::text[]))) not valid;

alter table "public"."banggia" validate constraint "ck_banggia_trangthai";

alter table "public"."booking" add constraint "booking_hinhthucnhando_check" CHECK (((hinhthucnhando)::text = ANY ((ARRAY['Tại cửa hàng'::character varying, 'Tại nhà'::character varying])::text[]))) not valid;

alter table "public"."booking" validate constraint "booking_hinhthucnhando_check";

alter table "public"."booking" add constraint "booking_trangthai_check" CHECK (((trangthai)::text = ANY ((ARRAY['Chờ xác nhận'::character varying, 'Đã xác nhận'::character varying, 'Đã hủy'::character varying, 'Hoàn thành'::character varying])::text[]))) not valid;

alter table "public"."booking" validate constraint "booking_trangthai_check";

alter table "public"."danhgia" add constraint "danhgia_trangthai_check" CHECK (((trangthai)::text = ANY ((ARRAY['Hiển thị'::character varying, 'Ẩn'::character varying])::text[]))) not valid;

alter table "public"."danhgia" validate constraint "danhgia_trangthai_check";

alter table "public"."dichvu" add constraint "ck_dichvu_trangthai" CHECK (((trangthai)::text = ANY ((ARRAY['Hoạt động'::character varying, 'Tạm ngưng'::character varying])::text[]))) not valid;

alter table "public"."dichvu" validate constraint "ck_dichvu_trangthai";

alter table "public"."donhang" add constraint "donhang_trangthai_check" CHECK (((trangthai)::text = ANY ((ARRAY['Chờ tiếp nhận'::character varying, 'Đã tiếp nhận'::character varying, 'Đang giặt'::character varying, 'Hoàn thành giặt'::character varying, 'Đang giao'::character varying, 'Đã giao'::character varying, 'Đã thanh toán'::character varying, 'Đã hủy'::character varying])::text[]))) not valid;

alter table "public"."donhang" validate constraint "donhang_trangthai_check";

alter table "public"."donvitinh" add constraint "ck_donvitinh_trangthai" CHECK (((trangthai)::text = ANY ((ARRAY['Hoạt động'::character varying, 'Tạm ngưng'::character varying])::text[]))) not valid;

alter table "public"."donvitinh" validate constraint "ck_donvitinh_trangthai";

alter table "public"."giaonhan" add constraint "giaonhan_hinhthuc_check" CHECK (((hinhthuc)::text = ANY ((ARRAY['Tại cửa hàng'::character varying, 'Tại nhà'::character varying])::text[]))) not valid;

alter table "public"."giaonhan" validate constraint "giaonhan_hinhthuc_check";

alter table "public"."giaonhan" add constraint "giaonhan_loaigiaonhan_check" CHECK (((loaigiaonhan)::text = ANY ((ARRAY['NHAN_DO'::character varying, 'GIAO_DO'::character varying])::text[]))) not valid;

alter table "public"."giaonhan" validate constraint "giaonhan_loaigiaonhan_check";

alter table "public"."giaonhan" add constraint "giaonhan_trangthai_check" CHECK (((trangthai)::text = ANY ((ARRAY['Chờ thực hiện'::character varying, 'Đang thực hiện'::character varying, 'Hoàn thành'::character varying, 'Đã hủy'::character varying])::text[]))) not valid;

alter table "public"."giaonhan" validate constraint "giaonhan_trangthai_check";

alter table "public"."hoadon" add constraint "hoadon_trangthai_check" CHECK (((trangthai)::text = ANY ((ARRAY['Chưa thanh toán'::character varying, 'Đã thanh toán'::character varying, 'Đã hủy'::character varying])::text[]))) not valid;

alter table "public"."hoadon" validate constraint "hoadon_trangthai_check";

alter table "public"."khachhang" add constraint "ck_khachhang_trangthai" CHECK (((trangthai)::text = ANY ((ARRAY['Hoạt động'::character varying, 'Khóa'::character varying, 'Ngừng hoạt động'::character varying])::text[]))) not valid;

alter table "public"."khachhang" validate constraint "ck_khachhang_trangthai";

alter table "public"."khuyenmai" add constraint "ck_khuyenmai_trangthai" CHECK (((trangthai)::text = ANY ((ARRAY['Hoạt động'::character varying, 'Tạm ngưng'::character varying, 'Hết hạn'::character varying])::text[]))) not valid;

alter table "public"."khuyenmai" validate constraint "ck_khuyenmai_trangthai";

alter table "public"."khuyenmai" add constraint "khuyenmai_loaikhuyenmai_check" CHECK (((loaikhuyenmai)::text = ANY ((ARRAY['Phần trăm'::character varying, 'Tiền mặt'::character varying])::text[]))) not valid;

alter table "public"."khuyenmai" validate constraint "khuyenmai_loaikhuyenmai_check";

alter table "public"."loaidichvu" add constraint "ck_loaidichvu_trangthai" CHECK (((trangthai)::text = ANY ((ARRAY['Hoạt động'::character varying, 'Tạm ngưng'::character varying])::text[]))) not valid;

alter table "public"."loaidichvu" validate constraint "ck_loaidichvu_trangthai";

alter table "public"."loaidogiat" add constraint "ck_loaidogiat_trangthai" CHECK (((trangthai)::text = ANY ((ARRAY['Hoạt động'::character varying, 'Tạm ngưng'::character varying])::text[]))) not valid;

alter table "public"."loaidogiat" validate constraint "ck_loaidogiat_trangthai";

alter table "public"."nhanvien" add constraint "ck_nhanvien_trangthai" CHECK (((trangthai)::text = ANY ((ARRAY['Hoạt động'::character varying, 'Khóa'::character varying, 'Ngừng hoạt động'::character varying])::text[]))) not valid;

alter table "public"."nhanvien" validate constraint "ck_nhanvien_trangthai";

alter table "public"."quyen" add constraint "ck_quyen_trangthai" CHECK (((trangthai)::text = ANY ((ARRAY['Hoạt động'::character varying, 'Ngừng hoạt động'::character varying])::text[]))) not valid;

alter table "public"."quyen" validate constraint "ck_quyen_trangthai";

alter table "public"."taikhoan" add constraint "ck_taikhoan_trangthai" CHECK (((trangthai)::text = ANY ((ARRAY['Hoạt động'::character varying, 'Khóa'::character varying, 'Ngừng hoạt động'::character varying])::text[]))) not valid;

alter table "public"."taikhoan" validate constraint "ck_taikhoan_trangthai";

alter table "public"."thanhtoan" add constraint "thanhtoan_phuongthuc_check" CHECK (((phuongthuc)::text = ANY ((ARRAY['Tiền mặt'::character varying, 'Chuyển khoản'::character varying])::text[]))) not valid;

alter table "public"."thanhtoan" validate constraint "thanhtoan_phuongthuc_check";

alter table "public"."thanhtoan" add constraint "thanhtoan_trangthai_check" CHECK (((trangthai)::text = ANY ((ARRAY['Chờ thanh toán'::character varying, 'Thành công'::character varying, 'Thất bại'::character varying, 'Đã hoàn tiền'::character varying])::text[]))) not valid;

alter table "public"."thanhtoan" validate constraint "thanhtoan_trangthai_check";

alter table "public"."tinnhan" add constraint "tinnhan_trangthai_check" CHECK (((trangthai)::text = ANY ((ARRAY['Đã gửi'::character varying, 'Đã nhận'::character varying, 'Đã đọc'::character varying])::text[]))) not valid;

alter table "public"."tinnhan" validate constraint "tinnhan_trangthai_check";

alter table "public"."vaitro" add constraint "ck_vaitro_trangthai" CHECK (((trangthai)::text = ANY ((ARRAY['Hoạt động'::character varying, 'Ngừng hoạt động'::character varying])::text[]))) not valid;

alter table "public"."vaitro" validate constraint "ck_vaitro_trangthai";


