-- =====================================================
-- Function: submit_laundry_order_cart
-- Tạo booking với nhiều items (giỏ hàng)
-- =====================================================

CREATE OR REPLACE FUNCTION public.submit_laundry_order_cart (
  p_items           jsonb,  -- Array of {banggiaid, measurement}
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

    existing_booking record;
    booking_id bigint;
    booking_number text;
    detail_count integer := 0;
    total_amount numeric := 0;
    item jsonb;
    price_row record;
    measurement numeric;
    quantity numeric;
    weight_kg numeric;
    line_total numeric;
    detail_id integer;
    pickup_at timestamptz;

BEGIN

    -- =====================================================
    -- 1. Kiểm tra đăng nhập
    -- =====================================================

    IF customer_id IS NULL THEN

        RAISE EXCEPTION
            'Authentication required';

    END IF;


    -- =====================================================
    -- 2. Kiểm tra idempotency
    -- =====================================================

    SELECT * INTO existing_booking
    FROM public."Booking"
    WHERE "IdempotencyKey" = p_idempotency_key
      AND "KhachHangID" = customer_id;

    IF FOUND THEN

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
    -- 3. Validate items không rỗng
    -- =====================================================

    IF p_items IS NULL OR jsonb_array_length(p_items) = 0 THEN

        RAISE EXCEPTION
            'Cart must contain at least one item';

    END IF;


    -- =====================================================
    -- 4. Tạo booking number
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
    -- 5. Insert Booking
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
    -- 6. Loop qua từng item và insert ChiTietBooking
    -- =====================================================

    FOR item IN SELECT * FROM jsonb_array_elements(p_items)
    LOOP

        -- Lấy thông tin giá
        SELECT
            bg."DonGia",
            bg."DichVuID",
            bg."LoaiDoGiatID",
            bg."DonViTinhID",
            lower(coalesce(dvt."KyHieu", dvt."TenDonViTinh")) AS unit_symbol

        INTO price_row

        FROM public."BangGia" AS bg

        INNER JOIN public."DichVu" AS dv
        ON bg."DichVuID" = dv."DichVuID"

        INNER JOIN public."LoaiDoGiat" AS ldg
        ON bg."LoaiDoGiatID" = ldg."LoaiDoGiatID"

        INNER JOIN public."DonViTinh" AS dvt
        ON bg."DonViTinhID" = dvt."DonViTinhID"

        WHERE bg."BangGiaID" = (item->>'banggiaid')::bigint
          AND bg."TrangThai" = 'Hoạt động'
          AND dv."TrangThai" = 'Hoạt động'
          AND ldg."TrangThai" = 'Hoạt động'
          AND dvt."TrangThai" = 'Hoạt động';


        IF NOT FOUND THEN

            RAISE EXCEPTION
                'Price ID % is no longer available',
                item->>'banggiaid';

        END IF;


        -- Validate measurement
        measurement := (item->>'measurement')::numeric(10,2);

        IF measurement IS NULL
           OR measurement <= 0
           OR measurement > 99999999.99
           OR measurement <> round(measurement, 2) THEN

            RAISE EXCEPTION
                'Invalid measurement for price ID %',
                item->>'banggiaid';

        END IF;


        -- Tính toán
        line_total := round(price_row."DonGia" * measurement, 2);

        IF price_row.unit_symbol IN ('kg', 'kilogram') THEN
            weight_kg := measurement;
            quantity := NULL;
        ELSE
            quantity := measurement;
            weight_kg := NULL;
        END IF;


        -- Insert ChiTietBooking
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

        );


        detail_count := detail_count + 1;
        total_amount := total_amount + line_total;

    END LOOP;


    -- Giao nhận chỉ được tạo sau khi nhân viên xác nhận booking.
    -- Function confirm_laundry_booking đã tạo bản ghi GiaoNhan với DonHangID.

    -- =====================================================
    -- 7. Trả kết quả
    -- =====================================================

    RETURN jsonb_build_object(

        'bookingid',
        booking_id,

        'mabooking',
        booking_number,

        'trangthai',
        'ChoTiepNhan',

        'thanhtien',
        total_amount,

        'itemcount',
        detail_count

    );

END;
$function$;


-- Grant permissions
GRANT EXECUTE ON FUNCTION public.submit_laundry_order_cart TO authenticated;
