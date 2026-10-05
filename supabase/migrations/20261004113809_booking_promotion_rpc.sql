BEGIN;

ALTER TABLE public."Booking"
  ADD COLUMN IF NOT EXISTS "KhuyenMaiID" integer
  REFERENCES public."KhuyenMai"("KhuyenMaiID");

CREATE OR REPLACE FUNCTION public.set_booking_promotion(p_bookingid bigint, p_makhuyenmai text)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO ''
AS $$
DECLARE
  customer_id bigint := (SELECT private.current_customer_id());
  promotion_id integer;
BEGIN
  SELECT "KhuyenMaiID"
  INTO promotion_id
  FROM public."KhuyenMai"
  WHERE upper("MaKhuyenMai") = upper(btrim(p_makhuyenmai))
    AND "TrangThai" = 'Hoạt động'
    AND "NgayBatDau" <= current_date
    AND "NgayKetThuc" >= current_date;

  IF promotion_id IS NULL THEN
    RAISE EXCEPTION 'Promotion code is invalid or expired';
  END IF;

  UPDATE public."Booking"
  SET "KhuyenMaiID" = promotion_id
  WHERE "BookingID" = p_bookingid
    AND "KhachHangID" = customer_id;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Booking not found';
  END IF;
END;
$$;

REVOKE ALL ON FUNCTION public.set_booking_promotion(bigint, text) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.set_booking_promotion(bigint, text) TO authenticated;

CREATE OR REPLACE FUNCTION private.apply_booking_promotion_to_order()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO ''
AS $$
DECLARE
  promotion public."KhuyenMai"%ROWTYPE;
  promotion_id integer;
  discount_amount numeric(18,2);
BEGIN
  IF NEW."BookingID" IS NULL THEN
    RETURN NEW;
  END IF;

  SELECT "KhuyenMaiID"
  INTO promotion_id
  FROM public."Booking"
  WHERE "BookingID" = NEW."BookingID";

  IF promotion_id IS NULL THEN
    RETURN NEW;
  END IF;

  SELECT *
  INTO promotion
  FROM public."KhuyenMai"
  WHERE "KhuyenMaiID" = promotion_id;

  IF NOT FOUND
     OR promotion."TrangThai" <> 'Hoạt động'
     OR promotion."NgayKetThuc" < current_date
     OR (promotion."GiaTriDonToiThieu" IS NOT NULL AND NEW."TongTien" < promotion."GiaTriDonToiThieu") THEN
    RETURN NEW;
  END IF;

  discount_amount := CASE
    WHEN promotion."LoaiKhuyenMai" = 'Phần trăm'
      THEN NEW."TongTien" * promotion."GiaTriGiam" / 100
    ELSE promotion."GiaTriGiam"
  END;

  IF promotion."MucGiamToiDa" IS NOT NULL THEN
    discount_amount := least(discount_amount, promotion."MucGiamToiDa");
  END IF;

  NEW."KhuyenMaiID" := promotion_id;
  NEW."TienGiamKhuyenMai" := greatest(least(discount_amount, NEW."TongTien"), 0);
  NEW."ThanhTien" := greatest(
    NEW."TongTien" + NEW."PhiGiaoHang" - NEW."TienGiamDoDiem" - NEW."TienGiamKhuyenMai",
    0
  );
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS apply_booking_promotion_to_order ON public."DonHang";
CREATE TRIGGER apply_booking_promotion_to_order
  BEFORE INSERT OR UPDATE ON public."DonHang"
  FOR EACH ROW
  EXECUTE FUNCTION private.apply_booking_promotion_to_order();

NOTIFY pgrst, 'reload schema';
COMMIT;