part of '../../../app/komekci_app.dart';

class WorkingHoursScreen extends StatefulWidget {
  const WorkingHoursScreen({super.key});

  @override
  State<WorkingHoursScreen> createState() => _WorkingHoursScreenState();
}

class _WorkingHoursScreenState extends State<WorkingHoursScreen> {
  // Mock weekly schedule: open flag plus start and end hour per weekday.
  var _days = List.generate(
    7,
    (index) => (
      open: index != 6,
      start: index == 5 ? '10:00' : '09:00',
      end: index == 5 ? '17:00' : '19:00',
    ),
  );

  String _breakStart = '13:00';
  String _breakEnd = '14:00';

  DateTime? _vacationStart = DateTime(2024, 6, 10);
  DateTime? _vacationEnd = DateTime(2024, 6, 20);
  String _vacationNote = '';
  bool _vacationEnabled = true;

  bool _bufferEnabled = true;
  int _bufferMinutes = 10;

  var _specialDays = <DateTime>[];

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
    final vacationValue = _vacationStart != null && _vacationEnd != null
        ? '${formatDate(_vacationStart!)} - ${formatDate(_vacationEnd!)}'
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
                    value: '$_breakStart - $_breakEnd',
                    showChevron: true,
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
                  ),
                  _SettingRow(
                    icon: Icons.event_busy_outlined,
                    title: t(tk: 'Dynç alyş ', ru: 'Отпуск', en: 'Vacation'),
                    value: vacationValue,
                    switchValue: _vacationEnabled,
                    onSwitchChanged: (v) =>
                        setState(() => _vacationEnabled = v),
                    onTap: () async {
                      final result =
                          await Navigator.push<
                            ({DateTime start, DateTime end, String note})?
                          >(
                            context,
                            pageRoute(
                              VacationScreen(
                                initialStart: _vacationStart,
                                initialEnd: _vacationEnd,
                                initialNote: _vacationNote,
                              ),
                            ),
                          );
                      if (result != null) {
                        setState(() {
                          _vacationStart = result.start;
                          _vacationEnd = result.end;
                          _vacationNote = result.note;
                          _vacationEnabled = true;
                        });
                      }
                    },
                  ),
                  _SettingRow(
                    icon: Icons.timer_outlined,
                    title: t(
                      tk: 'Müşderileriň arasyndaky arakesme',
                      ru: 'Перерыв между клиентами',
                      en: 'Break between customers',
                    ),
                    subtitle: t(
                      tk: 'Her bir müşderiden soň goşmaça wagt',
                      ru: 'Дополнительное время после каждого клиента',
                      en: 'Extra time after each customer',
                    ),
                    value:
                        '$_bufferMinutes ${t(tk: "min", ru: "мин", en: "min")}',
                    switchValue: _bufferEnabled,
                    onSwitchChanged: (v) => setState(() => _bufferEnabled = v),
                    onTap: () async {
                      final picked = await _pickDuration(
                        context,
                        language: language,
                        current: _bufferMinutes,
                        options: const [5, 10, 15, 20, 30, 45, 60],
                        unit: t(tk: 'min', ru: 'мин', en: 'min'),
                      );
                      if (picked != null)
                        setState(() => _bufferMinutes = picked);
                    },
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
                        '${_specialDays.length} ${t(tk: "gün", ru: "дн.", en: "days")}',
                    showChevron: true,
                    onTap: () async {
                      final result = await Navigator.push<List<DateTime>?>(
                        context,
                        pageRoute(
                          SpecialDaysScreen(initialDays: _specialDays),
                        ),
                      );
                      if (result != null) setState(() => _specialDays = result);
                    },
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
                enabled: true,
                leading: Icons.save_outlined,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        t(
                          tk: 'Iş wagty ýatda saklandy.',
                          ru: 'График сохранён.',
                          en: 'Working hours saved.',
                        ),
                      ),
                    ),
                  );
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
