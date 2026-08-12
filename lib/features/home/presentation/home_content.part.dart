part of '../../../app/komekci_app.dart';

class ClientDashboard extends StatelessWidget {
  const ClientDashboard({super.key});
  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.fromLTRB(24, 24, 24, 110),
    children: [
      const Text(
        'Good morning, Ayna',
        style: TextStyle(fontSize: 27, fontWeight: FontWeight.w700),
      ),
      const SizedBox(height: 6),
      const Text(
        'Your services, on your time.',
        style: TextStyle(color: Colors.black54),
      ),
      const SizedBox(height: 22),
      InkWell(
        onTap: () =>
            Navigator.push(context, _pageRoute(const MasterPreviewScreen())),
        child: const HeroPhoto(),
      ),
      const SizedBox(height: 14),
      const MasterPreviewCard(),
      const SizedBox(height: 24),
      const Text(
        'Next appointment',
        style: TextStyle(fontSize: 19, fontWeight: FontWeight.w600),
      ),
      const SizedBox(height: 10),
      InkWell(
        onTap: () => Navigator.push(
          context,
          _pageRoute(const AppointmentDetailScreen()),
        ),
        child: const AppointmentTile(
          time: '18:00',
          name: 'Computer repair',
          status: 'Expected',
        ),
      ),
      const SizedBox(height: 22),
      PrimaryButton(
        label: 'Choose a category',
        onTap: () =>
            Navigator.push(context, _pageRoute(const CategoryScreen())),
      ),
    ],
  );
}

class ClientHistory extends StatelessWidget {
  const ClientHistory({super.key});
  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.fromLTRB(24, 24, 24, 110),
    children: [
      const Text(
        'Your history',
        style: TextStyle(fontSize: 27, fontWeight: FontWeight.w700),
      ),
      const SizedBox(height: 18),
      const FilterBar(),
      ...[
        '30 July · Manicure · 150 TMT',
        '18 July · Haircut & styling · 120 TMT',
        '4 July · Hair colouring · 280 TMT',
      ].map(
        (x) => InkWell(
          onTap: () => Navigator.push(
            context,
            _pageRoute(HistoryDetailScreen(entry: x)),
          ),
          child: InfoRow(text: x, status: 'Completed'),
        ),
      ),
    ],
  );
}

class CategoryScreen extends StatelessWidget {
  const CategoryScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final isTk = context.watch<LanguageProvider>().isTurkmen;
    final categories = MockCategoryRepository().all();
    return AppScaffold(
      title: isTk ? 'Kategoriýany saýlaň' : 'Выберите категорию',
      subtitle: isTk ? 'Gerekli hyzmaty tapyň' : 'Найдите нужную услугу',
      child: GridView.builder(
        itemCount: categories.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: .95,
        ),
        itemBuilder: (_, index) {
          final category = categories[index];
          return InkWell(
            onTap: () =>
                Navigator.push(context, _pageRoute(const BookingPage())),
            borderRadius: BorderRadius.circular(18),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: line),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    backgroundColor: const Color(0xffF3E7D2),
                    child: AppIcon(
                      index.isEven
                          ? Icons.schedule_outlined
                          : Icons.spa_outlined,
                      color: ink,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    isTk ? category.nameTk : category.nameRu,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    'Explore services',
                    style: TextStyle(color: Colors.black54, fontSize: 12),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class ClientProfile extends StatelessWidget {
  const ClientProfile({super.key});
  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.fromLTRB(24, 24, 24, 110),
    children: [
      const Text(
        'Profile',
        style: TextStyle(fontSize: 27, fontWeight: FontWeight.w700),
      ),
      const SizedBox(height: 17),
      const MasterPreviewCard(),
      const SizedBox(height: 14),
      ...[
        ('My masters', const MyMastersScreen()),
        ('Notifications', const SettingsScreen(title: 'Notifications')),
        ('Appearance', const ThemeScreen()),
        ('Language', const LanguageScreen()),
        ('Support', const SettingsScreen(title: 'Support')),
      ].map(
        (item) => SettingRow(
          label: item.$1,
          onTap: () => Navigator.push(context, _pageRoute(item.$2)),
        ),
      ),
    ],
  );
}

class MasterSchedule extends StatelessWidget {
  const MasterSchedule({super.key});
  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.fromLTRB(24, 24, 24, 110),
    children: [
      const Text(
        'Working schedule',
        style: TextStyle(fontSize: 27, fontWeight: FontWeight.w700),
      ),
      const SizedBox(height: 18),
      ...[
        'Monday — Friday · 09:00 – 19:00',
        'Saturday · 10:00 – 17:00',
        'Sunday · Day off',
      ].map((x) => InfoRow(text: x)),
      SettingRow(
        label: 'Date override / day off',
        onTap: () => Navigator.push(
          context,
          _pageRoute(const SettingsScreen(title: 'Schedule override')),
        ),
      ),
      SettingRow(
        label: 'Vacation',
        onTap: () => Navigator.push(
          context,
          _pageRoute(const SettingsScreen(title: 'Vacation')),
        ),
      ),
    ],
  );
}

class AppointmentTile extends StatelessWidget {
  const AppointmentTile({
    super.key,
    required this.time,
    required this.name,
    required this.status,
  });
  final String time, name, status;
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 10),
    padding: const EdgeInsets.all(15),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(17),
      border: Border.all(color: line),
    ),
    child: Row(
      children: [
        Text(time, style: const TextStyle(fontSize: 16)),
        const SizedBox(width: 14),
        Expanded(child: Text(name)),
        StatusChip(label: status),
        const SizedBox(width: 3),
        const AppIcon(Icons.chevron_right),
      ],
    ),
  );
}

class InfoRow extends StatelessWidget {
  const InfoRow({super.key, required this.text, this.status});
  final String text;
  final String? status;
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 10),
    padding: const EdgeInsets.all(15),
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
        const SizedBox(width: 12),
        Expanded(child: Text(text)),
        if (status != null) StatusChip(label: status!),
        const AppIcon(Icons.chevron_right),
      ],
    ),
  );
}

class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.label});
  final String label;
  @override
  Widget build(BuildContext context) {
    final late = label.startsWith('Late');
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: late ? const Color(0xffFBE3E0) : const Color(0xffFBF1D8),
        borderRadius: BorderRadius.circular(11),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          color: late ? Colors.deepOrange : const Color(0xff77540E),
        ),
      ),
    );
  }
}

class SettingRow extends StatelessWidget {
  const SettingRow({super.key, required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => ListTile(
    onTap: onTap,
    contentPadding: EdgeInsets.zero,
    title: Text(label),
    trailing: const AppIcon(Icons.chevron_right),
  );
}

class FilterBar extends StatelessWidget {
  const FilterBar({super.key});
  @override
  Widget build(BuildContext context) => Wrap(
    spacing: 8,
    children: const [
      Chip(label: Text('All')),
      Chip(label: Text('Completed')),
      Chip(label: Text('Cancelled')),
    ],
  );
}

