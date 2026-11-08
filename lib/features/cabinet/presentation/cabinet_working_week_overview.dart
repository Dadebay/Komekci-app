part of '../../../app/komekci_app.dart';

extension _WorkingWeekOverview on _WorkingHoursScreenState {
  List<Widget> _weeklyOverview({required AppLanguage language}) {
    final tokens = context.appTokens;
    String t({required String tk, required String ru, required String en}) =>
        pickTr(language, tk: tk, ru: ru, en: en);
    final shortNames = switch (language) {
      AppLanguage.tk => ['Du', 'Si', 'Ça', 'Pe', 'An', 'Şe', 'Ýe'],
      AppLanguage.ru => ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'],
      AppLanguage.en => ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su'],
    };
    final openDays = _days.where((day) => day.open).length;
    return [
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
    ];
  }
}
