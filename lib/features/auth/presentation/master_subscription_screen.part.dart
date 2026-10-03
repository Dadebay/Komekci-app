part of '../../../app/komekci_app.dart';

class MasterSubscriptionScreen extends StatefulWidget {
  const MasterSubscriptionScreen({super.key});

  @override
  State<MasterSubscriptionScreen> createState() =>
      _MasterSubscriptionScreenState();
}

class _MasterSubscriptionScreenState extends State<MasterSubscriptionScreen> {
  int _amount = _topUpAmounts.first;
  bool _payByPhone = true;

  /// How long the chosen top-up keeps the monthly subscription running.
  String _coverageText(AppLanguage language) {
    final settings = context.watch<AppSettingsProvider>();
    final fee = settings.monthlyFee;
    final cur = settings.currencyLabel(language);
    final months = _amount ~/ fee;
    final remainder = _amount % fee;
    switch (language) {
      case AppLanguage.tk:
        final base = '$months aýlyk abuna (aýda $fee $cur)';
        return remainder == 0
            ? base
            : '$base · $remainder $cur balansda galýar';
      case AppLanguage.ru:
        final base = 'Подписка на $months мес. (по $fee $cur)';
        return remainder == 0
            ? base
            : '$base · $remainder $cur останется на балансе';
      case AppLanguage.en:
        final base = '$months month(s) of subscription (at $fee $cur/mo)';
        return remainder == 0
            ? base
            : '$base · $remainder $cur stays on your balance';
    }
  }

  @override
  Widget build(BuildContext context) {
    final language = context.watch<LanguageProvider>().language;
    String t({required String tk, required String ru, required String en}) =>
        pickTr(language, tk: tk, ru: ru, en: en);
    final tokens = context.appTokens;
    final settings = context.watch<AppSettingsProvider>();
    final cur = settings.currencyLabel(language);
    final fee = settings.monthlyFee;
    final example = fee * 2 + fee ~/ 2;
    final left = example - fee * 2;
    return Scaffold(
      backgroundColor: tokens.surface,
      appBar: _MasterSetupHeader(
        title: t(
          tk: 'ABUNA WE TÖLEG',
          ru: 'ПОДПИСКА И ОПЛАТА',
          en: 'SUBSCRIPTION & PAYMENT',
        ),
      ),
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
                      padding: const EdgeInsets.symmetric(
                        vertical: 24,
                        horizontal: 18,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: tokens.border),
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: 64,
                            height: 64,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: tokens.surfaceElevated,
                            ),
                            child: Text(
                              '♔',
                              style: TextStyle(
                                fontSize: 34,
                                color: tokens.accent,
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            t(
                              tk: 'MASTER ÜÇIN ABUNA',
                              ru: 'ПОДПИСКА ДЛЯ МАСТЕРА',
                              en: 'MASTER SUBSCRIPTION',
                            ),
                            style: const TextStyle(
                              fontSize: 13,
                              letterSpacing: .7,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 12),
                          // The headline price follows whichever top-up the master picked.
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 280),
                            switchInCurve: Curves.easeOutCubic,
                            switchOutCurve: Curves.easeInCubic,
                            transitionBuilder: (child, animation) =>
                                FadeTransition(
                                  opacity: animation,
                                  child: SlideTransition(
                                    position: Tween(
                                      begin: const Offset(0, .3),
                                      end: Offset.zero,
                                    ).animate(animation),
                                    child: child,
                                  ),
                                ),
                            child: RichText(
                              key: ValueKey(_amount),
                              text: TextSpan(
                                style: TextStyle(
                                  fontFamily: 'Gilroy',
                                  color: tokens.textPrimary,
                                ),
                                children: [
                                  TextSpan(
                                    text: '$_amount',
                                    style: const TextStyle(
                                      fontSize: 34,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  TextSpan(
                                    text: ' $cur',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 280),
                            child: Text(
                              _coverageText(language),
                              key: ValueKey('coverage-$_amount-$language'),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: tokens.textSecondary,
                                height: 1.4,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 26),
                    Text(
                      t(
                        tk: 'Möçberi saýlaň',
                        ru: 'Выберите сумму',
                        en: 'Choose an amount',
                      ),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      t(
                        tk: 'Balansyňyzy doldurmak üçin möçberi saýlaň.',
                        ru: 'Выберите сумму для пополнения баланса.',
                        en: 'Choose an amount to top up your balance.',
                      ),
                      style: TextStyle(
                        color: tokens.textSecondary,
                        fontSize: 12.5,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: _topUpAmounts.map((amount) {
                        final selected = amount == _amount;
                        return Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(
                              right: amount == _topUpAmounts.last ? 0 : 10,
                            ),
                            child: GestureDetector(
                              onTap: () => setState(() => _amount = amount),
                              child: AnimatedScale(
                                duration: const Duration(milliseconds: 260),
                                curve: Curves.easeOutBack,
                                scale: selected ? 1.04 : 1,
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 260),
                                  curve: Curves.easeOutCubic,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  decoration: BoxDecoration(
                                    color: selected
                                        ? tokens.surfaceElevated
                                        : tokens.surface,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: selected
                                          ? tokens.accent
                                          : tokens.border,
                                      width: selected ? 1.6 : 1,
                                    ),
                                    boxShadow: selected
                                        ? [
                                            BoxShadow(
                                              color: tokens.accent.withValues(
                                                alpha: .22,
                                              ),
                                              blurRadius: 14,
                                              offset: const Offset(0, 5),
                                            ),
                                          ]
                                        : null,
                                  ),
                                  child: Column(
                                    children: [
                                      TweenAnimationBuilder<Color?>(
                                        duration: const Duration(
                                          milliseconds: 260,
                                        ),
                                        tween: ColorTween(
                                          begin: tokens.textPrimary,
                                          end: selected
                                              ? tokens.accent
                                              : tokens.textPrimary,
                                        ),
                                        builder: (_, color, _) => Text(
                                          '$amount',
                                          style: TextStyle(
                                            fontSize: 22,
                                            fontWeight: FontWeight.w700,
                                            color: color,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        cur,
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: selected
                                              ? tokens.accent
                                              : tokens.textSecondary,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      AnimatedContainer(
                                        duration: const Duration(
                                          milliseconds: 260,
                                        ),
                                        curve: Curves.easeOutCubic,
                                        width: 20,
                                        height: 20,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: selected
                                              ? tokens.accent
                                              : Colors.transparent,
                                          border: Border.all(
                                            color: selected
                                                ? tokens.accent
                                                : tokens.border,
                                            width: 1.4,
                                          ),
                                        ),
                                        child: AnimatedScale(
                                          duration: const Duration(
                                            milliseconds: 260,
                                          ),
                                          curve: Curves.easeOutBack,
                                          scale: selected ? 1 : 0,
                                          child: AppIcon(
                                            Icons.check,
                                            color: tokens.accentOn,
                                            size: 13,
                                          ),
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
                    Text(
                      t(
                        tk: 'Töleg usulyny saýlaň',
                        ru: 'Выберите способ оплаты',
                        en: 'Choose a payment method',
                      ),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 14),
                    _PaymentMethodTile(
                      icon: Icons.smartphone_outlined,
                      title: t(
                        tk: 'Telefon balansy',
                        ru: 'Баланс телефона',
                        en: 'Phone balance',
                      ),
                      subtitle: t(
                        tk: 'SIM kartyňyzyň balansyndan tölän',
                        ru: 'Оплата с баланса SIM-карты',
                        en: 'Pay from your SIM card balance',
                      ),
                      selected: _payByPhone,
                      onTap: () => setState(() => _payByPhone = true),
                    ),
                    const SizedBox(height: 10),
                    _PaymentMethodTile(
                      icon: Icons.credit_card_outlined,
                      title: t(
                        tk: 'Bank kartasy',
                        ru: 'Банковская карта',
                        en: 'Bank card',
                      ),
                      subtitle: 'Halkbank, Rysgal, Senagat',
                      selected: !_payByPhone,
                      onTap: () => setState(() => _payByPhone = false),
                    ),
                    const SizedBox(height: 18),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: tokens.surfaceElevated,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: tokens.border),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppIcon(
                            Icons.info_outline,
                            color: tokens.accent,
                            size: 19,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  t(
                                    tk: 'Balans nähili işleýär?',
                                    ru: 'Как работает баланс?',
                                    en: 'How does the balance work?',
                                  ),
                                  style: const TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  t(
                                    tk: 'Goýan puluňyz balansyňyzda saklanýar. Her aý abuna üçin $fee $cur awtomatiki tutulýar. Mysal üçin, balansyňyza $example $cur doldursaňyz, birinji aý $fee $cur, indiki aý ýene $fee $cur tutulýar. Galan $left $cur balansyňyzda saklanýar.',
                                    ru: 'Внесённые деньги хранятся на балансе. Каждый месяц за подписку автоматически списывается $fee $cur. Например, при пополнении на $example $cur: $fee $cur спишется в первый месяц, ещё $fee — во второй, оставшиеся $left останутся на балансе.',
                                    en: 'Money you add is kept on your balance. Each month, $fee $cur is automatically deducted for the subscription. For example, if you top up $example $cur, $fee $cur is deducted the first month, another $fee $cur the next, and the remaining $left $cur stays on your balance.',
                                  ),
                                  style: TextStyle(
                                    color: tokens.textSecondary,
                                    fontSize: 12,
                                    height: 1.5,
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
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
              child: _MasterActionButton(
                label: t(tk: 'Tölegi töle', ru: 'Оплатить', en: 'Pay'),
                enabled: true,
                onTap: _pay,
              ),
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
        builder: (_) => _CardPaymentDialog(amount: _amount),
      );
    }
  }
}
