import 'package:app_quanly_giaiui/core/utils/validator_utils.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ValidatorUtils.validatePhone', () {
    test('accepts common Vietnamese mobile formats', () {
      expect(ValidatorUtils.validatePhone('0901234567'), isNull);
      expect(ValidatorUtils.validatePhone('+84 901 234 567'), isNull);
      expect(ValidatorUtils.validatePhone('84-901-234-567'), isNull);
    });

    test('rejects empty and malformed phone numbers', () {
      expect(ValidatorUtils.validatePhone('  '), isNotNull);
      expect(ValidatorUtils.validatePhone('09012345678'), isNotNull);
      expect(ValidatorUtils.validatePhone('0201234567'), isNotNull);
    });
  });
}