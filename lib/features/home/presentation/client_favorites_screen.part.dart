part of '../../../app/komekci_app.dart';

/// Favourited masters — the "Halanlarym" bottom-nav tab. Reads and mutates
/// [_favoriteMasterIds] directly so a heart tap here or on
/// [MasterProfileScreen] is reflected everywhere immediately.
class ClientFavoritesScreen extends StatelessWidget {
  const ClientFavoritesScreen({super.key});

  Future<void> _clearAll(BuildContext context, AppLanguage language) async {
    final confirmed = await _showConfirmDialog(
      context,
      icon: Icons.favorite_border,
      title: pickTr(language, tk: 'Halanlary arassalamaly?', ru: 'Очистить избранное?', en: 'Clear favourites?'),
      message: pickTr(language, tk: 'Ähli halanan ussalaryňyz sanawdan aýrylar.', ru: 'Все мастера будут удалены из избранного.', en: 'All masters will be removed from your favourites.'),
      confirmLabel: pickTr(language, tk: 'Arassala', ru: 'Очистить', en: 'Clear'),
      cancelLabel: pickTr(language, tk: 'Ýatyr', ru: 'Отмена', en: 'Cancel'),
      danger: true,
    );
    if (confirmed) _favoriteMasterIds.value = {};
  }

  @override
  Widget build(BuildContext context) {
    final language = context.watch<LanguageProvider>().language;
    final tk = language == AppLanguage.tk;
    final tokens = context.appTokens;
    final canPop = Navigator.of(context).canPop();

    return ValueListenableBuilder<Set<String>>(
      valueListenable: _favoriteMasterIds,
      builder: (context, ids, _) {
        final favorites = _clientMasters.where((m) => ids.contains(m.id)).toList();
        return Scaffold(
          backgroundColor: tokens.surface,
          appBar: CabinetAppBar(
            title: pickTr(language, tk: 'Halanlarym', ru: 'Избранное', en: 'Favourites'),
            action: favorites.isEmpty
                ? null
                : GestureDetector(
                    onTap: () => _clearAll(context, language),
                    child: SizedBox(
                      width: 34,
                      height: 34,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: AppIcon(Icons.delete_outline, color: tokens.danger, size: 21),
                      ),
                    ),
                  ),
          ),
          body: SafeArea(
            bottom: false,
            child: favorites.isEmpty
                ? ListView(
                    padding: EdgeInsets.fromLTRB(20, 8, 20, canPop ? 20 : 110),
                    children: [
                      const SizedBox(height: 32),
                      EmptyState(
                        icon: Icons.favorite_border,
                        title: pickTr(language, tk: 'Halanan ussaňyz ýok', ru: 'Избранных мастеров нет', en: 'No favourite masters yet'),
                        text: pickTr(
                          language,
                          tk: 'Ussanyň profilinde ýürek belligine basyp, ony halanlaryňyza goşuň.',
                          ru: 'Нажмите на сердце в профиле мастера, чтобы добавить его сюда.',
                          en: "Tap the heart on a master's profile to add them here.",
                        ),
                        action: OutlinedButton(
                          onPressed: () => Navigator.push(context, pageRoute(const ClientMastersScreen())),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: tokens.textPrimary,
                            side: BorderSide(color: tokens.border),
                            shape: const CircleBorder(),
                            padding: const EdgeInsets.all(14),
                          ),
                          child: const AppIcon(Icons.search, size: 20),
                        ),
                      ),
                    ],
                  )
                : ListView(
                    padding: EdgeInsets.fromLTRB(20, 10, 20, canPop ? 20 : 110),
                    children: [
                      ...favorites.map((m) => _FavoriteMasterCard(key: ValueKey('favorite-${m.id}'), master: m, tk: tk)),
                    ],
                  ),
          ),
        );
      },
    );
  }
}

/// A favourited master's card on [ClientFavoritesScreen] — like
/// [_ClientMasterListRow] but with a gold ring on the avatar, a rating line,
/// and two ways to unfavourite: tapping the heart (instant) or swiping the
/// card away (via [Dismissible]).
class _FavoriteMasterCard extends StatelessWidget {
  const _FavoriteMasterCard({super.key, required this.master, required this.tk});
  final _ClientMaster master;
  final bool tk;

  void _unfavorite() => _favoriteMasterIds.value = {..._favoriteMasterIds.value}..remove(master.id);

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    final rating = _masterRating(master);
    final reviews = _masterReviewCount(master);

    return Dismissible(
      key: ValueKey('dismiss-${master.id}'),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => _unfavorite(),
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 22),
        alignment: Alignment.centerRight,
        decoration: BoxDecoration(color: tokens.danger, borderRadius: BorderRadius.circular(16)),
        child: const AppIcon(Icons.delete_outline, color: Colors.white, size: 22),
      ),
      child: InkWell(
        onTap: () => Navigator.push(context, pageRoute(MasterProfileScreen(master: master))),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.black.withValues(alpha: .05)),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: .07), blurRadius: 20, offset: const Offset(0, 8))],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: tokens.accent.withValues(alpha: .55), width: 1.4),
                ),
                child: CircleAvatar(
                  radius: 23,
                  backgroundColor: const Color(0xffE6D2B1),
                  child: AppIcon(Icons.person_outline, size: 20, color: tokens.textPrimary),
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tk ? master.nameTk : master.nameRu,
                      style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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
                        Text(
                          '★ ${rating.toStringAsFixed(1)}',
                          style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: tokens.accent),
                        ),
                        const SizedBox(width: 3),
                        Text('($reviews)', style: TextStyle(fontSize: 10.5, color: tokens.textSecondary)),
                        const SizedBox(width: 8),
                        AppIcon(Icons.location_on_outlined, size: 11, color: tokens.textSecondary),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            tk ? master.locationTk : master.locationRu,
                            style: TextStyle(fontSize: 10.5, color: tokens.textSecondary),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Column(
                children: [
                  GestureDetector(
                    onTap: _unfavorite,
                    child: const AppIcon(Icons.favorite, size: 19, color: Color(0xffD84C3F)),
                  ),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: () => Navigator.push(context, pageRoute(BookingPage(masterName: tk ? master.nameTk : master.nameRu))),
                    child: Container(
                      width: 34,
                      height: 34,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(color: tokens.textPrimary, shape: BoxShape.circle),
                      child: AppIcon(Icons.calendar_month_outlined, size: 16, color: tokens.surface),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
