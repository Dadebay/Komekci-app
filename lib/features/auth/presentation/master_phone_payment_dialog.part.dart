part of '../../../app/komekci_app.dart';

/// Rules the operator applies to balance top-ups, shown before the SMS is sent.
class _PhonePaymentDialog extends StatefulWidget {
  const _PhonePaymentDialog({required this.amount});
  final int amount;

  @override
  State<_PhonePaymentDialog> createState() => _PhonePaymentDialogState();
}

class _PhonePaymentDialogState extends State<_PhonePaymentDialog> {
  _PaymentOutcome? _outcome;

  Future<void> _confirm() async {
    final billing = context.read<BillingProvider>();
    final body = Uri.encodeComponent('$_topUpAccount ${widget.amount}');
    final launched = await launchUrl(
      Uri.parse('sms:$_topUpShortCode?body=$body'),
    );
    if (!mounted) return;
    if (!launched) {
      setState(() => _outcome = _PaymentOutcome.failed);
      return;
    }
    final succeeded = _rollPaymentSucceeded();
    billing.topUp(widget.amount, success: succeeded);
    setState(
      () => _outcome = succeeded
          ? _PaymentOutcome.success
          : _PaymentOutcome.pending,
    );
  }

  void _finish() {
    Navigator.of(context).pop();
    Navigator.of(
      context,
    ).pushAndRemoveUntil(pageRoute(const MasterHome()), (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    if (_outcome != null) {
      return Dialog(
        backgroundColor: context.appTokens.surface,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 36),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        child: _PaymentResultPanel(
          outcome: _outcome!,
          amount: widget.amount,
          onContinue: _finish,
          onRetry: _confirm,
        ),
      );
    }
    final amount = widget.amount;
    final language = context.watch<LanguageProvider>().language;
    String t({required String tk, required String ru, required String en}) =>
        pickTr(language, tk: tk, ru: ru, en: en);
    final tokens = context.appTokens;
    final notes = switch (language) {
      AppLanguage.tk => [
        (
          Icons.savings_outlined,
          'Iň az möçber',
          'Bir gezekde iň az $_monthlyFee manat doldurylýar.',
        ),
        (
          Icons.atm_outlined,
          'Bankomat we terminal',
          'Bankomat ýa-da terminal arkaly töleg kabul edilmeýär.',
        ),
        (
          Icons.smartphone_outlined,
          'Töleg programmasy',
          'Töleg programmasy arkaly kabul edilmeýär.',
        ),
        (
          Icons.chat_bubble_outline,
          'Soraglaryňyz barmy?',
          'Habarlaşmak bölüminden bize ýazyp bilersiňiz.',
        ),
      ],
      AppLanguage.ru => [
        (
          Icons.savings_outlined,
          'Минимальная сумма',
          'За один раз пополняется минимум $_monthlyFee манат.',
        ),
        (
          Icons.atm_outlined,
          'Банкомат и терминал',
          'Оплата через банкомат или терминал не принимается.',
        ),
        (
          Icons.smartphone_outlined,
          'Платёжное приложение',
          'Оплата через платёжное приложение не принимается.',
        ),
        (
          Icons.chat_bubble_outline,
          'Есть вопросы?',
          'Напишите нам в разделе поддержки.',
        ),
      ],
      AppLanguage.en => [
        (
          Icons.savings_outlined,
          'Minimum amount',
          'A minimum of $_monthlyFee TMT is topped up at a time.',
        ),
        (
          Icons.atm_outlined,
          'ATM and terminal',
          'Payment via ATM or terminal is not accepted.',
        ),
        (
          Icons.smartphone_outlined,
          'Payment app',
          'Payment via a payment app is not accepted.',
        ),
        (
          Icons.chat_bubble_outline,
          'Have questions?',
          'You can reach us through the support section.',
        ),
      ],
    };
    return Dialog(
      backgroundColor: tokens.surface,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 36),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Cream header carrying the amount that is about to be sent.
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 22),
            decoration: BoxDecoration(
              color: tokens.surfaceElevated,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: Column(
              children: [
                Container(
                  width: 58,
                  height: 58,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: tokens.surface,
                    border: Border.all(
                      color: tokens.accent.withValues(alpha: .35),
                    ),
                  ),
                  child: AppIcon(
                    Icons.smartphone_outlined,
                    color: tokens.accent,
                    size: 26,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  t(
                    tk: 'Telefon arkaly töleg',
                    ru: 'Оплата с телефона',
                    en: 'Pay by phone',
                  ),
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  t(
                    tk: 'SIM kartyňyzyň balansyndan $amount manat tutulýar.',
                    ru: 'С баланса SIM-карты спишется $amount манат.',
                    en: '$amount TMT will be deducted from your SIM card balance.',
                  ),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: tokens.textSecondary,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      AppIcon(
                        Icons.warning_amber_rounded,
                        color: tokens.accent,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        t(tk: 'ÜNS BERIŇ', ru: 'ВНИМАНИЕ', en: 'NOTE'),
                        style: TextStyle(
                          fontSize: 12.5,
                          letterSpacing: .8,
                          fontWeight: FontWeight.w700,
                          color: tokens.accent,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  ...notes.map(
                    (note) => Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(13),
                              color: tokens.surfaceElevated,
                            ),
                            child: AppIcon(
                              note.$1,
                              color: tokens.textPrimary,
                              size: 19,
                            ),
                          ),
                          const SizedBox(width: 13),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  note.$2,
                                  style: const TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  note.$3,
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    color: tokens.textSecondary,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 6, 20, 14),
            child: Column(
              children: [
                _MasterActionButton(
                  label: t(
                    tk: 'Tölegi tassykla',
                    ru: 'Подтвердить оплату',
                    en: 'Confirm payment',
                  ),
                  enabled: true,
                  trailingArrow: true,
                  onTap: _confirm,
                ),
                const SizedBox(height: 6),
                _DialogCancelButton(
                  label: t(tk: 'Ýatyr', ru: 'Отмена', en: 'Cancel'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
