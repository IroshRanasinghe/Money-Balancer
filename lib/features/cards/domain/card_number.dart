import 'entities/bank_card.dart';

/// Strips everything except ASCII digits.
String digitsOnly(String input) => input.replaceAll(RegExp(r'\D'), '');

/// 12 to 19 digits that pass the Luhn checksum.
bool isValidCardNumber(String digits) {
  if (!RegExp(r'^\d{12,19}$').hasMatch(digits)) return false;
  var sum = 0;
  var alternate = false;
  for (var i = digits.length - 1; i >= 0; i--) {
    var d = digits.codeUnitAt(i) - 0x30;
    if (alternate) {
      d *= 2;
      if (d > 9) d -= 9;
    }
    sum += d;
    alternate = !alternate;
  }
  return sum % 10 == 0;
}

CardNetwork detectNetwork(String digits) {
  if (digits.startsWith('4')) return CardNetwork.visa;
  if (digits.length >= 2) {
    final two = int.parse(digits.substring(0, 2));
    if (two >= 51 && two <= 55) return CardNetwork.mastercard;
    if (two == 34 || two == 37) return CardNetwork.amex;
  }
  if (digits.length >= 4) {
    final four = int.parse(digits.substring(0, 4));
    if (four >= 2221 && four <= 2720) return CardNetwork.mastercard;
  }
  return CardNetwork.other;
}

/// Groups of 4, except Amex which is 4-6-5.
String formatCardNumber(String digits) {
  final groups = detectNetwork(digits) == CardNetwork.amex
      ? const [4, 6, 5]
      : const [4, 4, 4, 4, 3];
  final parts = <String>[];
  var i = 0;
  for (final g in groups) {
    if (i >= digits.length) break;
    final end = (i + g).clamp(0, digits.length);
    parts.add(digits.substring(i, end));
    i = end;
  }
  if (i < digits.length) parts.add(digits.substring(i));
  return parts.join(' ');
}

/// Offset in [formatted] just after its [digitCount]-th digit (0 when 0).
int caretOffsetForDigitCount(String formatted, int digitCount) {
  if (digitCount <= 0) return 0;
  var seen = 0;
  for (var i = 0; i < formatted.length; i++) {
    final c = formatted.codeUnitAt(i);
    if (c >= 0x30 && c <= 0x39) {
      seen++;
      if (seen == digitCount) return i + 1;
    }
  }
  return formatted.length;
}
