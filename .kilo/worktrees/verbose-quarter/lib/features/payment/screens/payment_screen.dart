import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:app_quanly_giaiui/core/constants/app_strings.dart';
import 'package:app_quanly_giaiui/core/navigation/app_routes.dart';
import 'package:app_quanly_giaiui/core/theme/app_colors.dart';
import 'package:app_quanly_giaiui/core/theme/app_typography.dart';

class PaymentScreen extends StatefulWidget {
  final String orderId;

  const PaymentScreen({super.key, required this.orderId});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String _selectedMethod = 'vnpay';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.payment),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Amount Summary Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.primaryExtraLight,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primaryLight),
              ),
              child: Column(
                children: [
                  Text('Số tiền cần thanh toán', style: AppTypography.bodySmall),
                  const SizedBox(height: 8),
                  Text(
                    '110.000 đ',
                    style: AppTypography.heading1.copyWith(
                      color: AppColors.primary,
                      fontSize: 36,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text('Đơn hàng #${widget.orderId}', style: AppTypography.caption),
                ],
              ),
            ),
            const SizedBox(height: 32),
            
            Text(AppStrings.paymentMethod, style: AppTypography.heading3),
            const SizedBox(height: 16),
            
            // Methods
            _buildPaymentMethodOption(
              id: 'vnpay',
              title: 'Ví VNPay / Thẻ ATM / QR',
              subtitle: 'Quét mã QR thanh toán nhanh qua ứng dụng ngân hàng',
              icon: Icons.qr_code_scanner,
              color: const Color(0xFF005BAA),
            ),
            const SizedBox(height: 12),
            _buildPaymentMethodOption(
              id: 'momo',
              title: 'Ví MoMo',
              subtitle: 'Thanh toán trực tiếp qua ví MoMo',
              icon: Icons.account_balance_wallet,
              color: const Color(0xFFA50064),
            ),
            const SizedBox(height: 12),
            _buildPaymentMethodOption(
              id: 'zalopay',
              title: 'Ví ZaloPay',
              subtitle: 'Thanh toán qua ví điện tử ZaloPay',
              icon: Icons.account_balance_wallet_outlined,
              color: const Color(0xFF006AF5),
            ),
            const SizedBox(height: 12),
            _buildPaymentMethodOption(
              id: 'cash',
              title: 'Tiền mặt khi nhận đồ (COD)',
              subtitle: 'Thanh toán bằng tiền mặt cho nhân viên giao đồ',
              icon: Icons.payments_outlined,
              color: AppColors.success,
            ),
            
            const SizedBox(height: 100),
          ],
        ),
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
              // Show Success Dialog
              _showSuccessDialog(context);
            },
            child: const Text(AppStrings.payNow),
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentMethodOption({
    required String id,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    final isSelected = _selectedMethod == id;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedMethod = id;
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.divider,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          color: isSelected ? AppColors.primaryExtraLight : AppColors.surface,
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color),
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
            Radio<String>(
              value: id,
              groupValue: _selectedMethod,
              onChanged: (val) {
                if (val != null) setState(() => _selectedMethod = val);
              },
              activeColor: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  color: AppColors.successLight,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle, size: 50, color: AppColors.success),
              ),
              const SizedBox(height: 24),
              Text('Đặt đơn thành công!', style: AppTypography.heading2),
              const SizedBox(height: 8),
              Text(
                'Mã đơn hàng của bạn là #DH001. Bạn có thể theo dõi tiến độ giặt ủi trong mục Lịch sử.',
                style: AppTypography.bodyText.copyWith(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  context.goNamed(AppRoutes.myOrders);
                },
                child: const Text('Xem đơn hàng'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
