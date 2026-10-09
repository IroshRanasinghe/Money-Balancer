import 'package:intl/intl.dart';

import '../../domain/entities/transaction.dart';

/// Transactions that fall on the same calendar day, in list order.
class TransactionDayGroup {
  const TransactionDayGroup({required this.day, required this.items});

  final DateTime day;
  final List<Transaction> items;

  /// Income minus expenses for the day.
  double get net => items.fold(
    0.0,
    (sum, t) => sum + (t.type == TransactionType.income ? t.amount : -t.amount),
  );

  /// `Today`, `Yesterday`, or `EEE, MMM d`.
  String label(DateTime now) {
    final today = DateTime(now.year, now.month, now.day);
    final diff = today.difference(day).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    return DateFormat('EEE, MMM d').format(day);
  }
}

/// Groups [list] into contiguous same-day runs, keeping its order.
List<TransactionDayGroup> groupTransactionsByDay(List<Transaction> list) {
  final groups = <TransactionDayGroup>[];
  for (final t in list) {
    final day = DateTime(t.date.year, t.date.month, t.date.day);
    if (groups.isNotEmpty && groups.last.day == day) {
      groups.last.items.add(t);
    } else {
      groups.add(TransactionDayGroup(day: day, items: [t]));
    }
  }
  return groups;
}
