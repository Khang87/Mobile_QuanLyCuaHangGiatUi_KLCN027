import 'package:flutter/material.dart';
import 'package:app_quanly_giaiui/core/constants/app_constants.dart';
import 'package:app_quanly_giaiui/core/config/supabase_config.dart';
import 'package:app_quanly_giaiui/core/navigation/app_router.dart';
import 'package:app_quanly_giaiui/core/theme/app_theme.dart';
import 'package:app_quanly_giaiui/features/notification/services/notification_service.dart';
import 'package:app_quanly_giaiui/features/notification/widgets/notification_overlay.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseConfig.initialize();
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  final _notificationService = NotificationService.instance;

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
    await _notificationService.initialize();
  }

  @override
  void dispose() {
    _notificationService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: AppRouter.router,
      builder: (context, child) => NotificationOverlay(
        child: child ?? const SizedBox(),
      ),
    );
  }
}
