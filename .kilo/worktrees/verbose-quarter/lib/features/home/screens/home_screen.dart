import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:app_quanly_giaiui/core/constants/app_strings.dart';
import 'package:app_quanly_giaiui/core/theme/app_colors.dart';
import 'package:app_quanly_giaiui/core/theme/app_typography.dart';
import 'package:app_quanly_giaiui/core/widgets/section_header.dart';
import 'package:app_quanly_giaiui/core/navigation/app_routes.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ---- Header with user greeting ----
              _buildHeader(context),
              
              const SizedBox(height: 16),
              
              // ---- Search Bar ----
              _buildSearchBar(context),
              
              const SizedBox(height: 24),
              
              // ---- Active Order Card ----
              _buildActiveOrderCard(context),
              
              const SizedBox(height: 24),
              
              // ---- Services Grid ----
              SectionHeader(
                title: AppStrings.services,
                actionText: AppStrings.seeAll,
                onActionTap: () {},
              ),
              _buildServicesGrid(context),
              
              const SizedBox(height: 24),
              
              // ---- Promotions ----
              SectionHeader(
                title: AppStrings.promotions,
                actionText: AppStrings.seeAll,
                onActionTap: () {},
              ),
              _buildPromotionBanners(),
              
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.pushNamed(AppRoutes.createOrder);
        },
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text(AppStrings.newOrder),
      ),
    );
  }

  // ---- Header ----
  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            radius: 25,
            backgroundColor: AppColors.primaryLight,
            child: const Icon(Icons.person, color: AppColors.primary, size: 28),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${AppStrings.hello}Khách hàng',
                  style: AppTypography.title,
                ),
                const SizedBox(height: 2),
                Text(
                  AppStrings.whatService,
                  style: AppTypography.bodySmall,
                ),
              ],
            ),
          ),
          // Notification Icon
          IconButton(
            onPressed: () {},
            icon: Badge(
              smallSize: 8,
              child: const Icon(Icons.notifications_outlined),
            ),
          ),
        ],
      ),
    );
  }

  // ---- Search Bar ----
  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GestureDetector(
        onTap: () {
          // TODO: Navigate to search screen
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              const Icon(Icons.search, color: AppColors.textMuted),
              const SizedBox(width: 12),
              Text(
                'Tìm dịch vụ giặt ủi...',
                style: AppTypography.bodyText.copyWith(color: AppColors.textMuted),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---- Active Order Card ----
  Widget _buildActiveOrderCard(BuildContext context) {
    // Mock data for active order
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          gradient: AppColors.heroCardGradient,
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppStrings.currentOrders,
                  style: AppTypography.title.copyWith(color: Colors.white),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    AppStrings.washing,
                    style: AppTypography.caption.copyWith(color: Colors.white),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Đơn #DH001 - Giặt thường (5kg)',
              style: AppTypography.bodyText.copyWith(color: Colors.white.withValues(alpha: 0.9)),
            ),
            const SizedBox(height: 8),
            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: 0.5,
                minHeight: 6,
                backgroundColor: Colors.white.withValues(alpha: 0.2),
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Dự kiến trả: 20/09/2026 - 14:00',
                  style: AppTypography.caption.copyWith(color: Colors.white.withValues(alpha: 0.8)),
                ),
                TextButton(
                  onPressed: () {
                    context.pushNamed(
                      AppRoutes.trackingDetail,
                      pathParameters: {'id': 'DH001'},
                    );
                  },
                  child: Text(
                    'Chi tiết →',
                    style: AppTypography.bodySmall.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ---- Services Grid ----
  Widget _buildServicesGrid(BuildContext context) {
    final services = [
      _ServiceItem(AppStrings.regularWash, Icons.water_drop_outlined, AppColors.info),
      _ServiceItem(AppStrings.dryClean, Icons.dry_cleaning_outlined, AppColors.secondary),
      _ServiceItem(AppStrings.ironing, Icons.iron_outlined, AppColors.warning),
      _ServiceItem(AppStrings.blanketWash, Icons.bed_outlined, AppColors.primary),
      _ServiceItem(AppStrings.curtainWash, Icons.curtains_outlined, AppColors.accent),
      _ServiceItem(AppStrings.shoeClean, Icons.snowshoeing_outlined, AppColors.success),
      _ServiceItem(AppStrings.premiumWash, Icons.diamond_outlined, Color(0xFF8B5CF6)),
      _ServiceItem(AppStrings.expressWash, Icons.bolt_outlined, AppColors.error),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          mainAxisSpacing: 16,
          crossAxisSpacing: 12,
          childAspectRatio: 0.75,
        ),
        itemCount: services.length,
        itemBuilder: (context, index) {
          final service = services[index];
          return GestureDetector(
            onTap: () {
              context.pushNamed(
                AppRoutes.serviceDetail,
                pathParameters: {'id': service.name},
              );
            },
            child: Column(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: service.color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(service.icon, color: service.color, size: 28),
                ),
                const SizedBox(height: 8),
                Text(
                  service.name,
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ---- Promotion Banners ----
  Widget _buildPromotionBanners() {
    final promos = [
      _PromoItem('Giảm 30% lần đầu', 'Áp dụng cho khách hàng mới', AppColors.primary),
      _PromoItem('Giặt 5 tặng 1', 'Tích đủ 5 đơn, miễn phí đơn thứ 6', AppColors.secondary),
      _PromoItem('Miễn phí giao nhận', 'Đơn hàng từ 100.000đ', AppColors.accent),
    ];

    return SizedBox(
      height: 140,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: promos.length,
        itemBuilder: (context, index) {
          final promo = promos[index];
          return GestureDetector(
            onTap: () => context.pushNamed(AppRoutes.loyalty),
            child: Container(
            width: 260,
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [promo.color, promo.color.withValues(alpha: 0.7)],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  promo.title,
                  style: AppTypography.title.copyWith(color: Colors.white),
                ),
                const SizedBox(height: 6),
                Text(
                  promo.subtitle,
                  style: AppTypography.bodySmall.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Dùng ngay',
                    style: AppTypography.caption.copyWith(
                      color: promo.color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          )
          );
        },
      ),
    );
  }
}

class _ServiceItem {
  final String name;
  final IconData icon;
  final Color color;
  const _ServiceItem(this.name, this.icon, this.color);
}

class _PromoItem {
  final String title;
  final String subtitle;
  final Color color;
  const _PromoItem(this.title, this.subtitle, this.color);
}
