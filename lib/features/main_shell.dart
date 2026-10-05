import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:app_quanly_giaiui/core/constants/app_strings.dart';
import 'package:app_quanly_giaiui/core/navigation/app_routes.dart';
import 'package:app_quanly_giaiui/core/theme/app_colors.dart';
import 'package:app_quanly_giaiui/features/auth/data/auth_repository.dart';
import 'package:app_quanly_giaiui/features/history/screens/history_screen.dart';
import 'package:app_quanly_giaiui/features/home/screens/home_screen.dart';
import 'package:app_quanly_giaiui/features/notification/screens/notification_screen.dart';
import 'package:app_quanly_giaiui/features/profile/screens/profile_screen.dart';
import 'package:app_quanly_giaiui/features/staff/screens/staff_order_queue_screen.dart';

class TabRequest {
  TabRequest(this.index); // KHÔNG const, để mỗi lần là một đối tượng mới
  final int index;
}

class MainShell extends StatefulWidget {
  final int initialIndex;

  const MainShell({super.key, this.initialIndex = 0});

  static final ValueNotifier<TabRequest?> tabRequests = ValueNotifier(null);

  /// Chuyển tới tab [index] của MainShell trong mọi trường hợp.
  static void goToTab(BuildContext context, int index) {
    tabRequests.value = TabRequest(index); // shell đang tồn tại sẽ đổi tab ngay
    const paths = [
      AppRoutes.homePath,
      AppRoutes.myOrdersPath,
      AppRoutes.notificationsPath,
      AppRoutes.profilePath,
    ];
    context.go(paths[index]); // đóng các màn đang push phía trên
  }

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  final _authRepository = AuthRepository();
  final _homeScreenKey = GlobalKey<HomeScreenState>();
  final _unreadNotificationCount = ValueNotifier<int>(0);
  late Future<List<String>> _rolesFuture;
  late int _selectedIndex;
  bool _isStaff = false;
  void Function(bool)? _setHistoryVisibility;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
    _rolesFuture = _authRepository.getCurrentRoles();
    MainShell.tabRequests.addListener(_onTabRequest);
  }

  void _onTabRequest() {
    final request = MainShell.tabRequests.value;
    if (request == null || !mounted) return;
    _onDestinationSelected(request.index, _isStaff);
  }

  @override
  void didUpdateWidget(covariant MainShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialIndex != oldWidget.initialIndex) {
      _selectedIndex = widget.initialIndex;
    }
  }

  @override
  void dispose() {
    MainShell.tabRequests.removeListener(_onTabRequest);
    _unreadNotificationCount.dispose();
    super.dispose();
  }

  bool _hasStaffRole(List<String> roles) =>
      roles.any({'Nhân viên', 'Quản lý', 'Chủ cửa hàng'}.contains);

  void _onDestinationSelected(int index, bool isStaff) {
    setState(() => _selectedIndex = index);
    if (index == 0) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _homeScreenKey.currentState?.refresh(),
      );
    }

    // Notify HistoryScreen about visibility change
    if (!isStaff) {
      final isHistoryVisible = index == 1;
      _setHistoryVisibility?.call(isHistoryVisible);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<String>>(
      future: _rolesFuture,
      builder: (context, snapshot) {
        final roles = snapshot.data ?? const <String>[];
        final isStaff = _hasStaffRole(roles);
        _isStaff = isStaff;
        final selectedIndex = isStaff
            ? (_selectedIndex.clamp(0, 2))
            : (_selectedIndex.clamp(0, 3));

        final screens = isStaff
            ? [
                const StaffOrderQueueScreen(),
                NotificationScreen(
                  unreadNotificationCount: _unreadNotificationCount,
                ),
                const ProfileScreen(),
              ]
            : [
                HomeScreen(
                  key: _homeScreenKey,
                  unreadNotificationCount: _unreadNotificationCount,
                  onOpenNotifications: () => _onDestinationSelected(2, false),
                ),
                HistoryScreen(
                  onVisibilityChanged: (setVisibility) {
                    _setHistoryVisibility = setVisibility;
                  },
                ),
                NotificationScreen(
                  unreadNotificationCount: _unreadNotificationCount,
                ),
                const ProfileScreen(),
              ];

        final destinations = isStaff
            ? const [
                NavigationDestination(
                  icon: Icon(Icons.fact_check_outlined),
                  selectedIcon: Icon(
                    Icons.fact_check,
                    color: AppColors.primary,
                  ),
                  label: 'Đơn hàng',
                ),
                NavigationDestination(
                  icon: Icon(Icons.notifications_outlined),
                  selectedIcon: Icon(
                    Icons.notifications,
                    color: AppColors.primary,
                  ),
                  label: AppStrings.notifications,
                ),
                NavigationDestination(
                  icon: Icon(Icons.person_outline),
                  selectedIcon: Icon(Icons.person, color: AppColors.primary),
                  label: AppStrings.profile,
                ),
              ]
            : const [
                NavigationDestination(
                  icon: Icon(Icons.home_outlined),
                  selectedIcon: Icon(Icons.home, color: AppColors.primary),
                  label: AppStrings.home,
                ),
                NavigationDestination(
                  icon: Icon(Icons.receipt_long_outlined),
                  selectedIcon: Icon(
                    Icons.receipt_long,
                    color: AppColors.primary,
                  ),
                  label: AppStrings.history,
                ),
                NavigationDestination(
                  icon: Icon(Icons.notifications_outlined),
                  selectedIcon: Icon(
                    Icons.notifications,
                    color: AppColors.primary,
                  ),
                  label: AppStrings.notifications,
                ),
                NavigationDestination(
                  icon: Icon(Icons.person_outline),
                  selectedIcon: Icon(Icons.person, color: AppColors.primary),
                  label: AppStrings.profile,
                ),
              ];

        return Scaffold(
          body: IndexedStack(index: selectedIndex, children: screens),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 20,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SafeArea(
              child: NavigationBar(
                selectedIndex: selectedIndex,
                onDestinationSelected: (index) =>
                    _onDestinationSelected(index, isStaff),
                backgroundColor: AppColors.surface,
                indicatorColor: AppColors.primaryLight,
                destinations: destinations,
              ),
            ),
          ),
        );
      },
    );
  }
}
