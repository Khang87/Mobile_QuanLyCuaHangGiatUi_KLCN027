import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:app_quanly_giaiui/core/constants/app_strings.dart';
import 'package:app_quanly_giaiui/core/theme/app_colors.dart';
import 'package:app_quanly_giaiui/core/theme/app_typography.dart';
import 'package:app_quanly_giaiui/features/auth/data/auth_repository.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool _isLoading = false;
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() { _name.dispose(); _email.dispose(); _password.dispose(); super.dispose(); }

  Future<void> _registerWithEmail() async {
    if (_name.text.trim().isEmpty || !_email.text.contains('@') || _password.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Nhập họ tên, Gmail hợp lệ và mật khẩu tối thiểu 6 ký tự.')));
      return;
    }
    setState(() => _isLoading = true);
    try {
      await AuthRepository().signUpCustomer(fullName: _name.text, email: _email.text, password: _password.text);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã đăng ký. Hãy kiểm tra Gmail để xác thực tài khoản.')));
    } catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Không thể đăng ký: $error')));
    } finally { if (mounted) setState(() => _isLoading = false); }
  }

  Future<void> _registerWithGoogle() async {
    setState(() => _isLoading = true);
    try {
      await AuthRepository().signInWithGoogle();
    } catch (error) {
      if (mounted) {
        final message = error is AuthException
            ? error.message
            : 'Không thể đăng ký bằng Google. Vui lòng thử lại.';
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(AppStrings.register, style: AppTypography.heading1),
                const SizedBox(height: 8),
                Text(
                  'Đăng ký bằng Gmail và mật khẩu, hoặc tiếp tục nhanh với Google.',
                  style: AppTypography.bodyText.copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 28),
                TextField(controller: _name, decoration: const InputDecoration(labelText: 'Họ và tên', prefixIcon: Icon(Icons.person_outline))),
                const SizedBox(height: 12),
                TextField(controller: _email, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: 'Gmail', prefixIcon: Icon(Icons.email_outlined))),
                const SizedBox(height: 12),
                TextField(controller: _password, obscureText: true, decoration: const InputDecoration(labelText: 'Mật khẩu', prefixIcon: Icon(Icons.lock_outline))),
                const SizedBox(height: 16),
                ElevatedButton(onPressed: _isLoading ? null : _registerWithEmail, child: const Text('Đăng ký bằng Gmail')),
                const SizedBox(height: 12),
                const Center(child: Text('hoặc')),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _registerWithGoogle,
                  icon: _isLoading
                      ? const SizedBox.square(dimension: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.g_mobiledata, size: 30),
                  label: const Text('Đăng ký bằng Google'),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(AppStrings.haveAccount, style: AppTypography.bodyText),
                    TextButton(
                      onPressed: () => context.pop(),
                      child: const Text(AppStrings.login),
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
