part of '../../../app/komekci_app.dart';

class RoleOnboardingScreen extends StatefulWidget {
  const RoleOnboardingScreen({super.key, required this.isMaster});
  final bool isMaster;
  @override
  State<RoleOnboardingScreen> createState() => _RoleOnboardingScreenState();
}

class _RoleOnboardingScreenState extends State<RoleOnboardingScreen>
    with SingleTickerProviderStateMixin {
  int page = 0;
  late final AnimationController controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 550),
  )..forward();
  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final language = context.watch<LanguageProvider>().language;
    final tokens = context.appTokens;
    final imageHeight = MediaQuery.sizeOf(context).height * .42;
    final slides = widget.isMaster
        ? [
            (
              AppStrings.onboardingOrganiseYourDay.select(language),
              AppStrings.onboardingManageBookingsFreeTimeAnd.select(language),
              Icons.calendar_today_outlined,
              'assets/images/onboarding_01.png',
            ),
            (
              AppStrings.onboardingKnowYourClients.select(language),
              AppStrings.onboardingSeePastServicesAndNotes.select(language),
              Icons.people_outline,
              'assets/images/onboarding_02.png',
            ),
            (
              AppStrings.onboardingNeverMissABooking2.select(language),
              AppStrings.onboardingSmartRemindersAndNotificationsKeep.select(language),
              Icons.notifications_active_outlined,
              'assets/images/onboarding_03.png',
            ),
          ]
        : [
            (
              AppStrings.onboardingStayConnectedWithYourMaster.select(language),
              AppStrings.onboardingPickAMasterYouTrust.select(language),
              Icons.favorite_border,
              'assets/images/onboarding_01.png',
            ),
            (
              AppStrings.onboardingChooseATimeThatWorks.select(language),
              AppStrings.onboardingSeeOpenSlotsAtA.select(language),
              Icons.schedule_outlined,
              'assets/images/onboarding_02.png',
            ),
            (
              AppStrings.onboardingNeverForgetABooking.select(language),
              AppStrings.onboardingGetTimelyRemindersForBooked.select(language),
              Icons.notifications_none,
              'assets/images/onboarding_03.png',
            ),
          ];
    final item = slides[page];
    return Scaffold(
      backgroundColor: tokens.surface,
      body: SafeArea(
        child: GestureDetector(
          onHorizontalDragEnd: (details) {
            final velocity = details.primaryVelocity ?? 0;
            if (velocity < -180 && page < 2) _goTo(page + 1);
            if (velocity > 180 && page > 0) _goTo(page - 1);
          },
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const SizedBox(height: 24),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 240),
                  child: FadeTransition(
                    key: ValueKey(page),
                    opacity: controller,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(28),
                      child: Image.asset(
                        item.$4,
                        width: double.infinity,
                        height: imageHeight,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                Text(
                  item.$1,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  item.$2,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: tokens.textSecondary, height: 1.45),
                ),
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    3,
                    (i) => AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      height: 7,
                      width: i == page ? 26 : 7,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: i == page ? tokens.accent : tokens.border,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                PrimaryButton(
                  label: page == 2
                      ? AppStrings.onboardingGetStarted.select(language)
                      : AppStrings.onboardingContinue.select(language),
                  onTap: () {
                    if (page == 2) {
                      _finish(context);
                    } else {
                      _goTo(page + 1);
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _goTo(int targetPage) {
    controller.forward(from: 0);
    setState(() => page = targetPage);
  }

  void _finish(BuildContext context) {
    if (widget.isMaster) {
      Navigator.push(context, pageRoute(const MasterPhoneScreen()));
      return;
    }
    Navigator.push(context, pageRoute(const ClientRegistrationScreen()));
  }
}
