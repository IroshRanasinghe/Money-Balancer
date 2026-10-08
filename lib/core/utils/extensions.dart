extension DateTimeX on DateTime {
  bool isSameMonth(DateTime other) =>
      year == other.year && month == other.month;

  /// First day of the month [delta] months away; rolls years correctly.
  DateTime addMonths(int delta) => DateTime(year, month + delta);
}
