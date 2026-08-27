part of '../../../app/komekci_app.dart';

/// Edit the client's own name, phone and photo — reads/writes
/// [ClientProfileProvider], so a change here is reflected immediately on
/// the profile card and the home-tab greeting.
class ClientEditProfileScreen extends StatefulWidget {
  const ClientEditProfileScreen({super.key});

  @override
  State<ClientEditProfileScreen> createState() =>
      _ClientEditProfileScreenState();
}

class _ClientEditProfileScreenState extends State<ClientEditProfileScreen> {
  late final _nameController = TextEditingController(
    text: context.read<ClientProfileProvider>().name,
  );
  late final _phoneController = TextEditingController(
    text: context.read<ClientProfileProvider>().phone,
  );

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _save() {
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    if (name.isEmpty || phone.isEmpty) return;
    context.read<ClientProfileProvider>().update(name: name, phone: phone);
    final language = context.read<LanguageProvider>().language;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          pickTr(
            language,
            tk: 'Profil ýatda saklandy.',
            ru: 'Профиль сохранён.',
            en: 'Profile saved.',
          ),
        ),
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final language = context.watch<LanguageProvider>().language;
    String t({required String tk, required String ru, required String en}) =>
        pickTr(language, tk: tk, ru: ru, en: en);
    final tokens = context.appTokens;
    final profile = context.watch<ClientProfileProvider>();

    return Scaffold(
      backgroundColor: tokens.surface,
      appBar: CabinetAppBar(
        title: t(tk: 'Profili redaktle', ru: 'Редактировать профиль', en: 'Edit profile'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                children: [
                  Center(
                    child: AvatarPicker(
                      file: profile.avatar,
                      onPicked: (file) =>
                          context.read<ClientProfileProvider>().setAvatar(file),
                      radius: 46,
                    ),
                  ),
                  const SizedBox(height: 26),
                  _EditField(
                    label: t(tk: 'Adyňyz', ru: 'Имя', en: 'Name'),
                    icon: Icons.person_outline,
                    controller: _nameController,
                  ),
                  const SizedBox(height: 14),
                  _EditField(
                    label: t(
                      tk: 'Telefon belgiňiz',
                      ru: 'Номер телефона',
                      en: 'Phone number',
                    ),
                    icon: Icons.phone_outlined,
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 6, 20, 14),
              child: PrimaryButton(
                label: t(tk: 'Ýatda sakla', ru: 'Сохранить', en: 'Save'),
                onTap: _save,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EditField extends StatelessWidget {
  const _EditField({
    required this.label,
    required this.icon,
    required this.controller,
    this.keyboardType,
  });
  final String label;
  final IconData icon;
  final TextEditingController controller;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 7),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            prefixIconConstraints: const BoxConstraints.tightFor(
              width: 44,
              height: 44,
            ),
            prefixIcon: SizedBox(
              width: 44,
              height: 44,
              child: Center(
                child: AppIcon(icon, color: tokens.textPrimary, size: 18),
              ),
            ),
            filled: true,
            fillColor: tokens.surfaceElevated,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 15,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: tokens.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: tokens.accent, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
