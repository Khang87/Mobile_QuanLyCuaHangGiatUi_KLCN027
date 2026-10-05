import 'package:flutter/material.dart';
import 'package:app_quanly_giaiui/core/constants/app_strings.dart';
import 'package:app_quanly_giaiui/core/theme/app_colors.dart';
import 'package:app_quanly_giaiui/core/theme/app_typography.dart';
import 'package:app_quanly_giaiui/features/loyalty/data/loyalty_repository.dart';

class LoyaltyScreen extends StatefulWidget {
  const LoyaltyScreen({super.key});

  @override
  State<LoyaltyScreen> createState() => _LoyaltyScreenState();
}

class _LoyaltyScreenState extends State<LoyaltyScreen> {
  final _repository = LoyaltyRepository();
  late Future<LoyaltySummary> _summaryFuture;

  @override
  void initState() {
    super.initState();
    _summaryFuture = _repository.getSummary();
  }

  void _retry() {
    setState(() {
      _summaryFuture = _repository.getSummary();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.loyalty)),
      body: FutureBuilder<LoyaltySummary>(
        future: _summaryFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.cloud_off_outlined, size: 48),
                  const SizedBox(height: 12),
                  const Text('Không tải được điểm và khuyến mãi.'),
                  TextButton(onPressed: _retry, child: const Text('Thử lại')),
                ],
              ),
            );
          }

          final summary = snapshot.data!;
          return RefreshIndicator(
            onRefresh: () async {
              final future = _repository.getSummary();
              setState(() {
                _summaryFuture = future;
              });
              await future;
            },
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(20),
              children: [
                _buildPointsCard(summary.points),
                const SizedBox(height: 28),
                Text('Quyền lợi thành viên', style: AppTypography.heading3),
                const SizedBox(height: 16),
                _buildBenefit(Icons.percent, 'Tích điểm theo đơn hàng', 'Điểm được cộng khi đơn hàng ở trạng thái "Đã giao".'),
                _buildBenefit(Icons.local_offer_outlined, 'Sử dụng điểm giảm tiền', 'Bật tính năng này khi đặt đơn để trừ tiền từ điểm tích lũy của bạn.'),
                _buildBenefit(Icons.card_giftcard, 'Đổi quà tặng', 'Sử dụng điểm tích lũy để đổi quà tặng hấp dẫn.'),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPointsCard(int points) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppColors.heroCardGradient,
        borderRadius: BorderRadius.circular(16),
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
          Text('$points', style: AppTypography.heading1.copyWith(color: Colors.white, fontSize: 40)),
          Text('điểm', style: AppTypography.bodySmall.copyWith(color: Colors.white.withValues(alpha: 0.8))),
          const SizedBox(height: 12),
          Text(
            'Có thể dùng để giảm tiền khi đặt đơn hàng',
            style: AppTypography.caption.copyWith(color: Colors.white.withValues(alpha: 0.8)),
          ),
        ],
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
            decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: AppColors.primary),
          ),
          const SizedBox(width: 16),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: AppTypography.title),
            const SizedBox(height: 4),
            Text(subtitle, style: AppTypography.bodySmall),
          ])),
        ],
      ),
    );
  }
}
