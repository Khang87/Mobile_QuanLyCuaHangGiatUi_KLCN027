import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:app_quanly_giaiui/core/constants/app_strings.dart';
import 'package:app_quanly_giaiui/core/navigation/app_routes.dart';
import 'package:app_quanly_giaiui/core/theme/app_colors.dart';
import 'package:app_quanly_giaiui/core/theme/app_typography.dart';
import 'package:app_quanly_giaiui/core/widgets/status_badge.dart';
import 'package:app_quanly_giaiui/features/order/data/order_repository.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key, this.onVisibilityChanged});

  final void Function(void Function(bool))? onVisibilityChanged;

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver, AutomaticKeepAliveClientMixin {
  late final TabController _tabController;
  final _repository = OrderRepository();
  late Future<List<LaundryOrderRecord>> _ordersFuture;
  bool _isCancelling = false;
  Timer? _autoRefreshTimer;
  bool _isVisible = true;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _tabController = TabController(length: 3, vsync: this);
    _loadHistory();
    _startAutoRefresh();
    widget.onVisibilityChanged?.call(setVisibility);
  }

  void _startAutoRefresh() {
    _autoRefreshTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (_isVisible && mounted) {
        _loadHistory();
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _isVisible) {
      _loadHistory();
    }
  }

  void setVisibility(bool visible) {
    _isVisible = visible;
    if (visible && mounted) {
      _loadHistory();
    }
  }

  void _loadHistory() {
    setState(() {
      _ordersFuture = _repository.getCustomerHistory();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _autoRefreshTimer?.cancel();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    setState(() {
      _ordersFuture = _repository.getCustomerHistory();
    });
    await _ordersFuture;
  }

  Future<void> _cancelBooking(LaundryOrderRecord booking) async {
    final bookingId = booking.bookingId;
    if (!booking.canCancelBooking || bookingId == null || _isCancelling) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Hủy yêu cầu đặt giặt?'),
        content: const Text('Bạn chỉ có thể hủy trước khi cửa hàng tiếp nhận.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Quay lại'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Hủy yêu cầu'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _isCancelling = true);
    try {
      await _repository.cancelBooking(bookingId);
      await _refresh();
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Không thể hủy yêu cầu: $error')),
        );
      }
    } finally {
      if (mounted) setState(() => _isCancelling = false);
    }
  }

  bool _isCancelled(LaundryOrderRecord order) => order.status == 'Đã hủy';

  bool _isCompleted(LaundryOrderRecord order) =>
      const {'Đã giao', 'Đã thanh toán', 'Hoàn thành'}.contains(order.status);

  List<LaundryOrderRecord> _filter(List<LaundryOrderRecord> orders, int tab) {
    return orders
        .where((order) {
          if (tab == 0) return !_isCancelled(order) && !_isCompleted(order);
          if (tab == 1) return _isCompleted(order);
          return _isCancelled(order);
        })
        .toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.orderHistory),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textMuted,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(text: 'Đang xử lý'),
            Tab(text: 'Hoàn tất'),
            Tab(text: 'Đã hủy'),
          ],
        ),
      ),
      body: FutureBuilder<List<LaundryOrderRecord>>(
        future: _ordersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return _StateMessage(
              icon: Icons.cloud_off_outlined,
              message: 'Không tải được lịch sử đơn hàng.',
              action: TextButton(
                onPressed: () => setState(() {
                  _ordersFuture = _repository.getCustomerHistory();
                }),
                child: const Text('Thử lại'),
              ),
            );
          }

          final orders = snapshot.data ?? const <LaundryOrderRecord>[];
          return TabBarView(
            controller: _tabController,
            children: List.generate(3, (tab) {
              final filtered = _filter(orders, tab);
              return RefreshIndicator(
                onRefresh: _refresh,
                child: filtered.isEmpty
                    ? ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: const [
                          SizedBox(height: 140),
                          _StateMessage(
                            icon: Icons.receipt_long_outlined,
                            message: 'Chưa có đơn hàng trong mục này.',
                          ),
                        ],
                      )
                    : ListView.separated(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(16),
                        itemCount: filtered.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 10),
                        itemBuilder: (context, index) => _OrderCard(
                          order: filtered[index],
                          onViewDetails: () {
                            final order = filtered[index];
                            if (order.orderId != null) {
                              context.pushNamed(
                                AppRoutes.trackingDetail,
                                pathParameters: {
                                  'id': order.orderId.toString(),
                                },
                              );
                            } else if (order.bookingId != null) {
                              context.pushNamed(
                                AppRoutes.trackingDetail,
                                pathParameters: {
                                  'id': 'booking_${order.bookingId}',
                                },
                              );
                            }
                          },
                          onRequestPayment: filtered[index].orderId == null
                              ? null
                              : () => context.pushNamed(
                                  AppRoutes.payment,
                                  pathParameters: {
                                    'id': filtered[index].orderId.toString(),
                                  },
                                ),
                          onCancelBooking: _isCancelling
                              ? null
                              : () => _cancelBooking(filtered[index]),
                        ),
                      ),
              );
            }),
          );
        },
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({
    required this.order,
    required this.onViewDetails,
    required this.onRequestPayment,
    required this.onCancelBooking,
  });

  final LaundryOrderRecord order;
  final VoidCallback onViewDetails;
  final VoidCallback? onRequestPayment;
  final VoidCallback? onCancelBooking;

  @override
  Widget build(BuildContext context) {
    final created = order.createdAt.toLocal();
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onViewDetails,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
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
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _StatusPill(status: order.status),
                  if (order.status == 'Đã giao' && order.orderId != null)
                    IconButton(
                      tooltip: 'Thanh toán hóa đơn',
                      onPressed: onRequestPayment,
                      icon: const Icon(Icons.payments_outlined),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(order.lineDescription, style: AppTypography.bodyText),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${created.day.toString().padLeft(2, '0')}/'
                    '${created.month.toString().padLeft(2, '0')}/${created.year}',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    '${order.totalVnd.toStringAsFixed(0)} đ',
                    style: AppTypography.title.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              if (order.canCancelBooking) ...[
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: onCancelBooking,
                  icon: const Icon(Icons.cancel_outlined),
                  label: const Text('Hủy yêu cầu'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    if (status == 'Đã hủy') {
      return StatusBadge(
        text: status,
        backgroundColor: AppColors.errorLight,
        textColor: AppColors.error,
      );
    }
    if (const {'Đã giao', 'Đã thanh toán', 'Hoàn thành'}.contains(status)) {
      return StatusBadge.completed(text: status);
    }
    return StatusBadge.active(text: status);
  }
}

class _StateMessage extends StatelessWidget {
  const _StateMessage({required this.icon, required this.message, this.action});

  final IconData icon;
  final String message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 48, color: AppColors.textMuted),
          const SizedBox(height: 12),
          Text(
            message,
            style: AppTypography.bodyText.copyWith(color: AppColors.textMuted),
          ),
          if (action != null) ...[const SizedBox(height: 12), action!],
        ],
      ),
    );
  }
}
