part of '../../../app/komekci_app.dart';

class SendMessageScreen extends StatefulWidget {
  const SendMessageScreen({super.key});

  @override
  State<SendMessageScreen> createState() => _SendMessageScreenState();
}

class _SendMessageScreenState extends State<SendMessageScreen> {
  final _messageController = TextEditingController();
  int _audience = 0; // 0 = all, 1 = selected, 2 = recent
  var _selectedNames = <String>[];
  var _recentNames = <String>[];
  bool _pushChannel = true;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  String _audienceSubtitle(AppLanguage language, int index) {
    String t({required String tk, required String ru, required String en}) =>
        pickTr(language, tk: tk, ru: ru, en: en);
    switch (index) {
      case 0:
        return t(
          tk: 'Ähli müşderilere iberiler ($_mockTotalClients adam).',
          ru: 'Будет отправлено всем клиентам ($_mockTotalClients чел.).',
          en: 'Will be sent to all clients ($_mockTotalClients people).',
        );
      case 1:
        return _selectedNames.isEmpty
            ? t(
                tk: 'Müşderileri saýlap iberiň.',
                ru: 'Выберите клиентов для отправки.',
                en: 'Choose clients to send to.',
              )
            : t(
                tk: '${_selectedNames.length} müşderi saýlandy.',
                ru: 'Выбрано клиентов: ${_selectedNames.length}.',
                en: '${_selectedNames.length} clients selected.',
              );
      default:
        return _recentNames.isEmpty
            ? t(
                tk: 'Belli bir wagtyň içinde ýazylan müşderiler.',
                ru: 'Клиенты за определённый период.',
                en: 'Clients within a specific time period.',
              )
            : t(
                tk: '${_recentNames.length} müşderi saýlandy.',
                ru: 'Выбрано клиентов: ${_recentNames.length}.',
                en: '${_recentNames.length} clients selected.',
              );
    }
  }

  Future<void> _selectAudience(int index) async {
    if (index == 1) {
      final result = await Navigator.push<List<String>>(
        context,
        pageRoute(SelectedClientsScreen(initialSelection: _selectedNames)),
      );
      if (result == null) return;
      setState(() {
        _audience = 1;
        _selectedNames = result;
      });
      return;
    }
    if (index == 2) {
      final result = await Navigator.push<List<String>>(
        context,
        pageRoute(RecentClientsScreen(initialSelection: _recentNames)),
      );
      if (result == null) return;
      setState(() {
        _audience = 2;
        _recentNames = result;
      });
      return;
    }
    setState(() => _audience = 0);
  }

  /// Shows who the message will actually reach and asks for a final confirmation before sending.
  Future<void> _confirmAndSend(AppLanguage language) async {
    String t({required String tk, required String ru, required String en}) =>
        pickTr(language, tk: tk, ru: ru, en: en);
    final int recipientCount;
    final String recipientLabel;
    switch (_audience) {
      case 0:
        recipientCount = _mockTotalClients;
        recipientLabel = t(
          tk: 'ähli müşderilere',
          ru: 'всем клиентам',
          en: 'to all clients',
        );
      case 1:
        recipientCount = _selectedNames.length;
        recipientLabel = t(
          tk: 'saýlanan müşderilere',
          ru: 'выбранным клиентам',
          en: 'to selected clients',
        );
      default:
        recipientCount = _recentNames.length;
        recipientLabel = t(
          tk: 'soňky wagt aralygyndaky müşderilere',
          ru: 'клиентам за период',
          en: 'to clients from the recent period',
        );
    }
    final tokens = context.appTokens;
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: tokens.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t(
                    tk: 'Habary tassyklaň',
                    ru: 'Подтвердите отправку',
                    en: 'Confirm sending',
                  ),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  t(
                    tk: 'Habar $recipientLabel iberiler · $recipientCount adam. Dowam etmek isleýärsiňizmi?',
                    ru: 'Сообщение будет отправлено $recipientLabel · $recipientCount чел. Продолжить?',
                    en: 'The message will be sent $recipientLabel · $recipientCount people. Continue?',
                  ),
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.black54,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          side: BorderSide(color: tokens.border),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        onPressed: () => Navigator.pop(sheetContext, false),
                        child: Text(
                          t(tk: 'Ýok', ru: 'Отмена', en: 'Cancel'),
                          style: TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w600,
                            color: tokens.textPrimary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _MasterActionButton(
                        label: t(tk: 'Iber', ru: 'Отправить', en: 'Send'),
                        enabled: true,
                        onTap: () => Navigator.pop(sheetContext, true),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
    if (confirmed != true || !mounted) return;

    // Real SMS delivery is only possible on Android, and only for audiences whose phone
    // numbers we actually know (the "all clients" count is a mock total with no directory).
    if (!_pushChannel && Platform.isAndroid) {
      final numbers = _resolvePhoneNumbers();
      if (numbers.isNotEmpty) {
        await _sendRealSms(language, numbers);
        return;
      }
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          t(
            tk: 'Habar $recipientCount adama iberildi.',
            ru: 'Сообщение отправлено $recipientCount получателям.',
            en: 'Message sent to $recipientCount recipients.',
          ),
        ),
      ),
    );
    Navigator.pop(context);
  }

  List<String> _resolvePhoneNumbers() {
    switch (_audience) {
      case 1:
        return _selectedNames
            .map((name) => _mockClients.firstWhere((c) => c.name == name).phone)
            .toList();
      case 2:
        return _recentNames
            .map((name) => _mockClients.firstWhere((c) => c.name == name).phone)
            .toList();
      default:
        return const [];
    }
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
    for (final number in numbers) {
      final result = await BackgroundSms.sendMessage(
        phoneNumber: number,
        message: message,
      );
      if (result == SmsStatus.sent) sent++;
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          t(
            tk: '$sent/${numbers.length} SMS iberildi.',
            ru: 'Отправлено SMS: $sent из ${numbers.length}.',
            en: '$sent/${numbers.length} SMS sent.',
          ),
        ),
      ),
    );
    Navigator.pop(context);
  }

  Future<void> _pickChannel(AppLanguage language) async {
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
    if (picked != null) setState(() => _pushChannel = picked);
  }

  @override
  Widget build(BuildContext context) {
    final language = context.watch<LanguageProvider>().language;
    String t({required String tk, required String ru, required String en}) =>
        pickTr(language, tk: tk, ru: ru, en: en);
    final tokens = context.appTokens;
    final audienceTitles = switch (language) {
      AppLanguage.tk => [
        'Ähli müşderiler',
        'Saýlanan müşderiler',
        'Soňky wagt aralygyndaky müşderiler',
      ],
      AppLanguage.ru => [
        'Все клиенты',
        'Выбранные клиенты',
        'Клиенты за период',
      ],
      AppLanguage.en => ['All clients', 'Selected clients', 'Recent clients'],
    };
    final ready =
        _messageController.text.trim().isNotEmpty &&
        (_audience != 1 || _selectedNames.isNotEmpty) &&
        (_audience != 2 || _recentNames.isNotEmpty);
    return Scaffold(
      backgroundColor: tokens.surface,
      appBar: CabinetAppBar(
        title: t(
          tk: 'Habar ibermek',
          ru: 'Отправить сообщение',
          en: 'Send message',
        ),
        action: _HelpIconButton(
          onTap: () =>
              Navigator.push(context, pageRoute(const SupportScreen())),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                children: [
                  _InfoBanner(
                    icon: Icons.chat_bubble_outline,
                    text: t(
                      tk: 'Saýlanan müşderilere gysga habar iberiň. SMS ýa-da push habarnama bolar.',
                      ru: 'Отправьте короткое сообщение выбранным клиентам. Это может быть SMS или push-уведомление.',
                      en: 'Send a short message to selected clients. This can be an SMS or a push notification.',
                    ),
                  ),
                  const SizedBox(height: 20),
                  _FieldLabel(
                    text: t(
                      tk: 'Kimlere ibermeli?',
                      ru: 'Кому отправить?',
                      en: 'Who to send to?',
                    ),
                  ),
                  const SizedBox(height: 10),
                  ...List.generate(3, (index) {
                    final selected = _audience == index;
                    return GestureDetector(
                      onTap: () => _selectAudience(index),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: selected
                              ? const Color(0xffFDF9F2)
                              : tokens.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: selected ? tokens.accent : tokens.border,
                            width: selected ? 1.5 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 21,
                              height: 21,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: selected
                                      ? tokens.accent
                                      : tokens.border,
                                  width: 1.6,
                                ),
                              ),
                              child: selected
                                  ? Container(
                                      width: 10,
                                      height: 10,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: tokens.accent,
                                      ),
                                    )
                                  : null,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    audienceTitles[index],
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    _audienceSubtitle(language, index),
                                    style: const TextStyle(
                                      fontSize: 11.5,
                                      color: Colors.black45,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (index != 0)
                              const AppIcon(
                                Icons.chevron_right,
                                color: Colors.black26,
                                size: 17,
                              ),
                          ],
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 8),
                  _FieldLabel(
                    text: t(
                      tk: 'Habar teksti',
                      ru: 'Текст сообщения',
                      en: 'Message text',
                    ),
                    required: true,
                  ),
                  const SizedBox(height: 8),
                  _FormField(
                    controller: _messageController,
                    hint: t(
                      tk: 'Habaryňyzy ýazyň...',
                      ru: 'Напишите сообщение...',
                      en: 'Write your message...',
                    ),
                    maxLines: 5,
                    maxLength: 160,
                    onChanged: () => setState(() {}),
                  ),
                  const SizedBox(height: 18),
                  _FieldLabel(
                    text: t(
                      tk: 'Geplesik görnüşi',
                      ru: 'Способ отправки',
                      en: 'Delivery method',
                    ),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () => _pickChannel(language),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 13,
                      ),
                      decoration: BoxDecoration(
                        color: tokens.surfaceElevated,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: _softLine(tokens)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 34,
                            height: 34,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: const Color(0xffFDF9F2),
                              borderRadius: BorderRadius.circular(11),
                            ),
                            child: AppIcon(
                              _pushChannel
                                  ? Icons.notifications_none
                                  : Icons.smartphone_outlined,
                              color: tokens.accent,
                              size: 16,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _pushChannel
                                      ? t(
                                          tk: 'Push habar',
                                          ru: 'Push-уведомление',
                                          en: 'Push notification',
                                        )
                                      : 'SMS',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _pushChannel
                                      ? t(
                                          tk: 'Müşderilere push habarnama iberiler.',
                                          ru: 'Клиентам придёт push-уведомление.',
                                          en: 'Clients will receive a push notification.',
                                        )
                                      : t(
                                          tk: 'Müşderilere SMS iberiler.',
                                          ru: 'Клиентам придёт SMS.',
                                          en: 'Clients will receive an SMS.',
                                        ),
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Colors.black45,
                                  ),
                                ),
                              ],
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
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 6, 20, 14),
              child: _MasterActionButton(
                label: t(
                  tk: 'Habar ibermek',
                  ru: 'Отправить',
                  en: 'Send message',
                ),
                enabled: ready,
                leading: Icons.send_outlined,
                onTap: () => _confirmAndSend(language),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
