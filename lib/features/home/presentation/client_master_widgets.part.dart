part of '../../../app/komekci_app.dart';

/// "My masters" strip on the client home: the accepted connections.
class _ClientMasterCarousel extends StatefulWidget {
  const _ClientMasterCarousel({required this.tk});
  final bool tk;

  @override
  State<_ClientMasterCarousel> createState() => _ClientMasterCarouselState();
}

class _ClientMasterCarouselState extends State<_ClientMasterCarousel> {
  final _controller = PageController(viewportFraction: .4);

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
        title: pickTr(language, tk: 'Baglanan ussaňyz ýok', ru: 'Связанных мастеров нет', en: 'No connected masters yet'),
        text: pickTr(
          language,
          tk: 'Lakamy ýa-da telefon belgisi bilen ussany tapyp baglanyň.',
          ru: 'Найдите мастера по никнейму или телефону и подключитесь.',
          en: 'Find a master by nickname or phone and connect.',
        ),
      );
    }
    return SizedBox(
      // A little taller than the cards themselves so their drop shadow has
      // room to render — PageView clips to its own bounds by default.
      height: 190,
      child: PageView.builder(
        controller: _controller,
        itemCount: masters.length,
        // Without this, PageView centers the first/last page instead of
        // starting flush at the left edge, leaving a near-empty-card gap
        // before the first card.
        padEnds: false,
        clipBehavior: Clip.none,
        itemBuilder: (_, index) => Padding(
          padding: const EdgeInsets.only(right: 12, bottom: 12),
          child: _ClientMasterCard(master: masters[index].master, tk: widget.tk),
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
    return InkWell(
      onTap: () => Navigator.push(context, pageRoute(MasterProfileScreen(master: master))),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.black.withValues(alpha: .05)),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: .07), blurRadius: 20, offset: const Offset(0, 8)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: tokens.accent.withValues(alpha: .55), width: 1.4),
              ),
              child: MasterAvatar(url: master.photoUrl, radius: 21),
            ),
            const SizedBox(height: 10),
            Text(
              master.name,
              style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 3),
            Text(
              '@${master.nickname}',
              style: TextStyle(fontSize: 10.5, color: tokens.textSecondary),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                AppIcon(Icons.location_on_outlined, size: 10, color: tokens.textSecondary),
                const SizedBox(width: 3),
                Expanded(
                  child: Text(
                    master.address.isEmpty ? '—' : master.address,
                    style: TextStyle(fontSize: 9.5, color: tokens.textSecondary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 32,
              child: FilledButton(
                style: FilledButton.styleFrom(backgroundColor: tokens.textPrimary, padding: EdgeInsets.zero, shape: const StadiumBorder()),
                onPressed: master.acceptingBookings
                    ? () => Navigator.push(context, pageRoute(BookingPage(master: master)))
                    : null,
                child: Text(
                  pickTr(language, tk: 'Ýazyl', ru: 'Записаться', en: 'Book'),
                  style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
