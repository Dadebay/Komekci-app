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

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isTurkmen = context.watch<LanguageProvider>().isTurkmen;
    final tokens = context.appTokens;
    return Scaffold(
      backgroundColor: tokens.textPrimary,
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/login_hero.png',
              fit: BoxFit.cover,
              alignment: const Alignment(0.2, -0.45),
            ),
          ),
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0x22000000),
                    Color(0x00000000),
                    Color(0xAA000000),
                  ],
                  stops: [0, .38, 1],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 26,
                    vertical: 18,
                  ),
                  child: Row(
                    children: [
                      const Text(
                        'KÖMEKÇI',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          letterSpacing: 2.6,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        width: 38,
                        height: 38,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: .14),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white24),
                        ),
                        child: const AppIcon(
                          Icons.language,
                          color: Colors.white,
                          size: 19,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(24, 27, 24, 22),
                  decoration: BoxDecoration(
                    color: tokens.surfaceElevated,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(30),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        isTurkmen ? 'Hoş geldiňiz' : 'Добро пожаловать',
                        style: const TextStyle(
                          fontSize: 27,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 7),
                      Text(
                        isTurkmen
                            ? 'Telefon belgiňiz bilen dowam ediň.'
                            : 'Продолжите с номером телефона.',
                        style: TextStyle(
                          color: tokens.textSecondary,
                          fontSize: 14,
                        ),
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
                            });
                          }
                        },
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                        ),
                        decoration: InputDecoration(
                          hintText: '65 65 65 65',
                          hintStyle: const TextStyle(color: Colors.black38),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          prefixText: '+993  ',
                          prefixStyle: TextStyle(
                            color: tokens.textPrimary,
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                          ),
                          errorText: _showPhoneError
                              ? (isTurkmen
                                    ? '8 sanly telefon belgisini ýazyň'
                                    : 'Введите 8-значный номер')
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
                            borderSide: BorderSide(
                              color: tokens.accent,
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      PrimaryButton(
                        label: isTurkmen ? 'OTP iber' : 'Отправить код',
                        loading: _busy,
                        onTap: _continueToOtp,
                      ),
                      const SizedBox(height: 15),
                      Center(
                        child: Text(
                          isTurkmen
                              ? 'Dowam etmek bilen hyzmat şertlerini kabul edýärsiňiz.'
                              : 'Продолжая, вы принимаете условия сервиса.',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.black45,
                            fontSize: 11,
                            height: 1.35,
                          ),
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
    });
    try {
      await auth.requestOtp(phone);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _serverError = apiErrorMessage(error, language);
      });
      return;
    }
    if (!mounted) return;
    setState(() => _busy = false);
    Navigator.push(
      context,
      pageRoute(OtpScreen(phone: phone, nextBuilder: homeForAccount)),
    );
  }
}

/// Formats a Turkmen mobile number after its fixed +993 country prefix.
/// The user enters exactly eight digits: 65 65 65 65.
class _TurkmenPhoneFormatter extends TextInputFormatter {
  const _TurkmenPhoneFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
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
