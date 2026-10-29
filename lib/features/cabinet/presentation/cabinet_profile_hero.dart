part of '../../../app/komekci_app.dart';

class _ProfileHero extends StatelessWidget {
  const _ProfileHero({
    required this.banner,
    required this.bannerUrl,
    required this.avatar,
    required this.avatarUrl,
    required this.nameController,
    required this.nicknameController,
    required this.onPickBanner,
    required this.onPickAvatar,
    required this.bannerLabel,
    required this.bannerHint,
  });

  final File? banner;
  final String? bannerUrl;
  final File? avatar;
  final String? avatarUrl;
  final TextEditingController nameController;
  final TextEditingController nicknameController;
  final VoidCallback onPickBanner;
  final ValueChanged<File> onPickAvatar;
  final String bannerLabel;
  final String bannerHint;

  static const _bannerHeight = 150.0;
  static const _avatarRadius = 42.0;
  static const _avatarRing = 4.0;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    final hasBanner = banner != null || bannerUrl != null;
    final ringSize = (_avatarRadius + _avatarRing) * 2;

    Widget bannerImage() {
      if (banner != null) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(24),

          child: Image.file(banner!, fit: BoxFit.cover),
        );
      }
      if (bannerUrl != null) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Image.network(bannerUrl!, fit: BoxFit.cover, errorBuilder: (_, _, _) => const SizedBox.shrink()),
        );
      }
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // The avatar hangs half its height below the banner, so this stack
        // is taller than the banner by that overhang.
        SizedBox(
          height: _bannerHeight + ringSize / 2,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                left: 0,
                right: 0,
                top: 0,
                height: _bannerHeight,
                child: GestureDetector(
                  onTap: onPickBanner,
                  child: Container(
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: hasBanner ? tokens.accent.withValues(alpha: .6) : tokens.border),
                      color: tokens.surfaceElevated,
                      gradient: tokens.surfaceElevated == tokens.surface
                          ? null
                          : LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [tokens.accent.withValues(alpha: .20), tokens.accent.withValues(alpha: .06)]),
                    ),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        bannerImage(),
                        if (!hasBanner)
                          Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                AppIcon(Icons.image_outlined, size: 28, color: tokens.accent),
                                const SizedBox(height: 8),
                                Text(
                                  bannerLabel,
                                  style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: tokens.textPrimary),
                                ),
                                const SizedBox(height: 3),
                                Text(bannerHint, style: TextStyle(fontSize: 11.5, color: tokens.textSecondary)),
                              ],
                            ),
                          )
                        else
                          Positioned(
                            right: 10,
                            top: 10,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
                              decoration: BoxDecoration(color: Colors.black.withValues(alpha: .55), borderRadius: BorderRadius.circular(20)),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const AppIcon(Icons.photo_camera_outlined, size: 14, color: Colors.white),
                                  const SizedBox(width: 6),
                                  Text(
                                    bannerLabel,
                                    style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 18,
                bottom: 0,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: ringSize,
                      height: ringSize,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: tokens.surface,
                        boxShadow: [
                          BoxShadow(
                            color: tokens.textPrimary.withValues(alpha: avatar != null || avatarUrl != null ? .16 : .08),
                            blurRadius: avatar != null || avatarUrl != null ? 20 : 12,
                            offset: Offset(0, avatar != null || avatarUrl != null ? 8 : 4),
                          ),
                        ],
                      ),
                      child: AvatarPicker(file: avatar, networkUrl: avatarUrl, onPicked: onPickAvatar, radius: _avatarRadius),
                    ),
                    // A fresh photo uploads at once; show that it is going.
                    if (avatar != null)
                      Container(
                        width: _avatarRadius * 2,
                        height: _avatarRadius * 2,
                        decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.black38),
                        child: const Center(
                          child: SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white)),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 4, 0),
          child: ListenableBuilder(
            listenable: Listenable.merge([nameController, nicknameController]),
            builder: (context, _) {
              final name = nameController.text.trim();
              final nickname = nicknameController.text.trim().replaceFirst('@', '');
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name.isEmpty ? '—' : name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: tokens.textPrimary),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    nickname.isEmpty ? '@' : '@$nickname',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 13.5, color: tokens.textSecondary),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

/// A titled card that groups related fields.
class _ProfileSection extends StatelessWidget {
  const _ProfileSection({required this.icon, required this.title, required this.children, this.subtitle, this.backgroundColor});

  final IconData icon;
  final String title;
  final String? subtitle;
  final List<Widget> children;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
      decoration: BoxDecoration(
        color: backgroundColor ?? tokens.surfaceElevated,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: tokens.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 30,
                height: 30,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: tokens.accent.withValues(alpha: .16), borderRadius: BorderRadius.circular(10)),
                child: AppIcon(icon, size: 16, color: tokens.accent),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700, color: tokens.textPrimary),
                ),
              ),
              if (subtitle != null) Text(subtitle!, style: TextStyle(fontSize: 11.5, color: tokens.textSecondary)),
            ],
          ),
          const SizedBox(height: 14),
          for (final child in children) Padding(padding: const EdgeInsets.only(bottom: 14), child: child),
        ],
      ),
    );
  }
}

/// One labelled text field: label above, soft filled input, an optional
/// state icon on the right and hint/error/footer underneath.
