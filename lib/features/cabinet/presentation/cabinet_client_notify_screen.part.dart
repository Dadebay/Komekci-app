part of '../../../app/komekci_app.dart';

class ClientNotifyScreen extends StatefulWidget {
  const ClientNotifyScreen({super.key});

  @override
  State<ClientNotifyScreen> createState() => _ClientNotifyScreenState();
}

class _ClientNotifyScreenState extends State<ClientNotifyScreen> {
  bool _reminderEnabled = true;
  int _reminderDays = 10;

  @override
  Widget build(BuildContext context) {
    final language = context.watch<LanguageProvider>().language;
    String t({required String tk, required String ru, required String en}) =>
        pickTr(language, tk: tk, ru: ru, en: en);
    final tokens = context.appTokens;
    return Scaffold(
      backgroundColor: tokens.surface,
      appBar: CabinetAppBar(
        title: t(
          tk: 'Müşderilere bildiriş',
          ru: 'Уведомления клиентам',
          en: 'Client notifications',
        ),
        action: _HelpIconButton(
          onTap: () =>
              Navigator.push(context, pageRoute(const SupportScreen())),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            _InfoBanner(
              icon: Icons.notifications_none,
              text: t(
                tk: 'Ýazgy ýatlatmalary müşderilere awtomatiki iberilýär. Bu habarlaryň sazlamasy ulgam tarapyndan dolandyrylýar.',
                ru: 'Напоминания о записи отправляются клиентам автоматически. Этими настройками управляет система.',
                en: 'Booking reminders are sent to clients automatically. These settings are managed by the system.',
              ),
            ),
            const SizedBox(height: 22),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: AppIcon(
                    Icons.groups_outlined,
                    color: tokens.textPrimary,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    t(
                      tk: '1. Müşderini gaýtadan çagyrmak',
                      ru: '1. Повторный вызов клиента',
                      en: '1. Bringing clients back',
                    ),
                    style: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              t(
                tk: 'Müşderä soňky saparyndan belli bir wagtdan soň ýatlatma habary iberiler.',
                ru: 'Клиенту будет отправлено напоминание через определённое время после последнего визита.',
                en: 'The client will receive a reminder a set amount of time after their last visit.',
              ),
              style: const TextStyle(
                fontSize: 12,
                color: Colors.black45,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: tokens.surfaceElevated,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _softLine(tokens)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          t(
                            tk: 'Funksiýany aç / ýap',
                            ru: 'Включить / выключить',
                            en: 'Turn on / off',
                          ),
                          style: const TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Switch(
                        value: _reminderEnabled,
                        activeThumbColor: tokens.surface,
                        activeTrackColor: tokens.textPrimary,
                        onChanged: (v) => setState(() => _reminderEnabled = v),
                      ),
                    ],
                  ),
                  Divider(color: _softLine(tokens), height: 22),
                  Text(
                    t(
                      tk: 'Ýatlatma näçe günden soň iberilsin?',
                      ru: 'Через сколько дней отправлять напоминание?',
                      en: 'How many days before sending a reminder?',
                    ),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    t(
                      tk: 'Müşteri bu wagt aralygynda täzeden ýazylmasa, oňa ýatlatma habary iberiler.',
                      ru: 'Если клиент не запишется повторно за это время, ему придёт напоминание.',
                      en: 'If the client does not book again within this time, they will receive a reminder.',
                    ),
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: Colors.black45,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: () async {
                      final picked = await _pickDuration(
                        context,
                        language: language,
                        current: _reminderDays,
                        options: const [3, 5, 7, 10, 14, 21, 30],
                        unit: t(tk: 'gün', ru: 'дн.', en: 'days'),
                      );
                      if (picked != null)
                        setState(() => _reminderDays = picked);
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 13,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: tokens.border),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              '$_reminderDays ${t(tk: "gün", ru: "дн.", en: "days")}',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const AppIcon(
                            Icons.expand_more,
                            color: Colors.black38,
                            size: 18,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 26),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: AppIcon(
                    Icons.send_outlined,
                    color: tokens.textPrimary,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    t(
                      tk: '2. Gysga habar ibermek',
                      ru: '2. Отправить короткое сообщение',
                      en: '2. Send a short message',
                    ),
                    style: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              t(
                tk: 'Islendik müşdere ýa-da ähli müşderilere gysga habar iberiň.',
                ru: 'Отправьте короткое сообщение любому клиенту или всем сразу.',
                en: 'Send a short message to any client or all of them at once.',
              ),
              style: const TextStyle(
                fontSize: 12,
                color: Colors.black45,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 12),
            _SettingRow(
              icon: Icons.send_outlined,
              title: t(
                tk: 'Habar ibermek',
                ru: 'Отправить сообщение',
                en: 'Send message',
              ),
              showChevron: true,
              onTap: () => Navigator.push(
                context,
                pageRoute(const SendMessageScreen()),
              ),
            ),
            const SizedBox(height: 10),
            _InfoBanner(
              icon: Icons.info_outline,
              text: t(
                tk: 'Habarlar ähli müşderilere ýa-da saýlanan müşderilere iberlip bilner.',
                ru: 'Сообщения можно отправить всем клиентам или выбранным.',
                en: 'Messages can be sent to all clients or to selected ones.',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
