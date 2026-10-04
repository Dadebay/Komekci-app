part of '../../../app/komekci_app.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final language = context.watch<LanguageProvider>().language;
    String t({required String tk, required String ru, required String en}) =>
        pickTr(language, tk: tk, ru: ru, en: en);
    final tokens = context.appTokens;
    final supportContact = context.watch<AppSettingsProvider>().supportContact;
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
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            ...faq.map(
              (item) => Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: tokens.surfaceElevated,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _softLine(tokens)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.$1,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      item.$2,
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: Colors.black54,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            _MasterActionButton(
              label: t(
                tk: 'Goldaw bilen habarlaş',
                ru: 'Связаться с поддержкой',
                en: 'Contact support',
              ),
              enabled: supportContact.isNotEmpty,
              leading: Icons.chat_bubble_outline,
              onTap: () => _openSupportContact(supportContact),
            ),
          ],
        ),
      ),
    );
  }
}
