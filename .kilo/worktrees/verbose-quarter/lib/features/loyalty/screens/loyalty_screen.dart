import 'package:flutter/material.dart';
import 'package:app_quanly_giaiui/core/constants/app_strings.dart';
import 'package:app_quanly_giaiui/core/theme/app_colors.dart';
import 'package:app_quanly_giaiui/core/theme/app_typography.dart';

class LoyaltyScreen extends StatelessWidget {
  const LoyaltyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.loyalty),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Points Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: AppColors.heroCardGradient,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Điểm tích lũy', style: AppTypography.title.copyWith(color: Colors.white)),
                      const Icon(Icons.stars_rounded, color: Colors.white, size: 32),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text('1.250', style: AppTypography.heading1.copyWith(color: Colors.white, fontSize: 40)),
                  const SizedBox(height: 4),
                  Text('điểm', style: AppTypography.bodySmall.copyWith(color: Colors.white.withValues(alpha: 0.8))),
                  const SizedBox(height: 24),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: 0.625,
                      minHeight: 8,
                      backgroundColor: Colors.white.withValues(alpha: 0.2),
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text('Còn 750 điểm để lên hạng Vàng', style: AppTypography.caption.copyWith(color: Colors.white.withValues(alpha: 0.8))),
                ],
              ),
            ),
            const SizedBox(height: 32),
            
            Text('Quyền lợi thành viên', style: AppTypography.heading3),
            const SizedBox(height: 16),
            _buildBenefit(Icons.percent, 'Giảm 5% mỗi đơn hàng', 'Áp dụng tự động cho mọi đơn giặt'),
            _buildBenefit(Icons.local_shipping_outlined, 'Miễn phí giao nhận', 'Cho đơn hàng từ 200.000đ'),
            _buildBenefit(Icons.card_giftcard_outlined, 'Quà sinh nhật đặc biệt', 'Nhận voucher 50.000đ vào ngày sinh nhật'),
            const SizedBox(height: 32),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(AppStrings.vouchers, style: AppTypography.heading3),
                TextButton(onPressed: () {}, child: const Text(AppStrings.seeAll)),
              ],
            ),
            const SizedBox(height: 8),
            _buildVoucher('SAVE30', 'Giảm 30.000đ', 'Cho đơn từ 150.000đ', AppColors.primary),
            _buildVoucher('FREESHIP', 'Miễn phí giao hàng', 'Cho đơn từ 100.000đ', AppColors.secondary),
            _buildVoucher('WELCOME', 'Giảm 20%', 'Cho khách hàng mới', AppColors.accent),
            const SizedBox(height: 32),
            
            // Referral Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.warningLight,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Icon(Icons.people_outline, size: 40, color: AppColors.warning),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(AppStrings.referFriend, style: AppTypography.title),
                        const SizedBox(height: 4),
                        Text('Mời bạn bè dùng app, nhận ngay 100 điểm', style: AppTypography.bodySmall),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: AppColors.warning),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBenefit(IconData icon, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTypography.title),
                const SizedBox(height: 4),
                Text(subtitle, style: AppTypography.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVoucher(String code, String title, String subtitle, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.confirmation_number_outlined, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTypography.title),
                const SizedBox(height: 4),
                Text(subtitle, style: AppTypography.bodySmall),
                const SizedBox(height: 6),
                Text('Mã: $code', style: AppTypography.caption.copyWith(color: color, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              minimumSize: Size.zero,
            ),
            child: const Text('Dùng ngay'),
          ),
        ],
      ),
    );
  }
}
