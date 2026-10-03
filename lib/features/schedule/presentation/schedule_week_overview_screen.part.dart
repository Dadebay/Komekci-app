part of '../../../app/komekci_app.dart';

class _NavArrow extends StatelessWidget {
  const _NavArrow({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 30,
        height: 30,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: tokens.surface,
          borderRadius: BorderRadius.circular(9),
          border: Border.all(color: tokens.border),
        ),
        child: AppIcon(icon, size: 15, color: tokens.textPrimary),
      ),
    );
  }
}

/// Lightweight week-density overview — a plain 7-row list rather than a
/// scrollable calendar widget, to stay cheap on low-RAM devices. Tapping a
/// day jumps the day-view timeline to it.
class WeekOverviewScreen extends StatefulWidget {
  const WeekOverviewScreen({
    super.key,
    required this.weekStart,
    required this.onSelectDay,
  });
  final DateTime weekStart;
  final ValueChanged<DateTime> onSelectDay;

  @override
  State<WeekOverviewScreen> createState() => _WeekOverviewScreenState();
}

class _WeekOverviewScreenState extends State<WeekOverviewScreen> {
  late DateTime _weekStart = widget.weekStart;

  @override
  Widget build(BuildContext context) {
    final language = context.watch<LanguageProvider>().language;
    final tokens = context.appTokens;
    final bookingProvider = context.watch<BookingProvider>();
    final days = List.generate(7, (i) => _weekStart.add(Duration(days: i)));
    bookingProvider
      ..prefetch(days.first)
      ..prefetch(days.last);
    final counts = [for (final d in days) bookingProvider.onDay(d).length];
    final maxCount = counts.fold(0, (m, c) => c > m ? c : m);

    return Scaffold(
      backgroundColor: tokens.surface,
      appBar: CabinetAppBar(
        title: pickTr(
          language,
          tk: 'Hepde görnüşi',
          ru: 'Недельный вид',
          en: 'Week view',
        ),
        action: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconActionButton(
              icon: Icons.chevron_left,
              onTap: () => setState(
                () => _weekStart = _weekStart.subtract(const Duration(days: 7)),
              ),
            ),
            const SizedBox(width: 6),
            IconActionButton(
              icon: Icons.chevron_right,
              onTap: () => setState(
                () => _weekStart = _weekStart.add(const Duration(days: 7)),
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          children: [
            Text(
              '${formatDate(days.first)} – ${formatDate(days.last)}',
              style: TextStyle(color: tokens.textSecondary, fontSize: 12.5),
            ),
            const SizedBox(height: 16),
            ...List.generate(7, (i) {
              final day = days[i];
              final count = counts[i];
              final isToday = _sameDay(day, appToday());
              final density = maxCount == 0 ? 0.0 : count / maxCount;
              return InkWell(
                onTap: () {
                  widget.onSelectDay(day);
                  Navigator.pop(context);
                },
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: isToday ? tokens.surfaceElevated : tokens.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isToday ? tokens.accent : tokens.border,
                      width: isToday ? 1.4 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 46,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _byLang(
                                language,
                                _weekdaysTk,
                                _weekdaysRu,
                                weekdaysEn,
                              )[day.weekday - 1],
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '${day.day}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: density,
                            minHeight: 8,
                            backgroundColor: tokens.border,
                            color: count == 0 ? tokens.border : tokens.accent,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        '$count',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: tokens.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 4),
                      AppIcon(
                        Icons.chevron_right,
                        size: 15,
                        color: tokens.textSecondary,
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _WeekStrip extends StatelessWidget {
  const _WeekStrip({
    required this.weekStart,
    required this.selected,
    required this.language,
    required this.onSelect,
    required this.onPrevWeek,
    required this.onNextWeek,
  });
  final DateTime weekStart;
  final DateTime selected;
  final AppLanguage language;
  final ValueChanged<DateTime> onSelect;
  final VoidCallback onPrevWeek;
  final VoidCallback onNextWeek;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    return Row(
      children: [
        _NavArrow(icon: Icons.chevron_left, onTap: onPrevWeek),
        const SizedBox(width: 4),
        Expanded(
          child: Row(
            children: List.generate(7, (i) {
              final day = weekStart.add(Duration(days: i));
              final isSelected = _sameDay(day, selected);
              return Expanded(
                child: GestureDetector(
                  onTap: () => onSelect(day),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    padding: const EdgeInsets.symmetric(vertical: 9),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? tokens.textPrimary
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: Column(
                      children: [
                        Text(
                          _byLang(
                            language,
                            _weekdaysTk,
                            _weekdaysRu,
                            weekdaysEn,
                          )[day.weekday - 1],
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? tokens.surface.withValues(alpha: .7)
                                : tokens.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${day.day}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: isSelected
                                ? tokens.surface
                                : tokens.textPrimary,
                          ),
                        ),
                        Text(
                          _byLang(
                            language,
                            _monthsShortTk,
                            _monthsShortRu,
                            _monthsShortEn,
                          )[day.month - 1],
                          style: TextStyle(
                            fontSize: 8.5,
                            color: isSelected
                                ? tokens.surface.withValues(alpha: .7)
                                : tokens.textSecondary.withValues(alpha: .8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
        const SizedBox(width: 4),
        _NavArrow(icon: Icons.chevron_right, onTap: onNextWeek),
      ],
    );
  }
}

class _MonthCalendar extends StatelessWidget {
  const _MonthCalendar({
    required this.month,
    required this.selected,
    required this.language,
    required this.onSelect,
    required this.onPrevMonth,
    required this.onNextMonth,
  });
  final DateTime month;
  final DateTime selected;
  final AppLanguage language;
  final ValueChanged<DateTime> onSelect;
  final VoidCallback onPrevMonth;
  final VoidCallback onNextMonth;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    final first = DateTime(month.year, month.month, 1);
    final leading = first.weekday - 1;
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final totalCells = ((leading + daysInMonth) / 7).ceil() * 7;
    final startCell = first.subtract(Duration(days: leading));

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: tokens.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: tokens.border),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _NavArrow(icon: Icons.chevron_left, onTap: onPrevMonth),
              Text(
                '${_byLang(language, _monthsFullTk, _monthsFullRu, _monthsFullEn)[month.month - 1]} ${month.year}',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              _NavArrow(icon: Icons.chevron_right, onTap: onNextMonth),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: _byLang(language, _weekdaysTk, _weekdaysRu, weekdaysEn)
                .map(
                  (d) => Expanded(
                    child: Center(
                      child: Text(
                        d,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.black45,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 8),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: totalCells,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 6,
              crossAxisSpacing: 2,
            ),
            itemBuilder: (_, i) {
              final date = startCell.add(Duration(days: i));
              final inMonth = date.month == month.month;
              final isSelected = _sameDay(date, selected);
              return GestureDetector(
                onTap: () => onSelect(date),
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isSelected ? tokens.textPrimary : Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '${date.day}',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w500,
                      color: isSelected
                          ? tokens.surface
                          : (inMonth ? tokens.textPrimary : Colors.black26),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

