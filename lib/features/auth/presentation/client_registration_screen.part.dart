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

  @override
  void dispose() {
    _nicknameDebounce?.cancel();
    _nameController.dispose();
    _nicknameController.dispose();
    _phoneController.dispose();
    super.dispose();
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
                if (_phoneError != null) setState(() => _phoneError = _validatePhone(t));
              },
            ),
            if (_phoneError != null) _FieldError(_phoneError!),
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

  String? _validateName(_Tr t) {
    final length = _nameController.text.trim().length;
    if (length < 2 || length > 50) {
      return t(tk: 'Ady 2-50 harp aralygynda giriziň', ru: 'Имя должно быть от 2 до 50 символов', en: 'Name must be 2-50 characters');
    }
    return null;
  }

  String? _validateNickname(_Tr t) {
    if (!nicknamePattern.hasMatch(_nickname)) {
      return t(
        tk: '3-20 harp: kiçi harp, san we _ (sanly başlanyp bilmez)',
        ru: '3-20 символов: строчные буквы, цифры и _ (не с цифры)',
        en: '3-20 chars: lowercase letters, numbers and _ (no leading digit)',
      );
    }
    if (_nicknameState == _NicknameState.taken) {
      return t(tk: 'Bu lakam eýesiz däl', ru: 'Этот никнейм уже занят', en: 'This nickname is taken');
    }
    return null;
  }

  String? _validatePhone(_Tr t) {
    final digits = _phoneController.text.replaceAll(RegExp(r'\D'), '');
    if (digits.length != 8) {
      return t(tk: 'Telefon belgini dolduryň (8 san)', ru: 'Введите номер полностью (8 цифр)', en: 'Enter the full number (8 digits)');
    }
    return null;
  }

  Future<void> _submit(_Tr t) async {
    final nameError = _validateName(t);
    final nicknameError = _validateNickname(t);
    final phoneError = _validatePhone(t);
    final photoError = _photo == null ? t(tk: 'Profil suraty hökmany', ru: 'Фото профиля обязательно', en: 'A profile photo is required') : null;
    setState(() {
      _nameError = nameError;
      _nicknameError = nicknameError;
      _phoneError = phoneError;
      _photoError = photoError;
      _formError = null;
    });
    if (nameError != null || nicknameError != null || phoneError != null || photoError != null) {
      return;
    }

    final language = context.read<LanguageProvider>().language;
    final auth = context.read<AuthProvider>();
    final authRepository = context.read<AuthRepository>();
    final phone = toApiPhone(_phoneController.text);
    final nickname = _nickname;
    final data = RegistrationData(role: 'client', name: _nameController.text.trim(), nickname: nickname, phone: phone, locale: language.name, photoPath: _photo?.path);
    setState(() => _submitting = true);
    try {
      final check = await authRepository.nicknameAvailable(nickname);
      if (!check.available) {
        if (!mounted) return;
        setState(() {
          _submitting = false;
          _nicknameState = _NicknameState.taken;
          _nicknameSuggestions = check.suggestions;
          _nicknameError = t(tk: 'Bu lakam eýesiz däl', ru: 'Этот никнейм уже занят', en: 'This nickname is taken');
        });
        return;
      }
      await auth.register(data);
    } catch (error) {
      if (!mounted) return;
      _showError(error, language);
      return;
    }
    if (!mounted) return;
    setState(() => _submitting = false);
    Navigator.push(
      context,
      pageRoute(
        OtpScreen(
          phone: phone,
          nextBuilder: (_) => const ConnectMasterScreen(),
          onResend: () async {
            try {
              await auth.requestOtp(phone);
            } on ApiException catch (e) {
              if (e.code != ApiErrors.phoneNotFound) rethrow;
              await auth.register(data);
            }
          },
        ),
      ),
    );
  }

  void _showError(Object error, AppLanguage language) {
    setState(() {
      _submitting = false;
      if (error is ApiException) {
        switch (error.code) {
          case ApiErrors.nicknameTaken:
            _nicknameState = _NicknameState.taken;
            _nicknameSuggestions = error.nicknameSuggestions;
            _nicknameError = error.localized(language);
            return;
          case ApiErrors.phoneTaken:
            _phoneError = error.localized(language);
            return;
          case ApiErrors.validation:
            final fields = error.fieldErrors;
            _nameError = fields['name'];
            _nicknameError = fields['nickname'];
            _phoneError = fields['phone'];
            _photoError = fields['photo'];
            if (fields.isNotEmpty) return;
        }
      }
      _formError = apiErrorMessage(error, language);
    });
  }
}

/// Free nickname alternatives offered by the server after `NICKNAME_TAKEN`.
class _NicknameSuggestionChips extends StatelessWidget {
  const _NicknameSuggestionChips({required this.suggestions, required this.onPick});
  final List<String> suggestions;
  final ValueChanged<String> onPick;

  @override
  Widget build(BuildContext context) {
    if (suggestions.isEmpty) return const SizedBox.shrink();
    final tokens = context.appTokens;
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final s in suggestions)
            InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () => onPick(s),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: tokens.surfaceElevated,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: tokens.border),
                ),
                child: Text('@$s', style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
              ),
            ),
        ],
      ),
    );
  }
}

/// Formats raw digit input as `XX XXXXXX` (max 8 digits) as the user types,
/// so the phone field reads like `+993 XX XXXXXX` end to end.
class _PhoneNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final allDigits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final digits = allDigits.length > 8 ? allDigits.substring(0, 8) : allDigits;
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i == 2) buffer.write(' ');
      buffer.write(digits[i]);
    }
    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.length),
    );
  }
}

class _FieldError extends StatelessWidget {
  const _FieldError(this.message);
  final String message;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 6, left: 4),
    child: Row(
      children: [
        AppIcon(Icons.warning_amber_rounded, size: 13, color: context.appTokens.danger),
        const SizedBox(width: 5),
        Expanded(
          child: Text(message, style: TextStyle(fontSize: 11.5, color: context.appTokens.danger)),
        ),
      ],
    ),
  );
}
