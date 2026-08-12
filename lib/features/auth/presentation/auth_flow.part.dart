part of '../../../app/komekci_app.dart';

class ClientRegistrationScreen extends StatelessWidget {
  const ClientRegistrationScreen({super.key});
  @override
  Widget build(BuildContext context) => FormScreen(
    title: 'Create your profile',
    subtitle: 'It only takes a minute.',
    fields: const ['Your name', '@ nickname', '+993 phone number'],
    avatar: true,
    action: 'Register',
    onAction: () => Navigator.push(
      context,
      _pageRoute(const OtpScreen(next: ConnectMasterScreen())),
    ),
  );
}

class OtpScreen extends StatelessWidget {
  const OtpScreen({super.key, required this.next});
  final Widget next;
  @override
  Widget build(BuildContext context) => AppScaffold(
    title: 'Verify your number',
    subtitle: 'We sent a 6-digit code to +993 61 123456',
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 30),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List<Widget>.generate(6, (_) {
            return Container(
              width: 44,
              height: 54,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(13),
                border: Border.all(color: line),
              ),
              child: const Text('•', style: TextStyle(fontSize: 25)),
            );
          }),
        ),
        const SizedBox(height: 16),
        const Text(
          'Resend code in 00:54',
          style: TextStyle(color: Colors.black54),
        ),
        const Spacer(),
        PrimaryButton(
          label: 'Verify',
          onTap: () {
            context.read<AuthProvider>().verifyOtp();
            Navigator.push(context, _pageRoute(next));
          },
        ),
      ],
    ),
  );
}

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
        InkWell(
          onTap: () =>
              Navigator.push(context, _pageRoute(const MasterPreviewScreen())),
          child: const MasterPreviewCard(),
        ),
        const Spacer(),
        TextButton(
          onPressed: () => Navigator.pushAndRemoveUntil(
            context,
            _pageRoute(const ClientHome()),
            (_) => false,
          ),
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
        const Text(
          'Beauty specialist',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        const Text(
          'Hair, colour and styling. I work by appointment in central Ashgabat.',
          style: TextStyle(color: Colors.black54, height: 1.45),
        ),
        const Spacer(),
        PrimaryButton(
          label: 'Send request',
          onTap: () =>
              Navigator.push(context, _pageRoute(const RequestPendingScreen())),
        ),
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
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xffF3E7D2),
            ),
            child: const AppIcon(
              Icons.hourglass_top_rounded,
              size: 38,
              color: gold,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Waiting for confirmation',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 9),
          const Text(
            'Aida will be notified about your request.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black54),
          ),
          const SizedBox(height: 34),
          PrimaryButton(
            label: 'Go to home',
            onTap: () => Navigator.pushAndRemoveUntil(
              context,
              _pageRoute(const ClientHome()),
              (_) => false,
            ),
          ),
        ],
      ),
    ),
  );
}

class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key,
    required this.title,
    this.subtitle,
    required this.child,
  });
  final String title;
  final String? subtitle;
  final Widget child;
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.white,
    appBar: AppBar(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      leading: IconButton(
        icon: const AppIcon(Icons.arrow_back),
        onPressed: () => Navigator.maybePop(context),
      ),
    ),
    body: SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 27, fontWeight: FontWeight.w700),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 7),
              Text(subtitle!, style: const TextStyle(color: Colors.black54)),
            ],
            const SizedBox(height: 18),
            Expanded(child: child),
          ],
        ),
      ),
    ),
  );
}

class FormScreen extends StatelessWidget {
  const FormScreen({
    super.key,
    required this.title,
    this.subtitle,
    required this.fields,
    required this.action,
    required this.onAction,
    this.avatar = false,
  });
  final String title;
  final String? subtitle;
  final List<String> fields;
  final String action;
  final VoidCallback onAction;
  final bool avatar;
  @override
  Widget build(BuildContext context) => AppScaffold(
    title: title,
    subtitle: subtitle,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (avatar) ...[
          const SizedBox(height: 14),
          const Center(
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 48,
                  backgroundColor: Color(0xffE6D2B1),
                  child: AppIcon(Icons.person_outline, size: 42, color: ink),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: CircleAvatar(
                    radius: 16,
                    backgroundColor: ink,
                    child: AppIcon(
                      Icons.camera_alt_outlined,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 25),
        ],
        ...fields.map(
          (label) => Padding(
            padding: const EdgeInsets.only(bottom: 13),
            child: Field(label: label),
          ),
        ),
        const Spacer(),
        PrimaryButton(label: action, onTap: onAction),
      ],
    ),
  );
}

class Field extends StatelessWidget {
  const Field({super.key, required this.label, this.icon});
  final String label;
  final IconData? icon;
  @override
  Widget build(BuildContext context) => TextField(
    decoration: InputDecoration(
      prefixIcon: icon == null ? null : AppIcon(icon!),
      labelText: label,
      floatingLabelBehavior: FloatingLabelBehavior.never,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: line),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: line),
      ),
    ),
  );
}

class SelectRow extends StatelessWidget {
  const SelectRow({
    super.key,
    required this.flag,
    required this.label,
    required this.onTap,
    this.selected = false,
  });
  final String flag;
  final String label;
  final VoidCallback onTap;
  final bool selected;
  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    child: Container(
      height: 66,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: selected ? gold : line),
      ),
      child: Row(
        children: [
          Text(flag, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 14),
          Text(label, style: const TextStyle(fontSize: 17)),
          const Spacer(),
          if (selected) const AppIcon(Icons.check_circle, color: gold),
        ],
      ),
    ),
  );
}

class MasterPreviewCard extends StatelessWidget {
  const MasterPreviewCard({super.key});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(15),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: line),
    ),
    child: const Row(
      children: [
        CircleAvatar(
          radius: 27,
          backgroundColor: Color(0xffE6D2B1),
          child: AppIcon(Icons.face_2_outlined, color: ink),
        ),
        SizedBox(width: 13),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Aida Saparova', style: TextStyle(fontSize: 17)),
              SizedBox(height: 3),
              Text(
                '@aida_style · Ashgabat',
                style: TextStyle(color: Colors.black54),
              ),
            ],
          ),
        ),
        AppIcon(Icons.chevron_right),
      ],
    ),
  );
}

class HeroPhoto extends StatelessWidget {
  const HeroPhoto({super.key});
  @override
  Widget build(BuildContext context) => Container(
    height: 210,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(24),
      image: const DecorationImage(
        image: AssetImage('assets/images/inspiration_02.jpeg'),
        fit: BoxFit.cover,
      ),
    ),
  );
}
