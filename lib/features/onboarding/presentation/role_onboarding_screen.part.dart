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
    String t({required String tk, required String ru, required String en}) =>
        pickTr(language, tk: tk, ru: ru, en: en);
    final tokens = context.appTokens;
    final imageHeight = MediaQuery.sizeOf(context).height * .42;
    final slides = widget.isMaster
        ? [
            (
              t(
                tk: 'Işiňizi tertipläň',
                ru: 'Организуйте свой день',
                en: 'Organise your day',
              ),
              t(
                tk: 'Ýazgylary, boş wagtlary we müşderi maglumatlaryny bir ekrandan dolandyryň.',
                ru: 'Управляйте записями, свободным временем и данными клиентов в одном месте.',
                en: 'Manage bookings, free time and client details all from one screen.',
              ),
              Icons.calendar_today_outlined,
              'assets/images/onboarding_01.png',
            ),
            (
              t(
                tk: 'Müşderileriňizi biliň',
                ru: 'Знайте своих клиентов',
                en: 'Know your clients',
              ),
              t(
                tk: 'Öňki hyzmatlary we bellikleri görüp, her müşderä has ünsli hyzmat hödürläň.',
                ru: 'Смотрите историю услуг и заметки, чтобы делать сервис более персональным.',
                en: 'See past services and notes to make every visit more personal.',
              ),
              Icons.people_outline,
              'assets/images/onboarding_02.png',
            ),
            (
              t(
                tk: 'Işiňizi hiç wagt sypdyrmaň',
                ru: 'Ничего не упускайте',
                en: 'Never miss a booking',
              ),
              t(
                tk: 'Akylly ýatlatmalar we bildirişler günüňizi hemişe tertipde saklar.',
                ru: 'Умные напоминания и уведомления помогут держать день под контролем.',
                en: 'Smart reminders and notifications keep your day on track.',
              ),
              Icons.notifications_active_outlined,
              'assets/images/onboarding_03.png',
            ),
          ]
        : [
            (
              t(
                tk: 'Öz masteriňiz bilen baglanyşykda boluň',
                ru: 'Будьте на связи с мастером',
                en: 'Stay connected with your master',
              ),
              t(
                tk: 'Ynanýan masteriňizi saýlaň we birnäçe sekuntda amatly wagtyňyzy belläň.',
                ru: 'Выберите мастера, которому доверяете, и забронируйте время за несколько секунд.',
                en: 'Pick a master you trust and book your slot in seconds.',
              ),
              Icons.favorite_border,
              'assets/images/onboarding_01.png',
            ),
            (
              t(
                tk: 'Amatly wagty saýlaň',
                ru: 'Выбирайте удобное время',
                en: 'Choose a time that works',
              ),
              t(
                tk: 'Boş wagtlary göni görüň we günüňize iň amatly sagady aňsatlyk bilen saýlaň.',
                ru: 'Сразу смотрите свободные слоты и выбирайте время, которое подходит именно вам.',
                en: 'See open slots at a glance and pick whatever suits your day best.',
              ),
              Icons.schedule_outlined,
              'assets/images/onboarding_02.png',
            ),
            (
              t(
                tk: 'Ýazgyňyzy ýatdan çykarmaň',
                ru: 'Не забывайте о записи',
                en: 'Never forget a booking',
              ),
              t(
                tk: 'Ýazylan hyzmatlaryňyz üçin wagtynda ýatlatma alyň we meýilnamaňyzy rahat saklaň.',
                ru: 'Получайте напоминания вовремя и спокойно планируйте свой день.',
                en: 'Get timely reminders for booked services and plan your day with ease.',
              ),
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
                        color: i == page ? tokens.accent : tokens.border,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                PrimaryButton(
                  label: page == 2
                      ? t(tk: 'Başla', ru: 'Начать', en: 'Get started')
                      : t(tk: 'Dowam et', ru: 'Продолжить', en: 'Continue'),
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
    Navigator.pushAndRemoveUntil(
      context,
      pageRoute(const ClientHome()),
      (_) => false,
    );
  }
}
