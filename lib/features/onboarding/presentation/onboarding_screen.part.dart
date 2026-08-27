part of '../../../app/komekci_app.dart';


class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int page = 0;
  static const slides = [
    (
      'Your time, beautifully organised',
      'Keep every beauty appointment in one private place.',
      Icons.calendar_month_outlined,
    ),
    (
      'Your personal circle',
      'Book only with specialists you know and trust.',
      Icons.people_outline,
    ),
    (
      'Never miss a booking',
      'Smart reminders and earlier-slot notifications.',
      Icons.notifications_none,
    ),
  ];
  @override
  Widget build(BuildContext context) {
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
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xffF3E7D2),
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
                style: const TextStyle(color: Colors.black54, height: 1.5),
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
                label: page == 2 ? 'Get started' : 'Continue',
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
                child: const Text('Skip'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
