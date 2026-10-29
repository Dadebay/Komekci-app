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

  Future<void> _pickService(List<SalonService> services) =>
      _showServicePicker(services, update: setState);

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
                    _NewSlotHeader(language: language),
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
                        children: [
                          _NewSlotTimeCard(start: widget.start, selectedEnd: selectedEnd, language: language),
                          const SizedBox(height: 24),
                          ..._customerFields(language: language, update: setState),
                          ..._serviceFields(language: language, services: services),
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
                        child: MasterActionButton(
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
