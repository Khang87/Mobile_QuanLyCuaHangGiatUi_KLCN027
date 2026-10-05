SET local check_function_bodies = off;

DROP POLICY "laundry_compat_review_insert" ON "public"."DanhGia";

ALTER TABLE "public"."BangGia"
  DROP CONSTRAINT "BangGia_TrangThai_check";

ALTER TABLE "public"."Booking"
  DROP CONSTRAINT "Booking_HinhThucNhanDo_check";

ALTER TABLE "public"."Booking"
  DROP CONSTRAINT "booking_trangthai_check";

ALTER TABLE "public"."DanhGia"
  DROP CONSTRAINT "DanhGia_TrangThai_check";

ALTER TABLE "public"."DichVu"
  DROP CONSTRAINT "DichVu_TrangThai_check";

ALTER TABLE "public"."DonHang"
  DROP CONSTRAINT "DonHang_TrangThai_check";

ALTER TABLE "public"."DonViTinh"
  DROP CONSTRAINT "DonViTinh_TrangThai_check";

ALTER TABLE "public"."GiaoNhan"
  DROP CONSTRAINT "GiaoNhan_HinhThuc_check";

ALTER TABLE "public"."GiaoNhan"
  DROP CONSTRAINT "GiaoNhan_LoaiGiaoNhan_check";

ALTER TABLE "public"."GiaoNhan"
  DROP CONSTRAINT "GiaoNhan_TrangThai_check";

ALTER TABLE "public"."HoaDon"
  DROP CONSTRAINT "HoaDon_TrangThai_check";

ALTER TABLE "public"."KhachHang"
  DROP CONSTRAINT "KhachHang_TrangThai_check";

ALTER TABLE "public"."KhuyenMai"
  DROP CONSTRAINT "KhuyenMai_LoaiKhuyenMai_check";

ALTER TABLE "public"."KhuyenMai"
  DROP CONSTRAINT "KhuyenMai_TrangThai_check";

ALTER TABLE "public"."LoaiDichVu"
  DROP CONSTRAINT "LoaiDichVu_TrangThai_check";

ALTER TABLE "public"."LoaiDoGiat"
  DROP CONSTRAINT "LoaiDoGiat_TrangThai_check";

ALTER TABLE "public"."NhanVien"
  DROP CONSTRAINT "NhanVien_TrangThai_check";

ALTER TABLE "public"."Quyen"
  DROP CONSTRAINT "Quyen_TrangThai_check";

ALTER TABLE "public"."TaiKhoan"
  DROP CONSTRAINT "TaiKhoan_TrangThai_check";

ALTER TABLE "public"."ThanhToan"
  DROP CONSTRAINT "ThanhToan_PhuongThuc_check";

ALTER TABLE "public"."ThanhToan"
  DROP CONSTRAINT "ThanhToan_TrangThai_check";

ALTER TABLE "public"."TinNhan"
  DROP CONSTRAINT "TinNhan_TrangThai_check";

ALTER TABLE "public"."VaiTro"
  DROP CONSTRAINT "VaiTro_TrangThai_check";

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

ALTER TABLE "public"."BangGia"
  ADD CONSTRAINT "BangGia_TrangThai_check"
    CHECK ((("TrangThai")::text = ANY ((ARRAY['Hoạt động'::character varying, 'Hết hiệu lực'::character varying, 'Tạm ngưng'::character varying])::text[])));

ALTER TABLE "public"."Booking"
  ADD CONSTRAINT "Booking_HinhThucNhanDo_check" CHECK ((("HinhThucNhanDo")::text = ANY ((ARRAY['Tại cửa hàng'::character varying, 'Tại nhà'::character varying])::text[])));

ALTER TABLE "public"."Booking"
  ADD CONSTRAINT "booking_trangthai_check"
    CHECK
    ((("TrangThai")::text = ANY ((ARRAY['ChoTiepNhan'::character varying, 'DaXacNhan'::character varying, 'DaHuy'::character varying, 'HoanThanh'::character varying])::text[])));

ALTER TABLE "public"."DanhGia"
  ADD CONSTRAINT "DanhGia_TrangThai_check" CHECK ((("TrangThai")::text = ANY ((ARRAY['Hiển thị'::character varying, 'Ẩn'::character varying])::text[])));

ALTER TABLE "public"."DichVu"
  ADD CONSTRAINT "DichVu_TrangThai_check" CHECK ((("TrangThai")::text = ANY ((ARRAY['Hoạt động'::character varying, 'Tạm ngưng'::character varying])::text[])));

ALTER TABLE "public"."DonHang"
  ADD CONSTRAINT "DonHang_TrangThai_check"
    CHECK
    ((("TrangThai")::text = ANY ((ARRAY['Chờ tiếp nhận'::character varying, 'Đã tiếp nhận'::character varying, 'Đang giặt'::character varying, 'Hoàn thành giặt'::character varying,
    'Đang giao'::character varying, 'Đã giao'::character varying, 'Đã thanh toán'::character varying, 'Đã hủy'::character varying])::text[])));

ALTER TABLE "public"."DonViTinh"
  ADD CONSTRAINT "DonViTinh_TrangThai_check" CHECK ((("TrangThai")::text = ANY ((ARRAY['Hoạt động'::character varying, 'Tạm ngưng'::character varying])::text[])));

ALTER TABLE "public"."GiaoNhan"
  ADD CONSTRAINT "GiaoNhan_HinhThuc_check" CHECK ((("HinhThuc")::text = ANY ((ARRAY['Tại cửa hàng'::character varying, 'Tại nhà'::character varying])::text[])));

ALTER TABLE "public"."GiaoNhan"
  ADD CONSTRAINT "GiaoNhan_LoaiGiaoNhan_check" CHECK ((("LoaiGiaoNhan")::text = ANY ((ARRAY['NHAN_DO'::character varying, 'GIAO_DO'::character varying])::text[])));

ALTER TABLE "public"."GiaoNhan"
  ADD CONSTRAINT "GiaoNhan_TrangThai_check"
    CHECK
    ((("TrangThai")::text = ANY ((ARRAY['Chờ thực hiện'::character varying, 'Đang thực hiện'::character varying, 'Hoàn thành'::character varying, 'Đã hủy'::character
    varying])::text[])));

ALTER TABLE "public"."HoaDon"
  ADD CONSTRAINT "HoaDon_TrangThai_check"
    CHECK ((("TrangThai")::text = ANY ((ARRAY['Chưa thanh toán'::character varying, 'Đã thanh toán'::character varying, 'Đã hủy'::character varying])::text[])));

ALTER TABLE "public"."KhachHang"
  ADD CONSTRAINT "KhachHang_TrangThai_check"
    CHECK ((("TrangThai")::text = ANY ((ARRAY['Hoạt động'::character varying, 'Khóa'::character varying, 'Ngừng hoạt động'::character varying])::text[])));

ALTER TABLE "public"."KhuyenMai"
  ADD CONSTRAINT "KhuyenMai_LoaiKhuyenMai_check" CHECK ((("LoaiKhuyenMai")::text = ANY ((ARRAY['Phần trăm'::character varying, 'Tiền mặt'::character varying])::text[])));

ALTER TABLE "public"."KhuyenMai"
  ADD CONSTRAINT "KhuyenMai_TrangThai_check"
    CHECK ((("TrangThai")::text = ANY ((ARRAY['Hoạt động'::character varying, 'Tạm ngưng'::character varying, 'Hết hạn'::character varying])::text[])));

ALTER TABLE "public"."LoaiDichVu"
  ADD CONSTRAINT "LoaiDichVu_TrangThai_check" CHECK ((("TrangThai")::text = ANY ((ARRAY['Hoạt động'::character varying, 'Tạm ngưng'::character varying])::text[])));

ALTER TABLE "public"."LoaiDoGiat"
  ADD CONSTRAINT "LoaiDoGiat_TrangThai_check" CHECK ((("TrangThai")::text = ANY ((ARRAY['Hoạt động'::character varying, 'Tạm ngưng'::character varying])::text[])));

ALTER TABLE "public"."NhanVien"
  ADD CONSTRAINT "NhanVien_TrangThai_check"
    CHECK ((("TrangThai")::text = ANY ((ARRAY['Hoạt động'::character varying, 'Khóa'::character varying, 'Ngừng hoạt động'::character varying])::text[])));

ALTER TABLE "public"."Quyen"
  ADD CONSTRAINT "Quyen_TrangThai_check" CHECK ((("TrangThai")::text = ANY ((ARRAY['Hoạt động'::character varying, 'Ngừng hoạt động'::character varying])::text[])));

ALTER TABLE "public"."TaiKhoan"
  ADD CONSTRAINT "TaiKhoan_TrangThai_check"
    CHECK ((("TrangThai")::text = ANY ((ARRAY['Hoạt động'::character varying, 'Khóa'::character varying, 'Ngừng hoạt động'::character varying])::text[])));

ALTER TABLE "public"."ThanhToan"
  ADD CONSTRAINT "ThanhToan_PhuongThuc_check" CHECK ((("PhuongThuc")::text = ANY ((ARRAY['Tiền mặt'::character varying, 'Chuyển khoản'::character varying])::text[])));

ALTER TABLE "public"."ThanhToan"
  ADD CONSTRAINT "ThanhToan_TrangThai_check"
    CHECK
    ((("TrangThai")::text = ANY ((ARRAY['Chờ thanh toán'::character varying, 'Thành công'::character varying, 'Thất bại'::character varying, 'Đã hoàn tiền'::character
    varying])::text[])));

ALTER TABLE "public"."TinNhan"
  ADD CONSTRAINT "TinNhan_TrangThai_check"
    CHECK ((("TrangThai")::text = ANY ((ARRAY['Đã gửi'::character varying, 'Đã nhận'::character varying, 'Đã đọc'::character varying])::text[])));

ALTER TABLE "public"."VaiTro"
  ADD CONSTRAINT "VaiTro_TrangThai_check" CHECK ((("TrangThai")::text = ANY ((ARRAY['Hoạt động'::character varying, 'Ngừng hoạt động'::character varying])::text[])));

CREATE POLICY "laundry_compat_review_insert" ON "public"."DanhGia"
  FOR INSERT
  TO "authenticated"
  WITH CHECK ((("KhachHangID" = ( SELECT private.current_customer_id() AS current_customer_id)) AND (EXISTS ( SELECT 1
   FROM public."DonHang" order_record
  WHERE
    ((order_record."DonHangID" = "DanhGia"."DonHangID") AND (order_record."KhachHangID" = ( SELECT private.current_customer_id() AS current_customer_id)) AND
    ((order_record."TrangThai")::text = ANY ((ARRAY['Đã giao'::character varying, 'Đã thanh toán'::character varying])::text[])))))));

REVOKE ALL ("DiaChi") ON TABLE "public"."KhachHang" FROM "authenticated";

GRANT UPDATE ("DiaChi") ON TABLE "public"."KhachHang" TO "authenticated";

REVOKE ALL ("Email") ON TABLE "public"."KhachHang" FROM "authenticated";

GRANT UPDATE ("Email") ON TABLE "public"."KhachHang" TO "authenticated";

REVOKE ALL ("HoTen") ON TABLE "public"."KhachHang" FROM "authenticated";

GRANT UPDATE ("HoTen") ON TABLE "public"."KhachHang" TO "authenticated";

REVOKE ALL ("DaDoc") ON TABLE "public"."ThongBao" FROM "authenticated";

GRANT UPDATE ("DaDoc") ON TABLE "public"."ThongBao" TO "authenticated";
