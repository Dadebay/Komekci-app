part of '../../../app/komekci_app.dart';

class _ProfilePill extends StatelessWidget {
  const _ProfilePill({required this.label, this.icon, this.dotColor});
  final String label;
  final IconData? icon;
  final Color? dotColor;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: tokens.surfaceElevated,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: tokens.border.withValues(alpha: .6)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            AppIcon(icon!, size: 13, color: tokens.textSecondary),
            const SizedBox(width: 5),
          ],
          if (dotColor != null) ...[
            Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                color: dotColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
          ],
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: tokens.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileStat extends StatelessWidget {
  const _ProfileStat({
    required this.icon,
    required this.caption,
    required this.value,
  });
  final IconData icon;
  final String caption;
  final String value;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: _bookingCardDecoration(tokens),
      child: Column(
        children: [
          AppIcon(icon, size: 18, color: tokens.accent),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            caption,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 11, color: tokens.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _MasterProfileHero extends StatelessWidget {
  const _MasterProfileHero({this.bannerUrl, this.photoUrl});
  final String? bannerUrl;
  final String? photoUrl;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    return SizedBox(
      height: 246,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            height: 196,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(32),
              ),
              color: tokens.surfaceElevated,
              border: Border.all(color: tokens.border),
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (bannerUrl != null)
                  Image.network(
                    bannerUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => const SizedBox.shrink(),
                  ),
                // Keeps the back button readable on a photo banner.
                if (bannerUrl != null)
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          tokens.textPrimary.withValues(alpha: .28),
                          Colors.transparent,
                          tokens.textPrimary.withValues(alpha: .12),
                        ],
                        stops: const [0, .45, 1],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: tokens.surface,
                  boxShadow: [
                    BoxShadow(
                      color: tokens.textPrimary.withValues(alpha: .14),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.fromBorderSide(
                      BorderSide(color: tokens.accent, width: 2),
                    ),
                  ),
                  child: MasterAvatar(url: photoUrl, radius: 44),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MasterProfileIconButton extends StatelessWidget {
  const _MasterProfileIconButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: tokens.surface.withValues(alpha: .92),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: tokens.textPrimary.withValues(alpha: .12),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: AppIcon(icon, size: 19, color: tokens.textPrimary),
      ),
    );
  }
}

class _MasterServiceRow extends StatelessWidget {
  const _MasterServiceRow({
    required this.name,
    required this.price,
    required this.minutes,
    this.description = '',
    this.onTap,
  });
  final String name;
  final String description;
  final double price;
  final int minutes;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final language = context.watch<LanguageProvider>().language;
    final tokens = context.appTokens;
    final bookable = onTap != null;
    return Opacity(
      opacity: bookable ? 1 : .6,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: _bookingCardDecoration(tokens),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: tokens.accent.withValues(alpha: .13),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: AppIcon(
                  Icons.content_cut,
                  size: 20,
                  color: tokens.accent,
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (description.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        description,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: tokens.textSecondary,
                        ),
                      ),
                    ],
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        AppIcon(
                          Icons.schedule_outlined,
                          size: 12,
                          color: tokens.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$minutes ${pickTr(language, tk: 'min', ru: 'мин', en: 'min')}',
                          style: TextStyle(
                            fontSize: 12,
                            color: tokens.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${formatMoney(price)} ${context.watch<AppSettingsProvider>().currencyLabel(language)}',
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w800,
                      color: tokens.accent,
                    ),
                  ),
                  if (bookable) ...[
                    const SizedBox(height: 4),
                    AppIcon(
                      Icons.chevron_right,
                      size: 16,
                      color: tokens.disabled,
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
