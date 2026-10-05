import 'dart:async';

import 'package:app_quanly_giaiui/core/navigation/app_router.dart';
import 'package:app_quanly_giaiui/core/navigation/app_routes.dart';
import 'package:app_quanly_giaiui/features/splash/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppRouter.defaultRouteForRoles', () {
    test('redirects staff roles to the worker queue', () {
      expect(
        AppRouter.defaultRouteForRoles(['Nhân viên']),
        AppRoutes.staffQueuePath,
      );
      expect(
        AppRouter.defaultRouteForRoles(['Quản lý']),
        AppRoutes.staffQueuePath,
      );
      expect(
        AppRouter.defaultRouteForRoles(['Chủ cửa hàng']),
        AppRoutes.staffQueuePath,
      );
    });

    test('redirects plain customer roles to the customer home shell', () {
      expect(
        AppRouter.defaultRouteForRoles(['Khách hàng']),
        AppRoutes.homePath,
      );
      expect(AppRouter.defaultRouteForRoles([]), AppRoutes.homePath);
    });
  });

  testWidgets('shows splash while resolving the initial route', (tester) async {
    final routeCompleter = Completer<String>();

    await tester.pumpWidget(
      MaterialApp(
        home: SplashScreen(resolveRoute: () => routeCompleter.future),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
