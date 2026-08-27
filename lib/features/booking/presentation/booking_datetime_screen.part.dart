part of '../../../app/komekci_app.dart';

// ── Step 2 — date & time ────────────────────────────────────────────────────

class BookingDateTimeScreen extends StatefulWidget {
  const BookingDateTimeScreen({
    super.key,
    required this.service,
    required this.masterName,
  });
  final SalonService service;
  final String masterName;

  @override
  State<BookingDateTimeScreen> createState() => _BookingDateTimeScreenState();
}

class _BookingDateTimeScreenState extends State<BookingDateTimeScreen> {
  static final _today = DateTime(
    dashboardToday.$1,
    dashboardToday.$2,
    dashboardToday.$3,
  );
  late DateTime _selectedDate = _today;
  DateTime? _selectedSlot;

  List<DateTime> _slotsFor(DateTime day, BookingProvider bookingProvider) {
    if (!isSalonOpen(day)) return const [];
    final slots = <DateTime>[];
    final closing = DateTime(day.year, day.month, day.day, _bookingCloseHour);
    var cursor = DateTime(day.year, day.month, day.day, _bookingOpenHour);
    // The app's "today" is a fixed mock date, not the real device date, so
    // lead time only borrows the real clock's time-of-day — comparing full
    // DateTimes here would compare against the wrong calendar day entirely.
    final realNow = TimeOfDay.now();
    final leadCutoff = day == _today
        ? DateTime(
            day.year,
            day.month,
            day.day,
            realNow.hour,
            realNow.minute,
          ).add(const Duration(minutes: 30))
        : null;
    while (cursor
            .add(Duration(minutes: widget.service.minutes))
            .isBefore(closing) ||
        cursor
            .add(Duration(minutes: widget.service.minutes))
            .isAtSameMomentAs(closing)) {
      final tooSoon = leadCutoff != null && cursor.isBefore(leadCutoff);
      if (!tooSoon &&
          !bookingProvider.hasConflict(cursor, widget.service.minutes)) {
        slots.add(cursor);
      }
      cursor = cursor.add(const Duration(minutes: _bookingSlotStepMinutes));
    }
    return slots;
  }

  @override
  Widget build(BuildContext context) {
    final language = context.watch<LanguageProvider>().language;
    String t({required String tk, required String ru, required String en}) =>
        pickTr(language, tk: tk, ru: ru, en: en);
    final tokens = context.appTokens;
    final bookingProvider = context.watch<BookingProvider>();
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
    final days = List.generate(14, (i) => _today.add(Duration(days: i)));
    final slots = _slotsFor(_selectedDate, bookingProvider);

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
                        final open = isSalonOpen(day);
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
                    child: !isSalonOpen(_selectedDate)
                        ? EmptyState(
                            icon: Icons.event_busy_outlined,
                            title: t(
                              tk: 'Bu gün dynç güni',
                              ru: 'Выходной день',
                              en: 'Closed today',
                            ),
                            text: t(
                              tk: 'Başga bir gün saýlaň.',
                              ru: 'Выберите другой день.',
                              en: 'Please pick another day.',
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
                              tk: 'Bu gün üçin ähli wagtlar dolan. Başga gün synanyşyň.',
                              ru: 'Все слоты на этот день заняты. Попробуйте другой день.',
                              en: 'Every slot on this day is booked. Try another day.',
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
                          masterName: widget.masterName,
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

