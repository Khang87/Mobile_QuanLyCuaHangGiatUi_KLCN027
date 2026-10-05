import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:app_quanly_giaiui/core/config/supabase_config.dart';
import 'package:app_quanly_giaiui/features/splash/screens/splash_screen.dart';
import 'package:app_quanly_giaiui/features/onboarding/screens/onboarding_screen.dart';
import 'package:app_quanly_giaiui/features/auth/data/auth_repository.dart';
import 'package:app_quanly_giaiui/features/auth/screens/login_screen.dart';
import 'package:app_quanly_giaiui/features/auth/screens/register_screen.dart';
import 'package:app_quanly_giaiui/features/auth/screens/otp_verification_screen.dart';
import 'package:app_quanly_giaiui/features/auth/screens/forgot_password_screen.dart';
import 'package:app_quanly_giaiui/features/auth/screens/reset_password_screen.dart';
import 'package:app_quanly_giaiui/features/main_shell.dart';
import 'package:app_quanly_giaiui/features/services/screens/service_detail_screen.dart';
import 'package:app_quanly_giaiui/features/order/screens/create_order_screen.dart';
import 'package:app_quanly_giaiui/features/order/screens/order_summary_screen.dart';
import 'package:app_quanly_giaiui/features/tracking/screens/tracking_screen.dart';
import 'package:app_quanly_giaiui/features/payment/screens/payment_screen.dart';
import 'package:app_quanly_giaiui/features/loyalty/screens/loyalty_screen.dart';
import 'package:app_quanly_giaiui/features/loyalty/screens/vouchers_screen.dart';
import 'package:app_quanly_giaiui/features/staff/screens/staff_order_queue_screen.dart';
import 'package:app_quanly_giaiui/features/profile/screens/address_book_screen.dart';
import 'package:app_quanly_giaiui/features/profile/screens/edit_profile_screen.dart';
import 'package:app_quanly_giaiui/features/review/screens/review_screen.dart';
import 'app_routes.dart';

class AppRouter {
  static final rootNavigatorKey = GlobalKey<NavigatorState>();
  static final _authRefreshListenable = _AuthRefreshListenable();
  static List<String>? _cachedRoles;

  static String defaultRouteForRoles(List<String> roles) {
    final normalized = roles.map((role) => role.trim()).toList(growable: false);
    final hasStaffRole = normalized.any(
      {'Nhân viên', 'Quản lý', 'Chủ cửa hàng'}.contains,
    );
    return hasStaffRole ? AppRoutes.staffQueuePath : AppRoutes.homePath;
  }

  static Future<List<String>> _loadCurrentRoles() async {
    final cachedRoles = _cachedRoles;
    if (cachedRoles != null) return cachedRoles;

    final roles = await AuthRepository().getCurrentRoles().timeout(
      const Duration(seconds: 10),
    );
    _cachedRoles = roles;
    return roles;
  }

  static final GoRouter router = GoRouter(
    navigatorKey: rootNavigatorKey,
    refreshListenable: _authRefreshListenable,
    initialLocation: AppRoutes.splashPath,
    redirect: _redirect,
    routes: [
      // Splash
      GoRoute(
        path: AppRoutes.splashPath,
        name: AppRoutes.splash,
        builder: (context, state) => SplashScreen(
          resolveRoute: () async {
            final repository = AuthRepository();
            await repository.ensureGoogleCustomerProfile();
            _cachedRoles = null;
            return defaultRouteForRoles(await _loadCurrentRoles());
          },
        ),
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
            builder: (context, state) {
              final extra = state.extra;
              if (extra is! Map) return const LoginScreen();

              final phone = extra['phone'];
              if (phone is! String || phone.isEmpty) {
                return const LoginScreen();
              }

              final fullName = extra['fullName'];
              return OtpVerificationScreen(
                phone: phone,
                fullName: fullName is String ? fullName : null,
              );
            },
          ),
        ],
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
      GoRoute(
        path: AppRoutes.resetPasswordPath,
        name: AppRoutes.resetPassword,
        builder: (context, state) => const ResetPasswordScreen(),
      ),

      // Main App Shell (Bottom Navigation)
      GoRoute(
        path: AppRoutes.homePath,
        name: AppRoutes.home,
        builder: (context, state) {
          final extra = state.extra;
          final initialIndex = extra is int ? extra : 0;
          return MainShell(initialIndex: initialIndex);
        },
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
        builder: (context, state) =>
            ServiceDetailScreen(serviceId: state.pathParameters['id'] ?? ''),
      ),

      // Order Flow
      GoRoute(
        path: '/create-order',
        name: AppRoutes.createOrder,
        builder: (context, state) => CreateOrderScreen(
          initialPriceId: state.extra is int ? state.extra as int : null,
        ),
        routes: [
          GoRoute(
            path: 'summary',
            name: AppRoutes.orderSummary,
            builder: (context, state) {
              final extra = state.extra;
              if (extra is! Map) return const CreateOrderScreen();
              return OrderSummaryScreen(draft: extra.cast<String, dynamic>());
            },
          ),
        ],
      ),

      // Tracking and payment
      GoRoute(
        path: '/tracking/:id',
        name: AppRoutes.trackingDetail,
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          if (id.startsWith('booking_')) {
            final bookingId = id.substring(8);
            return TrackingScreen(bookingId: bookingId);
          }
          return TrackingScreen(orderId: id);
        },
      ),
      GoRoute(
        path: '/payment/:id',
        name: AppRoutes.payment,
        builder: (context, state) =>
            PaymentScreen(orderId: state.pathParameters['id'] ?? 'DH001'),
      ),
      GoRoute(
        path: '/review/:id',
        name: AppRoutes.review,
        builder: (context, state) =>
            ReviewScreen(orderId: state.pathParameters['id'] ?? ''),
      ),

      // Loyalty
      GoRoute(
        path: '/loyalty',
        name: AppRoutes.loyalty,
        builder: (context, state) => const LoyaltyScreen(),
      ),
      GoRoute(
        path: '/vouchers',
        name: AppRoutes.vouchers,
        builder: (context, state) => const VouchersScreen(),
      ),
      GoRoute(
        path: AppRoutes.staffQueuePath,
        name: AppRoutes.staffQueue,
        builder: (context, state) => const StaffOrderQueueScreen(),
      ),
      GoRoute(
        path: AppRoutes.addressBookPath,
        name: AppRoutes.addressBook,
        builder: (context, state) => const AddressBookScreen(),
      ),
      GoRoute(
        path: AppRoutes.editProfilePath,
        name: AppRoutes.editProfile,
        builder: (context, state) => const EditProfileScreen(),
      ),
    ],
    // Handle error routes
    errorBuilder: (context, state) =>
        Scaffold(body: Center(child: Text('Route not found: ${state.uri}'))),
  );

  static Future<String?> _redirect(
    BuildContext context,
    GoRouterState state,
  ) async {
    final path = state.uri.path;
    final otpPath = '${AppRoutes.loginPath}/${AppRoutes.otpPath}';
    final isOtpRoute = path == otpPath;
    final isAuthRoute =
        path == AppRoutes.onboardingPath ||
        path == AppRoutes.loginPath ||
        path == AppRoutes.registerPath ||
        path == AppRoutes.forgotPasswordPath;
    final isPasswordResetRoute = path == AppRoutes.resetPasswordPath;
    final isPublicRoute = isAuthRoute || isOtpRoute || isPasswordResetRoute;

    if (!SupabaseConfig.isConfigured) {
      return isPublicRoute ? null : AppRoutes.loginPath;
    }

    final isSignedIn = Supabase.instance.client.auth.currentSession != null;
    if (path == AppRoutes.splashPath) {
      return isSignedIn ? null : AppRoutes.loginPath;
    }

    if (!isSignedIn && !isPublicRoute) return AppRoutes.loginPath;
    if (isSignedIn && isAuthRoute) {
      return AppRoutes.splashPath;
    }

    if (isSignedIn &&
        (path == AppRoutes.homePath ||
            path == AppRoutes.myOrdersPath ||
            path == AppRoutes.notificationsPath ||
            path == AppRoutes.profilePath)) {
      final roles = await _loadCurrentRoles();
      if (defaultRouteForRoles(roles) == AppRoutes.staffQueuePath &&
          path != AppRoutes.staffQueuePath) {
        return AppRoutes.staffQueuePath;
      }
    }

    return null;
  }
}

class _AuthRefreshListenable extends ChangeNotifier {
  StreamSubscription<AuthState>? _subscription;

  _AuthRefreshListenable() {
    if (SupabaseConfig.isConfigured) {
      _subscription = Supabase.instance.client.auth.onAuthStateChange.listen((
        authState,
      ) {
        AppRouter._cachedRoles = null;
        if (authState.event == AuthChangeEvent.passwordRecovery) {
          AppRouter.router.go(AppRoutes.resetPasswordPath);
        }
        notifyListeners();
      }, onError: (Object error, StackTrace stackTrace) {});
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
