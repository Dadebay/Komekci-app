part of '../../../app/komekci_app.dart';

class _SubscriptionNotice extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final billing = context.watch<BillingProvider>();
    if (!billing.loaded || billing.status == SubscriptionStatus.active) {
      return const SizedBox.shrink();
    }
    final language = context.watch<LanguageProvider>().language;
    final tokens = context.appTokens;
    final suspended = billing.status == SubscriptionStatus.suspended;
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: GestureDetector(
        onTap: () => Navigator.push(context, pageRoute(const BillingScreen())),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: (suspended ? tokens.danger : tokens.warning).withValues(alpha: .1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              AppIcon(Icons.info_outline, color: suspended ? tokens.danger : tokens.warning, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  suspended
                      ? pickTr(
                          language,
                          tk: 'Abuna işjeň däl: täze ýazgylar ýapyk. Açmak üçin balansy dolduryň.',
                          ru: 'Подписка не активна: новые записи закрыты. Пополните баланс, чтобы открыть.',
                          en: 'Subscription is not active: new bookings are closed. Top up to reopen.',
                        )
                      : pickTr(
                          language,
                          tk: 'Tölegiň wagty ýakynlaşdy. Balansy dolduryň.',
                          ru: 'Скоро нужно оплатить подписку. Пополните баланс.',
                          en: 'Your subscription payment is due soon. Please top up.',
                        ),
                  style: const TextStyle(fontSize: 12.5, height: 1.4),
                ),
              ),
              const AppIcon(Icons.chevron_right, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}
