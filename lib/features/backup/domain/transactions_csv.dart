import 'package:intl/intl.dart';

import '../../transactions/domain/entities/transaction.dart';

/// Builds an RFC 4180 CSV (CRLF line endings) in the order given. Starts with
/// a UTF-8 BOM so Excel doesn't mangle non-ASCII text such as the card dots.
String buildTransactionsCsv(
  List<Transaction> txs,
  Map<String, String> accountNames,
) {
  final dateFormat = DateFormat('yyyy-MM-dd');
  final buffer = StringBuffer()
    ..write('\uFEFF')
    ..write(
      _row(const [
        'Date',
        'Type',
        'Category',
        'Amount',
        'Payment method',
        'Card',
        'Account',
        'Notes',
      ]),
    );
  for (final t in txs) {
    buffer.write(
      _row([
        dateFormat.format(t.date),
        t.type == TransactionType.income ? 'Income' : 'Expense',
        t.category,
        t.amount.toStringAsFixed(2),
        t.paymentMethod ?? '',
        t.cardLast4 != null ? '•••• ${t.cardLast4}' : '',
        t.accountId != null ? (accountNames[t.accountId] ?? '') : '',
        t.notes ?? '',
      ]),
    );
  }
  return buffer.toString();
}

String _row(List<String> fields) => '${fields.map(_escape).join(',')}\r\n';

String _escape(String field) {
  if (field.contains(',') ||
      field.contains('"') ||
      field.contains('\r') ||
      field.contains('\n')) {
    return '"${field.replaceAll('"', '""')}"';
  }
  return field;
}
