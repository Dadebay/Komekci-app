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
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.length < 2 || name.length > 50) {
      setState(() => _error = pickTr(
        context.read<LanguageProvider>().language,
        tk: 'Ady 2-50 harp aralygynda giriziň',
        ru: 'Имя должно быть от 2 до 50 символов',
        en: 'Name must be 2-50 characters',
      ));
      return;
    }
    final language = context.read<LanguageProvider>().language;
    final profile = context.read<ClientProfileProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await profile.save(name: name);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _error = apiErrorMessage(error, language);
      });
      return;
    }
    messenger.showSnackBar(
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
    navigator.pop();
  }

  Future<void> _changeAvatar(File file) async {
    final language = context.read<LanguageProvider>().language;
    final messenger = ScaffoldMessenger.of(context);
    try {
      await context.read<ClientProfileProvider>().setAvatar(file);
    } catch (error) {
      messenger.showSnackBar(SnackBar(content: Text(apiErrorMessage(error, language))));
    }
  }

  Future<void> _changePhone() async {
    final language = context.read<LanguageProvider>().language;
    final messenger = ScaffoldMessenger.of(context);
    if (await showChangePhoneDialog(context)) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            pickTr(
              language,
              tk: 'Telefon belgisi üýtgedildi.',
              ru: 'Номер телефона изменён.',
              en: 'Phone number updated.',
            ),
          ),
        ),
      );
    }
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
                      networkUrl: profile.avatarUrl,
                      onPicked: _changeAvatar,
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
                  Text(
                    t(tk: 'Telefon belgiňiz', ru: 'Номер телефона', en: 'Phone number'),
                    style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 7),
                  InkWell(
                    onTap: _changePhone,
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      height: 52,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: tokens.surfaceElevated,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: tokens.border),
                      ),
                      child: Row(
                        children: [
                          AppIcon(Icons.phone_outlined, color: tokens.textPrimary, size: 18),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              displayPhone(profile.phone),
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                            ),
                          ),
                          Text(
                            t(tk: 'Üýtget', ru: 'Изменить', en: 'Change'),
                            style: TextStyle(color: tokens.accent, fontWeight: FontWeight.w600, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (_error != null) _FieldError(_error!),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 6, 20, 14),
              child: PrimaryButton(
                label: t(tk: 'Ýatda sakla', ru: 'Сохранить', en: 'Save'),
                loading: _saving,
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
  });
  final String label;
  final IconData icon;
  final TextEditingController controller;

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
