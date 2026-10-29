part of '../../../app/komekci_app.dart';

class _NewSlotTimeCard extends StatelessWidget {
  const _NewSlotTimeCard({required this.start, required this.selectedEnd, required this.language});

  final DateTime start;
  final DateTime selectedEnd;
  final AppLanguage language;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    String t({required String tk, required String ru, required String en}) =>
        pickTr(language, tk: tk, ru: ru, en: en);
    return Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: tokens.surfaceElevated,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: tokens.border),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: tokens.accent.withValues(alpha: .13),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: AppIcon(
                                    Icons.calendar_today_outlined,
                                    size: 20,
                                    color: tokens.accent,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        formatDate(start),
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: tokens.textSecondary,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '${formatTime(TimeOfDay.fromDateTime(start))}–${formatTime(TimeOfDay.fromDateTime(selectedEnd))}',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          color: tokens.textPrimary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 9,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: freeSlotSurface(tokens),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    t(tk: 'Boş', ru: 'Свободно', en: 'Free'),
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: freeSlotForeground(tokens),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
  }
}
