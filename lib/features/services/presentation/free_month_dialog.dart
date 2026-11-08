part of '../../../app/komekci_app.dart';

/// Offer dialog for the one-month free trial. Resolves to true when the user
/// chooses to activate it.
Future<bool> _showFreeMonthDialog(
  BuildContext context, {
  required String title,
  required String message,
  required List<String> steps,
  required String confirmLabel,
  required String cancelLabel,
}) async {
  final tokens = context.appTokens;
  final result = await showDialog<bool>(
    context: context,
    barrierColor: tokens.scrim,
    builder: (dialogContext) => Dialog(
      backgroundColor: tokens.surface,
      surfaceTintColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 400,
          maxHeight: MediaQuery.sizeOf(dialogContext).height * .9,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                height: 132,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      tokens.accent.withValues(alpha: .28),
                      tokens.accent.withValues(alpha: .08),
                    ],
                  ),
                ),
                child: Container(
                  width: 72,
                  height: 72,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: tokens.accent,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: tokens.accent.withValues(alpha: .35),
                        blurRadius: 22,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.card_giftcard_rounded,
                    color: tokens.accentOn,
                    size: 34,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 22, 24, 22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Semantics(
                      header: true,
                      child: Text(
                        title,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: appFontFamily,
                          color: tokens.textPrimary,
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      message,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: appFontFamily,
                        color: tokens.textSecondary,
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                    if (steps.isNotEmpty) ...[
                      const SizedBox(height: 18),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: tokens.surfaceElevated,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Column(
                          children: [
                            for (var i = 0; i < steps.length; i++)
                              Padding(
                                padding: EdgeInsets.only(top: i == 0 ? 0 : 10),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 24,
                                      height: 24,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: tokens.accent.withValues(
                                          alpha: .16,
                                        ),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Text(
                                        '${i + 1}',
                                        style: TextStyle(
                                          fontFamily: appFontFamily,
                                          color: tokens.accent,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        steps[i],
                                        style: TextStyle(
                                          fontFamily: appFontFamily,
                                          color: tokens.textPrimary,
                                          fontSize: 13.5,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 22),
                    FilledButton(
                      onPressed: () => Navigator.pop(dialogContext, true),
                      style: FilledButton.styleFrom(
                        backgroundColor: tokens.accent,
                        foregroundColor: tokens.accentOn,
                        minimumSize: const Size.fromHeight(54),
                        shape: const StadiumBorder(),
                        textStyle: const TextStyle(
                          fontFamily: appFontFamily,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      child: Text(confirmLabel),
                    ),
                    const SizedBox(height: 4),
                    TextButton(
                      onPressed: () => Navigator.pop(dialogContext, false),
                      style: TextButton.styleFrom(
                        minimumSize: const Size.fromHeight(46),
                        foregroundColor: tokens.textSecondary,
                        textStyle: const TextStyle(
                          fontFamily: appFontFamily,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      child: Text(cancelLabel),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
  return result ?? false;
}
