part of '../../../app/komekci_app.dart';

class SpecialDaysScreen extends StatefulWidget {
  const SpecialDaysScreen({super.key});

  @override
  State<SpecialDaysScreen> createState() => _SpecialDaysScreenState();
}

class _SpecialDaysScreenState extends State<SpecialDaysScreen> {
  bool _busy = false;

  Future<void> _addDay() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now.subtract(const Duration(days: 1)),
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked == null || !mounted) return;
    final schedule = context.read<ScheduleProvider>();
    final bookings = context.read<BookingProvider>();
    final exists = schedule.daysOff.any(
      (o) =>
          o.date.year == picked.year &&
          o.date.month == picked.month &&
          o.date.day == picked.day,
    );
    if (exists) return;

    setState(() => _busy = true);
    // Closing a day that already has bookings on it needs the master's
    // explicit acknowledgement — those appointments don't disappear on
    // their own, so surface them before the day is marked closed.
    try {
      await bookings.ensureLoaded(picked);
    } catch (_) {}
    if (!mounted) return;
    final affected = bookings
        .onDay(picked)
        .where((a) => a.status == AppointmentStatus.expected || a.status == AppointmentStatus.arrived)
        .toList();
    if (affected.isNotEmpty) {
      final proceed = await _showAffectedAppointmentsDialog(
        context,
        dateLabel: formatDate(picked),
        count: affected.length,
      );
      if (!mounted) return;
      if (proceed == null) {
        setState(() => _busy = false);
        return;
      }
      if (!proceed) {
        setState(() => _busy = false);
        Navigator.push(context, pageRoute(ScheduleScreen(initialDate: picked)));
        return;
      }
    }
    await runApi(context, () => schedule.addDayOff(picked));
    if (mounted) setState(() => _busy = false);
  }

  /// A one-off day with different opening hours (`custom_hours`).
  Future<void> _addCustomHours() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now.subtract(const Duration(days: 1)),
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked == null || !mounted) return;
    final language = context.read<LanguageProvider>().language;
    final range = await _pickTimeRange(
      context,
      language: language,
      title: pickTr(
        language,
        tk: 'Şol gün üçin iş wagty',
        ru: 'Часы работы в этот день',
        en: 'Working hours for that day',
      ),
      start: '10:00',
      end: '16:00',
    );
    if (range == null || !mounted) return;
    final schedule = context.read<ScheduleProvider>();
    setState(() => _busy = true);
    await runApi(context, () => schedule.addCustomHours(picked, range.$1, range.$2));
    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    final language = context.watch<LanguageProvider>().language;
    String t({required String tk, required String ru, required String en}) =>
        pickTr(language, tk: tk, ru: ru, en: en);
    final tokens = context.appTokens;
    final daysOff = context.watch<ScheduleProvider>().overrides;
    return Scaffold(
      backgroundColor: tokens.surface,
      appBar: CabinetAppBar(
        title: t(tk: 'Aýratyn günler', ru: 'Особые дни', en: 'Special days'),
        action: _HelpIconButton(
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
                    icon: Icons.event_busy_outlined,
                    text: t(
                      tk: 'Bu günlerde hyzmat kabul edilmez. Islendik senäni goşup ýa-da aýryp bilersiňiz.',
                      ru: 'В эти дни запись недоступна. Добавляйте или удаляйте любые даты.',
                      en: 'Bookings are not accepted on these days. You can add or remove any date.',
                    ),
                  ),
                  const SizedBox(height: 18),
                  if (daysOff.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 30),
                      child: Center(
                        child: Text(
                          t(
                            tk: 'Entek aýratyn gün goşulmady.',
                            ru: 'Особые дни ещё не добавлены.',
                            en: 'No special days added yet.',
                          ),
                          style: const TextStyle(
                            color: Colors.black45,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    )
                  else
                    ...daysOff.map(
                      (o) => Container(
                        margin: const EdgeInsets.only(bottom: 10),
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
                            AppIcon(
                              o.type == OverrideType.dayOff
                                  ? Icons.event_busy_outlined
                                  : Icons.schedule_outlined,
                              color: tokens.accent,
                              size: 18,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                o.type == OverrideType.dayOff
                                    ? formatDate(o.date)
                                    : '${formatDate(o.date)} · ${o.startTime}–${o.endTime}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () => runApi(
                                context,
                                () => context.read<ScheduleProvider>().removeOverride(o.id),
                              ),
                              child: const AppIcon(
                                Icons.close,
                                color: Colors.black38,
                                size: 18,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 4),
                  GestureDetector(
                    onTap: _busy ? null : _addCustomHours,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: tokens.border),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AppIcon(Icons.schedule_outlined, color: tokens.textPrimary, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            t(
                              tk: 'Aýratyn iş wagty goş',
                              ru: 'Добавить особые часы',
                              en: 'Add special hours',
                            ),
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: _busy ? null : _addDay,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: tokens.border),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AppIcon(
                            Icons.add,
                            color: tokens.textPrimary,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            t(
                              tk: 'Gün goş',
                              ru: 'Добавить день',
                              en: 'Add day',
                            ),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
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
              child: _MasterActionButton(
                label: t(tk: 'Taýýar', ru: 'Готово', en: 'Done'),
                enabled: true,
                leading: Icons.check,
                onTap: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
