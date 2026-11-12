part of '../../../app/komekci_app.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int page = 0;
  @override
  Widget build(BuildContext context) {
    final language = context.watch<LanguageProvider>().language;
    final slides = [
      (
        AppStrings.onboardingYourTimeBeautifullyOrganised.select(language),
        AppStrings.onboardingKeepEveryBeautyAppointmentIn.select(language),
        Icons.calendar_month_outlined,
      ),
      (
        AppStrings.onboardingYourPersonalCircle.select(language),
        AppStrings.onboardingBookOnlyWithSpecialistsYou.select(language),
        Icons.people_outline,
      ),
      (
        AppStrings.onboardingNeverMissABooking.select(language),
        AppStrings.onboardingSmartRemindersAndEarlierSlot.select(language),
        Icons.notifications_none,
      ),
    ];
    final item = slides[page];
    final tokens = context.appTokens;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),
              Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: tokens.accent.withValues(alpha: .16),
                ),
                child: AppIcon(item.$3, size: 70, color: tokens.textPrimary),
              ),
              const SizedBox(height: 44),
              Text(
                item.$1,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                item.$2,
                textAlign: TextAlign.center,
                style: TextStyle(color: tokens.textSecondary, height: 1.5),
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  3,
                  (i) => Container(
                    width: page == i ? 26 : 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: page == i ? tokens.textPrimary : tokens.border,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 22),
              PrimaryButton(
                label: page == 2
                    ? AppStrings.onboardingGetStarted.select(language)
                    : AppStrings.onboardingContinue.select(language),
                onTap: () {
                  if (page == 2) {
                    Navigator.pushReplacement(
                      context,
                      pageRoute(const RoleScreen()),
                    );
                  } else {
                    setState(() => page++);
                  }
                },
              ),
              TextButton(
                onPressed: () => Navigator.pushReplacement(
                  context,
                  pageRoute(const RoleScreen()),
                ),
                child: Text(AppStrings.onboardingSkip.select(language)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
