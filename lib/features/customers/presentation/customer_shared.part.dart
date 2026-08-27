part of '../../../app/komekci_app.dart';


Color _statusColor(CustomerStatus status) => switch (status) {
  CustomerStatus.vip => const Color(0xff9C6B14),
  CustomerStatus.regular => const Color(0xff2F7D4F),
  CustomerStatus.newClient => const Color(0xff2A5DB0),
};

Color _statusBg(CustomerStatus status) => switch (status) {
  CustomerStatus.vip => const Color(0xffFBF1D8),
  CustomerStatus.regular => const Color(0xffE3F3E7),
  CustomerStatus.newClient => const Color(0xffE6EEFB),
};

IconData _statusIcon(CustomerStatus status) => switch (status) {
  CustomerStatus.vip => Icons.emoji_events_outlined,
  CustomerStatus.regular => Icons.star_border,
  CustomerStatus.newClient => Icons.person_add_alt_1,
};

String _statusLabel(CustomerStatus status, bool tk) => switch (status) {
  CustomerStatus.vip => 'VIP',
  CustomerStatus.regular => tk ? 'Hemişelik' : 'Постоянный',
  CustomerStatus.newClient => tk ? 'Täze' : 'Новый',
};

/// Shared "are you sure" dialog: icon badge, centred copy, a cancel outline
/// button and a filled confirm button. Used for every destructive or
/// meaningful confirmation across the app instead of a bare [AlertDialog].
Future<bool> _showConfirmDialog(
  BuildContext context, {
  required IconData icon,
  required String title,
  required String message,
  required String confirmLabel,
  required String cancelLabel,
  bool danger = false,
}) async {
  final tokens = context.appTokens;
  final result = await showDialog<bool>(
    context: context,
    barrierColor: tokens.scrim,
    builder: (dialogContext) => Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 30),
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
        decoration: BoxDecoration(
          color: tokens.surfaceElevated,
          borderRadius: BorderRadius.circular(26),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: danger
                    ? const Color(0xffFDF0EE)
                    : const Color(0xffFBF1D8),
                shape: BoxShape.circle,
              ),
              child: AppIcon(
                icon,
                size: 25,
                color: danger ? tokens.danger : tokens.accent,
              ),
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
                fontSize: 13.5,
                color: tokens.textSecondary,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 22),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: tokens.border),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      onPressed: () => Navigator.pop(dialogContext, false),
                      child: Text(
                        cancelLabel,
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                          color: tokens.textPrimary,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: danger
                            ? tokens.danger
                            : tokens.textPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      onPressed: () => Navigator.pop(dialogContext, true),
                      child: Text(
                        confirmLabel,
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: danger ? Colors.white : tokens.surface,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
  return result ?? false;
}

/// Shared single-action info dialog (success / done states) matching
/// [_showConfirmDialog]'s look.
Future<void> _showInfoDialog(
  BuildContext context, {
  required IconData icon,
  required String title,
  required String message,
  required String actionLabel,
}) {
  final tokens = context.appTokens;
  return showDialog<void>(
    context: context,
    barrierColor: tokens.scrim,
    builder: (dialogContext) => Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 30),
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
        decoration: BoxDecoration(
          color: tokens.surfaceElevated,
          borderRadius: BorderRadius.circular(26),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: Color(0xffDCF3E3),
                shape: BoxShape.circle,
              ),
              child: AppIcon(icon, size: 25, color: const Color(0xff1F8A4C)),
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
                fontSize: 13.5,
                color: tokens.textSecondary,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: tokens.textPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                onPressed: () => Navigator.pop(dialogContext),
                child: Text(
                  actionLabel,
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: tokens.surface,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

/// Shows the customer's picked photo when set, otherwise the generic
/// person-outline placeholder used across the app.
class _CustomerAvatar extends StatelessWidget {
  const _CustomerAvatar({required this.customer, this.radius = 24});
  final Customer customer;
  final double radius;

  @override
  Widget build(BuildContext context) => CircleAvatar(
    radius: radius,
    backgroundColor: const Color(0xffE6D2B1),
    backgroundImage: customer.photoPath.isEmpty
        ? null
        : FileImage(File(customer.photoPath)),
    child: customer.photoPath.isEmpty
        ? AppIcon(
            Icons.person_outline,
            size: radius * .75,
            color: context.appTokens.textPrimary,
          )
        : null,
  );
}

