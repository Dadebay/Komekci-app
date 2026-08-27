part of '../../../app/komekci_app.dart';

/// A master the client has linked their account to — 'connected' once the
/// master accepts, 'pending' while awaiting their response.
enum _MyMasterStatus { connected, pending }

/// Mock "my masters" list — the first two entries of [_clientMasters] read
/// as connected, the third as still pending, so both states have something
/// real to show without a backend.
final _myMasters = [
  (_clientMasters[0], _MyMasterStatus.connected),
  (_clientMasters[1], _MyMasterStatus.connected),
  (_clientMasters[2], _MyMasterStatus.pending),
];

class MyMastersScreen extends StatelessWidget {
  const MyMastersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final language = context.watch<LanguageProvider>().language;
    final tk = language == AppLanguage.tk;
    String t({required String tk, required String ru, required String en}) =>
        pickTr(language, tk: tk, ru: ru, en: en);
    final tokens = context.appTokens;
    final canPop = Navigator.of(context).canPop();

    return Scaffold(
      backgroundColor: tokens.surface,
      appBar: CabinetAppBar(
        title: t(tk: 'Ussalarym', ru: 'Мои мастера', en: 'My masters'),
      ),
      body: SafeArea(
        bottom: false,
        child: _myMasters.isEmpty
            ? Center(
                child: SizedBox(
                  width: double.infinity,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(20, 10, 20, canPop ? 20 : 110),
                    child: EmptyState(
                      icon: Icons.groups_outlined,
                      title: t(
                        tk: 'Baglanan ussaňyz ýok',
                        ru: 'Связанных мастеров нет',
                        en: 'No connected masters yet',
                      ),
                      text: t(
                        tk: 'Ussa goşup, bir näçe minutda baglanyşyň.',
                        ru: 'Добавьте мастера, чтобы связаться с ним.',
                        en: 'Add a master to connect with them.',
                      ),
                    ),
                  ),
                ),
              )
            : ListView(
                padding: EdgeInsets.fromLTRB(20, 12, 20, canPop ? 20 : 24),
                children: [
                  ..._myMasters.map(
                    (entry) => _MyMasterCard(master: entry.$1, status: entry.$2, tk: tk),
                  ),
                ],
              ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
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
  const _MyMasterCard({required this.master, required this.status, required this.tk});
  final _ClientMaster master;
  final _MyMasterStatus status;
  final bool tk;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    final language = context.watch<LanguageProvider>().language;
    String t({required String tk, required String ru, required String en}) =>
        pickTr(language, tk: tk, ru: ru, en: en);
    final connected = status == _MyMasterStatus.connected;
    final (statusBg, statusFg, statusLabel) = connected
        ? (freeSlotBg, freeSlotColorDark, t(tk: 'Baglanan', ru: 'Подключено', en: 'Connected'))
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
          onTap: () => Navigator.push(context, pageRoute(MasterProfileScreen(master: master))),
          child: Container(
            padding: const EdgeInsets.all(13),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: const Color(0xffE6D2B1),
                  child: AppIcon(Icons.person_outline, size: 21, color: tokens.textPrimary),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              tk ? master.nameTk : master.nameRu,
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
                        tk ? master.specialtyTk : master.specialtyRu,
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
                              tk ? master.locationTk : master.locationRu,
                              style: TextStyle(fontSize: 11, color: tokens.textSecondary),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          AppIcon(Icons.chevron_right, size: 15, color: tokens.disabled),
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

