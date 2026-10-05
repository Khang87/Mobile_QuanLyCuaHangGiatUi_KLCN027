BEGIN;

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
AS $$
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
  IF customer_id IS NULL THEN
    RAISE EXCEPTION 'Authentication required';
  END IF;

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
          FLOOR(total_amount)
        )::integer;
        points_discount := points_to_use;

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
$$;

COMMIT;