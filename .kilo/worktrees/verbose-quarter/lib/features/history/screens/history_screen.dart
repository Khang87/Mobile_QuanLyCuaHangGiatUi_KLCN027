import 'package:flutter/material.dart';
import 'package:app_quanly_giaiui/core/constants/app_strings.dart';import 'package:app_quanly_giaiui/core/navigation/app_routes.dart';import 'package:app_quanly_giaiui/core/theme/app_colors.dart';
import 'package:app_quanly_giaiui/core/theme/app_typography.dart';
import 'package:app_quanly_giaiui/core/widgets/section_header.dart';
import 'package:app_quanly_giaiui/core/widgets/status_badge.dart';
import 'package:go_router/go_router.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOrderList(_mockActiveOrders),
          _buildOrderList(_mockCompletedOrders),
          _buildEmptyState('Chưa có đơn hàng nào bị hủy'),
        ],
      ),
    );
  }

  Widget _buildOrderList(List<_MockOrder> orders) {
    if (orders.isEmpty) {
      return _buildEmptyState(AppStrings.noData);
    }

    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: orders.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final order = orders[index];
        return _OrderCard(order: order);
      },
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long_outlined, size: 64, color: AppColors.textMuted),
          const SizedBox(height: 16),
          Text(message, style: AppTypography.bodyText.copyWith(color: AppColors.textMuted)),
        ],
      ),
    );
  }
}

// ---- Mock Data ----
class _MockOrder {
  final String id;
  final String serviceName;
  final String date;
  final String total;
  final String status;
  final double rating;

  const _MockOrder({
    required this.id,
    required this.serviceName,
    required this.date,
    required this.total,
    required this.status,
    this.rating = 0,
  });
}

final _mockActiveOrders = [
  const _MockOrder(
    id: 'DH001',
    serviceName: 'Giặt thường - 5kg',
    date: '19/09/2026',
    total: '75.000 đ',
    status: 'Đang giặt',
  ),
  const _MockOrder(
    id: 'DH002',
    serviceName: 'Giặt khô - 3 món',
    date: '18/09/2026',
    total: '120.000 đ',
    status: 'Đang sấy',
  ),
];

final _mockCompletedOrders = [
  const _MockOrder(
    id: 'DH098',
    serviceName: 'Ủi đồ - 10 món',
    date: '15/09/2026',
    total: '50.000 đ',
    status: 'Hoàn tất',
    rating: 5,
  ),
  const _MockOrder(
    id: 'DH097',
    serviceName: 'Giặt chăn mền - 2 chiếc',
    date: '10/09/2026',
    total: '180.000 đ',
    status: 'Hoàn tất',
    rating: 4,
  ),
];

// ---- Order Card ----
class _OrderCard extends StatelessWidget {
  final _MockOrder order;

  const _OrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.pushNamed(
          AppRoutes.trackingDetail,
          pathParameters: {'id': order.id},
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('#${order.id}', style: AppTypography.title),
              _buildStatusBadge(),
            ],
          ),
          const SizedBox(height: 8),
          Text(order.serviceName, style: AppTypography.bodyText),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.calendar_today_outlined, size: 14, color: AppColors.textMuted),
                  const SizedBox(width: 4),
                  Text(order.date, style: AppTypography.bodySmall),
                ],
              ),
              Text(
                order.total,
                style: AppTypography.title.copyWith(color: AppColors.primary),
              ),
            ],
          ),
          if (order.rating > 0) ...[
            const Divider(height: 24),
            Row(
              children: [
                ...List.generate(
                  5,
                  (i) => Icon(
                    i < order.rating.round() ? Icons.star : Icons.star_border,
                    color: AppColors.warning,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 8),
                Text('Đã đánh giá', style: AppTypography.caption),
              ],
            ),
          ],
        ],
      ),
      ),
    );
  }

  Widget _buildStatusBadge() {
    switch (order.status) {
      case 'Hoàn tất':
        return StatusBadge.completed(text: order.status);
      case 'Đã hủy':
        return StatusBadge(
          text: order.status,
          backgroundColor: AppColors.errorLight,
          textColor: AppColors.error,
        );
      default:
        return StatusBadge.active(text: order.status);
    }
  }
}
