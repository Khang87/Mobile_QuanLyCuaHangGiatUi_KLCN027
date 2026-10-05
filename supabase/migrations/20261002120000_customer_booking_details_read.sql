DROP POLICY IF EXISTS laundry_compat_booking_detail_read
  ON public."ChiTietBooking";

CREATE POLICY laundry_compat_booking_detail_read
  ON public."ChiTietBooking"
  FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1
      FROM public."Booking" AS booking
      WHERE booking."BookingID" = "ChiTietBooking"."BookingID"
        AND (
          booking."KhachHangID" = (SELECT private.current_customer_id())
          OR (SELECT private.is_staff())
        )
    )
  );