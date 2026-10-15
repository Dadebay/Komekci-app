part of '../../../app/komekci_app.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final language = context.watch<LanguageProvider>().language;
    String t({required String tk, required String ru, required String en}) =>
        pickTr(language, tk: tk, ru: ru, en: en);
    final tokens = context.appTokens;
    final dark = tokens.brightness == Brightness.dark;
    final supportContact = context.watch<AppSettingsProvider>().supportContact;
    final contact = context.watch<AppSettingsProvider>().contact;
    final contactRows = _configuredContactRows(context, contact);
    final hasContact = supportContact.isNotEmpty || contactRows.isNotEmpty;
    final faq = switch (language) {
      AppLanguage.tk => [
        (
          'Abunany nädip tölemeli?',
          'Kabinet → Töleg bölüminden balansyňyzy dolduryp bilersiňiz.',
        ),
        ('Hyzmat nädip goşulýar?', 'Kabinet → Hyzmatlar → Täze hyzmat goş.'),
        (
          'Iş wagtymy üýtgedip bilerinmi?',
          'Hawa, Kabinet → Iş wagty bölüminden islendik wagt.',
        ),
      ],
      AppLanguage.ru => [
        ('Как оплатить подписку?', 'Кабинет → Оплата, пополните баланс.'),
        ('Как добавить услугу?', 'Кабинет → Услуги → Добавить услугу.'),
        ('Можно ли менять график?', 'Да, в разделе Кабинет → График работы.'),
      ],
      AppLanguage.en => [
        (
          'How do I pay for my subscription?',
          'Cabinet → Billing, top up your balance there.',
        ),
        ('How do I add a service?', 'Cabinet → Services → Add service.'),
        (
          'Can I change my working hours?',
          'Yes, any time from Cabinet → Working hours.',
        ),
      ],
    };
    return Scaffold(
      backgroundColor: tokens.surface,
      appBar: CabinetAppBar(
        title: t(tk: 'Kömek', ru: 'Помощь', en: 'Help'),
      ),
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
                    t(
                      tk: 'Size nädip kömek edip bileris?',
                      ru: 'Чем мы можем помочь?',
                      en: 'How can we help?',
                    ),
                    style: TextStyle(
                      color: dark ? tokens.textPrimary : tokens.surface,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      height: 1.15,
                    ),
                  ),
                  const SizedBox(height: 9),
                  Text(
                    t(
                      tk: 'Soragyňyza jogap tapyň ýa-da elýeterli usul bilen bize ýüz tutuň.',
                      ru: 'Найдите ответ на вопрос или свяжитесь с нами удобным способом.',
                      en: 'Find an answer or reach us using an available contact method.',
                    ),
                    style: TextStyle(
                      color: dark ? tokens.textSecondary : tokens.surface.withValues(alpha: .72),
                      fontSize: 13,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            Text(
              t(
                tk: 'Bize habarlaşyň',
                ru: 'Свяжитесь с нами',
                en: 'Get in touch',
              ),
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
                title: t(
                  tk: 'Goldaw bilen habarlaş',
                  ru: 'Связаться с поддержкой',
                  en: 'Contact support',
                ),
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
                        t(
                          tk: 'Aragatnaşyk maglumatlary häzir elýeterli däl.',
                          ru: 'Контактные данные сейчас недоступны.',
                          en: 'Contact details are not available right now.',
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
              t(
                tk: 'Köp soralýan soraglar',
                ru: 'Частые вопросы',
                en: 'Frequently asked questions',
              ),
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
              title: t(tk: 'Biz barada', ru: 'О нас', en: 'About us'),
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
