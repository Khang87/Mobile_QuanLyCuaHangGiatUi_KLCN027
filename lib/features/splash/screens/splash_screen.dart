import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:app_quanly_giaiui/core/theme/app_colors.dart';
import 'package:app_quanly_giaiui/core/constants/app_constants.dart';
import 'package:app_quanly_giaiui/core/theme/app_typography.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key, required this.resolveRoute});

  final Future<String> Function() resolveRoute;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _loadFailed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _resolveRoute());
  }

  Future<void> _resolveRoute() async {
    try {
      final route = await widget.resolveRoute();
      if (mounted) context.go(route);
    } catch (_) {
      if (mounted) setState(() => _loadFailed = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Placeholder logo - we'll use an Icon for now
            Container(
              width: 120,
              height: 120,
              decoration: const BoxDecoration(
                color: AppColors.surface,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.local_laundry_service_rounded,
                size: 60,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              AppConstants.appName,
              style: AppTypography.heading1.copyWith(color: AppColors.surface),
            ),
            const SizedBox(height: 48),
            if (_loadFailed) ...[
              Text(
                'Không tải được thông tin tài khoản.',
                style: AppTypography.bodyText.copyWith(
                  color: AppColors.surface,
                ),
              ),
              TextButton(
                onPressed: () {
                  setState(() => _loadFailed = false);
                  _resolveRoute();
                },
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.surface,
                ),
                child: const Text('Thử lại'),
              ),
            ] else
              const CircularProgressIndicator(color: AppColors.surface),
          ],
        ),
      ),
    );
  }
}
