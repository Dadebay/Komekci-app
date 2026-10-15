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
    toast.success(
      pickTr(
        language,
        tk: 'Iş wagty ýatda saklandy.',
        ru: 'График сохранён.',
        en: 'Working hours saved.',
      ),
    );
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
    final shortNames = switch (language) {
      AppLanguage.tk => ['Du', 'Si', 'Ça', 'Pe', 'An', 'Şe', 'Ýe'],
      AppLanguage.ru => ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'],
      AppLanguage.en => ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su'],
    };
    final openDays = _days.where((day) => day.open).length;
    final waitingForSchedule = schedule.loading || schedule.error == null;
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
                  if (!schedule.loaded)
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: tokens.surfaceElevated,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: _softLine(tokens)),
                      ),
                      child: Column(
                        children: [
                          AppIcon(
                            waitingForSchedule
                                ? Icons.schedule_outlined
                                : Icons.wifi_off_outlined,
                            color: tokens.accent,
                            size: 28,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            waitingForSchedule
                                ? t(
                                    tk: 'Iş wagty ýüklenýär...',
                                    ru: 'Загружаем график...',
                                    en: 'Loading working hours...',
                                  )
                                : t(
                                    tk: 'Iş wagtyny ýükläp bolmady.',
                                    ru: 'Не удалось загрузить график.',
                                    en: 'Could not load working hours.',
                                  ),
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: tokens.textPrimary,
                            ),
                          ),
                          if (!waitingForSchedule) ...[
                            const SizedBox(height: 12),
                            TextButton.icon(
                              onPressed: schedule.load,
                              icon: const Icon(Icons.refresh, size: 18),
                              label: Text(
                                t(
                                  tk: 'Täzeden synanyş',
                                  ru: 'Повторить',
                                  en: 'Try again',
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    )
                  else ...[
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: tokens.textPrimary,
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: tokens.accent.withValues(alpha: .18),
                                  borderRadius: BorderRadius.circular(13),
                                ),
                                child: AppIcon(
                                  Icons.calendar_month_outlined,
                                  color: tokens.accent,
                                  size: 21,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      t(
                                        tk: 'Hepdelik tertip',
                                        ru: 'Неделя',
                                        en: 'Your week',
                                      ),
                                      style: TextStyle(
                                        color: tokens.surface.withValues(
                                          alpha: .72,
                                        ),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '$openDays / 7 ${t(tk: 'iş güni', ru: 'рабочих дней', en: 'working days')}',
                                      style: TextStyle(
                                        color: tokens.surface,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              for (var i = 0; i < 7; i++)
                                Expanded(
                                  child: Padding(
                                    padding: EdgeInsets.only(
                                      right: i == 6 ? 0 : 7,
                                    ),
                                    child: Column(
                                      children: [
                                        Text(
                                          shortNames[i],
                                          style: TextStyle(
                                            color: _days[i].open
                                                ? tokens.surface
                                                : tokens.surface.withValues(
                                                    alpha: .48,
                                                  ),
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 7),
                                        Container(
                                          height: 4,
                                          decoration: BoxDecoration(
                                            color: _days[i].open
                                                ? tokens.accent
                                                : tokens.surface.withValues(
                                                    alpha: .24,
                                                  ),
                                            borderRadius: BorderRadius.circular(
                                              4,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      t(
                        tk: 'Bu tertip müşderilere görünýän boş wagtlary kesgitleýär.',
                        ru: 'Этот график определяет доступное клиентам время.',
                        en: 'This schedule sets the times clients can book.',
                      ),
                      style: TextStyle(
                        color: tokens.textSecondary,
                        fontSize: 12.5,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Wrap(
                      alignment: WrapAlignment.spaceBetween,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 8,
                      runSpacing: 2,
                      children: [
                        Text(
                          t(
                            tk: 'Hepdäniň iş günleri',
                            ru: 'Рабочие дни недели',
                            en: 'Working days of the week',
                          ),
                          style: TextStyle(
                            color: tokens.textPrimary,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
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
                        decoration: BoxDecoration(
                          color: tokens.surfaceElevated,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: _softLine(tokens)),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(18),
                          child: Material(
                            color: Colors.transparent,
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                    14,
                                    11,
                                    8,
                                    11,
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 38,
                                        height: 38,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          color: day.open
                                              ? tokens.accent.withValues(
                                                  alpha: .14,
                                                )
                                              : tokens.border.withValues(
                                                  alpha: .42,
                                                ),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: Text(
                                          '${index + 1}'.padLeft(2, '0'),
                                          style: TextStyle(
                                            color: day.open
                                                ? tokens.accent
                                                : tokens.textSecondary,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              names[index],
                                              style: TextStyle(
                                                color: tokens.textPrimary,
                                                fontSize: 14.5,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              day.open
                                                  ? t(
                                                      tk: 'Iş güni',
                                                      ru: 'Рабочий день',
                                                      en: 'Working day',
                                                    )
                                                  : t(
                                                      tk: 'Dynç güni',
                                                      ru: 'Выходной',
                                                      en: 'Day off',
                                                    ),
                                              style: TextStyle(
                                                color: tokens.textSecondary,
                                                fontSize: 11.5,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Semantics(
                                        label: names[index],
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
                                    ],
                                  ),
                                ),
                                if (day.open) ...[
                                  Divider(height: 1, color: _softLine(tokens)),
                                  InkWell(
                                    onTap: () =>
                                        _editDay(index, language, names),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 12,
                                      ),
                                      child: Row(
                                        children: [
                                          AppIcon(
                                            Icons.schedule_outlined,
                                            color: tokens.accent,
                                            size: 18,
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Text(
                                              '${day.start} – ${day.end}',
                                              style: TextStyle(
                                                color: tokens.textPrimary,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ),
                                          AppIcon(
                                            Icons.chevron_right,
                                            color: tokens.textSecondary,
                                            size: 18,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
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
                    Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        color: tokens.surfaceElevated,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: _softLine(tokens)),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: Material(
                          color: Colors.transparent,
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  14,
                                  11,
                                  8,
                                  11,
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 38,
                                      height: 38,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: tokens.accent.withValues(
                                          alpha: .14,
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: AppIcon(
                                        Icons.coffee_outlined,
                                        color: tokens.accent,
                                        size: 18,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            t(
                                              tk: 'Arakesme wagty',
                                              ru: 'Время перерыва',
                                              en: 'Break time',
                                            ),
                                            style: TextStyle(
                                              color: tokens.textPrimary,
                                              fontSize: 14.5,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            _breakEnabled
                                                ? t(
                                                    tk: 'Iş günlerinde',
                                                    ru: 'В рабочие дни',
                                                    en: 'On working days',
                                                  )
                                                : t(
                                                    tk: 'Goşulmady',
                                                    ru: 'Не добавлен',
                                                    en: 'Not set',
                                                  ),
                                            style: TextStyle(
                                              color: tokens.textSecondary,
                                              fontSize: 11.5,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Semantics(
                                      label: t(
                                        tk: 'Arakesme wagty',
                                        ru: 'Время перерыва',
                                        en: 'Break time',
                                      ),
                                      child: Switch(
                                        value: _breakEnabled,
                                        activeThumbColor: tokens.surface,
                                        activeTrackColor: tokens.textPrimary,
                                        onChanged: (value) => setState(
                                          () => _breakEnabled = value,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (_breakEnabled) ...[
                                Divider(height: 1, color: _softLine(tokens)),
                                InkWell(
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
                                      });
                                    }
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                    child: Row(
                                      children: [
                                        AppIcon(
                                          Icons.schedule_outlined,
                                          color: tokens.accent,
                                          size: 18,
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Text(
                                            '$_breakStart – $_breakEnd',
                                            style: TextStyle(
                                              color: tokens.textPrimary,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                        AppIcon(
                                          Icons.chevron_right,
                                          color: tokens.textSecondary,
                                          size: 18,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                    _SettingRow(
                      icon: Icons.event_busy_outlined,
                      title: t(tk: 'Dynç alyş', ru: 'Отпуск', en: 'Vacation'),
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
