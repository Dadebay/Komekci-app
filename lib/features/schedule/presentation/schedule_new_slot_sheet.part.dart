part of '../../../app/komekci_app.dart';

enum _NewSlotCustomerMode { existing, brandNew }

/// The "Täze ýazgy goşmak" sheet opened from a free-time row: pick or add a
/// customer, pick a service, add an optional note, and book it into the slot.
class _NewSlotAppointmentSheet extends StatefulWidget {
  const _NewSlotAppointmentSheet({required this.start, required this.end});
  final DateTime start;
  final DateTime end;

  static Future<void> show(
    BuildContext context, {
    required DateTime start,
    required DateTime end,
  }) => showModalBottomSheet(
    context: context,
    backgroundColor: context.appTokens.surface,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => _NewSlotAppointmentSheet(start: start, end: end),
  );

  @override
  State<_NewSlotAppointmentSheet> createState() =>
      _NewSlotAppointmentSheetState();
}

class _NewSlotAppointmentSheetState extends State<_NewSlotAppointmentSheet> {
  _NewSlotCustomerMode? _mode;
  Customer? _selectedCustomer;
  final _newNameController = TextEditingController();
  final _newPhoneController = TextEditingController();
  SalonService? _selectedService;
  final _noteController = TextEditingController();
  bool _showErrors = false;

  @override
  void dispose() {
    _newNameController.dispose();
    _newPhoneController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  bool get _newCustomerOk =>
      _newNameController.text.trim().isNotEmpty &&
      _newPhoneController.text.trim().length >= 8;
  bool get _customerOk => switch (_mode) {
    _NewSlotCustomerMode.existing => _selectedCustomer != null,
    _NewSlotCustomerMode.brandNew => _newCustomerOk,
    null => false,
  };
  bool get _complete => _customerOk && _selectedService != null;

  Future<void> _pickExistingCustomer() async {
    final language = context.read<LanguageProvider>().language;
    final customers = context.read<CustomerProvider>().customers;
    final picked = await showModalBottomSheet<Customer>(
      context: context,
      backgroundColor: context.appTokens.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) =>
          _CustomerPickerSheet(customers: customers, language: language),
    );
    if (picked != null) {
      setState(() {
        _selectedCustomer = picked;
        _mode = _NewSlotCustomerMode.existing;
      });
    }
  }

  Future<void> _pickService(List<SalonService> services) async {
    final language = context.read<LanguageProvider>().language;
    String t({required String tk, required String ru, required String en}) =>
        pickTr(language, tk: tk, ru: ru, en: en);
    final tokens = context.appTokens;
    final picked = await showModalBottomSheet<SalonService>(
      context: context,
      backgroundColor: tokens.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: tokens.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                t(
                  tk: 'Hyzmat saýlaň',
                  ru: 'Выберите услугу',
                  en: 'Choose a service',
                ),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              if (services.isEmpty)
                EmptyState(
                  icon: Icons.content_cut,
                  title: t(
                    tk: 'Hyzmat ýok',
                    ru: 'Услуг нет',
                    en: 'No services',
                  ),
                  text: t(
                    tk: 'Ilki bilen hyzmat goşuň.',
                    ru: 'Сначала добавьте услугу.',
                    en: 'Add a service first.',
                  ),
                )
              else
                ...services.map(
                  (s) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      s.name,
                      style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      '${s.price} ${context.watch<AppSettingsProvider>().currencyLabel(language)}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                    trailing: _selectedService?.id == s.id
                        ? AppIcon(Icons.check, color: tokens.accent)
                        : null,
                    onTap: () => Navigator.pop(sheetContext, s),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
    if (picked != null) setState(() => _selectedService = picked);
  }

  bool _saving = false;

  Future<void> _save() async {
    if (!_complete) {
      setState(() => _showErrors = true);
      return;
    }
    if (_saving) return;
    final customers = context.read<CustomerProvider>();
    final bookings = context.read<BookingProvider>();
    final navigator = Navigator.of(context);
    final String name;
    final String? phone;
    if (_mode == _NewSlotCustomerMode.existing) {
      name = _selectedCustomer!.name;
      phone = _selectedCustomer!.phone.isEmpty ? null : _selectedCustomer!.phone;
    } else {
      name = _newNameController.text.trim();
      phone = toApiPhone(_newPhoneController.text);
    }
    final service = _selectedService!;
    setState(() => _saving = true);
    final ok = await runApi(context, () async {
      await bookings.create(
        serviceId: int.parse(service.id),
        clientName: name,
        phone: phone,
        startsAt: widget.start,
      );
    });
    if (!mounted) return;
    if (!ok) {
      setState(() => _saving = false);
      return;
    }
    // A new client only exists on the server from now on.
    customers.load();
    navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    final language = context.watch<LanguageProvider>().language;
    final tk = language == AppLanguage.tk;
    String t({required String tk, required String ru, required String en}) =>
        pickTr(language, tk: tk, ru: ru, en: en);
    final tokens = context.appTokens;
    final services = context.watch<ServiceProvider>().services;
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          12,
          20,
          MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: tokens.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      t(
                        tk: 'Täze ýazgy goşmak',
                        ru: 'Добавить новую запись',
                        en: 'Add new booking',
                      ),
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const AppIcon(
                      Icons.close,
                      size: 20,
                      color: Colors.black45,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: freeSlotBg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: _freeSlotColor),
                ),
                child: Row(
                  children: [
                    const AppIcon(
                      Icons.schedule_outlined,
                      size: 16,
                      color: freeSlotColorDark,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${formatTime(TimeOfDay.fromDateTime(widget.start))} - ${formatTime(TimeOfDay.fromDateTime(widget.end))} • ${formatDate(widget.start)}',
                            style: const TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: freeSlotColorDark,
                            ),
                          ),
                          Text(
                            t(tk: 'Boş wagt', ru: 'Свободно', en: 'Free'),
                            style: const TextStyle(
                              fontSize: 11,
                              color: freeSlotColorDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              Text(
                t(
                  tk: '1. Müşderi saýlaň',
                  ru: '1. Выберите клиента',
                  en: '1. Choose a customer',
                ),
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              _ChoiceCard(
                icon: Icons.people_outline,
                title: t(
                  tk: 'Müşderilerden saýlaň',
                  ru: 'Выбрать из клиентов',
                  en: 'Choose from customers',
                ),
                subtitle:
                    _mode == _NewSlotCustomerMode.existing &&
                        _selectedCustomer != null
                    ? _selectedCustomer!.name
                    : t(
                        tk: 'Bar bolan müşderini saýlaň',
                        ru: 'Выберите существующего клиента',
                        en: 'Pick an existing customer',
                      ),
                selected: _mode == _NewSlotCustomerMode.existing,
                onTap: _pickExistingCustomer,
              ),
              const SizedBox(height: 8),
              _ChoiceCard(
                icon: Icons.person_add_alt_1,
                title: t(
                  tk: 'Täze müşderi goşuň',
                  ru: 'Добавить нового клиента',
                  en: 'Add a new customer',
                ),
                subtitle: t(
                  tk: 'Täze müşderini el bilen goşuň',
                  ru: 'Добавьте нового клиента вручную',
                  en: 'Add a new customer manually',
                ),
                selected: _mode == _NewSlotCustomerMode.brandNew,
                onTap: () =>
                    setState(() => _mode = _NewSlotCustomerMode.brandNew),
              ),
              if (_mode == _NewSlotCustomerMode.brandNew) ...[
                const SizedBox(height: 12),
                _FormField(
                  controller: _newNameController,
                  hint: t(
                    tk: 'Ady we familiýasy',
                    ru: 'Имя и фамилия',
                    en: 'First and last name',
                  ),
                  invalid:
                      _showErrors && _newNameController.text.trim().isEmpty,
                  onChanged: () => setState(() {}),
                ),
                const SizedBox(height: 10),
                _FormField(
                  controller: _newPhoneController,
                  hint: '+993 65 123456',
                  keyboardType: TextInputType.phone,
                  invalid:
                      _showErrors && _newPhoneController.text.trim().length < 8,
                  onChanged: () => setState(() {}),
                ),
              ],
              if (_showErrors && !_customerOk) _ErrorText(tk: tk),
              const SizedBox(height: 22),
              Text(
                t(
                  tk: '2. Hyzmat saýlaň',
                  ru: '2. Выберите услугу',
                  en: '2. Choose a service',
                ),
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () => _pickService(services),
                child: Container(
                  height: 52,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: tokens.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: _showErrors && _selectedService == null
                          ? const Color(0xffC0392B)
                          : tokens.border,
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          _selectedService?.name ??
                              t(
                                tk: 'Hyzmat saýlaň',
                                ru: 'Выберите услугу',
                                en: 'Choose a service',
                              ),
                          style: TextStyle(
                            fontSize: 14,
                            color: _selectedService == null
                                ? Colors.black38
                                : tokens.textPrimary,
                            fontWeight: _selectedService == null
                                ? FontWeight.w400
                                : FontWeight.w600,
                          ),
                        ),
                      ),
                      const AppIcon(
                        Icons.expand_more,
                        size: 18,
                        color: Colors.black45,
                      ),
                    ],
                  ),
                ),
              ),
              if (_showErrors && _selectedService == null) _ErrorText(tk: tk),
              const SizedBox(height: 22),
              Text(
                t(
                  tk: '3. Bellik (islege görä)',
                  ru: '3. Заметка (необязательно)',
                  en: '3. Note (optional)',
                ),
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              _FormField(
                controller: _noteController,
                hint: t(
                  tk: 'Bellik goşuň...',
                  ru: 'Добавьте заметку...',
                  en: 'Add a note...',
                ),
                maxLines: 3,
                maxLength: 200,
                onChanged: () => setState(() {}),
              ),
              const SizedBox(height: 12),
              _MasterActionButton(
                label: t(
                  tk: 'Ýazgyny sakla',
                  ru: 'Сохранить запись',
                  en: 'Save booking',
                ),
                enabled: _complete,
                leading: Icons.save_outlined,
                onTap: _save,
              ),
              const SizedBox(height: 6),
              Center(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    t(tk: 'Ýatyr', ru: 'Отмена', en: 'Cancel'),
                    style: const TextStyle(
                      color: Colors.black45,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
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
