part of '../../../app/komekci_app.dart';

enum _NicknameState { idle, checking, free, taken, invalid }

/// Client sign-up: photo, name, @nickname and phone. Submitting calls
/// `POST /auth/register` (role `client`), which sends the SMS code.
///
/// The server requires `photo` ("Поле photo обязательно"), so the photo is
/// required here too and is shrunk under 1 MB when picked.
class ClientRegistrationScreen extends StatefulWidget {
  const ClientRegistrationScreen({super.key});
  @override
  State<ClientRegistrationScreen> createState() => _ClientRegistrationScreenState();
}

class _ClientRegistrationScreenState extends State<ClientRegistrationScreen> {
  final _nameController = TextEditingController();
  final _nicknameController = TextEditingController();
  final _phoneController = TextEditingController();
  File? _photo;
  String? _nameError;
  String? _nicknameError;
  String? _phoneError;
  String? _photoError;
  String? _formError;
  List<String> _nicknameSuggestions = const [];
  _NicknameState _nicknameState = _NicknameState.idle;
  Timer? _nicknameDebounce;
  bool _submitting = false;
  bool _phoneTaken = false;

  @override
  void dispose() {
    _nicknameDebounce?.cancel();
    _nameController.dispose();
    _nicknameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final language = context.read<LanguageProvider>().language;
    final picked = await pickCompressedImage(context, language: language);
    if (picked != null) {
      setState(() {
        _photo = picked;
        _photoError = null;
      });
    }
  }

  String get _nickname => _nicknameController.text.trim().toLowerCase().replaceFirst('@', '');

  /// Checks the format at once and asks the server whether the nickname is
  /// free after a short pause in typing.
  void _onNicknameChanged() {
    _nicknameDebounce?.cancel();
    final value = _nickname;
    if (value.isEmpty) {
      setState(() {
        _nicknameState = _NicknameState.idle;
        _nicknameError = null;
        _nicknameSuggestions = const [];
      });
      return;
    }
    if (!nicknamePattern.hasMatch(value)) {
      setState(() {
        _nicknameState = _NicknameState.invalid;
        _nicknameError = null;
        _nicknameSuggestions = const [];
      });
      return;
    }
    setState(() {
      _nicknameState = _NicknameState.checking;
      _nicknameError = null;
      _nicknameSuggestions = const [];
    });
    final repository = context.read<AuthRepository>();
    _nicknameDebounce = Timer(const Duration(milliseconds: 500), () async {
      try {
        final check = await repository.nicknameAvailable(value);
        if (!mounted || value != _nickname) return;
        setState(() {
          _nicknameState = check.available ? _NicknameState.free : _NicknameState.taken;
          _nicknameSuggestions = check.suggestions;
        });
      } catch (_) {
        // Offline or rate limited: the server re-checks on submit.
        if (mounted && value == _nickname) setState(() => _nicknameState = _NicknameState.idle);
      }
    });
  }

  Widget _label(String text, {bool required = true}) {
    final tokens = context.appTokens;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 2),
      child: Row(
        children: [
          Text(text, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
          if (required)
            Text(
              ' *',
              style: TextStyle(fontSize: 13, color: tokens.danger, fontWeight: FontWeight.w700),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final language = context.watch<LanguageProvider>().language;
    String t({required String tk, required String ru, required String en}) => pickTr(language, tk: tk, ru: ru, en: en);
    final tokens = context.appTokens;

    final nicknameSuffix = switch (_nicknameState) {
      _NicknameState.checking => SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: tokens.textSecondary)),
      _NicknameState.free => AppIcon(Icons.check_circle, size: 20, color: tokens.success),
      _NicknameState.taken || _NicknameState.invalid => AppIcon(Icons.cancel, size: 20, color: tokens.danger),
      _NicknameState.idle => null,
    };
    final nicknameHint = switch (_nicknameState) {
      _NicknameState.free => (t(tk: 'Bu lakam elýeterli', ru: 'Никнейм свободен', en: 'Nickname is available'), tokens.success),
      _NicknameState.taken => (t(tk: 'Bu lakam eýesiz däl', ru: 'Этот никнейм уже занят', en: 'This nickname is taken'), tokens.danger),
      _NicknameState.invalid => (
        t(tk: '3–20 simwol: a–z, 0–9 we _ (sanly başlap bilmez)', ru: '3–20 символов: a–z, 0–9 и _ (не с цифры)', en: '3–20 characters: a–z, 0–9 and _ (no leading digit)'),
        tokens.danger,
      ),
      _ => (t(tk: 'Müşderiler sizi şu lakam bilen tapar', ru: 'Мастера найдут вас по этому никнейму', en: 'Masters will find you by this nickname'), tokens.textSecondary),
    };

    return AppScaffold(
      titleInAppBar: true,
      title: t(tk: 'Profiliňizi dörediň', ru: 'Создайте профиль', en: 'Create your profile'),
      subtitle: t(tk: 'Bary-ýogy bir minut gerek', ru: 'Это займёт одну минуту', en: 'It only takes a minute'),
      child: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            Center(
              // The ring and the caption open the picker too, not only the
              // photo itself.
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _pickPhoto,
                child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
                child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: _photoError != null ? tokens.danger : (_photo != null ? tokens.accent : tokens.border), width: 1.6),
                    ),
                    child: AvatarPicker(
                      file: _photo,
                      radius: 52,
                      onPicked: (file) => setState(() {
                        _photo = file;
                        _photoError = null;
                      }),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _photo == null
                        ? t(tk: 'Profil suratyny goşuň', ru: 'Добавьте фото профиля', en: 'Add a profile photo')
                        : t(tk: 'Suraty üýtgetmek üçin basyň', ru: 'Нажмите, чтобы изменить фото', en: 'Tap to change the photo'),
                    style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: _photoError != null ? tokens.danger : tokens.textSecondary),
                  ),
                  if (_photoError != null) _FieldError(_photoError!),
                ],
              ),
              ),
              ),
            ),
            const SizedBox(height: 26),
            _label(t(tk: 'Adyňyz', ru: 'Ваше имя', en: 'Your name')),
            TextField(
              controller: _nameController,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
              maxLength: 50,
              buildCounter: (_, {required currentLength, required isFocused, maxLength}) => null,
              style: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w600),
              decoration: registrationDecoration(
                tokens,
                hint: t(tk: 'Adyňyzy ýazyň', ru: 'Введите имя', en: 'Enter your name'),
                icon: Icons.person_outline,
                error: _nameError != null,
              ),
              onChanged: (_) {
                if (_nameError != null) setState(() => _nameError = _validateName(t));
              },
            ),
            if (_nameError != null) _FieldError(_nameError!),
            const SizedBox(height: 18),
            _label(t(tk: 'Lakam (nickname)', ru: 'Никнейм', en: 'Nickname')),
            TextField(
              controller: _nicknameController,
              autocorrect: false,
              enableSuggestions: false,
              textInputAction: TextInputAction.next,
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9_@]'))],
              maxLength: 21,
              buildCounter: (_, {required currentLength, required isFocused, maxLength}) => null,
              style: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w600),
              decoration: registrationDecoration(
                tokens,
                hint: 'ayna_style',
                icon: Icons.alternate_email,
                suffix: nicknameSuffix,
                error: _nicknameState == _NicknameState.taken || _nicknameState == _NicknameState.invalid || _nicknameError != null,
              ),
              onChanged: (_) => _onNicknameChanged(),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 6, left: 4),
              child: Text(_nicknameError ?? nicknameHint.$1, style: TextStyle(fontSize: 11.5, height: 1.35, color: _nicknameError != null ? tokens.danger : nicknameHint.$2)),
            ),
            _NicknameSuggestionChips(
              suggestions: _nicknameSuggestions,
              onPick: (value) {
                _nicknameController.text = value;
                _onNicknameChanged();
              },
            ),
            const SizedBox(height: 18),
            _label(t(tk: 'Telefon belgiňiz', ru: 'Номер телефона', en: 'Phone number')),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.done,

              inputFormatters: [_PhoneNumberFormatter()],
              style: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w600),
              decoration: registrationDecoration(tokens, hint: '65 123456', icon: Icons.phone_outlined, prefix: phonePrefix(context, fontSize: 15.5), error: _phoneError != null),
              onChanged: (_) {
                if (_phoneError != null || _phoneTaken) {
                  setState(() {
                    _phoneTaken = false;
                    _phoneError = _validatePhone(t);
                  });
                }
              },
            ),
            if (_phoneError != null) _FieldError(_phoneError!),
            if (_phoneTaken) PhoneTakenNotice(phone: toApiPhone(_phoneController.text)),
            const SizedBox(height: 26),
            if (_formError != null) ...[_FieldError(_formError!), const SizedBox(height: 12)],
            PrimaryButton(
              label: t(tk: 'Hasaba durmak', ru: 'Зарегистрироваться', en: 'Register'),
              loading: _submitting,
              onTap: () => _submit(t),
            ),
            const SizedBox(height: 14),
            Center(
              child: Text(
                t(tk: 'Telefon belgiňize SMS kody iberiler.', ru: 'На ваш номер придёт SMS с кодом.', en: "We'll text a code to your number."),
                style: TextStyle(fontSize: 11.5, color: tokens.textSecondary),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Future<void> _submit(_Tr t) => _submitRegistration(t, update: setState);

}
