part of '../../../app/komekci_app.dart';

class _ScheduleHeaderActions extends StatelessWidget {
  const _ScheduleHeaderActions({required this.language, required this.selected, required this.weekStart, required this.searching, required this.onSelect, required this.onToggleSearch});

  final AppLanguage language;
  final DateTime selected;
  final DateTime weekStart;
  final bool searching;
  final ValueChanged<DateTime> onSelect;
  final VoidCallback onToggleSearch;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    String t({required String tk, required String ru, required String en}) =>
        pickTr(language, tk: tk, ru: ru, en: en);
    return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!_sameDay(selected, appToday()))
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: TextButton(
                  onPressed: () => onSelect(appToday()),
                  child: Text(t(tk: 'Şu gün', ru: 'Сегодня', en: 'Today')),
                ),
              ),
            IconButton(
              tooltip: t(tk: 'Hepdelik görnüş', ru: 'Неделя', en: 'Week view'),
              icon: AppIcon(
                Icons.grid_view_outlined,
                size: 21,
                color: tokens.textPrimary,
              ),
              onPressed: () => Navigator.push(
                context,
                pageRoute(
                  WeekOverviewScreen(
                    weekStart: weekStart,
                    onSelectDay: onSelect,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              tooltip: searching
                  ? t(
                      tk: 'Gözlegi ýap',
                      ru: 'Закрыть поиск',
                      en: 'Close search',
                    )
                  : t(tk: 'Gözle', ru: 'Поиск', en: 'Search'),
              icon: AppIcon(
                searching ? Icons.close : Icons.search,
                size: 21,
                color: tokens.textPrimary,
              ),
              onPressed: onToggleSearch,
            ),
          ],
        );
  }
}
