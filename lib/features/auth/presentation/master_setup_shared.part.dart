part of '../../../app/komekci_app.dart';


/// Master onboarding runs in four steps: 1. phone number, 2. SMS code,
/// 3. profile details, 4. subscription payment.
const _masterSetupSteps = 4;

/// Balance top-ups are sent as an SMS to the operator short code. The message
/// body carries the account number and the chosen amount: "+99362990344 30".
const _topUpShortCode = '0804';
const _topUpAccount = '+99362990344';
const _topUpAmounts = [20, 30, 40, 50];
const _monthlyFee = 20;


/// Sits under the confirm button in payment dialogs, replacing a back arrow.
class _DialogCancelButton extends StatelessWidget {
  const _DialogCancelButton({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: TextButton(
        onPressed: () => Navigator.pop(context),
        style: TextButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: tokens.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _MasterActionButton extends StatelessWidget {
  const _MasterActionButton({
    required this.label,
    required this.enabled,
    required this.onTap,
    this.trailingArrow = false,
    this.leading,
  });
  final String label;
  final bool enabled;
  final VoidCallback onTap;
  final bool trailingArrow;
  final IconData? leading;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: FilledButton(
        style: FilledButton.styleFrom(
          backgroundColor: enabled
              ? tokens.textPrimary
              : tokens.surfaceElevated,
          foregroundColor: enabled ? tokens.surface : tokens.disabled,
          disabledBackgroundColor: tokens.surfaceElevated,
          disabledForegroundColor: tokens.disabled,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        onPressed: enabled ? onTap : null,
        child: Row(
          mainAxisAlignment: trailingArrow
              ? MainAxisAlignment.spaceBetween
              : MainAxisAlignment.center,
          children: [
            if (trailingArrow) const SizedBox(width: 20),
            if (leading != null) ...[
              AppIcon(
                leading!,
                color: enabled ? tokens.surface : tokens.disabled,
                size: 19,
              ),
              const SizedBox(width: 10),
            ],
            Flexible(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (trailingArrow) const AppIcon(Icons.chevron_right, size: 20),
          ],
        ),
      ),
    );
  }
}

class _MasterSetupHeader extends StatelessWidget
    implements PreferredSizeWidget {
  const _MasterSetupHeader({required this.title});
  final String title;

  @override
  Size get preferredSize => const Size.fromHeight(44);

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    return AppBar(
      toolbarHeight: 44,
      backgroundColor: tokens.surface,
      surfaceTintColor: tokens.surface,
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        onPressed: () => Navigator.maybePop(context),
        icon: AppIcon(Icons.arrow_back, color: tokens.textPrimary),
      ),
      title: Text(
        title,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _MasterProgressIndicator extends StatelessWidget {
  const _MasterProgressIndicator({required this.step});
  final int step;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    return SizedBox(
      height: 24,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            left: 12,
            right: 12,
            child: Row(
              children: List.generate(
                _masterSetupSteps - 1,
                (index) => Expanded(
                  child: Container(
                    height: 1.5,
                    color: index < step - 1
                        ? tokens.textPrimary
                        : tokens.border,
                  ),
                ),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(_masterSetupSteps, (index) {
              final current = index + 1 == step;
              final completed = index + 1 < step;
              return Container(
                width: 24,
                height: 24,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: current || completed
                      ? tokens.textPrimary
                      : tokens.surface,
                  border: Border.all(
                    color: current || completed
                        ? tokens.textPrimary
                        : tokens.border,
                  ),
                ),
                child: completed
                    ? AppIcon(Icons.check, color: tokens.surface, size: 13)
                    : null,
              );
            }),
          ),
        ],
      ),
    );
  }
}
