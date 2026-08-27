part of '../../../app/komekci_app.dart';

class ConnectMasterScreen extends StatelessWidget {
  const ConnectMasterScreen({super.key});
  @override
  Widget build(BuildContext context) => AppScaffold(
    title: 'Connect to your master',
    subtitle: 'Enter a nickname or phone number.',
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        const Field(label: 'Search @nickname or phone', icon: Icons.search),
        const SizedBox(height: 20),
        InkWell(onTap: () => Navigator.push(context, pageRoute(const MasterPreviewScreen())), child: const MasterPreviewCard()),
        const Spacer(),
        TextButton(
          onPressed: () => Navigator.pushAndRemoveUntil(context, pageRoute(const ClientHome()), (_) => false),
          child: const Center(child: Text('I’ll connect later')),
        ),
      ],
    ),
  );
}

class MasterPreviewScreen extends StatelessWidget {
  const MasterPreviewScreen({super.key});
  @override
  Widget build(BuildContext context) => AppScaffold(
    title: 'Aida Saparova',
    subtitle: '@aida_style · Ashgabat',
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const HeroPhoto(),
        const SizedBox(height: 20),
        const Text('Beauty specialist', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        const Text('Hair, colour and styling. I work by appointment in central Ashgabat.', style: TextStyle(color: Colors.black54, height: 1.45)),
        const Spacer(),
        PrimaryButton(label: 'Send request', onTap: () => Navigator.push(context, pageRoute(const RequestPendingScreen()))),
      ],
    ),
  );
}

class RequestPendingScreen extends StatelessWidget {
  const RequestPendingScreen({super.key});
  @override
  Widget build(BuildContext context) => AppScaffold(
    title: 'Request sent',
    child: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 90,
            height: 90,
            decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xffF3E7D2)),
            child: AppIcon(Icons.hourglass_top_rounded, size: 38, color: context.appTokens.accent),
          ),
          const SizedBox(height: 24),
          const Text('Waiting for confirmation', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
          const SizedBox(height: 9),
          const Text(
            'Aida will be notified about your request.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black54),
          ),
          const SizedBox(height: 34),
          PrimaryButton(label: 'Go to home', onTap: () => Navigator.pushAndRemoveUntil(context, pageRoute(const ClientHome()), (_) => false)),
        ],
      ),
    ),
  );
}

