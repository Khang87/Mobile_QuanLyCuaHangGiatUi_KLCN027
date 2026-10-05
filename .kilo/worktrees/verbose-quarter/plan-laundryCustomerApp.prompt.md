# Plan: Flutter Laundry Customer App - App Quản Lý Tiệm Giặt Ủi

## Context
- Project: `e:\app_mobile_bvkl\app_quanly_giaiui`
- Flutter SDK: ^3.11.3
- Hiện tại: chỉ có Hello World trong main.dart
- Mục tiêu: App cho KHÁCH HÀNG (không phải admin)
- Admin/quản lý → web app riêng

## Key Decisions (từ user)
- **Backend**: Chỉ xây giao diện trước, chưa cần data thật
- **Delivery**: Hỗ trợ cả 2 - khách mang đến hoặc tiệm đến lấy theo yêu cầu
- **Multi-store**: 1 cửa hàng trước mắt
- **Thanh toán**: Online (VNPay/MoMo/ZaloPay) + tại quầy
- **State Management**: Đề xuất BLoC/Cubit (chuẩn production)

## Architecture

### State Management: BLoC + Cubit
- Dễ test, scale tốt, phổ biến dùng production

### Folder Structure (Clean Architecture)
```
lib/
├── core/
│   ├── theme/          # màu sắc, typography, theme
│   ├── constants/      # constants toàn app
│   ├── utils/          # helpers, extensions
│   ├── widgets/        # shared widgets
│   └── navigation/     # routes
├── features/
│   ├── auth/           # đăng nhập / đăng ký
│   ├── home/           # trang chủ
│   ├── services/       # danh sách dịch vụ
│   ├── order/          # đặt đơn giặt
│   ├── tracking/       # theo dõi đơn hàng
│   ├── history/        # lịch sử đơn hàng
│   ├── payment/        # thanh toán
│   ├── notification/   # thông báo
│   ├── profile/        # hồ sơ khách hàng
│   └── loyalty/        # điểm thưởng / khuyến mãi
└── main.dart
```

## Features Plan

### Phase 1: Foundation & Auth (Bước 1)
1. Setup packages (pubspec.yaml)
2. Theme, colors, typography (brand nhận diện)
3. App router (go_router)
4. Splash screen + Onboarding
5. Đăng nhập / Đăng ký (phone OTP + Google)
6. Màn hình quên mật khẩu

### Phase 2: Home & Services (Bước 2)
7. Home screen: banner, shortcuts, đơn đang xử lý
8. Danh sách dịch vụ (giặt thường, giặt khô, ủi, giặt chăn mền...)
9. Chi tiết dịch vụ + bảng giá
10. Tìm kiếm / lọc dịch vụ

### Phase 3: Order Flow (Bước 3)
11. Đặt đơn: chọn dịch vụ → chọn số lượng/loại đồ
12. Chọn hình thức: mang đến tự / yêu cầu lấy tận nơi
13. Chọn địa chỉ lấy đồ (nếu giao nhận)
14. Chọn thời gian lấy/trả đồ
15. Ghi chú đặc biệt (quần áo nhạy cảm, dị ứng...)
16. Xác nhận đơn hàng

### Phase 4: Tracking (Bước 4)
17. Theo dõi trạng thái đơn hàng real-time
    - Đã nhận → Đang giặt → Đang sấy → Đã xong → Đã giao
18. Timeline view đơn hàng
19. Thông báo push khi trạng thái thay đổi
20. Gọi điện / chat với tiệm

### Phase 5: Payment (Bước 5)
21. Màn hình thanh toán
22. Chọn phương thức: tiền mặt / VNPay / MoMo / ZaloPay
23. Lịch sử giao dịch
24. Hóa đơn điện tử

### Phase 6: History & Profile (Bước 6)
25. Lịch sử đơn hàng (có filter)
26. Chi tiết đơn cũ + đánh giá dịch vụ (rating + comment)
27. Hồ sơ cá nhân (tên, SĐT, ảnh đại diện)
28. Quản lý địa chỉ
29. Cài đặt thông báo

### Phase 7: Loyalty & Promotions (Bước 7)
30. Chương trình tích điểm
31. Danh sách khuyến mãi / coupon
32. Áp dụng mã giảm giá khi đặt đơn
33. Giới thiệu bạn bè (referral)

## Packages cần dùng
- **State**: flutter_bloc, equatable
- **Navigation**: go_router
- **UI**: cached_network_image, shimmer, lottie, flutter_svg
- **Forms**: reactive_forms hoặc formz
- **Local storage**: shared_preferences, flutter_secure_storage
- **Notifications**: flutter_local_notifications, firebase_messaging
- **Payment**: vnpay/momo SDKs (phase sau)
- **Maps/Location**: google_maps_flutter, geolocator (cho pickup)
- **Date/time**: intl
- **HTTP**: dio, retrofit
- **Phone auth**: firebase_auth (placeholder)

## Implementation Order (for UI-only phase)
1. pubspec.yaml → thêm packages
2. core/theme → màu sắc xanh dương/trắng chuyên nghiệp
3. main.dart → MaterialApp với theme + router
4. Splash + Onboarding screens
5. Auth screens (login, register)
6. Bottom navigation + Home
7. Services screens
8. Order flow screens
9. Tracking screen
10. Payment screens
11. History + Profile screens
12. Notifications screen
13. Loyalty/Promotions screens
