part of '../../../app/komekci_app.dart';

/// Outgoing messages for masters. Booking reminders are managed by the server;
/// this screen only offers actions the master can actually complete.
class ClientNotifyScreen extends StatelessWidget {
  const ClientNotifyScreen({super.key});

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
          tk: 'Müşderilere habar',
          ru: 'Сообщения клиентам',
          en: 'Messages to clients',
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          children: [
            Text(
              t(
                tk: 'Müşderilere habar iberiň',
                ru: 'Напишите клиентам',
                en: 'Message your clients',
              ),
              style: TextStyle(
                color: tokens.textPrimary,
                fontSize: 24,
                fontWeight: FontWeight.w800,
                height: 1.15,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              t(
                tk: 'Müşderileri saýlap, olara push habar ýa-da SMS iberiň.',
                ru: 'Выберите клиентов и отправьте push-уведомление или SMS.',
                en: 'Choose clients and send a push notification or SMS.',
              ),
              style: TextStyle(
                color: tokens.textSecondary,
                fontSize: 13.5,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 24),
            Material(
              color: tokens.surfaceElevated,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(color: tokens.border),
              ),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () => Navigator.push(
                  context,
                  pageRoute(const SendMessageScreen()),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: tokens.accent.withValues(alpha: .12),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: AppIcon(
                          Icons.send_outlined,
                          color: tokens.accent,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              t(
                                tk: 'Täze habar',
                                ru: 'Новое сообщение',
                                en: 'New message',
                              ),
                              style: TextStyle(
                                color: tokens.textPrimary,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              t(
                                tk: 'Push ýa-da SMS iber',
                                ru: 'Отправить push или SMS',
                                en: 'Send push or SMS',
                              ),
                              style: TextStyle(
                                color: tokens.textSecondary,
                                fontSize: 12.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      AppIcon(
                        Icons.chevron_right,
                        color: tokens.textSecondary,
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              t(
                tk: 'Awtomatiki ýatlatmalar',
                ru: 'Автоматические напоминания',
                en: 'Automatic reminders',
              ),
              style: TextStyle(
                color: tokens.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: tokens.surfaceElevated,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: tokens.border),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppIcon(
                    Icons.notifications_active_outlined,
                    color: tokens.accent,
                    size: 21,
                  ),
                  const SizedBox(width: 13),
                  Expanded(
                    child: Text(
                      t(
                        tk: 'Ýazgy ýatlatmalary müşderilere ulgam tarapyndan awtomatiki iberilýär.',
                        ru: 'Напоминания о записи отправляются клиентам автоматически.',
                        en: 'Booking reminders are sent to clients automatically.',
                      ),
                      style: TextStyle(
                        color: tokens.textSecondary,
                        fontSize: 13,
                        height: 1.45,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
