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
