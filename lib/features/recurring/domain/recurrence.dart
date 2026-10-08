import 'entities/recurring_rule.dart';

int _daysInMonth(int year, int month) => DateTime(year, month + 1, 0).day;

/// The [index]-th occurrence (0-based) of a schedule starting at [start].
/// Always computed from [start], never by stepping, so there is no drift.
DateTime occurrenceAt(DateTime start, RecurrenceFrequency f, int index) {
  switch (f) {
    case RecurrenceFrequency.daily:
      return DateTime(start.year, start.month, start.day + index);
    case RecurrenceFrequency.weekly:
      return DateTime(start.year, start.month, start.day + 7 * index);
    case RecurrenceFrequency.monthly:
      final total = start.year * 12 + (start.month - 1) + index;
      final year = total ~/ 12;
      final month = total % 12 + 1;
      final dim = _daysInMonth(year, month);
      return DateTime(year, month, start.day < dim ? start.day : dim);
    case RecurrenceFrequency.yearly:
      final year = start.year + index;
      final dim = _daysInMonth(year, start.month);
      return DateTime(year, start.month, start.day < dim ? start.day : dim);
  }
}
