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
      setState(
        () => _error = AppStrings.profileNameMustBe250.select(
          context.read<LanguageProvider>().language,
        ),
      );
      return;
    }
    final language = context.read<LanguageProvider>().language;
    final profile = context.read<ClientProfileProvider>();
    final toast = AppToast.of(context);
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
    toast.success(AppStrings.profileProfileSaved.select(language));
    navigator.pop();
  }

  Future<void> _changeAvatar(File file) async {
    final language = context.read<LanguageProvider>().language;
    final toast = AppToast.of(context);
    try {
      await context.read<ClientProfileProvider>().setAvatar(file);
    } catch (error) {
      toast.error(apiErrorMessage(error, language));
    }
  }

  Future<void> _changePhone() async {
    final language = context.read<LanguageProvider>().language;
    final toast = AppToast.of(context);
    if (await showChangePhoneDialog(context)) {
      toast.success(AppStrings.profilePhoneNumberUpdated.select(language));
    }
  }

  @override
  Widget build(BuildContext context) {
    final language = context.watch<LanguageProvider>().language;
    final tokens = context.appTokens;
    final profile = context.watch<ClientProfileProvider>();

    return Scaffold(
      backgroundColor: tokens.surface,
      appBar: CabinetAppBar(
        title: AppStrings.profileEditProfile.select(language),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                children: [
                  Center(
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow:
                            profile.avatar != null || profile.avatarUrl != null
                            ? [
                                BoxShadow(
                                  color: tokens.textPrimary.withValues(
                                    alpha: .16,
                                  ),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ]
                            : null,
                      ),
                      child: AvatarPicker(
                        file: profile.avatar,
                        networkUrl: profile.avatarUrl,
                        onPicked: _changeAvatar,
                        radius: 46,
                      ),
                    ),
                  ),
                  const SizedBox(height: 26),
                  _EditField(
                    label: AppStrings.profileName.select(language),
                    icon: Icons.person_outline,
                    controller: _nameController,
                  ),
                  const SizedBox(height: 14),
                  Text(
                    AppStrings.profilePhoneNumber.select(language),
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                    ),
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
                          AppIcon(
                            Icons.phone_outlined,
                            color: tokens.textPrimary,
                            size: 18,
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              displayPhone(profile.phone),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Text(
                            AppStrings.profileChange.select(language),
                            style: TextStyle(
                              color: tokens.accent,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
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
                label: AppStrings.servicesSave.select(language),
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
