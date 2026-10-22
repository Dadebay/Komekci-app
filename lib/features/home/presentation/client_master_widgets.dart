part of '../../../app/komekci_app.dart';

/// "My masters" strip on the client home: the accepted connections.
class _ClientMasterCarousel extends StatefulWidget {
  const _ClientMasterCarousel({required this.tk});
  final bool tk;

  @override
  State<_ClientMasterCarousel> createState() => _ClientMasterCarouselState();
}

class _ClientMasterCarouselState extends State<_ClientMasterCarousel> {
  final _controller = PageController(viewportFraction: .78);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final masters = context.watch<ClientMastersProvider>().accepted;
    final language = context.watch<LanguageProvider>().language;
    if (masters.isEmpty) {
      return EmptyState(
        icon: Icons.groups_outlined,
        title: pickTr(language, tk: 'Baglanan masteriňiz ýok', ru: 'Связанных мастеров нет', en: 'No connected masters yet'),
        text: pickTr(
          language,
          tk: 'Lakamy ýa-da telefon belgisi bilen masteri tapyp baglanyň.',
          ru: 'Найдите мастера по никнейму или телефону и подключитесь.',
          en: 'Find a master by nickname or phone and connect.',
        ),
      );
    }
    return SizedBox(
      // A little taller than the cards themselves so their drop shadow has
      // room to render — PageView clips to its own bounds by default.
      height: 226,
      child: PageView.builder(
        controller: _controller,
        itemCount: masters.length + 1,
        // Without this, PageView centers the first/last page instead of
        // starting flush at the left edge, leaving a near-empty-card gap
        // before the first card.
        padEnds: false,
        clipBehavior: Clip.none,
        itemBuilder: (_, index) => Padding(
          padding: const EdgeInsets.only(right: 12, bottom: 12),
          child: index == masters.length
              ? const _AddMasterCard()
              : _ClientMasterCard(master: masters[index].master, tk: widget.tk),
        ),
      ),
    );
  }
}

class _ClientMasterCard extends StatelessWidget {
  const _ClientMasterCard({required this.master, required this.tk});
  final MasterBrief master;
  final bool tk;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    final language = context.watch<LanguageProvider>().language;
    final open = master.acceptingBookings;
    return GestureDetector(
      onTap: () => Navigator.push(context, pageRoute(MasterProfileScreen(master: master))),
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: _bookingCardDecoration(tokens),
        child: Column(
          children: [
            Container(height: 46, color: tokens.surfaceElevated),
            // 30px of layout height: the avatar hangs up into the band above.
            SizedBox(
              height: 30,
              child: OverflowBox(
                alignment: Alignment.topCenter,
                minHeight: 0,
                maxHeight: 90,
                child: Transform.translate(
                  offset: const Offset(0, -30),
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: tokens.surface,
                      border: Border.all(color: tokens.accent, width: 1.6),
                      boxShadow: [BoxShadow(color: tokens.textPrimary.withValues(alpha: .10), blurRadius: 12, offset: const Offset(0, 5))],
                    ),
                    child: MasterAvatar(url: master.photoUrl, radius: 26),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                child: Column(
                  children: [
                    Text(
                      master.name,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '@${master.nickname}',
                      style: TextStyle(fontSize: 12.5, color: tokens.textSecondary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AppIcon(Icons.location_on_outlined, size: 13, color: tokens.textSecondary),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            master.address.isEmpty ? '—' : master.address,
                            style: TextStyle(fontSize: 12, color: tokens.textSecondary),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    SizedBox(
                      width: double.infinity,
                      height: 38,
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: tokens.textPrimary,
                          disabledBackgroundColor: tokens.surfaceElevated,
                          padding: EdgeInsets.zero,
                          shape: const StadiumBorder(),
                        ),
                        onPressed: open ? () => Navigator.push(context, pageRoute(BookingPage(master: master))) : null,
                        child: Text(
                          open
                              ? pickTr(language, tk: 'Ýazyl', ru: 'Записаться', en: 'Book')
                              : pickTr(language, tk: 'Wagtlaýyn ýapyk', ru: 'Запись закрыта', en: 'Paused'),
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: open ? tokens.surface : tokens.textSecondary),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Last slot of the strip: connect one more master.
class _AddMasterCard extends StatelessWidget {
  const _AddMasterCard();

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    final language = context.watch<LanguageProvider>().language;
    return GestureDetector(
      onTap: () => Navigator.push(context, pageRoute(const ConnectMasterScreen())),
      child: Container(
        decoration: BoxDecoration(
          color: tokens.surfaceElevated,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: tokens.accent.withValues(alpha: .35)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 56,
              height: 56,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: tokens.accent.withValues(alpha: .15), shape: BoxShape.circle),
              child: AppIcon(Icons.add, size: 26, color: tokens.accent),
            ),
            const SizedBox(height: 12),
            Text(
              pickTr(language, tk: 'Master goş', ru: 'Добавить мастера', en: 'Add master'),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 4),
            Text(
              pickTr(language, tk: 'Lakam ýa-da telefon', ru: 'Никнейм или телефон', en: 'Nickname or phone'),
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11.5, color: tokens.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
