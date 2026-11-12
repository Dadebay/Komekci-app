part of '../../../app/komekci_app.dart';

class _PrivacyNote extends StatelessWidget {
  const _PrivacyNote();

  @override
  Widget build(BuildContext context) {
    final language = context.watch<LanguageProvider>().language;
    final tokens = context.appTokens;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 30,
          height: 30,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: tokens.surfaceElevated,
          ),
          child: AppIcon(Icons.lock_outline, color: tokens.accent, size: 15),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Text(
            AppStrings.authYourDataIsStoredSecurely.select(language),
            style: TextStyle(
              color: tokens.textSecondary,
              fontSize: 12,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}
