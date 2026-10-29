part of '../../../app/komekci_app.dart';

class _DateChip extends StatelessWidget {
  const _DateChip({
    required this.weekday,
    required this.dayNumber,
    required this.selected,
    required this.enabled,
    required this.onTap,
    this.isToday = false,
  });
  final String weekday;
  final int dayNumber;
  final bool selected;
  final bool enabled;
  final bool isToday;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    return Opacity(
      opacity: enabled ? 1 : .38,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: 58,
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? t.textPrimary : t.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: selected ? t.textPrimary : t.border),
            boxShadow: selected ? [BoxShadow(color: t.textPrimary.withValues(alpha: .22), blurRadius: 12, offset: const Offset(0, 5))] : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                weekday,
                style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: selected ? t.surface.withValues(alpha: .7) : t.textSecondary),
              ),
              const SizedBox(height: 5),
              Text(
                '$dayNumber',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: selected ? t.surface : t.textPrimary),
              ),
              const SizedBox(height: 5),
              Container(
                width: 5,
                height: 5,
                decoration: BoxDecoration(shape: BoxShape.circle, color: isToday ? t.accent : Colors.transparent),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
