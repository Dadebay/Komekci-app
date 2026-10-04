part of '../../../app/komekci_app.dart';

class WorkingHoursScreen extends StatefulWidget {
  const WorkingHoursScreen({super.key});

  @override
  State<WorkingHoursScreen> createState() => _WorkingHoursScreenState();
}

class _WorkingHoursScreenState extends State<WorkingHoursScreen> {
  // Weekly schedule from the server, Monday (0) to Sunday (6).
  var _days = List.generate(
    7,
    (index) => (open: index != 6, start: '09:00', end: '19:00'),
  );

  String _breakStart = '13:00';
  String _breakEnd = '14:00';
  bool _breakEnabled = false;

  bool _initialized = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    // The schedule loads at sign-in; if that failed (no network) the form
    // would stay locked, so try again when the screen opens.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final schedule = context.read<ScheduleProvider>();
      if (!schedule.loaded && !schedule.loading) schedule.load();
    });
  }

  /// Copies the saved schedule into the editable fields, once it is loaded.
  void _adopt(ScheduleProvider schedule) {
    if (_initialized || !schedule.loaded) return;
    _initialized = true;
    final saved = schedule.days;
    if (saved.length == 7) {
      _days = [
        for (final d in saved)
          (
            open: d.isWorking,
            start: d.startTime ?? '09:00',
            end: d.endTime ?? '19:00',
          ),
      ];
      final withBreak = saved.where(
        (d) => d.isWorking && d.breakStart != null && d.breakEnd != null,
      );
      if (withBreak.isNotEmpty) {
        _breakEnabled = true;
        _breakStart = withBreak.first.breakStart!;
        _breakEnd = withBreak.first.breakEnd!;
      }
    }
  }

  Future<void> _save(AppLanguage language) async {
    if (_saving) return;
    final schedule = context.read<ScheduleProvider>();
    final navigator = Navigator.of(context);
    final toast = AppToast.of(context);
    setState(() => _saving = true);
    final ok = await runApi(context, () async {
      await schedule.saveWeek([
        for (var i = 0; i < 7; i++)
          ScheduleDay(
            weekday: i,
            isWorking: _days[i].open,
            startTime: _days[i].start,
            endTime: _days[i].end,
            breakStart: _breakEnabled ? _breakStart : null,
            breakEnd: _breakEnabled ? _breakEnd : null,
          ),
      ]);
    });
    if (!mounted) return;
    setState(() => _saving = false);
    if (!ok) return;
    toast.success(pickTr(
            language,
            tk: 'Iş wagty ýatda saklandy.',
            ru: 'График сохранён.',
            en: 'Working hours saved.',
          ));
    navigator.pop();
  }

  Future<void> _applyToAllDays(AppLanguage language) async {
    final result = await _pickTimeRange(
      context,
      language: language,
      title: pickTr(
        language,
        tk: 'Ähli günler üçin wagt',
        ru: 'Время для всех дней',
        en: 'Time for all days',
      ),
      start: _days.first.start,
      end: _days.first.end,
    );
    if (result == null) return;
    setState(() {
      _days = List.generate(
        7,
        (i) => (open: _days[i].open, start: result.$1, end: result.$2),
      );
    });
  }

  Future<void> _editDay(
    int index,
    AppLanguage language,
    List<String> names,
  ) async {
    final day = _days[index];
    final result = await _pickTimeRange(
      context,
      language: language,
      title: names[index],
      start: day.start,
      end: day.end,
    );
    if (result == null) return;
    setState(() {
      final updated = List.of(_days);
      updated[index] = (open: day.open, start: result.$1, end: result.$2);
      _days = updated;
    });
  }

  @override
  Widget build(BuildContext context) {
    final language = context.watch<LanguageProvider>().language;
    String t({required String tk, required String ru, required String en}) =>
        pickTr(language, tk: tk, ru: ru, en: en);
    final tokens = context.appTokens;
    final schedule = context.watch<ScheduleProvider>();
    _adopt(schedule);
    final names = switch (language) {
      AppLanguage.tk => [
        'Duşenbe',
        'Sişenbe',
        'Çarşenbe',
        'Penşenbe',
        'Anna',
        'Şenbe',
        'Ýekşenbe',
      ],
      AppLanguage.ru => [
        'Понедельник',
        'Вторник',
        'Среда',
        'Четверг',
        'Пятница',
        'Суббота',
        'Воскресенье',
      ],
      AppLanguage.en => [
        'Monday',
        'Tuesday',
        'Wednesday',
        'Thursday',
        'Friday',
        'Saturday',
        'Sunday',
      ],
    };
    final nextVacation = schedule.nextVacation;
    final vacationValue = nextVacation != null
        ? '${formatDate(nextVacation.start)} - ${formatDate(nextVacation.end)}'
        : t(tk: 'Bellenmedik', ru: 'Не задано', en: 'Not set');
    return Scaffold(
      backgroundColor: tokens.surface,
      appBar: CabinetAppBar(
        title: t(tk: 'Iş wagty', ru: 'График работы', en: 'Working hours'),
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
                    icon: Icons.schedule_outlined,
                    text: t(
                      tk: 'Siziň iş wagtyňyz müşderilere siziň boş wagtlaryňyzy görkezmek üçin ulanylýar.',
                      ru: 'Ваш график используется, чтобы показывать клиентам свободное время.',
                      en: "Your working hours are used to show clients your available times.",
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          t(
                            tk: 'Hepdäniň iş günleri',
                            ru: 'Рабочие дни недели',
                            en: 'Working days of the week',
                          ),
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () => _applyToAllDays(language),
                        child: Text(
                          t(
                            tk: 'Hemme güne ulan',
                            ru: 'Применить ко всем',
                            en: 'Apply to all',
                          ),
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...List.generate(names.length, (index) {
                    final day = _days[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: tokens.surfaceElevated,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: day.open
                              ? tokens.border
                              : const Color(0xffF0EEE9),
                        ),
                      ),
                      child: Row(
                        children: [
                          Text(
                            names[index],
                            style: const TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Transform.scale(
                            scale: .78,
                            child: Switch(
                              value: day.open,
                              activeThumbColor: tokens.surface,
                              activeTrackColor: tokens.textPrimary,
                              onChanged: (value) => setState(() {
                                final updated = List.of(_days);
                                updated[index] = (
                                  open: value,
                                  start: day.start,
                                  end: day.end,
                                );
                                _days = updated;
                              }),
                            ),
                          ),
                          const Spacer(),
                          GestureDetector(
                            onTap: day.open
                                ? () => _editDay(index, language, names)
                                : null,
                            child: Row(
                              children: [
                                if (day.open) ...[
                                  _TimeChip(text: day.start),
                                  const Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 6,
                                    ),
                                    child: Text(
                                      '–',
                                      style: TextStyle(color: Colors.black38),
                                    ),
                                  ),
                                  _TimeChip(text: day.end),
                                ] else
                                  Text(
                                    t(
                                      tk: 'Dynç güni',
                                      ru: 'Выходной',
                                      en: 'Day off',
                                    ),
                                    style: const TextStyle(
                                      fontSize: 12.5,
                                      color: Colors.black38,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                const SizedBox(width: 6),
                                AppIcon(
                                  Icons.chevron_right,
                                  color: day.open
                                      ? Colors.black26
                                      : Colors.black12,
                                  size: 17,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 22),
                  Text(
                    t(
                      tk: 'Goşmaça sazlamalar',
                      ru: 'Дополнительные настройки',
                      en: 'Additional settings',
                    ),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _SettingRow(
                    icon: Icons.coffee_outlined,
                    title: t(
                      tk: 'Arakesme wagty',
                      ru: 'Время перерыва',
                      en: 'Break time',
                    ),
                    value: _breakEnabled
                        ? '$_breakStart - $_breakEnd'
                        : t(tk: 'Ýok', ru: 'Нет', en: 'None'),
                    switchValue: _breakEnabled,
                    onSwitchChanged: (v) => setState(() => _breakEnabled = v),
                    onTap: () async {
                      final result = await _pickTimeRange(
                        context,
                        language: language,
                        title: t(
                          tk: 'Arakesme wagty',
                          ru: 'Время перерыва',
                          en: 'Break time',
                        ),
                        start: _breakStart,
                        end: _breakEnd,
                      );
                      if (result != null) {
                        setState(() {
                          _breakStart = result.$1;
                          _breakEnd = result.$2;
                          _breakEnabled = true;
                        });
                      }
                    },
                  ),
                  _SettingRow(
                    icon: Icons.event_busy_outlined,
                    title: t(tk: 'Dynç alyş ', ru: 'Отпуск', en: 'Vacation'),
                    subtitle: schedule.vacations.length > 1
                        ? '${schedule.vacations.length} ${t(tk: "döwür", ru: "периодов", en: "periods")}'
                        : null,
                    value: vacationValue,
                    showChevron: true,
                    onTap: () => Navigator.push(
                      context,
                      pageRoute(const VacationScreen()),
                    ),
                  ),
                  _SettingRow(
                    icon: Icons.event_busy_outlined,
                    title: t(
                      tk: 'Aýratyn günler',
                      ru: 'Особые дни',
                      en: 'Special days',
                    ),
                    subtitle: t(
                      tk: 'Goşmaça günleri ýa-da üýtgeşmeleri belläň',
                      ru: 'Отметьте дополнительные дни или изменения',
                      en: 'Mark additional days or changes',
                    ),
                    value:
                        '${schedule.overrides.length} ${t(tk: "gün", ru: "дн.", en: "days")}',
                    showChevron: true,
                    onTap: () => Navigator.push(
                      context,
                      pageRoute(const SpecialDaysScreen()),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 6, 20, 14),
              child: _MasterActionButton(
                label: t(
                  tk: 'Üýtgeşmeleri ýatda sakla',
                  ru: 'Сохранить изменения',
                  en: 'Save changes',
                ),
                enabled: schedule.loaded && !_saving,
                leading: Icons.save_outlined,
                onTap: () => _save(language),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
