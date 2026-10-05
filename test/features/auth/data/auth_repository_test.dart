import 'package:app_quanly_giaiui/features/auth/data/auth_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AuthRepository.normalizeVietnamesePhone', () {
    test('converts a local Vietnamese number to E.164', () {
      expect(
        AuthRepository.normalizeVietnamesePhone('090 123 4567'),
        '+84901234567',
      );
    });

    test('normalizes international Vietnamese formats', () {
      expect(
        AuthRepository.normalizeVietnamesePhone('+84 901 234 567'),
        '+84901234567',
      );
      expect(
        AuthRepository.normalizeVietnamesePhone('84 901 234 567'),
        '+84901234567',
      );
    });

    test('rejects unsupported or malformed local numbers', () {
      expect(
        () => AuthRepository.normalizeVietnamesePhone('12345'),
        throwsFormatException,
      );
      expect(
        () => AuthRepository.normalizeVietnamesePhone('09012345678'),
        throwsFormatException,
      );
    });
  });
}