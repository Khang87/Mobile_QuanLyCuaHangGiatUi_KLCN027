import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:app_quanly_giaiui/core/config/supabase_config.dart';

class AuthRepository {
  static const passwordRecoveryRedirectTo =
      'io.supabase.appquanlygiaui://login-callback/reset-password';

  AuthRepository({SupabaseClient? client})
    : _client = client ?? _configuredClient();

  final SupabaseClient _client;

  Future<AuthenticatedProfile?> getCurrentProfile() async {
    final user = _client.auth.currentUser;
    if (user == null) return null;

    final account = await _client
        .from('taikhoan')
        .select(
          'email,sodienthoai,khachhang(hoten,diachi,avatarurl),nhanvien(hoten)',
        )
        .eq('userauthid', user.id)
        .maybeSingle();
    if (account == null) return null;

    final customer = account['khachhang'] as Map<String, dynamic>?;
    final employee = account['nhanvien'] as Map<String, dynamic>?;
    final roles = await getCurrentRoles();

    return AuthenticatedProfile(
      displayName:
          customer?['hoten'] as String? ??
          employee?['hoten'] as String? ??
          user.phone ??
          'Tài khoản',
      phone: account['sodienthoai'] as String? ?? user.phone,
      email: account['email'] as String? ?? user.email,
      address: customer?['diachi'] as String?,
      avatarUrl: customer?['avatarurl'] as String?,
      roles: roles,
    );
  }

  Future<List<String>> getCurrentRoles() async {
    final roles = await _client.rpc('get_current_roles');
    return (roles as List<dynamic>).whereType<String>().toList(growable: false);
  }

  static SupabaseClient _configuredClient() {
    if (!SupabaseConfig.isConfigured) {
      throw StateError(
        'Cấu hình SUPABASE_URL và SUPABASE_PUBLISHABLE_KEY trước khi đăng nhập.',
      );
    }
    return Supabase.instance.client;
  }

  static String normalizeVietnamesePhone(String value) {
    final trimmed = value.trim();
    final digits = trimmed.replaceAll(RegExp(r'[^0-9]'), '');

    if (trimmed.startsWith('+')) {
      if (digits.length < 8 || digits.length > 15 || digits.startsWith('0')) {
        throw const FormatException('Số điện thoại không hợp lệ.');
      }
      return '+$digits';
    }

    if (digits.length == 10 && digits.startsWith('0')) {
      return '+84${digits.substring(1)}';
    }
    if (digits.length == 11 && digits.startsWith('84')) {
      return '+$digits';
    }

    throw const FormatException('Nhập số điện thoại Việt Nam hợp lệ.');
  }

  Future<void> requestPhoneOtp(
    String phone, {
    required bool createUser,
    String? fullName,
  }) async {
    final normalizedPhone = normalizeVietnamesePhone(phone);
    final name = fullName?.trim();

    await _client.auth.signInWithOtp(
      phone: normalizedPhone,
      shouldCreateUser: createUser,
      data: name == null || name.isEmpty ? null : {'full_name': name},
    );
  }

  Future<void> signInWithGoogle() async {
    final started = await _client.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: 'io.supabase.appquanlygiaui://login-callback',
      authScreenLaunchMode: LaunchMode.externalApplication,
      queryParams: const {'prompt': 'select_account'},
    );

    if (!started) {
      throw const AuthException('Không thể mở đăng nhập Google.');
    }
  }

  Future<void> signInWithPassword({
    required String email,
    required String password,
  }) async {
    await _client.auth.signInWithPassword(
      email: email.trim(),
      password: password,
    );
  }

  Future<void> signUpCustomer({
    required String fullName,
    required String email,
    required String password,
  }) async {
    final response = await _client.auth.signUp(
      email: email.trim(),
      password: password,
      data: {'full_name': fullName.trim()},
    );
    if (response.session != null) await ensureCustomerProfile();
  }

  Future<void> ensureCustomerProfile() async {
    final user = _client.auth.currentUser;
    if (user == null) return;
    await _client.rpc(
      'complete_google_customer_profile',
      params: {'p_full_name': user.userMetadata?['full_name'] ?? user.email},
    );
  }

  Future<void> requestPasswordReset(String email) async {
    await _client.auth.resetPasswordForEmail(
      email.trim(),
      redirectTo: kIsWeb ? Uri.base.origin : passwordRecoveryRedirectTo,
    );
  }

  Future<void> updatePassword(String password) async {
    if (_client.auth.currentSession == null) {
      throw const AuthException(
        'Liên kết đặt lại mật khẩu không hợp lệ hoặc đã hết hạn.',
      );
    }
    await _client.auth.updateUser(UserAttributes(password: password));
  }

  Future<void> ensureGoogleCustomerProfile() async {
    final user = _client.auth.currentUser;
    if (user == null) return;

    final isGoogleUser =
        user.appMetadata['provider'] == 'google' ||
        (user.identities ?? const []).any(
          (identity) => identity.provider == 'google',
        );
    if (!isGoogleUser) return;

    await _client
        .rpc(
          'complete_google_customer_profile',
          params: {'p_full_name': user.userMetadata?['full_name']},
        )
        .timeout(const Duration(seconds: 10));
  }

  Future<void> verifyPhoneOtp({
    required String phone,
    required String token,
    String? fullName,
  }) async {
    if (_client.auth.currentSession == null) {
      final response = await _client.auth.verifyOTP(
        phone: normalizeVietnamesePhone(phone),
        token: token.trim(),
        type: OtpType.sms,
      );

      if (response.session == null) {
        throw const AuthException('Không thể xác thực mã OTP.');
      }
    }

    await _client.rpc(
      'complete_customer_profile',
      params: {'p_full_name': fullName?.trim()},
    );
  }

  Future<void> signOut() => _client.auth.signOut();

  Future<void> updateCustomerProfile({
    required String fullName,
    String? email,
    String? phone,
    String? address,
  }) => _client.rpc(
    'update_customer_profile',
    params: {
      'p_full_name': fullName.trim(),
      'p_email': email?.trim(),
      'p_phone': phone?.trim(),
      'p_address': address?.trim(),
    },
  );

  Future<String> uploadAvatar(Uint8List bytes, String extension) async {
    final user = _client.auth.currentUser;
    if (user == null) throw const AuthException('Bạn cần đăng nhập.');
    final path =
        '${user.id}/avatar-${DateTime.now().microsecondsSinceEpoch}.$extension';
    final contentType = extension == 'jpg' || extension == 'jpeg'
        ? 'image/jpeg'
        : 'image/$extension';
    await _client.storage
        .from('avatars')
        .uploadBinary(
          path,
          bytes,
          fileOptions: FileOptions(upsert: true, contentType: contentType),
        );
    final url = _client.storage.from('avatars').getPublicUrl(path);
    final profile = await getCurrentProfile();
    await _client.rpc(
      'update_customer_profile_with_avatar',
      params: {
        'p_full_name':
            profile?.displayName ??
            user.userMetadata?['full_name'] ??
            user.email ??
            'Khách hàng',
        'p_email': profile?.email ?? user.email,
        'p_phone': profile?.phone ?? user.phone,
        'p_address': profile?.address,
        'p_avatar_url': url,
      },
    );
    return url;
  }
}

class AuthenticatedProfile {
  const AuthenticatedProfile({
    required this.displayName,
    required this.phone,
    required this.email,
    this.address,
    this.avatarUrl,
    this.roles = const <String>[],
  });

  final String displayName;
  final String? phone;
  final String? email;
  final String? address;
  final String? avatarUrl;
  final List<String> roles;
}
