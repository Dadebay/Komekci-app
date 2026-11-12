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
    final tokens = context.appTokens;
    final (icon, color, title, message) = switch (outcome) {
      _PaymentOutcome.success => (
        Icons.check_circle_outline,
        tokens.success,
        AppStrings.authPaymentSuccessful.select(language),
        AppStrings.authHasBeenAddedToYour(amount, cur).select(language),
      ),
      _PaymentOutcome.pending => (
        Icons.hourglass_top_outlined,
        tokens.warning,
        AppStrings.authPaymentPending.select(language),
        AppStrings.authYourPaymentIsBeingVerified.select(language),
      ),
      _PaymentOutcome.failed => (
        Icons.error_outline,
        tokens.danger,
        AppStrings.authPaymentFailed.select(language),
        AppStrings.authWeCouldnTCompleteThe.select(language),
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
                ? AppStrings.onboardingContinue.select(language)
                : outcome == _PaymentOutcome.pending
                ? AppStrings.authCheckAgain.select(language)
                : AppStrings.profileTryAgain.select(language),
            enabled: true,
            onTap: isSuccess ? onContinue : onRetry,
          ),
          if (!isSuccess) ...[
            const SizedBox(height: 6),
            _DialogCancelButton(
              label: AppStrings.authClose.select(language),
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
    final promo = context.watch<BillingProvider>().promo;
    if (promo == null) return const SizedBox.shrink();

    if (promo.active) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: _InfoBanner(
          icon: Icons.card_giftcard_outlined,
          text: AppStrings.authFreeMonthIsActiveDays(promo.daysLeft).select(language),
        ),
      );
    }
    if (promo.needsTopup) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: _InfoBanner(
          icon: Icons.info_outline,
          text: AppStrings.authYourFreeMonthHasEnded.select(language),
        ),
      );
    }
    return const SizedBox.shrink();
  }
}
