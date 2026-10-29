part of '../../../app/komekci_app.dart';

/// The client's "Masterler" tab and "My masters" menu page: accepted and
/// pending connections (`GET /connections`) with the main-master switch and
/// removal, and the entry point for connecting to a new master.
class MyMastersScreen extends StatelessWidget {
  const MyMastersScreen({super.key});

  @override
  Widget build(BuildContext context) => const ClientMastersScreen();
}

class ClientMastersScreen extends StatelessWidget {
  const ClientMastersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final language = context.watch<LanguageProvider>().language;
    String t({required String tk, required String ru, required String en}) => pickTr(language, tk: tk, ru: ru, en: en);
    final tokens = context.appTokens;
    final masters = context.watch<ClientMastersProvider>();
    final canPop = Navigator.of(context).canPop();
    final main = masters.active;
    final others = [
      for (final c in masters.accepted)
        if (c.id != main?.id) c,
    ];
    final pending = masters.pending;
    final total = masters.accepted.length + pending.length;

    Widget sectionTitle(String text, int count) => Padding(
      padding: const EdgeInsets.fromLTRB(0, 24, 0, 12),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 16,
            decoration: BoxDecoration(color: tokens.accent, borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(width: 8),
          Text(text, style: const TextStyle(fontSize: 16.5, fontWeight: FontWeight.w800)),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(color: tokens.surfaceElevated, borderRadius: BorderRadius.circular(9)),
            child: Text(
              '$count',
              style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: tokens.textSecondary),
            ),
          ),
        ],
      ),
    );

    final Widget content;
    if (masters.error != null && total == 0) {
      content = RetryErrorState(
        title: t(tk: 'Ýalňyşlyk', ru: 'Ошибка', en: 'Something went wrong'),
        text: apiErrorMessage(masters.error!, language),
        retryLabel: t(tk: 'Täzeden synanyş', ru: 'Повторить', en: 'Try again'),
        onRetry: masters.load,
      );
    } else if (total == 0) {
      content = masters.loading
          ? const Padding(
              padding: EdgeInsets.only(top: 40),
              child: Center(child: CircularProgressIndicator()),
            )
          : _MastersEmpty(
              title: t(tk: 'Baglanan masteriňiz ýok', ru: 'Связанных мастеров нет', en: 'No connected masters yet'),
              text: t(
                tk: 'Masteriň lakamyny ýa-da telefonyny giriziň, haýyş iberiň — kabul eden badyna ýazyp bilersiňiz.',
                ru: 'Введите никнейм или телефон мастера и отправьте запрос — после принятия вы сможете записываться.',
                en: 'Enter your master’s nickname or phone and send a request — once accepted you can book.',
              ),
              button: t(tk: 'Master goş', ru: 'Добавить мастера', en: 'Add master'),
            );
    } else {
      content = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (main != null) ...[_MainMasterCard(connection: main)],
          if (others.isNotEmpty) ...[
            sectionTitle(
              main == null ? t(tk: 'Baglanan masterler', ru: 'Подключённые мастера', en: 'Connected masters') : t(tk: 'Beýleki masterler', ru: 'Другие мастера', en: 'Other masters'),
              others.length,
            ),
            for (final c in others) _MyMasterCard(connection: c),
          ],
          if (pending.isNotEmpty) ...[sectionTitle(t(tk: 'Garaşylýan haýyşlar', ru: 'Ожидают ответа', en: 'Pending requests'), pending.length), for (final c in pending) _MyMasterCard(connection: c)],
        ],
      );
    }

    return Scaffold(
      backgroundColor: tokens.surface,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: masters.load,
          child: ListView(
            padding: EdgeInsets.fromLTRB(20, 14, 20, canPop ? 24 : 120),
            children: [
              Row(
                children: [
                  if (canPop) ...[
                    GestureDetector(
                      onTap: () => Navigator.maybePop(context),
                      child: Container(
                        width: 44,
                        height: 44,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: tokens.surface,
                          shape: BoxShape.circle,
                          border: Border.all(color: tokens.border.withValues(alpha: .8)),
                          boxShadow: [BoxShadow(color: tokens.textPrimary.withValues(alpha: .06), blurRadius: 10, offset: const Offset(0, 3))],
                        ),
                        child: AppIcon(Icons.arrow_back, size: 19, color: tokens.textPrimary),
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          t(tk: 'Masterlerim', ru: 'Мои мастера', en: 'My masters'),
                          style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, height: 1.1),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          total == 0
                              ? t(tk: 'Heniz master goşulmady', ru: 'Мастеров пока нет', en: 'No masters yet')
                              : t(tk: '$total master', ru: 'Мастеров: $total', en: '$total ${total == 1 ? 'master' : 'masters'}'),
                          style: TextStyle(fontSize: 13, color: tokens.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.push(context, pageRoute(const ConnectMasterScreen())),
                    child: Container(
                      height: 44,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: tokens.textPrimary,
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: [BoxShadow(color: tokens.textPrimary.withValues(alpha: .22), blurRadius: 14, offset: const Offset(0, 6))],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AppIcon(Icons.add, size: 18, color: tokens.surface),
                          const SizedBox(width: 6),
                          Text(
                            t(tk: 'Master goş', ru: 'Добавить', en: 'Add'),
                            style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: tokens.surface),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              content,
            ],
          ),
        ),
      ),
    );
  }
}
