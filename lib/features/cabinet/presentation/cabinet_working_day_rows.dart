part of '../../../app/komekci_app.dart';

extension _WorkingDayRows on _WorkingHoursScreenState {
  List<Widget> _workingDayRows({required AppLanguage language, required List<String> names, required StateSetter update}) {
    final tokens = context.appTokens;
    String t({required String tk, required String ru, required String en}) =>
        pickTr(language, tk: tk, ru: ru, en: en);
    return List.generate(names.length, (index) {
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
                                          onChanged: (value) => update(() {
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
                    });
  }
}
