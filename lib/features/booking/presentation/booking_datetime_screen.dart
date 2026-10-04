part of '../../../app/komekci_app.dart';

// ── Step 2 — date & time ────────────────────────────────────────────────────

class BookingDateTimeScreen extends StatefulWidget {
  const BookingDateTimeScreen({
    super.key,
    required this.service,
    required this.master,
  });
  final ApiService service;
  final MasterBrief master;

  @override
  State<BookingDateTimeScreen> createState() => _BookingDateTimeScreenState();
}

class _BookingDateTimeScreenState extends State<BookingDateTimeScreen> {
  /// Days offered in the strip. The API answers up to 31 days at once.
  static const _horizonDays = 14;

  late final DateTime _today = appToday();
  late DateTime _selectedDate = _today;
  DateTime? _selectedSlot;
  Availability? _availability;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _availability = null;
      _error = null;
    });
    try {
      final result = await context.read<ClientRepository>().availability(
        widget.master.id,
        serviceId: widget.service.id,
        from: _today,
        to: _today.add(const Duration(days: _horizonDays - 1)),
      );
      if (!mounted) return;
      setState(() {
        _availability = result;
        // Start on the first day that actually has room.
        for (var i = 0; i < _horizonDays; i++) {
          final day = _today.add(Duration(days: i));
          if (_slotsFor(day).isNotEmpty) {
            _selectedDate = day;
            break;
          }
        }
      });
    } catch (error) {
      if (mounted) setState(() => _error = error);
    }
  }

  /// Free start times on [day], as given by the server (`HH:mm`).
  List<DateTime> _slotsFor(DateTime day) {
    final raw = _availability?.dates[formatApiDate(day)] ?? const <String>[];
    return [
      for (final s in raw)
        if (RegExp(r'^\d{1,2}:\d{2}').hasMatch(s))
          DateTime(
            day.year,
            day.month,
            day.day,
            int.parse(s.split(':')[0]),
            int.parse(s.split(':')[1]),
          ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final language = context.watch<LanguageProvider>().language;
    String t({required String tk, required String ru, required String en}) =>
        pickTr(language, tk: tk, ru: ru, en: en);
    final tokens = context.appTokens;
    final weekdayLabels = switch (language) {
      AppLanguage.tk => _weekdaysTk,
      AppLanguage.ru => _weekdaysRu,
      AppLanguage.en => weekdaysEn,
    };
    final monthLabels = switch (language) {
      AppLanguage.tk => _monthsFullTk,
      AppLanguage.ru => _monthsFullRu,
      AppLanguage.en => _monthsEn,
    };
    final availability = _availability;
    final paused = availability != null && !availability.acceptingBookings;
    final days = List.generate(14, (i) => _today.add(Duration(days: i)));
    final slots = _slotsFor(_selectedDate);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const AppIcon(Icons.arrow_back),
          onPressed: () => Navigator.maybePop(context),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 18),
              child: _WizardSteps(
                current: 2,
                labels: [
                  t(tk: 'Hyzmat', ru: 'Услуга', en: 'Service'),
                  t(tk: 'Wagt', ru: 'Время', en: 'Time'),
                  t(tk: 'Tassykla', ru: 'Подтв.', en: 'Confirm'),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 24),
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      t(
                        tk: 'Tarih we wagt saýlaň',
                        ru: 'Выберите дату и время',
                        en: 'Pick a date & time',
                      ),
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      '${monthLabels[_selectedDate.month - 1]} ${_selectedDate.year}',
                      style: TextStyle(color: tokens.textSecondary),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 74,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      itemCount: days.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 8),
                      itemBuilder: (_, index) {
                        final day = days[index];
                        final open = _slotsFor(day).isNotEmpty;
                        final selected =
                            day.year == _selectedDate.year &&
                            day.month == _selectedDate.month &&
                            day.day == _selectedDate.day;
                        return _DateChip(
                          weekday: weekdayLabels[day.weekday - 1],
                          dayNumber: day.day,
                          selected: selected,
                          enabled: open,
                          onTap: open
                              ? () => setState(() {
                                  _selectedDate = day;
                                  _selectedSlot = null;
                                })
                              : null,
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 22),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      t(
                        tk: 'Elýeterli wagtlar',
                        ru: 'Доступное время',
                        en: 'Available times',
                      ),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: _error != null
                        ? RetryErrorState(
                            title: t(tk: 'Ýalňyşlyk', ru: 'Ошибка', en: 'Something went wrong'),
                            text: apiErrorMessage(_error!, language),
                            retryLabel: t(tk: 'Täzeden synanyş', ru: 'Повторить', en: 'Try again'),
                            onRetry: _load,
                          )
                        : availability == null
                        ? const Padding(
                            padding: EdgeInsets.symmetric(vertical: 30),
                            child: Center(child: CircularProgressIndicator()),
                          )
                        : paused
                        ? EmptyState(
                            icon: Icons.event_busy_outlined,
                            title: t(
                              tk: 'Ýazgy wagtlaýyn ýapyk',
                              ru: 'Запись временно закрыта',
                              en: 'Bookings are paused',
                            ),
                            text: availability.message ??
                                t(
                                  tk: 'Usta häzirlikçe täze ýazgylary kabul etmeýär.',
                                  ru: 'Мастер временно не принимает новые записи.',
                                  en: 'This master is not accepting new bookings right now.',
                                ),
                          )
                        : slots.isEmpty
                        ? EmptyState(
                            icon: Icons.schedule_outlined,
                            title: t(
                              tk: 'Boş wagt ýok',
                              ru: 'Свободного времени нет',
                              en: 'No free slots',
                            ),
                            text: t(
                              tk: 'Bu gün üçin boş wagt ýok. Başga gün synanyşyň.',
                              ru: 'На этот день свободного времени нет. Попробуйте другой день.',
                              en: 'There is no free time on this day. Try another day.',
                            ),
                          )
                        : Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: slots.map((slot) {
                              final selected = _selectedSlot == slot;
                              return InkWell(
                                onTap: () =>
                                    setState(() => _selectedSlot = slot),
                                borderRadius: BorderRadius.circular(14),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: selected
                                        ? tokens.textPrimary
                                        : tokens.surface,
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: selected
                                          ? tokens.textPrimary
                                          : tokens.border,
                                    ),
                                  ),
                                  child: Text(
                                    '${slot.hour.toString().padLeft(2, '0')}:${slot.minute.toString().padLeft(2, '0')}',
                                    style: TextStyle(
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w600,
                                      color: selected
                                          ? tokens.surface
                                          : tokens.textPrimary,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 10, 24, 14),
          child: SizedBox(
            height: 56,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: tokens.textPrimary,
                shape: const StadiumBorder(),
              ),
              onPressed: _selectedSlot == null
                  ? null
                  : () => Navigator.push(
                      context,
                      pageRoute(
                        BookingConfirmScreen(
                          service: widget.service,
                          master: widget.master,
                          startsAt: _selectedSlot!,
                        ),
                      ),
                    ),
              child: Text(
                t(tk: 'Dowam et', ru: 'Далее', en: 'Continue'),
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DateChip extends StatelessWidget {
  const _DateChip({
    required this.weekday,
    required this.dayNumber,
    required this.selected,
    required this.enabled,
    required this.onTap,
  });
  final String weekday;
  final int dayNumber;
  final bool selected;
  final bool enabled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    return Opacity(
      opacity: enabled ? 1 : .35,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 52,
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? t.textPrimary : t.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: selected ? t.textPrimary : t.border),
          ),
          child: Column(
            children: [
              Text(
                weekday,
                style: TextStyle(
                  fontSize: 11,
                  color: selected
                      ? t.surface.withValues(alpha: .7)
                      : t.textSecondary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '$dayNumber',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: selected ? t.surface : t.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

