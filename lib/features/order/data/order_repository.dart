import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:app_quanly_giaiui/features/order/domain/cart_item.dart';
import 'package:app_quanly_giaiui/features/notification/data/notification_repository.dart';
import 'package:app_quanly_giaiui/features/notification/services/notification_service.dart';

enum LaundryBookingStatus {
  awaitingReception('ChoTiepNhan', 'Chờ tiếp nhận'),
  confirmed('DaXacNhan', 'Đã xác nhận'),
  cancelled('DaHuy', 'Đã hủy'),
  completed('HoanThanh', 'Hoàn thành'),
  delivered('DaGiao', 'Đã giao'),
  unknown('Unknown', 'Không xác định');

  const LaundryBookingStatus(this.databaseValue, this.displayValue);

  final String databaseValue;
  final String displayValue;

  static LaundryBookingStatus fromDatabase(String value) => values.firstWhere(
    (status) => status.databaseValue == value,
    orElse: () => switch (value) {
      'Chờ xác nhận' => awaitingReception,
      'Đã xác nhận' => confirmed,
      'Đã hủy' => cancelled,
      'Hoàn thành' => completed,
      'Đã giao' => delivered,
      _ => unknown,
    },
  );
}

class LaundryPriceOption {
  const LaundryPriceOption({
    required this.priceId,
    required this.serviceId,
    required this.serviceName,
    this.serviceDescription,
    this.processingTimeMinutes,
    required this.itemTypeId,
    required this.itemTypeName,
    required this.unitId,
    required this.unitName,
    required this.unitSymbol,
    required this.unitPriceVnd,
  });

  final int priceId;
  final int serviceId;
  final String serviceName;
  final String? serviceDescription;
  final int? processingTimeMinutes;
  final int itemTypeId;
  final String itemTypeName;
  final int unitId;
  final String unitName;
  final String unitSymbol;
  final num unitPriceVnd;

  factory LaundryPriceOption.fromJson(Map<String, dynamic> json) {
    return LaundryPriceOption(
      priceId: (json['banggiaid'] as num).toInt(),
      serviceId: (json['dichvuid'] as num).toInt(),
      serviceName: json['tendichvu'] as String,
      serviceDescription: json['mota'] as String?,
      processingTimeMinutes: (json['thoigiandukien'] as num?)?.toInt(),
      itemTypeId: (json['loaidogiatid'] as num).toInt(),
      itemTypeName: json['tenloaidogiat'] as String,
      unitId: (json['donvitinhid'] as num).toInt(),
      unitName: json['tendonvitinh'] as String,
      unitSymbol: json['kyhieu'] as String? ?? '',
      unitPriceVnd: json['dongia'] as num,
    );
  }
}

class CreatedLaundryBooking {
  const CreatedLaundryBooking({
    required this.bookingId,
    required this.bookingNumber,
    required this.estimatedTotalVnd,
    this.itemCount = 1,
    this.pointsUsed = 0,
    this.pointsDiscountVnd = 0,
    this.finalTotalVnd,
  });

  final int bookingId;
  final String bookingNumber;
  final num estimatedTotalVnd;
  final int itemCount;
  final int pointsUsed;
  final num pointsDiscountVnd;
  final num? finalTotalVnd;

  factory CreatedLaundryBooking.fromJson(Map<String, dynamic> json) {
    final estimatedTotal = json['thanhtien'] as num;
    final pointsDiscount = json['tiengiamdodiem'] as num? ?? 0;
    return CreatedLaundryBooking(
      bookingId: (json['bookingid'] as num).toInt(),
      bookingNumber: json['mabooking'] as String,
      estimatedTotalVnd: estimatedTotal,
      itemCount: (json['itemcount'] as num?)?.toInt() ?? 1,
      pointsUsed: (json['diemsudung'] as num?)?.toInt() ?? 0,
      pointsDiscountVnd: pointsDiscount,
      finalTotalVnd:
          json['thanhtoan'] as num? ?? estimatedTotal - pointsDiscount,
    );
  }
}

class LaundryOrderRecord {
  const LaundryOrderRecord({
    required this.orderId,
    this.bookingId,
    required this.orderNumber,
    required this.status,
    required this.totalVnd,
    required this.createdAt,
    required this.lineDescription,
    this.canCancelBooking = false,
    this.hasLaundryDetails = true,
  });

  final int? orderId;
  final int? bookingId;
  final String orderNumber;
  final String status;
  final num totalVnd;
  final DateTime createdAt;
  final String lineDescription;
  final bool canCancelBooking;
  final bool hasLaundryDetails;

  factory LaundryOrderRecord.fromJson(Map<String, dynamic> json) {
    final details = json['ChiTietDonHang'] as List<dynamic>? ?? const [];
    final descriptions = details.map((entry) {
      final detail = entry as Map<String, dynamic>;
      final service = detail['DichVu'] as Map<String, dynamic>?;
      final itemType = detail['LoaiDoGiat'] as Map<String, dynamic>?;
      final unit = detail['DonViTinh'] as Map<String, dynamic>?;
      final measurement = detail['KhoiLuong'] ?? detail['SoLuong'];
      return '${service?['TenDichVu'] ?? 'Dịch vụ'} · '
          '${itemType?['TenLoaiDoGiat'] ?? 'Đồ giặt'} · '
          '$measurement ${unit?['KyHieu'] ?? ''}';
    });

    return LaundryOrderRecord(
      orderId: (json['DonHangID'] as num).toInt(),
      bookingId: (json['BookingID'] as num?)?.toInt(),
      orderNumber: json['MaDonHang'] as String,
      status: json['TrangThai'] as String,
      totalVnd: json['ThanhTien'] as num,
      createdAt: DateTime.parse(json['NgayTao'] as String),
      lineDescription: descriptions.isEmpty
          ? 'Cửa hàng đang kiểm nhận đồ'
          : descriptions.join(', '),
    );
  }

  factory LaundryOrderRecord.fromBookingJson(
    Map<String, dynamic> json, {
    Map<String, dynamic>? linkedOrder,
  }) {
    final details = json['ChiTietBooking'] as List<dynamic>? ?? const [];
    // Build descriptions from all items
    final descriptions = details.map((entry) {
      final detail = entry as Map<String, dynamic>;
      final service = detail['DichVu'] as Map<String, dynamic>?;
      final itemType = detail['LoaiDoGiat'] as Map<String, dynamic>?;
      final unit = detail['DonViTinh'] as Map<String, dynamic>?;
      final measurement = detail['KhoiLuong'] ?? detail['SoLuong'];
      return '${service?['TenDichVu'] ?? 'Dịch vụ'} · '
          '${itemType?['TenLoaiDoGiat'] ?? 'Đồ giặt'} · '
          '$measurement ${unit?['KyHieu'] ?? ''}';
    }).toList();

    final bookingStatus = LaundryBookingStatus.fromDatabase(
      json['TrangThai'] as String,
    );

    // Calculate total from all detail items
    final totalVnd = details.fold<num>(
      0,
      (sum, entry) =>
          sum + ((entry as Map<String, dynamic>)['ThanhTien'] as num? ?? 0),
    );

    return LaundryOrderRecord(
      orderId: (linkedOrder?['DonHangID'] as num?)?.toInt(),
      bookingId: (json['BookingID'] as num).toInt(),
      orderNumber: json['MaBooking'] as String,
      status:
          linkedOrder?['TrangThai'] as String? ?? bookingStatus.displayValue,
      totalVnd: totalVnd,
      createdAt: DateTime.parse(json['NgayTao'] as String),
      lineDescription: descriptions.isEmpty
          ? 'Cửa hàng sẽ kiểm nhận đồ và báo giá'
          : descriptions.join(', '),
      canCancelBooking: bookingStatus == LaundryBookingStatus.awaitingReception,
      hasLaundryDetails: details.isNotEmpty,
    );
  }
}

class LaundryOrderStatusEvent {
  const LaundryOrderStatusEvent({
    required this.previousStatus,
    required this.status,
    required this.note,
    required this.occurredAt,
  });

  final String? previousStatus;
  final String status;
  final String? note;
  final DateTime occurredAt;

  factory LaundryOrderStatusEvent.fromJson(Map<String, dynamic> json) {
    return LaundryOrderStatusEvent(
      previousStatus: json['trangthaicu'] as String?,
      status: json['trangthaimoi'] as String,
      note: json['lydo'] as String?,
      occurredAt: DateTime.parse(json['thoigian'] as String),
    );
  }
}

class LaundryOrderDetails {
  const LaundryOrderDetails({
    required this.order,
    required this.events,
    this.pickupMethod,
    this.paymentMethod,
    this.address,
    this.appointment,
    this.notes,
    this.items,
    this.subtotalVnd,
    this.deliveryFeeVnd = 0,
    this.pointsUsed = 0,
    this.pointsDiscountVnd = 0,
    this.promotionDiscountVnd,
    this.promotionApplied = false,
    this.promotionCode,
    this.finalTotalVnd,
  });

  final LaundryOrderRecord order;
  final List<LaundryOrderStatusEvent> events;
  final String? pickupMethod;
  final String? paymentMethod;
  final String? address;
  final DateTime? appointment;
  final String? notes;
  final List<LaundryOrderItem>? items;
  final num? subtotalVnd;
  final num deliveryFeeVnd;
  final int pointsUsed;
  final num pointsDiscountVnd;
  final num? promotionDiscountVnd;
  final bool promotionApplied;
  final String? promotionCode;
  final num? finalTotalVnd;
}

class LaundryOrderItem {
  const LaundryOrderItem({
    required this.serviceName,
    required this.itemTypeName,
    required this.unitSymbol,
    required this.measurement,
    required this.unitPriceVnd,
    required this.totalVnd,
  });

  final String serviceName;
  final String itemTypeName;
  final String unitSymbol;
  final num measurement;
  final num unitPriceVnd;
  final num totalVnd;
}

class OrderRepository {
  OrderRepository({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client,
      _notificationRepository = NotificationRepository(client: client);

  final SupabaseClient _client;
  final NotificationRepository _notificationRepository;

  static String createIdempotencyKey() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    bytes[6] = (bytes[6] & 0x0f) | 0x40;
    bytes[8] = (bytes[8] & 0x3f) | 0x80;
    final hex = bytes.map((byte) => byte.toRadixString(16).padLeft(2, '0'));
    final value = hex.join();
    return '${value.substring(0, 8)}-${value.substring(8, 12)}-'
        '${value.substring(12, 16)}-${value.substring(16, 20)}-'
        '${value.substring(20)}';
  }

  Future<List<LaundryPriceOption>> getActivePrices() async {
    final rows = await _client
        .from('banggia')
        .select(
          'banggiaid,dichvuid,loaidogiatid,donvitinhid,dongia,'
          'dichvu!inner(tendichvu,trangthai,mota,thoigiandukien),'
          'loaidogiat!inner(tenloaidogiat,trangthai),'
          'donvitinh!inner(tendonvitinh,kyhieu,trangthai)',
        )
        .eq('trangthai', 'Hoạt động')
        .order('banggiaid');

    return (rows as List<dynamic>)
        .map((row) {
          final price = row as Map<String, dynamic>;
          final service = price['dichvu'] as Map<String, dynamic>;
          final itemType = price['loaidogiat'] as Map<String, dynamic>;
          final unit = price['donvitinh'] as Map<String, dynamic>;

          return LaundryPriceOption.fromJson({
            ...price,
            'tendichvu': service['tendichvu'],
            'mota': service['mota'],
            'thoigiandukien': service['thoigiandukien'],
            'tenloaidogiat': itemType['tenloaidogiat'],
            'tendonvitinh': unit['tendonvitinh'],
            'kyhieu': unit['kyhieu'],
          });
        })
        .toList(growable: false);
  }

  Future<List<LaundryOrderRecord>> getCustomerOrders() async {
    final user = _client.auth.currentUser;
    if (user == null) {
      return const [];
    }

    try {
      final rows = await _client
          .from('DonHang')
          .select(
            'DonHangID,BookingID,MaDonHang,TrangThai,ThanhTien,NgayTao,'
            'ChiTietDonHang('
            'SoLuong,KhoiLuong,DichVu(TenDichVu),'
            'LoaiDoGiat(TenLoaiDoGiat),DonViTinh(KyHieu)'
            ')',
          )
          .order('NgayTao', ascending: false);

      return (rows as List<dynamic>)
          .map(
            (row) => LaundryOrderRecord.fromJson(row as Map<String, dynamic>),
          )
          .toList(growable: false);
    } catch (e) {
      // Log error but don't throw, allow other queries to complete
      return const [];
    }
  }

  Future<List<LaundryOrderRecord>> getStaffOrders() => getCustomerOrders();

  Future<List<LaundryOrderRecord>> getCustomerHistory() async {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw const AuthException('Bạn cần đăng nhập để xem lịch sử.');
    }

    // Fetch both orders and bookings, but don't fail if one fails
    final results = await Future.wait([
      getCustomerOrders().catchError((_) => <LaundryOrderRecord>[]),
      _getBookings().catchError((_) => <LaundryOrderRecord>[]),
    ]);

    final orders = results[0];
    final orderBookingIds = orders
        .map((order) => order.bookingId)
        .whereType<int>()
        .toSet();
    final bookings = results[1].where(
      (booking) => !orderBookingIds.contains(booking.bookingId),
    );
    return [...orders, ...bookings]
      ..sort((left, right) => right.createdAt.compareTo(left.createdAt));
  }

  Future<List<LaundryOrderRecord>> getStaffQueue() async {
    final results = await Future.wait([getStaffOrders(), _getBookings()]);
    final pendingBookings = results[1].where(
      (booking) => booking.canCancelBooking,
    );
    return [...results[0], ...pendingBookings]
      ..sort((left, right) => right.createdAt.compareTo(left.createdAt));
  }

  Future<List<LaundryOrderRecord>> _getBookings() async {
    final user = _client.auth.currentUser;
    if (user == null) {
      return const [];
    }

    try {
      // Get bookings first
      final bookings = await _client
          .from('Booking')
          .select('BookingID,MaBooking,TrangThai,NgayTao')
          .order('NgayTao', ascending: false);

      // Then fetch ChiTietBooking for each booking
      final bookingIds = (bookings as List<dynamic>)
          .map((b) => (b as Map<String, dynamic>)['BookingID'] as int)
          .toList();

      final chiTietMap = <int, List<dynamic>>{};
      final linkedOrderMap = <int, Map<String, dynamic>>{};

      if (bookingIds.isNotEmpty) {
        final chiTietRows = await _client
            .from('ChiTietBooking')
            .select(
              'BookingID,SoLuong,KhoiLuong,ThanhTien,'
              'DichVu(TenDichVu),LoaiDoGiat(TenLoaiDoGiat),DonViTinh(KyHieu)',
            )
            .inFilter('BookingID', bookingIds);

        for (final row in chiTietRows as List<dynamic>) {
          final detail = row as Map<String, dynamic>;
          final bookingId = (detail['BookingID'] as num).toInt();
          chiTietMap.putIfAbsent(bookingId, () => []).add(detail);
        }

        // Fetch linked DonHang records for all bookings at once
        final linkedOrders = await _client
            .from('DonHang')
            .select('DonHangID,BookingID,TrangThai')
            .inFilter('BookingID', bookingIds);

        for (final row in linkedOrders as List<dynamic>) {
          final order = row as Map<String, dynamic>;
          final bookingId = (order['BookingID'] as num).toInt();
          linkedOrderMap[bookingId] = order;
        }
      }

      // Build LaundryOrderRecord with joined data
      return (bookings as List<dynamic>)
          .map((row) {
            final booking = row as Map<String, dynamic>;
            final bookingId = (booking['BookingID'] as num).toInt();
            final details = chiTietMap[bookingId] ?? const [];
            final linkedOrder = linkedOrderMap[bookingId];
            return LaundryOrderRecord.fromBookingJson({
              ...booking,
              'ChiTietBooking': details,
            }, linkedOrder: linkedOrder);
          })
          .toList(growable: false);
    } catch (e) {
      // Log error but don't throw, allow other queries to complete
      return const [];
    }
  }

  Future<void> transitionStatus({
    required int orderId,
    required String newStatus,
    String? reason,
  }) async {
    await _client.rpc(
      'transition_laundry_order',
      params: {
        'p_donhangid': orderId,
        'p_trangthaimoi': newStatus,
        'p_lydo': reason,
      },
    );
  }

  Future<void> confirmBooking(int bookingId, {required bool hasDetails}) async {
    await _client.rpc(
      hasDetails
          ? 'confirm_laundry_booking'
          : 'confirm_laundry_booking_without_details',
      params: {'p_bookingid': bookingId},
    );
  }

  Future<void> cancelBooking(int bookingId) async {
    await _client.rpc(
      'cancel_laundry_booking',
      params: {'p_bookingid': bookingId},
    );

    // Notify staff that the customer cancelled
    try {
      final user = _client.auth.currentUser;
      final customerName =
          user?.userMetadata?['full_name'] as String? ?? 'Khách hàng';
      await _notificationRepository.notifyStaffOfNewBooking(
        bookingId: bookingId,
        bookingNumber: 'bị hủy',
        customerName: customerName,
      );
    } catch (e) {
      debugPrint('Lỗi gửi thông báo hủy cho nhân viên: $e');
    }
  }

  Future<LaundryOrderDetails> getOrderDetails(int orderId) async {
    final order = await _client
        .from('DonHang')
        .select(
          'DonHangID,BookingID,MaDonHang,TrangThai,TongTien,DiemSuDung,'
          'TienGiamDoDiem,KhuyenMaiID,TienGiamKhuyenMai,PhiGiaoHang,'
          'ThanhTien,NgayTao,KhuyenMai(MaKhuyenMai),'
          'ChiTietDonHang('
          'SoLuong,KhoiLuong,DonGia,ThanhTien,'
          'DichVu(TenDichVu),'
          'LoaiDoGiat(TenLoaiDoGiat),'
          'DonViTinh(KyHieu)'
          ')',
        )
        .eq('DonHangID', orderId)
        .maybeSingle();

    if (order == null) throw StateError('Không tìm thấy đơn hàng.');

    // Lấy dữ liệu Booking riêng biệt nếu BookingID tồn tại
    Map<String, dynamic>? booking;
    final bookingId = (order['BookingID'] as num?)?.toInt();
    if (bookingId != null) {
      try {
        booking = await _client
            .from('Booking')
            .select('HinhThucNhanDo,DiaChiNhan,NgayHen,GioHen,GhiChu')
            .eq('BookingID', bookingId)
            .maybeSingle();
      } catch (e) {
        debugPrint('Lỗi lấy dữ liệu Booking $bookingId: $e');
        // Tiếp tục nếu không lấy được Booking
      }
    }

    List<dynamic> eventsList = [];
    try {
      final eventsResponse = await _client.rpc(
        'get_laundry_order_status_history',
        params: {'p_donhangid': orderId},
      );
      if (eventsResponse is List<dynamic>) {
        eventsList = eventsResponse;
      }
    } catch (e) {
      // RPC gọi thất bại, vẫn tiếp tục với danh sách trống
      debugPrint('Lỗi lấy lịch sử trạng thái đơn hàng $orderId: $e');
    }

    DateTime? appointment;
    if (booking != null &&
        booking['NgayHen'] != null &&
        booking['GioHen'] != null) {
      final date = DateTime.parse(booking['NgayHen'] as String);
      final timeStr = booking['GioHen'] as String;
      final timeParts = timeStr.split(':');
      appointment = DateTime(
        date.year,
        date.month,
        date.day,
        int.parse(timeParts[0]),
        int.parse(timeParts[1]),
      );
    }

    final details = order['ChiTietDonHang'] as List<dynamic>? ?? [];
    final items = details
        .map((entry) {
          final detail = entry as Map<String, dynamic>;
          final service = detail['DichVu'] as Map<String, dynamic>?;
          final itemType = detail['LoaiDoGiat'] as Map<String, dynamic>?;
          final unit = detail['DonViTinh'] as Map<String, dynamic>?;
          final measurement = detail['KhoiLuong'] ?? detail['SoLuong'];
          final unitPrice = detail['DonGia'] as num? ?? 0;
          final total = detail['ThanhTien'] as num? ?? 0;
          return LaundryOrderItem(
            serviceName: service?['TenDichVu'] as String? ?? 'Dịch vụ',
            itemTypeName: itemType?['TenLoaiDoGiat'] as String? ?? 'Đồ giặt',
            unitSymbol: unit?['KyHieu'] as String? ?? '',
            measurement: measurement as num,
            unitPriceVnd: unitPrice,
            totalVnd: total,
          );
        })
        .toList(growable: false);

    String? pickupMethod;
    String? address;
    String? notes;
    if (booking != null) {
      pickupMethod = booking['HinhThucNhanDo'] as String?;
      address = booking['DiaChiNhan'] as String?;
      notes = booking['GhiChu'] as String?;
    }

    return LaundryOrderDetails(
      order: LaundryOrderRecord.fromJson(order),
      events: eventsList
          .map(
            (event) =>
                LaundryOrderStatusEvent.fromJson(event as Map<String, dynamic>),
          )
          .toList(growable: false),
      pickupMethod: pickupMethod,
      paymentMethod: await _getPaymentMethod(orderId),
      address: address,
      appointment: appointment,
      notes: notes,
      items: items.isNotEmpty ? items : null,
      subtotalVnd: order['TongTien'] as num?,
      deliveryFeeVnd: order['PhiGiaoHang'] as num? ?? 0,
      pointsUsed: (order['DiemSuDung'] as num?)?.toInt() ?? 0,
      pointsDiscountVnd: order['TienGiamDoDiem'] as num? ?? 0,
      promotionDiscountVnd: order['TienGiamKhuyenMai'] as num? ?? 0,
      promotionApplied: order['KhuyenMaiID'] != null,
      promotionCode:
          (order['KhuyenMai'] as Map<String, dynamic>?)?['MaKhuyenMai']
              as String?,
      finalTotalVnd: order['ThanhTien'] as num?,
    );
  }

  Future<LaundryOrderDetails> getBookingDetails(int bookingId) async {
    final booking = await _client
        .from('Booking')
        .select(
          'BookingID,MaBooking,TrangThai,NgayTao,HinhThucNhanDo,DiaChiNhan,NgayHen,GioHen,GhiChu,'
          'DiemSuDung,TienGiamDoDiem,KhuyenMaiID,KhuyenMai(MaKhuyenMai),'
          'ChiTietBooking('
          'SoLuong,KhoiLuong,DonGia,ThanhTien,'
          'DichVu(TenDichVu),'
          'LoaiDoGiat(TenLoaiDoGiat),'
          'DonViTinh(KyHieu)'
          ')',
        )
        .eq('BookingID', bookingId)
        .maybeSingle();

    if (booking == null) throw StateError('Không tìm thấy yêu cầu đặt giặt.');

    final linkedOrder = await _client
        .from('DonHang')
        .select(
          'DonHangID,TrangThai,TongTien,DiemSuDung,TienGiamDoDiem,KhuyenMaiID,'
          'TienGiamKhuyenMai,PhiGiaoHang,ThanhTien,KhuyenMai(MaKhuyenMai)',
        )
        .eq('BookingID', bookingId)
        .maybeSingle();
    final record = LaundryOrderRecord.fromBookingJson(
      booking,
      linkedOrder: linkedOrder,
    );
    final linkedOrderId = (linkedOrder?['DonHangID'] as num?)?.toInt();
    var events = <dynamic>[];
    if (linkedOrderId != null) {
      try {
        final eventsResponse = await _client.rpc(
          'get_laundry_order_status_history',
          params: {'p_donhangid': linkedOrderId},
        );
        events = eventsResponse is List<dynamic> ? eventsResponse : <dynamic>[];
      } catch (e) {
        debugPrint('Lỗi lấy lịch sử trạng thái đơn hàng $linkedOrderId: $e');
      }
    }

    DateTime? appointment;
    if (booking['NgayHen'] != null && booking['GioHen'] != null) {
      final date = DateTime.parse(booking['NgayHen'] as String);
      final timeStr = booking['GioHen'] as String;
      final timeParts = timeStr.split(':');
      appointment = DateTime(
        date.year,
        date.month,
        date.day,
        int.parse(timeParts[0]),
        int.parse(timeParts[1]),
      );
    }

    final details = booking['ChiTietBooking'] as List<dynamic>? ?? [];
    final items = details
        .map((entry) {
          final detail = entry as Map<String, dynamic>;
          final service = detail['DichVu'] as Map<String, dynamic>?;
          final itemType = detail['LoaiDoGiat'] as Map<String, dynamic>?;
          final unit = detail['DonViTinh'] as Map<String, dynamic>?;
          final measurement = detail['KhoiLuong'] ?? detail['SoLuong'];
          final unitPrice = detail['DonGia'] as num? ?? 0;
          final total = detail['ThanhTien'] as num? ?? 0;
          return LaundryOrderItem(
            serviceName: service?['TenDichVu'] as String? ?? 'Dịch vụ',
            itemTypeName: itemType?['TenLoaiDoGiat'] as String? ?? 'Đồ giặt',
            unitSymbol: unit?['KyHieu'] as String? ?? '',
            measurement: measurement as num,
            unitPriceVnd: unitPrice,
            totalVnd: total,
          );
        })
        .toList(growable: false);

    return LaundryOrderDetails(
      order: record,
      events: events
          .map(
            (event) =>
                LaundryOrderStatusEvent.fromJson(event as Map<String, dynamic>),
          )
          .toList(growable: false),
      pickupMethod: booking['HinhThucNhanDo'] as String?,
      paymentMethod: linkedOrderId == null
          ? null
          : await _getPaymentMethod(linkedOrderId),
      address: booking['DiaChiNhan'] as String?,
      appointment: appointment,
      notes: booking['GhiChu'] as String?,
      items: items.isNotEmpty ? items : null,
      subtotalVnd:
          linkedOrder?['TongTien'] as num? ??
          details.fold<num>(
            0,
            (total, item) =>
                total +
                ((item as Map<String, dynamic>)['ThanhTien'] as num? ?? 0),
          ),
      deliveryFeeVnd: linkedOrder?['PhiGiaoHang'] as num? ?? 0,
      pointsUsed:
          (linkedOrder?['DiemSuDung'] as num?)?.toInt() ??
          (booking['DiemSuDung'] as num?)?.toInt() ??
          0,
      pointsDiscountVnd:
          linkedOrder?['TienGiamDoDiem'] as num? ??
          booking['TienGiamDoDiem'] as num? ??
          0,
      promotionDiscountVnd: linkedOrder?['TienGiamKhuyenMai'] as num?,
      promotionApplied:
          linkedOrder?['KhuyenMaiID'] != null || booking['KhuyenMaiID'] != null,
      promotionCode:
          ((linkedOrder?['KhuyenMai'] as Map<String, dynamic>?) ??
                  (booking['KhuyenMai']
                      as Map<String, dynamic>?))?['MaKhuyenMai']
              as String?,
      finalTotalVnd: linkedOrder?['ThanhTien'] as num?,
    );
  }

  Future<String?> _getPaymentMethod(int orderId) async {
    final rows = await _client
        .from('ThanhToan')
        .select('PhuongThuc')
        .eq('DonHangID', orderId)
        .order('ThoiGian', ascending: false)
        .limit(1);
    final payments = rows as List<dynamic>;
    if (payments.isEmpty) return null;
    return (payments.first as Map<String, dynamic>)['PhuongThuc'] as String?;
  }

  Future<CreatedLaundryBooking> submitOrder({
    required int priceId,
    required num measurement,
    required String pickupMethod,
    required String? address,
    required DateTime appointment,
    required String notes,
    required String idempotencyKey,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw const AuthException('Bạn cần đăng nhập trước khi đặt đơn.');
    }

    final fullName = user.userMetadata?['full_name'] as String? ?? 'Khách hàng';

    await _client.rpc(
      'complete_google_customer_profile',
      params: {'p_full_name': fullName},
    );

    final result = await _client.rpc(
      'submit_laundry_order',
      params: {
        'p_banggiaid': priceId,
        'p_measurement': measurement,
        'p_hinhthucnhando': pickupMethod,
        'p_diachinhan': address,
        'p_ngayhen': _formatDate(appointment),
        'p_giohen': _formatTime(appointment),
        'p_ghichu': notes.trim().isEmpty ? null : notes.trim(),
        'p_idempotency_key': idempotencyKey,
      },
    );

    final booking = CreatedLaundryBooking.fromJson(
      result as Map<String, dynamic>,
    );

    // Send notification to customer
    await _notificationRepository
        .createNotification(
          title: 'Đơn hàng được tạo thành công',
          message:
              'Đơn hàng ${booking.bookingNumber} đã được đặt. Hãy theo dõi trạng thái của bạn.',
          orderId: booking.bookingId,
          type: 'order_created',
        )
        .catchError((e) => debugPrint('Lỗi gửi thông báo tạo đơn hàng: $e'));

    // Send notification to staff
    await _notificationRepository
        .notifyStaffOfNewBooking(
          bookingId: booking.bookingId,
          bookingNumber: booking.bookingNumber,
          customerName: fullName,
        )
        .catchError((e) => debugPrint('Lỗi thông báo cho nhân viên: $e'));

    NotificationService.instance.showInApp(
      LaundryNotification(
        id: -booking.bookingId,
        title: 'Đơn hàng được tạo thành công',
        message:
            'Đơn hàng ${booking.bookingNumber} đã được đặt. Hãy theo dõi trạng thái của bạn.',
        sentAt: DateTime.now(),
        isRead: false,
        type: 'order_created',
      ),
    );

    return booking;
  }

  Future<CreatedLaundryBooking> submitCartOrder({
    required Iterable<CartItem> items,
    required bool usePoints,
    required String paymentMethod,
    required String pickupMethod,
    required String? address,
    required DateTime appointment,
    required String notes,
    required String idempotencyKey,
    String? promotionCode,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw const AuthException('Bạn cần đăng nhập trước khi đặt đơn.');
    }

    final fullName = user.userMetadata?['full_name'] as String? ?? 'Khách hàng';

    await _client.rpc(
      'complete_google_customer_profile',
      params: {'p_full_name': fullName},
    );

    final itemsJson = items.map((item) => item.toJson()).toList();
    final trimmedNotes = notes.trim().isEmpty ? null : notes.trim();

    final result = await _client.rpc(
      'submit_laundry_booking_request',
      params: {
        'p_items': itemsJson,
        'p_use_points': usePoints,
        'p_phuongthucthanhtoan': paymentMethod,
        'p_hinhthucnhando': pickupMethod,
        'p_diachinhan': address,
        'p_ngayhen': _formatDate(appointment),
        'p_giohen': _formatTime(appointment),
        'p_ghichu': trimmedNotes,
        'p_idempotency_key': idempotencyKey,
        'p_makhuyenmai': promotionCode?.trim().isNotEmpty == true
            ? promotionCode!.trim()
            : null,
      },
    );

    final booking = CreatedLaundryBooking.fromJson(
      result as Map<String, dynamic>,
    );

    // Send notification to customer
    await _notificationRepository
        .createNotification(
          title: 'Đơn hàng được tạo thành công',
          message:
              'Đơn hàng ${booking.bookingNumber} đã được đặt. Hãy theo dõi trạng thái của bạn.',
          orderId: booking.bookingId,
          type: 'order_created',
        )
        .catchError((e) => debugPrint('Lỗi gửi thông báo tạo đơn hàng: $e'));

    // Send notification to staff
    await _notificationRepository
        .notifyStaffOfNewBooking(
          bookingId: booking.bookingId,
          bookingNumber: booking.bookingNumber,
          customerName: fullName,
        )
        .catchError((e) => debugPrint('Lỗi thông báo cho nhân viên: $e'));

    NotificationService.instance.showInApp(
      LaundryNotification(
        id: -booking.bookingId,
        title: 'Đơn hàng được tạo thành công',
        message:
            'Đơn hàng ${booking.bookingNumber} đã được đặt. Hãy theo dõi trạng thái của bạn.',
        sentAt: DateTime.now(),
        isRead: false,
        type: 'order_created',
      ),
    );

    return booking;
  }

  Future<CreatedLaundryBooking> submitBookingWithoutDetails({
    required String paymentMethod,
    required String pickupMethod,
    required String? address,
    required DateTime appointment,
    required String notes,
    required String idempotencyKey,
    String? promotionCode,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw const AuthException('Bạn cần đăng nhập trước khi đặt đơn.');
    }

    final fullName = user.userMetadata?['full_name'] as String? ?? 'Khách hàng';

    await _client.rpc(
      'complete_google_customer_profile',
      params: {'p_full_name': fullName},
    );

    final result = await _client.rpc(
      'submit_laundry_booking_request',
      params: {
        'p_items': null,
        'p_use_points': false,
        'p_phuongthucthanhtoan': paymentMethod,
        'p_hinhthucnhando': pickupMethod,
        'p_diachinhan': address,
        'p_ngayhen': _formatDate(appointment),
        'p_giohen': _formatTime(appointment),
        'p_ghichu': notes.trim().isEmpty ? null : notes.trim(),
        'p_idempotency_key': idempotencyKey,
        'p_makhuyenmai': promotionCode?.trim().isNotEmpty == true
            ? promotionCode!.trim()
            : null,
      },
    );

    final booking = CreatedLaundryBooking.fromJson(
      result as Map<String, dynamic>,
    );

    // Send notification to customer
    await _notificationRepository
        .createNotification(
          title: 'Đơn hàng được tạo thành công',
          message:
              'Đơn hàng ${booking.bookingNumber} đã được đặt. Hãy theo dõi trạng thái của bạn.',
          orderId: booking.bookingId,
          type: 'order_created',
        )
        .catchError((e) => debugPrint('Lỗi gửi thông báo tạo đơn hàng: $e'));

    // Send notification to staff
    await _notificationRepository
        .notifyStaffOfNewBooking(
          bookingId: booking.bookingId,
          bookingNumber: booking.bookingNumber,
          customerName: fullName,
        )
        .catchError((e) => debugPrint('Lỗi thông báo cho nhân viên: $e'));

    return booking;
  }

  String _formatDate(DateTime date) {
    final localDate = date.toLocal();
    return '${localDate.year.toString().padLeft(4, '0')}-'
        '${localDate.month.toString().padLeft(2, '0')}-'
        '${localDate.day.toString().padLeft(2, '0')}';
  }

  String _formatTime(DateTime date) {
    final localDate = date.toLocal();
    return '${localDate.hour.toString().padLeft(2, '0')}:'
        '${localDate.minute.toString().padLeft(2, '0')}:00';
  }
}
