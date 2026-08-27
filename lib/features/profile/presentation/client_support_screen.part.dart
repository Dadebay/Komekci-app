part of '../../../app/komekci_app.dart';

const _supportPhone = '+993 12 345678';
const _supportTelegram = 'https://t.me/komekci_support';
const _supportEmail = 'support@komekci.app';

/// Real support content — an FAQ accordion plus tappable contact rows —
/// replacing the old generic `SettingsScreen` stub that had no actual
/// answers or contact info.
class ClientSupportScreen extends StatelessWidget {
  const ClientSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final language = context.watch<LanguageProvider>().language;
    String t({required String tk, required String ru, required String en}) =>
        pickTr(language, tk: tk, ru: ru, en: en);
    final tokens = context.appTokens;

    final faqs = <(String, String)>[
      (
        t(
          tk: 'Duşuşygy nädip ýatyryp bolar?',
          ru: 'Как отменить запись?',
          en: 'How do I cancel a booking?',
        ),
        t(
          tk: '"Duşuşyklar" bölüminden degişli duşuşygy açyň we "Ýatyr" düwmesine basyň. Duşuşykdan azyndan 2 sagat öň ýatyrsaňyz, töleg alynmaýar.',
          ru: 'Откройте нужную запись во вкладке «Записи» и нажмите «Отменить». Если отменить не позднее чем за 2 часа до визита, плата не взимается.',
          en: 'Open the booking under the "Bookings" tab and tap "Cancel". Cancelling at least 2 hours before the appointment is free of charge.',
        ),
      ),
      (
        t(
          tk: 'Halanan ussalarym nirede saklanýar?',
          ru: 'Где хранятся мои избранные мастера?',
          en: 'Where are my favourite masters saved?',
        ),
        t(
          tk: 'Aşaky menýudaky ýürek nyşanyna basyp, halanlaryňyzy islendik wagt görüp bilersiňiz. Ussanyň profilindäki ýürek belligi bilen goşup/aýryp bolýar.',
          ru: 'Нажмите на значок сердца в нижнем меню, чтобы увидеть избранное в любое время. Добавляйте и убирайте мастеров сердцем на странице их профиля.',
          en: 'Tap the heart icon in the bottom menu to see your favourites anytime. Add or remove a master with the heart on their profile page.',
        ),
      ),
      (
        t(
          tk: 'Töleg nädip amala aşyrylýar?',
          ru: 'Как происходит оплата?',
          en: 'How does payment work?',
        ),
        t(
          tk: 'Häzirki wagtda tölegler salon ýerinde nagt ýa-da kart bilen alynýar. Programmanyň içinden onlaýn töleg ýakynda goşular.',
          ru: 'Сейчас оплата принимается наличными или картой прямо в салоне. Онлайн-оплата в приложении появится позже.',
          en: 'Payments are currently taken in person at the salon, by cash or card. In-app online payment is coming soon.',
        ),
      ),
      (
        t(
          tk: 'Telefon belgimi üýtgedip bolarmy?',
          ru: 'Можно ли изменить номер телефона?',
          en: 'Can I change my phone number?',
        ),
        t(
          tk: '"Profil" bölüminden adyňyzy we belgiňizi redaktläp bilersiňiz. Uly üýtgeşmeler üçin goldaw gullugy bilen habarlaşyň.',
          ru: 'Вы можете изменить имя и номер в разделе «Профиль». Для более сложных случаев свяжитесь со службой поддержки.',
          en: 'You can edit your name and number from the "Profile" tab. For anything more complex, contact support below.',
        ),
      ),
    ];

    return Scaffold(
      backgroundColor: tokens.surface,
      appBar: CabinetAppBar(
        title: t(tk: 'Goldaw', ru: 'Поддержка', en: 'Support'),
      ),
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            Text(
              t(
                tk: 'Ýygy-ýygydan soralýan soraglar',
                ru: 'Частые вопросы',
                en: 'Frequently asked questions',
              ),
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
            ...faqs.map((faq) => _FaqTile(question: faq.$1, answer: faq.$2)),
            const SizedBox(height: 22),
            Text(
              t(tk: 'Bize habarlaşyň', ru: 'Свяжитесь с нами', en: 'Get in touch'),
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
            _ContactRow(
              icon: Icons.phone_outlined,
              title: t(tk: 'Jaň ediň', ru: 'Позвонить', en: 'Call us'),
              value: _supportPhone,
              onTap: () => launchUrl(
                Uri(scheme: 'tel', path: _supportPhone.replaceAll(' ', '')),
              ),
            ),
            _ContactRow(
              icon: Icons.send_outlined,
              title: 'Telegram',
              value: '@komekci_support',
              onTap: () => launchUrl(
                Uri.parse(_supportTelegram),
                mode: LaunchMode.externalApplication,
              ),
            ),
            _ContactRow(
              icon: Icons.chat_bubble_outline,
              title: t(tk: 'E-poçta', ru: 'Эл. почта', en: 'Email'),
              value: _supportEmail,
              onTap: () => launchUrl(Uri(scheme: 'mailto', path: _supportEmail)),
            ),
          ],
        ),
      ),
    );
  }
}

class _FaqTile extends StatelessWidget {
  const _FaqTile({required this.question, required this.answer});
  final String question;
  final String answer;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: tokens.surfaceElevated,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: tokens.border),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 14),
          childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
          iconColor: tokens.accent,
          collapsedIconColor: tokens.textSecondary,
          title: Text(
            question,
            style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600),
          ),
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                answer,
                style: TextStyle(
                  fontSize: 12.5,
                  color: tokens.textSecondary,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ContactRow extends StatelessWidget {
  const _ContactRow({
    required this.icon,
    required this.title,
    required this.value,
    required this.onTap,
  });
  final IconData icon;
  final String title;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: tokens.surfaceElevated,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: tokens.border),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: tokens.accent.withValues(alpha: .12),
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: AppIcon(icon, color: tokens.accent, size: 17),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        value,
                        style: TextStyle(
                          fontSize: 11.5,
                          color: tokens.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                AppIcon(Icons.arrow_outward, size: 15, color: tokens.disabled),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
