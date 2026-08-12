part of '../../../app/komekci_app.dart';

/// Master onboarding runs in four steps: 1. phone number, 2. SMS code,
/// 3. profile details, 4. subscription payment.
const _masterSetupSteps = 4;

/// Balance top-ups are sent as an SMS to the operator short code. The message
/// body carries the account number and the chosen amount: "+99362990344 30".
const _topUpShortCode = '0804';
const _topUpAccount = '+99362990344';
const _topUpAmounts = [20, 30, 40, 50];
const _monthlyFee = 20;

class MasterPhoneScreen extends StatefulWidget {
  const MasterPhoneScreen({super.key});

  @override
  State<MasterPhoneScreen> createState() => _MasterPhoneScreenState();
}

class _MasterPhoneScreenState extends State<MasterPhoneScreen> {
  final _phoneController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  bool get _phoneReady => _phoneController.text.replaceAll(RegExp(r'\D'), '').length == 8;

  void _sendCode() {
    if (!_phoneReady) return;
    context.read<AuthProvider>().sendOtp();
    Navigator.push(context, _pageRoute(MasterOtpScreen(phone: '+993 ${_phoneController.text}')));
  }

  @override
  Widget build(BuildContext context) {
    final tk = context.watch<LanguageProvider>().isTurkmen;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _MasterSetupHeader(title: tk ? 'MASTER BELLIGI' : 'РЕГИСТРАЦИЯ МАСТЕРА'),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _MasterProgressIndicator(step: 1),
              const SizedBox(height: 34),
              Text(
                tk ? 'Telefon belgiňizi giriziň' : 'Введите номер телефона',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700, height: 1.25),
              ),
              const SizedBox(height: 10),
              Text(
                tk ? 'Belgiňize tassyklama kody iberiler.' : 'На ваш номер придёт код подтверждения.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.black54, height: 1.45),
              ),
              const SizedBox(height: 30),
              Text(tk ? 'Telefon belgiňiz' : 'Номер телефона', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              const SizedBox(height: 10),
              Container(
                height: 56,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: line),
                ),
                child: Row(
                  children: [
                    const SizedBox(
                      width: 72,
                      child: Center(
                        child: Text('+993', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                      ),
                    ),
                    Container(width: 1, height: 30, color: line),
                    Expanded(
                      child: TextField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        inputFormatters: const [_TurkmenPhoneFormatter()],
                        onChanged: (_) => setState(() {}),
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        decoration: const InputDecoration(
                          hintText: '65 123456',
                          hintStyle: TextStyle(color: Colors.black38, fontWeight: FontWeight.w400),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Text(
                tk ? 'Dogry telefon belgiňizi giriziň. Size kod iberiler.' : 'Введите корректный номер. Мы отправим код.',
                style: const TextStyle(color: Colors.black45, fontSize: 12.5, height: 1.35),
              ),
              const SizedBox(height: 26),
              _MasterActionButton(label: tk ? 'Kod iber' : 'Отправить код', enabled: _phoneReady, onTap: _sendCode),
              const SizedBox(height: 26),
              const _PrivacyNote(),
            ],
          ),
        ),
      ),
    );
  }
}

class MasterOtpScreen extends StatefulWidget {
  const MasterOtpScreen({super.key, required this.phone});
  final String phone;

  @override
  State<MasterOtpScreen> createState() => _MasterOtpScreenState();
}

class _MasterOtpScreenState extends State<MasterOtpScreen> {
  final _codeControllers = List.generate(4, (_) => TextEditingController());
  final _codeNodes = List.generate(4, (_) => FocusNode());
  int _secondsLeft = 45;
  Timer? _resendTimer;

  @override
  void initState() {
    super.initState();
    _startCountdown();
    WidgetsBinding.instance.addPostFrameCallback((_) => _codeNodes.first.requestFocus());
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    for (final controller in _codeControllers) {
      controller.dispose();
    }
    for (final node in _codeNodes) {
      node.dispose();
    }
    super.dispose();
  }

  bool get _codeReady => _codeControllers.every((controller) => controller.text.isNotEmpty);

  void _startCountdown() {
    setState(() => _secondsLeft = 45);
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsLeft == 0) {
        timer.cancel();
        return;
      }
      setState(() => _secondsLeft -= 1);
    });
  }

  void _resend() {
    context.read<AuthProvider>().sendOtp();
    _startCountdown();
  }

  void _verify() {
    if (!_codeReady) return;
    context.read<AuthProvider>().verifyOtp();
    Navigator.push(context, _pageRoute(const MasterRegistrationScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final tk = context.watch<LanguageProvider>().isTurkmen;
    final countdown = '${(_secondsLeft ~/ 60).toString().padLeft(2, '0')}:${(_secondsLeft % 60).toString().padLeft(2, '0')}';
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _MasterSetupHeader(title: tk ? 'TASSYKLAMA' : 'ПОДТВЕРЖДЕНИЕ'),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _MasterProgressIndicator(step: 2),
              const SizedBox(height: 34),
              Text(
                tk ? 'Telefon belgiňizi tassyklaň' : 'Подтвердите номер телефона',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700, height: 1.25),
              ),
              const SizedBox(height: 10),
              Text.rich(
                TextSpan(
                  style: const TextStyle(color: Colors.black54, height: 1.45, fontFamily: 'Gilroy'),
                  children: [
                    TextSpan(text: tk ? 'Size SMS arkaly iberilen 4 belgili kody giriziň.\n' : 'Введите 4-значный код из SMS.\n'),
                    TextSpan(
                      text: widget.phone,
                      style: const TextStyle(color: ink, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: List.generate(4, (index) => _codeBox(index))),
              const SizedBox(height: 20),
              Row(
                children: [
                  Text(tk ? 'Kod gelmedi?' : 'Код не пришёл?', style: const TextStyle(color: Colors.black54, fontSize: 13)),
                  const SizedBox(width: 6),
                  GestureDetector(
                    onTap: _secondsLeft == 0 ? _resend : null,
                    child: Text(
                      tk ? 'Kody täzeden iber' : 'Отправить снова',
                      style: TextStyle(color: _secondsLeft == 0 ? gold : Colors.black26, fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text('($countdown)', style: const TextStyle(color: Colors.black45, fontSize: 13)),
                ],
              ),
              const SizedBox(height: 26),
              _MasterActionButton(label: tk ? 'Tassyklaň' : 'Подтвердить', enabled: _codeReady, onTap: _verify),
              const SizedBox(height: 26),
              const _PrivacyNote(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _codeBox(int index) => SizedBox(
    width: 66,
    height: 92,
    child: TextField(
      controller: _codeControllers[index],
      focusNode: _codeNodes[index],
      textAlign: TextAlign.center,
      keyboardType: TextInputType.number,
      maxLength: 1,
      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
      onChanged: (value) {
        if (value.isNotEmpty && index < 3) {
          _codeNodes[index + 1].requestFocus();
        } else if (value.isEmpty && index > 0) {
          _codeNodes[index - 1].requestFocus();
        }
        setState(() {});
      },
      decoration: InputDecoration(
        counterText: '',
        contentPadding: EdgeInsets.symmetric(vertical: 17, horizontal: 16),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: line),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: gold, width: 1.6),
        ),
      ),
    ),
  );
}

class _PrivacyNote extends StatelessWidget {
  const _PrivacyNote();

  @override
  Widget build(BuildContext context) {
    final tk = context.watch<LanguageProvider>().isTurkmen;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 30,
          height: 30,
          alignment: Alignment.center,
          decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xffF8F3E9)),
          child: const AppIcon(Icons.lock_outline, color: gold, size: 15),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Text(
            tk ? 'Siziň maglumatlaryňyz ygtybarly saklanýar we üçünji taraplar bilen paýlaşylmaýar.' : 'Ваши данные хранятся надёжно и не передаются третьим лицам.',
            style: const TextStyle(color: Colors.black45, fontSize: 12, height: 1.4),
          ),
        ),
      ],
    );
  }
}

class MasterRegistrationScreen extends StatefulWidget {
  const MasterRegistrationScreen({super.key});

  @override
  State<MasterRegistrationScreen> createState() => _MasterRegistrationScreenState();
}

class _MasterRegistrationScreenState extends State<MasterRegistrationScreen> {
  /// Every field except the last (social links) has to be filled before the
  /// master can move on to payment.
  static const _optionalIndex = 4;
  static const _icons = [Icons.person_outline, Icons.account_box_outlined, Icons.location_on_outlined, Icons.edit_outlined, Icons.link_outlined];

  final _controllers = List.generate(5, (_) => TextEditingController());
  bool _showErrors = false;
  File? _photo;

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  bool _missing(int index) => index != _optionalIndex && _controllers[index].text.trim().isEmpty;
  bool get _complete => !List.generate(_controllers.length, _missing).contains(true);

  void _continue() {
    if (!_complete) {
      setState(() => _showErrors = true);
      return;
    }
    Navigator.push(context, _pageRoute(const MasterSubscriptionScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final tk = context.watch<LanguageProvider>().isTurkmen;
    final fields = tk
        ? ['Adyňyz', '@ lakamyňyz', 'Iş salgyňyz', 'Özüňiz barada', 'Instagram / TikTok (islege görä)']
        : ['Имя', '@ никнейм', 'Рабочий адрес', 'Описание', 'Instagram / TikTok (необязательно)'];
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _MasterSetupHeader(title: tk ? 'MASTER HASABY' : 'ПРОФИЛЬ МАСТЕРА'),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
          child: Column(
            children: [
              const _MasterProgressIndicator(step: 3),
              const SizedBox(height: 30),
              SizedBox(
                width: 158,
                child: PhotoUploadBox(
                  file: _photo,
                  onPicked: (file) => setState(() => _photo = file),
                  title: tk ? 'Profil suraty' : 'Фото профиля',
                  height: 128,
                  radius: 35,
                ),
              ),
              const SizedBox(height: 24),
              ...List.generate(fields.length, (index) {
                final invalid = _showErrors && _missing(index);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: TextField(
                    controller: _controllers[index],
                    onChanged: (_) => setState(() {}),
                    maxLines: index == 3 ? 3 : 1,
                    decoration: InputDecoration(
                      hintText: fields[index],
                      hintStyle: const TextStyle(color: Colors.black38, fontSize: 14),
                      errorText: invalid ? (tk ? 'Bu meýdan hökmany' : 'Обязательное поле') : null,
                      errorStyle: const TextStyle(fontSize: 11.5),
                      prefixIconConstraints: const BoxConstraints.tightFor(width: 44, height: 44),
                      prefixIcon: SizedBox(
                        width: 44,
                        height: 44,
                        child: Center(child: AppIcon(_icons[index], color: invalid ? const Color(0xffC0392B) : ink, size: 19)),
                      ),
                      filled: true,
                      fillColor: const Color(0xffFCFBF8),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 17),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: const BorderSide(color: line),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: const BorderSide(color: line),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: const BorderSide(color: gold, width: 1.5),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: const BorderSide(color: Color(0xffC0392B)),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: const BorderSide(color: Color(0xffC0392B), width: 1.5),
                      ),
                    ),
                  ),
                );
              }),
              const SizedBox(height: 6),
              AnimatedOpacity(
                duration: const Duration(milliseconds: 220),
                opacity: _complete ? 0 : 1,
                child: Text(
                  tk ? 'Töleg sahypasyna geçmek üçin ähli hökmany meýdanlary dolduryň.' : 'Заполните обязательные поля, чтобы перейти к оплате.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.black45, fontSize: 12, height: 1.4),
                ),
              ),
              const SizedBox(height: 14),
              RoleContinueButton(label: tk ? 'Dowam et' : 'Продолжить', fillFraction: .70, enabled: _complete, onTap: _continue),
            ],
          ),
        ),
      ),
    );
  }
}

class MasterSubscriptionScreen extends StatefulWidget {
  const MasterSubscriptionScreen({super.key});

  @override
  State<MasterSubscriptionScreen> createState() => _MasterSubscriptionScreenState();
}

class _MasterSubscriptionScreenState extends State<MasterSubscriptionScreen> {
  int _amount = _topUpAmounts.first;
  bool _payByPhone = true;

  /// How long the chosen top-up keeps the 20 manat / month subscription running.
  String _coverageText(bool tk) {
    final months = _amount ~/ _monthlyFee;
    final remainder = _amount % _monthlyFee;
    if (tk) {
      final base = '$months aýlyk abuna (aýda $_monthlyFee manat)';
      return remainder == 0 ? base : '$base · $remainder manat balansda galýar';
    }
    final base = 'Подписка на $months мес. (по $_monthlyFee манат)';
    return remainder == 0 ? base : '$base · $remainder манат останется на балансе';
  }

  @override
  Widget build(BuildContext context) {
    final tk = context.watch<LanguageProvider>().isTurkmen;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _MasterSetupHeader(title: tk ? 'ABUNA WE TÖLEG' : 'ПОДПИСКА И ОПЛАТА'),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _MasterProgressIndicator(step: 4),
                    const SizedBox(height: 24),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 18),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: line),
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: 64,
                            height: 64,
                            alignment: Alignment.center,
                            decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xffF8F3E9)),
                            child: const Text('♔', style: TextStyle(fontSize: 34, color: gold)),
                          ),
                          const SizedBox(height: 14),
                          Text(tk ? 'MASTER ÜÇIN ABUNA' : 'ПОДПИСКА ДЛЯ МАСТЕРА', style: const TextStyle(fontSize: 13, letterSpacing: .7, fontWeight: FontWeight.w700)),
                          const SizedBox(height: 12),
                          // The headline price follows whichever top-up the master picked.
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 280),
                            switchInCurve: Curves.easeOutCubic,
                            switchOutCurve: Curves.easeInCubic,
                            transitionBuilder: (child, animation) => FadeTransition(
                              opacity: animation,
                              child: SlideTransition(
                                position: Tween(begin: const Offset(0, .3), end: Offset.zero).animate(animation),
                                child: child,
                              ),
                            ),
                            child: RichText(
                              key: ValueKey(_amount),
                              text: TextSpan(
                                style: const TextStyle(fontFamily: 'Gilroy', color: ink),
                                children: [
                                  TextSpan(
                                    text: '$_amount',
                                    style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w700),
                                  ),
                                  TextSpan(
                                    text: tk ? ' manat' : ' манат',
                                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 280),
                            child: Text(
                              _coverageText(tk),
                              key: ValueKey('coverage-$_amount-$tk'),
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.black54, height: 1.4, fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 26),
                    Text(tk ? 'Möçberi saýlaň' : 'Выберите сумму', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 6),
                    Text(tk ? 'Balansyňyzy doldurmak üçin möçberi saýlaň.' : 'Выберите сумму для пополнения баланса.', style: const TextStyle(color: Colors.black45, fontSize: 12.5)),
                    const SizedBox(height: 14),
                    Row(
                      children: _topUpAmounts.map((amount) {
                        final selected = amount == _amount;
                        return Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(right: amount == _topUpAmounts.last ? 0 : 10),
                            child: GestureDetector(
                              onTap: () => setState(() => _amount = amount),
                              child: AnimatedScale(
                                duration: const Duration(milliseconds: 260),
                                curve: Curves.easeOutBack,
                                scale: selected ? 1.04 : 1,
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 260),
                                  curve: Curves.easeOutCubic,
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  decoration: BoxDecoration(
                                    color: selected ? const Color(0xffFDF9F2) : Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: selected ? gold : line, width: selected ? 1.6 : 1),
                                    boxShadow: selected ? [BoxShadow(color: gold.withValues(alpha: .22), blurRadius: 14, offset: const Offset(0, 5))] : null,
                                  ),
                                  child: Column(
                                    children: [
                                      TweenAnimationBuilder<Color?>(
                                        duration: const Duration(milliseconds: 260),
                                        tween: ColorTween(begin: ink, end: selected ? gold : ink),
                                        builder: (_, color, _) => Text(
                                          '$amount',
                                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: color),
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(tk ? 'manat' : 'манат', style: TextStyle(fontSize: 11, color: selected ? gold : Colors.black45)),
                                      const SizedBox(height: 8),
                                      AnimatedContainer(
                                        duration: const Duration(milliseconds: 260),
                                        curve: Curves.easeOutCubic,
                                        width: 20,
                                        height: 20,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: selected ? gold : Colors.transparent,
                                          border: Border.all(color: selected ? gold : line, width: 1.4),
                                        ),
                                        child: AnimatedScale(
                                          duration: const Duration(milliseconds: 260),
                                          curve: Curves.easeOutBack,
                                          scale: selected ? 1 : 0,
                                          child: const AppIcon(Icons.check, color: Colors.white, size: 13),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 26),
                    Text(tk ? 'Töleg usulyny saýlaň' : 'Выберите способ оплаты', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 14),
                    _PaymentMethodTile(
                      icon: Icons.smartphone_outlined,
                      title: tk ? 'Telefon balansy' : 'Баланс телефона',
                      subtitle: tk ? 'SIM kartyňyzyň balansyndan tölän' : 'Оплата с баланса SIM-карты',
                      selected: _payByPhone,
                      onTap: () => setState(() => _payByPhone = true),
                    ),
                    const SizedBox(height: 10),
                    _PaymentMethodTile(
                      icon: Icons.credit_card_outlined,
                      title: tk ? 'Bank kartasy' : 'Банковская карта',
                      subtitle: tk ? 'Halkbank, Rysgal, Senagat bank' : 'Halkbank, Rysgal, Senagat bank',
                      selected: !_payByPhone,
                      onTap: () => setState(() => _payByPhone = false),
                    ),
                    const SizedBox(height: 18),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xffFDF9F2),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xffF0E4CE)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const AppIcon(Icons.info_outline, color: gold, size: 19),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(tk ? 'Balans nähili işleýär?' : 'Как работает баланс?', style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700)),
                                const SizedBox(height: 6),
                                Text(
                                  tk
                                      ? 'Goýan puluňyz balansyňyzda saklanýar. Her aý abuna üçin 20 manat awtomatiki tutulýar. Mysal üçin, balansyňyza 50 manat doldursaňyz, birinji aý 20 manat, indiki aý ýene 20 manat tutulýar. Galan 10 manat balansyňyzda saklanýar.'
                                      : 'Внесённые деньги хранятся на балансе. Каждый месяц за подписку автоматически списывается 20 манат. Например, при пополнении на 50 манат: 20 манат спишется в первый месяц, ещё 20 — во второй, оставшиеся 10 останутся на балансе.',
                                  style: const TextStyle(color: Colors.black54, fontSize: 12, height: 1.5),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
              child: _MasterActionButton(label: tk ? 'Tölegi töle' : 'Оплатить', enabled: true, onTap: _pay),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pay() async {
    if (_payByPhone) {
      await showDialog<void>(
        context: context,
        builder: (_) => _PhonePaymentDialog(amount: _amount),
      );
    } else {
      await showDialog<void>(
        context: context,
        builder: (_) => _BankPickerDialog(amount: _amount),
      );
    }
  }
}

class _PaymentMethodTile extends StatelessWidget {
  const _PaymentMethodTile({required this.icon, required this.title, required this.subtitle, required this.selected, required this.onTap});
  final IconData icon;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: selected ? const Color(0xffFDF9F2) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: selected ? gold : line, width: selected ? 1.6 : 1),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: line),
            ),
            child: AppIcon(icon, color: ink, size: 20),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700)),
                const SizedBox(height: 3),
                Text(subtitle, style: const TextStyle(color: Colors.black45, fontSize: 12)),
              ],
            ),
          ),
          Container(
            width: 22,
            height: 22,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: selected ? gold : line, width: 1.6),
            ),
            child: selected
                ? Container(
                    width: 11,
                    height: 11,
                    decoration: const BoxDecoration(shape: BoxShape.circle, color: gold),
                  )
                : null,
          ),
        ],
      ),
    ),
  );
}

/// Rules the operator applies to balance top-ups, shown before the SMS is sent.
class _PhonePaymentDialog extends StatelessWidget {
  const _PhonePaymentDialog({required this.amount});
  final int amount;

  @override
  Widget build(BuildContext context) {
    final tk = context.watch<LanguageProvider>().isTurkmen;
    final notes = tk
        ? [
            (Icons.savings_outlined, 'Iň az möçber', 'Bir gezekde iň az $_monthlyFee manat doldurylýar.'),
            (Icons.atm_outlined, 'Bankomat we terminal', 'Bankomat ýa-da terminal arkaly töleg kabul edilmeýär.'),
            (Icons.payments_outlined, 'PLN programmasy', 'Töleg programmasy (PLN) arkaly kabul edilmeýär.'),
            (Icons.chat_bubble_outline, 'Soraglaryňyz barmy?', 'Habarlaşmak bölüminden bize ýazyp bilersiňiz.'),
          ]
        : [
            (Icons.savings_outlined, 'Минимальная сумма', 'За один раз пополняется минимум $_monthlyFee манат.'),
            (Icons.atm_outlined, 'Банкомат и терминал', 'Оплата через банкомат или терминал не принимается.'),
            (Icons.payments_outlined, 'Приложение PLN', 'Оплата через приложение PLN не принимается.'),
            (Icons.chat_bubble_outline, 'Есть вопросы?', 'Напишите нам в разделе поддержки.'),
          ];
    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 36),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Cream header carrying the amount that is about to be sent.
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 22),
            decoration: const BoxDecoration(
              color: Color(0xffFDF9F2),
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: Column(
              children: [
                Container(
                  width: 58,
                  height: 58,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    border: Border.all(color: gold.withValues(alpha: .35)),
                  ),
                  child: const AppIcon(Icons.smartphone_outlined, color: gold, size: 26),
                ),
                const SizedBox(height: 12),
                Text(tk ? 'Telefon arkaly töleg' : 'Оплата с телефона', style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                Text(
                  tk ? 'SIM kartyňyzyň balansyndan $amount manat tutulýar.' : 'С баланса SIM-карты спишется $amount манат.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.black54, fontSize: 13, height: 1.4),
                ),
              ],
            ),
          ),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const AppIcon(Icons.warning_amber_rounded, color: gold, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        tk ? 'ÜNS BERIŇ' : 'ВНИМАНИЕ',
                        style: const TextStyle(fontSize: 12.5, letterSpacing: .8, fontWeight: FontWeight.w700, color: gold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  ...notes.map(
                    (note) => Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(borderRadius: BorderRadius.circular(13), color: const Color(0xffF7F4EE)),
                            child: AppIcon(note.$1, color: ink, size: 19),
                          ),
                          const SizedBox(width: 13),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(note.$2, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700)),
                                const SizedBox(height: 3),
                                Text(note.$3, style: const TextStyle(fontSize: 12.5, color: Colors.black54, height: 1.4)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 6, 20, 14),
            child: Column(
              children: [
                _MasterActionButton(
                  label: tk ? 'Tölegi tassykla' : 'Подтвердить оплату',
                  enabled: true,
                  trailingArrow: true,
                  onTap: () => _sendTopUpSms(context, amount),
                ),
                const SizedBox(height: 6),
                _DialogCancelButton(label: tk ? 'Ýatyr' : 'Отмена'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Opens the SMS composer pre-filled with the account and amount for the short code.
Future<void> _sendTopUpSms(BuildContext context, int amount) async {
  final navigator = Navigator.of(context);
  final messenger = ScaffoldMessenger.of(context);
  final tk = context.read<LanguageProvider>().isTurkmen;
  final body = Uri.encodeComponent('$_topUpAccount $amount');
  final launched = await launchUrl(Uri.parse('sms:$_topUpShortCode?body=$body'));
  if (!launched) {
    messenger.showSnackBar(SnackBar(content: Text(tk ? 'SMS programmasy açylmady.' : 'Не удалось открыть SMS.')));
    return;
  }
  navigator.pop();
  navigator.pushAndRemoveUntil(_pageRoute(const MasterHome()), (_) => false);
}

class _BankPickerDialog extends StatefulWidget {
  const _BankPickerDialog({required this.amount});
  final int amount;

  @override
  State<_BankPickerDialog> createState() => _BankPickerDialogState();
}

class _BankPickerDialogState extends State<_BankPickerDialog> {
  static const _banks = [('assets/images/banks/halk.webp', 'Halkbank'), ('assets/images/banks/rysgal.webp', 'Rysgal bank'), ('assets/images/banks/senagat.webp', 'Senagat bank')];
  int? _selected;

  @override
  Widget build(BuildContext context) {
    final tk = context.watch<LanguageProvider>().isTurkmen;
    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              tk ? 'Banky saýlaň' : 'Выберите банк',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              tk ? '${widget.amount} manat tölegi geçirjek bankyňyzy saýlaň.' : 'Выберите банк для оплаты ${widget.amount} манат.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.black45, fontSize: 12.5),
            ),
            const SizedBox(height: 18),
            ...List.generate(_banks.length, (index) {
              final selected = _selected == index;
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: GestureDetector(
                  onTap: () => setState(() => _selected = index),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: selected ? const Color(0xffFDF9F2) : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: selected ? gold : line, width: selected ? 1.6 : 1),
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.asset(_banks[index].$1, width: 46, height: 46, fit: BoxFit.contain),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(_banks[index].$2, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                        ),
                        Container(
                          width: 22,
                          height: 22,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: selected ? gold : line, width: 1.6),
                          ),
                          child: selected
                              ? Container(
                                  width: 11,
                                  height: 11,
                                  decoration: const BoxDecoration(shape: BoxShape.circle, color: gold),
                                )
                              : null,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
            const SizedBox(height: 8),
            _MasterActionButton(
              label: tk ? 'Tölegi tassykla' : 'Подтвердить оплату',
              enabled: _selected != null,
              trailingArrow: true,
              onTap: () {
                Navigator.pop(context);
                Navigator.pushAndRemoveUntil(context, _pageRoute(const MasterHome()), (_) => false);
              },
            ),
            const SizedBox(height: 6),
            _DialogCancelButton(label: tk ? 'Ýatyr' : 'Отмена'),
          ],
        ),
      ),
    );
  }
}

/// Sits under the confirm button in payment dialogs, replacing a back arrow.
class _DialogCancelButton extends StatelessWidget {
  const _DialogCancelButton({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity,
    height: 48,
    child: TextButton(
      onPressed: () => Navigator.pop(context),
      style: TextButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
      child: Text(label, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black54)),
    ),
  );
}

class _MasterActionButton extends StatelessWidget {
  const _MasterActionButton({
    required this.label,
    required this.enabled,
    required this.onTap,
    this.trailingArrow = false,
    this.leading,
  });
  final String label;
  final bool enabled;
  final VoidCallback onTap;
  final bool trailingArrow;
  final IconData? leading;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity,
    height: 56,
    child: FilledButton(
      style: FilledButton.styleFrom(
        backgroundColor: enabled ? ink : const Color(0xffEDEAE4),
        foregroundColor: enabled ? Colors.white : Colors.black38,
        disabledBackgroundColor: const Color(0xffEDEAE4),
        disabledForegroundColor: Colors.black38,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
      onPressed: enabled ? onTap : null,
      child: Row(
        mainAxisAlignment: trailingArrow ? MainAxisAlignment.spaceBetween : MainAxisAlignment.center,
        children: [
          if (trailingArrow) const SizedBox(width: 20),
          if (leading != null) ...[
            AppIcon(leading!, color: enabled ? Colors.white : Colors.black38, size: 19),
            const SizedBox(width: 10),
          ],
          Flexible(
            child: Text(
              label,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (trailingArrow) const AppIcon(Icons.chevron_right, size: 20),
        ],
      ),
    ),
  );
}

class _MasterSetupHeader extends StatelessWidget implements PreferredSizeWidget {
  const _MasterSetupHeader({required this.title});
  final String title;

  @override
  Size get preferredSize => const Size.fromHeight(44);

  @override
  Widget build(BuildContext context) => AppBar(
    toolbarHeight: 44,
    backgroundColor: Colors.white,
    surfaceTintColor: Colors.white,
    elevation: 0,
    centerTitle: true,
    leading: IconButton(
      onPressed: () => Navigator.maybePop(context),
      icon: const AppIcon(Icons.arrow_back, color: ink),
    ),
    title: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
  );
}

class _MasterProgressIndicator extends StatelessWidget {
  const _MasterProgressIndicator({required this.step});
  final int step;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 24,
    child: Stack(
      alignment: Alignment.center,
      children: [
        Positioned(
          left: 12,
          right: 12,
          child: Row(
            children: List.generate(_masterSetupSteps - 1, (index) => Expanded(child: Container(height: 1.5, color: index < step - 1 ? ink : line))),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(_masterSetupSteps, (index) {
            final current = index + 1 == step;
            final completed = index + 1 < step;
            return Container(
              width: 24,
              height: 24,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: current || completed ? ink : Colors.white,
                border: Border.all(color: current || completed ? ink : line),
              ),
              child: completed ? const AppIcon(Icons.check, color: Colors.white, size: 13) : null,
            );
          }),
        ),
      ],
    ),
  );
}
