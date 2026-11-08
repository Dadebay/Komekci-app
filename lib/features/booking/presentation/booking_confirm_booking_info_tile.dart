part of '../../../app/komekci_app.dart';

class _BookingInfoTile extends StatelessWidget {
  const _BookingInfoTile({required this.icon, required this.caption, required this.value});
  final IconData icon;
  final String caption;
  final String value;

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: t.surfaceElevated, borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: t.accent.withValues(alpha: .14), shape: BoxShape.circle),
            child: AppIcon(icon, size: 16, color: t.accent),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(caption, style: TextStyle(fontSize: 10.5, color: t.textSecondary)),
                const SizedBox(height: 2),
                Text(value, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
