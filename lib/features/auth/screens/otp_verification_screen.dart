import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:app_quanly_giaiui/core/navigation/app_routes.dart';
import 'package:app_quanly_giaiui/core/theme/app_colors.dart';
import 'package:app_quanly_giaiui/core/theme/app_typography.dart';
import 'package:app_quanly_giaiui/features/auth/data/auth_repository.dart';

class OtpVerificationScreen extends StatefulWidget {
  const OtpVerificationScreen({required this.phone, this.fullName, super.key});

  final String phone;
  final String? fullName;

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final _tokenController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _tokenController.dispose();
    super.dispose();
  }

  Future<void> _verifyOtp() async {
    final token = _tokenController.text.trim();
    if (!RegExp(r'^\d{6}$').hasMatch(token)) {
      setState(() => _errorMessage = 'Mã xác nhận phải gồm 6 chữ số.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await AuthRepository().verifyPhoneOtp(
        phone: widget.phone,
        token: token,
        fullName: widget.fullName,
      );
      if (mounted) context.goNamed(AppRoutes.home);
    } catch (error) {
      if (mounted) setState(() => _errorMessage = _messageFor(error));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _resendOtp() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await AuthRepository().requestPhoneOtp(
        widget.phone,
        createUser: widget.fullName != null,
        fullName: widget.fullName,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã gửi lại mã xác nhận.')),
        );
      }
    } catch (error) {
      if (mounted) setState(() => _errorMessage = _messageFor(error));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _messageFor(Object error) {
    if (error is AuthException) {
      return error.message;
    }
    if (error is FormatException || error is StateError) {
      return error.toString();
    }
    return 'Không thể xác thực mã. Vui lòng thử lại.';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Xác nhận số điện thoại')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),
              Text('Nhập mã xác nhận', style: AppTypography.heading1),
              const SizedBox(height: 8),
              Text(
                'Mã gồm 6 chữ số đã được gửi đến ${widget.phone}.',
                style: AppTypography.bodyText.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 32),
              TextField(
                controller: _tokenController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Mã xác nhận',
                  prefixIcon: Icon(Icons.pin_outlined),
                ),
                onSubmitted: (_) => _verifyOtp(),
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 8),
                Text(
                  _errorMessage!,
                  style: const TextStyle(color: AppColors.error),
                ),
              ],
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _verifyOtp,
                child: _isLoading
                    ? const SizedBox.square(
                        dimension: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Xác nhận'),
              ),
              TextButton(
                onPressed: _isLoading ? null : _resendOtp,
                child: const Text('Gửi lại mã'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
