part of '../../../app/komekci_app.dart';

class _PaymentMethodTile extends StatelessWidget {
  const _PaymentMethodTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
    this.enabled = true,
    this.compact = false,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  /// False greys the tile out and ignores taps (method not available now).
  final bool enabled;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    return Opacity(
      opacity: enabled ? 1 : .45,
      child: GestureDetector(
        onTap: enabled ? onTap : null,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: 14,
            vertical: compact ? 10 : 14,
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
              Container(
                width: compact ? 36 : 42,
                height: compact ? 36 : 42,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: tokens.border),
                ),
                child: AppIcon(
                  icon,
                  color: tokens.textPrimary,
                  size: compact ? 18 : 20,
                ),
              ),
              SizedBox(width: compact ? 10 : 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: compact ? 14 : 14.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: compact ? 1 : 3),
                    Text(
                      subtitle,
                      maxLines: compact ? 1 : null,
                      overflow: compact ? TextOverflow.ellipsis : null,
                      style: TextStyle(
                        color: tokens.textSecondary,
                        fontSize: compact ? 11.5 : 12,
                      ),
                    ),
                  ],
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
  }
}

/// How a top-up attempt ended, as reported by the payment system.
enum _PaymentOutcome { success, pending, failed }

/// Success/pending/failed screen shown inside a payment dialog after the
/// user confirms. Pending and failed both offer a retry, per the same rule.
class _PaymentResultPanel extends StatelessWidget {
  const _PaymentResultPanel({
    required this.outcome,
    required this.amount,
    required this.onContinue,
    required this.onRetry,
  });
  final _PaymentOutcome outcome;
  final String amount;
  final VoidCallback onContinue;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final language = context.watch<LanguageProvider>().language;
    final cur = context.watch<AppSettingsProvider>().currencyLabel(language);
    String t({required String tk, required String ru, required String en}) =>
        pickTr(language, tk: tk, ru: ru, en: en);
    final tokens = context.appTokens;
    final (icon, color, title, message) = switch (outcome) {
      _PaymentOutcome.success => (
        Icons.check_circle_outline,
        tokens.success,
        t(
          tk: 'Töleg üstünlikli!',
          ru: 'Оплата прошла успешно!',
          en: 'Payment successful!',
        ),
        t(
          tk: 'Balansyňyza $amount $cur goşuldy.',
          ru: 'На ваш баланс зачислено $amount $cur.',
          en: '$amount $cur has been added to your balance.',
        ),
      ),
      _PaymentOutcome.pending => (
        Icons.hourglass_top_outlined,
        tokens.warning,
        t(
          tk: 'Töleg garaşylýar',
          ru: 'Платёж в обработке',
          en: 'Payment pending',
        ),
        t(
          tk: 'Tölegiňiz barlanýar, biraz wagt alyp biler.',
          ru: 'Ваш платёж проверяется, это может занять некоторое время.',
          en: 'Your payment is being verified — this may take a moment.',
        ),
      ),
      _PaymentOutcome.failed => (
        Icons.error_outline,
        tokens.danger,
        t(
          tk: 'Töleg başa barmady',
          ru: 'Платёж не прошёл',
          en: 'Payment failed',
        ),
        t(
          tk: 'Tölegi amala aşyryp bolmady.',
          ru: 'Не удалось выполнить платёж.',
          en: 'We couldn’t complete the payment.',
        ),
      ),
    };
    final isSuccess = outcome == _PaymentOutcome.success;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 30, 24, 18),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: .12),
            ),
            child: AppIcon(icon, color: color, size: 30),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: tokens.textSecondary,
              fontSize: 13,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 22),
          MasterActionButton(
            label: isSuccess
                ? t(tk: 'Dowam et', ru: 'Продолжить', en: 'Continue')
                : outcome == _PaymentOutcome.pending
                ? t(
                    tk: 'Täzeden barla',
                    ru: 'Проверить снова',
                    en: 'Check again',
                  )
                : t(tk: 'Täzeden synanyş', ru: 'Повторить', en: 'Try again'),
            enabled: true,
            onTap: isSuccess ? onContinue : onRetry,
          ),
          if (!isSuccess) ...[
            const SizedBox(height: 6),
            _DialogCancelButton(
              label: t(tk: 'Ýapmak', ru: 'Закрыть', en: 'Close'),
            ),
          ],
        ],
      ),
    );
  }
}

/// Billing shows the free-month countdown, but activation is offered only
/// when the master first attempts to add a service.
class _PromoCard extends StatelessWidget {
  const _PromoCard();

  @override
  Widget build(BuildContext context) {
    final language = context.watch<LanguageProvider>().language;
    String t({required String tk, required String ru, required String en}) =>
        pickTr(language, tk: tk, ru: ru, en: en);
    final promo = context.watch<BillingProvider>().promo;
    if (promo == null) return const SizedBox.shrink();

    if (promo.active) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: _InfoBanner(
          icon: Icons.card_giftcard_outlined,
          text: t(
            tk: 'Mugt aý işjeň: ${promo.daysLeft} gün galdy. Soň abuna üçin balansyňyzy dolduryň.',
            ru: 'Бесплатный месяц активен: осталось ${promo.daysLeft} дн. Затем пополните баланс для подписки.',
            en: 'Free month is active: ${promo.daysLeft} days left. Afterwards top up your balance to continue.',
          ),
        ),
      );
    }
    if (promo.needsTopup) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: _InfoBanner(
          icon: Icons.info_outline,
          text: t(
            tk: 'Mugt aý gutardy. Onlaýn ýazgylary dowam etmek üçin balansyňyzy dolduryň.',
            ru: 'Бесплатный месяц закончился. Пополните баланс, чтобы продолжить онлайн-запись.',
            en: 'Your free month has ended. Top up your balance to keep online booking open.',
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }
}
