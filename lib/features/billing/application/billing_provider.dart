import 'package:flutter/foundation.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/session/session_scoped.dart';
import '../../../data/models/api/billing_models.dart';
import '../../../data/models/api/json_helpers.dart';
import '../../../data/models/api/user_models.dart';
import '../../../data/repositories/billing_repository.dart';

/// "120" for whole amounts, "120.50" otherwise.
String formatMoney(double value) =>
    value == value.roundToDouble() ? '${value.toInt()}' : value.toStringAsFixed(2);

/// The master's balance, subscription state and payment history, straight
/// from `/me/billing`. The server owns every number here: after a payment
/// the app only asks again ([refresh]); it never edits the balance or the
/// subscription status itself.
class BillingProvider extends SessionScoped {
  BillingProvider(this._repository);

  final BillingRepository _repository;

  Billing? _billing;
  final List<LedgerTransaction> _history = [];
  String? _cursor;
  bool _loading = false;
  bool _loadingMore = false;
  ApiException? _error;

  bool get loaded => _billing != null;
  bool get loading => _loading;
  bool get loadingMore => _loadingMore;
  ApiException? get error => _error;
  Billing? get billing => _billing;

  double get balanceValue => _billing?.balance ?? 0;
  String get balance => formatMoney(balanceValue);
  SubscriptionStatus get status => _billing?.status ?? SubscriptionStatus.suspended;
  bool get acceptingBookings => _billing?.acceptingBookings ?? false;
  DateTime? get paidUntil => _billing?.paidUntil;
  DateTime? get nextChargeAt => _billing?.nextChargeAt;

  /// Newest first.
  List<LedgerTransaction> get history => List.unmodifiable(_history);
  bool get hasMoreHistory => _cursor != null;

  /// The most recent successful subscription charge, if any is loaded.
  DateTime? get lastChargeAt {
    for (final entry in _history) {
      if (entry.type == LedgerType.charge && entry.status == LedgerStatus.succeeded) {
        return entry.createdAt;
      }
    }
    return null;
  }

  @override
  void reset() {
    _billing = null;
    _history.clear();
    _cursor = null;
    _loading = _loadingMore = false;
    _error = null;
  }

  @override
  Future<void> onSignedIn(Me me) async {
    if (me.isMaster) await load();
  }

  /// Billing summary plus the first page of the ledger.
  Future<void> load() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final results = await Future.wait<Object>([
        _repository.billing(),
        _repository.transactions(),
      ]);
      _billing = results[0] as Billing;
      final page = results[1] as ApiPage<LedgerTransaction>;
      _history
        ..clear()
        ..addAll(page.items);
      _cursor = page.nextCursor;
    } on ApiException catch (e) {
      _error = e;
      debugPrint('Loading billing failed: $e');
    }
    _loading = false;
    notifyListeners();
  }

  /// Re-reads balance/status and the newest ledger page, e.g. right after a
  /// payment went through.
  Future<void> refresh() => load();

  Future<void> loadMoreHistory() async {
    final cursor = _cursor;
    if (cursor == null || _loadingMore) return;
    _loadingMore = true;
    notifyListeners();
    try {
      final page = await _repository.transactions(cursor: cursor);
      _history.addAll(page.items);
      _cursor = page.nextCursor;
    } on ApiException catch (e) {
      debugPrint('Loading more transactions failed: $e');
    }
    _loadingMore = false;
    notifyListeners();
  }

  // ---- phone payment ----------------------------------------------------

  /// Asks the server which number to pay. Throws `PAYMENT_UNAVAILABLE`
  /// (404) when no number is free.
  Future<MobileTopup> startMobilePayment(num amount) =>
      _repository.topUpMobile(amount);

  /// Transfers the payment system has seen so far. When one has completed
  /// the balance and subscription are re-read.
  Future<PhonePayments> checkPhonePayments() async {
    final result = await _repository.phonePayments();
    if (result.payments.any((p) => p.status == PhonePaymentStatus.completed) &&
        (result.balance != _billing?.balance ||
            result.subscriptionStatus != _billing?.status)) {
      await refresh();
    }
    return result;
  }

  // ---- card payment -----------------------------------------------------

  /// Creates a bank order; open [CardTopup.formUrl] in a WebView.
  Future<CardTopup> startCardPayment(num amount) => _repository.topUpCard(amount);

  /// Asks the bank (through the server) how the order ended. Pass the
  /// [cardTransactionId] when signed in, or just the bank's [orderId].
  /// On `success` the new balance and subscription are loaded.
  Future<CardPaymentResult> checkCardPayment({int? cardTransactionId, String? orderId}) async {
    assert(cardTransactionId != null || orderId != null);
    final result = cardTransactionId != null
        ? await _repository.cardStatus(cardTransactionId)
        : await _repository.paymentResult(orderId!);
    if (result.status == CardPaymentStatus.success) await refresh();
    return result;
  }
}
