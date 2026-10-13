part of '../../../app/komekci_app.dart';

/// The client's "Ussalar" tab and "My masters" menu page: accepted and
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
              title: t(tk: 'Baglanan ussaňyz ýok', ru: 'Связанных мастеров нет', en: 'No connected masters yet'),
              text: t(
                tk: 'Ussanyň lakamyny ýa-da telefonyny giriziň, haýyş iberiň — kabul eden badyna ýazyp bilersiňiz.',
                ru: 'Введите никнейм или телефон мастера и отправьте запрос — после принятия вы сможете записываться.',
                en: 'Enter your master’s nickname or phone and send a request — once accepted you can book.',
              ),
              button: t(tk: 'Usta goş', ru: 'Добавить мастера', en: 'Add master'),
            );
    } else {
      content = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (main != null) ...[_MainMasterCard(connection: main)],
          if (others.isNotEmpty) ...[
            sectionTitle(
              main == null ? t(tk: 'Baglanan ussalar', ru: 'Подключённые мастера', en: 'Connected masters') : t(tk: 'Beýleki ussalar', ru: 'Другие мастера', en: 'Other masters'),
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
                          t(tk: 'Ussalarym', ru: 'Мои мастера', en: 'My masters'),
                          style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, height: 1.1),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          total == 0
                              ? t(tk: 'Heniz usta goşulmady', ru: 'Мастеров пока нет', en: 'No masters yet')
                              : t(tk: '$total usta', ru: 'Мастеров: $total', en: '$total ${total == 1 ? 'master' : 'masters'}'),
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
                            t(tk: 'Usta goş', ru: 'Добавить', en: 'Add'),
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

class _MastersEmpty extends StatelessWidget {
  const _MastersEmpty({required this.title, required this.text, required this.button});
  final String title;
  final String text;
  final String button;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 28),
      decoration: _bookingCardDecoration(tokens).copyWith(borderRadius: BorderRadius.circular(28)),
      child: Column(
        children: [
          Container(
            width: 112,
            height: 112,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: tokens.accent.withValues(alpha: .12), shape: BoxShape.circle),
            child: Container(
              width: 78,
              height: 78,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: tokens.surface,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: tokens.accent.withValues(alpha: .3), blurRadius: 18, offset: const Offset(0, 8))],
              ),
              child: AppIcon(Icons.groups_outlined, size: 36, color: tokens.accent),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13.5, height: 1.5, color: tokens.textSecondary),
          ),
          const SizedBox(height: 22),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: FilledButton.icon(
              style: FilledButton.styleFrom(backgroundColor: tokens.textPrimary, shape: const StadiumBorder()),
              onPressed: () => Navigator.push(context, pageRoute(const ConnectMasterScreen())),
              icon: AppIcon(Icons.person_add_alt_1, size: 19, color: tokens.surface),
              label: Text(
                button,
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: tokens.surface),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Make-main / remove sheet for one connection, shared by every card.
Future<void> _showMasterMenu(BuildContext context, ClientConnection connection) async {
  final language = context.read<LanguageProvider>().language;
  String t({required String tk, required String ru, required String en}) => pickTr(language, tk: tk, ru: ru, en: en);
  final tokens = context.appTokens;
  final masters = context.read<ClientMastersProvider>();
  final connected = connection.status == ConnectionStatus.accepted;
  final action = await showModalBottomSheet<String>(
    context: context,
    backgroundColor: tokens.surface,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
    builder: (sheetContext) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 42,
              height: 4,
              decoration: BoxDecoration(color: tokens.border, borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                MasterAvatar(url: connection.master.photoUrl, radius: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        connection.master.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                      ),
                      Text('@${connection.master.nickname}', style: TextStyle(fontSize: 12.5, color: tokens.textSecondary)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (connected && !connection.active)
              _MasterMenuTile(
                icon: Icons.star_border,
                color: tokens.accent,
                title: t(tk: 'Esasy usta et', ru: 'Сделать основным', en: 'Make main master'),
                onTap: () => Navigator.pop(sheetContext, 'active'),
              ),
            _MasterMenuTile(
              icon: Icons.link_off,
              color: tokens.danger,
              title: connected ? t(tk: 'Baglanyşygy aýyr', ru: 'Удалить связь', en: 'Remove connection') : t(tk: 'Haýyşy yzyna al', ru: 'Отозвать запрос', en: 'Cancel request'),
              onTap: () => Navigator.pop(sheetContext, 'remove'),
            ),
          ],
        ),
      ),
    ),
  );
  if (action == null || !context.mounted) return;
  if (action == 'active') {
    await runApi(context, () => masters.setActive(connection.id));
    return;
  }
  if (connected) {
    final ok = await _showConfirmDialog(
      context,
      icon: Icons.link_off,
      danger: true,
      title: t(tk: 'Baglanyşygy aýyrmalymy?', ru: 'Удалить связь?', en: 'Remove this connection?'),
      message: t(
        tk: '${connection.master.name} bilen ýazyp bilmersiňiz, täzeden haýyş ibermeli bolarsyňyz.',
        ru: 'Вы больше не сможете записываться к ${connection.master.name} — потребуется новый запрос.',
        en: 'You won’t be able to book ${connection.master.name} until you send a new request.',
      ),
      confirmLabel: t(tk: 'Aýyr', ru: 'Удалить', en: 'Remove'),
      cancelLabel: t(tk: 'Ýapmak', ru: 'Закрыть', en: 'Close'),
    );
    if (!ok || !context.mounted) return;
  }
  await runApi(context, () => masters.remove(connection.id));
}

class _MasterMenuTile extends StatelessWidget {
  const _MasterMenuTile({required this.icon, required this.color, required this.title, required this.onTap});
  final IconData icon;
  final Color color;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: tokens.surfaceElevated, borderRadius: BorderRadius.circular(18)),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: color.withValues(alpha: .13), shape: BoxShape.circle),
              child: AppIcon(icon, size: 18, color: color),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700, color: color == tokens.danger ? color : tokens.textPrimary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Round "..." button that opens [_showMasterMenu].
class _MasterMoreButton extends StatelessWidget {
  const _MasterMoreButton({required this.connection});
  final ClientConnection connection;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    return GestureDetector(
      onTap: () => _showMasterMenu(context, connection),
      child: Container(
        width: 36,
        height: 36,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: tokens.surface.withValues(alpha: .9),
          shape: BoxShape.circle,
          border: Border.all(color: tokens.border.withValues(alpha: .7)),
        ),
        child: AppIcon(Icons.more_horiz, size: 18, color: tokens.textSecondary),
      ),
    );
  }
}

/// The main master: big card with the two things a client does most.
class _MainMasterCard extends StatelessWidget {
  const _MainMasterCard({required this.connection});
  final ClientConnection connection;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    final language = context.watch<LanguageProvider>().language;
    String t({required String tk, required String ru, required String en}) => pickTr(language, tk: tk, ru: ru, en: en);
    final master = connection.master;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _flatTintDecoration(tokens, tokens.accent, shadow: true),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(color: tokens.accent, borderRadius: BorderRadius.circular(12)),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AppIcon(Icons.star_border, size: 13, color: tokens.accentOn),
                    const SizedBox(width: 4),
                    Text(
                      t(tk: 'Esasy usta', ru: 'Основной мастер', en: 'Main master'),
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: tokens.accentOn),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              _MasterMoreButton(connection: connection),
            ],
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () => Navigator.push(context, pageRoute(MasterProfileScreen(master: master))),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: tokens.surface,
                    border: Border.all(color: tokens.accent, width: 1.8),
                  ),
                  child: MasterAvatar(url: master.photoUrl, radius: 34),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        master.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, height: 1.15),
                      ),
                      const SizedBox(height: 3),
                      Text('@${master.nickname}', style: TextStyle(fontSize: 13.5, color: tokens.textSecondary)),
                      if (master.address.isNotEmpty) ...[
                        const SizedBox(height: 7),
                        Row(
                          children: [
                            AppIcon(Icons.location_on_outlined, size: 13, color: tokens.textSecondary),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                master.address,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontSize: 12.5, color: tokens.textSecondary),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 50,
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(backgroundColor: tokens.textPrimary, shape: const StadiumBorder()),
                    onPressed: () => Navigator.push(context, pageRoute(BookingPage(master: master))),
                    icon: AppIcon(Icons.calendar_month_outlined, size: 18, color: tokens.surface),
                    label: Text(
                      t(tk: 'Ýazyl', ru: 'Записаться', en: 'Book'),
                      style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700, color: tokens.surface),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                height: 50,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: tokens.textPrimary.withValues(alpha: .25)),
                    shape: const StadiumBorder(),
                    padding: const EdgeInsets.symmetric(horizontal: 22),
                  ),
                  onPressed: () => Navigator.push(context, pageRoute(MasterProfileScreen(master: master))),
                  child: Text(
                    t(tk: 'Profil', ru: 'Профиль', en: 'Profile'),
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: tokens.textPrimary),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MyMasterCard extends StatelessWidget {
  const _MyMasterCard({required this.connection});
  final ClientConnection connection;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    final language = context.watch<LanguageProvider>().language;
    String t({required String tk, required String ru, required String en}) => pickTr(language, tk: tk, ru: ru, en: en);
    final master = connection.master;
    final connected = connection.status == ConnectionStatus.accepted;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: _bookingCardDecoration(tokens),
      child: Column(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: connected ? () => Navigator.push(context, pageRoute(MasterProfileScreen(master: master))) : null,
            child: Row(
              children: [
                Opacity(
                  opacity: connected ? 1 : .6,
                  child: MasterAvatar(url: master.photoUrl, radius: 27),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        master.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '@${master.nickname}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 12.5, color: tokens.textSecondary),
                      ),
                      if (master.address.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            AppIcon(Icons.location_on_outlined, size: 12, color: tokens.textSecondary),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                master.address,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontSize: 11.5, color: tokens.textSecondary),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                _MasterMoreButton(connection: connection),
              ],
            ),
          ),
          const SizedBox(height: 14),
          if (connected)
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 44,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: tokens.border),
                        shape: const StadiumBorder(),
                      ),
                      onPressed: () => Navigator.push(context, pageRoute(MasterProfileScreen(master: master))),
                      child: Text(
                        t(tk: 'Profil', ru: 'Профиль', en: 'Profile'),
                        style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: tokens.textPrimary),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: SizedBox(
                    height: 44,
                    child: FilledButton(
                      style: FilledButton.styleFrom(backgroundColor: tokens.textPrimary, shape: const StadiumBorder()),
                      onPressed: () => Navigator.push(context, pageRoute(BookingPage(master: master))),
                      child: Text(
                        t(tk: 'Ýazyl', ru: 'Записаться', en: 'Book'),
                        style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: tokens.surface),
                      ),
                    ),
                  ),
                ),
              ],
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
              decoration: BoxDecoration(color: tokens.warning.withValues(alpha: .1), borderRadius: BorderRadius.circular(14)),
              child: Row(
                children: [
                  AppIcon(Icons.hourglass_empty, size: 15, color: tokens.warning),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      t(tk: 'Usta kabul edenini garaşýar', ru: 'Ждём ответа мастера', en: 'Waiting for the master to accept'),
                      style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: tokens.warning),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
