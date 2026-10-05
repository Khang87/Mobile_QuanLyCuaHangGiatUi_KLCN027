import 'package:flutter/material.dart';
import 'package:app_quanly_giaiui/core/theme/app_colors.dart';
import 'package:app_quanly_giaiui/core/theme/app_typography.dart';
import 'package:app_quanly_giaiui/features/auth/data/auth_repository.dart';
import 'package:app_quanly_giaiui/features/order/data/order_repository.dart';

class StaffOrderQueueScreen extends StatefulWidget {
  const StaffOrderQueueScreen({super.key});

  @override
  State<StaffOrderQueueScreen> createState() => _StaffOrderQueueScreenState();
}

class _StaffOrderQueueScreenState extends State<StaffOrderQueueScreen> {
  final _authRepository = AuthRepository();
  final _orderRepository = OrderRepository();
  late Future<_StaffQueueData> _queueFuture;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _queueFuture = _loadQueue();
  }

  Future<_StaffQueueData> _loadQueue() async {
    final roles = await _authRepository.getCurrentRoles();
    if (!roles.any({'Nhân viên', 'Quản lý', 'Chủ cửa hàng'}.contains)) {
      return _StaffQueueData(roles: roles, orders: const []);
    }
    final orders = await _orderRepository.getStaffQueue();
    return _StaffQueueData(roles: roles, orders: orders);
  }

  Future<void> _refresh() async {
    final future = _loadQueue();
    setState(() {
      _queueFuture = future;
    });
    await future;
  }

  List<String> _nextStatuses(String status) {
    return switch (status) {
      'Chờ tiếp nhận' => ['Đã tiếp nhận', 'Đã hủy'],
      'Đã tiếp nhận' => ['Đang giặt', 'Đã hủy'],
      'Đang giặt' => ['Hoàn thành giặt'],
      'Hoàn thành giặt' => ['Đang giao', 'Đã giao'],
      'Đang giao' => ['Đã giao'],
      _ => const [],
    };
  }

  Future<void> _transition(LaundryOrderRecord order, String newStatus) async {
    String? reason;
    if (newStatus == 'Đã hủy') {
      reason = await _requestCancellationReason();
      if (reason == null) return;
    }

    setState(() => _isUpdating = true);
    try {
      if (order.orderId == null && order.bookingId != null) {
        await _orderRepository.confirmBooking(
          order.bookingId!,
          hasDetails: order.hasLaundryDetails,
        );
      } else if (order.orderId != null) {
        await _orderRepository.transitionStatus(
          orderId: order.orderId!,
          newStatus: newStatus,
          reason: reason,
        );
      }
      await _refresh();
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Không thể cập nhật đơn: $error')),
        );
      }
    } finally {
      if (mounted) setState(() => _isUpdating = false);
    }
  }

  Future<String?> _requestCancellationReason() async {
    final controller = TextEditingController();
    final reason = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Lý do hủy đơn'),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLength: 500,
          maxLines: 3,
          decoration: const InputDecoration(hintText: 'Nhập lý do'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Quay lại'),
          ),
          FilledButton(
            onPressed: () {
              final value = controller.text.trim();
              if (value.isNotEmpty) Navigator.pop(dialogContext, value);
            },
            child: const Text('Xác nhận hủy'),
          ),
        ],
      ),
    );
    controller.dispose();
    return reason;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Yêu cầu và đơn hàng'),
        actions: [
          IconButton(
            tooltip: 'Làm mới',
            onPressed: _refresh,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: FutureBuilder<_StaffQueueData>(
        future: _queueFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return _QueueState(
              message: 'Không tải được hàng đợi đơn hàng.',
              action: TextButton(
                onPressed: _refresh,
                child: const Text('Thử lại'),
              ),
            );
          }

          final queue = snapshot.data!;
          if (!queue.roles.any(
            {'Nhân viên', 'Quản lý', 'Chủ cửa hàng'}.contains,
          )) {
            return const _QueueState(
              icon: Icons.lock_outline,
              message: 'Tài khoản không có quyền vận hành đơn hàng.',
            );
          }
          if (queue.orders.isEmpty) {
            return const _QueueState(
              icon: Icons.receipt_long_outlined,
              message: 'Chưa có đơn hàng.',
            );
          }

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: queue.orders.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (context, index) => _StaffOrderCard(
                order: queue.orders[index],
                nextStatuses: _nextStatuses(queue.orders[index].status),
                isUpdating: _isUpdating,
                onTransition: (status) =>
                    _transition(queue.orders[index], status),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _StaffQueueData {
  const _StaffQueueData({required this.roles, required this.orders});

  final List<String> roles;
  final List<LaundryOrderRecord> orders;
}

class _StaffOrderCard extends StatelessWidget {
  const _StaffOrderCard({
    required this.order,
    required this.nextStatuses,
    required this.isUpdating,
    required this.onTransition,
  });

  final LaundryOrderRecord order;
  final List<String> nextStatuses;
  final bool isUpdating;
  final ValueChanged<String> onTransition;

  @override
  Widget build(BuildContext context) {
    final isBooking = order.orderId == null;
    final actions = isBooking ? const ['Xác nhận yêu cầu'] : nextStatuses;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.divider),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '#${order.orderNumber}',
                  style: AppTypography.title,
                ),
              ),
              Text(order.status, style: AppTypography.bodySmall),
            ],
          ),
          const SizedBox(height: 8),
          Text(order.lineDescription, style: AppTypography.bodyText),
          const SizedBox(height: 8),
          Text(
            '${order.totalVnd.toStringAsFixed(0)} đ',
            style: AppTypography.title.copyWith(color: AppColors.primary),
          ),
          if (actions.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: actions.map((status) {
                return OutlinedButton(
                  onPressed: isUpdating
                      ? null
                      : () => onTransition(isBooking ? 'DaXacNhan' : status),
                  child: Text(status),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }
}

class _QueueState extends StatelessWidget {
  const _QueueState({
    required this.message,
    this.icon = Icons.inbox_outlined,
    this.action,
  });

  final String message;
  final IconData icon;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 48, color: AppColors.textMuted),
          const SizedBox(height: 12),
          Text(message, style: AppTypography.bodyText),
          if (action != null) ...[const SizedBox(height: 10), action!],
        ],
      ),
    );
  }
}
