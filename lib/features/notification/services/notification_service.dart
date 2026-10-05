import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:app_quanly_giaiui/features/notification/data/notification_repository.dart';

class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  final _client = Supabase.instance.client;
  final _newNotificationController =
      StreamController<LaundryNotification>.broadcast();

  RealtimeChannel? _channel;
  StreamSubscription<AuthState>? _authSubscription;
  int? _subscribedTaiKhoanId;
  bool _isInitialized = false;

  Stream<LaundryNotification> get onNewNotification =>
      _newNotificationController.stream;

  void showInApp(LaundryNotification notification) {
    _newNotificationController.add(notification);
  }

  static const String _notificationEnabledKey = 'notification_enabled';
  bool _notificationEnabled = true;

  Future<void> initialize() async {
    if (_isInitialized) return;

    final prefs = await SharedPreferences.getInstance();
    _notificationEnabled = prefs.getBool(_notificationEnabledKey) ?? true;

    _authSubscription = _client.auth.onAuthStateChange.listen((_) {
      _subscribeForCurrentUser();
    });

    _isInitialized = true;
    await _subscribeForCurrentUser();
  }

  Future<void> _subscribeForCurrentUser() async {
    final user = _client.auth.currentUser;
    if (user == null) {
      await _unsubscribeCurrentChannel();
      return;
    }

    int? taikhoanId;
    try {
      final result = await _client.rpc('get_taikhoanid_from_auth');
      taikhoanId = result as int?;
      if (taikhoanId == null) return;
    } catch (e) {
      debugPrint('Failed to get taikhoanid: $e');
      return;
    }

    if (_subscribedTaiKhoanId == taikhoanId && _channel != null) {
      return;
    }

    await _unsubscribeCurrentChannel();

    _channel = _client
        .channel('notifications:${user.id}')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'ThongBao',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'TaiKhoanID',
            value: taikhoanId,
          ),
          callback: (payload) {
            final notification = LaundryNotification.fromJson(
            payload.newRecord,
            );
            _newNotificationController.add(notification);
          },
        )
        .subscribe();

    _subscribedTaiKhoanId = taikhoanId;
  }

  Future<void> dispose() async {
    await _authSubscription?.cancel();
    await _unsubscribeCurrentChannel();
    await _newNotificationController.close();
    _isInitialized = false;
  }

  Future<void> _unsubscribeCurrentChannel() async {
    await _channel?.unsubscribe();
    _channel = null;
    _subscribedTaiKhoanId = null;
  }

  Future<bool> isNotificationEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_notificationEnabledKey) ?? true;
  }

  Future<void> setNotificationEnabled(bool enabled) async {
    _notificationEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notificationEnabledKey, enabled);
  }

  bool get notificationEnabled => _notificationEnabled;

  Future<void> playNotificationSound() async {
    if (!_notificationEnabled) return;

    try {
      await SystemSound.play(SystemSoundType.alert);
    } catch (e) {
      debugPrint('Failed to play notification sound: $e');
    }
  }
}
