part of '../../../app/komekci_app.dart';

bool _canMessageCustomer(Customer customer, {required bool forPush}) => forPush
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

  List<Customer> get _eligibleClients => context
      .read<CustomerProvider>()
      .customers
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
        title: AppStrings.cabinetSendMessage.select(language),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                children: [
                  if (customerProvider.loading &&
                      customerProvider.customers.isEmpty) ...[
                    const SizedBox(height: 16),
                    const Center(child: CircularProgressIndicator()),
                  ] else if (customerProvider.error != null &&
                      customerProvider.customers.isEmpty) ...[
                    const SizedBox(height: 10),
                    RetryErrorState(
                      title: AppStrings.cabinetCouldNotLoadClients.select(
                        language,
                      ),
                      text: AppStrings.cabinetPleaseTryAgain.select(language),
                      retryLabel: AppStrings.profileTryAgain.select(language),
                      onRetry: customerProvider.load,
                    ),
                  ] else if (_eligibleClients.isEmpty) ...[
                    const SizedBox(height: 10),
                    _InfoBanner(
                      icon: Icons.info_outline,
                      text: customerProvider.customers.isEmpty
                          ? _pushChannel
                                ? AppStrings.cabinetTheClientListIsEmpty.select(
                                    language,
                                  )
                                : AppStrings.cabinetTheClientListIsEmpty2
                                      .select(language)
                          : _pushChannel
                          ? AppStrings.cabinetClientsAreListedButTheir.select(
                              language,
                            )
                          : AppStrings.cabinetTheseClientsHaveNoPhone.select(
                              language,
                            ),
                    ),
                  ],
                  if (_recipients.length > 50) ...[
                    const SizedBox(height: 10),
                    _InfoBanner(
                      icon: Icons.info_outline,
                      text: AppStrings.cabinetChooseUpTo50Clients.select(
                        language,
                      ),
                    ),
                  ],
                  _MessageAudienceOptions(
                    language: language,
                    selectedAudience: _audience,
                    subtitle: (index) => _audienceSubtitle(language, index),
                    onSelect: (index) =>
                        _selectAudience(index, update: setState),
                  ),
                  if (_pushChannel) ...[
                    _FieldLabel(
                      text: AppStrings.cabinetTitle.select(language),
                      required: true,
                    ),
                    const SizedBox(height: 8),
                    _FormField(
                      controller: _titleController,
                      hint: AppStrings.cabinetMessageTitle.select(language),
                      maxLength: 80,
                      onChanged: () => setState(() {}),
                    ),
                    const SizedBox(height: 18),
                  ],
                  _FieldLabel(
                    text: AppStrings.cabinetMessageText.select(language),
                    required: true,
                  ),
                  const SizedBox(height: 8),
                  _FormField(
                    controller: _messageController,
                    hint: AppStrings.cabinetWriteYourMessage.select(language),
                    maxLines: 5,
                    maxLength: 300,
                    onChanged: () => setState(() {}),
                  ),
                  const SizedBox(height: 18),
                  _FieldLabel(
                    text: AppStrings.cabinetDeliveryMethod.select(language),
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
                                      ? AppStrings.cabinetPushNotification
                                            .select(language)
                                      : 'SMS',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
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
                    ? AppStrings.cabinetSendPush.select(language)
                    : AppStrings.cabinetSendSms.select(language),
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
