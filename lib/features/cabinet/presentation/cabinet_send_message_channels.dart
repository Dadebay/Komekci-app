part of '../../../app/komekci_app.dart';

extension _SendMessageChannels on _SendMessageScreenState {
  /// Opens the phone's own messaging app with the text filled in, one client
  /// at a time. Nothing is sent from here, so the app needs no SMS permission,
  /// and clients never see each other's numbers (a single group message
  /// would show them).
  Future<void> _sendSmsViaApp(
    AppLanguage language,
    List<Customer> customers,
  ) async {
    final message = _messageController.text.trim();
    final tokens = context.appTokens;
    String t({required String tk, required String ru, required String en}) =>
        pickTr(language, tk: tk, ru: ru, en: en);
    final opened = <String>{};
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: tokens.surface,
      isScrollControlled: true,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setSheetState) => SafeArea(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * .8,
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    t(tk: 'SMS ibermek', ru: 'Отправка SMS', en: 'Send SMS'),
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    t(
                      tk: 'Her müşderi üçin SMS programmasy açylar. Tekst taýýar, diňe “Iber” düwmesine basyň.',
                      ru: 'Для каждого клиента откроется приложение SMS с готовым текстом. Остаётся нажать «Отправить».',
                      en: 'The messaging app opens for each client with the text ready. Just tap send there.',
                    ),
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.4,
                      color: tokens.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Flexible(
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: customers.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final customer = customers[index];
                        final done = opened.contains(customer.id);
                        return Container(
                          padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
                          decoration: BoxDecoration(
                            color: tokens.surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: done ? tokens.success : tokens.border,
                            ),
                          ),
                          child: Row(
                            children: [
                              _CustomerAvatar(customer: customer, radius: 18),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      customer.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    Text(
                                      customer.phone,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: tokens.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              TextButton.icon(
                                onPressed: () async {
                                  final ok = await _openSmsApp(
                                    customer.phone,
                                    message,
                                  );
                                  if (ok) {
                                    setSheetState(
                                      () => opened.add(customer.id),
                                    );
                                  } else if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          AppStrings.cabinetCouldNotSendTheSms
                                              .select(language),
                                        ),
                                      ),
                                    );
                                  }
                                },
                                icon: AppIcon(
                                  done
                                      ? Icons.check_circle
                                      : Icons.sms_outlined,
                                  size: 18,
                                  color: done ? tokens.success : tokens.accent,
                                ),
                                label: Text(
                                  done
                                      ? t(
                                          tk: 'Täzeden',
                                          ru: 'Ещё раз',
                                          en: 'Again',
                                        )
                                      : t(tk: 'Aç', ru: 'Открыть', en: 'Open'),
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: done
                                        ? tokens.success
                                        : tokens.accent,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    if (mounted && opened.length == customers.length) Navigator.pop(context);
  }

  /// `sms:` link with the text prefilled. iOS wants `&body=` after the number,
  /// Android `?body=`.
  Future<bool> _openSmsApp(String phone, String message) async {
    final number = phone.replaceAll(RegExp(r'[^\d+]'), '');
    final body = Uri.encodeComponent(message);
    final uri = Uri.parse(
      Platform.isIOS ? 'sms:$number&body=$body' : 'sms:$number?body=$body',
    );
    try {
      return await launchUrl(uri);
    } catch (_) {
      return false;
    }
  }

  Future<void> _pickChannel(
    AppLanguage language, {
    required StateSetter update,
  }) async {
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
                  AppStrings.cabinetDeliveryMethod.select(language),
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
                    AppStrings.cabinetPushNotification.select(language),
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
