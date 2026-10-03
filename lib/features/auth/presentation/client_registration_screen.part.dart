part of '../../../app/komekci_app.dart';

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
  bool _submitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _nicknameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final language = context.watch<LanguageProvider>().language;
    String t({required String tk, required String ru, required String en}) => pickTr(language, tk: tk, ru: ru, en: en);

    return AppScaffold(
      title: t(tk: 'Profiliňizi dörediň', ru: 'Создайте профиль', en: 'Create your profile'),
      subtitle: t(tk: 'Bary-ýogy bir minut gerek', ru: 'Это займёт одну минуту', en: 'It only takes a minute'),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 14),
            Center(
              child: AvatarPicker(
                file: _photo,
                radius: 48,
                onPicked: (file) => setState(() {
                  _photo = file;
                  _photoError = null;
                }),
              ),
            ),
            if (_photoError != null) Center(child: _FieldError(_photoError!)),
            const SizedBox(height: 25),
            Field(
              label: t(tk: 'Adyňyz', ru: 'Ваше имя', en: 'Your name'),
              controller: _nameController,
              onChanged: (_) {
                if (_nameError != null) {
                  setState(() => _nameError = _validateName(t));
                }
              },
            ),
            if (_nameError != null) _FieldError(_nameError!),
            const SizedBox(height: 13),
            Field(
              label: t(tk: '@ nickname', ru: '@ никнейм', en: '@ nickname'),
              controller: _nicknameController,
              onChanged: (_) {
                if (_nicknameError != null) {
                  setState(() {
                    _nicknameError = _validateNickname(t);
                    _nicknameSuggestions = const [];
                  });
                }
              },
            ),
            if (_nicknameError != null) ...[
              _FieldError(_nicknameError!),
              _NicknameSuggestionChips(
                suggestions: _nicknameSuggestions,
                onPick: (value) => setState(() {
                  _nicknameController.text = value;
                  _nicknameSuggestions = const [];
                  _nicknameError = _validateNickname(t);
                }),
              ),
            ],
            const SizedBox(height: 13),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              inputFormatters: [_PhoneNumberFormatter()],
              onChanged: (_) {
                if (_phoneError != null) {
                  setState(() => _phoneError = _validatePhone(t));
                }
              },
              decoration: InputDecoration(
                labelText: t(tk: 'Telefon belgiňiz', ru: 'Номер телефона', en: 'Phone number'),
                floatingLabelBehavior: FloatingLabelBehavior.never,
                prefixText: '+993 ',
                prefixStyle: TextStyle(color: context.appTokens.textPrimary, fontSize: 16),
              ),
            ),
            if (_phoneError != null) _FieldError(_phoneError!),
            const SizedBox(height: 22),
            if (_formError != null) ...[
              _FieldError(_formError!),
              const SizedBox(height: 12),
            ],
            SizedBox(
              width: double.infinity,
              height: 56,
              child: FilledButton(
                style: FilledButton.styleFrom(backgroundColor: context.appTokens.textPrimary, shape: const StadiumBorder()),
                onPressed: _submitting ? null : () => _submit(t),
                child: _submitting
                    ? SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.4, color: context.appTokens.surface))
                    : Text(
                        t(tk: 'Hasaba durmak', ru: 'Зарегистрироваться', en: 'Register'),
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  String? _validateName(String Function({required String tk, required String ru, required String en}) t) {
    final length = _nameController.text.trim().length;
    if (length < 2 || length > 50) {
      return t(tk: 'Ady 2-50 harp aralygynda giriziň', ru: 'Имя должно быть от 2 до 50 символов', en: 'Name must be 2-50 characters');
    }
    return null;
  }

  String? _validateNickname(String Function({required String tk, required String ru, required String en}) t) {
    final value = _nicknameController.text.trim().toLowerCase().replaceFirst('@', '');
    if (!nicknamePattern.hasMatch(value)) {
      return t(
        tk: '3-20 harp: kiçi harp, san we _ (sanly başlanyp bilmez)',
        ru: '3-20 символов: строчные буквы, цифры и _ (не с цифры)',
        en: '3-20 chars: lowercase letters, numbers and _ (no leading digit)',
      );
    }
    return null;
  }

  String? _validatePhone(String Function({required String tk, required String ru, required String en}) t) {
    final digits = _phoneController.text.replaceAll(RegExp(r'\D'), '');
    if (digits.length != 8) {
      return t(tk: 'Telefon belgini dolduryň (8 san)', ru: 'Введите номер полностью (8 цифр)', en: 'Enter the full number (8 digits)');
    }
    return null;
  }

  Future<void> _submit(String Function({required String tk, required String ru, required String en}) t) async {
    final nameError = _validateName(t);
    final nicknameError = _validateNickname(t);
    final phoneError = _validatePhone(t);
    setState(() {
      _nameError = nameError;
      _nicknameError = nicknameError;
      _phoneError = phoneError;
      _formError = null;
    });
    if (nameError != null || nicknameError != null || phoneError != null) {
      return;
    }

    final language = context.read<LanguageProvider>().language;
    final auth = context.read<AuthProvider>();
    final authRepository = context.read<AuthRepository>();
    final phone = toApiPhone(_phoneController.text);
    final nickname = _nicknameController.text.trim().toLowerCase().replaceFirst('@', '');
    final data = RegistrationData(
      role: 'client',
      name: _nameController.text.trim(),
      nickname: nickname,
      phone: phone,
      locale: language.name,
      photoPath: _photo?.path,
    );
    setState(() => _submitting = true);
    try {
      final check = await authRepository.nicknameAvailable(nickname);
      if (!check.available) {
        if (!mounted) return;
        setState(() {
          _submitting = false;
          _nicknameSuggestions = check.suggestions;
          _nicknameError = t(tk: 'Bu nickname eýesiz däl', ru: 'Этот никнейм уже занят', en: 'This nickname is taken');
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
