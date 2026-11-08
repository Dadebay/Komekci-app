part of '../../../app/komekci_app.dart';

class PageViewData extends StatelessWidget {
  const PageViewData({
    super.key,
    required this.title,
    this.subtitle,
    this.image = false,
    required this.entries,
  });
  final String title;
  final String? subtitle;
  final bool image;
  final List<String> entries;
  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 27, fontWeight: FontWeight.w700),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 7),
          Text(subtitle!, style: TextStyle(color: tokens.textSecondary)),
        ],
        if (image) ...[
          const SizedBox(height: 22),
          Container(
            height: 145,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              image: const DecorationImage(
                image: AssetImage('assets/images/inspiration_02.jpeg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
        const SizedBox(height: 22),
        ...entries.map(
          (entry) => Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: tokens.surfaceElevated,
              borderRadius: BorderRadius.circular(17),
              border: Border.all(color: tokens.border),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: tokens.accent.withValues(alpha: .18),
                  child: AppIcon(
                    Icons.person_outline,
                    color: tokens.textPrimary,
                  ),
                ),
                const SizedBox(width: 13),
                Expanded(child: Text(entry)),
                const AppIcon(Icons.chevron_right),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
