part of '../../../app/komekci_app.dart';

/// Top of the schedule tab: a large title with the visible month under it on
/// the left, and round action buttons (jump to today, week overview, search)
/// on the right.
class _ScheduleHeader extends StatelessWidget {
  const _ScheduleHeader({
    required this.language,
    required this.selected,
    required this.weekStart,
    required this.searching,
    required this.onSelect,
    required this.onToggleSearch,
  });

  final AppLanguage language;
  final DateTime selected;
  final DateTime weekStart;
  final bool searching;
  final ValueChanged<DateTime> onSelect;
  final VoidCallback onToggleSearch;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    final canPop = Navigator.of(context).canPop();
    final isToday = _sameDay(selected, appToday());
    final month = _byLang(
      language,
      _monthsFullTk,
      _monthsFullRu,
      _monthsFullEn,
    )[selected.month - 1];
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 6),
      child: Row(
        children: [
          if (canPop) ...[
            _HeaderCircleButton(
              icon: Icons.arrow_back,
              onTap: () => Navigator.maybePop(context),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.scheduleSchedule.select(language),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -.5,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '$month ${selected.year}',
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: tokens.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (!isToday) ...[
            GestureDetector(
              onTap: () => onSelect(appToday()),
              child: Container(
                height: 40,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: tokens.accent.withValues(alpha: .12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  AppStrings.scheduleToday.select(language),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: tokens.accent,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          _HeaderCircleButton(
            icon: Icons.grid_view_outlined,
            tooltip: AppStrings.scheduleWeekView.select(language),
            onTap: () => Navigator.push(
              context,
              pageRoute(
                WeekOverviewScreen(weekStart: weekStart, onSelectDay: onSelect),
              ),
            ),
          ),
          const SizedBox(width: 8),
          _HeaderCircleButton(
            icon: searching ? Icons.close : Icons.search,
            tooltip: searching
                ? AppStrings.scheduleCloseSearch.select(language)
                : AppStrings.scheduleSearch.select(language),
            active: searching,
            onTap: onToggleSearch,
          ),
        ],
      ),
    );
  }
}

class _HeaderCircleButton extends StatelessWidget {
  const _HeaderCircleButton({
    required this.icon,
    required this.onTap,
    this.tooltip,
    this.active = false,
  });
  final IconData icon;
  final VoidCallback onTap;
  final String? tooltip;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    final button = GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        width: 40,
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: active ? tokens.textPrimary : tokens.surfaceElevated,
          border: Border.all(
            color: active ? tokens.textPrimary : tokens.border,
          ),
        ),
        child: AppIcon(
          icon,
          size: 19,
          color: active ? tokens.surface : tokens.textPrimary,
        ),
      ),
    );
    return tooltip == null ? button : Tooltip(message: tooltip!, child: button);
  }
}
