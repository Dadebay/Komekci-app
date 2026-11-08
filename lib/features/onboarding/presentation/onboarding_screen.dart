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
    String t({required String tk, required String ru, required String en}) =>
        pickTr(language, tk: tk, ru: ru, en: en);
    final slides = [
      (
        t(
          tk: 'Wagtyňyzy tertipli saklaň',
          ru: 'Ваше время под контролем',
          en: 'Your time, beautifully organised',
        ),
        t(
          tk: 'Ähli gözellik hyzmatlaryna ýazgylaryňyzy bir ýerde saklaň.',
          ru: 'Храните все записи на услуги красоты в одном месте.',
          en: 'Keep every beauty appointment in one private place.',
        ),
        Icons.calendar_month_outlined,
      ),
      (
        t(
          tk: 'Öz masterleriňiz',
          ru: 'Ваш круг мастеров',
          en: 'Your personal circle',
        ),
        t(
          tk: 'Diňe tanaýan we ynanýan hünärmenleriňize ýazylyň.',
          ru: 'Записывайтесь только к знакомым и проверенным специалистам.',
          en: 'Book only with specialists you know and trust.',
        ),
        Icons.people_outline,
      ),
      (
        t(
          tk: 'Ýazgylaryňyzy sypdyrmaň',
          ru: 'Не пропускайте записи',
          en: 'Never miss a booking',
        ),
        t(
          tk: 'Ýatlatmalar we has irki boş wagt barada bildirişler alyň.',
          ru: 'Получайте напоминания и уведомления о более раннем свободном времени.',
          en: 'Smart reminders and earlier-slot notifications.',
        ),
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
                    ? t(tk: 'Başla', ru: 'Начать', en: 'Get started')
                    : t(tk: 'Dowam et', ru: 'Продолжить', en: 'Continue'),
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
                child: Text(t(tk: 'Geç', ru: 'Пропустить', en: 'Skip')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
