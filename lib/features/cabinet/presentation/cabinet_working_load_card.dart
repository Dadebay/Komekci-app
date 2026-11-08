part of '../../../app/komekci_app.dart';

class _WorkingHoursLoadCard extends StatelessWidget {
  const _WorkingHoursLoadCard({required this.language, required this.schedule});

  final AppLanguage language;
  final ScheduleProvider schedule;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    final waitingForSchedule = schedule.loading || schedule.error == null;
    String t({required String tk, required String ru, required String en}) =>
        pickTr(language, tk: tk, ru: ru, en: en);
    return Container(
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
                    );
  }
}
