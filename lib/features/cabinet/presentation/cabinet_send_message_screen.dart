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

  @override
  Widget build(BuildContext context) {
    final language = context.watch<LanguageProvider>().language;
    final customerProvider = context.watch<CustomerProvider>();
    String t({required String tk, required String ru, required String en}) =>
        pickTr(language, tk: tk, ru: ru, en: en);
    final tokens = context.appTokens;
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
        action: AppHelpButton(
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
                  _MessageAudienceOptions(language: language, selectedAudience: _audience, subtitle: (index) => _audienceSubtitle(language, index), onSelect: (index) => _selectAudience(index, update: setState)),
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
                    onTap: () => _pickChannel(language, update: setState),
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
              child: MasterActionButton(
                label: _pushChannel
                    ? t(tk: 'Push iber', ru: 'Отправить push', en: 'Send push')
                    : t(tk: 'SMS iber', ru: 'Отправить SMS', en: 'Send SMS'),
                enabled: ready,
                leading: Icons.send_outlined,
                onTap: () => _confirmAndSend(language, update: setState),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
