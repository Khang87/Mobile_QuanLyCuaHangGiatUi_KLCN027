import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:app_quanly_giaiui/core/constants/app_strings.dart';
import 'package:app_quanly_giaiui/core/navigation/app_routes.dart';
import 'package:app_quanly_giaiui/core/theme/app_colors.dart';
import 'package:app_quanly_giaiui/core/theme/app_typography.dart';
import 'package:app_quanly_giaiui/features/notification/data/notification_repository.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({required this.unreadNotificationCount, super.key});

  final ValueNotifier<int> unreadNotificationCount;

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final _repository = NotificationRepository();
  late Future<List<LaundryNotification>> _notificationsFuture;
  final Set<int> _selectedNotificationIds = {};
  List<int> _loadedNotificationIds = [];
  bool _isBusy = false;

  @override
  void initState() {
    super.initState();
    _notificationsFuture = _loadNotifications();
  }

  Future<List<LaundryNotification>> _loadNotifications() async {
    final notifications = await _repository.getNotifications();
    if (mounted) {
      _loadedNotificationIds = notifications
          .map((notification) => notification.id)
          .toList(growable: false);
      _selectedNotificationIds.retainAll(_loadedNotificationIds);
      widget.unreadNotificationCount.value = notifications
          .where((notification) => !notification.isRead)
          .length;
    }
    return notifications;
  }

  Future<void> _refresh() async {
    final future = _loadNotifications();
    setState(() {
      _notificationsFuture = future;
    });
    await future;
  }

  Future<void> _markAllRead() async {
    setState(() => _isBusy = true);
    try {
      await _repository.markAllRead();
      await _refresh();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Không thể cập nhật thông báo.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  Future<void> _markSelectedRead() async {
    if (_selectedNotificationIds.isEmpty) return;
    setState(() => _isBusy = true);
    try {
      await _repository.markManyRead(_selectedNotificationIds);
      _selectedNotificationIds.clear();
      await _refresh();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Không thể cập nhật thông báo.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  Future<void> _deleteSelected() async {
    if (_selectedNotificationIds.isEmpty) return;
    final count = _selectedNotificationIds.length;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Xóa thông báo đã chọn?'),
        content: Text(
          'Bạn sắp xóa $count thông báo. Thao tác này không thể hoàn tác.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _isBusy = true);
    try {
      await _repository.deleteMany(_selectedNotificationIds);
      _selectedNotificationIds.clear();
      await _refresh();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Không thể xóa thông báo đã chọn.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  void _toggleSelection(int notificationId, bool? selected) {
    setState(() {
      if (selected ?? false) {
        _selectedNotificationIds.add(notificationId);
      } else {
        _selectedNotificationIds.remove(notificationId);
      }
    });
  }

  void _toggleAllSelection() {
    setState(() {
      if (_selectedNotificationIds.length == _loadedNotificationIds.length) {
        _selectedNotificationIds.clear();
      } else {
        _selectedNotificationIds
          ..clear()
          ..addAll(_loadedNotificationIds);
      }
    });
  }

  Future<void> _openNotification(LaundryNotification notification) async {
    if (!notification.isRead) {
      try {
        await _repository.markRead(notification.id);
        await _refresh();
      } catch (_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Không thể cập nhật thông báo.')),
          );
        }
      }
    }

    if (mounted && notification.orderId != null) {
      context.pushNamed(
        AppRoutes.trackingDetail,
        pathParameters: {'id': notification.orderId.toString()},
      );
    }
  }

  String _timeLabel(DateTime value) {
    final difference = DateTime.now().difference(value.toLocal());
    if (difference.inMinutes < 1) return 'Vừa xong';
    if (difference.inHours < 1) return '${difference.inMinutes} phút trước';
    if (difference.inDays < 1) return '${difference.inHours} giờ trước';
    if (difference.inDays < 7) return '${difference.inDays} ngày trước';
    final local = value.toLocal();
    return '${local.day.toString().padLeft(2, '0')}/'
        '${local.month.toString().padLeft(2, '0')}/${local.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.notifications),
        actions: [
          Tooltip(
            message: 'Chọn tất cả thông báo',
            child: Checkbox(
              value:
                  _selectedNotificationIds.isNotEmpty &&
                  _selectedNotificationIds.length ==
                      _loadedNotificationIds.length,
              tristate:
                  _selectedNotificationIds.isNotEmpty &&
                  _selectedNotificationIds.length <
                      _loadedNotificationIds.length,
              onChanged: _isBusy || _loadedNotificationIds.isEmpty
                  ? null
                  : (_) => _toggleAllSelection(),
            ),
          ),
          IconButton(
            tooltip: 'Đánh dấu đã đọc',
            onPressed: _isBusy || _selectedNotificationIds.isEmpty
                ? null
                : _markSelectedRead,
            icon: const Icon(Icons.mark_email_read_outlined),
          ),
          IconButton(
            tooltip: 'Đánh dấu tất cả đã đọc',
            onPressed: _isBusy ? null : _markAllRead,
            icon: _isBusy
                ? const SizedBox.square(
                    dimension: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.done_all),
          ),
          IconButton(
            tooltip: 'Xóa thông báo đã chọn',
            onPressed: _isBusy || _selectedNotificationIds.isEmpty
                ? null
                : _deleteSelected,
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
      body: FutureBuilder<List<LaundryNotification>>(
        future: _notificationsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return _NotificationState(
              icon: Icons.cloud_off_outlined,
              text: 'Không tải được thông báo.',
              action: TextButton(
                onPressed: () => setState(() {
                  _notificationsFuture = _loadNotifications();
                }),
                child: const Text('Thử lại'),
              ),
            );
          }

          final notifications = snapshot.data ?? const <LaundryNotification>[];
          if (notifications.isEmpty) {
            return RefreshIndicator(
              onRefresh: _refresh,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 180),
                  _NotificationState(
                    icon: Icons.notifications_off_outlined,
                    text: AppStrings.noNotifications,
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: notifications.length,
              separatorBuilder: (context, index) =>
                  const Divider(height: 1, color: AppColors.divider),
              itemBuilder: (context, index) {
                final notification = notifications[index];
                final isSelected = _selectedNotificationIds.contains(
                  notification.id,
                );
                return ListTile(
                  tileColor: isSelected
                      ? AppColors.primaryLight
                      : notification.isRead
                      ? AppColors.surface
                      : AppColors.primaryExtraLight,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 8,
                  ),
                  leading: CircleAvatar(
                    backgroundColor: notification.isRead
                        ? AppColors.border
                        : AppColors.primary,
                    foregroundColor: Colors.white,
                    child: Icon(_iconFor(notification.type)),
                  ),
                  trailing: Checkbox(
                    value: isSelected,
                    onChanged: _isBusy
                        ? null
                        : (selected) =>
                              _toggleSelection(notification.id, selected),
                  ),
                  title: Text(
                    notification.title,
                    style: AppTypography.title.copyWith(
                      fontWeight: notification.isRead
                          ? FontWeight.normal
                          : FontWeight.bold,
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 5),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(notification.message),
                        const SizedBox(height: 6),
                        Text(
                          _timeLabel(notification.sentAt),
                          style: AppTypography.caption.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  onTap: () {
                    if (_selectedNotificationIds.isNotEmpty) {
                      _toggleSelection(notification.id, !isSelected);
                    } else {
                      _openNotification(notification);
                    }
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }

  IconData _iconFor(String? type) {
    final normalized = (type ?? '').toLowerCase();
    if (normalized.contains('giao')) return Icons.local_shipping_outlined;
    if (normalized.contains('thanh')) return Icons.payments_outlined;
    return Icons.local_laundry_service_outlined;
  }
}

class _NotificationState extends StatelessWidget {
  const _NotificationState({
    required this.icon,
    required this.text,
    this.action,
  });

  final IconData icon;
  final String text;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 52, color: AppColors.textMuted),
          const SizedBox(height: 14),
          Text(
            text,
            style: AppTypography.bodyText.copyWith(color: AppColors.textMuted),
          ),
          if (action != null) ...[const SizedBox(height: 10), action!],
        ],
      ),
    );
  }
}
