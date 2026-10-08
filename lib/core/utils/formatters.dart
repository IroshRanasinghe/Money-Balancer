import 'package:intl/intl.dart';

String formatCurrency(double amount, String currencyCode) =>
    NumberFormat.simpleCurrency(name: currencyCode).format(amount);

String formatDate(DateTime date) => DateFormat('MMM d, yyyy').format(date);

String formatMonthYear(int month, int year) =>
    DateFormat('MMMM yyyy').format(DateTime(year, month));

String formatShortMonth(int month, int year) =>
    DateFormat('MMM').format(DateTime(year, month));

/// Parses user-entered money. Accepts `12.5`, and a comma only as a decimal
/// separator with 1 or 2 digits after it (`12,5`, `12,50`). Any other input
/// containing a comma (e.g. thousands separators like `1,234`) is rejected.
/// Returns null for empty, non-numeric, non-finite, zero or negative input.
double? parseAmount(String input) {
  final trimmed = input.trim();
  var normalized = trimmed;
  if (trimmed.contains(',')) {
    if (!RegExp(r'^[^,.]*,\d{1,2}$').hasMatch(trimmed)) return null;
    normalized = trimmed.replaceAll(',', '.');
  }
  final value = double.tryParse(normalized);
  if (value == null || !value.isFinite || value <= 0) return null;
  return value;
}

/// Like [parseAmount] but for values that may be zero or negative (e.g. an
/// opening balance). Empty input is 0; an optional leading `-` is allowed.
/// Returns null for invalid input.
double? parseSignedAmount(String input) {
  final trimmed = input.trim();
  if (trimmed.isEmpty) return 0;
  final negative = trimmed.startsWith('-');
  final body = negative ? trimmed.substring(1) : trimmed;
  if (body.isEmpty || !RegExp(r'^[0-9.,]').hasMatch(body)) return null;
  final value = parseAmount(body) ?? (_isZeroAmount(body) ? 0.0 : null);
  if (value == null) return null;
  return negative && value != 0 ? -value : value;
}

bool _isZeroAmount(String body) {
  var normalized = body;
  if (body.contains(',')) {
    if (!RegExp(r'^[^,.]*,\d{1,2}$').hasMatch(body)) return false;
    normalized = body.replaceAll(',', '.');
  }
  return double.tryParse(normalized) == 0;
}
