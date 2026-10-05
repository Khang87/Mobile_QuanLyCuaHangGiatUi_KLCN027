BEGIN;

CREATE EXTENSION IF NOT EXISTS pgtap WITH SCHEMA extensions;
SET LOCAL search_path = public, extensions;

SELECT plan(74);

DO $$
DECLARE
  first_user_id uuid := 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa';
  second_user_id uuid := 'bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb';
  first_customer_id bigint;
  second_customer_id bigint;
  legacy_customer_id bigint;
  legacy_account_id bigint;
  customer_role_id bigint;
  test_service_id bigint;
  test_item_type_id bigint;
  test_unit_id bigint;
  employee_id bigint;
  staff_account_id bigint;
  staff_role_id bigint;
BEGIN
  INSERT INTO auth.users (id, email)
  VALUES
    (first_user_id, 'rls-customer-1@example.test'),
    (second_user_id, 'rls-customer-2@example.test');

  INSERT INTO public.khachhang (hoten, sodienthoai, email)
  VALUES ('RLS Customer One', '0900000001', 'rls-customer-1@example.test')
  RETURNING khachhangid INTO first_customer_id;

  INSERT INTO public.khachhang (hoten, sodienthoai, email)
  VALUES ('RLS Customer Two', '0900000002', 'rls-customer-2@example.test')
  RETURNING khachhangid INTO second_customer_id;

  INSERT INTO public.khachhang_diachi (
    khachhangid,
    tennguoinhan,
    sodienthoai,
    diachi,
    macdinh
  ) VALUES
    (first_customer_id, 'Customer One', '0900000001', '1 RLS Street', true),
    (second_customer_id, 'Customer Two', '0900000002', '2 RLS Street', true);

  INSERT INTO public.taikhoan (
    tendangnhap,
    matkhau,
    email,
    khachhangid,
    userauthid
  ) VALUES
    ('rls-customer-1', 'test-fixture-not-a-real-password',
     'rls-customer-1@example.test', first_customer_id, first_user_id),
    ('rls-customer-2', 'test-fixture-not-a-real-password',
     'rls-customer-2@example.test', second_customer_id, second_user_id);

  INSERT INTO public.donhang (
    madonhang,
    khachhangid,
    tongtien,
    thanhtien
  ) VALUES
    ('RLS-ORDER-1', first_customer_id, 100000, 100000),
    ('RLS-ORDER-2', second_customer_id, 100000, 100000);

  INSERT INTO public.loaidichvu (tenloaidichvu)
  VALUES ('RLS test service category');

  INSERT INTO public.dichvu (loaidichvuid, tendichvu)
  SELECT loaidichvuid, 'RLS test service'
  FROM public.loaidichvu
  WHERE tenloaidichvu = 'RLS test service category'
  RETURNING dichvuid INTO test_service_id;

  INSERT INTO public.loaidogiat (tenloaidogiat)
  VALUES ('RLS test laundry item')
  RETURNING loaidogiatid INTO test_item_type_id;

  SELECT donvitinhid INTO test_unit_id
  FROM public.donvitinh
  WHERE tendonvitinh = 'Kilogram';

  IF test_unit_id IS NULL THEN
    INSERT INTO public.donvitinh (tendonvitinh, kyhieu)
    VALUES ('Kilogram', 'kg')
    RETURNING donvitinhid INTO test_unit_id;
  END IF;

  INSERT INTO public.banggia (
    dichvuid,
    loaidogiatid,
    donvitinhid,
    dongia,
    ngayapdung
  ) VALUES (
    test_service_id,
    test_item_type_id,
    test_unit_id,
    25000,
    current_date
  );

  INSERT INTO auth.users (id, email, phone, phone_confirmed_at)
  VALUES
    ('cccccccc-cccc-4ccc-8ccc-cccccccccccc', 'rls-customer-3@example.test',
     '+84' || substr('0900000003', 2), now()),
    ('dddddddd-dddd-4ddd-8ddd-dddddddddddd', 'rls-customer-4@example.test',
     '+8490000004', now()),
    ('eeeeeeee-eeee-4eee-8eee-eeeeeeeeeeee', 'rls-customer-5@example.test',
     '+8490000005', NULL);

  INSERT INTO public.khachhang (hoten, sodienthoai, email)
  VALUES ('Legacy Customer', '0900000003', 'rls-customer-3@example.test')
  RETURNING khachhangid INTO legacy_customer_id;

  INSERT INTO public.taikhoan (
    tendangnhap,
    matkhau,
    email,
    sodienthoai,
    khachhangid
  ) VALUES (
    'legacy-customer-3',
    'legacy-test-fixture-only',
    'rls-customer-3@example.test',
    '0900000003',
    legacy_customer_id
  ) RETURNING taikhoanid INTO legacy_account_id;

  SELECT vaitroid INTO customer_role_id
  FROM public.vaitro
  WHERE tenvaitro = 'Khách hàng';

  IF customer_role_id IS NULL THEN
    INSERT INTO public.vaitro (tenvaitro)
    VALUES ('Khách hàng')
    RETURNING vaitroid INTO customer_role_id;
  END IF;

  INSERT INTO public.taikhoan_vaitro (taikhoanid, vaitroid)
  VALUES (legacy_account_id, customer_role_id);

  INSERT INTO auth.users (id, email, phone, phone_confirmed_at)
  VALUES (
    'ffffffff-ffff-4fff-8fff-ffffffffffff',
    'rls-staff@example.test',
    '+8490000006',
    now()
  );

  INSERT INTO public.nhanvien (hoten, sodienthoai)
  VALUES ('RLS Staff', '0900000006')
  RETURNING nhanvienid INTO employee_id;

  INSERT INTO public.taikhoan (
    tendangnhap,
    matkhau,
    sodienthoai,
    nhanvienid,
    userauthid
  ) VALUES (
    'rls-staff',
    'staff-test-fixture-only',
    '0900000006',
    employee_id,
    'ffffffff-ffff-4fff-8fff-ffffffffffff'
  ) RETURNING taikhoanid INTO staff_account_id;

  SELECT vaitroid INTO staff_role_id
  FROM public.vaitro
  WHERE tenvaitro = 'Nhân viên';

  INSERT INTO public.taikhoan_vaitro (taikhoanid, vaitroid)
  VALUES (staff_account_id, staff_role_id);
END;
$$;

SELECT is(
  (SELECT count(*)::integer FROM pg_class AS relation
   JOIN pg_namespace AS namespace ON namespace.oid = relation.relnamespace
   WHERE namespace.nspname = 'public'
     AND relation.relkind IN ('r', 'p')
     AND relation.relrowsecurity),
  26,
  'RLS is enabled on all public tables'
);
SELECT ok(
  NOT has_table_privilege('anon', 'public.taikhoan', 'SELECT'),
  'anonymous clients cannot select account rows'
);
SELECT ok(
  NOT has_column_privilege('authenticated', 'public.taikhoan', 'matkhau', 'SELECT'),
  'authenticated clients cannot select the legacy password column'
);

SET LOCAL ROLE anon;
SELECT is(
  (SELECT count(*)::integer FROM public.dichvu
   WHERE tendichvu = 'RLS test service'),
  1,
  'anonymous clients can read active catalog entries'
);
SELECT throws_ok(
  'SELECT khachhangid FROM public.khachhang',
  '42501',
  'permission denied for table khachhang',
  'anonymous clients cannot read customer profiles'
);
SELECT throws_ok(
  $$SELECT public.submit_laundry_order(
    1, 1, 'Tại cửa hàng', NULL, current_date + 1, time '10:00', NULL,
    '11111111-1111-4111-8111-111111111111'::uuid)$$,
  '42501',
  'permission denied for function submit_laundry_order',
  'anonymous clients cannot submit an order'
);
RESET ROLE;

SELECT set_config(
  'request.jwt.claim.sub',
  'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa',
  true
);
SELECT set_config(
  'request.jwt.claims',
  '{"sub":"aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa","role":"authenticated"}',
  true
);
SET LOCAL ROLE authenticated;

SELECT is(
  (SELECT count(*)::integer FROM public.khachhang),
  1,
  'a customer can read only their own profile'
);
SELECT is(
  (SELECT count(*)::integer FROM public.donhang),
  1,
  'a customer can read only their own orders'
);
SELECT is(
  (SELECT count(*)::integer FROM public.donhang
   WHERE madonhang = 'RLS-ORDER-2'),
  0,
  'a customer cannot read another customer order'
);
SELECT is(
  (SELECT count(*)::integer FROM public.taikhoan),
  1,
  'a customer can read only their own account metadata'
);
SELECT ok(
  NOT has_table_privilege('anon', 'public.khachhang_diachi', 'SELECT'),
  'anonymous users cannot select saved addresses'
);
SELECT is(
  (SELECT count(*)::integer FROM public.khachhang_diachi),
  1,
  'a customer sees only their own saved address'
);
SELECT is(
  (SELECT count(*)::integer FROM public.khachhang_diachi
   WHERE diachi = '2 RLS Street'),
  0,
  'a customer cannot read another customer address'
);
SELECT lives_ok(
  $$SELECT public.save_customer_address(
    NULL, 'Customer One New', '0900000001', '3 RLS Street', NULL, true)$$,
  'a customer can save an address and make it the default'
);
SELECT is(
  (SELECT count(*)::integer FROM public.khachhang_diachi WHERE macdinh),
  1,
  'switching a default address preserves a single default per customer'
);
SELECT lives_ok(
  $$UPDATE public.khachhang SET diachi = 'Updated by owner'
    WHERE sodienthoai = '0900000001'$$,
  'a customer can update their own profile'
);
SELECT is(
  (SELECT count(*)::integer FROM public.khachhang
   WHERE diachi = 'Updated by owner'),
  1,
  'the customer profile update is persisted'
);
SELECT lives_ok(
  $$UPDATE public.khachhang SET diachi = 'Cross-customer write'
    WHERE sodienthoai = '0900000002'$$,
  'a cross-customer update is filtered by row-level security'
);
SELECT throws_ok(
  $$INSERT INTO public.donhang (madonhang, khachhangid)
    VALUES ('CLIENT-CREATED-ORDER', 1)$$,
  '42501',
  'permission denied for table donhang',
  'clients cannot bypass the server order-creation operation'
);
SELECT lives_ok(
  $$SELECT public.submit_laundry_order(
    (SELECT banggiaid FROM public.banggia
     WHERE dichvuid = (SELECT dichvuid FROM public.dichvu
                       WHERE tendichvu = 'RLS test service')),
    1.5,
    'Tại nhà',
    '10 RLS Lane',
    current_date + 1,
    time '10:30',
    'Separate colors',
    '11111111-1111-4111-8111-111111111111'::uuid
  )$$,
  'an authenticated customer can submit an order through the server RPC'
);
SELECT is(
  (SELECT count(*)::integer FROM public.booking
   WHERE idempotency_key = '11111111-1111-4111-8111-111111111111'),
  1,
  'booking submission stores one idempotency key'
);
SELECT is(
  (SELECT thanhtien FROM public.booking
   WHERE idempotency_key = '11111111-1111-4111-8111-111111111111'),
  37500::numeric,
  'the booking snapshots the server-calculated amount'
);
SELECT is(
  (SELECT count(*)::integer FROM public.booking
   WHERE idempotency_key = '11111111-1111-4111-8111-111111111111'
     AND khoiluong = 1.5 AND soluong IS NULL),
  1,
  'weight-based bookings store weight rather than quantity'
);
SELECT is(
  (SELECT count(*)::integer FROM public.booking
   WHERE idempotency_key = '11111111-1111-4111-8111-111111111111'
     AND trangthai = 'ChoTiepNhan'),
  1,
  'a new booking begins in the pending reception state'
);
SELECT is(
  (SELECT count(*)::integer FROM public.donhang
   WHERE bookingid = (SELECT bookingid FROM public.booking
     WHERE idempotency_key = '11111111-1111-4111-8111-111111111111')),
  0,
  'customer submission does not create an order'
);
SELECT is(
  (SELECT count(*)::integer FROM public.giaonhan
   WHERE donhangid IN (SELECT donhangid FROM public.donhang
     WHERE bookingid = (SELECT bookingid FROM public.booking
       WHERE idempotency_key = '11111111-1111-4111-8111-111111111111'))),
  0,
  'pickup assignment waits until staff confirms the booking'
);
SELECT lives_ok(
  $$SELECT public.cancel_laundry_booking(
    (SELECT bookingid FROM public.booking
     WHERE idempotency_key = '11111111-1111-4111-8111-111111111111'))$$,
  'a customer can cancel a booking while it is pending'
);
SELECT is(
  (SELECT trangthai FROM public.booking
   WHERE idempotency_key = '11111111-1111-4111-8111-111111111111'),
  'DaHuy',
  'cancellation preserves the booking and changes its status'
);
SELECT lives_ok(
  $$SELECT public.submit_laundry_order(
    (SELECT banggiaid FROM public.banggia
     WHERE dichvuid = (SELECT dichvuid FROM public.dichvu
                       WHERE tendichvu = 'RLS test service')),
    0.5,
    'Tại nhà',
    '12 Staff Lane',
    current_date + 1,
    time '11:00',
    'Confirm after acceptance',
    '77777777-7777-4777-8777-777777777777'::uuid
  )$$,
  'the customer can create another pending booking'
);
SELECT is(
  (SELECT count(*)::integer FROM public.donhang
   WHERE bookingid = (SELECT bookingid FROM public.booking
     WHERE idempotency_key = '77777777-7777-4777-8777-777777777777')),
  0,
  'the second submission also creates no order before staff confirmation'
);
SELECT lives_ok(
  $$SELECT public.submit_laundry_order(
    (SELECT banggiaid FROM public.banggia
     WHERE dichvuid = (SELECT dichvuid FROM public.dichvu
                       WHERE tendichvu = 'RLS test service')),
    1.5,
    'Tại nhà',
    '10 RLS Lane',
    current_date + 1,
    time '10:30',
    'Separate colors',
    '11111111-1111-4111-8111-111111111111'::uuid
  )$$,
  'a retry with the same idempotency key succeeds'
);
SELECT is(
  (SELECT count(*)::integer FROM public.booking
   WHERE idempotency_key = '11111111-1111-4111-8111-111111111111'),
  1,
  'retry does not create a duplicate booking'
);
SELECT is(
  (SELECT count(*)::integer FROM public.donhang_trangthai AS event
   JOIN public.donhang AS order_record USING (donhangid)
   WHERE order_record.bookingid = (SELECT bookingid FROM public.booking
     WHERE idempotency_key = '11111111-1111-4111-8111-111111111111')),
  0,
  'retry does not create order status history before confirmation'
);
SELECT throws_ok(
  $$SELECT public.submit_laundry_order(
    999999, 1, 'Tại cửa hàng', NULL, current_date + 1, time '10:00', NULL,
    '22222222-2222-4222-8222-222222222222'::uuid)$$,
  'P0001',
  'The selected price is no longer available',
  'the RPC rejects an inactive or missing price'
);
SELECT throws_ok(
  $$SELECT public.submit_laundry_order(
    1, 1.234, 'Tại cửa hàng', NULL, current_date + 1, time '10:00', NULL,
    '33333333-3333-4333-8333-333333333333'::uuid)$$,
  'P0001',
  'Measurement must be positive and have at most two decimals',
  'the RPC rejects measurements outside database precision'
);
SELECT throws_ok(
  $$SELECT public.submit_laundry_order(
    1, 1, 'Tại nhà', NULL, current_date + 1, time '10:00', NULL,
    '44444444-4444-4444-8444-444444444444'::uuid)$$,
  'P0001',
  'A pickup address is required',
  'the RPC requires an address for home pickup'
);
RESET ROLE;
SELECT is(
  (SELECT count(*)::integer FROM public.khachhang
   WHERE sodienthoai = '0900000002' AND diachi = 'Cross-customer write'),
  0,
  'a customer cannot change another customer profile'
);

SELECT set_config(
  'request.jwt.claim.sub',
  'cccccccc-cccc-4ccc-8ccc-cccccccccccc',
  true
);
SELECT set_config(
  'request.jwt.claims',
  '{"sub":"cccccccc-cccc-4ccc-8ccc-cccccccccccc","role":"authenticated"}',
  true
);
SET LOCAL ROLE authenticated;
SELECT lives_ok(
  $$SELECT public.complete_customer_profile('Linked Customer')$$,
  'a verified phone can link an existing customer account'
);
SELECT is(
  (SELECT count(*)::integer FROM public.taikhoan
   WHERE userauthid = 'cccccccc-cccc-4ccc-8ccc-cccccccccccc'),
  1,
  'legacy account linkage is unique and belongs to the verified user'
);
SELECT is(
  (SELECT count(*)::integer FROM public.khachhang
   WHERE sodienthoai = '0900000003' AND hoten = 'Linked Customer'),
  1,
  'linking updates the existing customer profile'
);
SELECT is(
  (SELECT count(*)::integer
   FROM public.taikhoan_vaitro AS account_role
   JOIN public.taikhoan AS account USING (taikhoanid)
   JOIN public.vaitro AS role USING (vaitroid)
   WHERE account.userauthid = 'cccccccc-cccc-4ccc-8ccc-cccccccccccc'
     AND role.tenvaitro = 'Khách hàng'),
  1,
  'legacy customer role is preserved without duplication'
);
RESET ROLE;

SELECT set_config(
  'request.jwt.claim.sub',
  'dddddddd-dddd-4ddd-8ddd-dddddddddddd',
  true
);
SELECT set_config(
  'request.jwt.claims',
  '{"sub":"dddddddd-dddd-4ddd-8ddd-dddddddddddd","role":"authenticated"}',
  true
);
SET LOCAL ROLE authenticated;
SELECT lives_ok(
  $$SELECT public.complete_customer_profile('New Customer')$$,
  'a verified new customer can create their profile'
);
SELECT is(
  (SELECT count(*)::integer FROM public.taikhoan
   WHERE userauthid = 'dddddddd-dddd-4ddd-8ddd-dddddddddddd'),
  1,
  'the new auth account is linked to its verified user'
);
SELECT is(
  (SELECT count(*)::integer
   FROM public.taikhoan_vaitro AS account_role
   JOIN public.taikhoan AS account USING (taikhoanid)
   JOIN public.vaitro AS role USING (vaitroid)
   WHERE account.userauthid = 'dddddddd-dddd-4ddd-8ddd-dddddddddddd'
     AND role.tenvaitro = 'Khách hàng'),
  1,
  'self-service signup can only receive the customer role'
);
RESET ROLE;
SELECT is(
  (SELECT count(*)::integer FROM public.taikhoan
   WHERE userauthid = 'dddddddd-dddd-4ddd-8ddd-dddddddddddd'
     AND matkhau IS NULL),
  1,
  'new auth accounts do not store a legacy password'
);

SELECT set_config(
  'request.jwt.claim.sub',
  'eeeeeeee-eeee-4eee-8eee-eeeeeeeeeeee',
  true
);
SELECT set_config(
  'request.jwt.claims',
  '{"sub":"eeeeeeee-eeee-4eee-8eee-eeeeeeeeeeee","role":"authenticated"}',
  true
);
SET LOCAL ROLE authenticated;
SELECT throws_ok(
  $$SELECT public.complete_customer_profile('Unverified Customer')$$,
  'P0001',
  'A verified phone number is required',
  'an unverified phone cannot create or link a customer profile'
);
RESET ROLE;

SELECT set_config(
  'request.jwt.claim.sub',
  'ffffffff-ffff-4fff-8fff-ffffffffffff',
  true
);
SELECT set_config(
  'request.jwt.claims',
  '{"sub":"ffffffff-ffff-4fff-8fff-ffffffffffff","role":"authenticated"}',
  true
);
SET LOCAL ROLE authenticated;
SELECT lives_ok(
  $$SELECT public.confirm_laundry_booking(
    (SELECT bookingid FROM public.booking
     WHERE idempotency_key = '77777777-7777-4777-8777-777777777777'))$$,
  'an active staff member can confirm a pending booking'
);
SELECT is(
  (SELECT trangthai FROM public.booking
   WHERE idempotency_key = '77777777-7777-4777-8777-777777777777'),
  'DaXacNhan',
  'staff confirmation updates the retained booking status'
);
SELECT is(
  (SELECT count(*)::integer FROM public.donhang AS order_record
   JOIN public.booking AS booking USING (bookingid)
   WHERE booking.idempotency_key = '77777777-7777-4777-8777-777777777777'
     AND order_record.trangthai = 'Đã tiếp nhận'),
  1,
  'staff confirmation creates one accepted order from the booking'
);
SELECT is(
  (SELECT count(*)::integer FROM public.chitietdonhang AS detail
   JOIN public.donhang AS order_record USING (donhangid)
   JOIN public.booking AS booking USING (bookingid)
   WHERE booking.idempotency_key = '77777777-7777-4777-8777-777777777777'
     AND detail.soluong = booking.soluong
     AND detail.dongia = booking.dongia
     AND detail.thanhtien = booking.thanhtien),
  1,
  'the new order details are copied from the booking snapshot'
);
SELECT is(
  (SELECT count(*)::integer FROM public.hoadon AS invoice
   JOIN public.donhang AS order_record USING (donhangid)
   JOIN public.booking AS booking USING (bookingid)
   WHERE booking.idempotency_key = '77777777-7777-4777-8777-777777777777'
     AND invoice.thanhtien = booking.thanhtien
     AND invoice.trangthai = 'Chưa thanh toán'),
  1,
  'confirmation creates an unpaid invoice from the booking total'
);
SELECT is(
  (SELECT count(*)::integer FROM public.giaonhan AS pickup
   JOIN public.donhang AS order_record USING (donhangid)
   JOIN public.booking AS booking USING (bookingid)
   WHERE booking.idempotency_key = '77777777-7777-4777-8777-777777777777'
     AND pickup.loaigiaonhan = 'NHAN_DO'
     AND pickup.diachi = '12 Staff Lane'),
  1,
  'confirmation creates home pickup from the retained booking'
);
SELECT lives_ok(
  $$SELECT public.confirm_laundry_booking(
    (SELECT bookingid FROM public.booking
     WHERE idempotency_key = '77777777-7777-4777-8777-777777777777'))$$,
  'repeating staff confirmation returns the existing order'
);
SELECT is(
  (SELECT count(*)::integer FROM public.donhang
   WHERE bookingid = (SELECT bookingid FROM public.booking
     WHERE idempotency_key = '77777777-7777-4777-8777-777777777777')),
  1,
  'repeated confirmation cannot duplicate the order'
);
SELECT lives_ok(
  $$SELECT public.transition_laundry_order(
    (SELECT donhangid FROM public.donhang WHERE madonhang = 'RLS-ORDER-1'),
    'Đã tiếp nhận', NULL)$$,
  'an active staff member can accept an order'
);
SELECT is(
  (SELECT count(*)::integer FROM public.donhang
   WHERE madonhang = 'RLS-ORDER-1' AND trangthai = 'Đã tiếp nhận'),
  1,
  'accepting an order updates its state'
);
SELECT is(
  (SELECT count(*)::integer FROM public.donhang_trangthai AS event
   JOIN public.donhang AS order_record USING (donhangid)
   WHERE order_record.madonhang = 'RLS-ORDER-1'
     AND event.trangthaicu = 'Chờ tiếp nhận'
     AND event.trangthaimoi = 'Đã tiếp nhận'),
  1,
  'staff status changes are written to the timeline'
);
SELECT lives_ok(
  $$SELECT public.transition_laundry_order(
    (SELECT donhangid FROM public.donhang WHERE madonhang = 'RLS-ORDER-1'),
    'Đang giặt', NULL)$$,
  'staff can move an accepted order into processing'
);
SELECT lives_ok(
  $$SELECT public.transition_laundry_order(
    (SELECT donhangid FROM public.donhang WHERE madonhang = 'RLS-ORDER-1'),
    'Hoàn thành giặt', NULL)$$,
  'staff can finish processing an order'
);
SELECT lives_ok(
  $$SELECT public.transition_laundry_order(
    (SELECT donhangid FROM public.donhang WHERE madonhang = 'RLS-ORDER-1'),
    'Đã giao', NULL)$$,
  'staff can mark a store handoff as delivered'
);
SELECT throws_ok(
  $$SELECT public.transition_laundry_order(
    (SELECT donhangid FROM public.donhang WHERE madonhang = 'RLS-ORDER-2'),
    'Đã hủy', NULL)$$,
  'P0001',
  'A cancellation reason is required',
  'staff cancellation requires a reason'
);
SELECT lives_ok(
  $$SELECT public.transition_laundry_order(
    (SELECT donhangid FROM public.donhang WHERE madonhang = 'RLS-ORDER-2'),
    'Đã hủy', 'Khách yêu cầu hủy')$$,
  'staff can cancel an order with a reason'
);
SELECT is(
  (SELECT count(*)::integer FROM public.donhang_trangthai AS event
   JOIN public.donhang AS order_record USING (donhangid)
   WHERE order_record.madonhang = 'RLS-ORDER-2'
     AND event.trangthaimoi = 'Đã hủy'
     AND event.lydo = 'Khách yêu cầu hủy'),
  1,
  'cancellation reason is recorded with the status event'
);
SELECT throws_ok(
  $$SELECT public.transition_laundry_order(
    (SELECT donhangid FROM public.donhang WHERE madonhang = 'RLS-ORDER-2'),
    'Đang giặt', NULL)$$,
  'P0001',
  'Invalid order status transition: Đã hủy -> Đang giặt',
  'invalid order status transitions are rejected'
);
RESET ROLE;

SELECT set_config(
  'request.jwt.claim.sub',
  'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa',
  true
);
SELECT set_config(
  'request.jwt.claims',
  '{"sub":"aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa","role":"authenticated"}',
  true
);
SET LOCAL ROLE authenticated;
SELECT throws_ok(
  $$SELECT public.cancel_laundry_booking(
    (SELECT bookingid FROM public.booking
     WHERE idempotency_key = '77777777-7777-4777-8777-777777777777'))$$,
  'P0001',
  'Only pending bookings can be canceled',
  'a customer cannot cancel a booking after staff confirmation'
);
SELECT lives_ok(
  $$SELECT public.request_order_payment(
    (SELECT donhangid FROM public.donhang WHERE madonhang = 'RLS-ORDER-1'),
    'Chuyển khoản',
    '55555555-5555-4555-8555-555555555555'::uuid)$$,
  'a customer can create a bank-transfer payment intent after delivery'
);
SELECT is(
  (SELECT count(*)::integer FROM public.thanhtoan
   WHERE idempotency_key = '55555555-5555-4555-8555-555555555555'
     AND sotien = 100000 AND trangthai = 'Chờ thanh toán'),
  1,
  'payment intent amount and status come from the server invoice'
);
SELECT lives_ok(
  $$SELECT public.request_order_payment(
    (SELECT donhangid FROM public.donhang WHERE madonhang = 'RLS-ORDER-1'),
    'Chuyển khoản',
    '55555555-5555-4555-8555-555555555555'::uuid)$$,
  'a payment intent retry returns its existing record'
);
SELECT is(
  (SELECT count(*)::integer FROM public.thanhtoan
   WHERE idempotency_key = '55555555-5555-4555-8555-555555555555'),
  1,
  'a payment retry cannot create a duplicate intent'
);
SELECT throws_ok(
  $$SELECT public.request_order_payment(
    (SELECT donhangid FROM public.donhang WHERE madonhang = 'RLS-ORDER-2'),
    'Tiền mặt',
    '66666666-6666-4666-8666-666666666666'::uuid)$$,
  'P0001',
  'Order not found',
  'a customer cannot create a payment intent for another customer order'
);
RESET ROLE;

SELECT set_config(
  'request.jwt.claim.sub',
  'ffffffff-ffff-4fff-8fff-ffffffffffff',
  true
);
SELECT set_config(
  'request.jwt.claims',
  '{"sub":"ffffffff-ffff-4fff-8fff-ffffffffffff","role":"authenticated"}',
  true
);
SET LOCAL ROLE authenticated;
SELECT lives_ok(
  $$SELECT public.confirm_order_payment(
    (SELECT thanhtoanid FROM public.thanhtoan
     WHERE idempotency_key = '55555555-5555-4555-8555-555555555555'),
    true,
    'Đã đối soát chuyển khoản')$$,
  'staff can confirm a pending payment'
);
SELECT is(
  (SELECT count(*)::integer FROM public.thanhtoan
   WHERE idempotency_key = '55555555-5555-4555-8555-555555555555'
     AND trangthai = 'Thành công'),
  1,
  'staff confirmation marks the payment successful'
);
SELECT is(
  (SELECT count(*)::integer FROM public.hoadon AS invoice
   JOIN public.donhang AS order_record USING (donhangid)
   WHERE order_record.madonhang = 'RLS-ORDER-1'
     AND invoice.trangthai = 'Đã thanh toán'),
  1,
  'successful payment settles the invoice'
);
SELECT is(
  (SELECT count(*)::integer FROM public.donhang
   WHERE madonhang = 'RLS-ORDER-1' AND trangthai = 'Đã thanh toán'),
  1,
  'successful payment reconciles the order status'
);
RESET ROLE;

SELECT * FROM finish();
ROLLBACK;