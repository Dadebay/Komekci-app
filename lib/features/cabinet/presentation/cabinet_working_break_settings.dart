part of '../../../app/komekci_app.dart';

extension _WorkingBreakSettings on _WorkingHoursScreenState {
  List<Widget> _breakSettings({required AppLanguage language, required StateSetter update}) {
    final tokens = context.appTokens;
    String t({required String tk, required String ru, required String en}) =>
        pickTr(language, tk: tk, ru: ru, en: en);
    return [
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
                                        onChanged: (value) => update(
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
                                      update(() {
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
    ];
  }
}
