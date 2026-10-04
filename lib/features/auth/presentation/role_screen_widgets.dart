part of '../../../app/komekci_app.dart';

class RoleCard extends StatelessWidget {
  const RoleCard({super.key, required this.selected, required this.imageAsset, required this.title, required this.text, required this.onTap});
  final bool selected;
  final String imageAsset;
  final String title;
  final String text;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: 230,
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: selected ? const Color(0xffFFFCF6) : tokens.surfaceElevated,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: selected ? tokens.accent : tokens.border, width: selected ? 1.6 : 1),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: .025), blurRadius: 8, offset: const Offset(0, 3))],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 110,
              height: 110,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),

                border: Border.all(color: selected ? tokens.accent : const Color(0xffF8F3E9), width: selected ? 2.5 : 1),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(26),
                child: Image.asset(imageAsset, fit: BoxFit.cover, alignment: const Alignment(0, -.45), filterQuality: FilterQuality.medium),
              ),
            ),
            const SizedBox(height: 22),
            Text(
              title,
              style: TextStyle(color: tokens.textPrimary, letterSpacing: .5, fontSize: 13, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11, height: 1.5, color: tokens.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

class RoleContinueButton extends StatefulWidget {
  const RoleContinueButton({super.key, required this.label, required this.onTap, this.fillFraction = .70, this.enabled = true});
  final String label;
  final VoidCallback onTap;
  final double fillFraction;
  final bool enabled;
  @override
  State<RoleContinueButton> createState() => _RoleContinueButtonState();
}

class _RoleContinueButtonState extends State<RoleContinueButton> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 720))..repeat(reverse: true);
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => IgnorePointer(
    ignoring: !widget.enabled,
    child: Opacity(opacity: widget.enabled ? 1 : .38, child: _pill()),
  );

  Widget _pill() {
    final tokens = context.appTokens;
    return InkWell(
      onTap: widget.onTap,
      borderRadius: BorderRadius.circular(32),
      child: Container(
        height: 58,
        decoration: BoxDecoration(color: tokens.textPrimary, borderRadius: BorderRadius.circular(32)),
        child: LayoutBuilder(
          builder: (context, constraints) => Stack(
            children: [
              TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 620),
                curve: Curves.easeOutCubic,
                tween: Tween(begin: .56, end: widget.fillFraction),
                builder: (_, value, _) => AnimatedBuilder(
                  animation: _controller,
                  builder: (_, _) => SizedBox(
                    width: constraints.maxWidth * (value - .025 + (.025 * _controller.value)),
                    height: 58,
                    child: Container(
                      margin: const EdgeInsets.all(2),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(color: tokens.surface, borderRadius: const BorderRadius.all(Radius.circular(30))),
                      child: Text(
                        widget.label,
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: tokens.textPrimary),
                      ),
                    ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: const SizedBox(
                  width: 84,
                  child: Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AppIcon(Icons.chevron_right, color: Color(0xffF7E4BE), size: 16),
                        AppIcon(Icons.chevron_right, color: Color(0xffF7E4BE), size: 16),
                        AppIcon(Icons.chevron_right, color: Color(0xffF7E4BE), size: 16),
                        AppIcon(Icons.chevron_right, color: Color(0xffF7E4BE), size: 16),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
