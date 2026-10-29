part of '../../../app/komekci_app.dart';

extension _SendMessageChannels on _SendMessageScreenState {
  List<String> _resolvePhoneNumbers() {
    return _recipients.map((c) => c.phone).where((phone) => phone.isNotEmpty).toSet().toList();
  }

  Future<void> _sendRealSms(AppLanguage language, List<String> numbers) async {
    String t({required String tk, required String ru, required String en}) =>
        pickTr(language, tk: tk, ru: ru, en: en);
    final status = await Permission.sms.request();
    if (!status.isGranted) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            t(
              tk: 'SMS ibermek üçin rugsat gerek.',
              ru: 'Для отправки SMS нужно разрешение.',
              en: 'Permission is needed to send SMS.',
            ),
          ),
        ),
      );
      return;
    }
    final message = _messageController.text.trim();
    var sent = 0;
    var unknown = 0;
    for (final number in numbers) {
      final result = await BackgroundSms.sendMessage(
        phoneNumber: number,
        message: message,
      );
      if (result == SmsStatus.sent) {
        sent++;
      } else if (result == SmsStatus.unknown) {
        unknown++;
      }
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: Duration(seconds: unknown > 0 ? 8 : 4),
        content: Text(
          unknown > 0
              ? t(
                  tk: '$sent/${numbers.length} SMS iberilendigi tassyklandy. $unknown SMS-iň netijesi näbelli; gaýtadan ibermezden öň SMS taryhyny barlaň.',
                  ru: 'Подтверждено SMS: $sent из ${numbers.length}. Результат $unknown неизвестен; проверьте историю SMS перед повторной отправкой.',
                  en: '$sent/${numbers.length} SMS confirmed sent. $unknown unconfirmed; check SMS history before retrying.',
                )
              : sent == numbers.length
                  ? t(
                      tk: '$sent/${numbers.length} SMS iberilendigi tassyklandy.',
                      ru: 'Подтверждено SMS: $sent из ${numbers.length}.',
                      en: '$sent/${numbers.length} SMS confirmed sent.',
                    )
                  : t(
                      tk: '$sent/${numbers.length} SMS iberildi, galanlaryny iberip bolmady.',
                      ru: 'Отправлено SMS: $sent из ${numbers.length}; остальные не отправлены.',
                      en: '$sent/${numbers.length} SMS sent; the rest failed.',
                    ),
        ),
      ),
    );
    if (sent == numbers.length) Navigator.pop(context);
  }

  Future<void> _pickChannel(AppLanguage language, {required StateSetter update}) async {
    String t({required String tk, required String ru, required String en}) =>
        pickTr(language, tk: tk, ru: ru, en: en);
    final tokens = context.appTokens;
    final picked = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: tokens.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t(
                    tk: 'Geplesik görnüşi',
                    ru: 'Способ отправки',
                    en: 'Delivery method',
                  ),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: AppIcon(
                    Icons.notifications_none,
                    color: tokens.accent,
                  ),
                  title: Text(
                    t(
                      tk: 'Push habar',
                      ru: 'Push-уведомление',
                      en: 'Push notification',
                    ),
                    style: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  trailing: _pushChannel
                      ? AppIcon(Icons.check, color: tokens.accent)
                      : null,
                  onTap: () => Navigator.pop(sheetContext, true),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: AppIcon(
                    Icons.smartphone_outlined,
                    color: tokens.accent,
                  ),
                  title: const Text(
                    'SMS',
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  trailing: !_pushChannel
                      ? AppIcon(Icons.check, color: tokens.accent)
                      : null,
                  onTap: () => Navigator.pop(sheetContext, false),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    if (picked != null) update(() => _pushChannel = picked);
  }

}
