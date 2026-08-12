part of '../../../app/komekci_app.dart';

class AppointmentDetailScreen extends StatelessWidget {
  const AppointmentDetailScreen({super.key});
  @override
  Widget build(BuildContext context) => AppScaffold(
    title: 'Your appointment',
    subtitle: 'Friday, 14 August · 18:00',
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const HeroPhoto(),
        const SizedBox(height: 20),
        const Text(
          'Haircut & styling',
          style: TextStyle(fontSize: 23, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 7),
        const Text(
          'Aida Saparova · 120 TMT',
          style: TextStyle(color: Colors.black54),
        ),
        const SizedBox(height: 22),
        const StatusChip(label: 'Expected'),
        const Spacer(),
        OutlinedButton(onPressed: () {}, child: const Text('I’m running late')),
        const SizedBox(height: 10),
        OutlinedButton(
          onPressed: () {},
          child: const Text('Change appointment'),
        ),
        const SizedBox(height: 10),
        TextButton(
          onPressed: () {},
          child: const Center(
            child: Text(
              'Cancel appointment',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ),
      ],
    ),
  );
}

class HistoryDetailScreen extends StatelessWidget {
  const HistoryDetailScreen({super.key, required this.entry});
  final String entry;
  @override
  Widget build(BuildContext context) => AppScaffold(
    title: 'Appointment details',
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const HeroPhoto(),
        const SizedBox(height: 20),
        Text(
          entry,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 9),
        const StatusChip(label: 'Completed'),
        const Spacer(),
        PrimaryButton(
          label: 'Book again',
          onTap: () => Navigator.push(context, _pageRoute(const BookingPage())),
        ),
      ],
    ),
  );
}

class MyMastersScreen extends StatelessWidget {
  const MyMastersScreen({super.key});
  @override
  Widget build(BuildContext context) => AppScaffold(
    title: 'My masters',
    child: Column(
      children: [
        const MasterPreviewCard(),
        const SizedBox(height: 10),
        const InfoRow(text: 'Maral Beauty · Pending request'),
        const Spacer(),
        PrimaryButton(
          label: 'Add master',
          onTap: () =>
              Navigator.push(context, _pageRoute(const ConnectMasterScreen())),
        ),
      ],
    ),
  );
}

class ClientCardScreen extends StatelessWidget {
  const ClientCardScreen({super.key, required this.name});
  final String name;
  @override
  Widget build(BuildContext context) => AppScaffold(
    title: name,
    subtitle: '@${name.toLowerCase().replaceAll(' ', '_')}',
    child: ListView(
      children: [
        const Center(
          child: CircleAvatar(
            radius: 40,
            backgroundColor: Color(0xffE6D2B1),
            child: AppIcon(Icons.person_outline, size: 42, color: ink),
          ),
        ),
        const SizedBox(height: 24),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Stat(label: 'Visits', value: '12'),
            Stat(label: 'Last visit', value: '30 Jul'),
            Stat(label: 'Spend', value: '1,480'),
          ],
        ),
        const SizedBox(height: 25),
        const Text(
          'Booking history',
          style: TextStyle(fontSize: 19, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        const InfoRow(
          text: '30 July · Haircut · Completed',
          status: 'Completed',
        ),
        const InfoRow(
          text: '15 July · Beard shaping · Completed',
          status: 'Completed',
        ),
        const SizedBox(height: 14),
        PrimaryButton(label: 'Create booking', onTap: () {}),
      ],
    ),
  );
}

class Stat extends StatelessWidget {
  const Stat({super.key, required this.label, required this.value});
  final String label, value;
  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text(
        value,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
      ),
      const SizedBox(height: 3),
      Text(label, style: const TextStyle(color: Colors.black54, fontSize: 12)),
    ],
  );
}


class ServiceEditorScreen extends StatelessWidget {
  const ServiceEditorScreen({super.key, required this.name});
  final String name;
  @override
  Widget build(BuildContext context) => FormScreen(
    title: 'Edit service',
    subtitle: name,
    fields: const [
      'Service name',
      'Description',
      'Price (TMT)',
      'Duration (minutes)',
    ],
    action: 'Save changes',
    onAction: () => Navigator.pop(context),
  );
}

class RequestsScreen extends StatelessWidget {
  const RequestsScreen({super.key});
  @override
  Widget build(BuildContext context) => AppScaffold(
    title: 'Connection requests',
    child: ListView(
      children: ['Aman Batyrov', 'Mähri Annayeva']
          .map(
            (name) => ListTile(
              leading: const CircleAvatar(
                backgroundColor: Color(0xffE6D2B1),
                child: AppIcon(Icons.person_outline, color: ink),
              ),
              title: Text(name),
              subtitle: const Text('New client request'),
              trailing: FilledButton(
                onPressed: () {},
                child: const Text('Accept'),
              ),
            ),
          )
          .toList(),
    ),
  );
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key, required this.title});
  final String title;
  @override
  Widget build(BuildContext context) => AppScaffold(
    title: title,
    child: ListView(
      children: [
        const Text(
          'Manage your preferences.',
          style: TextStyle(color: Colors.black54),
        ),
        const SizedBox(height: 18),
        ...[
          'Appointment reminders',
          'Earlier-slot offers',
          'Master messages',
        ].map(
          (x) => SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(x),
            value: true,
            onChanged: (_) {},
          ),
        ),
        const SizedBox(height: 16),
        const Field(label: 'Contact or note'),
      ],
    ),
  );
}

class ThemeScreen extends StatelessWidget {
  const ThemeScreen({super.key});
  @override
  Widget build(BuildContext context) => AppScaffold(
    title: 'Appearance',
    child: ListView(
      children: [
        const Text(
          'Choose a colour theme',
          style: TextStyle(color: Colors.black54),
        ),
        const SizedBox(height: 18),
        ...[
          ('Ivory', cream, ink, KomekciTheme.ivory),
          ('Onyx', const Color(0xff1A1A1C), Colors.white, KomekciTheme.onyx),
          (
            'Champagne',
            const Color(0xffFAF6EE),
            const Color(0xffB9963F),
            KomekciTheme.champagne,
          ),
          (
            'Rose',
            const Color(0xffFCF7F6),
            const Color(0xffB0757C),
            KomekciTheme.rose,
          ),
        ].map(
          (t) => InkWell(
            onTap: () => context.read<ThemeProvider>().select(t.$4),
            borderRadius: BorderRadius.circular(17),
            child: Container(
              height: 72,
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: t.$2,
                borderRadius: BorderRadius.circular(17),
                border: Border.all(color: line),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: t.$3,
                    child: AppIcon(
                      context.watch<ThemeProvider>().selected == t.$4
                          ? Icons.check
                          : Icons.circle_outlined,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Text(t.$1, style: TextStyle(fontSize: 17, color: t.$3)),
                ],
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

// ── Onboarding and registration (mock-data flows) ─────────────────────────
