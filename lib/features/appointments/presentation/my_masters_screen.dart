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
    final connections = [...masters.accepted, ...masters.pending];

    return Scaffold(
      backgroundColor: tokens.surface,
      appBar: CabinetAppBar(
        title: t(tk: 'Ussalarym', ru: 'Мои мастера', en: 'My masters'),
      ),
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: masters.load,
          child: masters.error != null && connections.isEmpty
              ? ListView(
                  padding: EdgeInsets.fromLTRB(20, 30, 20, canPop ? 20 : 110),
                  children: [
                    RetryErrorState(
                      title: t(tk: 'Ýalňyşlyk', ru: 'Ошибка', en: 'Something went wrong'),
                      text: apiErrorMessage(masters.error!, language),
                      retryLabel: t(tk: 'Täzeden synanyş', ru: 'Повторить', en: 'Try again'),
                      onRetry: masters.load,
                    ),
                  ],
                )
              : connections.isEmpty
              ? ListView(
                  padding: EdgeInsets.fromLTRB(20, 30, 20, canPop ? 20 : 110),
                  children: [
                    if (masters.loading)
                      const Padding(
                        padding: EdgeInsets.only(top: 40),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else
                      EmptyState(
                        icon: Icons.groups_outlined,
                        title: t(tk: 'Baglanan ussaňyz ýok', ru: 'Связанных мастеров нет', en: 'No connected masters yet'),
                        text: t(tk: 'Ussa goşup, bir näçe minutda baglanyşyň.', ru: 'Добавьте мастера, чтобы связаться с ним.', en: 'Add a master to connect with them.'),
                      ),
                  ],
                )
              : ListView(
                  padding: EdgeInsets.fromLTRB(20, 12, 20, canPop ? 20 : 110),
                  children: [for (final c in connections) _MyMasterCard(connection: c)],
                ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(20, 8, 20, canPop ? 16 : 96),
          child: PrimaryButton(
            label: t(tk: 'Usta goş', ru: 'Добавить мастера', en: 'Add master'),
            onTap: () => Navigator.push(context, pageRoute(const ConnectMasterScreen())),
          ),
        ),
      ),
    );
  }
}

class _MyMasterCard extends StatelessWidget {
  const _MyMasterCard({required this.connection});
  final ClientConnection connection;

  Future<void> _menu(BuildContext context) async {
    final language = context.read<LanguageProvider>().language;
    String t({required String tk, required String ru, required String en}) => pickTr(language, tk: tk, ru: ru, en: en);
    final masters = context.read<ClientMastersProvider>();
    final connected = connection.status == ConnectionStatus.accepted;
    final action = await showModalBottomSheet<String>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (connected && !connection.active)
              ListTile(
                leading: const AppIcon(Icons.star_outline),
                title: Text(t(tk: 'Esasy usta et', ru: 'Сделать основным', en: 'Make main master')),
                onTap: () => Navigator.pop(sheetContext, 'active'),
              ),
            ListTile(
              leading: const AppIcon(Icons.link_off),
              title: Text(connected ? t(tk: 'Baglanyşygy aýyr', ru: 'Удалить связь', en: 'Remove connection') : t(tk: 'Haýyşy yzyna al', ru: 'Отозвать запрос', en: 'Cancel request')),
              onTap: () => Navigator.pop(sheetContext, 'remove'),
            ),
          ],
        ),
      ),
    );
    if (action == null || !context.mounted) return;
    if (action == 'active') {
      await runApi(context, () => masters.setActive(connection.id));
    } else {
      await runApi(context, () => masters.remove(connection.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    final language = context.watch<LanguageProvider>().language;
    String t({required String tk, required String ru, required String en}) => pickTr(language, tk: tk, ru: ru, en: en);
    final master = connection.master;
    final connected = connection.status == ConnectionStatus.accepted;
    final (statusBg, statusFg, statusLabel) = connected
        ? (freeSlotBg, freeSlotColorDark, connection.active ? t(tk: 'Esasy', ru: 'Основной', en: 'Main') : t(tk: 'Baglanan', ru: 'Подключено', en: 'Connected'))
        : (const Color(0xffFBF1D8), const Color(0xff77540E), t(tk: 'Garaşylýar', ru: 'Ожидание', en: 'Pending'));

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black.withValues(alpha: .05)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: .07), blurRadius: 20, offset: const Offset(0, 8))],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: connected ? () => Navigator.push(context, pageRoute(MasterProfileScreen(master: master))) : null,
          onLongPress: () => _menu(context),
          child: Padding(
            padding: const EdgeInsets.all(13),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MasterAvatar(url: master.photoUrl, radius: 24),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              master.name,
                              style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                            decoration: BoxDecoration(color: statusBg, borderRadius: BorderRadius.circular(10)),
                            child: Text(
                              statusLabel,
                              style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: statusFg),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '@${master.nickname}',
                        style: TextStyle(fontSize: 12, color: tokens.textSecondary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 7),
                      Row(
                        children: [
                          AppIcon(Icons.location_on_outlined, size: 12, color: tokens.textSecondary),
                          const SizedBox(width: 3),
                          Expanded(
                            child: Text(
                              master.address.isEmpty ? '—' : master.address,
                              style: TextStyle(fontSize: 11, color: tokens.textSecondary),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => _menu(context),
                            child: AppIcon(Icons.more_horiz, size: 18, color: tokens.disabled),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
