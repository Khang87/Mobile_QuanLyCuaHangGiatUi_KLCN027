import 'package:flutter/material.dart';
import 'package:app_quanly_giaiui/core/constants/app_strings.dart';
import 'package:app_quanly_giaiui/core/theme/app_colors.dart';
import 'package:app_quanly_giaiui/core/theme/app_typography.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock data
    final hasNotifications = true;

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.notifications),
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all),
            onPressed: () {},
            tooltip: 'Đánh dấu đã đọc tất cả',
          ),
        ],
      ),
      body: hasNotifications
          ? ListView.separated(
              itemCount: 10,
              separatorBuilder: (_, __) => const Divider(height: 1, color: AppColors.divider),
              itemBuilder: (context, index) {
                final isUnread = index < 3;
                return Container(
                  color: isUnread ? AppColors.primaryExtraLight : AppColors.surface,
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    leading: CircleAvatar(
                      backgroundColor: isUnread ? AppColors.primary : AppColors.border,
                      child: const Icon(Icons.local_shipping_outlined, color: Colors.white),
                    ),
                    title: Text(
                      'Đơn hàng #DH00${index + 1} đang được giao!',
                      style: AppTypography.title.copyWith(
                        fontWeight: isUnread ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(
                          'Nhân viên giao hàng đang trên đường đến địa chỉ của bạn.',
                          style: AppTypography.bodySmall,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${10 + index} phút trước',
                          style: AppTypography.caption.copyWith(color: AppColors.primary),
                        ),
                      ],
                    ),
                    onTap: () {},
                  ),
                );
              },
            )
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_off_outlined,
                      size: 64, color: AppColors.textMuted),
                  const SizedBox(height: 16),
                  Text(AppStrings.noNotifications,
                      style: AppTypography.bodyText.copyWith(color: AppColors.textMuted)),
                ],
              ),
            ),
    );
  }
}
