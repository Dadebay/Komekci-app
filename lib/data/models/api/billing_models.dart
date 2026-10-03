import 'json_helpers.dart';
import 'user_models.dart';

/// `GET /me/billing`.
class Billing {
  const Billing({
    required this.balance,
    required this.subscriptionPrice,
    required this.status,
    required this.acceptingBookings,
    this.nextChargeAt,
    this.paidUntil,
    this.paymentMethods = const ['mobile', 'card'],
    this.phone,
    this.phoneDailyLimit = 7,
    this.phoneMinAmount = 20,
  });

  final double balance;
  final double subscriptionPrice;
  final SubscriptionStatus status;
  final bool acceptingBookings;
  final DateTime? nextChargeAt;
  final DateTime? paidUntil;
  final List<String> paymentMethods;

  /// Number the master transfers money to; null = phone payment unavailable.
  final String? phone;
  final int phoneDailyLimit;
  final double phoneMinAmount;

  factory Billing.fromJson(Map<String, dynamic> json) => Billing(
    balance: parseMoney(json['balance']),
    subscriptionPrice: parseMoney(json['subscription_price']),
    status: SubscriptionStatus.parse(json['subscription_status']),
    acceptingBookings: json['accepting_bookings'] as bool? ?? false,
    nextChargeAt: parseApiTime(json['next_charge_at']),
    paidUntil: parseApiTime(json['paid_until']),
    paymentMethods: [
      for (final m in (json['payment_methods'] as List? ?? const ['mobile', 'card'])) '$m',
    ],
    phone: json['phone'] as String?,
    phoneDailyLimit: parseIntOrNull(json['phone_daily_limit']) ?? 7,
    phoneMinAmount: parseMoney(json['phone_min_amount'] ?? '20.00'),
  );
}

enum LedgerType { topup, charge, refund }

enum LedgerStatus { succeeded, pending, failed }

/// One row of `GET /me/billing/transactions`.
class LedgerTransaction {
  const LedgerTransaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.balanceAfter,
    required this.method,
    required this.status,
    required this.createdAt,
  });

  final int id;
  final LedgerType type;
  final double amount;
  final double balanceAfter;

  /// `mobile`, `card` or `system`.
  final String method;
  final LedgerStatus status;
  final DateTime createdAt;

  factory LedgerTransaction.fromJson(Map<String, dynamic> json) => LedgerTransaction(
    id: parseIntOrNull(json['id']) ?? 0,
    type: switch (json['type']) {
      'charge' => LedgerType.charge,
      'refund' => LedgerType.refund,
      _ => LedgerType.topup,
    },
    amount: parseMoney(json['amount']),
    balanceAfter: parseMoney(json['balance_after']),
    method: json['method'] as String? ?? 'system',
    status: switch (json['status']) {
      'pending' => LedgerStatus.pending,
      'failed' => LedgerStatus.failed,
      _ => LedgerStatus.succeeded,
    },
    createdAt: parseApiTime(json['created_at']) ?? DateTime.now(),
  );
}

/// `POST /me/billing/topup` with `method: mobile` — which number to pay.
class MobileTopup {
  const MobileTopup({
    required this.amount,
    required this.phone,
    required this.phoneUsed,
    required this.phoneDailyLimit,
    required this.phoneMinAmount,
    required this.balance,
    required this.subscriptionStatus,
  });

  final double amount;
  final String phone;
  final int phoneUsed;
  final int phoneDailyLimit;
  final double phoneMinAmount;
  final double balance;
  final SubscriptionStatus subscriptionStatus;

  factory MobileTopup.fromJson(Map<String, dynamic> json) => MobileTopup(
    amount: parseMoney(json['amount']),
    phone: json['phone'] as String? ?? '',
    phoneUsed: parseIntOrNull(json['phone_used']) ?? 0,
    phoneDailyLimit: parseIntOrNull(json['phone_daily_limit']) ?? 7,
    phoneMinAmount: parseMoney(json['phone_min_amount'] ?? '20.00'),
    balance: parseMoney(json['balance']),
    subscriptionStatus: SubscriptionStatus.parse(json['subscription_status']),
  );
}

enum PhonePaymentStatus { pending, completed, rejected }

/// An incoming phone transfer seen by the payment system.
class PhonePayment {
  const PhonePayment({
    required this.id,
    required this.amount,
    required this.status,
    required this.createdAt,
    this.pendingReason,
    this.receiver,
  });

  final int id;
  final double amount;
  final PhonePaymentStatus status;

  /// `amount_too_low` or `user_not_found` while pending.
  final String? pendingReason;
  final String? receiver;
  final DateTime createdAt;

  factory PhonePayment.fromJson(Map<String, dynamic> json) => PhonePayment(
    id: parseIntOrNull(json['id']) ?? 0,
    amount: parseMoney(json['amount']),
    status: switch (json['status']) {
      'completed' => PhonePaymentStatus.completed,
      'rejected' => PhonePaymentStatus.rejected,
      _ => PhonePaymentStatus.pending,
    },
    pendingReason: json['pending_reason'] as String?,
    receiver: json['receiver'] as String?,
    createdAt: parseApiTime(json['created_at']) ?? DateTime.now(),
  );
}

/// `GET /me/billing/phone`.
class PhonePayments {
  const PhonePayments({
    required this.balance,
    required this.subscriptionStatus,
    required this.payments,
    this.paidUntil,
  });

  final double balance;
  final SubscriptionStatus subscriptionStatus;
  final DateTime? paidUntil;
  final List<PhonePayment> payments;

  factory PhonePayments.fromJson(Map<String, dynamic> json) => PhonePayments(
    balance: parseMoney(json['balance']),
    subscriptionStatus: SubscriptionStatus.parse(json['subscription_status']),
    paidUntil: parseApiTime(json['paid_until']),
    payments: [for (final p in asMapList(json['payments'])) PhonePayment.fromJson(p)],
  );
}

enum CardPaymentStatus {
  unfinished,
  unknown,
  success,
  failed;

  static CardPaymentStatus parse(Object? value) => switch (value) {
    'success' => success,
    'failed' => failed,
    'unknown' => unknown,
    _ => unfinished,
  };

  /// Worth asking the server again.
  bool get isPending => this == unfinished || this == unknown;
}

/// `POST /me/billing/topup` with `method: card` — the bank page to open.
class CardTopup {
  const CardTopup({
    required this.cardTransactionId,
    required this.bankOrderId,
    required this.formUrl,
    required this.amount,
    required this.balance,
    required this.subscriptionStatus,
  });

  final int cardTransactionId;
  final String bankOrderId;
  final String formUrl;
  final double amount;
  final double balance;
  final SubscriptionStatus subscriptionStatus;

  factory CardTopup.fromJson(Map<String, dynamic> json) => CardTopup(
    cardTransactionId: parseIntOrNull(json['card_transaction_id']) ?? 0,
    bankOrderId: '${json['bank_order_id'] ?? ''}',
    formUrl: json['form_url'] as String? ?? '',
    amount: parseMoney(json['amount']),
    balance: parseMoney(json['balance']),
    subscriptionStatus: SubscriptionStatus.parse(json['subscription_status']),
  );
}

/// `GET /me/billing/cards/{id}` and `GET /payments/result?orderId=`.
class CardPaymentResult {
  const CardPaymentResult({
    required this.cardTransactionId,
    required this.status,
    required this.amount,
    required this.balance,
    required this.subscriptionStatus,
    this.paidUntil,
    this.bankOrderId,
  });

  final int cardTransactionId;
  final String? bankOrderId;
  final CardPaymentStatus status;
  final double amount;
  final double balance;
  final SubscriptionStatus subscriptionStatus;
  final DateTime? paidUntil;

  factory CardPaymentResult.fromJson(Map<String, dynamic> json) => CardPaymentResult(
    cardTransactionId: parseIntOrNull(json['card_transaction_id']) ?? 0,
    bankOrderId: json['bank_order_id'] as String?,
    status: CardPaymentStatus.parse(json['status']),
    amount: parseMoney(json['amount']),
    balance: parseMoney(json['balance']),
    subscriptionStatus: SubscriptionStatus.parse(json['subscription_status']),
    paidUntil: parseApiTime(json['paid_until']),
  );
}
