export type Json =
  | string
  | number
  | boolean
  | null
  | { [key: string]: Json | undefined }
  | Json[]

export type Database = {
  // Allows to automatically instantiate createClient with right options
  // instead of createClient<Database, { PostgrestVersion: 'XX' }>(URL, KEY)
  __InternalSupabase: {
    PostgrestVersion: "14.5"
  }
  graphql_public: {
    Tables: {
      [_ in never]: never
    }
    Views: {
      [_ in never]: never
    }
    Functions: {
      graphql: {
        Args: {
          extensions?: Json
          operationName?: string
          query?: string
          variables?: Json
        }
        Returns: Json
      }
    }
    Enums: {
      [_ in never]: never
    }
    CompositeTypes: {
      [_ in never]: never
    }
  }
  public: {
    Tables: {
      BangGia: {
        Row: {
          BangGiaID: number
          DichVuID: number
          DonGia: number
          DonViTinhID: number
          LoaiDoGiatID: number
          NgayApDung: string
          NgayKetThuc: string | null
          TrangThai: string
        }
        Insert: {
          BangGiaID?: number
          DichVuID: number
          DonGia: number
          DonViTinhID: number
          LoaiDoGiatID: number
          NgayApDung: string
          NgayKetThuc?: string | null
          TrangThai?: string
        }
        Update: {
          BangGiaID?: number
          DichVuID?: number
          DonGia?: number
          DonViTinhID?: number
          LoaiDoGiatID?: number
          NgayApDung?: string
          NgayKetThuc?: string | null
          TrangThai?: string
        }
        Relationships: [
          {
            foreignKeyName: "BangGia_DichVuID_fkey"
            columns: ["DichVuID"]
            isOneToOne: false
            referencedRelation: "dichvu"
            referencedColumns: ["dichvuid"]
          },
          {
            foreignKeyName: "BangGia_DichVuID_fkey"
            columns: ["DichVuID"]
            isOneToOne: false
            referencedRelation: "DichVu"
            referencedColumns: ["DichVuID"]
          },
          {
            foreignKeyName: "BangGia_DonViTinhID_fkey"
            columns: ["DonViTinhID"]
            isOneToOne: false
            referencedRelation: "donvitinh"
            referencedColumns: ["donvitinhid"]
          },
          {
            foreignKeyName: "BangGia_DonViTinhID_fkey"
            columns: ["DonViTinhID"]
            isOneToOne: false
            referencedRelation: "DonViTinh"
            referencedColumns: ["DonViTinhID"]
          },
          {
            foreignKeyName: "BangGia_LoaiDoGiatID_fkey"
            columns: ["LoaiDoGiatID"]
            isOneToOne: false
            referencedRelation: "loaidogiat"
            referencedColumns: ["loaidogiatid"]
          },
          {
            foreignKeyName: "BangGia_LoaiDoGiatID_fkey"
            columns: ["LoaiDoGiatID"]
            isOneToOne: false
            referencedRelation: "LoaiDoGiat"
            referencedColumns: ["LoaiDoGiatID"]
          },
        ]
      }
      Booking: {
        Row: {
          BookingID: number
          DiaChiNhan: string | null
          GhiChu: string | null
          GioHen: string
          HinhThucNhanDo: string
          IdempotencyKey: string | null
          KhachHangID: number
          MaBooking: string
          NgayCapNhat: string | null
          NgayHen: string
          NgayTao: string
          NhanVienID: number | null
          NhanVienXacNhanID: number | null
          ThoiGianXacNhan: string | null
          TrangThai: string
        }
        Insert: {
          BookingID?: number
          DiaChiNhan?: string | null
          GhiChu?: string | null
          GioHen: string
          HinhThucNhanDo: string
          IdempotencyKey?: string | null
          KhachHangID: number
          MaBooking: string
          NgayCapNhat?: string | null
          NgayHen: string
          NgayTao?: string
          NhanVienID?: number | null
          NhanVienXacNhanID?: number | null
          ThoiGianXacNhan?: string | null
          TrangThai?: string
        }
        Update: {
          BookingID?: number
          DiaChiNhan?: string | null
          GhiChu?: string | null
          GioHen?: string
          HinhThucNhanDo?: string
          IdempotencyKey?: string | null
          KhachHangID?: number
          MaBooking?: string
          NgayCapNhat?: string | null
          NgayHen?: string
          NgayTao?: string
          NhanVienID?: number | null
          NhanVienXacNhanID?: number | null
          ThoiGianXacNhan?: string | null
          TrangThai?: string
        }
        Relationships: [
          {
            foreignKeyName: "Booking_KhachHangID_fkey"
            columns: ["KhachHangID"]
            isOneToOne: false
            referencedRelation: "khachhang"
            referencedColumns: ["khachhangid"]
          },
          {
            foreignKeyName: "Booking_KhachHangID_fkey"
            columns: ["KhachHangID"]
            isOneToOne: false
            referencedRelation: "KhachHang"
            referencedColumns: ["KhachHangID"]
          },
          {
            foreignKeyName: "Booking_NhanVienID_fkey"
            columns: ["NhanVienID"]
            isOneToOne: false
            referencedRelation: "nhanvien"
            referencedColumns: ["nhanvienid"]
          },
          {
            foreignKeyName: "Booking_NhanVienID_fkey"
            columns: ["NhanVienID"]
            isOneToOne: false
            referencedRelation: "NhanVien"
            referencedColumns: ["NhanVienID"]
          },
          {
            foreignKeyName: "Booking_NhanVienXacNhanID_fkey"
            columns: ["NhanVienXacNhanID"]
            isOneToOne: false
            referencedRelation: "nhanvien"
            referencedColumns: ["nhanvienid"]
          },
          {
            foreignKeyName: "Booking_NhanVienXacNhanID_fkey"
            columns: ["NhanVienXacNhanID"]
            isOneToOne: false
            referencedRelation: "NhanVien"
            referencedColumns: ["NhanVienID"]
          },
        ]
      }
      ChiTietBooking: {
        Row: {
          BookingID: number
          ChiTietBookingID: number
          DichVuID: number
          DonGia: number
          DonViTinhID: number
          GhiChu: string | null
          KhoiLuong: number | null
          LoaiDoGiatID: number
          SoLuong: number | null
          ThanhTien: number
        }
        Insert: {
          BookingID: number
          ChiTietBookingID?: number
          DichVuID: number
          DonGia?: number
          DonViTinhID: number
          GhiChu?: string | null
          KhoiLuong?: number | null
          LoaiDoGiatID: number
          SoLuong?: number | null
          ThanhTien?: number
        }
        Update: {
          BookingID?: number
          ChiTietBookingID?: number
          DichVuID?: number
          DonGia?: number
          DonViTinhID?: number
          GhiChu?: string | null
          KhoiLuong?: number | null
          LoaiDoGiatID?: number
          SoLuong?: number | null
          ThanhTien?: number
        }
        Relationships: [
          {
            foreignKeyName: "ChiTietBooking_BookingID_fkey"
            columns: ["BookingID"]
            isOneToOne: false
            referencedRelation: "Booking"
            referencedColumns: ["BookingID"]
          },
          {
            foreignKeyName: "ChiTietBooking_DichVuID_fkey"
            columns: ["DichVuID"]
            isOneToOne: false
            referencedRelation: "dichvu"
            referencedColumns: ["dichvuid"]
          },
          {
            foreignKeyName: "ChiTietBooking_DichVuID_fkey"
            columns: ["DichVuID"]
            isOneToOne: false
            referencedRelation: "DichVu"
            referencedColumns: ["DichVuID"]
          },
          {
            foreignKeyName: "ChiTietBooking_DonViTinhID_fkey"
            columns: ["DonViTinhID"]
            isOneToOne: false
            referencedRelation: "donvitinh"
            referencedColumns: ["donvitinhid"]
          },
          {
            foreignKeyName: "ChiTietBooking_DonViTinhID_fkey"
            columns: ["DonViTinhID"]
            isOneToOne: false
            referencedRelation: "DonViTinh"
            referencedColumns: ["DonViTinhID"]
          },
          {
            foreignKeyName: "ChiTietBooking_LoaiDoGiatID_fkey"
            columns: ["LoaiDoGiatID"]
            isOneToOne: false
            referencedRelation: "loaidogiat"
            referencedColumns: ["loaidogiatid"]
          },
          {
            foreignKeyName: "ChiTietBooking_LoaiDoGiatID_fkey"
            columns: ["LoaiDoGiatID"]
            isOneToOne: false
            referencedRelation: "LoaiDoGiat"
            referencedColumns: ["LoaiDoGiatID"]
          },
        ]
      }
      ChiTietDonHang: {
        Row: {
          ChiTietDonHangID: number
          DichVuID: number
          DonGia: number
          DonHangID: number
          DonViTinhID: number
          GhiChu: string | null
          KhoiLuong: number | null
          LoaiDoGiatID: number
          SoLuong: number | null
          ThanhTien: number
        }
        Insert: {
          ChiTietDonHangID?: number
          DichVuID: number
          DonGia: number
          DonHangID: number
          DonViTinhID: number
          GhiChu?: string | null
          KhoiLuong?: number | null
          LoaiDoGiatID: number
          SoLuong?: number | null
          ThanhTien: number
        }
        Update: {
          ChiTietDonHangID?: number
          DichVuID?: number
          DonGia?: number
          DonHangID?: number
          DonViTinhID?: number
          GhiChu?: string | null
          KhoiLuong?: number | null
          LoaiDoGiatID?: number
          SoLuong?: number | null
          ThanhTien?: number
        }
        Relationships: [
          {
            foreignKeyName: "ChiTietDonHang_DichVuID_fkey"
            columns: ["DichVuID"]
            isOneToOne: false
            referencedRelation: "dichvu"
            referencedColumns: ["dichvuid"]
          },
          {
            foreignKeyName: "ChiTietDonHang_DichVuID_fkey"
            columns: ["DichVuID"]
            isOneToOne: false
            referencedRelation: "DichVu"
            referencedColumns: ["DichVuID"]
          },
          {
            foreignKeyName: "ChiTietDonHang_DonHangID_fkey"
            columns: ["DonHangID"]
            isOneToOne: false
            referencedRelation: "DonHang"
            referencedColumns: ["DonHangID"]
          },
          {
            foreignKeyName: "ChiTietDonHang_DonViTinhID_fkey"
            columns: ["DonViTinhID"]
            isOneToOne: false
            referencedRelation: "donvitinh"
            referencedColumns: ["donvitinhid"]
          },
          {
            foreignKeyName: "ChiTietDonHang_DonViTinhID_fkey"
            columns: ["DonViTinhID"]
            isOneToOne: false
            referencedRelation: "DonViTinh"
            referencedColumns: ["DonViTinhID"]
          },
          {
            foreignKeyName: "ChiTietDonHang_LoaiDoGiatID_fkey"
            columns: ["LoaiDoGiatID"]
            isOneToOne: false
            referencedRelation: "loaidogiat"
            referencedColumns: ["loaidogiatid"]
          },
          {
            foreignKeyName: "ChiTietDonHang_LoaiDoGiatID_fkey"
            columns: ["LoaiDoGiatID"]
            isOneToOne: false
            referencedRelation: "LoaiDoGiat"
            referencedColumns: ["LoaiDoGiatID"]
          },
        ]
      }
      DanhGia: {
        Row: {
          BinhLuan: string | null
          DanhGiaID: number
          DonHangID: number
          KhachHangID: number
          NgayDanhGia: string
          SoSao: number
          TrangThai: string
        }
        Insert: {
          BinhLuan?: string | null
          DanhGiaID?: number
          DonHangID: number
          KhachHangID: number
          NgayDanhGia?: string
          SoSao: number
          TrangThai?: string
        }
        Update: {
          BinhLuan?: string | null
          DanhGiaID?: number
          DonHangID?: number
          KhachHangID?: number
          NgayDanhGia?: string
          SoSao?: number
          TrangThai?: string
        }
        Relationships: [
          {
            foreignKeyName: "DanhGia_DonHangID_fkey"
            columns: ["DonHangID"]
            isOneToOne: true
            referencedRelation: "DonHang"
            referencedColumns: ["DonHangID"]
          },
          {
            foreignKeyName: "DanhGia_KhachHangID_fkey"
            columns: ["KhachHangID"]
            isOneToOne: false
            referencedRelation: "khachhang"
            referencedColumns: ["khachhangid"]
          },
          {
            foreignKeyName: "DanhGia_KhachHangID_fkey"
            columns: ["KhachHangID"]
            isOneToOne: false
            referencedRelation: "KhachHang"
            referencedColumns: ["KhachHangID"]
          },
        ]
      }
      DichVu: {
        Row: {
          DichVuID: number
          LoaiDichVuID: number
          MoTa: string | null
          NgayTao: string
          TenDichVu: string
          ThoiGianDuKien: number | null
          TrangThai: string
        }
        Insert: {
          DichVuID?: number
          LoaiDichVuID: number
          MoTa?: string | null
          NgayTao?: string
          TenDichVu: string
          ThoiGianDuKien?: number | null
          TrangThai?: string
        }
        Update: {
          DichVuID?: number
          LoaiDichVuID?: number
          MoTa?: string | null
          NgayTao?: string
          TenDichVu?: string
          ThoiGianDuKien?: number | null
          TrangThai?: string
        }
        Relationships: [
          {
            foreignKeyName: "DichVu_LoaiDichVuID_fkey"
            columns: ["LoaiDichVuID"]
            isOneToOne: false
            referencedRelation: "loaidichvu"
            referencedColumns: ["loaidichvuid"]
          },
          {
            foreignKeyName: "DichVu_LoaiDichVuID_fkey"
            columns: ["LoaiDichVuID"]
            isOneToOne: false
            referencedRelation: "LoaiDichVu"
            referencedColumns: ["LoaiDichVuID"]
          },
        ]
      }
      DiemTichLuy: {
        Row: {
          DiemHienTai: number
          DiemTichLuyID: number
          KhachHangID: number
          NgayCapNhat: string
        }
        Insert: {
          DiemHienTai?: number
          DiemTichLuyID?: number
          KhachHangID: number
          NgayCapNhat?: string
        }
        Update: {
          DiemHienTai?: number
          DiemTichLuyID?: number
          KhachHangID?: number
          NgayCapNhat?: string
        }
        Relationships: [
          {
            foreignKeyName: "DiemTichLuy_KhachHangID_fkey"
            columns: ["KhachHangID"]
            isOneToOne: true
            referencedRelation: "khachhang"
            referencedColumns: ["khachhangid"]
          },
          {
            foreignKeyName: "DiemTichLuy_KhachHangID_fkey"
            columns: ["KhachHangID"]
            isOneToOne: true
            referencedRelation: "KhachHang"
            referencedColumns: ["KhachHangID"]
          },
        ]
      }
      DonHang: {
        Row: {
          BookingID: number | null
          DiemSuDung: number
          DonHangID: number
          GhiChu: string | null
          IdempotencyKey: string | null
          KhachHangID: number
          KhuyenMaiID: number | null
          MaDonHang: string
          NgayCapNhat: string | null
          NgayTao: string
          NhanVienID: number | null
          PhiGiaoHang: number
          ThanhTien: number
          TienGiamDoDiem: number
          TienGiamKhuyenMai: number
          TongTien: number
          TrangThai: string
        }
        Insert: {
          BookingID?: number | null
          DiemSuDung?: number
          DonHangID?: number
          GhiChu?: string | null
          IdempotencyKey?: string | null
          KhachHangID: number
          KhuyenMaiID?: number | null
          MaDonHang: string
          NgayCapNhat?: string | null
          NgayTao?: string
          NhanVienID?: number | null
          PhiGiaoHang?: number
          ThanhTien?: number
          TienGiamDoDiem?: number
          TienGiamKhuyenMai?: number
          TongTien?: number
          TrangThai?: string
        }
        Update: {
          BookingID?: number | null
          DiemSuDung?: number
          DonHangID?: number
          GhiChu?: string | null
          IdempotencyKey?: string | null
          KhachHangID?: number
          KhuyenMaiID?: number | null
          MaDonHang?: string
          NgayCapNhat?: string | null
          NgayTao?: string
          NhanVienID?: number | null
          PhiGiaoHang?: number
          ThanhTien?: number
          TienGiamDoDiem?: number
          TienGiamKhuyenMai?: number
          TongTien?: number
          TrangThai?: string
        }
        Relationships: [
          {
            foreignKeyName: "DonHang_BookingID_fkey"
            columns: ["BookingID"]
            isOneToOne: false
            referencedRelation: "Booking"
            referencedColumns: ["BookingID"]
          },
          {
            foreignKeyName: "DonHang_KhachHangID_fkey"
            columns: ["KhachHangID"]
            isOneToOne: false
            referencedRelation: "khachhang"
            referencedColumns: ["khachhangid"]
          },
          {
            foreignKeyName: "DonHang_KhachHangID_fkey"
            columns: ["KhachHangID"]
            isOneToOne: false
            referencedRelation: "KhachHang"
            referencedColumns: ["KhachHangID"]
          },
          {
            foreignKeyName: "DonHang_KhuyenMaiID_fkey"
            columns: ["KhuyenMaiID"]
            isOneToOne: false
            referencedRelation: "KhuyenMai"
            referencedColumns: ["KhuyenMaiID"]
          },
          {
            foreignKeyName: "DonHang_NhanVienID_fkey"
            columns: ["NhanVienID"]
            isOneToOne: false
            referencedRelation: "nhanvien"
            referencedColumns: ["nhanvienid"]
          },
          {
            foreignKeyName: "DonHang_NhanVienID_fkey"
            columns: ["NhanVienID"]
            isOneToOne: false
            referencedRelation: "NhanVien"
            referencedColumns: ["NhanVienID"]
          },
        ]
      }
      DonViTinh: {
        Row: {
          DonViTinhID: number
          KyHieu: string | null
          TenDonViTinh: string
          TrangThai: string
        }
        Insert: {
          DonViTinhID?: number
          KyHieu?: string | null
          TenDonViTinh: string
          TrangThai?: string
        }
        Update: {
          DonViTinhID?: number
          KyHieu?: string | null
          TenDonViTinh?: string
          TrangThai?: string
        }
        Relationships: []
      }
      GiaoNhan: {
        Row: {
          DiaChi: string | null
          DonHangID: number
          GhiChu: string | null
          GiaoNhanID: number
          HinhThuc: string
          LoaiGiaoNhan: string
          NhanVienID: number | null
          PhiGiaoNhan: number
          ThoiGianDuKien: string | null
          ThoiGianThucTe: string | null
          TrangThai: string
        }
        Insert: {
          DiaChi?: string | null
          DonHangID: number
          GhiChu?: string | null
          GiaoNhanID?: number
          HinhThuc: string
          LoaiGiaoNhan: string
          NhanVienID?: number | null
          PhiGiaoNhan?: number
          ThoiGianDuKien?: string | null
          ThoiGianThucTe?: string | null
          TrangThai?: string
        }
        Update: {
          DiaChi?: string | null
          DonHangID?: number
          GhiChu?: string | null
          GiaoNhanID?: number
          HinhThuc?: string
          LoaiGiaoNhan?: string
          NhanVienID?: number | null
          PhiGiaoNhan?: number
          ThoiGianDuKien?: string | null
          ThoiGianThucTe?: string | null
          TrangThai?: string
        }
        Relationships: [
          {
            foreignKeyName: "GiaoNhan_DonHangID_fkey"
            columns: ["DonHangID"]
            isOneToOne: false
            referencedRelation: "DonHang"
            referencedColumns: ["DonHangID"]
          },
          {
            foreignKeyName: "GiaoNhan_NhanVienID_fkey"
            columns: ["NhanVienID"]
            isOneToOne: false
            referencedRelation: "nhanvien"
            referencedColumns: ["nhanvienid"]
          },
          {
            foreignKeyName: "GiaoNhan_NhanVienID_fkey"
            columns: ["NhanVienID"]
            isOneToOne: false
            referencedRelation: "NhanVien"
            referencedColumns: ["NhanVienID"]
          },
        ]
      }
      HoaDon: {
        Row: {
          DonHangID: number
          GiamGia: number
          HoaDonID: number
          MaHoaDon: string
          NgayLap: string
          PhiGiaoHang: number
          ThanhTien: number
          TongTien: number
          TrangThai: string
        }
        Insert: {
          DonHangID: number
          GiamGia?: number
          HoaDonID?: number
          MaHoaDon: string
          NgayLap?: string
          PhiGiaoHang?: number
          ThanhTien: number
          TongTien: number
          TrangThai?: string
        }
        Update: {
          DonHangID?: number
          GiamGia?: number
          HoaDonID?: number
          MaHoaDon?: string
          NgayLap?: string
          PhiGiaoHang?: number
          ThanhTien?: number
          TongTien?: number
          TrangThai?: string
        }
        Relationships: [
          {
            foreignKeyName: "HoaDon_DonHangID_fkey"
            columns: ["DonHangID"]
            isOneToOne: true
            referencedRelation: "DonHang"
            referencedColumns: ["DonHangID"]
          },
        ]
      }
      KhachHang: {
        Row: {
          DiaChi: string | null
          Email: string | null
          HoTen: string
          KhachHangID: number
          NgayTao: string
          SoDienThoai: string | null
          TrangThai: string
        }
        Insert: {
          DiaChi?: string | null
          Email?: string | null
          HoTen: string
          KhachHangID?: number
          NgayTao?: string
          SoDienThoai?: string | null
          TrangThai?: string
        }
        Update: {
          DiaChi?: string | null
          Email?: string | null
          HoTen?: string
          KhachHangID?: number
          NgayTao?: string
          SoDienThoai?: string | null
          TrangThai?: string
        }
        Relationships: []
      }
      khachhang_diachi: {
        Row: {
          diachi: string
          diachiid: number
          ghichu: string | null
          khachhangid: number
          macdinh: boolean
          ngaytao: string
          sodienthoai: string | null
          tennguoinhan: string | null
        }
        Insert: {
          diachi: string
          diachiid?: never
          ghichu?: string | null
          khachhangid: number
          macdinh?: boolean
          ngaytao?: string
          sodienthoai?: string | null
          tennguoinhan?: string | null
        }
        Update: {
          diachi?: string
          diachiid?: never
          ghichu?: string | null
          khachhangid?: number
          macdinh?: boolean
          ngaytao?: string
          sodienthoai?: string | null
          tennguoinhan?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "khachhang_diachi_khachhangid_fkey"
            columns: ["khachhangid"]
            isOneToOne: false
            referencedRelation: "khachhang"
            referencedColumns: ["khachhangid"]
          },
          {
            foreignKeyName: "khachhang_diachi_khachhangid_fkey"
            columns: ["khachhangid"]
            isOneToOne: false
            referencedRelation: "KhachHang"
            referencedColumns: ["KhachHangID"]
          },
        ]
      }
      KhuyenMai: {
        Row: {
          DieuKienApDung: string | null
          GiaTriDonToiThieu: number | null
          GiaTriGiam: number
          KhuyenMaiID: number
          LoaiKhuyenMai: string
          MaKhuyenMai: string
          MucGiamToiDa: number | null
          NgayBatDau: string
          NgayKetThuc: string
          SoLuongSuDung: number | null
          TenKhuyenMai: string
          TrangThai: string
        }
        Insert: {
          DieuKienApDung?: string | null
          GiaTriDonToiThieu?: number | null
          GiaTriGiam: number
          KhuyenMaiID?: number
          LoaiKhuyenMai: string
          MaKhuyenMai: string
          MucGiamToiDa?: number | null
          NgayBatDau: string
          NgayKetThuc: string
          SoLuongSuDung?: number | null
          TenKhuyenMai: string
          TrangThai?: string
        }
        Update: {
          DieuKienApDung?: string | null
          GiaTriDonToiThieu?: number | null
          GiaTriGiam?: number
          KhuyenMaiID?: number
          LoaiKhuyenMai?: string
          MaKhuyenMai?: string
          MucGiamToiDa?: number | null
          NgayBatDau?: string
          NgayKetThuc?: string
          SoLuongSuDung?: number | null
          TenKhuyenMai?: string
          TrangThai?: string
        }
        Relationships: []
      }
      LichSuThayDoiHoaDon: {
        Row: {
          GiaTriCu: string | null
          GiaTriMoi: string | null
          HoaDonID: number
          LichSuID: number
          LyDo: string | null
          TaiKhoanID: number
          ThoiGian: string
          TruongThayDoi: string
        }
        Insert: {
          GiaTriCu?: string | null
          GiaTriMoi?: string | null
          HoaDonID: number
          LichSuID?: number
          LyDo?: string | null
          TaiKhoanID: number
          ThoiGian?: string
          TruongThayDoi: string
        }
        Update: {
          GiaTriCu?: string | null
          GiaTriMoi?: string | null
          HoaDonID?: number
          LichSuID?: number
          LyDo?: string | null
          TaiKhoanID?: number
          ThoiGian?: string
          TruongThayDoi?: string
        }
        Relationships: [
          {
            foreignKeyName: "LichSuThayDoiHoaDon_HoaDonID_fkey"
            columns: ["HoaDonID"]
            isOneToOne: false
            referencedRelation: "hoadon"
            referencedColumns: ["hoadonid"]
          },
          {
            foreignKeyName: "LichSuThayDoiHoaDon_HoaDonID_fkey"
            columns: ["HoaDonID"]
            isOneToOne: false
            referencedRelation: "HoaDon"
            referencedColumns: ["HoaDonID"]
          },
          {
            foreignKeyName: "LichSuThayDoiHoaDon_TaiKhoanID_fkey"
            columns: ["TaiKhoanID"]
            isOneToOne: false
            referencedRelation: "taikhoan"
            referencedColumns: ["taikhoanid"]
          },
          {
            foreignKeyName: "LichSuThayDoiHoaDon_TaiKhoanID_fkey"
            columns: ["TaiKhoanID"]
            isOneToOne: false
            referencedRelation: "TaiKhoan"
            referencedColumns: ["TaiKhoanID"]
          },
        ]
      }
      LoaiDichVu: {
        Row: {
          LoaiDichVuID: number
          MoTa: string | null
          TenLoaiDichVu: string
          TrangThai: string
        }
        Insert: {
          LoaiDichVuID?: number
          MoTa?: string | null
          TenLoaiDichVu: string
          TrangThai?: string
        }
        Update: {
          LoaiDichVuID?: number
          MoTa?: string | null
          TenLoaiDichVu?: string
          TrangThai?: string
        }
        Relationships: []
      }
      LoaiDoGiat: {
        Row: {
          LoaiDoGiatID: number
          MoTa: string | null
          TenLoaiDoGiat: string
          TrangThai: string
        }
        Insert: {
          LoaiDoGiatID?: number
          MoTa?: string | null
          TenLoaiDoGiat: string
          TrangThai?: string
        }
        Update: {
          LoaiDoGiatID?: number
          MoTa?: string | null
          TenLoaiDoGiat?: string
          TrangThai?: string
        }
        Relationships: []
      }
      NhanVien: {
        Row: {
          ChucDanh: string | null
          DiaChi: string | null
          Email: string | null
          HoTen: string
          NgayVaoLam: string | null
          NhanVienID: number
          SoDienThoai: string
          TrangThai: string
        }
        Insert: {
          ChucDanh?: string | null
          DiaChi?: string | null
          Email?: string | null
          HoTen: string
          NgayVaoLam?: string | null
          NhanVienID?: number
          SoDienThoai: string
          TrangThai?: string
        }
        Update: {
          ChucDanh?: string | null
          DiaChi?: string | null
          Email?: string | null
          HoTen?: string
          NgayVaoLam?: string | null
          NhanVienID?: number
          SoDienThoai?: string
          TrangThai?: string
        }
        Relationships: []
      }
      NhatKyHeThong: {
        Row: {
          BangDuLieu: string
          BanGhiID: number | null
          DuLieuCu: Json | null
          DuLieuMoi: Json | null
          HanhDong: string
          IPAddress: string | null
          LyDo: string | null
          NhatKyID: number
          TaiKhoanID: number | null
          ThoiGian: string
          UserAgent: string | null
        }
        Insert: {
          BangDuLieu: string
          BanGhiID?: number | null
          DuLieuCu?: Json | null
          DuLieuMoi?: Json | null
          HanhDong: string
          IPAddress?: string | null
          LyDo?: string | null
          NhatKyID?: number
          TaiKhoanID?: number | null
          ThoiGian?: string
          UserAgent?: string | null
        }
        Update: {
          BangDuLieu?: string
          BanGhiID?: number | null
          DuLieuCu?: Json | null
          DuLieuMoi?: Json | null
          HanhDong?: string
          IPAddress?: string | null
          LyDo?: string | null
          NhatKyID?: number
          TaiKhoanID?: number | null
          ThoiGian?: string
          UserAgent?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "NhatKyHeThong_TaiKhoanID_fkey"
            columns: ["TaiKhoanID"]
            isOneToOne: false
            referencedRelation: "taikhoan"
            referencedColumns: ["taikhoanid"]
          },
          {
            foreignKeyName: "NhatKyHeThong_TaiKhoanID_fkey"
            columns: ["TaiKhoanID"]
            isOneToOne: false
            referencedRelation: "TaiKhoan"
            referencedColumns: ["TaiKhoanID"]
          },
        ]
      }
      Quyen: {
        Row: {
          MaQuyen: string
          MoTa: string | null
          QuyenID: number
          TenQuyen: string
          TrangThai: string
        }
        Insert: {
          MaQuyen: string
          MoTa?: string | null
          QuyenID?: number
          TenQuyen: string
          TrangThai?: string
        }
        Update: {
          MaQuyen?: string
          MoTa?: string | null
          QuyenID?: number
          TenQuyen?: string
          TrangThai?: string
        }
        Relationships: []
      }
      sessions: {
        Row: {
          id: string
          ip_address: string | null
          last_activity: number
          payload: string
          user_agent: string | null
          user_id: number | null
        }
        Insert: {
          id: string
          ip_address?: string | null
          last_activity: number
          payload: string
          user_agent?: string | null
          user_id?: number | null
        }
        Update: {
          id?: string
          ip_address?: string | null
          last_activity?: number
          payload?: string
          user_agent?: string | null
          user_id?: number | null
        }
        Relationships: []
      }
      TaiKhoan: {
        Row: {
          Email: string | null
          KhachHangID: number | null
          MatKhau: string | null
          NgayTao: string
          NhanVienID: number | null
          SoDienThoai: string | null
          TaiKhoanID: number
          TenDangNhap: string
          TrangThai: string
          UserAuthId: string | null
        }
        Insert: {
          Email?: string | null
          KhachHangID?: number | null
          MatKhau?: string | null
          NgayTao?: string
          NhanVienID?: number | null
          SoDienThoai?: string | null
          TaiKhoanID?: number
          TenDangNhap: string
          TrangThai?: string
          UserAuthId?: string | null
        }
        Update: {
          Email?: string | null
          KhachHangID?: number | null
          MatKhau?: string | null
          NgayTao?: string
          NhanVienID?: number | null
          SoDienThoai?: string | null
          TaiKhoanID?: number
          TenDangNhap?: string
          TrangThai?: string
          UserAuthId?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "TaiKhoan_KhachHangID_fkey"
            columns: ["KhachHangID"]
            isOneToOne: false
            referencedRelation: "khachhang"
            referencedColumns: ["khachhangid"]
          },
          {
            foreignKeyName: "TaiKhoan_KhachHangID_fkey"
            columns: ["KhachHangID"]
            isOneToOne: false
            referencedRelation: "KhachHang"
            referencedColumns: ["KhachHangID"]
          },
          {
            foreignKeyName: "TaiKhoan_NhanVienID_fkey"
            columns: ["NhanVienID"]
            isOneToOne: false
            referencedRelation: "nhanvien"
            referencedColumns: ["nhanvienid"]
          },
          {
            foreignKeyName: "TaiKhoan_NhanVienID_fkey"
            columns: ["NhanVienID"]
            isOneToOne: false
            referencedRelation: "NhanVien"
            referencedColumns: ["NhanVienID"]
          },
        ]
      }
      TaiKhoan_VaiTro: {
        Row: {
          TaiKhoanID: number
          VaiTroID: number
        }
        Insert: {
          TaiKhoanID: number
          VaiTroID: number
        }
        Update: {
          TaiKhoanID?: number
          VaiTroID?: number
        }
        Relationships: [
          {
            foreignKeyName: "TaiKhoan_VaiTro_TaiKhoanID_fkey"
            columns: ["TaiKhoanID"]
            isOneToOne: false
            referencedRelation: "taikhoan"
            referencedColumns: ["taikhoanid"]
          },
          {
            foreignKeyName: "TaiKhoan_VaiTro_TaiKhoanID_fkey"
            columns: ["TaiKhoanID"]
            isOneToOne: false
            referencedRelation: "TaiKhoan"
            referencedColumns: ["TaiKhoanID"]
          },
          {
            foreignKeyName: "TaiKhoan_VaiTro_VaiTroID_fkey"
            columns: ["VaiTroID"]
            isOneToOne: false
            referencedRelation: "vaitro"
            referencedColumns: ["vaitroid"]
          },
          {
            foreignKeyName: "TaiKhoan_VaiTro_VaiTroID_fkey"
            columns: ["VaiTroID"]
            isOneToOne: false
            referencedRelation: "VaiTro"
            referencedColumns: ["VaiTroID"]
          },
        ]
      }
      ThanhToan: {
        Row: {
          DonHangID: number
          GhiChu: string | null
          MaGiaoDich: string | null
          PhuongThuc: string
          SoTien: number
          ThanhToanID: number
          ThoiGian: string
          TrangThai: string
        }
        Insert: {
          DonHangID: number
          GhiChu?: string | null
          MaGiaoDich?: string | null
          PhuongThuc: string
          SoTien: number
          ThanhToanID?: number
          ThoiGian?: string
          TrangThai?: string
        }
        Update: {
          DonHangID?: number
          GhiChu?: string | null
          MaGiaoDich?: string | null
          PhuongThuc?: string
          SoTien?: number
          ThanhToanID?: number
          ThoiGian?: string
          TrangThai?: string
        }
        Relationships: [
          {
            foreignKeyName: "ThanhToan_DonHangID_fkey"
            columns: ["DonHangID"]
            isOneToOne: false
            referencedRelation: "DonHang"
            referencedColumns: ["DonHangID"]
          },
        ]
      }
      ThongBao: {
        Row: {
          DaDoc: boolean
          DonHangID: number | null
          LoaiThongBao: string | null
          NoiDung: string
          TaiKhoanID: number
          ThoiGianGui: string
          ThongBaoID: number
          TieuDe: string
        }
        Insert: {
          DaDoc?: boolean
          DonHangID?: number | null
          LoaiThongBao?: string | null
          NoiDung: string
          TaiKhoanID: number
          ThoiGianGui?: string
          ThongBaoID?: number
          TieuDe: string
        }
        Update: {
          DaDoc?: boolean
          DonHangID?: number | null
          LoaiThongBao?: string | null
          NoiDung?: string
          TaiKhoanID?: number
          ThoiGianGui?: string
          ThongBaoID?: number
          TieuDe?: string
        }
        Relationships: [
          {
            foreignKeyName: "ThongBao_DonHangID_fkey"
            columns: ["DonHangID"]
            isOneToOne: false
            referencedRelation: "DonHang"
            referencedColumns: ["DonHangID"]
          },
          {
            foreignKeyName: "ThongBao_TaiKhoanID_fkey"
            columns: ["TaiKhoanID"]
            isOneToOne: false
            referencedRelation: "taikhoan"
            referencedColumns: ["taikhoanid"]
          },
          {
            foreignKeyName: "ThongBao_TaiKhoanID_fkey"
            columns: ["TaiKhoanID"]
            isOneToOne: false
            referencedRelation: "TaiKhoan"
            referencedColumns: ["TaiKhoanID"]
          },
        ]
      }
      TinNhan: {
        Row: {
          DonHangID: number | null
          NguoiGuiID: number
          NguoiNhanID: number
          NoiDung: string
          ThoiGianGui: string
          TinNhanID: number
          TrangThai: string
        }
        Insert: {
          DonHangID?: number | null
          NguoiGuiID: number
          NguoiNhanID: number
          NoiDung: string
          ThoiGianGui?: string
          TinNhanID?: number
          TrangThai?: string
        }
        Update: {
          DonHangID?: number | null
          NguoiGuiID?: number
          NguoiNhanID?: number
          NoiDung?: string
          ThoiGianGui?: string
          TinNhanID?: number
          TrangThai?: string
        }
        Relationships: [
          {
            foreignKeyName: "TinNhan_DonHangID_fkey"
            columns: ["DonHangID"]
            isOneToOne: false
            referencedRelation: "DonHang"
            referencedColumns: ["DonHangID"]
          },
          {
            foreignKeyName: "TinNhan_NguoiGuiID_fkey"
            columns: ["NguoiGuiID"]
            isOneToOne: false
            referencedRelation: "taikhoan"
            referencedColumns: ["taikhoanid"]
          },
          {
            foreignKeyName: "TinNhan_NguoiGuiID_fkey"
            columns: ["NguoiGuiID"]
            isOneToOne: false
            referencedRelation: "TaiKhoan"
            referencedColumns: ["TaiKhoanID"]
          },
          {
            foreignKeyName: "TinNhan_NguoiNhanID_fkey"
            columns: ["NguoiNhanID"]
            isOneToOne: false
            referencedRelation: "taikhoan"
            referencedColumns: ["taikhoanid"]
          },
          {
            foreignKeyName: "TinNhan_NguoiNhanID_fkey"
            columns: ["NguoiNhanID"]
            isOneToOne: false
            referencedRelation: "TaiKhoan"
            referencedColumns: ["TaiKhoanID"]
          },
        ]
      }
      VaiTro: {
        Row: {
          MoTa: string | null
          TenVaiTro: string
          TrangThai: string
          VaiTroID: number
        }
        Insert: {
          MoTa?: string | null
          TenVaiTro: string
          TrangThai?: string
          VaiTroID?: number
        }
        Update: {
          MoTa?: string | null
          TenVaiTro?: string
          TrangThai?: string
          VaiTroID?: number
        }
        Relationships: []
      }
      VaiTro_Quyen: {
        Row: {
          QuyenID: number
          VaiTroID: number
        }
        Insert: {
          QuyenID: number
          VaiTroID: number
        }
        Update: {
          QuyenID?: number
          VaiTroID?: number
        }
        Relationships: [
          {
            foreignKeyName: "VaiTro_Quyen_QuyenID_fkey"
            columns: ["QuyenID"]
            isOneToOne: false
            referencedRelation: "quyen"
            referencedColumns: ["quyenid"]
          },
          {
            foreignKeyName: "VaiTro_Quyen_QuyenID_fkey"
            columns: ["QuyenID"]
            isOneToOne: false
            referencedRelation: "Quyen"
            referencedColumns: ["QuyenID"]
          },
          {
            foreignKeyName: "VaiTro_Quyen_VaiTroID_fkey"
            columns: ["VaiTroID"]
            isOneToOne: false
            referencedRelation: "vaitro"
            referencedColumns: ["vaitroid"]
          },
          {
            foreignKeyName: "VaiTro_Quyen_VaiTroID_fkey"
            columns: ["VaiTroID"]
            isOneToOne: false
            referencedRelation: "VaiTro"
            referencedColumns: ["VaiTroID"]
          },
        ]
      }
    }
    Views: {
      banggia: {
        Row: {
          banggiaid: number | null
          dichvuid: number | null
          dongia: number | null
          donvitinhid: number | null
          loaidogiatid: number | null
          ngayapdung: string | null
          ngayketthuc: string | null
          trangthai: string | null
        }
        Insert: {
          banggiaid?: number | null
          dichvuid?: number | null
          dongia?: number | null
          donvitinhid?: number | null
          loaidogiatid?: number | null
          ngayapdung?: string | null
          ngayketthuc?: string | null
          trangthai?: string | null
        }
        Update: {
          banggiaid?: number | null
          dichvuid?: number | null
          dongia?: number | null
          donvitinhid?: number | null
          loaidogiatid?: number | null
          ngayapdung?: string | null
          ngayketthuc?: string | null
          trangthai?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "BangGia_DichVuID_fkey"
            columns: ["dichvuid"]
            isOneToOne: false
            referencedRelation: "dichvu"
            referencedColumns: ["dichvuid"]
          },
          {
            foreignKeyName: "BangGia_DichVuID_fkey"
            columns: ["dichvuid"]
            isOneToOne: false
            referencedRelation: "DichVu"
            referencedColumns: ["DichVuID"]
          },
          {
            foreignKeyName: "BangGia_DonViTinhID_fkey"
            columns: ["donvitinhid"]
            isOneToOne: false
            referencedRelation: "donvitinh"
            referencedColumns: ["donvitinhid"]
          },
          {
            foreignKeyName: "BangGia_DonViTinhID_fkey"
            columns: ["donvitinhid"]
            isOneToOne: false
            referencedRelation: "DonViTinh"
            referencedColumns: ["DonViTinhID"]
          },
          {
            foreignKeyName: "BangGia_LoaiDoGiatID_fkey"
            columns: ["loaidogiatid"]
            isOneToOne: false
            referencedRelation: "loaidogiat"
            referencedColumns: ["loaidogiatid"]
          },
          {
            foreignKeyName: "BangGia_LoaiDoGiatID_fkey"
            columns: ["loaidogiatid"]
            isOneToOne: false
            referencedRelation: "LoaiDoGiat"
            referencedColumns: ["LoaiDoGiatID"]
          },
        ]
      }
      danhgia: {
        Row: {
          binhluan: string | null
          danhgiaid: number | null
          donhangid: number | null
          khachhangid: number | null
          ngaydanhgia: string | null
          sosao: number | null
          trangthai: string | null
        }
        Insert: {
          binhluan?: string | null
          danhgiaid?: number | null
          donhangid?: number | null
          khachhangid?: number | null
          ngaydanhgia?: string | null
          sosao?: number | null
          trangthai?: string | null
        }
        Update: {
          binhluan?: string | null
          danhgiaid?: number | null
          donhangid?: number | null
          khachhangid?: number | null
          ngaydanhgia?: string | null
          sosao?: number | null
          trangthai?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "DanhGia_DonHangID_fkey"
            columns: ["donhangid"]
            isOneToOne: true
            referencedRelation: "DonHang"
            referencedColumns: ["DonHangID"]
          },
          {
            foreignKeyName: "DanhGia_KhachHangID_fkey"
            columns: ["khachhangid"]
            isOneToOne: false
            referencedRelation: "khachhang"
            referencedColumns: ["khachhangid"]
          },
          {
            foreignKeyName: "DanhGia_KhachHangID_fkey"
            columns: ["khachhangid"]
            isOneToOne: false
            referencedRelation: "KhachHang"
            referencedColumns: ["KhachHangID"]
          },
        ]
      }
      dichvu: {
        Row: {
          dichvuid: number | null
          loaidichvuid: number | null
          mota: string | null
          ngaytao: string | null
          tendichvu: string | null
          thoigiandukien: number | null
          trangthai: string | null
        }
        Insert: {
          dichvuid?: number | null
          loaidichvuid?: number | null
          mota?: string | null
          ngaytao?: string | null
          tendichvu?: string | null
          thoigiandukien?: number | null
          trangthai?: string | null
        }
        Update: {
          dichvuid?: number | null
          loaidichvuid?: number | null
          mota?: string | null
          ngaytao?: string | null
          tendichvu?: string | null
          thoigiandukien?: number | null
          trangthai?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "DichVu_LoaiDichVuID_fkey"
            columns: ["loaidichvuid"]
            isOneToOne: false
            referencedRelation: "loaidichvu"
            referencedColumns: ["loaidichvuid"]
          },
          {
            foreignKeyName: "DichVu_LoaiDichVuID_fkey"
            columns: ["loaidichvuid"]
            isOneToOne: false
            referencedRelation: "LoaiDichVu"
            referencedColumns: ["LoaiDichVuID"]
          },
        ]
      }
      donvitinh: {
        Row: {
          donvitinhid: number | null
          kyhieu: string | null
          tendonvitinh: string | null
          trangthai: string | null
        }
        Insert: {
          donvitinhid?: number | null
          kyhieu?: string | null
          tendonvitinh?: string | null
          trangthai?: string | null
        }
        Update: {
          donvitinhid?: number | null
          kyhieu?: string | null
          tendonvitinh?: string | null
          trangthai?: string | null
        }
        Relationships: []
      }
      hoadon: {
        Row: {
          donhangid: number | null
          giamgia: number | null
          hoadonid: number | null
          mahoadon: string | null
          ngaylap: string | null
          phigiaohang: number | null
          thanhtien: number | null
          tongtien: number | null
          trangthai: string | null
        }
        Insert: {
          donhangid?: number | null
          giamgia?: number | null
          hoadonid?: number | null
          mahoadon?: string | null
          ngaylap?: string | null
          phigiaohang?: number | null
          thanhtien?: number | null
          tongtien?: number | null
          trangthai?: string | null
        }
        Update: {
          donhangid?: number | null
          giamgia?: number | null
          hoadonid?: number | null
          mahoadon?: string | null
          ngaylap?: string | null
          phigiaohang?: number | null
          thanhtien?: number | null
          tongtien?: number | null
          trangthai?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "HoaDon_DonHangID_fkey"
            columns: ["donhangid"]
            isOneToOne: true
            referencedRelation: "DonHang"
            referencedColumns: ["DonHangID"]
          },
        ]
      }
      khachhang: {
        Row: {
          diachi: string | null
          email: string | null
          hoten: string | null
          khachhangid: number | null
          ngaytao: string | null
          sodienthoai: string | null
          trangthai: string | null
        }
        Insert: {
          diachi?: string | null
          email?: string | null
          hoten?: string | null
          khachhangid?: number | null
          ngaytao?: string | null
          sodienthoai?: string | null
          trangthai?: string | null
        }
        Update: {
          diachi?: string | null
          email?: string | null
          hoten?: string | null
          khachhangid?: number | null
          ngaytao?: string | null
          sodienthoai?: string | null
          trangthai?: string | null
        }
        Relationships: []
      }
      lichsuthaydoihoadon: {
        Row: {
          giatricu: string | null
          giatrimoi: string | null
          hoadonid: number | null
          lichsuid: number | null
          lydo: string | null
          taikhoanid: number | null
          thoigian: string | null
          truongthaydoi: string | null
        }
        Insert: {
          giatricu?: string | null
          giatrimoi?: string | null
          hoadonid?: number | null
          lichsuid?: number | null
          lydo?: string | null
          taikhoanid?: number | null
          thoigian?: string | null
          truongthaydoi?: string | null
        }
        Update: {
          giatricu?: string | null
          giatrimoi?: string | null
          hoadonid?: number | null
          lichsuid?: number | null
          lydo?: string | null
          taikhoanid?: number | null
          thoigian?: string | null
          truongthaydoi?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "LichSuThayDoiHoaDon_HoaDonID_fkey"
            columns: ["hoadonid"]
            isOneToOne: false
            referencedRelation: "hoadon"
            referencedColumns: ["hoadonid"]
          },
          {
            foreignKeyName: "LichSuThayDoiHoaDon_HoaDonID_fkey"
            columns: ["hoadonid"]
            isOneToOne: false
            referencedRelation: "HoaDon"
            referencedColumns: ["HoaDonID"]
          },
          {
            foreignKeyName: "LichSuThayDoiHoaDon_TaiKhoanID_fkey"
            columns: ["taikhoanid"]
            isOneToOne: false
            referencedRelation: "taikhoan"
            referencedColumns: ["taikhoanid"]
          },
          {
            foreignKeyName: "LichSuThayDoiHoaDon_TaiKhoanID_fkey"
            columns: ["taikhoanid"]
            isOneToOne: false
            referencedRelation: "TaiKhoan"
            referencedColumns: ["TaiKhoanID"]
          },
        ]
      }
      loaidichvu: {
        Row: {
          loaidichvuid: number | null
          mota: string | null
          tenloaidichvu: string | null
          trangthai: string | null
        }
        Insert: {
          loaidichvuid?: number | null
          mota?: string | null
          tenloaidichvu?: string | null
          trangthai?: string | null
        }
        Update: {
          loaidichvuid?: number | null
          mota?: string | null
          tenloaidichvu?: string | null
          trangthai?: string | null
        }
        Relationships: []
      }
      loaidogiat: {
        Row: {
          loaidogiatid: number | null
          mota: string | null
          tenloaidogiat: string | null
          trangthai: string | null
        }
        Insert: {
          loaidogiatid?: number | null
          mota?: string | null
          tenloaidogiat?: string | null
          trangthai?: string | null
        }
        Update: {
          loaidogiatid?: number | null
          mota?: string | null
          tenloaidogiat?: string | null
          trangthai?: string | null
        }
        Relationships: []
      }
      nhanvien: {
        Row: {
          chucdanh: string | null
          diachi: string | null
          email: string | null
          hoten: string | null
          ngayvaolam: string | null
          nhanvienid: number | null
          sodienthoai: string | null
          trangthai: string | null
        }
        Insert: {
          chucdanh?: string | null
          diachi?: string | null
          email?: string | null
          hoten?: string | null
          ngayvaolam?: string | null
          nhanvienid?: number | null
          sodienthoai?: string | null
          trangthai?: string | null
        }
        Update: {
          chucdanh?: string | null
          diachi?: string | null
          email?: string | null
          hoten?: string | null
          ngayvaolam?: string | null
          nhanvienid?: number | null
          sodienthoai?: string | null
          trangthai?: string | null
        }
        Relationships: []
      }
      quyen: {
        Row: {
          maquyen: string | null
          mota: string | null
          quyenid: number | null
          tenquyen: string | null
          trangthai: string | null
        }
        Insert: {
          maquyen?: string | null
          mota?: string | null
          quyenid?: number | null
          tenquyen?: string | null
          trangthai?: string | null
        }
        Update: {
          maquyen?: string | null
          mota?: string | null
          quyenid?: number | null
          tenquyen?: string | null
          trangthai?: string | null
        }
        Relationships: []
      }
      taikhoan: {
        Row: {
          email: string | null
          khachhangid: number | null
          matkhau: string | null
          ngaytao: string | null
          nhanvienid: number | null
          sodienthoai: string | null
          taikhoanid: number | null
          tendangnhap: string | null
          trangthai: string | null
          userauthid: string | null
        }
        Insert: {
          email?: string | null
          khachhangid?: number | null
          matkhau?: string | null
          ngaytao?: string | null
          nhanvienid?: number | null
          sodienthoai?: string | null
          taikhoanid?: number | null
          tendangnhap?: string | null
          trangthai?: string | null
          userauthid?: string | null
        }
        Update: {
          email?: string | null
          khachhangid?: number | null
          matkhau?: string | null
          ngaytao?: string | null
          nhanvienid?: number | null
          sodienthoai?: string | null
          taikhoanid?: number | null
          tendangnhap?: string | null
          trangthai?: string | null
          userauthid?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "TaiKhoan_KhachHangID_fkey"
            columns: ["khachhangid"]
            isOneToOne: false
            referencedRelation: "khachhang"
            referencedColumns: ["khachhangid"]
          },
          {
            foreignKeyName: "TaiKhoan_KhachHangID_fkey"
            columns: ["khachhangid"]
            isOneToOne: false
            referencedRelation: "KhachHang"
            referencedColumns: ["KhachHangID"]
          },
          {
            foreignKeyName: "TaiKhoan_NhanVienID_fkey"
            columns: ["nhanvienid"]
            isOneToOne: false
            referencedRelation: "nhanvien"
            referencedColumns: ["nhanvienid"]
          },
          {
            foreignKeyName: "TaiKhoan_NhanVienID_fkey"
            columns: ["nhanvienid"]
            isOneToOne: false
            referencedRelation: "NhanVien"
            referencedColumns: ["NhanVienID"]
          },
        ]
      }
      taikhoan_vaitro: {
        Row: {
          taikhoanid: number | null
          vaitroid: number | null
        }
        Insert: {
          taikhoanid?: number | null
          vaitroid?: number | null
        }
        Update: {
          taikhoanid?: number | null
          vaitroid?: number | null
        }
        Relationships: [
          {
            foreignKeyName: "TaiKhoan_VaiTro_TaiKhoanID_fkey"
            columns: ["taikhoanid"]
            isOneToOne: false
            referencedRelation: "taikhoan"
            referencedColumns: ["taikhoanid"]
          },
          {
            foreignKeyName: "TaiKhoan_VaiTro_TaiKhoanID_fkey"
            columns: ["taikhoanid"]
            isOneToOne: false
            referencedRelation: "TaiKhoan"
            referencedColumns: ["TaiKhoanID"]
          },
          {
            foreignKeyName: "TaiKhoan_VaiTro_VaiTroID_fkey"
            columns: ["vaitroid"]
            isOneToOne: false
            referencedRelation: "vaitro"
            referencedColumns: ["vaitroid"]
          },
          {
            foreignKeyName: "TaiKhoan_VaiTro_VaiTroID_fkey"
            columns: ["vaitroid"]
            isOneToOne: false
            referencedRelation: "VaiTro"
            referencedColumns: ["VaiTroID"]
          },
        ]
      }
      thanhtoan: {
        Row: {
          donhangid: number | null
          ghichu: string | null
          magiaodich: string | null
          phuongthuc: string | null
          sotien: number | null
          thanhtoanid: number | null
          thoigian: string | null
          trangthai: string | null
        }
        Insert: {
          donhangid?: number | null
          ghichu?: string | null
          magiaodich?: string | null
          phuongthuc?: string | null
          sotien?: number | null
          thanhtoanid?: number | null
          thoigian?: string | null
          trangthai?: string | null
        }
        Update: {
          donhangid?: number | null
          ghichu?: string | null
          magiaodich?: string | null
          phuongthuc?: string | null
          sotien?: number | null
          thanhtoanid?: number | null
          thoigian?: string | null
          trangthai?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "ThanhToan_DonHangID_fkey"
            columns: ["donhangid"]
            isOneToOne: false
            referencedRelation: "DonHang"
            referencedColumns: ["DonHangID"]
          },
        ]
      }
      thongbao: {
        Row: {
          dadoc: boolean | null
          donhangid: number | null
          loaithongbao: string | null
          noidung: string | null
          taikhoanid: number | null
          thoigiangui: string | null
          thongbaoid: number | null
          tieude: string | null
        }
        Insert: {
          dadoc?: boolean | null
          donhangid?: number | null
          loaithongbao?: string | null
          noidung?: string | null
          taikhoanid?: number | null
          thoigiangui?: string | null
          thongbaoid?: number | null
          tieude?: string | null
        }
        Update: {
          dadoc?: boolean | null
          donhangid?: number | null
          loaithongbao?: string | null
          noidung?: string | null
          taikhoanid?: number | null
          thoigiangui?: string | null
          thongbaoid?: number | null
          tieude?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "ThongBao_DonHangID_fkey"
            columns: ["donhangid"]
            isOneToOne: false
            referencedRelation: "DonHang"
            referencedColumns: ["DonHangID"]
          },
          {
            foreignKeyName: "ThongBao_TaiKhoanID_fkey"
            columns: ["taikhoanid"]
            isOneToOne: false
            referencedRelation: "taikhoan"
            referencedColumns: ["taikhoanid"]
          },
          {
            foreignKeyName: "ThongBao_TaiKhoanID_fkey"
            columns: ["taikhoanid"]
            isOneToOne: false
            referencedRelation: "TaiKhoan"
            referencedColumns: ["TaiKhoanID"]
          },
        ]
      }
      tinnhan: {
        Row: {
          donhangid: number | null
          nguoiguiid: number | null
          nguoinhanid: number | null
          noidung: string | null
          thoigiangui: string | null
          tinnhanid: number | null
          trangthai: string | null
        }
        Insert: {
          donhangid?: number | null
          nguoiguiid?: number | null
          nguoinhanid?: number | null
          noidung?: string | null
          thoigiangui?: string | null
          tinnhanid?: number | null
          trangthai?: string | null
        }
        Update: {
          donhangid?: number | null
          nguoiguiid?: number | null
          nguoinhanid?: number | null
          noidung?: string | null
          thoigiangui?: string | null
          tinnhanid?: number | null
          trangthai?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "TinNhan_DonHangID_fkey"
            columns: ["donhangid"]
            isOneToOne: false
            referencedRelation: "DonHang"
            referencedColumns: ["DonHangID"]
          },
          {
            foreignKeyName: "TinNhan_NguoiGuiID_fkey"
            columns: ["nguoiguiid"]
            isOneToOne: false
            referencedRelation: "taikhoan"
            referencedColumns: ["taikhoanid"]
          },
          {
            foreignKeyName: "TinNhan_NguoiGuiID_fkey"
            columns: ["nguoiguiid"]
            isOneToOne: false
            referencedRelation: "TaiKhoan"
            referencedColumns: ["TaiKhoanID"]
          },
          {
            foreignKeyName: "TinNhan_NguoiNhanID_fkey"
            columns: ["nguoinhanid"]
            isOneToOne: false
            referencedRelation: "taikhoan"
            referencedColumns: ["taikhoanid"]
          },
          {
            foreignKeyName: "TinNhan_NguoiNhanID_fkey"
            columns: ["nguoinhanid"]
            isOneToOne: false
            referencedRelation: "TaiKhoan"
            referencedColumns: ["TaiKhoanID"]
          },
        ]
      }
      vaitro: {
        Row: {
          mota: string | null
          tenvaitro: string | null
          trangthai: string | null
          vaitroid: number | null
        }
        Insert: {
          mota?: string | null
          tenvaitro?: string | null
          trangthai?: string | null
          vaitroid?: number | null
        }
        Update: {
          mota?: string | null
          tenvaitro?: string | null
          trangthai?: string | null
          vaitroid?: number | null
        }
        Relationships: []
      }
      vaitro_quyen: {
        Row: {
          quyenid: number | null
          vaitroid: number | null
        }
        Insert: {
          quyenid?: number | null
          vaitroid?: number | null
        }
        Update: {
          quyenid?: number | null
          vaitroid?: number | null
        }
        Relationships: [
          {
            foreignKeyName: "VaiTro_Quyen_QuyenID_fkey"
            columns: ["quyenid"]
            isOneToOne: false
            referencedRelation: "quyen"
            referencedColumns: ["quyenid"]
          },
          {
            foreignKeyName: "VaiTro_Quyen_QuyenID_fkey"
            columns: ["quyenid"]
            isOneToOne: false
            referencedRelation: "Quyen"
            referencedColumns: ["QuyenID"]
          },
          {
            foreignKeyName: "VaiTro_Quyen_VaiTroID_fkey"
            columns: ["vaitroid"]
            isOneToOne: false
            referencedRelation: "vaitro"
            referencedColumns: ["vaitroid"]
          },
          {
            foreignKeyName: "VaiTro_Quyen_VaiTroID_fkey"
            columns: ["vaitroid"]
            isOneToOne: false
            referencedRelation: "VaiTro"
            referencedColumns: ["VaiTroID"]
          },
        ]
      }
    }
    Functions: {
      cancel_laundry_booking: {
        Args: { p_bookingid: number }
        Returns: undefined
      }
      complete_customer_profile: {
        Args: { p_full_name?: string }
        Returns: undefined
      }
      complete_google_customer_profile: {
        Args: { p_full_name?: string }
        Returns: undefined
      }
      confirm_laundry_booking: { Args: { p_bookingid: number }; Returns: Json }
      confirm_order_payment: {
        Args: { p_ghichu?: string; p_success: boolean; p_thanhtoanid: number }
        Returns: undefined
      }
      get_current_roles: { Args: never; Returns: string[] }
      get_customer_loyalty: { Args: never; Returns: Json }
      request_order_payment: {
        Args: {
          p_donhangid: number
          p_idempotency_key: string
          p_phuongthuc: string
        }
        Returns: Json
      }
      save_customer_address: {
        Args: {
          p_diachi: string
          p_diachiid: number
          p_ghichu: string
          p_macdinh: boolean
          p_sodienthoai: string
          p_tennguoinhan: string
        }
        Returns: number
      }
      submit_laundry_order: {
        Args: {
          p_banggiaid: number
          p_diachinhan: string
          p_ghichu: string
          p_giohen: string
          p_hinhthucnhando: string
          p_idempotency_key: string
          p_measurement: number
          p_ngayhen: string
        }
        Returns: Json
      }
      submit_laundry_order_cart: {
        Args: {
          p_diachinhan: string
          p_ghichu: string
          p_giohen: string
          p_hinhthucnhando: string
          p_idempotency_key: string
          p_items: Json
          p_ngayhen: string
        }
        Returns: Json
      }
      transition_laundry_order: {
        Args: { p_donhangid: number; p_lydo?: string; p_trangthaimoi: string }
        Returns: undefined
      }
    }
    Enums: {
      [_ in never]: never
    }
    CompositeTypes: {
      [_ in never]: never
    }
  }
}

type DatabaseWithoutInternals = Omit<Database, "__InternalSupabase">

type DefaultSchema = DatabaseWithoutInternals[Extract<keyof Database, "public">]

export type Tables<
  DefaultSchemaTableNameOrOptions extends
    | keyof (DefaultSchema["Tables"] & DefaultSchema["Views"])
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends (DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof (DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"] &
        DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Views"])
    : never) = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? (DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"] &
      DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Views"])[TableName] extends {
      Row: infer R
    }
    ? R
    : never
  : DefaultSchemaTableNameOrOptions extends keyof (DefaultSchema["Tables"] &
        DefaultSchema["Views"])
    ? (DefaultSchema["Tables"] &
        DefaultSchema["Views"])[DefaultSchemaTableNameOrOptions] extends {
        Row: infer R
      }
      ? R
      : never
    : never

export type TablesInsert<
  DefaultSchemaTableNameOrOptions extends
    | keyof DefaultSchema["Tables"]
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends (DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"]
    : never) = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"][TableName] extends {
      Insert: infer I
    }
    ? I
    : never
  : DefaultSchemaTableNameOrOptions extends keyof DefaultSchema["Tables"]
    ? DefaultSchema["Tables"][DefaultSchemaTableNameOrOptions] extends {
        Insert: infer I
      }
      ? I
      : never
    : never

export type TablesUpdate<
  DefaultSchemaTableNameOrOptions extends
    | keyof DefaultSchema["Tables"]
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends (DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"]
    : never) = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"][TableName] extends {
      Update: infer U
    }
    ? U
    : never
  : DefaultSchemaTableNameOrOptions extends keyof DefaultSchema["Tables"]
    ? DefaultSchema["Tables"][DefaultSchemaTableNameOrOptions] extends {
        Update: infer U
      }
      ? U
      : never
    : never

export type Enums<
  DefaultSchemaEnumNameOrOptions extends
    | keyof DefaultSchema["Enums"]
    | { schema: keyof DatabaseWithoutInternals },
  EnumName extends (DefaultSchemaEnumNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaEnumNameOrOptions["schema"]]["Enums"]
    : never) = never,
> = DefaultSchemaEnumNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaEnumNameOrOptions["schema"]]["Enums"][EnumName]
  : DefaultSchemaEnumNameOrOptions extends keyof DefaultSchema["Enums"]
    ? DefaultSchema["Enums"][DefaultSchemaEnumNameOrOptions]
    : never

export type CompositeTypes<
  PublicCompositeTypeNameOrOptions extends
    | keyof DefaultSchema["CompositeTypes"]
    | { schema: keyof DatabaseWithoutInternals },
  CompositeTypeName extends (PublicCompositeTypeNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[PublicCompositeTypeNameOrOptions["schema"]]["CompositeTypes"]
    : never) = never,
> = PublicCompositeTypeNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[PublicCompositeTypeNameOrOptions["schema"]]["CompositeTypes"][CompositeTypeName]
  : PublicCompositeTypeNameOrOptions extends keyof DefaultSchema["CompositeTypes"]
    ? DefaultSchema["CompositeTypes"][PublicCompositeTypeNameOrOptions]
    : never

export const Constants = {
  graphql_public: {
    Enums: {},
  },
  public: {
    Enums: {},
  },
} as const
