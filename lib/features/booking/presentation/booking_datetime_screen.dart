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

  /// Free start times on [day], as given by the server (`HH:mm`), shown on
  /// half-hour boundaries in the booking picker.
  List<DateTime> _slotsFor(DateTime day) {
    final raw = _availability?.dates[formatApiDate(day)] ?? const <String>[];
    return [
      for (final s in raw)
        if (RegExp(r'^\d{1,2}:\d{2}').hasMatch(s) &&
            int.parse(s.split(':')[1]) % 30 == 0)
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

    // Free times split into parts of the day, so a long list stays scannable.
    final groups = <(String, List<DateTime>)>[
      (t(tk: 'Irden', ru: 'Утро', en: 'Morning'), [for (final x in slots) if (x.hour < 12) x]),
      (t(tk: 'Günorta', ru: 'День', en: 'Afternoon'), [for (final x in slots) if (x.hour >= 12 && x.hour < 17) x]),
      (t(tk: 'Agşam', ru: 'Вечер', en: 'Evening'), [for (final x in slots) if (x.hour >= 17) x]),
    ];
    final slotWidth = (MediaQuery.sizeOf(context).width - 40 - 30) / 4;
    final currency = context.watch<AppSettingsProvider>().currencyLabel(language);
    String clock(DateTime d) => '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

    return Scaffold(
      backgroundColor: tokens.surface,
      body: SafeArea(
        child: Column(
          children: [
            _BookingHeader(
              master: widget.master,
              current: 2,
              labels: [
                t(tk: 'Hyzmat', ru: 'Услуга', en: 'Service'),
                t(tk: 'Wagt', ru: 'Время', en: 'Time'),
                t(tk: 'Tassykla', ru: 'Подтв.', en: 'Confirm'),
              ],
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 24),
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _BookingTitle(
                      title: t(tk: 'Sene we wagt saýlaň', ru: 'Выберите дату и время', en: 'Pick a date & time'),
                      subtitle: '${widget.service.name} · ${widget.service.durationMin} ${t(tk: 'min', ru: 'мин', en: 'min')} · ${formatMoney(widget.service.price)} $currency',
                    ),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        AppIcon(Icons.calendar_today_outlined, size: 15, color: tokens.accent),
                        const SizedBox(width: 6),
                        Text(
                          '${monthLabels[_selectedDate.month - 1]} ${_selectedDate.year}',
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: max(100.0, MediaQuery.textScalerOf(context).scale(100)),
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: days.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 10),
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
                          isToday: day == _today,
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
                  const SizedBox(height: 26),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
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
                            title: t(tk: 'Ýazgy wagtlaýyn ýapyk', ru: 'Запись временно закрыта', en: 'Bookings are paused'),
                            text: availability.message ??
                                t(
                                  tk: 'Master häzirlikçe täze ýazgylary kabul etmeýär.',
                                  ru: 'Мастер временно не принимает новые записи.',
                                  en: 'This master is not accepting new bookings right now.',
                                ),
                          )
                        : slots.isEmpty
                        ? EmptyState(
                            icon: Icons.schedule_outlined,
                            title: t(tk: 'Boş wagt ýok', ru: 'Свободного времени нет', en: 'No free slots'),
                            text: t(
                              tk: 'Bu gün üçin boş wagt ýok. Başga gün synanyşyň.',
                              ru: 'На этот день свободного времени нет. Попробуйте другой день.',
                              en: 'There is no free time on this day. Try another day.',
                            ),
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              for (final group in groups)
                                if (group.$2.isNotEmpty) ...[
                                  Row(
                                    children: [
                                      Text(group.$1, style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700)),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                        decoration: BoxDecoration(color: tokens.surfaceElevated, borderRadius: BorderRadius.circular(8)),
                                        child: Text(
                                          '${group.$2.length}',
                                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: tokens.textSecondary),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Wrap(
                                    spacing: 10,
                                    runSpacing: 10,
                                    children: [
                                      for (final slot in group.$2)
                                        GestureDetector(
                                          onTap: () => setState(() => _selectedSlot = slot),
                                          child: AnimatedContainer(
                                            duration: const Duration(milliseconds: 180),
                                            width: slotWidth,
                                            padding: const EdgeInsets.symmetric(vertical: 12),
                                            alignment: Alignment.center,
                                            decoration: BoxDecoration(
                                              color: _selectedSlot == slot ? tokens.textPrimary : tokens.surface,
                                              borderRadius: BorderRadius.circular(14),
                                              border: Border.all(color: _selectedSlot == slot ? tokens.textPrimary : tokens.border),
                                              boxShadow: _selectedSlot == slot
                                                  ? [BoxShadow(color: tokens.textPrimary.withValues(alpha: .22), blurRadius: 12, offset: const Offset(0, 5))]
                                                  : null,
                                            ),
                                            child: Text(
                                              clock(slot),
                                              style: TextStyle(
                                                fontSize: 13.5,
                                                fontWeight: FontWeight.w700,
                                                color: _selectedSlot == slot ? tokens.surface : tokens.textPrimary,
                                              ),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 22),
                                ],
                            ],
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _BookingBottomBar(
        caption: t(tk: 'Saýlanan wagt', ru: 'Выбранное время', en: 'Selected time'),
        value: _selectedSlot == null ? '—' : '${formatDate(_selectedSlot!)} · ${clock(_selectedSlot!)}',
        label: t(tk: 'Dowam et', ru: 'Далее', en: 'Continue'),
        onPressed: _selectedSlot == null
            ? null
            : () => Navigator.push(
                context,
                pageRoute(BookingConfirmScreen(service: widget.service, master: widget.master, startsAt: _selectedSlot!)),
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
    this.isToday = false,
  });
  final String weekday;
  final int dayNumber;
  final bool selected;
  final bool enabled;
  final bool isToday;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    return Opacity(
      opacity: enabled ? 1 : .38,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: 58,
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? t.textPrimary : t.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: selected ? t.textPrimary : t.border),
            boxShadow: selected ? [BoxShadow(color: t.textPrimary.withValues(alpha: .22), blurRadius: 12, offset: const Offset(0, 5))] : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                weekday,
                style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: selected ? t.surface.withValues(alpha: .7) : t.textSecondary),
              ),
              const SizedBox(height: 5),
              Text(
                '$dayNumber',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: selected ? t.surface : t.textPrimary),
              ),
              const SizedBox(height: 5),
              Container(
                width: 5,
                height: 5,
                decoration: BoxDecoration(shape: BoxShape.circle, color: isToday ? t.accent : Colors.transparent),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
