import 'package:intl/intl.dart';

class FormatterUtils {
  FormatterUtils._();

  /// Format money (e.g., 100000 -> "100.000 đ")
  static String formatCurrency(double amount) {
    final formatter = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');
    return formatter.format(amount);
  }

  /// Format date (e.g., DateTime -> "19/09/2026")
  static String formatDate(DateTime date) {
    final formatter = DateFormat('dd/MM/yyyy');
    return formatter.format(date);
  }

  /// Format time (e.g., DateTime -> "14:30")
  static String formatTime(DateTime date) {
    final formatter = DateFormat('HH:mm');
    return formatter.format(date);
  }

  /// Format date and time (e.g., DateTime -> "14:30 - 19/09/2026")
  static String formatDateTime(DateTime date) {
    final formatter = DateFormat('HH:mm - dd/MM/yyyy');
    return formatter.format(date);
  }

  /// Obscure phone number (e.g., "0901234567" -> "090****567")
  static String obscurePhone(String phone) {
    if (phone.length < 10) return phone;
    return '${phone.substring(0, 3)}****${phone.substring(phone.length - 3)}';
  }
}
