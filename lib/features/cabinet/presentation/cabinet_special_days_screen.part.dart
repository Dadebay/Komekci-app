part of '../../../app/komekci_app.dart';

class SpecialDaysScreen extends StatefulWidget {
  const SpecialDaysScreen({super.key, required this.initialDays});
  final List<DateTime> initialDays;

  @override
  State<SpecialDaysScreen> createState() => _SpecialDaysScreenState();
}

class _SpecialDaysScreenState extends State<SpecialDaysScreen> {
  late var _days = List.of(widget.initialDays)..sort();

  Future<void> _addDay() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now.subtract(const Duration(days: 1)),
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked == null || !mounted) return;
    final exists = _days.any(
      (d) =>
          d.year == picked.year &&
          d.month == picked.month &&
          d.day == picked.day,
    );
    if (exists) return;

    // Closing a day that already has bookings on it needs the master's
    // explicit acknowledgement — those appointments don't disappear on
    // their own, so surface them before the day is marked closed.
    final affected = context.read<BookingProvider>().onDay(picked);
    if (affected.isNotEmpty && mounted) {
      final proceed = await _showAffectedAppointmentsDialog(
        context,
        dateLabel: formatDate(picked),
        count: affected.length,
      );
      if (proceed == null || !mounted) return;
      if (!proceed) {
        Navigator.push(
          context,
          pageRoute(ScheduleScreen(initialDate: picked)),
        );
        return;
      }
    }
    setState(() => _days = (List.of(_days)..add(picked))..sort());
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
                  if (_days.isEmpty)
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
                    ..._days.map(
                      (d) => Container(
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
                              Icons.event_busy_outlined,
                              color: tokens.accent,
                              size: 18,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                formatDate(d),
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () => setState(
                                () => _days = List.of(_days)..remove(d),
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
                    onTap: _addDay,
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
                label: t(tk: 'Ýatda sakla', ru: 'Сохранить', en: 'Save'),
                enabled: true,
                leading: Icons.save_outlined,
                onTap: () => Navigator.pop(context, _days),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
