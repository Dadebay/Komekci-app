part of '../../../app/komekci_app.dart';

bool _canMessageCustomer(Customer customer, {required bool forPush}) =>
    forPush
        ? !customer.offline && customer.accountId != null
        : customer.phone.isNotEmpty;

class SendMessageScreen extends StatefulWidget {
  const SendMessageScreen({super.key});

  @override
  State<SendMessageScreen> createState() => _SendMessageScreenState();
}

class _SendMessageScreenState extends State<SendMessageScreen> {
  final _titleController = TextEditingController();
  final _messageController = TextEditingController();
  int _audience = 0; // 0 = all, 1 = selected, 2 = recent
  var _selectedIds = <String>[];
  var _recentIds = <String>[];
  bool _pushChannel = true;
  bool _sending = false;

  List<Customer> get _eligibleClients => context.read<CustomerProvider>().customers
      .where((c) => _canMessageCustomer(c, forPush: _pushChannel))
      .toList();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final customers = context.read<CustomerProvider>();
      if (!customers.loading) customers.load();
    });
  }

  List<Customer> get _recipients {
    final clients = _eligibleClients;
    return switch (_audience) {
      1 => clients.where((c) => _selectedIds.contains(c.id)).toList(),
      2 => clients.where((c) => _recentIds.contains(c.id)).toList(),
      _ => clients,
    };
  }

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  String _audienceSubtitle(AppLanguage language, int index) {
    String t({required String tk, required String ru, required String en}) =>
        pickTr(language, tk: tk, ru: ru, en: en);
    switch (index) {
      case 0:
        return t(
          tk: 'Ähli müşderilere iberiler (${_eligibleClients.length} adam).',
          ru: 'Будет отправлено всем клиентам (${_eligibleClients.length} чел.).',
          en: 'Will be sent to all clients (${_eligibleClients.length} people).',
        );
      case 1:
        return _selectedIds.isEmpty
            ? t(
                tk: 'Müşderileri saýlap iberiň.',
                ru: 'Выберите клиентов для отправки.',
                en: 'Choose clients to send to.',
              )
            : t(
                tk: '${_selectedIds.length} müşderi saýlandy.',
                ru: 'Выбрано клиентов: ${_selectedIds.length}.',
                en: '${_selectedIds.length} clients selected.',
              );
      default:
        return _recentIds.isEmpty
            ? t(
                tk: 'Belli bir wagtyň içinde ýazylan müşderiler.',
                ru: 'Клиенты за определённый период.',
                en: 'Clients within a specific time period.',
              )
            : t(
                tk: '${_recentIds.length} müşderi saýlandy.',
                ru: 'Выбрано клиентов: ${_recentIds.length}.',
                en: '${_recentIds.length} clients selected.',
              );
    }
  }

  Future<void> _selectAudience(int index) async {
    if (index == 1) {
      final result = await Navigator.push<List<String>>(
        context,
        pageRoute(SelectedClientsScreen(initialSelection: _selectedIds, forPush: _pushChannel)),
      );
      if (result == null) return;
      setState(() {
        _audience = 1;
        _selectedIds = result;
      });
      return;
    }
    if (index == 2) {
      final result = await Navigator.push<List<String>>(
        context,
        pageRoute(RecentClientsScreen(initialSelection: _recentIds, forPush: _pushChannel)),
      );
      if (result == null) return;
      setState(() {
        _audience = 2;
        _recentIds = result;
      });
      return;
    }
    setState(() => _audience = 0);
  }

  /// Shows who the message will actually reach and asks for a final confirmation before sending.
  Future<void> _confirmAndSend(AppLanguage language) async {
    final recipients = _recipients;
    if (_sending || recipients.isEmpty || recipients.length > 50 ||
        _messageController.text.trim().isEmpty ||
        (_pushChannel && _titleController.text.trim().isEmpty)) {
      return;
    }
    String t({required String tk, required String ru, required String en}) =>
        pickTr(language, tk: tk, ru: ru, en: en);
    final methodLabel = _pushChannel
        ? t(tk: 'Push habar', ru: 'Push-уведомление', en: 'Push notification')
        : 'SMS';
    final int recipientCount;
    final String recipientLabel;
    switch (_audience) {
      case 0:
        recipientCount = recipients.length;
        recipientLabel = t(
          tk: 'ähli müşderilere',
          ru: 'всем клиентам',
          en: 'to all clients',
        );
      case 1:
        recipientCount = recipients.length;
        recipientLabel = t(
          tk: 'saýlanan müşderilere',
          ru: 'выбранным клиентам',
          en: 'to selected clients',
        );
      default:
        recipientCount = recipients.length;
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
                    tk: '$methodLabel $recipientLabel iberiler · $recipientCount adam. Dowam etmek isleýärsiňizmi?',
                    ru: '$methodLabel будет отправлено $recipientLabel · $recipientCount чел. Продолжить?',
                    en: '$methodLabel will be sent $recipientLabel · $recipientCount people. Continue?',
                  ),
                  style: TextStyle(
                    fontSize: 13,
                    color: tokens.textSecondary,
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

    if (!_pushChannel && Platform.isAndroid) {
      final numbers = _resolvePhoneNumbers();
      if (numbers.isNotEmpty) {
        setState(() => _sending = true);
        try {
          await _sendRealSms(language, numbers);
        } catch (_) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t(
              tk: 'SMS iberilip bilmedi.',
              ru: 'Не удалось отправить SMS.',
              en: 'Could not send the SMS.',
            ))));
          }
        } finally {
          if (mounted) setState(() => _sending = false);
        }
        return;
      }
    }
    if (!_pushChannel) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t(
        tk: 'SMS ibermek üçin Android we müşderiniň telefon belgisi gerek.',
        ru: 'Для SMS нужен Android и номер телефона клиента.',
        en: 'SMS requires Android and a client phone number.',
      ))));
      return;
    }
    setState(() => _sending = true);
    try {
      final response = await context.read<MeRepository>().sendClientNotification(
        title: _titleController.text.trim(),
        body: _messageController.text.trim(),
        accountIds: recipients.map((c) => c.accountId!).toSet().toList(),
      );
      if (!mounted) return;
      final inbox = (response['sent'] as List? ?? const []).length;
      final skipped = (response['skipped'] as List? ?? const []).length;
      final push = response['success_count'] as int? ?? 0;
      final failed = response['failure_count'] as int? ?? 0;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t(
        tk: 'Gelen habarlar: $inbox, push tassyklandy: $push, şowsuz: $failed, geçildi: $skipped.',
        ru: 'Входящие: $inbox, push подтверждено: $push, не доставлено: $failed, пропущено: $skipped.',
        en: 'Inbox: $inbox, push confirmed: $push, failed: $failed, skipped: $skipped.',
      ))));
      Navigator.pop(context);
    } catch (error) {
      if (!mounted) return;
      final rejected = error is ApiException && error.code == ApiErrors.forbidden
          ? error.details['rejected'] as List?
          : null;
      final message = rejected != null && rejected.isNotEmpty
          ? t(
              tk: 'Habar iberilmedi. Rugsat berilmedik hasaplar: ${rejected.join(', ')}.',
              ru: 'Ничего не отправлено. Недоступные аккаунты: ${rejected.join(', ')}.',
              en: 'Nothing was sent. Unavailable accounts: ${rejected.join(', ')}.',
            )
          : apiErrorMessage(error, language);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
      setState(() => _sending = false);
    }
  }

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
    final customerProvider = context.watch<CustomerProvider>();
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
        !_sending &&
        (!_pushChannel || _titleController.text.trim().isNotEmpty) &&
        _messageController.text.trim().isNotEmpty &&
        _recipients.isNotEmpty &&
        _recipients.length <= 50;
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
                  if (customerProvider.loading && customerProvider.customers.isEmpty) ...[
                    const SizedBox(height: 16),
                    const Center(child: CircularProgressIndicator()),
                  ] else if (customerProvider.error != null && customerProvider.customers.isEmpty) ...[
                    const SizedBox(height: 10),
                    RetryErrorState(
                      title: t(tk: 'Müşderileri ýükläp bolmady', ru: 'Не удалось загрузить клиентов', en: 'Could not load clients'),
                      text: t(tk: 'Täzeden synanyşyň.', ru: 'Попробуйте ещё раз.', en: 'Please try again.'),
                      retryLabel: t(tk: 'Täzeden synanyş', ru: 'Повторить', en: 'Try again'),
                      onRetry: customerProvider.load,
                    ),
                  ] else if (_eligibleClients.isEmpty) ...[
                    const SizedBox(height: 10),
                    _InfoBanner(
                      icon: Icons.info_outline,
                      text: customerProvider.customers.isEmpty
                          ? _pushChannel
                              ? t(
                                  tk: 'Sanawda entek müşderi ýok. Push üçin baglanan müşderi gerek.',
                                  ru: 'Список клиентов пуст. Для push нужен подключённый клиент.',
                                  en: 'The client list is empty. Push needs a connected client.',
                                )
                              : t(
                                  tk: 'Sanawda entek müşderi ýok.',
                                  ru: 'Список клиентов пока пуст.',
                                  en: 'The client list is empty.',
                                )
                          : _pushChannel
                              ? t(
                                  tk: 'Müşderiler bar, ýöne push alyjynyň hasaby kesgitlenmedi. SMS saýlap bilersiňiz.',
                                  ru: 'Клиенты есть, но аккаунт получателя для push не определён. Можно выбрать SMS.',
                                  en: 'Clients are listed, but their push account cannot be identified. You can choose SMS.',
                                )
                              : t(
                                  tk: 'Müşderileriň telefon belgisi ýok.',
                                  ru: 'У клиентов нет номеров телефонов.',
                                  en: 'These clients have no phone numbers.',
                                ),
                    ),
                  ],
                  if (_recipients.length > 50) ...[
                    const SizedBox(height: 10),
                    _InfoBanner(
                      icon: Icons.info_outline,
                      text: t(
                        tk: 'Bir gezekde iň köp 50 müşderini saýlaň.',
                        ru: 'Выберите не более 50 клиентов за раз.',
                        en: 'Choose up to 50 clients at a time.',
                      ),
                    ),
                  ],
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
                              ? tokens.accent.withValues(alpha: .1)
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
                                    style: TextStyle(
                                      fontSize: 11.5,
                                      color: tokens.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (index != 0)
                              AppIcon(
                                Icons.chevron_right,
                                color: tokens.textSecondary,
                                size: 17,
                              ),
                          ],
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 8),
                  if (_pushChannel) ...[
                    _FieldLabel(
                      text: t(tk: 'Sözbaşy', ru: 'Заголовок', en: 'Title'),
                      required: true,
                    ),
                    const SizedBox(height: 8),
                    _FormField(
                      controller: _titleController,
                      hint: t(tk: 'Habaryň sözbaşysy', ru: 'Заголовок сообщения', en: 'Message title'),
                      maxLength: 80,
                      onChanged: () => setState(() {}),
                    ),
                    const SizedBox(height: 18),
                  ],
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
                    maxLength: 300,
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
                              color: tokens.accent.withValues(alpha: .1),
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
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: tokens.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          AppIcon(
                            Icons.expand_more,
                            color: tokens.textSecondary,
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
                label: _pushChannel
                    ? t(tk: 'Push iber', ru: 'Отправить push', en: 'Send push')
                    : t(tk: 'SMS iber', ru: 'Отправить SMS', en: 'Send SMS'),
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
