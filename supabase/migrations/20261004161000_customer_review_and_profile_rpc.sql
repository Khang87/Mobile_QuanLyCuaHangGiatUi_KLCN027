BEGIN;

CREATE OR REPLACE FUNCTION public.submit_order_review(
  p_donhangid bigint,
  p_sosao integer,
  p_binhluan text DEFAULT NULL
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO ''
AS $$
DECLARE
  customer_id bigint := (SELECT private.current_customer_id());
  review_id bigint;
BEGIN
  IF customer_id IS NULL THEN
    RAISE EXCEPTION 'Authentication required';
  END IF;

  IF p_sosao < 1 OR p_sosao > 5 THEN
    RAISE EXCEPTION 'Rating must be between 1 and 5';
  END IF;

  IF NOT EXISTS (
    SELECT 1
    FROM public."DonHang" AS order_record
    WHERE order_record."DonHangID" = p_donhangid
      AND order_record."KhachHangID" = customer_id
      AND order_record."TrangThai" IN ('Đã giao', 'Đã thanh toán')
  ) THEN
    RAISE EXCEPTION 'Only completed customer orders can be reviewed';
  END IF;

  INSERT INTO public."DanhGia" (
    "DonHangID", "KhachHangID", "SoSao", "BinhLuan", "NgayDanhGia", "TrangThai"
  ) VALUES (
    p_donhangid::integer,
    customer_id::integer,
    p_sosao,
    nullif(left(btrim(p_binhluan), 1000), ''),
    now(),
    'Hiển thị'
  )
  ON CONFLICT ("DonHangID") DO UPDATE
  SET "SoSao" = EXCLUDED."SoSao",
      "BinhLuan" = EXCLUDED."BinhLuan",
      "NgayDanhGia" = now(),
      "TrangThai" = 'Hiển thị'
  RETURNING "DanhGiaID" INTO review_id;

  RETURN jsonb_build_object('danhgiaid', review_id);
END;
$$;

REVOKE ALL ON FUNCTION public.submit_order_review(bigint, integer, text) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.submit_order_review(bigint, integer, text) TO authenticated;

CREATE OR REPLACE FUNCTION public.update_customer_profile(
  p_full_name text,
  p_email text DEFAULT NULL,
  p_phone text DEFAULT NULL,
  p_address text DEFAULT NULL
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO ''
AS $$
DECLARE
  customer_id bigint := (SELECT private.current_customer_id());
  account_id bigint;
BEGIN
  IF customer_id IS NULL THEN
    RAISE EXCEPTION 'Authentication required';
  END IF;

  IF nullif(btrim(p_full_name), '') IS NULL THEN
    RAISE EXCEPTION 'Full name is required';
  END IF;

  SELECT "TaiKhoanID"
  INTO account_id
  FROM public."TaiKhoan"
  WHERE "KhachHangID" = customer_id
    AND "UserAuthId" = (SELECT auth.uid())
  LIMIT 1;

  UPDATE public."KhachHang"
  SET "HoTen" = left(btrim(p_full_name), 150),
      "Email" = nullif(left(btrim(p_email), 255), ''),
      "SoDienThoai" = nullif(left(btrim(p_phone), 20), ''),
      "DiaChi" = nullif(left(btrim(p_address), 255), '')
  WHERE "KhachHangID" = customer_id;

  UPDATE public."TaiKhoan"
  SET "Email" = nullif(left(btrim(p_email), 255), ''),
      "SoDienThoai" = nullif(left(btrim(p_phone), 20), '')
  WHERE "TaiKhoanID" = account_id;

  RETURN jsonb_build_object('khachhangid', customer_id, 'taikhoanid', account_id);
END;
$$;

REVOKE ALL ON FUNCTION public.update_customer_profile(text, text, text, text) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.update_customer_profile(text, text, text, text) TO authenticated;

COMMIT;
