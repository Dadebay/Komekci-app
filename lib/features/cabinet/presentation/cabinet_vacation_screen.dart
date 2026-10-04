part of '../../../app/komekci_app.dart';

/// Makes sure every month between [from] and [to] is in the calendar cache,
/// so "bookings in this period" is counted from real data.
Future<void> _loadMonthsBetween(
  BookingProvider bookings,
  DateTime from,
  DateTime to,
) async {
  var cursor = DateTime(from.year, from.month);
  final last = DateTime(to.year, to.month);
  while (!cursor.isAfter(last)) {
    await bookings.ensureLoaded(cursor);
    cursor = DateTime(cursor.year, cursor.month + 1);
  }
}

/// The master's vacations (`/me/vacations`): the list on top, and a form to
/// add another period. Each add/remove is sent to the server immediately.
class VacationScreen extends StatefulWidget {
  const VacationScreen({super.key});

  @override
  State<VacationScreen> createState() => _VacationScreenState();
}

class _VacationScreenState extends State<VacationScreen> {
  late DateTime _start = appToday();
  late DateTime _end = appToday().add(const Duration(days: 7));
  bool _saving = false;

  Future<void> _pickDate({required bool isStart}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? _start : _end,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 730)),
    );
    if (picked == null) return;
    setState(() {
      if (isStart) {
        _start = picked;
        if (_end.isBefore(_start)) _end = _start;
      } else {
        _end = picked;
        if (_start.isAfter(_end)) _start = _end;
      }
    });
  }

  Future<void> _add() async {
    if (_saving) return;
    final bookings = context.read<BookingProvider>();
    final schedule = context.read<ScheduleProvider>();
    setState(() => _saving = true);
    try {
      await _loadMonthsBetween(bookings, _start, _end);
    } catch (_) {
      // Counting affected bookings is advisory; the server decides.
    }
    if (!mounted) return;
    final rangeEnd = DateTime(_end.year, _end.month, _end.day, 23, 59);
    final affected = bookings.appointments
        .where(
          (a) =>
              !a.startsAt.isBefore(_start) &&
              !a.startsAt.isAfter(rangeEnd) &&
              a.status == AppointmentStatus.expected,
        )
        .toList();
    if (affected.isNotEmpty) {
      final rangeLabel = '${formatDate(_start)} – ${formatDate(_end)}';
      final proceed = await _showAffectedAppointmentsDialog(
        context,
        dateLabel: rangeLabel,
        count: affected.length,
      );
      if (!mounted) return;
      if (proceed == null) {
        setState(() => _saving = false);
        return;
      }
      if (!proceed) {
        setState(() => _saving = false);
        Navigator.push(context, pageRoute(ScheduleScreen(initialDate: _start)));
        return;
      }
    }
    final ok = await runApi(context, () => schedule.addVacation(_start, _end));
    if (!mounted) return;
    setState(() => _saving = false);
    if (ok) {
      setState(() {
        _start = appToday();
        _end = appToday().add(const Duration(days: 7));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final language = context.watch<LanguageProvider>().language;
    String t({required String tk, required String ru, required String en}) =>
        pickTr(language, tk: tk, ru: ru, en: en);
    final tokens = context.appTokens;
    final vacations = context.watch<ScheduleProvider>().vacations;
    return Scaffold(
      backgroundColor: tokens.surface,
      appBar: CabinetAppBar(
        title: t(tk: 'Dynç alyş ', ru: 'Отпуск', en: 'Vacation'),
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
                      tk: 'Bu wagtda siz hyzmatlary kabul etmersiňiz. Müşderiler bu günler üçin sargyt edip bilmezler.',
                      ru: 'В это время вы не принимаете заявки. Клиенты не смогут записаться на эти дни.',
                      en: 'During this time you will not accept bookings. Clients will not be able to book these days.',
                    ),
                  ),
                  if (vacations.isNotEmpty) ...[
                    const SizedBox(height: 22),
                    Text(
                      t(tk: 'Goşulan döwürler', ru: 'Добавленные периоды', en: 'Added periods'),
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 12),
                    for (final v in vacations)
                      Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                        decoration: BoxDecoration(
                          color: tokens.surfaceElevated,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: _softLine(tokens)),
                        ),
                        child: Row(
                          children: [
                            AppIcon(Icons.event_busy_outlined, color: tokens.accent, size: 18),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                '${formatDate(v.start)} – ${formatDate(v.end)}',
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                              ),
                            ),
                            GestureDetector(
                              onTap: () => runApi(
                                context,
                                () => context.read<ScheduleProvider>().removeVacation(v.id),
                              ),
                              child: const AppIcon(Icons.close, color: Colors.black38, size: 18),
                            ),
                          ],
                        ),
                      ),
                  ],
                  const SizedBox(height: 22),
                  Text(
                    t(
                      tk: 'Täze dynç alyş döwri',
                      ru: 'Новый период отпуска',
                      en: 'New vacation period',
                    ),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 14),
                  _PickerField(
                    label: t(
                      tk: 'Başlangyç senesi',
                      ru: 'Дата начала',
                      en: 'Start date',
                    ),
                    value: formatDate(_start),
                    icon: Icons.calendar_today_outlined,
                    onTap: () => _pickDate(isStart: true),
                  ),
                  const SizedBox(height: 14),
                  _PickerField(
                    label: t(
                      tk: 'Tamamlanýan senesi',
                      ru: 'Дата окончания',
                      en: 'End date',
                    ),
                    value: formatDate(_end),
                    icon: Icons.calendar_today_outlined,
                    onTap: () => _pickDate(isStart: false),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 6, 20, 14),
              child: _MasterActionButton(
                label: _saving
                    ? t(tk: 'Saklanýar...', ru: 'Сохранение...', en: 'Saving...')
                    : t(tk: 'Dynç alyş goş', ru: 'Добавить отпуск', en: 'Add vacation'),
                enabled: !_saving,
                leading: Icons.add,
                onTap: _add,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Warns before closing a day that already has bookings on it.
/// Returns `true` to close the day anyway, `false` to go review the day's
/// appointments instead, `null` if the master backed out entirely.
Future<bool?> _showAffectedAppointmentsDialog(
  BuildContext context, {
  required String dateLabel,
  required int count,
}) {
  final language = context.read<LanguageProvider>().language;
  String t({required String tk, required String ru, required String en}) =>
      pickTr(language, tk: tk, ru: ru, en: en);
  final tokens = context.appTokens;
  return showDialog<bool>(
    context: context,
    barrierColor: tokens.scrim,
    builder: (dialogContext) => Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 30),
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
        decoration: BoxDecoration(
          color: tokens.surface,
          borderRadius: BorderRadius.circular(26),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: tokens.surfaceElevated,
                shape: BoxShape.circle,
              ),
              child: AppIcon(
                Icons.warning_amber_rounded,
                size: 25,
                color: tokens.warning,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              t(
                tk: 'Bu wagtda ýazgylar bar',
                ru: 'На этот период уже есть записи',
                en: 'There are bookings in this period',
              ),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              t(
                tk: '$dateLabel üçin $count ýazgy bar. Dowam etseňiz, ol ýazgylar awtomatik ýatyrylmaýar — özüňiz dolandyrmaly bolarsyňyz.',
                ru: 'На $dateLabel уже есть $count запис(ей). Продолжив, вы не отменяете их автоматически — вам нужно будет управлять ими вручную.',
                en: 'There are $count booking(s) for $dateLabel. Continuing will not cancel them automatically — you will need to manage them yourself.',
              ),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.5,
                color: tokens.textSecondary,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: tokens.border),
                ),
                onPressed: () => Navigator.pop(dialogContext, false),
                child: Text(
                  t(
                    tk: 'Ýazgylara seret',
                    ru: 'Посмотреть записи',
                    en: 'View bookings',
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: tokens.textPrimary,
                ),
                onPressed: () => Navigator.pop(dialogContext, true),
                child: Text(
                  t(
                    tk: 'Ýene-de ýap',
                    ru: 'Всё равно закрыть',
                    en: 'Close anyway',
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, null),
              child: Text(t(tk: 'Ýatyr', ru: 'Отмена', en: 'Cancel')),
            ),
          ],
        ),
      ),
    ),
  );
}
