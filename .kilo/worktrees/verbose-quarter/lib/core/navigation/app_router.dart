import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:app_quanly_giaiui/features/splash/screens/splash_screen.dart';
import 'package:app_quanly_giaiui/features/onboarding/screens/onboarding_screen.dart';
import 'package:app_quanly_giaiui/features/auth/screens/login_screen.dart';
import 'package:app_quanly_giaiui/features/auth/screens/register_screen.dart';
import 'package:app_quanly_giaiui/features/auth/screens/forgot_password_screen.dart';
import 'package:app_quanly_giaiui/features/main_shell.dart';
import 'package:app_quanly_giaiui/features/services/screens/service_detail_screen.dart';
import 'package:app_quanly_giaiui/features/order/screens/create_order_screen.dart';
import 'package:app_quanly_giaiui/features/order/screens/order_summary_screen.dart';
import 'package:app_quanly_giaiui/features/tracking/screens/tracking_screen.dart';
import 'package:app_quanly_giaiui/features/payment/screens/payment_screen.dart';
import 'package:app_quanly_giaiui/features/loyalty/screens/loyalty_screen.dart';
import 'app_routes.dart';

class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  // static final _shellNavigatorKey = GlobalKey<NavigatorState>();

  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppRoutes.splashPath,
    routes: [
      // Splash
      GoRoute(
        path: AppRoutes.splashPath,
        name: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      
      // Onboarding
      GoRoute(
        path: AppRoutes.onboardingPath,
        name: AppRoutes.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      
      // Auth
      GoRoute(
        path: AppRoutes.loginPath,
        name: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
        routes: [
          GoRoute(
            path: AppRoutes.otpPath,
            name: AppRoutes.otp,
            builder: (context, state) => const _PlaceholderScreen(title: 'Verify OTP'),
          ),
        ]
      ),
      GoRoute(
        path: AppRoutes.registerPath,
        name: AppRoutes.register,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: AppRoutes.forgotPasswordPath,
        name: AppRoutes.forgotPassword,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),

      // Main App Shell (Bottom Navigation)
      GoRoute(
        path: AppRoutes.homePath,
        name: AppRoutes.home,
        builder: (context, state) => const MainShell(initialIndex: 0),
      ),
      GoRoute(
        path: AppRoutes.myOrdersPath,
        name: AppRoutes.myOrders,
        builder: (context, state) => const MainShell(initialIndex: 1),
      ),
      GoRoute(
        path: AppRoutes.notificationsPath,
        name: AppRoutes.notifications,
        builder: (context, state) => const MainShell(initialIndex: 2),
      ),
      GoRoute(
        path: AppRoutes.profilePath,
        name: AppRoutes.profile,
        builder: (context, state) => const MainShell(initialIndex: 3),
      ),
      
      // Service Details
      GoRoute(
        path: '/service-detail/:id',
        name: AppRoutes.serviceDetail,
        builder: (context, state) => ServiceDetailScreen(
          serviceId: state.pathParameters['id'] ?? 'regular-wash',
        ),
      ),

      // Order Flow
      GoRoute(
        path: '/create-order',
        name: AppRoutes.createOrder,
        builder: (context, state) => const CreateOrderScreen(),
        routes: [
          GoRoute(
            path: 'summary',
            name: AppRoutes.orderSummary,
            builder: (context, state) => const OrderSummaryScreen(),
          ),
        ],
      ),

      // Tracking and payment
      GoRoute(
        path: '/tracking/:id',
        name: AppRoutes.trackingDetail,
        builder: (context, state) => TrackingScreen(
          orderId: state.pathParameters['id'] ?? 'DH001',
        ),
      ),
      GoRoute(
        path: '/payment/:id',
        name: AppRoutes.payment,
        builder: (context, state) => PaymentScreen(
          orderId: state.pathParameters['id'] ?? 'DH001',
        ),
      ),

      // Loyalty
      GoRoute(
        path: '/loyalty',
        name: AppRoutes.loyalty,
        builder: (context, state) => const LoyaltyScreen(),
      ),
    ],
    // Handle error routes
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Route not found: ${state.uri}'),
      ),
    ),
  );
}

// Temporary placeholder for unbuilt screens
class _PlaceholderScreen extends StatelessWidget {
  final String title;
  const _PlaceholderScreen({required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Text(
          'Screen: $title',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
    );
  }
}
