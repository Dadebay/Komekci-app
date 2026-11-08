part of '../../../app/komekci_app.dart';

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
                title: t(tk: 'Esasy master et', ru: 'Сделать основным', en: 'Make main master'),
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
