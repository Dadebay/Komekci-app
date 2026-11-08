part of '../../../app/komekci_app.dart';

class _AmountOption extends StatelessWidget {
  const _AmountOption({
    required this.amount,
    required this.months,
    required this.cur,
    required this.selected,
    required this.onTap,
    this.compact = false,
  });
  final int amount;
  final int months;
  final String cur;
  final bool selected;
  final VoidCallback onTap;
  final bool compact;

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
        padding: EdgeInsets.symmetric(horizontal: compact ? 12 : 14),
        decoration: BoxDecoration(
          color: selected ? tokens.surfaceElevated : tokens.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected ? tokens.accent : tokens.border,
            width: selected ? 1.8 : 1,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: tokens.accent.withValues(alpha: .18),
                    blurRadius: 14,
                    offset: const Offset(0, 5),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (compact)
                    Text(
                      monthsLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: selected ? tokens.accent : tokens.textPrimary,
                      ),
                    )
                  else
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
                  Text(
                    compact ? '$amount $cur' : monthsLabel,
                    maxLines: compact ? 1 : null,
                    overflow: compact ? TextOverflow.ellipsis : null,
                    style: TextStyle(fontSize: 12, color: tokens.textSecondary),
                  ),
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
                border: Border.all(
                  color: selected ? tokens.accent : tokens.border,
                  width: 1.5,
                ),
              ),
              child: selected
                  ? AppIcon(Icons.check, size: 13, color: tokens.accentOn)
                  : null,
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
    return Material(
      color: tokens.surfaceElevated,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: tokens.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          shape: const Border(),
          collapsedShape: const Border(),
          tilePadding: const EdgeInsets.symmetric(horizontal: 16),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          leading: AppIcon(Icons.info_outline, color: tokens.accent, size: 20),
          title: Text(
            t(
              tk: 'Balans nähili işleýär?',
              ru: 'Как работает баланс?',
              en: 'How does the balance work?',
            ),
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
                style: TextStyle(
                  color: tokens.textSecondary,
                  fontSize: 12.5,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
