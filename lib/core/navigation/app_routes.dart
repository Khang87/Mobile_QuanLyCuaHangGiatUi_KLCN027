class AppRoutes {
  AppRoutes._();

  // Route Names
  static const String splash = 'splash';
  static const String onboarding = 'onboarding';
  
  // Auth
  static const String login = 'login';
  static const String register = 'register';
  static const String forgotPassword = 'forgot-password';
  static const String resetPassword = 'reset-password';
  static const String otp = 'otp';
  
  // Main Navigation (Bottom Nav)
  static const String home = 'home';
  static const String myOrders = 'my-orders'; // Tracking & History combined
  static const String notifications = 'notifications';
  static const String profile = 'profile';

  // Order Flow
  static const String serviceDetail = 'service-detail';
  static const String createOrder = 'create-order';
  static const String orderSummary = 'order-summary';
  
  // Post-order
  static const String trackingDetail = 'tracking-detail';
  static const String payment = 'payment';
  static const String review = 'review';
  static const String loyalty = 'loyalty';
  static const String vouchers = 'vouchers';
  static const String staffQueue = 'staff-order-queue';
  static const String addressBook = 'address-book';
  static const String editProfile = 'edit-profile';
  
  // Pre-defined paths
  static const String splashPath = '/';
  static const String onboardingPath = '/onboarding';
  
  static const String loginPath = '/login';
  static const String registerPath = '/register';
  static const String forgotPasswordPath = '/forgot-password';
  static const String resetPasswordPath = '/reset-password';
  static const String otpPath = 'otp'; // Relative to auth routes
  
  static const String homePath = '/home';
  static const String myOrdersPath = '/my-orders';
  static const String notificationsPath = '/notifications';
  static const String profilePath = '/profile';
  
  static const String serviceDetailPath = 'service-detail/:id'; // Relative to home
  static const String createOrderPath = 'create-order'; // Relative to home
  static const String orderSummaryPath = 'order-summary'; // Relative to create order
  
  static const String trackingDetailPath = 'tracking-detail/:id'; // Relative to my-orders
  static const String paymentPath = 'payment/:id'; // Relative to tracking detail
  static const String reviewPath = 'review/:id';
  static const String staffQueuePath = '/staff/orders';
  static const String addressBookPath = '/profile/addresses';
  static const String editProfilePath = '/profile/edit';
}
