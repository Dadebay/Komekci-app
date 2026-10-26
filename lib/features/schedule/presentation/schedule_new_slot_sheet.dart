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
    clipBehavior: Clip.antiAlias,
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
      _newPhoneController.text.replaceAll(RegExp(r'\D'), '').length == 8;
  bool get _customerOk => switch (_mode) {
    _NewSlotCustomerMode.existing => _selectedCustomer != null,
    _NewSlotCustomerMode.brandNew => _newCustomerOk,
    null => false,
  };
  bool get _complete => _customerOk && _selectedService != null;

  bool _serviceFits(SalonService service) =>
      appointmentFitsWorkingTime(
        context.read<ScheduleProvider>().schedule,
        widget.start,
        service.minutes,
      ) &&
      !context.read<BookingProvider>().hasConflict(
        widget.start,
        service.minutes,
      ) &&
      !context.read<ScheduleProvider>().hasClosedConflict(
        widget.start,
        service.minutes,
      );

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
                ...services.map((s) {
                  final fits = _serviceFits(s);
                  return ListTile(
                    enabled: fits,
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      s.name,
                      style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      fits
                          ? '${s.minutes} ${t(tk: 'min', ru: 'мин', en: 'min')} · ${s.price} ${context.read<AppSettingsProvider>().currencyLabel(language)}'
                          : t(
                              tk: 'Bu wagt hyzmat üçin ýeterlik däl',
                              ru: 'Недостаточно времени для услуги',
                              en: 'Not enough time for this service',
                            ),
                      style: TextStyle(
                        fontSize: 12,
                        color: fits ? tokens.textSecondary : tokens.danger,
                      ),
                    ),
                    trailing: _selectedService?.id == s.id
                        ? AppIcon(Icons.check, color: tokens.accent)
                        : null,
                    onTap: fits ? () => Navigator.pop(sheetContext, s) : null,
                  );
                }),
            ],
          ),
        ),
      ),
    );
    if (picked != null) setState(() => _selectedService = picked);
  }

  bool _saving = false;

  Future<void> _save(BuildContext sheetContext) async {
    if (!_complete) {
      setState(() => _showErrors = true);
      return;
    }
    if (_saving) return;
    if (!meetsBookingLeadTime(
      widget.start,
      DateTime.now(),
      context.read<ScheduleProvider>().schedule?.minLeadMin ?? 30,
    )) {
      final language = context.read<LanguageProvider>().language;
      AppToast.of(sheetContext).error(
        pickTr(
          language,
          tk: 'Bu wagt indi elýeterli däl. Başga wagt saýlaň.',
          ru: 'Это время уже недоступно. Выберите другое.',
          en: 'This time is no longer available. Choose another.',
        ),
      );
      return;
    }
    if (!_serviceFits(_selectedService!)) {
      final language = context.read<LanguageProvider>().language;
      AppToast.of(sheetContext).error(
        pickTr(
          language,
          tk: 'Bu hyzmat saýlanan wagta sygmaýar. Başga wagt ýa-da hyzmat saýlaň.',
          ru: 'Услуга не помещается в выбранное время. Выберите другое время или услугу.',
          en: 'This service does not fit the selected time. Choose another time or service.',
        ),
      );
      return;
    }
    final customers = context.read<CustomerProvider>();
    final bookings = context.read<BookingProvider>();
    final navigator = Navigator.of(context);
    final String name;
    final String? phone;
    if (_mode == _NewSlotCustomerMode.existing) {
      name = _selectedCustomer!.name;
      phone = _selectedCustomer!.phone.isEmpty
          ? null
          : _selectedCustomer!.phone;
    } else {
      name = _newNameController.text.trim();
      phone = toApiPhone(_newPhoneController.text);
    }
    final service = _selectedService!;
    setState(() => _saving = true);
    final ok = await runApi(sheetContext, () async {
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
    String t({required String tk, required String ru, required String en}) =>
        pickTr(language, tk: tk, ru: ru, en: en);
    final tokens = context.appTokens;
    final services = context.watch<ServiceProvider>().services;
    final selectedEnd = _selectedService == null
        ? widget.end
        : widget.start.add(Duration(minutes: _selectedService!.minutes));
    final keyboardInset = MediaQuery.viewInsetsOf(context).bottom;
    final sheetHeight =
        (MediaQuery.sizeOf(context).height - keyboardInset) * .88;
    return Padding(
      padding: EdgeInsets.only(bottom: keyboardInset),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: sheetHeight,
          // A snackbar on the page's Scaffold would sit behind this modal.
          child: ScaffoldMessenger(
            child: Scaffold(
              backgroundColor: tokens.surface,
              resizeToAvoidBottomInset: false,
              body: Builder(
                builder: (sheetContext) => Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                      child: Column(
                        children: [
                          Container(
                            width: 40,
                            height: 4,
                            decoration: BoxDecoration(
                              color: tokens.border,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  t(
                                    tk: 'Täze ýazgy goşmak',
                                    ru: 'Добавить запись',
                                    en: 'New booking',
                                  ),
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    color: tokens.textPrimary,
                                  ),
                                ),
                              ),
                              IconButton(
                                tooltip: t(
                                  tk: 'Ýap',
                                  ru: 'Закрыть',
                                  en: 'Close',
                                ),
                                onPressed: () => Navigator.pop(context),
                                icon: AppIcon(
                                  Icons.close,
                                  size: 20,
                                  color: tokens.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Divider(height: 1, color: tokens.border),
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
                        children: [
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: tokens.surfaceElevated,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: tokens.border),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: tokens.accent.withValues(alpha: .13),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: AppIcon(
                                    Icons.calendar_today_outlined,
                                    size: 20,
                                    color: tokens.accent,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        formatDate(widget.start),
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: tokens.textSecondary,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '${formatTime(TimeOfDay.fromDateTime(widget.start))}–${formatTime(TimeOfDay.fromDateTime(selectedEnd))}',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          color: tokens.textPrimary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 9,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: freeSlotSurface(tokens),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    t(tk: 'Boş', ru: 'Свободно', en: 'Free'),
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: freeSlotForeground(tokens),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          _NewBookingSectionTitle(
                            number: 1,
                            title: t(
                              tk: 'Müşderi saýlaň',
                              ru: 'Выберите клиента',
                              en: 'Choose a customer',
                            ),
                          ),
                          const SizedBox(height: 10),
                          if (_mode == _NewSlotCustomerMode.existing &&
                              _selectedCustomer != null)
                            Material(
                              color: tokens.surfaceElevated == tokens.surface
                                  ? tokens.surface
                                  : tokens.accent.withValues(alpha: .08),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                                side: BorderSide(
                                  color: tokens.accent,
                                  width: 1.5,
                                ),
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: InkWell(
                                onTap: _pickExistingCustomer,
                                child: Padding(
                                  padding: const EdgeInsets.all(14),
                                  child: Row(
                                    children: [
                                      _CustomerAvatar(
                                        customer: _selectedCustomer!,
                                        radius: 22,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              _selectedCustomer!.name,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w700,
                                                color: tokens.textPrimary,
                                              ),
                                            ),
                                            if (_selectedCustomer!
                                                .phone
                                                .isNotEmpty)
                                              Text(
                                                _selectedCustomer!.phone,
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: tokens.textSecondary,
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        t(
                                          tk: 'Üýtget',
                                          ru: 'Изменить',
                                          en: 'Change',
                                        ),
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: tokens.accent,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            )
                          else ...[
                            _ChoiceCard(
                              icon: Icons.people_outline,
                              title: t(
                                tk: 'Müşderilerden saýlaň',
                                ru: 'Выбрать из клиентов',
                                en: 'Choose from customers',
                              ),
                              subtitle: t(
                                tk: 'Bar bolan müşderini saýlaň',
                                ru: 'Выберите существующего клиента',
                                en: 'Pick an existing customer',
                              ),
                              selected: false,
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
                              onTap: () => setState(
                                () => _mode = _NewSlotCustomerMode.brandNew,
                              ),
                            ),
                          ],
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
                                  _showErrors &&
                                  _newNameController.text.trim().isEmpty,
                              onChanged: () => setState(() {}),
                            ),
                            const SizedBox(height: 10),
                            _FormField(
                              controller: _newPhoneController,
                              hint: '65 123456',
                              keyboardType: TextInputType.phone,
                              textInputAction: TextInputAction.done,
                              onSubmitted: (_) =>
                                  FocusScope.of(context).unfocus(),
                              prefixIcon: phonePrefix(context, fontSize: 14),
                              inputFormatters: [_PhoneNumberFormatter()],
                              invalid: _showErrors && !_newCustomerOk,
                              onChanged: () => setState(() {}),
                            ),
                          ],
                          if (_showErrors && !_customerOk) _ErrorText(language: language),
                          const SizedBox(height: 22),
                          _NewBookingSectionTitle(
                            number: 2,
                            title: t(
                              tk: 'Hyzmat saýlaň',
                              ru: 'Выберите услугу',
                              en: 'Choose a service',
                            ),
                          ),
                          const SizedBox(height: 10),
                          GestureDetector(
                            onTap: () => _pickService(services),
                            child: Container(
                              height: 66,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                              ),
                              decoration: BoxDecoration(
                                color: tokens.surfaceElevated,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: _showErrors && _selectedService == null
                                      ? tokens.danger
                                      : _selectedService == null
                                      ? tokens.border
                                      : tokens.accent,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 38,
                                    height: 38,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: tokens.accent.withValues(
                                        alpha: .12,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: AppIcon(
                                      Icons.content_cut,
                                      size: 18,
                                      color: tokens.accent,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _selectedService?.name ??
                                              t(
                                                tk: 'Hyzmat saýlaň',
                                                ru: 'Выберите услугу',
                                                en: 'Choose a service',
                                              ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: tokens.textPrimary,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        if (_selectedService != null) ...[
                                          const SizedBox(height: 2),
                                          Text(
                                            '${_selectedService!.minutes} ${t(tk: "min", ru: "мин", en: "min")} · ${_selectedService!.price} ${context.watch<AppSettingsProvider>().currencyLabel(language)}',
                                            style: TextStyle(
                                              fontSize: 11.5,
                                              color: tokens.textSecondary,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                  AppIcon(
                                    Icons.chevron_right,
                                    size: 18,
                                    color: tokens.textSecondary,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (_showErrors && _selectedService == null)
                            _ErrorText(language: language),
                          const SizedBox(height: 22),
                          _NewBookingSectionTitle(
                            number: 3,
                            title: t(
                              tk: 'Bellik (islege görä)',
                              ru: 'Заметка (необязательно)',
                              en: 'Note (optional)',
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
                            keyboardType: TextInputType.text,
                            textInputAction: TextInputAction.done,
                            onSubmitted: (_) =>
                                FocusScope.of(context).unfocus(),
                            onChanged: () => setState(() {}),
                          ),
                        ],
                      ),
                    ),
                    if (keyboardInset == 0)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                        child: _MasterActionButton(
                          label: t(
                            tk: 'Ýazgyny sakla',
                            ru: 'Сохранить запись',
                            en: 'Save booking',
                          ),
                          enabled:
                              _complete &&
                              !_saving &&
                              _serviceFits(_selectedService!),
                          leading: Icons.check,
                          onTap: () => _save(sheetContext),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NewBookingSectionTitle extends StatelessWidget {
  const _NewBookingSectionTitle({required this.number, required this.title});

  final int number;
  final String title;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: tokens.accent.withValues(alpha: .13),
            shape: BoxShape.circle,
          ),
          child: Text(
            '$number',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: tokens.accent,
            ),
          ),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: tokens.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}
