import 'package:flutter/material.dart';
import 'package:app_quanly_giaiui/core/theme/app_colors.dart';
import 'package:app_quanly_giaiui/core/theme/app_typography.dart';

class StatusBadge extends StatelessWidget {
  final String text;
  final Color backgroundColor;
  final Color textColor;

  const StatusBadge({
    super.key,
    required this.text,
    required this.backgroundColor,
    required this.textColor,
  });

  factory StatusBadge.pending({required String text}) => StatusBadge(
        text: text,
        backgroundColor: AppColors.warningLight,
        textColor: AppColors.warning,
      );
  factory StatusBadge.active({required String text}) => StatusBadge(
        text: text,
        backgroundColor: AppColors.infoLight,
        textColor: AppColors.info,
      );
  factory StatusBadge.completed({required String text}) => StatusBadge(
        text: text,
        backgroundColor: AppColors.successLight,
        textColor: AppColors.success,
      );

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: AppTypography.caption.copyWith(
          color: textColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
