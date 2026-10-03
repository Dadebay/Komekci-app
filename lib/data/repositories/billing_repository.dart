import '../../core/network/api_client.dart';
import '../models/api/billing_models.dart';
import '../models/api/json_helpers.dart';

/// `/me/billing/*` and the public `/payments/result`.
class BillingRepository {
  BillingRepository(this._api);
  final ApiClient _api;

  Future<Billing> billing() async =>
      Billing.fromJson(asMap(unwrapData(await _api.get('/me/billing'))));

  Future<ApiPage<LedgerTransaction>> transactions({String? cursor}) async =>
      ApiPage.fromJson(
        await _api.get('/me/billing/transactions', query: {'cursor': cursor}),
        LedgerTransaction.fromJson,
      );

  /// Starts a phone payment: the server hands back the number to pay.
  /// 404 `PAYMENT_UNAVAILABLE` when no number is free.
  Future<MobileTopup> topUpMobile(num amount) async => MobileTopup.fromJson(
    asMap(await _api.post('/me/billing/topup', json: {'amount': amount, 'method': 'mobile'})),
  );

  /// Starts a card payment: open [CardTopup.formUrl] in a WebView.
  Future<CardTopup> topUpCard(num amount) async => CardTopup.fromJson(
    asMap(await _api.post('/me/billing/topup', json: {'amount': amount, 'method': 'card'})),
  );

  Future<PhonePayments> phonePayments() async =>
      PhonePayments.fromJson(asMap(await _api.get('/me/billing/phone')));

  /// Asks the bank (via the server). Safe to repeat; credits only once.
  Future<CardPaymentResult> cardStatus(int cardTransactionId) async =>
      CardPaymentResult.fromJson(
        asMap(await _api.get('/me/billing/cards/$cardTransactionId')),
      );

  /// Same result by the bank's `orderId`, without a token.
  Future<CardPaymentResult> paymentResult(String orderId) async =>
      CardPaymentResult.fromJson(
        asMap(
          await _api.get('/payments/result', query: {'orderId': orderId}, auth: false),
        ),
      );
}
