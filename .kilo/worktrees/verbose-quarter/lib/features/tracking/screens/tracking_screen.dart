import 'package:flutter/material.dart';
import 'package:app_quanly_giaiui/core/constants/app_strings.dart';
import 'package:app_quanly_giaiui/core/theme/app_colors.dart';
import 'package:app_quanly_giaiui/core/theme/app_typography.dart';
import 'package:app_quanly_giaiui/core/widgets/status_badge.dart';

class TrackingScreen extends StatelessWidget {
  final String orderId;

  const TrackingScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Theo dõi đơn #$orderId'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Current status header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: AppColors.heroCardGradient,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const Icon(Icons.local_laundry_service, size: 50, color: Colors.white),
                  const SizedBox(height: 12),
                  Text(
                    AppStrings.washing,
                    style: AppTypography.heading2.copyWith(color: Colors.white),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Đơn hàng của bạn đang được xử lý',
                    style: AppTypography.bodyText.copyWith(color: Colors.white.withValues(alpha: 0.9)),
                  ),
                  const SizedBox(height: 16),
                  StatusBadge(
                    text: 'Dự kiến hoàn tất: Hôm nay, 18:00',
                    backgroundColor: Colors.white.withValues(alpha: 0.2),
                    textColor: Colors.white,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            
            Text('Trạng thái đơn hàng', style: AppTypography.heading3),
            const SizedBox(height: 20),
            
            // Timeline
            _buildTimeline(),
            
            const SizedBox(height: 32),
            
            // Order details
            Text('Thông tin đơn hàng', style: AppTypography.heading3),
            const SizedBox(height: 12),
            _buildOrderDetails(),
            
            const SizedBox(height: 32),
            
            // Support Actions
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.phone_outlined),
                    label: const Text(AppStrings.callShop),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.chat_bubble_outline),
                    label: const Text(AppStrings.chatShop),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeline() {
    final steps = [
      _TimelineItem(AppStrings.orderReceived, '19/09/2026 - 10:30', 'Đơn hàng đã được tiếp nhận', true),
      _TimelineItem(AppStrings.washing, '19/09/2026 - 11:15', 'Đồ của bạn đang được giặt sạch', true),
      _TimelineItem(AppStrings.drying, 'Đang chờ', 'Đồ sẽ được sấy khô sau khi giặt', false),
      _TimelineItem(AppStrings.completed, 'Đang chờ', 'Đóng gói và chờ giao đến bạn', false),
      _TimelineItem(AppStrings.delivered, 'Đang chờ', 'Đã giao đồ thành công', false),
    ];

    return Column(
      children: List.generate(steps.length, (index) {
        final item = steps[index];
        final isLast = index == steps.length - 1;
        return _buildTimelineItem(item, isLast);
      }),
    );
  }

  Widget _buildTimelineItem(_TimelineItem item, bool isLast) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: item.isCompleted ? AppColors.primary : AppColors.divider,
                  border: Border.all(
                    color: item.isCompleted ? AppColors.primary : AppColors.border,
                    width: 2,
                  ),
                ),
                child: item.isCompleted
                    ? const Icon(Icons.check, size: 14, color: Colors.white)
                    : null,
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: item.isCompleted ? AppColors.primary : AppColors.divider,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: AppTypography.title.copyWith(
                      color: item.isCompleted ? AppColors.textPrimary : AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.time,
                    style: AppTypography.caption.copyWith(
                      color: item.isCompleted ? AppColors.primary : AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.description,
                    style: AppTypography.bodySmall.copyWith(
                      color: item.isCompleted ? AppColors.textSecondary : AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderDetails() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.divider),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _buildDetailRow('Dịch vụ', 'Giặt thường (5kg)'),
          _buildDetailRow('Hình thức', 'Lấy tận nơi'),
          _buildDetailRow('Địa chỉ', '123 Điện Biên Phủ, Bình Thạnh'),
          _buildDetailRow('Tổng tiền', '110.000 đ', valueColor: AppColors.primary),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(label, style: AppTypography.bodySmall),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTypography.bodyText.copyWith(
                color: valueColor ?? AppColors.textPrimary,
                fontWeight: valueColor != null ? FontWeight.bold : null,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}

class _TimelineItem {
  final String title;
  final String time;
  final String description;
  final bool isCompleted;

  const _TimelineItem(this.title, this.time, this.description, this.isCompleted);
}
