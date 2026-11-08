part of '../../../app/komekci_app.dart';

/// Floating, blurred-backdrop sheet used by the settings pickers (language,
/// appearance). Pops with the value passed to [Navigator.pop].
Future<T?> _showFloatingSheet<T>(
  BuildContext context, {
  required IconData icon,
  required String title,
  required String subtitle,
  required WidgetBuilder builder,
}) {
  return showGeneralDialog<T>(
    context: context,
    useRootNavigator: true,
    barrierDismissible: true,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: Colors.black.withValues(alpha: .24),
    transitionDuration: const Duration(milliseconds: 260),
    transitionBuilder: (context, animation, secondaryAnimation, child) => child,
    pageBuilder: (sheetContext, animation, secondaryAnimation) =>
        _FloatingSheetOverlay(
          animation: animation,
          icon: icon,
          title: title,
          subtitle: subtitle,
          builder: builder,
        ),
  );
}

class _FloatingSheetOverlay extends StatelessWidget {
  const _FloatingSheetOverlay({
    required this.animation,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.builder,
  });

  static const _easeOut = Cubic(0.23, 1, 0.32, 1);

  final Animation<double> animation;
  final IconData icon;
  final String title;
  final String subtitle;
  final WidgetBuilder builder;

  @override
  Widget build(BuildContext context) {
    final bottomGap = max(12.0, MediaQuery.viewPaddingOf(context).bottom);
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    return AnimatedBuilder(
      animation: animation,
      child: _FloatingSheet(
        icon: icon,
        title: title,
        subtitle: subtitle,
        builder: builder,
      ),
      builder: (context, sheet) {
        final progress = animation.status == AnimationStatus.reverse
            ? 1 - _easeOut.transform(1 - animation.value)
            : _easeOut.transform(animation.value);
        return SizedBox.expand(
          child: Stack(
            children: [
              Positioned.fill(
                child: Opacity(
                  opacity: progress,
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                    child: const SizedBox.expand(),
                  ),
                ),
              ),
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => Navigator.of(context).pop(),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(12, 0, 12, bottomGap),
                  child: Opacity(
                    opacity: progress,
                    child: FractionalTranslation(
                      translation: Offset(
                        0,
                        reduceMotion ? 0 : (1 - progress) * .1,
                      ),
                      child: sheet,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _FloatingSheet extends StatelessWidget {
  const _FloatingSheet({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.builder,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final WidgetBuilder builder;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    return Material(
      color: tokens.surface,
      borderRadius: BorderRadius.circular(32),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 390,
          maxHeight: MediaQuery.sizeOf(context).height * .8,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: 52,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: tokens.accent.withValues(alpha: .14),
                        shape: BoxShape.circle,
                      ),
                      child: AppIcon(icon, color: tokens.accent, size: 26),
                    ),
                    Positioned(
                      right: 0,
                      child: Material(
                        color: tokens.surfaceElevated,
                        shape: CircleBorder(
                          side: BorderSide(color: tokens.border),
                        ),
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          onTap: () => Navigator.of(context).pop(),
                          child: SizedBox(
                            width: 38,
                            height: 38,
                            child: Icon(
                              Icons.close,
                              size: 18,
                              color: tokens.textSecondary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: appFontFamily,
                  color: tokens.textPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: appFontFamily,
                  color: tokens.textSecondary,
                  fontSize: 13.5,
                ),
              ),
              const SizedBox(height: 22),
              builder(context),
            ],
          ),
        ),
      ),
    );
  }
}

/// Rounded group holding [_SheetChoiceRow]s separated by thin dividers.
class _SheetChoiceGroup extends StatelessWidget {
  const _SheetChoiceGroup({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    return Material(
      color: tokens.surfaceElevated,
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < children.length; i++) ...[
            children[i],
            if (i < children.length - 1)
              Divider(height: 1, thickness: 1, color: tokens.surface),
          ],
        ],
      ),
    );
  }
}

class _SheetChoiceRow extends StatelessWidget {
  const _SheetChoiceRow({
    required this.leading,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final Widget leading;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    return Semantics(
      button: true,
      selected: selected,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              leading,
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontFamily: appFontFamily,
                        color: tokens.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontFamily: appFontFamily,
                        color: tokens.textSecondary,
                        fontSize: 12.5,
                      ),
                    ),
                  ],
                ),
              ),
              if (selected)
                Icon(Icons.check_rounded, color: tokens.accent, size: 26),
            ],
          ),
        ),
      ),
    );
  }
}

/// Circular flag for an app language, drawn from the bundled SVGs.
class LanguageFlag extends StatelessWidget {
  const LanguageFlag({super.key, required this.language, this.size = 34});

  final AppLanguage language;
  final double size;

  @override
  Widget build(BuildContext context) {
    final code = switch (language) {
      AppLanguage.tk => 'tm',
      AppLanguage.ru => 'ru',
      AppLanguage.en => 'gb',
    };
    return SizedBox.square(
      dimension: size,
      child: ClipOval(
        child: SvgPicture.asset(
          'assets/images/flags/$code.svg',
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
