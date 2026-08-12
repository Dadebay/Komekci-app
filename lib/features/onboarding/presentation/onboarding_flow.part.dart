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
                child: AppIcon(item.$3, size: 70, color: ink),
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
                      color: page == i ? ink : line,
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
                      _pageRoute(const RoleScreen()),
                    );
                  } else {
                    setState(() => page++);
                  }
                },
              ),
              TextButton(
                onPressed: () => Navigator.pushReplacement(
                  context,
                  _pageRoute(const RoleScreen()),
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
    final tk = context.watch<LanguageProvider>().isTurkmen;
    final imageHeight = MediaQuery.sizeOf(context).height * .42;
    final slides = widget.isMaster
        ? [
            (
              tk ? 'Işiňizi tertipläň' : 'Организуйте свой день',
              tk
                  ? 'Ýazgylary, boş wagtlary we müşderi maglumatlaryny bir ekrandan dolandyryň.'
                  : 'Управляйте записями, свободным временем и данными клиентов в одном месте.',
              Icons.calendar_today_outlined,
              'assets/images/onboarding_01.png',
            ),
            (
              tk ? 'Müşderileriňizi biliň' : 'Знайте своих клиентов',
              tk
                  ? 'Öňki hyzmatlary we bellikleri görüp, her müşderä has ünsli hyzmat hödürläň.'
                  : 'Смотрите историю услуг и заметки, чтобы делать сервис более персональным.',
              Icons.people_outline,
              'assets/images/onboarding_02.png',
            ),
            (
              tk ? 'Işiňizi hiç wagt sypdyrmaň' : 'Ничего не упускайте',
              tk
                  ? 'Akylly ýatlatmalar we bildirişler günüňizi hemişe tertipde saklar.'
                  : 'Умные напоминания и уведомления помогут держать день под контролем.',
              Icons.notifications_active_outlined,
              'assets/images/onboarding_03.png',
            ),
          ]
        : [
            (
              tk
                  ? 'Öz masteriňiz bilen baglanyşykda boluň'
                  : 'Будьте на связи с мастером',
              tk
                  ? 'Ynanýan masteriňizi saýlaň we birnäçe sekuntda amatly wagtyňyzy belläň.'
                  : 'Выберите мастера, которому доверяете, и забронируйте время за несколько секунд.',
              Icons.favorite_border,
              'assets/images/onboarding_01.png',
            ),
            (
              tk ? 'Amatly wagty saýlaň' : 'Выбирайте удобное время',
              tk
                  ? 'Boş wagtlary göni görüň we günüňize iň amatly sagady aňsatlyk bilen saýlaň.'
                  : 'Сразу смотрите свободные слоты и выбирайте время, которое подходит именно вам.',
              Icons.schedule_outlined,
              'assets/images/onboarding_02.png',
            ),
            (
              tk ? 'Ýazgyňyzy ýatdan çykarmaň' : 'Не забывайте о записи',
              tk
                  ? 'Ýazylan hyzmatlaryňyz üçin wagtynda ýatlatma alyň we meýilnamaňyzy rahat saklaň.'
                  : 'Получайте напоминания вовремя и спокойно планируйте свой день.',
              Icons.notifications_none,
              'assets/images/onboarding_03.png',
            ),
          ];
    final item = slides[page];
    return Scaffold(
      backgroundColor: const Color(0xffFBF1E7),
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
                  style: const TextStyle(color: Colors.black54, height: 1.45),
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
                        color: i == page ? gold : line,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                PrimaryButton(
                  label: page == 2
                      ? (tk ? 'Başla' : 'Начать')
                      : (tk ? 'Dowam et' : 'Продолжить'),
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

  void _finish(BuildContext context) => Navigator.push(
    context,
    _pageRoute(
      widget.isMaster
          ? const MasterPhoneScreen()
          : const ClientRegistrationScreen(),
    ),
  );
}

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({super.key, required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity,
    height: 56,
    child: FilledButton(
      style: FilledButton.styleFrom(
        backgroundColor: ink,
        shape: const StadiumBorder(),
        padding: const EdgeInsets.only(left: 22, right: 10),
      ),
      onPressed: onTap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SizedBox(width: 22),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Gilroy',
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const CircleAvatar(
            backgroundColor: gold,
            child: AppIcon(Icons.arrow_forward, color: ink, size: 20),
          ),
        ],
      ),
    ),
  );
}
