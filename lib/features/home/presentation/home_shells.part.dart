part of '../../../app/komekci_app.dart';

class ClientHome extends StatefulWidget {
  const ClientHome({super.key});
  @override
  State<ClientHome> createState() => _ClientHomeState();
}

class _ClientHomeState extends State<ClientHome> {
  int tab = 0;
  @override
  Widget build(BuildContext context) {
    final pages = [
      const ClientDashboard(),
      const BookingPage(),
      const ClientHistory(),
      const ClientProfile(),
    ];
    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.white,
      body: SafeArea(bottom: false, child: pages[tab]),
      bottomNavigationBar: GlassNavBar(
        currentIndex: tab,
        onSelected: (v) => setState(() => tab = v),
        icons: const [
          HugeIcons.strokeRoundedHome01,
          HugeIcons.strokeRoundedCalendar01,
          HugeIcons.strokeRoundedClock01,
          HugeIcons.strokeRoundedUser,
        ],
      ),
    );
  }
}

class BookingPage extends StatefulWidget {
  const BookingPage({super.key});
  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  int service = 0;
  int time = 0;
  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(24),
    children: [
      const Text(
        'Book appointment',
        style: TextStyle(fontSize: 27, fontWeight: FontWeight.w700),
      ),
      const SizedBox(height: 7),
      const Text(
        'Aida Saparova · @aida_style',
        style: TextStyle(color: Colors.black54),
      ),
      const SizedBox(height: 26),
      const Text(
        'Select service',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
      ),
      ...[
        'Haircut & styling · 120 TMT',
        'Hair colouring · 280 TMT',
        'Manicure · 150 TMT',
      ].asMap().entries.map(
        (e) => ListTile(
          onTap: () => setState(() => service = e.key),
          title: Text(e.value),
          trailing: service == e.key
              ? const AppIcon(Icons.check_circle, color: gold)
              : null,
        ),
      ),
      const SizedBox(height: 18),
      const Text(
        'Choose a time',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
      ),
      const SizedBox(height: 12),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: ['10:00', '11:30', '14:15', '18:00']
            .asMap()
            .entries
            .map(
              (e) => ChoiceChip(
                label: Text(e.value),
                selected: time == e.key,
                onSelected: (_) => setState(() => time = e.key),
              ),
            )
            .toList(),
      ),
      const SizedBox(height: 22),
      PrimaryButton(
        label: 'Confirm booking',
        onTap: () {
          const names = ['Haircut & styling', 'Hair colouring', 'Manicure'];
          const prices = [120.0, 280.0, 150.0];
          const hours = [10, 11, 14, 18];
          context.read<BookingProvider>().create(
            service: names[service],
            startsAt: DateTime(2026, 8, 14, hours[time]),
            price: prices[service],
          );
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text('Appointment booked'),
              content: const Text('Your specialist has been notified.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Done'),
                ),
              ],
            ),
          );
        },
      ),
    ],
  );
}

class MasterHome extends StatefulWidget {
  const MasterHome({super.key});
  @override
  State<MasterHome> createState() => _MasterHomeState();
}

class _MasterHomeState extends State<MasterHome> {
  int tab = 0;
  @override
  Widget build(BuildContext context) {
    // Index 3 ("Müşderi goşmak") is a push-style action, not a persistent tab —
    // the form has its own back arrow and pops rather than swapping content.
    final pages = [
      const ScheduleScreen(),
      const CustomersScreen(),
      const ServicesScreen(),
      const SizedBox.shrink(),
      const CabinetScreen(),
    ];
    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.white,
      body: SafeArea(bottom: false, child: pages[tab]),
      bottomNavigationBar: GlassNavBar(
        currentIndex: tab,
        onSelected: (v) {
          if (v == 3) {
            Navigator.push(context, _pageRoute(const CustomerFormScreen()));
            return;
          }
          setState(() => tab = v);
        },
        icons: const [
          HugeIcons.strokeRoundedCalendar01,
          HugeIcons.strokeRoundedUserGroup,
          HugeIcons.strokeRoundedScissor,
          HugeIcons.strokeRoundedUserAdd01,
          HugeIcons.strokeRoundedUser,
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
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(24),
    children: [
      Text(
        title,
        style: const TextStyle(fontSize: 27, fontWeight: FontWeight.w700),
      ),
      if (subtitle != null) ...[
        const SizedBox(height: 7),
        Text(subtitle!, style: const TextStyle(color: Colors.black54)),
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
            color: Colors.white,
            borderRadius: BorderRadius.circular(17),
            border: Border.all(color: line),
          ),
          child: Row(
            children: [
              const CircleAvatar(
                backgroundColor: Color(0xffE6D2B1),
                child: AppIcon(Icons.person_outline, color: ink),
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
