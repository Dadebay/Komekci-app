part of '../../../app/komekci_app.dart';

class VacationScreen extends StatefulWidget {
  const VacationScreen({
    super.key,
    this.initialStart,
    this.initialEnd,
    this.initialNote = '',
  });
  final DateTime? initialStart;
  final DateTime? initialEnd;
  final String initialNote;

  @override
  State<VacationScreen> createState() => _VacationScreenState();
}

class _VacationScreenState extends State<VacationScreen> {
  late DateTime _start = widget.initialStart ?? DateTime.now();
  late DateTime _end =
      widget.initialEnd ?? DateTime.now().add(const Duration(days: 7));
  late final _noteController = TextEditingController(text: widget.initialNote);

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickDate({required bool isStart}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? _start : _end,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
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

  Future<void> _save() async {
    final rangeEnd = DateTime(_end.year, _end.month, _end.day, 23, 59);
    final affected = context
        .read<BookingProvider>()
        .appointments
        .where(
          (a) =>
              !a.startsAt.isBefore(_start) &&
              !a.startsAt.isAfter(rangeEnd) &&
              a.status != AppointmentStatus.cancelled,
        )
        .toList();
    if (affected.isNotEmpty) {
      final rangeLabel = '${formatDate(_start)} – ${formatDate(_end)}';
      final proceed = await _showAffectedAppointmentsDialog(
        context,
        dateLabel: rangeLabel,
        count: affected.length,
      );
      if (proceed == null || !mounted) return;
      if (!proceed) {
        Navigator.push(
          context,
          pageRoute(ScheduleScreen(initialDate: _start)),
        );
        return;
      }
    }
    if (!mounted) return;
    Navigator.pop(context, (
      start: _start,
      end: _end,
      note: _noteController.text.trim(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final language = context.watch<LanguageProvider>().language;
    String t({required String tk, required String ru, required String en}) =>
        pickTr(language, tk: tk, ru: ru, en: en);
    final tokens = context.appTokens;
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
                  const SizedBox(height: 22),
                  Text(
                    t(
                      tk: 'Dynç alyş döwri',
                      ru: 'Период отпуска',
                      en: 'Vacation period',
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
                  const SizedBox(height: 22),
                  _FieldLabel(
                    text: t(
                      tk: 'Düşündiriş (islege görä)',
                      ru: 'Комментарий (необязательно)',
                      en: 'Comment (optional)',
                    ),
                  ),
                  const SizedBox(height: 8),
                  _FormField(
                    controller: _noteController,
                    hint: t(
                      tk: 'Mysal: Tomusky dynç alyş',
                      ru: 'Например: летний отпуск',
                      en: 'Example: summer vacation',
                    ),
                    maxLines: 4,
                    maxLength: 200,
                    onChanged: () => setState(() {}),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 6, 20, 14),
              child: _MasterActionButton(
                label: t(tk: 'Ýatda sakla', ru: 'Сохранить', en: 'Save'),
                enabled: true,
                leading: Icons.save_outlined,
                onTap: _save,
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
