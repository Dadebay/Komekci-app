part of '../../../app/komekci_app.dart';

/// Books a new appointment for [customer] — picks a service from the real
/// catalogue, a date and a time, then records it and updates the customer's
/// next-visit date.
class NewAppointmentScreen extends StatefulWidget {
  const NewAppointmentScreen({super.key, required this.customer});
  final Customer customer;

  @override
  State<NewAppointmentScreen> createState() => _NewAppointmentScreenState();
}

class _NewAppointmentScreenState extends State<NewAppointmentScreen> {
  int? _serviceIndex;
  DateTime _date = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _time = const TimeOfDay(hour: 10, minute: 0);
  bool _showErrors = false;

  Future<void> _pickDateTime() async {
    final language = context.read<LanguageProvider>().language;
    final services = context.read<ServiceProvider>().services;
    final minutes = _serviceIndex != null
        ? services[_serviceIndex!].minutes
        : 30;
    final picked = await _pickAppointmentDateTime(
      context,
      language: language,
      initial: DateTime(
        _date.year,
        _date.month,
        _date.day,
        _time.hour,
        _time.minute,
      ),
      minutes: minutes,
      excludeId: '',
      bookingProvider: context.read<BookingProvider>(),
    );
    if (picked != null) {
      setState(() {
        _date = picked;
        _time = TimeOfDay.fromDateTime(picked);
      });
    }
  }

  bool _saving = false;

  Future<void> _confirm(List<SalonService> services) async {
    if (_serviceIndex == null) {
      setState(() => _showErrors = true);
      return;
    }
    if (_saving) return;
    final tk = context.read<LanguageProvider>().isTurkmen;
    final service = services[_serviceIndex!];
    final startsAt = DateTime(
      _date.year,
      _date.month,
      _date.day,
      _time.hour,
      _time.minute,
    );
    final bookings = context.read<BookingProvider>();
    final customers = context.read<CustomerProvider>();
    setState(() => _saving = true);
    final ok = await runApi(context, () async {
      await bookings.create(
        serviceId: int.parse(service.id),
        clientName: widget.customer.name,
        phone: widget.customer.phone.isEmpty ? null : widget.customer.phone,
        startsAt: startsAt,
      );
    });
    if (!mounted) return;
    if (!ok) {
      setState(() => _saving = false);
      return;
    }
    // A brand-new client only exists on the server from this moment.
    customers.load();
    await _finish(tk, service, startsAt);
  }

  Future<void> _finish(bool tk, SalonService service, DateTime startsAt) async {
    await _showInfoDialog(
      context,
      icon: Icons.check,
      title: tk ? 'Ýazgy döredildi' : 'Запись создана',
      message:
          '${widget.customer.name} — ${service.name}\n${formatDate(startsAt)} • ${formatTime(TimeOfDay.fromDateTime(startsAt))}',
      actionLabel: tk ? 'Bolýar' : 'Готово',
    );
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final tk = context.watch<LanguageProvider>().isTurkmen;
    final services = context.watch<ServiceProvider>().services;
    final selected = _serviceIndex != null && _serviceIndex! < services.length
        ? services[_serviceIndex!]
        : null;
    final tokens = context.appTokens;

    return Scaffold(
      backgroundColor: tokens.surface,
      appBar: CabinetAppBar(title: tk ? 'Täze ýazgy' : 'Новая запись'),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: tokens.surfaceElevated,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        _CustomerAvatar(customer: widget.customer, radius: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.customer.name,
                                style: const TextStyle(
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                displayPhone(widget.customer.phone),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: tokens.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),
                  _FieldLabel(
                    text: tk ? 'Hyzmat saýlaň' : 'Выберите услугу',
                    required: true,
                  ),
                  const SizedBox(height: 8),
                  if (services.isEmpty)
                    EmptyState(
                      icon: Icons.content_cut,
                      title: tk ? 'Hyzmat ýok' : 'Услуг нет',
                      text: tk
                          ? 'Ilki bilen hyzmat goşuň.'
                          : 'Сначала добавьте услугу.',
                    )
                  else
                    ...services.asMap().entries.map((entry) {
                      final rowSelected = _serviceIndex == entry.key;
                      return GestureDetector(
                        onTap: () => setState(() {
                          _serviceIndex = entry.key;
                          _showErrors = false;
                        }),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 13,
                          ),
                          decoration: BoxDecoration(
                            color: rowSelected
                                ? tokens.accent.withValues(alpha: .08)
                                : tokens.surfaceElevated,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: rowSelected
                                  ? tokens.accent
                                  : tokens.border,
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  entry.value.name,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              Text(
                                '${entry.value.price} ${context.watch<AppSettingsProvider>().currencyLabel(tk ? AppLanguage.tk : AppLanguage.ru)}',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: tokens.textSecondary,
                                ),
                              ),
                              const SizedBox(width: 10),
                              if (rowSelected)
                                AppIcon(
                                  Icons.check_circle,
                                  color: tokens.accent,
                                  size: 19,
                                )
                              else
                                const SizedBox(width: 19),
                            ],
                          ),
                        ),
                      );
                    }),
                  if (_showErrors && _serviceIndex == null) _ErrorText(tk: tk),
                  const SizedBox(height: 22),
                  _PickerField(
                    label: tk ? 'Sene we wagt' : 'Дата и время',
                    value: '${formatDate(_date)} • ${formatTime(_time)}',
                    icon: Icons.calendar_month_outlined,
                    onTap: _pickDateTime,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 6, 20, 14),
              child: _MasterActionButton(
                label: tk ? 'Ýazgyny tassykla' : 'Подтвердить запись',
                enabled: selected != null,
                leading: Icons.check,
                onTap: () => _confirm(services),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
