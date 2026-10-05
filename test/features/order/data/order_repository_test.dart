import 'package:flutter_test/flutter_test.dart';
import 'package:app_quanly_giaiui/features/order/data/order_repository.dart';

void main() {
  test('parses service description and estimated processing time', () {
    final price = LaundryPriceOption.fromJson({
      'banggiaid': 1,
      'dichvuid': 2,
      'tendichvu': 'Giặt thường',
      'mota': 'Giặt và sấy quần áo thường',
      'thoigiandukien': 45,
      'loaidogiatid': 3,
      'tenloaidogiat': 'Áo sơ mi',
      'donvitinhid': 4,
      'tendonvitinh': 'Cái',
      'kyhieu': 'cái',
      'dongia': 15000,
    });

    expect(price.serviceDescription, 'Giặt và sấy quần áo thường');
    expect(price.processingTimeMinutes, 45);
  });

  test('parses the Booking payload returned by submit_laundry_order', () {
    final booking = CreatedLaundryBooking.fromJson({
      'bookingid': 11,
      'mabooking': 'BK-20260929122336-17194d74',
      'trangthai': 'ChoTiepNhan',
      'thanhtien': 10000,
      'diemsudung': 500,
      'tiengiamdodiem': 5000,
      'thanhtoan': 5000,
    });

    expect(booking.bookingId, 11);
    expect(booking.bookingNumber, 'BK-20260929122336-17194d74');
    expect(booking.estimatedTotalVnd, 10000);
    expect(booking.pointsUsed, 500);
    expect(booking.pointsDiscountVnd, 5000);
    expect(booking.finalTotalVnd, 5000);
  });

  test('uses the linked order status for a booking detail', () {
    final order = LaundryOrderRecord.fromBookingJson(
      {
        'BookingID': 99,
        'MaBooking': 'BK-20261003120333-e717c494',
        'TrangThai': 'ChoTiepNhan',
        'NgayTao': '2026-10-03T12:03:33',
        'ChiTietBooking': <dynamic>[],
      },
      linkedOrder: {'DonHangID': 33, 'TrangThai': 'Đã giao'},
    );

    expect(order.bookingId, 99);
    expect(order.orderId, 33);
    expect(order.status, 'Đã giao');
  });

  test('parses status-history RPC rows without changing event fields', () {
    final event = LaundryOrderStatusEvent.fromJson({
      'trangthaicu': 'Chờ tiếp nhận',
      'trangthaimoi': 'Đã tiếp nhận',
      'lydo': 'Đơn đã được cửa hàng xác nhận',
      'thoigian': '2026-10-03T07:00:00',
    });

    expect(event.previousStatus, 'Chờ tiếp nhận');
    expect(event.status, 'Đã tiếp nhận');
    expect(event.note, 'Đơn đã được cửa hàng xác nhận');
    expect(event.occurredAt, DateTime(2026, 10, 3, 7));
  });
}
