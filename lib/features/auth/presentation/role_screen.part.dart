part of '../../../app/komekci_app.dart';

class RoleScreen extends StatefulWidget {
  const RoleScreen({super.key});
  @override
  State<RoleScreen> createState() => _RoleScreenState();
}

class _RoleScreenState extends State<RoleScreen> {
  bool isMaster = false;
  @override
  Widget build(BuildContext context) {
    final tr = Tr(context.watch<LanguageProvider>().language);
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(28, 24, 28, 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(flex: 2),
              const Text('KÖMEKÇI', style: TextStyle(fontSize: 39, letterSpacing: 4, fontWeight: FontWeight.w500)),
              const Spacer(flex: 2),
              Text(tr.chooseRole, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w500)),
              const SizedBox(height: 36),
              Row(
                children: [
                  Expanded(
                    child: RoleCard(
                      selected: isMaster,
                      imageAsset: 'assets/images/role_master.png',
                      title: tr.master,
                      text: tr.masterText,
                      onTap: () {
                        context.read<AuthProvider>().chooseRole(UserRole.master);
                        setState(() => isMaster = true);
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: RoleCard(
                      selected: !isMaster,
                      imageAsset: 'assets/images/role_client.jpg',
                      title: tr.client,
                      text: tr.clientText,
                      onTap: () {
                        context.read<AuthProvider>().chooseRole(UserRole.client);
                        setState(() => isMaster = false);
                      },
                    ),
                  ),
                ],
              ),
              const Spacer(flex: 3),
              RoleContinueButton(
                label: tr.continueText,
                onTap: () {
                  context.read<AuthProvider>().chooseRole(isMaster ? UserRole.master : UserRole.client);
                  Navigator.push(context, _pageRoute(isMaster ? const MasterPhoneScreen() : const RoleOnboardingScreen(isMaster: false)));
                },
              ),
              const SizedBox(height: 9),
              TextButton(
                onPressed: () => Navigator.push(context, _pageRoute(const LoginScreen())),
                child: const Center(child: Text('Hasabyňyz barmy? Giriň')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RoleCard extends StatelessWidget {
  const RoleCard({super.key, required this.selected, required this.imageAsset, required this.title, required this.text, required this.onTap});
  final bool selected;
  final String imageAsset;
  final String title;
  final String text;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(20),
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      height: 230,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: selected ? const Color(0xffFFFCF6) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: selected ? gold : line, width: selected ? 1.6 : 1),
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
              borderRadius: BorderRadius.circular(20),

              border: Border.all(color: selected ? gold : const Color(0xffF8F3E9), width: selected ? 2.5 : 1),
            ),
            child: Image.asset(imageAsset, fit: BoxFit.cover, alignment: const Alignment(0, -.45), filterQuality: FilterQuality.medium),
          ),
          const SizedBox(height: 22),
          Text(
            title,
            style: TextStyle(color: ink, letterSpacing: .5, fontSize: 13, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 11, height: 1.5, color: Colors.black54),
          ),
        ],
      ),
    ),
  );
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
    child: Opacity(
      opacity: widget.enabled ? 1 : .38,
      child: _pill(),
    ),
  );

  Widget _pill() => InkWell(
    onTap: widget.onTap,
    borderRadius: BorderRadius.circular(32),
    child: Container(
      height: 58,
      decoration: BoxDecoration(color: ink, borderRadius: BorderRadius.circular(32)),
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
                    decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.all(Radius.circular(30))),
                    child: Text(
                      widget.label,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: ink),
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

Route<T> _pageRoute<T>(Widget screen) => PageRouteBuilder<T>(
  pageBuilder: (_, animation, _) => FadeTransition(
    opacity: animation,
    child: SlideTransition(
      position: Tween(begin: const Offset(0.04, 0), end: Offset.zero).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
      child: screen,
    ),
  ),
  transitionDuration: const Duration(milliseconds: 220),
);
