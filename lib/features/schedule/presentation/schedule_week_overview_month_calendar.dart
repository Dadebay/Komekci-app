part of '../../../app/komekci_app.dart';

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
                        style: TextStyle(
                          fontSize: 11,
                          color: tokens.textSecondary,
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
                          : (inMonth ? tokens.textPrimary : tokens.disabled),
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

