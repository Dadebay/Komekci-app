part of '../../../app/komekci_app.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneController = TextEditingController();
  bool _showPhoneError = false;
  bool _busy = false;
  String? _serverError;
  Object? _lastRequestError;
  String? _failedPhone;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final language = context.watch<LanguageProvider>().language;
    String t({required String tk, required String ru, required String en}) =>
        pickTr(language, tk: tk, ru: ru, en: en);
    final tokens = context.appTokens;
    return Scaffold(
      backgroundColor: tokens.surface,
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/images/login_hero.png', fit: BoxFit.cover, alignment: const Alignment(0.2, -0.45)),
          ),
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0x22000000), Color(0x00000000), Color(0xAA000000)], stops: [0, .38, 1]),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 18),
                  child: Row(
                    children: [
                      const Text(
                        'KÖMEKÇI',
                        style: TextStyle(color: Colors.white, fontSize: 22, letterSpacing: 2.6, fontWeight: FontWeight.w600),
                      ),
                      const Spacer(),
                    ],
                  ),
                ),
                const Spacer(),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(24, 27, 24, 22),
                  decoration: BoxDecoration(
                    color: tokens.surfaceElevated,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        t(tk: 'Hoş geldiňiz', ru: 'Добро пожаловать', en: 'Welcome'),
                        style: const TextStyle(fontSize: 27, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 7),
                      Text(
                        t(
                          tk: 'Telefon belgiňiz bilen dowam ediň.',
                          ru: 'Продолжите с номером телефона.',
                          en: 'Continue with your phone number.',
                        ),
                        style: TextStyle(color: tokens.textSecondary, fontSize: 14),
                      ),
                      const SizedBox(height: 22),
                      TextField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        inputFormatters: const [_TurkmenPhoneFormatter()],
                        onChanged: (_) {
                          if (_showPhoneError || _serverError != null) {
                            setState(() {
                              _showPhoneError = false;
                              _serverError = null;
                              _lastRequestError = null;
                              _failedPhone = null;
                            });
                          }
                        },
                        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                        decoration: InputDecoration(
                          hintText: '65 65 65 65',
                          hintStyle: TextStyle(color: tokens.textSecondary),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          prefixIcon: phonePrefix(context, fontSize: 17),
                          prefixIconConstraints: phonePrefixConstraints,
                          errorText: _showPhoneError
                              ? t(
                                  tk: '8 sanly telefon belgisini ýazyň',
                                  ru: 'Введите 8-значный номер',
                                  en: 'Enter an 8-digit phone number',
                                )
                              : _serverError,
                          errorMaxLines: 3,
                          filled: true,
                          fillColor: tokens.surfaceElevated,
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: BorderSide(color: tokens.border),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: BorderSide(color: tokens.accent, width: 1.5),
                          ),
                        ),
                      ),
                      if (_lastRequestError != null)
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton.icon(
                            onPressed: _emailErrorReport,
                            icon: const AppIcon(Icons.mail_outline, size: 18),
                            label: Text(t(
                              tk: 'Ýalňyşlygy e-poçta arkaly iber',
                              ru: 'Отправить отчёт об ошибке',
                              en: 'Email error report',
                            )),
                          ),
                        ),
                      const SizedBox(height: 14),
                      PrimaryButton(
                        label: t(tk: 'OTP iber', ru: 'Отправить код', en: 'Send code'),
                        loading: _busy,
                        onTap: _continueToOtp,
                      ),
                      const SizedBox(height: 15),
                      Center(
                        child: Text(
                          t(
                            tk: 'Dowam etmek bilen hyzmat şertlerini kabul edýärsiňiz.',
                            ru: 'Продолжая, вы принимаете условия сервиса.',
                            en: 'By continuing, you accept the terms of service.',
                          ),
                          textAlign: TextAlign.center,
                          style: TextStyle(color: tokens.textSecondary, fontSize: 11, height: 1.35),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _continueToOtp() async {
    if (_busy) return;
    final digits = _phoneController.text.replaceAll(RegExp(r'\D'), '');
    if (digits.length != 8) {
      setState(() => _showPhoneError = true);
      return;
    }
    final auth = context.read<AuthProvider>();
    final language = context.read<LanguageProvider>().language;
    final phone = toApiPhone(digits);
    setState(() {
      _busy = true;
      _serverError = null;
      _lastRequestError = null;
      _failedPhone = null;
    });
    try {
      await auth.requestOtp(phone);
    } catch (error) {
      if (!mounted) return;
      FocusScope.of(context).unfocus();
      setState(() {
        _busy = false;
        _serverError = apiErrorMessage(error, language);
        _lastRequestError = error;
        _failedPhone = phone;
      });
      return;
    }
    if (!mounted) return;
    setState(() => _busy = false);
    Navigator.push(context, pageRoute(OtpScreen(phone: phone, nextBuilder: homeForAccount)));
  }

  Future<void> _emailErrorReport() async {
    final error = _lastRequestError;
    final phone = _failedPhone;
    if (error == null || phone == null) return;

    final apiError = error is ApiException ? error : null;
    final code = apiError?.code ?? error.runtimeType.toString();
    final status = apiError == null || apiError.statusCode == 0
        ? 'No HTTP response'
        : '${apiError.statusCode}';
    final localDigits = phone.replaceAll(RegExp(r'\D'), '').replaceFirst(RegExp(r'^993'), '');
    final maskedPhone = '+993****${localDigits.substring(localDigits.length - 4)}';
    final detail = apiError?.message
            .replaceAll(phone, maskedPhone)
            .replaceAll(localDigits, '********') ??
        error.runtimeType.toString();
    final subject = 'KÖMEKÇI login error [$code]';
    final body = [
      'Time (UTC): ${DateTime.now().toUtc().toIso8601String()}',
      'API request: POST $apiBaseUrl/auth/otp/request',
      'Request body: {"phone":"$maskedPhone"}',
      'HTTP status: $status',
      'Error code: $code',
      'Error detail: $detail',
      'Platform: ${Platform.operatingSystem} ${Platform.operatingSystemVersion}',
      '',
      'OTP codes and session tokens are not included.',
    ].join('\n');
    final uri = Uri(
      scheme: 'mailto',
      path: 'dadebaygurbanow333@gmail.com',
      query: 'subject=${Uri.encodeComponent(subject)}&body=${Uri.encodeComponent(body)}',
    );

    try {
      if (await launchUrl(uri, mode: LaunchMode.externalApplication)) return;
    } catch (_) {
      // No email app is available; keep the report so it can be sent manually.
    }
    await Clipboard.setData(ClipboardData(text: 'To: dadebaygurbanow333@gmail.com\nSubject: $subject\n\n$body'));
    if (!mounted) return;
    final language = context.read<LanguageProvider>().language;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(pickTr(
        language,
        tk: 'E-poçta programmasy tapylmady. Ýalňyşlyk hasabaty göçürildi.',
        ru: 'Почтовое приложение не найдено. Отчёт скопирован.',
        en: 'No email app found. The error report was copied.',
      )),
    ));
  }
}

/// Formats a Turkmen mobile number after its fixed +993 country prefix.
/// The user enters exactly eight digits: 65 65 65 65.
class _TurkmenPhoneFormatter extends TextInputFormatter {
  const _TurkmenPhoneFormatter();

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final rawDigits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final digits = rawDigits.length > 8 ? rawDigits.substring(0, 8) : rawDigits;
    final groups = <String>[];
    for (var index = 0; index < digits.length; index += 2) {
      final end = index + 2 > digits.length ? digits.length : index + 2;
      groups.add(digits.substring(index, end));
    }
    final formatted = groups.join(' ');
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
