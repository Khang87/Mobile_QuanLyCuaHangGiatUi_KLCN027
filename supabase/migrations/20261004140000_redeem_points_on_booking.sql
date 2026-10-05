BEGIN;

ALTER TABLE public."Booking"
  ADD COLUMN IF NOT EXISTS "DiemSuDung" integer NOT NULL DEFAULT 0,
  ADD COLUMN IF NOT EXISTS "TienGiamDoDiem" numeric(18,2) NOT NULL DEFAULT 0,
  ADD COLUMN IF NOT EXISTS "DiemDaTru" boolean NOT NULL DEFAULT false;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint
    WHERE conname = 'Booking_DiemSuDung_check'
      AND conrelid = 'public."Booking"'::regclass
  ) THEN
    ALTER TABLE public."Booking"
      ADD CONSTRAINT "Booking_DiemSuDung_check"
      CHECK ("DiemSuDung" >= 0);
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint
    WHERE conname = 'Booking_TienGiamDoDiem_check'
      AND conrelid = 'public."Booking"'::regclass
  ) THEN
    ALTER TABLE public."Booking"
      ADD CONSTRAINT "Booking_TienGiamDoDiem_check"
      CHECK ("TienGiamDoDiem" >= 0);
  END IF;
END $$;

CREATE OR REPLACE FUNCTION public.submit_laundry_order_cart_with_points(
  p_items jsonb,
  p_hinhthucnhando text,
  p_diachinhan text,
  p_ngayhen date,
  p_giohen time without time zone,
  p_ghichu text,
  p_idempotency_key uuid,
  p_use_points boolean DEFAULT false
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO ''
AS $function$
DECLARE
  customer_id bigint := (SELECT private.current_customer_id());
  booking_result jsonb;
  booking_id bigint;
  booking_row public."Booking"%ROWTYPE;
  available_points integer := 0;
  points_to_use integer := 0;
  points_discount numeric(18,2) := 0;
  total_amount numeric(18,2) := 0;
  remaining_points integer := 0;
BEGIN
  booking_result := public.submit_laundry_order_cart(
    p_items,
    p_hinhthucnhando,
    p_diachinhan,
    p_ngayhen,
    p_giohen,
    p_ghichu,
    p_idempotency_key
  );
  booking_id := (booking_result->>'bookingid')::bigint;

  SELECT *
  INTO booking_row
  FROM public."Booking"
  WHERE "BookingID" = booking_id
    AND "KhachHangID" = customer_id
  FOR UPDATE;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Booking not found';
  END IF;

  SELECT COALESCE(SUM("ThanhTien"), 0)
  INTO total_amount
  FROM public."ChiTietBooking"
  WHERE "BookingID" = booking_id;

  IF NOT booking_row."DiemDaTru" THEN
    IF COALESCE(p_use_points, false) THEN
      SELECT "DiemHienTai"
      INTO available_points
      FROM public."DiemTichLuy"
      WHERE "KhachHangID" = customer_id
      FOR UPDATE;

      IF FOUND THEN
        points_to_use := LEAST(
          available_points::numeric,
          FLOOR(total_amount / 10)
        )::integer;
        points_discount := points_to_use * 10;

        IF points_to_use > 0 THEN
          UPDATE public."DiemTichLuy"
          SET
            "DiemHienTai" = "DiemHienTai" - points_to_use,
            "NgayCapNhat" = now()
          WHERE "KhachHangID" = customer_id;
        END IF;
      END IF;
    END IF;

    UPDATE public."Booking"
    SET
      "DiemSuDung" = points_to_use,
      "TienGiamDoDiem" = points_discount,
      "DiemDaTru" = true
    WHERE "BookingID" = booking_id;
  END IF;

  SELECT COALESCE("DiemHienTai", 0)
  INTO remaining_points
  FROM public."DiemTichLuy"
  WHERE "KhachHangID" = customer_id;
  remaining_points := COALESCE(remaining_points, 0);

  SELECT *
  INTO booking_row
  FROM public."Booking"
  WHERE "BookingID" = booking_id;

  RETURN booking_result || jsonb_build_object(
    'thanhtien', total_amount,
    'diemsudung', booking_row."DiemSuDung",
    'tiengiamdodiem', booking_row."TienGiamDoDiem",
    'thanhtoan', GREATEST(
      total_amount - booking_row."TienGiamDoDiem",
      0
    ),
    'diemconlai', remaining_points
  );
END;
$function$;

ALTER FUNCTION public.submit_laundry_order_cart_with_points(
  jsonb,
  text,
  text,
  date,
  time without time zone,
  text,
  uuid,
  boolean
) OWNER TO postgres;

REVOKE ALL ON FUNCTION public.submit_laundry_order_cart_with_points(
  jsonb,
  text,
  text,
  date,
  time without time zone,
  text,
  uuid,
  boolean
) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.submit_laundry_order_cart_with_points(
  jsonb,
  text,
  text,
  date,
  time without time zone,
  text,
  uuid,
  boolean
) TO authenticated;

CREATE OR REPLACE FUNCTION private.apply_booking_points_to_order()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO ''
AS $function$
DECLARE
  booking_points integer;
  booking_discount numeric(18,2);
BEGIN
  IF NEW."BookingID" IS NULL THEN
    RETURN NEW;
  END IF;

  SELECT "DiemSuDung", "TienGiamDoDiem"
  INTO booking_points, booking_discount
  FROM public."Booking"
  WHERE "BookingID" = NEW."BookingID";

  IF FOUND THEN
    NEW."DiemSuDung" := booking_points;
    NEW."TienGiamDoDiem" := booking_discount;
    NEW."ThanhTien" := GREATEST(
      NEW."TongTien" + NEW."PhiGiaoHang" -
        NEW."TienGiamDoDiem" - NEW."TienGiamKhuyenMai",
      0
    );
  END IF;

  RETURN NEW;
END;
$function$;

ALTER FUNCTION private.apply_booking_points_to_order() OWNER TO postgres;

DROP TRIGGER IF EXISTS apply_booking_points_to_order
  ON public."DonHang";
CREATE TRIGGER apply_booking_points_to_order
  BEFORE INSERT OR UPDATE ON public."DonHang"
  FOR EACH ROW
  EXECUTE FUNCTION private.apply_booking_points_to_order();

COMMIT;