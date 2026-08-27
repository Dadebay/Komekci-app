part of '../../../app/komekci_app.dart';

class ClientCardScreen extends StatelessWidget {
  const ClientCardScreen({super.key, required this.name});
  final String name;
  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    return AppScaffold(
      title: name,
      subtitle: '@${name.toLowerCase().replaceAll(' ', '_')}',
      child: ListView(
        children: [
          Center(
            child: CircleAvatar(
              radius: 40,
              backgroundColor: const Color(0xffE6D2B1),
              child: AppIcon(
                Icons.person_outline,
                size: 42,
                color: tokens.textPrimary,
              ),
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
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    return AppScaffold(
      title: 'Connection requests',
      child: ListView(
        children: ['Aman Batyrov', 'Mähri Annayeva']
            .map(
              (name) => ListTile(
                leading: CircleAvatar(
                  backgroundColor: const Color(0xffE6D2B1),
                  child: AppIcon(
                    Icons.person_outline,
                    color: tokens.textPrimary,
                  ),
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
}

