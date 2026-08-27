part of '../../../app/komekci_app.dart';

// ── Master profile ─────────────────────────────────────────────────────────
// No backend yet, so rating/experience/services are derived deterministically
// from the master's id instead of being separate fields to keep — the mock
// data stays believable without a per-master entry explosion.

double _masterRating(_ClientMaster m) => 4.5 + ((m.id.hashCode.abs() % 5) / 10);
int _masterReviewCount(_ClientMaster m) => 40 + (m.id.hashCode.abs() % 160);
int _masterExperience(_ClientMaster m) => 2 + (m.id.hashCode.abs() % 9);

/// Splits the specialty string ("Manikýur, pedikýur") into individual priced
/// rows, so the profile's service list always matches what the card shows.
List<(String name, int price, int minutes)> _masterServices(_ClientMaster m, AppLanguage language) {
  // No English specialty field exists on the mock master data — English
  // falls back to the Latin-script Turkmen text rather than the Russian one.
  final specialty = language == AppLanguage.ru ? m.specialtyRu : m.specialtyTk;
  final parts = specialty.split(RegExp(r'[,/]')).map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
  final seed = m.id.hashCode.abs();
  return List.generate(parts.length, (i) {
    final price = 40 + ((seed + i * 37) % 8) * 10;
    final minutes = 30 + ((seed + i * 19) % 5) * 15;
    return (parts[i], price, minutes);
  });
}

String _masterBio(_ClientMaster m, AppLanguage language) {
  final years = _masterExperience(m);
  switch (language) {
    case AppLanguage.tk:
      final district = m.locationTk.split(', ').last;
      return '${m.nameTk} Aşgabadyň $district etrabynda kabul edýär. ${m.specialtyTk} ugrunda $years ýyldan gowrak tejribesi bar we her müşderä şahsy çemeleşme hödürleýär.';
    case AppLanguage.ru:
      final district = m.locationRu.split(', ').last;
      return '${m.nameRu} принимает в районе «$district» в Ашхабаде. Специализация: ${m.specialtyRu.toLowerCase()}. Опыт более $years лет, индивидуальный подход к каждому клиенту.';
    case AppLanguage.en:
      final district = m.locationTk.split(', ').last;
      return '${m.nameTk} sees clients in the $district district of Ashgabat. With over $years years of experience in ${m.specialtyTk.toLowerCase()}, they offer a personal approach to every client.';
  }
}

/// Full master profile — hero header with an overlapping avatar, rating and
/// experience stats, a bio and a derived service list, with a sticky
/// price-and-book bar pinned to the bottom.
class MasterProfileScreen extends StatefulWidget {
  // ignore: library_private_types_in_public_api
  const MasterProfileScreen({super.key, required this.master});
  // ignore: library_private_types_in_public_api
  final _ClientMaster master;

  @override
  State<MasterProfileScreen> createState() => _MasterProfileScreenState();
}

class _MasterProfileScreenState extends State<MasterProfileScreen> {
  bool get _favorite => _favoriteMasterIds.value.contains(widget.master.id);

  @override
  void initState() {
    super.initState();
    _favoriteMasterIds.addListener(_onFavoritesChanged);
  }

  @override
  void dispose() {
    _favoriteMasterIds.removeListener(_onFavoritesChanged);
    super.dispose();
  }

  void _onFavoritesChanged() => setState(() {});

  void _toggleFavorite() {
    final next = {..._favoriteMasterIds.value};
    if (!next.remove(widget.master.id)) next.add(widget.master.id);
    _favoriteMasterIds.value = next;
  }

  @override
  Widget build(BuildContext context) {
    final language = context.watch<LanguageProvider>().language;
    final tk = language == AppLanguage.tk;
    String t({required String tk, required String ru, required String en}) => pickTr(language, tk: tk, ru: ru, en: en);
    final tokens = context.appTokens;
    final m = widget.master;
    final rating = _masterRating(m);
    final reviews = _masterReviewCount(m);
    final years = _masterExperience(m);
    final services = _masterServices(m, language);
    final priceFrom = services.isEmpty ? 0 : services.map((s) => s.$2).reduce((a, b) => a < b ? a : b);

    return Scaffold(
      backgroundColor: tokens.surface,
      body: Stack(
        children: [
          ListView(
            padding: EdgeInsets.zero,
            children: [
              _MasterProfileHero(master: m),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(tk ? m.nameTk : m.nameRu, style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w700)),
                    ),
                    const SizedBox(height: 4),
                    Center(
                      child: Text(
                        tk ? m.specialtyTk : m.specialtyRu,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 13.5, color: tokens.textSecondary),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AppIcon(Icons.location_on_outlined, size: 13, color: tokens.textSecondary),
                          const SizedBox(width: 3),
                          Text(tk ? m.locationTk : m.locationRu, style: TextStyle(fontSize: 12.5, color: tokens.textSecondary)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 22),
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(color: tokens.surfaceElevated, borderRadius: BorderRadius.circular(18)),
                      child: Row(
                        children: [
                          Expanded(
                            child: Stat(
                              label: t(tk: 'Baha', ru: 'Рейтинг', en: 'Rating'),
                              value: '★ ${rating.toStringAsFixed(1)}',
                            ),
                          ),
                          Container(width: 1, height: 30, color: tokens.border),
                          Expanded(
                            child: Stat(
                              label: t(tk: 'Synlar', ru: 'Отзывы', en: 'Reviews'),
                              value: '$reviews',
                            ),
                          ),
                          Container(width: 1, height: 30, color: tokens.border),
                          Expanded(
                            child: Stat(
                              label: t(tk: 'Tejribe', ru: 'Опыт', en: 'Experience'),
                              value: t(tk: '$years ýyl', ru: '$years лет', en: '$years yrs'),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      t(tk: 'Hakynda', ru: 'О мастере', en: 'About'),
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 8),
                    Text(_masterBio(m, language), style: TextStyle(fontSize: 13, color: tokens.textSecondary, height: 1.55)),
                    const SizedBox(height: 24),
                    Text(
                      t(tk: 'Hyzmatlar', ru: 'Услуги', en: 'Services'),
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 10),
                    ...services.map((service) => _MasterServiceRow(name: service.$1, price: service.$2, minutes: service.$3)),
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _MasterProfileIconButton(icon: Icons.arrow_back, onTap: () => Navigator.maybePop(context)),
                    _MasterProfileIconButton(icon: _favorite ? Icons.favorite : Icons.favorite_border, iconColor: _favorite ? const Color(0xffD84C3F) : tokens.textPrimary, onTap: _toggleFavorite),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              top: false,
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
                decoration: BoxDecoration(
                  color: tokens.surface,
                  border: Border(top: BorderSide(color: tokens.border)),
                ),
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          t(tk: 'Başlangyç bahasy', ru: 'Цена от', en: 'Starting from'),
                          style: TextStyle(fontSize: 11, color: tokens.textSecondary),
                        ),
                        Text(
                          '$priceFrom ${t(tk: 'manat', ru: 'манат', en: 'TMT')}',
                          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
                        ),
                      ],
                    ),
                    const Spacer(),
                    SizedBox(
                      height: 50,
                      child: FilledButton(
                        style: FilledButton.styleFrom(backgroundColor: tokens.textPrimary, shape: const StadiumBorder(), padding: const EdgeInsets.symmetric(horizontal: 30)),
                        onPressed: () => Navigator.push(context, pageRoute(BookingPage(masterName: tk ? m.nameTk : m.nameRu))),
                        child: Text(
                          t(tk: 'Ýazyl', ru: 'Записаться', en: 'Book'),
                          style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MasterProfileHero extends StatelessWidget {
  const _MasterProfileHero({required this.master});
  final _ClientMaster master;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    return SizedBox(
      height: 194,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            height: 150,
            decoration: BoxDecoration(
              gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [const Color(0xffFBF1D8), tokens.surface]),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(shape: BoxShape.circle, color: tokens.surface),
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.fromBorderSide(BorderSide(color: tokens.accent, width: 2)),
                  ),
                  child: CircleAvatar(
                    radius: 40,
                    backgroundColor: const Color(0xffE6D2B1),
                    child: AppIcon(Icons.person_outline, size: 36, color: tokens.textPrimary),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MasterProfileIconButton extends StatelessWidget {
  const _MasterProfileIconButton({required this.icon, required this.onTap, this.iconColor});
  final IconData icon;
  final Color? iconColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: tokens.surface.withValues(alpha: .85),
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: tokens.textPrimary.withValues(alpha: .08), blurRadius: 10, offset: const Offset(0, 3))],
        ),
        child: AppIcon(icon, size: 18, color: iconColor ?? tokens.textPrimary),
      ),
    );
  }
}

class _MasterServiceRow extends StatelessWidget {
  const _MasterServiceRow({required this.name, required this.price, required this.minutes});
  final String name;
  final int price;
  final int minutes;

  @override
  Widget build(BuildContext context) {
    final language = context.watch<LanguageProvider>().language;
    final tokens = context.appTokens;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      decoration: BoxDecoration(
        color: tokens.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: tokens.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600)),
                const SizedBox(height: 3),
                Row(
                  children: [
                    const AppIcon(Icons.schedule_outlined, size: 12, color: Colors.black38),
                    const SizedBox(width: 4),
                    Text(
                      '$minutes ${pickTr(language, tk: 'min', ru: 'мин', en: 'min')}',
                      style: const TextStyle(fontSize: 11.5, color: Colors.black45),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Text(
            '$price ${pickTr(language, tk: 'manat', ru: 'манат', en: 'TMT')}',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: tokens.accent),
          ),
        ],
      ),
    );
  }
}
