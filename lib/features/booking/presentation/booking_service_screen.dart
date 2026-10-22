part of '../../../app/komekci_app.dart';

// ── Step 1 — service selection ──────────────────────────────────────────────

class BookingPage extends StatefulWidget {
  const BookingPage({super.key, required this.master, this.preselectedServiceId});

  /// The connected master being booked.
  final MasterBrief master;
  final int? preselectedServiceId;

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  List<ApiService>? _services;
  bool _acceptingBookings = true;
  Object? _error;
  int? _selectedId;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _services = null;
      _error = null;
    });
    try {
      final result = await context.read<ClientRepository>().masterServices(widget.master.id);
      if (!mounted) return;
      setState(() {
        _services = [
          for (final s in result.services)
            if (!s.isHidden) s,
        ];
        _acceptingBookings = result.acceptingBookings;
        _selectedId = _services!.any((s) => s.id == widget.preselectedServiceId)
            ? widget.preselectedServiceId
            : null;
      });
    } catch (error) {
      if (mounted) setState(() => _error = error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final language = context.watch<LanguageProvider>().language;
    String t({required String tk, required String ru, required String en}) =>
        pickTr(language, tk: tk, ru: ru, en: en);
    final tokens = context.appTokens;
    final services = _services;
    ApiService? selected;
    for (final s in services ?? const <ApiService>[]) {
      if (s.id == _selectedId) selected = s;
    }

    return Scaffold(
      backgroundColor: tokens.surface,
      body: SafeArea(
        child: Column(
          children: [
            _BookingHeader(
              master: widget.master,
              current: 1,
              labels: [
                t(tk: 'Hyzmat', ru: 'Услуга', en: 'Service'),
                t(tk: 'Wagt', ru: 'Время', en: 'Time'),
                t(tk: 'Tassykla', ru: 'Подтв.', en: 'Confirm'),
              ],
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                children: [
                  _BookingTitle(
                    title: t(tk: 'Hyzmaty saýlaň', ru: 'Выберите услугу', en: 'Select a service'),
                    subtitle: services == null || services.isEmpty
                        ? null
                        : t(
                            tk: '${services.length} hyzmat elýeterli',
                            ru: 'Доступно услуг: ${services.length}',
                            en: '${services.length} services available',
                          ),
                  ),
                  const SizedBox(height: 18),
                  if (_error != null)
                    RetryErrorState(
                      title: t(tk: 'Ýalňyşlyk', ru: 'Ошибка', en: 'Something went wrong'),
                      text: apiErrorMessage(_error!, language),
                      retryLabel: t(tk: 'Täzeden synanyş', ru: 'Повторить', en: 'Try again'),
                      onRetry: _load,
                    )
                  else if (services == null)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (!_acceptingBookings)
                    EmptyState(
                      icon: Icons.event_busy_outlined,
                      title: t(
                        tk: 'Ýazgy wagtlaýyn ýapyk',
                        ru: 'Запись временно закрыта',
                        en: 'Bookings are paused',
                      ),
                      text: t(
                        tk: 'Master häzirlikçe täze ýazgylary kabul etmeýär.',
                        ru: 'Мастер временно не принимает новые записи.',
                        en: 'This master is not accepting new bookings right now.',
                      ),
                    )
                  else if (services.isEmpty)
                    EmptyState(
                      icon: Icons.content_cut,
                      title: t(
                        tk: 'Hyzmat ýok',
                        ru: 'Услуг нет',
                        en: 'No services',
                      ),
                      text: t(
                        tk: 'Bu master heniz hyzmat goşmady.',
                        ru: 'Мастер пока не добавил услуги.',
                        en: 'This master hasn’t added any services yet.',
                      ),
                    )
                  else
                    ...services.map(
                      (s) => _ServiceOption(
                        service: SalonService.fromApi(s),
                        selected: s.id == _selectedId,
                        tk: language == AppLanguage.tk,
                        onTap: () => setState(() => _selectedId = s.id),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _BookingBottomBar(
        caption: selected == null
            ? t(tk: 'Hyzmat saýlaň', ru: 'Выберите услугу', en: 'Pick a service')
            : '${selected.durationMin} ${t(tk: 'min', ru: 'мин', en: 'min')}',
        value: selected == null
            ? '—'
            : '${formatMoney(selected.price)} ${context.watch<AppSettingsProvider>().currencyLabel(language)}',
        label: t(tk: 'Dowam et', ru: 'Далее', en: 'Continue'),
        onPressed: selected == null
            ? null
            : () => Navigator.push(
                context,
                pageRoute(BookingDateTimeScreen(service: selected!, master: widget.master)),
              ),
      ),
    );
  }
}

class _ServiceOption extends StatelessWidget {
  const _ServiceOption({
    required this.service,
    required this.selected,
    required this.tk,
    required this.onTap,
  });
  final SalonService service;
  final bool selected;
  final bool tk;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    final language = context.watch<LanguageProvider>().language;
    final currency = context.watch<AppSettingsProvider>().currencyLabel(language);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(12),
        decoration: _bookingCardDecoration(t, selected: selected),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: ServiceThumb(service: service, size: 72),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          service.name,
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, height: 1.2),
                        ),
                      ),
                      const SizedBox(width: 8),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 180),
                        child: AppIcon(
                          selected ? Icons.check_circle : Icons.circle_outlined,
                          key: ValueKey(selected),
                          color: selected ? t.accent : t.disabled,
                          size: 22,
                        ),
                      ),
                    ],
                  ),
                  if (service.description.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      service.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 12, color: t.textSecondary, height: 1.3),
                    ),
                  ],
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                        decoration: BoxDecoration(color: t.surfaceElevated, borderRadius: BorderRadius.circular(10)),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AppIcon(Icons.schedule_outlined, size: 12, color: t.textSecondary),
                            const SizedBox(width: 4),
                            Text(
                              '${service.minutes} ${pickTr(language, tk: "min", ru: "мин", en: "min")}',
                              style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: t.textSecondary),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${service.price} $currency',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: t.accent),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
