import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:app_quanly_giaiui/core/constants/app_strings.dart';
import 'package:app_quanly_giaiui/core/theme/app_colors.dart';
import 'package:app_quanly_giaiui/core/theme/app_typography.dart';
import 'package:app_quanly_giaiui/core/utils/validator_utils.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  bool _otpSent = false;
  final _otpController = TextEditingController();
  final _newPasswordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  void _handleSendOtp() {
    if (_formKey.currentState?.validate() ?? false) {
      // TODO: Implement actual OTP sending via Firebase or API
      setState(() {
        _otpSent = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${AppStrings.otpSent} ${_phoneController.text}'),
        ),
      );
    }
  }

  void _handleResetPassword() {
    // TODO: Implement actual password reset logic
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đặt lại mật khẩu thành công!')),
    );
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.forgotPassword),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Illustration
              Container(
                width: 120,
                height: 120,
                decoration: const BoxDecoration(
                  color: AppColors.primaryLight,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.lock_reset_outlined,
                  size: 60,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 32),
              
              Text(
                AppStrings.resetPassword,
                style: AppTypography.heading2,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Nhập số điện thoại đã đăng ký để nhận mã xác nhận',
                style: AppTypography.bodyText.copyWith(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 32),

              // Phone Input
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: AppStrings.phoneNumber,
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
                validator: ValidatorUtils.validatePhone,
                enabled: !_otpSent,
              ),
              
              const SizedBox(height: 16),

              if (!_otpSent) ...[
                // Send OTP Button
                ElevatedButton(
                  onPressed: _handleSendOtp,
                  child: const Text('Gửi mã xác nhận'),
                ),
              ],

              if (_otpSent) ...[
                // OTP Input
                TextFormField(
                  controller: _otpController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: AppStrings.enterOtp,
                    prefixIcon: Icon(Icons.pin_outlined),
                  ),
                  maxLength: 6,
                ),
                const SizedBox(height: 16),
                
                // New Password Input
                TextFormField(
                  controller: _newPasswordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: AppStrings.newPassword,
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                        color: AppColors.textMuted,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                  validator: ValidatorUtils.validatePassword,
                ),
                const SizedBox(height: 24),
                
                // Reset Password Button
                ElevatedButton(
                  onPressed: _handleResetPassword,
                  child: const Text(AppStrings.resetPassword),
                ),
                
                const SizedBox(height: 16),

                // Resend OTP
                TextButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Đã gửi lại mã xác nhận!')),
                    );
                  },
                  child: const Text('Gửi lại mã'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
