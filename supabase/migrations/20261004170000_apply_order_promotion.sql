BEGIN;

CREATE OR REPLACE FUNCTION public.apply_order_promotion(
  p_donhangid bigint,
  p_makhuyenmai text
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO ''
AS $$
DECLARE
  customer_id bigint := (SELECT private.current_customer_id());
  promotion public."KhuyenMai"%ROWTYPE;
  order_record public."DonHang"%ROWTYPE;
  discount_amount numeric(18,2);
BEGIN
  IF customer_id IS NULL THEN
    RAISE EXCEPTION 'Authentication required';
  END IF;

  SELECT * INTO order_record
  FROM public."DonHang"
  WHERE "DonHangID" = p_donhangid
    AND "KhachHangID" = customer_id
  FOR UPDATE;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Order not found';
  END IF;
  IF order_record."TrangThai" = 'Đã thanh toán' THEN
    RAISE EXCEPTION 'A paid order cannot be changed';
  END IF;

  SELECT * INTO promotion
  FROM public."KhuyenMai"
  WHERE upper("MaKhuyenMai") = upper(btrim(p_makhuyenmai))
    AND "TrangThai" = 'Hoạt động'
    AND "NgayBatDau" <= current_date
    AND "NgayKetThuc" >= current_date
    AND ("SoLuongSuDung" IS NULL OR "SoLuongSuDung" > 0)
  FOR UPDATE;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Promotion code is invalid or expired';
  END IF;
  IF promotion."GiaTriDonToiThieu" IS NOT NULL
     AND order_record."TongTien" < promotion."GiaTriDonToiThieu" THEN
    RAISE EXCEPTION 'Order does not meet the promotion minimum';
  END IF;

  discount_amount := CASE WHEN promotion."LoaiKhuyenMai" = 'Phần trăm'
    THEN order_record."TongTien" * promotion."GiaTriGiam" / 100
    ELSE promotion."GiaTriGiam"
  END;
  IF promotion."MucGiamToiDa" IS NOT NULL THEN
    discount_amount := least(discount_amount, promotion."MucGiamToiDa");
  END IF;
  discount_amount := greatest(least(discount_amount, order_record."TongTien"), 0);

  UPDATE public."DonHang"
  SET "KhuyenMaiID" = promotion."KhuyenMaiID",
      "TienGiamKhuyenMai" = discount_amount,
      "ThanhTien" = greatest("TongTien" + "PhiGiaoHang" - "TienGiamDoDiem" - discount_amount, 0),
      "NgayCapNhat" = now()
  WHERE "DonHangID" = p_donhangid;

  UPDATE public."HoaDon"
  SET "GiamGia" = order_record."TienGiamDoDiem" + discount_amount,
      "ThanhTien" = greatest(order_record."TongTien" + order_record."PhiGiaoHang" - order_record."TienGiamDoDiem" - discount_amount, 0)
  WHERE "DonHangID" = p_donhangid
    AND "TrangThai" = 'Chưa thanh toán';

  RETURN jsonb_build_object('code', promotion."MaKhuyenMai", 'discount', discount_amount);
END;
$$;

REVOKE ALL ON FUNCTION public.apply_order_promotion(bigint, text) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.apply_order_promotion(bigint, text) TO authenticated;

COMMIT;
