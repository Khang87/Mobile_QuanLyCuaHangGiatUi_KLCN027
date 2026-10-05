import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LaundryNotification {
  const LaundryNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.sentAt,
    required this.isRead,
    this.orderId,
    this.type,
  });

  final int id;
  final String title;
  final String message;
  final DateTime sentAt;
  final bool isRead;
  final int? orderId;
  final String? type;

  factory LaundryNotification.fromJson(Map<String, dynamic> json) {
    // Handle both lowercase (from view select) and capitalized (from realtime table insert)
    return LaundryNotification(
      id: (json['thongbaoid'] ?? json['ThongBaoID'] as num).toInt(),
      title: json['tieude'] ?? json['TieuDe'] as String,
      message: json['noidung'] ?? json['NoiDung'] as String,
      sentAt: DateTime.parse((json['thoigiangui'] ?? json['ThoiGianGui']) as String),
      isRead: json['dadoc'] ?? json['DaDoc'] as bool,
      orderId: ((json['donhangid'] ?? json['DonHangID']) as num?)?.toInt(),
      type: json['loaithongbao'] ?? json['LoaiThongBao'] as String?,
    );
  }
}

class NotificationRepository {
  NotificationRepository({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  Future<List<LaundryNotification>> getNotifications() async {
    final rows = await _client
        .from('thongbao')
        .select(
          'thongbaoid,tieude,noidung,thoigiangui,dadoc,donhangid,loaithongbao',
        )
        .order('thoigiangui', ascending: false);

    return (rows as List<dynamic>)
        .map((row) => LaundryNotification.fromJson(row as Map<String, dynamic>))
        .toList(growable: false);
  }

  Future<int> getUnreadCount() async {
    final rows = await _client
        .from('thongbao')
        .select('thongbaoid')
        .eq('dadoc', false);
    return (rows as List<dynamic>).length;
  }

  Future<void> markRead(int notificationId) async {
    await _client
        .from('thongbao')
        .update({'dadoc': true})
        .eq('thongbaoid', notificationId);
  }

  Future<void> markAllRead() async {
    await _client.from('thongbao').update({'dadoc': true}).eq('dadoc', false);
  }

  Future<void> markManyRead(Iterable<int> notificationIds) async {
    final ids = notificationIds.toList(growable: false);
    if (ids.isEmpty) return;
    await _client
        .from('thongbao')
        .update({'dadoc': true})
        .inFilter('thongbaoid', ids);
  }

  Future<void> deleteMany(Iterable<int> notificationIds) async {
    final ids = notificationIds.toList(growable: false);
    if (ids.isEmpty) return;
    await _client.from('thongbao').delete().inFilter('thongbaoid', ids);
  }

  Future<void> createNotification({
    required String title,
    required String message,
    required int? orderId,
    String? type,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) return;

    try {
      // Get taikhoanid from userauthid
      final taikhoanId = await _client.rpc('get_taikhoanid_from_auth') as int?;
      if (taikhoanId == null) {
        debugPrint('Failed to get taikhoanid for notification');
        return;
      }

      await _client.from('thongbao').insert({
        'taikhoanid': taikhoanId,
        'tieude': title,
        'noidung': message,
        'thoigiangui': DateTime.now().toUtc().toIso8601String(),
        'dadoc': false,
        'donhangid': orderId,
        'loaithongbao': type,
      });
    } catch (e) {
      debugPrint('Failed to create notification: $e');
    }
  }

  Future<void> notifyStaffOfNewBooking({
    required int bookingId,
    required String bookingNumber,
    required String customerName,
  }) async {
    try {
      // Gọi RPC để tạo thông báo cho tất cả staff
      await _client.rpc(
        'notify_staff_new_booking',
        params: {
          'p_bookingid': bookingId,
          'p_booking_number': bookingNumber,
          'p_customer_name': customerName,
        },
      );
    } catch (e) {
      debugPrint('Failed to notify staff of new booking: $e');
    }
  }
}
