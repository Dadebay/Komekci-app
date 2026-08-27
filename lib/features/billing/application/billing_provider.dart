import 'package:flutter/foundation.dart';

enum LedgerEntryType { topUp, subscriptionCharge }

enum LedgerEntryStatus { success, pending, failed }

/// One balance-affecting event: a top-up the master made, or a monthly
/// subscription charge. [resultingBalance] is the balance immediately after
/// this entry — for [LedgerEntryStatus.pending]/[LedgerEntryStatus.failed]
/// entries that's just the balance unchanged, since nothing was applied yet.
class LedgerEntry {
  const LedgerEntry({
    required this.id,
    required this.date,
    required this.type,
    required this.amount,
    required this.resultingBalance,
    required this.status,
  });

  final String id;
  final DateTime date;
  final LedgerEntryType type;
  final int amount;
  final int resultingBalance;
  final LedgerEntryStatus status;
}

/// Master's balance and payment ledger. [topUp] is the only way the balance
/// moves for now — there's no real payment provider, so callers decide
/// whether an attempt counts as [LedgerEntryStatus.success] up front and
/// this just records the outcome.
class BillingProvider extends ChangeNotifier {
  BillingProvider()
    : balance = _initialBalance,
      lastPaymentDate = _initialLastPayment,
      nextPaymentDate = _addMonths(_initialLastPayment, 1);

  static const _initialBalance = 50;
  static final _initialLastPayment = DateTime(2026, 8, 1);

  int balance;
  DateTime lastPaymentDate;
  DateTime nextPaymentDate;

  final List<LedgerEntry> _history = [];

  /// Newest first.
  List<LedgerEntry> get history => List.unmodifiable(_history.reversed);

  int _nextId = 1;

  void topUp(int amount, {required bool success}) {
    if (success) balance += amount;
    _history.add(
      LedgerEntry(
        id: 'txn_${_nextId++}',
        date: DateTime.now(),
        type: LedgerEntryType.topUp,
        amount: amount,
        resultingBalance: balance,
        status: success ? LedgerEntryStatus.success : LedgerEntryStatus.pending,
      ),
    );
    notifyListeners();
  }

  static DateTime _addMonths(DateTime date, int months) =>
      DateTime(date.year, date.month + months, date.day);
}
