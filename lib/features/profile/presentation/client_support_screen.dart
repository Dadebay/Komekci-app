part of '../../../app/komekci_app.dart';

/// Opens the support contact configured on the server
/// (`support_contact` of `GET /settings/public`): a link, an e-mail address
/// or a phone number.
Future<void> _openSupportContact(String contact) {
  final value = contact.trim();
  if (value.startsWith('http://') || value.startsWith('https://')) {
    return launchUrl(Uri.parse(value), mode: LaunchMode.externalApplication);
  }
  if (value.startsWith('t.me/')) {
    return launchUrl(
      Uri.parse('https://$value'),
      mode: LaunchMode.externalApplication,
    );
  }
  if (value.contains('@') && !value.startsWith('@') && !value.contains(' ')) {
    return launchUrl(Uri(scheme: 'mailto', path: value));
  }
  if (value.startsWith('@')) {
    return launchUrl(
      Uri.parse('https://t.me/${value.substring(1)}'),
      mode: LaunchMode.externalApplication,
    );
  }
  return launchUrl(Uri(scheme: 'tel', path: value.replaceAll(' ', '')));
}

List<Widget> _configuredContactRows(BuildContext context, AppContact contact) {
  final language = context.read<LanguageProvider>().language;
  return [
    if (contact.phone case final phone?)
      _ContactRow(
        icon: Icons.phone_outlined,
        title: AppStrings.profilePhone.select(language),
        value: phone,
        onTap: () => launchUrl(Uri(scheme: 'tel', path: phone)),
      ),
    if (contact.email case final email?)
      _ContactRow(
        icon: Icons.mail_outline,
        title: AppStrings.profileEmail.select(language),
        value: email,
        onTap: () => launchUrl(Uri(scheme: 'mailto', path: email)),
      ),
    if (contact.whatsapp case final whatsapp?)
      _ContactRow(
        icon: Icons.chat_bubble_outline,
        title: 'WhatsApp',
        value: whatsapp,
        onTap: () => launchUrl(
          Uri.parse('https://wa.me/${whatsapp.replaceAll(RegExp(r'\D'), '')}'),
          mode: LaunchMode.externalApplication,
        ),
      ),
    if (contact.imo case final imo?)
      _ContactRow(
        icon: Icons.forum_outlined,
        title: 'IMO',
        value: imo,
        onTap: () async {
          await Clipboard.setData(ClipboardData(text: imo));
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  AppStrings.profileImoContactCopied.select(language),
                ),
              ),
            );
          }
          await launchUrl(
            Uri.parse('https://imo.im/'),
            mode: LaunchMode.externalApplication,
          );
        },
      ),
    if (contact.address case final address?)
      _ContactRow(
        icon: Icons.location_on_outlined,
        title: AppStrings.profileAddress.select(language),
        value: address,
        onTap: null,
      ),
  ];
}

/// Real support content — an FAQ accordion plus tappable contact rows —
/// replacing the old generic `SettingsScreen` stub that had no actual
/// answers or contact info.
class ClientSupportScreen extends StatelessWidget {
  const ClientSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final language = context.watch<LanguageProvider>().language;
    final tokens = context.appTokens;
    final supportContact = context.watch<AppSettingsProvider>().supportContact;
    final contact = context.watch<AppSettingsProvider>().contact;

    final faqs = <(String, String)>[
      (
        AppStrings.profileHowDoICancelA.select(language),
        AppStrings.profileOpenTheBookingUnderThe.select(language),
      ),
      (
        AppStrings.profileWhereAreMyFavouriteMasters.select(language),
        AppStrings.profileTapTheHeartIconIn.select(language),
      ),
      (
        AppStrings.profileHowDoesPaymentWork.select(language),
        AppStrings.profilePaymentsAreCurrentlyTakenIn.select(language),
      ),
      (
        AppStrings.profileCanIChangeMyPhone.select(language),
        AppStrings.profileYouCanEditYourName.select(language),
      ),
    ];

    return Scaffold(
      backgroundColor: tokens.surface,
      appBar: CabinetAppBar(title: AppStrings.profileSupport.select(language)),
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            Text(
              AppStrings.profileFrequentlyAskedQuestions.select(language),
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
            ...faqs.map((faq) => _FaqTile(question: faq.$1, answer: faq.$2)),
            const SizedBox(height: 22),
            Text(
              AppStrings.profileGetInTouch.select(language),
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
            if (supportContact.isNotEmpty)
              _ContactRow(
                icon: Icons.support_agent_outlined,
                title: AppStrings.profileSupport.select(language),
                value: supportContact,
                onTap: () => _openSupportContact(supportContact),
              ),
            ..._configuredContactRows(context, contact),
            const SizedBox(height: 16),
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

class _FaqTile extends StatelessWidget {
  const _FaqTile({required this.question, required this.answer});
  final String question;
  final String answer;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: tokens.surfaceElevated,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: tokens.border),
        ),
        clipBehavior: Clip.antiAlias,
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            tilePadding: const EdgeInsets.symmetric(horizontal: 14),
            childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
            iconColor: tokens.accent,
            collapsedIconColor: tokens.textSecondary,
            title: Text(
              question,
              style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
              ),
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
      ),
    );
  }
}
