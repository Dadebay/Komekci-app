part of '../../../app/komekci_app.dart';

class ClientHome extends StatefulWidget {
  const ClientHome({super.key, this.initialTab = 0});
  final int initialTab;
  @override
  State<ClientHome> createState() => _ClientHomeState();
}

class _ClientHomeState extends State<ClientHome> {
  late int tab = widget.initialTab;
  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    final pages = [
      const ClientHomeDashboard(),
      const ClientMastersScreen(),
      const ClientBookingsScreen(),
      const ClientFavoritesScreen(),
      const ClientProfile(),
    ];
    return Scaffold(
      extendBody: true,
      backgroundColor: tokens.surface,
      body: SafeArea(bottom: false, child: pages[tab]),
      bottomNavigationBar: GlassNavBar(
        currentIndex: tab,
        onSelected: (v) => setState(() => tab = v),
        icons: const [
          HugeIcons.strokeRoundedHome01,
          HugeIcons.strokeRoundedUserGroup,
          HugeIcons.strokeRoundedCalendar01,
          HugeIcons.strokeRoundedFavourite,
          HugeIcons.strokeRoundedUser,
        ],
      ),
    );
  }
}

class MasterHome extends StatefulWidget {
  const MasterHome({super.key});
  @override
  State<MasterHome> createState() => _MasterHomeState();
}

class _MasterHomeState extends State<MasterHome> {
  int tab = 0;

  /// Set right before jumping to the Senenama tab from the home dashboard's
  /// day list, so that tab opens on the tapped day instead of "today".
  DateTime? _scheduleInitialDate;

  void _goToSchedule(DateTime day) => setState(() {
    _scheduleInitialDate = day;
    tab = 2;
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    final language = context.watch<LanguageProvider>().language;
    String t({required String tk, required String ru, required String en}) =>
        pickTr(language, tk: tk, ru: ru, en: en);
    // Index 3 ("Müşderi goşmak") is a push-style action, not a persistent tab —
    // the form has its own back arrow and pops rather than swapping content.
    final pages = [
      HomeDashboardScreen(onViewSchedule: _goToSchedule),
      const CustomersScreen(),
      ScheduleScreen(initialDate: _scheduleInitialDate),
      const SizedBox.shrink(),
      const CabinetScreen(),
    ];
    return Scaffold(
      extendBody: true,
      backgroundColor: tokens.surface,
      body: SafeArea(bottom: false, child: pages[tab]),
      bottomNavigationBar: GlassNavBar(
        currentIndex: tab,
        onSelected: (v) {
          if (v == 3) {
            Navigator.push(context, pageRoute(const CustomerFormScreen()));
            return;
          }
          if (v == 2) _scheduleInitialDate = null;
          setState(() => tab = v);
        },
        icons: const [
          HugeIcons.strokeRoundedHome01,
          HugeIcons.strokeRoundedUserGroup,
          HugeIcons.strokeRoundedCalendar01,
          HugeIcons.strokeRoundedUserAdd01,
          HugeIcons.strokeRoundedUser,
        ],
        labels: [
          t(tk: 'Baş sahypa', ru: 'Главная', en: 'Home'),
          t(tk: 'Müşderiler', ru: 'Клиенты', en: 'Customers'),
          t(tk: 'Senenama', ru: 'Календарь', en: 'Calendar'),
          t(tk: 'Müşderi goşmak', ru: 'Добавить клиента', en: 'Add customer'),
          t(tk: 'Kabinet', ru: 'Кабинет', en: 'Cabinet'),
        ],
      ),
    );
  }
}

class PageViewData extends StatelessWidget {
  const PageViewData({
    super.key,
    required this.title,
    this.subtitle,
    this.image = false,
    required this.entries,
  });
  final String title;
  final String? subtitle;
  final bool image;
  final List<String> entries;
  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 27, fontWeight: FontWeight.w700),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 7),
          Text(subtitle!, style: TextStyle(color: tokens.textSecondary)),
        ],
        if (image) ...[
          const SizedBox(height: 22),
          Container(
            height: 145,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              image: const DecorationImage(
                image: AssetImage('assets/images/inspiration_02.jpeg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
        const SizedBox(height: 22),
        ...entries.map(
          (entry) => Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: tokens.surfaceElevated,
              borderRadius: BorderRadius.circular(17),
              border: Border.all(color: tokens.border),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: const Color(0xffE6D2B1),
                  child: AppIcon(
                    Icons.person_outline,
                    color: tokens.textPrimary,
                  ),
                ),
                const SizedBox(width: 13),
                Expanded(child: Text(entry)),
                const AppIcon(Icons.chevron_right),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
