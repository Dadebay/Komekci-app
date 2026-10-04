part of '../../../app/komekci_app.dart';

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
