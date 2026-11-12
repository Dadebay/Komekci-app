part of '../../../app/komekci_app.dart';

class _NotesList extends StatelessWidget {
  const _NotesList({required this.notes, required this.heading});
  final List<(IconData, String, String)> notes;
  final String heading;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    return Column(
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
              heading,
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
        for (final note in notes)
          Padding(
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
                  child: AppIcon(note.$1, color: tokens.textPrimary, size: 19),
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
      ],
    );
  }
}

/// Where to send the money, plus a live status line while waiting.
class _TransferInstructions extends StatelessWidget {
  const _TransferInstructions({
    required this.topup,
    required this.amount,
    required this.cur,
    required this.onResendSms,
    this.pendingMessage,
  });
  final MobileTopup topup;
  final int amount;
  final String cur;
  final String? pendingMessage;
  final VoidCallback onResendSms;

  @override
  Widget build(BuildContext context) {
    final language = context.watch<LanguageProvider>().language;
    final tokens = context.appTokens;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.authNumberToSendTo.select(language),
          style: TextStyle(color: tokens.textSecondary, fontSize: 12.5),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: tokens.border),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  displayPhone(topup.phone),
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                    letterSpacing: .4,
                  ),
                ),
              ),
              IconButton(
                tooltip: AppStrings.authCopy.select(language),
                icon: AppIcon(
                  Icons.copy_outlined,
                  color: tokens.accent,
                  size: 19,
                ),
                onPressed: () async {
                  await Clipboard.setData(ClipboardData(text: topup.phone));
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        AppStrings.authCopied.select(language),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Text(
          AppStrings.authSendToThisNumberIn(amount, cur, formatMoney(topup.phoneMinAmount), _topUpShortCode).select(language),
          style: TextStyle(
            color: tokens.textSecondary,
            fontSize: 12.5,
            height: 1.45,
          ),
        ),
        const SizedBox(height: 6),
        TextButton.icon(
          onPressed: onResendSms,
          icon: AppIcon(Icons.sms_outlined, size: 17, color: tokens.accent),
          label: Text(
            AppStrings.authOpenTheSmsAgain.select(language),
          ),
        ),
        if (pendingMessage != null) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: tokens.warning.withValues(alpha: .12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              pendingMessage!,
              style: const TextStyle(fontSize: 12.5, height: 1.4),
            ),
          ),
        ] else ...[
          const SizedBox(height: 8),
          Row(
            children: [
              const SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  AppStrings.authWaitingForYourTransferThis.select(language),
                  style: TextStyle(color: tokens.textSecondary, fontSize: 12.5),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
