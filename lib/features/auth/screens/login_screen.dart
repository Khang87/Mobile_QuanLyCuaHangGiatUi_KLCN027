import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:app_quanly_giaiui/core/constants/app_strings.dart';
import 'package:app_quanly_giaiui/core/navigation/app_routes.dart';
import 'package:app_quanly_giaiui/core/theme/app_colors.dart';
import 'package:app_quanly_giaiui/core/theme/app_typography.dart';
import 'package:app_quanly_giaiui/features/auth/data/auth_repository.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isStaffLogin = false;
  bool _useEmailPassword = false;
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if ((_isStaffLogin || _useEmailPassword) &&
        (_emailController.text.trim().isEmpty ||
            _passwordController.text.isEmpty)) {
      _showMessage('Nhập email và mật khẩu do quản trị viên cấp.');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final repository = AuthRepository();
      if (_isStaffLogin || _useEmailPassword) {
        await repository.signInWithPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );
        await repository.ensureCustomerProfile();
        final roles = await repository.getCurrentRoles();
        final isStaff = roles.any(
          {'Nhân viên', 'Quản lý', 'Chủ cửa hàng'}.contains,
        );
        if (_isStaffLogin && !isStaff) {
          await repository.signOut();
          throw const AuthException(
            'Tài khoản chưa được cấp vai trò nhân viên hoặc quản lý.',
          );
        }
      } else {
        await repository.signInWithGoogle();
      }
    } catch (error) {
      if (mounted) {
        final message = error is AuthException
            ? error.message
            : 'Không thể đăng nhập. Vui lòng thử lại.';
        _showMessage(message);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(Icons.local_laundry_service_rounded, size: 80, color: AppColors.primary),
                const SizedBox(height: 24),
                Text(AppStrings.login, style: AppTypography.heading1, textAlign: TextAlign.center),
                const SizedBox(height: 8),
                Text(
                  _isStaffLogin
                      ? 'Dành cho nhân viên, quản lý và chủ cửa hàng.'
                      : 'Khách hàng đăng nhập nhanh bằng tài khoản Google.',
                  style: AppTypography.bodyText.copyWith(color: AppColors.textSecondary),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 28),
                SegmentedButton<bool>(
                  segments: const [
                    ButtonSegment<bool>(
                      value: false,
                      icon: Icon(Icons.account_circle_outlined),
                      label: Text('Khách hàng'),
                    ),
                    ButtonSegment<bool>(
                      value: true,
                      icon: Icon(Icons.badge_outlined),
                      label: Text('Nhân viên'),
                    ),
                  ],
                  selected: {_isStaffLogin},
                  onSelectionChanged: (selection) {
                    setState(() { _isStaffLogin = selection.first; _useEmailPassword = selection.first; });
                  },
                ),
                const SizedBox(height: 28),
                if (_isStaffLogin || _useEmailPassword) ...[
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email tài khoản',
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: AppStrings.password,
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                        icon: Icon(_obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () =>
                          context.pushNamed(AppRoutes.forgotPassword),
                      child: const Text('Quên mật khẩu?'),
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _login,
                  icon: _isLoading
                      ? const SizedBox.square(dimension: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : Icon(_isStaffLogin ? Icons.login : Icons.g_mobiledata, size: 30),
                  label: Text((_isStaffLogin || _useEmailPassword) ? 'Đăng nhập tài khoản' : 'Tiếp tục với Google'),
                ),
                if (!_isStaffLogin)
                  TextButton(
                    onPressed: () => setState(() => _useEmailPassword = !_useEmailPassword),
                    child: Text(_useEmailPassword ? 'Đăng nhập bằng Google' : 'Đăng nhập bằng Gmail và mật khẩu'),
                  ),
                if (!_isStaffLogin) ...[
                  const SizedBox(height: 16),
                  Text(
                    'Tài khoản khách hàng mới sẽ được tạo tự động sau khi xác thực Google.',
                    textAlign: TextAlign.center,
                    style: AppTypography.caption,
                  ),
                ],
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(AppStrings.noAccount, style: AppTypography.bodyText),
                    TextButton(
                      onPressed: () => context.pushNamed(AppRoutes.register),
                      child: const Text(AppStrings.register),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
