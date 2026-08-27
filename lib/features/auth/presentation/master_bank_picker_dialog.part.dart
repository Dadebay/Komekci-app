part of '../../../app/komekci_app.dart';

class _BankPickerDialog extends StatefulWidget {
  const _BankPickerDialog({required this.amount});
  final int amount;

  @override
  State<_BankPickerDialog> createState() => _BankPickerDialogState();
}

class _BankPickerDialogState extends State<_BankPickerDialog> {
  static const _banks = [
    ('assets/images/banks/halk.webp', 'Halkbank'),
    ('assets/images/banks/rysgal.webp', 'Rysgal bank'),
    ('assets/images/banks/senagat.webp', 'Senagat bank'),
  ];
  int? _selected;
  _PaymentOutcome? _outcome;

  void _confirm() {
    final succeeded = _rollPaymentSucceeded();
    context.read<BillingProvider>().topUp(widget.amount, success: succeeded);
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
    final tokens = context.appTokens;
    if (_outcome != null) {
      return Dialog(
        backgroundColor: tokens.surface,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: _PaymentResultPanel(
          outcome: _outcome!,
          amount: widget.amount,
          onContinue: _finish,
          onRetry: () => setState(() => _outcome = null),
        ),
      );
    }
    final language = context.watch<LanguageProvider>().language;
    String t({required String tk, required String ru, required String en}) =>
        pickTr(language, tk: tk, ru: ru, en: en);
    return Dialog(
      backgroundColor: tokens.surface,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              t(tk: 'Banky saýlaň', ru: 'Выберите банк', en: 'Choose a bank'),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              t(
                tk: '${widget.amount} manat tölegi geçirjek bankyňyzy saýlaň.',
                ru: 'Выберите банк для оплаты ${widget.amount} манат.',
                en: 'Choose which bank to pay ${widget.amount} TMT through.',
              ),
              textAlign: TextAlign.center,
              style: TextStyle(color: tokens.textSecondary, fontSize: 12.5),
            ),
            const SizedBox(height: 18),
            ...List.generate(_banks.length, (index) {
              final selected = _selected == index;
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: GestureDetector(
                  onTap: () => setState(() => _selected = index),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: selected ? tokens.surfaceElevated : tokens.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: selected ? tokens.accent : tokens.border,
                        width: selected ? 1.6 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.asset(
                            _banks[index].$1,
                            width: 46,
                            height: 46,
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            _banks[index].$2,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Container(
                          width: 22,
                          height: 22,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: selected ? tokens.accent : tokens.border,
                              width: 1.6,
                            ),
                          ),
                          child: selected
                              ? Container(
                                  width: 11,
                                  height: 11,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: tokens.accent,
                                  ),
                                )
                              : null,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
            const SizedBox(height: 8),
            _MasterActionButton(
              label: t(
                tk: 'Tölegi tassykla',
                ru: 'Подтвердить оплату',
                en: 'Confirm payment',
              ),
              enabled: _selected != null,
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
    );
  }
}

