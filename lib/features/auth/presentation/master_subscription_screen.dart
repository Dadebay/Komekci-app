part of '../../../app/komekci_app.dart';

/// Subscription and top-up. The monthly price comes from the server; the
/// amount offered is 1, 2, 3 or 6 months of it. The balance and subscription
/// state shown here are the server's — after a payment the app only asks
/// again, it never marks anything paid itself.
///
/// [onboarding] is true when this is step 4 of master sign-up (shows the
/// progress dots); the cabinet's "Top up" opens it with false.
class MasterSubscriptionScreen extends StatefulWidget {
  const MasterSubscriptionScreen({super.key, this.onboarding = true});
  final bool onboarding;

  @override
  State<MasterSubscriptionScreen> createState() =>
      _MasterSubscriptionScreenState();
}

class _MasterSubscriptionScreenState extends State<MasterSubscriptionScreen> {
  /// Months offered as top-up amounts.
  static const _monthChoices = [1, 2, 3, 6];

  int _monthsIndex = 0;
  bool _payByPhone = true;

  @override
  void initState() {
    super.initState();
    // Fresh balance/status whenever the page opens.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<BillingProvider>().refresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    final language = context.watch<LanguageProvider>().language;
    String t({required String tk, required String ru, required String en}) =>
        pickTr(language, tk: tk, ru: ru, en: en);
    final tokens = context.appTokens;
    final settings = context.watch<AppSettingsProvider>();
    final billing = context.watch<BillingProvider>();
    final cur = settings.currencyLabel(language);
    final fee = settings.monthlyFee;
    final months = _monthChoices[_monthsIndex];
    final amount = fee * months;
    // `phone: null` in /me/billing means the server has no receiving number
    // free, so paying by phone cannot start (POST topup would 404).
    final phoneAvailable = !billing.loaded || billing.billing?.phone != null;
    final byPhone = _payByPhone && phoneAvailable;

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
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.onboarding) ...[
                const _MasterProgressIndicator(step: 4),
                const SizedBox(height: 22),
              ],
              if (billing.loaded) ...[
                _SubscriptionStatusStrip(billing: billing, cur: cur),
                const SizedBox(height: 16),
              ],
              _PlanCard(fee: fee, cur: cur),
              const SizedBox(height: 28),
              Text(
                t(tk: 'Näçe aýa tölemeli?', ru: 'На сколько месяцев оплатить?', en: 'How many months?'),
                style: const TextStyle(fontSize: 16.5, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 4),
              Text(
                t(
                  tk: 'Töleg balansyňyza goşulýar, abuna aýlyk awtomatik tutulýar.',
                  ru: 'Сумма зачисляется на баланс, подписка списывается ежемесячно.',
                  en: 'The amount goes to your balance; the subscription is charged monthly.',
                ),
                style: TextStyle(color: tokens.textSecondary, fontSize: 12.5, height: 1.4),
              ),
              const SizedBox(height: 14),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 1.95,
                children: [
                  for (var i = 0; i < _monthChoices.length; i++)
                    _AmountOption(
                      amount: fee * _monthChoices[i],
                      months: _monthChoices[i],
                      cur: cur,
                      selected: i == _monthsIndex,
                      onTap: () => setState(() => _monthsIndex = i),
                    ),
                ],
              ),
              const SizedBox(height: 28),
              Text(
                t(tk: 'Töleg usuly', ru: 'Способ оплаты', en: 'Payment method'),
                style: const TextStyle(fontSize: 16.5, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 14),
              _PaymentMethodTile(
                icon: Icons.smartphone_outlined,
                title: t(tk: 'Telefon balansy', ru: 'Баланс телефона', en: 'Phone balance'),
                subtitle: phoneAvailable
                    ? t(
                        tk: 'SIM kartyňyzyň balansyndan geçiriň',
                        ru: 'Перевод с баланса SIM-карты',
                        en: 'Transfer from your SIM card balance',
                      )
                    : t(
                        tk: 'Häzirlikçe elýeterli däl',
                        ru: 'Сейчас недоступно',
                        en: 'Not available right now',
                      ),
                enabled: phoneAvailable,
                selected: byPhone,
                onTap: () => setState(() => _payByPhone = true),
              ),
              const SizedBox(height: 10),
              _PaymentMethodTile(
                icon: Icons.credit_card_outlined,
                title: t(tk: 'Bank kartasy', ru: 'Банковская карта', en: 'Bank card'),
                subtitle: 'Halkbank, Rysgal, Senagat',
                selected: !byPhone,
                onTap: () => setState(() => _payByPhone = false),
              ),
              const SizedBox(height: 20),
              _HowBalanceWorks(fee: fee, cur: cur),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: tokens.surface,
          border: Border(top: BorderSide(color: tokens.border)),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 12),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      t(tk: 'Tölenmeli', ru: 'К оплате', en: 'To pay'),
                      style: TextStyle(fontSize: 11.5, color: tokens.textSecondary),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$amount $cur',
                      style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w800),
                    ),
                    Text(
                      t(
                        tk: '$months aý üçin',
                        ru: 'за $months мес.',
                        en: 'for $months month${months == 1 ? '' : 's'}',
                      ),
                      style: TextStyle(fontSize: 11.5, color: tokens.textSecondary),
                    ),
                  ],
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: _MasterActionButton(
                    label: t(tk: 'Tölegi töle', ru: 'Оплатить', en: 'Pay'),
                    enabled: true,
                    trailingArrow: true,
                    onTap: () => _pay(amount, byPhone),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pay(int amount, bool byPhone) async {
    await showDialog<void>(
      context: context,
      builder: (_) => byPhone
          ? _PhonePaymentDialog(amount: amount)
          : _CardPaymentDialog(amount: amount),
    );
  }
}

/// Balance and subscription state at a glance.
class _SubscriptionStatusStrip extends StatelessWidget {
  const _SubscriptionStatusStrip({required this.billing, required this.cur});
  final BillingProvider billing;
  final String cur;

  @override
  Widget build(BuildContext context) {
    final language = context.watch<LanguageProvider>().language;
    String t({required String tk, required String ru, required String en}) =>
        pickTr(language, tk: tk, ru: ru, en: en);
    final tokens = context.appTokens;
    final (label, color) = switch (billing.status) {
      SubscriptionStatus.active => (t(tk: 'Abuna işjeň', ru: 'Подписка активна', en: 'Subscription active'), tokens.success),
      SubscriptionStatus.grace => (t(tk: 'Töleg wagty ýetdi', ru: 'Пора оплатить', en: 'Payment due'), tokens.warning),
      SubscriptionStatus.suspended => (t(tk: 'Abuna işjeň däl', ru: 'Подписка не активна', en: 'Subscription inactive'), tokens.danger),
    };
    final until = billing.paidUntil;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .09),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800, color: color)),
                if (until != null)
                  Text(
                    t(tk: '${formatDate(until)} çenli', ru: 'до ${formatDate(until)}', en: 'until ${formatDate(until)}'),
                    style: TextStyle(fontSize: 11.5, color: tokens.textSecondary),
                  ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(t(tk: 'Balans', ru: 'Баланс', en: 'Balance'), style: TextStyle(fontSize: 11, color: tokens.textSecondary)),
              Text('${billing.balance} $cur', style: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w800)),
            ],
          ),
        ],
      ),
    );
  }
}

/// What the subscription is and costs, on a dark card.
class _PlanCard extends StatelessWidget {
  const _PlanCard({required this.fee, required this.cur});
  final int fee;
  final String cur;

  @override
  Widget build(BuildContext context) {
    final language = context.watch<LanguageProvider>().language;
    String t({required String tk, required String ru, required String en}) =>
        pickTr(language, tk: tk, ru: ru, en: en);
    final tokens = context.appTokens;
    final perks = [
      t(tk: 'Onlaýn ýazgylary kabul ediň', ru: 'Принимайте онлайн-записи', en: 'Accept online bookings'),
      t(tk: 'Müşderi bazaňyzy dolandyryň', ru: 'Ведите базу клиентов', en: 'Manage your client list'),
      t(tk: 'Iş wagtyňyzy we dynç günlerini sazlaň', ru: 'Настраивайте график и выходные', en: 'Set your hours and days off'),
    ];
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: tokens.textPrimary,
        borderRadius: BorderRadius.circular(26),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('♔', style: TextStyle(fontSize: 24, color: tokens.accent)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  t(tk: 'MASTER ABUNA', ru: 'ПОДПИСКА МАСТЕРА', en: 'MASTER SUBSCRIPTION'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12.5,
                    letterSpacing: 1.1,
                    fontWeight: FontWeight.w800,
                    color: tokens.surface.withValues(alpha: .75),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('$fee', style: TextStyle(fontSize: 46, height: 1, fontWeight: FontWeight.w800, color: tokens.surface)),
              const SizedBox(width: 8),
              Flexible(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text(
                    '$cur / ${t(tk: 'aý', ru: 'мес.', en: 'month')}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: tokens.surface.withValues(alpha: .8)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          for (final perk in perks)
            Padding(
              padding: const EdgeInsets.only(bottom: 9),
              child: Row(
                children: [
                  AppIcon(Icons.check_circle, size: 18, color: tokens.accent),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(perk, style: TextStyle(fontSize: 13.5, color: tokens.surface.withValues(alpha: .92))),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// One selectable top-up amount ("40 TMT · 2 months").
class _AmountOption extends StatelessWidget {
  const _AmountOption({
    required this.amount,
    required this.months,
    required this.cur,
    required this.selected,
    required this.onTap,
  });
  final int amount;
  final int months;
  final String cur;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final language = context.watch<LanguageProvider>().language;
    final tokens = context.appTokens;
    final monthsLabel = pickTr(
      language,
      tk: '$months aý',
      ru: months == 1 ? '1 месяц' : '$months мес.',
      en: months == 1 ? '1 month' : '$months months',
    );
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: selected ? tokens.surfaceElevated : tokens.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected ? tokens.accent : tokens.border,
            width: selected ? 1.8 : 1,
          ),
          boxShadow: selected
              ? [BoxShadow(color: tokens.accent.withValues(alpha: .18), blurRadius: 14, offset: const Offset(0, 5))]
              : null,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '$amount $cur',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: selected ? tokens.accent : tokens.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(monthsLabel, style: TextStyle(fontSize: 12, color: tokens.textSecondary)),
                ],
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 22,
              height: 22,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected ? tokens.accent : Colors.transparent,
                border: Border.all(color: selected ? tokens.accent : tokens.border, width: 1.5),
              ),
              child: selected ? AppIcon(Icons.check, size: 13, color: tokens.accentOn) : null,
            ),
          ],
        ),
      ),
    );
  }
}

/// Collapsible explanation of how the balance and monthly charge work.
class _HowBalanceWorks extends StatelessWidget {
  const _HowBalanceWorks({required this.fee, required this.cur});
  final int fee;
  final String cur;

  @override
  Widget build(BuildContext context) {
    final language = context.watch<LanguageProvider>().language;
    String t({required String tk, required String ru, required String en}) =>
        pickTr(language, tk: tk, ru: ru, en: en);
    final tokens = context.appTokens;
    final example = fee * 2 + fee ~/ 2;
    final left = example - fee * 2;
    return Container(
      decoration: BoxDecoration(
        color: tokens.surfaceElevated,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: tokens.border),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          shape: const Border(),
          collapsedShape: const Border(),
          tilePadding: const EdgeInsets.symmetric(horizontal: 16),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          leading: AppIcon(Icons.info_outline, color: tokens.accent, size: 20),
          title: Text(
            t(tk: 'Balans nähili işleýär?', ru: 'Как работает баланс?', en: 'How does the balance work?'),
            style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700),
          ),
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                t(
                  tk: 'Goýan puluňyz balansyňyzda saklanýar. Her aý abuna üçin $fee $cur awtomatiki tutulýar. Mysal üçin, balansyňyza $example $cur doldursaňyz, birinji aý $fee $cur, indiki aý ýene $fee $cur tutulýar. Galan $left $cur balansyňyzda saklanýar.',
                  ru: 'Внесённые деньги хранятся на балансе. Каждый месяц за подписку автоматически списывается $fee $cur. Например, при пополнении на $example $cur: $fee $cur спишется в первый месяц, ещё $fee — во второй, оставшиеся $left останутся на балансе.',
                  en: 'Money you add is kept on your balance. Each month, $fee $cur is automatically deducted for the subscription. For example, if you top up $example $cur, $fee $cur is deducted the first month, another $fee $cur the next, and the remaining $left $cur stays on your balance.',
                ),
                style: TextStyle(color: tokens.textSecondary, fontSize: 12.5, height: 1.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
