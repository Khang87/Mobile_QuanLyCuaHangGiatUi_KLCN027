import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:app_quanly_giaiui/core/constants/app_strings.dart';
import 'package:app_quanly_giaiui/core/theme/app_colors.dart';
import 'package:app_quanly_giaiui/core/theme/app_typography.dart';
import 'package:app_quanly_giaiui/core/navigation/app_routes.dart';

class ServiceDetailScreen extends StatelessWidget {
  final String serviceId;

  const ServiceDetailScreen({super.key, required this.serviceId});

  @override
  Widget build(BuildContext context) {
    // Mock dữ liệu chi tiết dịch vụ
    final serviceName = 'Giặt thường (Theo kg)';
    final serviceDesc = 'Dịch vụ giặt quần áo thông thường hàng ngày của bạn. Bao gồm giặt sạch, sấy khô và xếp gọn gàng.';
    final basePrice = 25000;
    
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: AppColors.infoLight,
                child: const Center(
                  child: Icon(Icons.water_drop, size: 100, color: AppColors.info),
                ),
              ),
            ),
            title: const Text('Chi tiết dịch vụ'),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(24),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Text(serviceName, style: AppTypography.heading1),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        '$basePrice đ / kg',
                        style: AppTypography.title.copyWith(color: AppColors.primaryDark),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Icon(Icons.timer_outlined, size: 18, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Text('24h - 48h', style: AppTypography.bodyText.copyWith(color: AppColors.textSecondary)),
                  ],
                ),
                const SizedBox(height: 24),
                Text('Mô tả', style: AppTypography.heading3),
                const SizedBox(height: 8),
                Text(serviceDesc, style: AppTypography.bodyText),
                
                const SizedBox(height: 32),
                Text('Bảng giá chi tiết', style: AppTypography.heading3),
                const SizedBox(height: 12),
                
                _buildPriceRow('Giặt sấy xếp (1-5kg)', '25.000 đ/kg'),
                _buildPriceRow('Giặt sấy xếp (>5kg)', '20.000 đ/kg'),
                _buildPriceRow('Áo sơ mi/Áo thun', '15.000 đ/cái'),
                _buildPriceRow('Quần tây/Quần jean', '20.000 đ/cái'),
                
                const SizedBox(height: 32),
                Text('Quy trình xử lý', style: AppTypography.heading3),
                const SizedBox(height: 12),
                
                _buildProcessStep(
                  '1', 
                  'Tiếp nhận & Phân loại', 
                  'Phân loại đồ theo màu và chất liệu vải để tránh lem màu, hư hỏng.'
                ),
                _buildProcessStep(
                  '2', 
                  'Xử lý vết bẩn', 
                  'Giặt vò tay các vết bẩn cứng đầu trên cổ áo, nách áo (nếu có).'
                ),
                _buildProcessStep(
                  '3', 
                  'Giặt & Xả thơm', 
                  'Sử dụng nước giặt chuyên dụng và nước xả thơm cao cấp.'
                ),
                _buildProcessStep(
                  '4', 
                  'Sấy khô & Gấp', 
                  'Sấy nhiệt độ chuẩn và xếp gọn gàng vào túi trước khi giao.'
                ),
                const SizedBox(height: 80),
              ]),
            ),
          ),
        ],
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            )
          ],
        ),
        child: SafeArea(
          child: ElevatedButton(
            onPressed: () {
              context.pushNamed(AppRoutes.createOrder);
            },
            child: const Text('Đặt Dịch Vụ Này'),
          ),
        ),
      ),
    );
  }

  Widget _buildPriceRow(String label, String price) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTypography.bodyText),
          Text(price, style: AppTypography.title),
        ],
      ),
    );
  }

  Widget _buildProcessStep(String step, String title, String desc) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary,
            ),
            child: Text(
              step,
              style: AppTypography.caption.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTypography.title),
                const SizedBox(height: 4),
                Text(
                  desc,
                  style: AppTypography.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
