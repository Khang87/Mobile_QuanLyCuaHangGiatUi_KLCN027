import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:app_quanly_giaiui/core/constants/app_strings.dart';
import 'package:app_quanly_giaiui/core/navigation/app_routes.dart';
import 'package:app_quanly_giaiui/core/theme/app_colors.dart';
import 'package:app_quanly_giaiui/core/theme/app_typography.dart';

class OrderSummaryScreen extends StatelessWidget {
  const OrderSummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.orderSummary),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order ID & Status
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primaryExtraLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.receipt_long, color: AppColors.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Đơn hàng mới', style: AppTypography.title),
                        Text('Kiểm tra thông tin trước khi gửi', style: AppTypography.bodySmall),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            _buildSection(
              title: 'Dịch vụ đã chọn',
              child: _buildServiceInfo(),
            ),
            const SizedBox(height: 20),
            
            _buildSection(
              title: 'Hình thức giao nhận',
              child: _buildDeliveryInfo(),
            ),
            const SizedBox(height: 20),
            
            _buildSection(
              title: 'Thời gian dự kiến',
              child: _buildTimeInfo(),
            ),
            const SizedBox(height: 20),
            
            // Pricing
            _buildPricingSection(),
            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 10)],
        ),
        child: SafeArea(
          child: ElevatedButton(
            onPressed: () => context.pushNamed(AppRoutes.payment, pathParameters: {'id': 'new'}),
            child: const Text('Xác nhận & Thanh toán'),
          ),
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTypography.heading3),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.divider),
          ),
          child: child,
        ),
      ],
    );
  }

  Widget _buildServiceInfo() {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.infoLight,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.water_drop, color: AppColors.info),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Giặt thường', style: AppTypography.title),
              Text('Khối lượng dự kiến: 5 kg', style: AppTypography.bodySmall),
            ],
          ),
        ),
        Text('125.000 đ', style: AppTypography.title.copyWith(color: AppColors.primary)),
      ],
    );
  }

  Widget _buildDeliveryInfo() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.local_shipping_outlined, color: AppColors.textSecondary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Lấy tận nơi', style: AppTypography.title),
              const SizedBox(height: 4),
              Text('123 Điện Biên Phủ, P.15, Bình Thạnh, TP.HCM', style: AppTypography.bodySmall),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTimeInfo() {
    return Row(
      children: [
        Expanded(
          child: Row(
            children: [
              const Icon(Icons.calendar_today_outlined, size: 18, color: AppColors.textSecondary),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Ngày lấy', style: AppTypography.caption),
                  Text('Hôm nay, 19/09', style: AppTypography.bodyText),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: Row(
            children: [
              const Icon(Icons.access_time_outlined, size: 18, color: AppColors.textSecondary),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Khung giờ', style: AppTypography.caption),
                  Text('14:00 - 15:00', style: AppTypography.bodyText),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPricingSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _buildPriceRow('Tạm tính', '125.000 đ'),
          const SizedBox(height: 12),
          _buildPriceRow('Phí giao nhận', '15.000 đ'),
          const SizedBox(height: 12),
          _buildPriceRow('Giảm giá', '-30.000 đ', color: AppColors.success),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(),
          ),
          _buildPriceRow('Tổng cộng', '110.000 đ', isTotal: true),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, String price, {Color? color, bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: isTotal ? AppTypography.heading3 : AppTypography.bodyText,
        ),
        Text(
          price,
          style: (isTotal ? AppTypography.heading2 : AppTypography.bodyText).copyWith(
            color: color ?? (isTotal ? AppColors.primary : AppColors.textPrimary),
            fontWeight: isTotal ? FontWeight.bold : null,
          ),
        ),
      ],
    );
  }
}
