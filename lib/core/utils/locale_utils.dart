import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

/// Utility class for locale-aware number, currency, date and time formatting.
/// Converts Arabic digits to the script of the selected locale.
///
/// Gujarati: 0=૦ 1=૧ 2=૨ 3=૩ 4=૪ 5=૫ 6=૬ 7=૭ 8=૮ 9=૯
/// Hindi:    0=० 1=१ 2=२ 3=३ 4=४ 5=५ 6=६ 7=७ 8=८ 9=९
class LocaleUtils {
  // Digit maps per language code
  static const Map<String, List<String>> _digits = {
    'en': ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'],
    'gu': ['૦', '૧', '૨', '૩', '૪', '૫', '૬', '૭', '૮', '૯'],
    'hi': ['०', '१', '२', '३', '४', '५', '६', '७', '८', '९'],
  };

  // Month names per language
  static const Map<String, List<String>> _months = {
    'en': [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ],
    'gu': [
      'જાન', 'ફેબ', 'માર', 'એપ્રિ', 'મે', 'જૂન',
      'જુલ', 'ઑગ', 'સેપ', 'ઑક', 'નવ', 'ડિસ'
    ],
    'hi': [
      'जन', 'फ़र', 'मार', 'अप्र', 'मई', 'जून',
      'जुल', 'अग', 'सित', 'अक्त', 'नव', 'दिस'
    ],
  };

  /// Returns current language code from context
  static String _lang(BuildContext context) =>
      context.locale.languageCode;

  /// Converts any digit characters in [value] to locale-specific script.
  /// Non-digit characters (e.g. '.', '-', ',') are left unchanged.
  ///
  /// Example (Gujarati): '525.50' → '૫૨૫.૫૦'
  static String formatNumber(BuildContext context, dynamic value) {
    final lang = _lang(context);
    final digits = _digits[lang] ?? _digits['en']!;
    return value.toString().split('').map((c) {
      final d = int.tryParse(c);
      return d != null ? digits[d] : c;
    }).join();
  }

  /// Formats a currency amount: ₹ symbol stays, digits are localized.
  /// Example (Hindi): 525.00 → ₹५२५.००
  static String formatCurrency(BuildContext context, double amount) {
    final formatted = amount.toStringAsFixed(2);
    return '₹${formatNumber(context, formatted)}';
  }

  /// Formats an integer count with locale digits.
  static String formatCount(BuildContext context, int count) {
    return formatNumber(context, count);
  }

  /// Parses a date string and returns locale-aware formatted date.
  /// Handles ISO format (2026-04-02) and "dd MMM yyyy" format.
  /// Example (Gujarati): '2026-04-02' → '૦૨ એપ્રિ ૨૦૨૬'
  static String formatDate(BuildContext context, String dateStr) {
    try {
      DateTime date;
      if (dateStr.contains('-') && dateStr.length >= 10) {
        // ISO format: 2026-04-02 or 2026-04-02T...
        date = DateTime.parse(dateStr.substring(0, 10));
      } else {
        // Try "dd MMM yyyy" format
        try {
          date = DateFormat('dd MMM yyyy').parse(dateStr);
        } catch (_) {
          return dateStr; // Return as-is if unparseable
        }
      }
      final lang = _lang(context);
      final months = _months[lang] ?? _months['en']!;
      final day = formatNumber(
        context,
        date.day.toString().padLeft(2, '0'),
      );
      final month = months[date.month - 1];
      final year = formatNumber(context, date.year);
      return '$day $month $year';
    } catch (_) {
      return dateStr;
    }
  }

  /// Formats a time string (e.g. '10:30', '10:30 AM') with locale digits.
  static String formatTime(BuildContext context, String time) {
    return formatNumber(context, time);
  }

  /// Formats a percentage value with locale digits.
  /// Example (Gujarati): 5.0 → '૫%'
  static String formatPercent(BuildContext context, double value) {
    return '${formatNumber(context, value.toInt())}%';
  }
}
