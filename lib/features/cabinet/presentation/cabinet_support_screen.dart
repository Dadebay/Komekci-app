part of '../../../app/komekci_app.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final language = context.watch<LanguageProvider>().language;
    final tokens = context.appTokens;
    final dark = tokens.brightness == Brightness.dark;
    final supportContact = context.watch<AppSettingsProvider>().supportContact;
    final contact = context.watch<AppSettingsProvider>().contact;
    final contactRows = _configuredContactRows(context, contact);
    final hasContact = supportContact.isNotEmpty || contactRows.isNotEmpty;
    final faq = [
      for (final item in AppStrings.faq)
        (item.question.select(language), item.answer.select(language)),
    ];
    return Scaffold(
      backgroundColor: tokens.surface,
      appBar: CabinetAppBar(title: AppStrings.profileHelp.select(language)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: dark ? tokens.surfaceElevated : tokens.textPrimary,
                borderRadius: BorderRadius.circular(24),
                border: dark ? Border.all(color: tokens.border) : null,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: tokens.accent.withValues(alpha: .2),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: AppIcon(
                      Icons.support_agent_outlined,
                      color: tokens.accent,
                      size: 25,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    AppStrings.cabinetHowCanWeHelp.select(language),
                    style: TextStyle(
                      color: dark ? tokens.textPrimary : tokens.surface,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      height: 1.15,
                    ),
                  ),
                  const SizedBox(height: 9),
                  Text(
                    AppStrings.cabinetFindAnAnswerOrReach.select(language),
                    style: TextStyle(
                      color: dark
                          ? tokens.textSecondary
                          : tokens.surface.withValues(alpha: .72),
                      fontSize: 13,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            Text(
              AppStrings.profileGetInTouch.select(language),
              style: TextStyle(
                color: tokens.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 12),
            if (supportContact.isNotEmpty)
              _ContactRow(
                icon: Icons.chat_bubble_outline,
                title: AppStrings.cabinetContactSupport.select(language),
                value: supportContact,
                onTap: () => _openSupportContact(supportContact),
              ),
            ...contactRows,
            if (!hasContact)
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: tokens.surfaceElevated,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: _softLine(tokens)),
                ),
                child: Row(
                  children: [
                    AppIcon(Icons.info_outline, color: tokens.accent, size: 22),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        AppStrings.cabinetContactDetailsAreNotAvailable.select(
                          language,
                        ),
                        style: TextStyle(
                          color: tokens.textSecondary,
                          fontSize: 13,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 28),
            Text(
              AppStrings.cabinetFrequentlyAskedQuestions.select(language),
              style: TextStyle(
                color: tokens.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 12),
            ...faq.map((item) => _FaqTile(question: item.$1, answer: item.$2)),
            const SizedBox(height: 18),
            _ContactRow(
              icon: Icons.info_outline,
              title: AppStrings.profileAboutUs.select(language),
              value: '',
              onTap: () =>
                  Navigator.push(context, pageRoute(const AboutScreen())),
            ),
          ],
        ),
      ),
    );
  }
}
