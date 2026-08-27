part of '../../../app/komekci_app.dart';

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
  Widget build(BuildContext context) => SizedBox(
    // A little taller than the cards themselves so their drop shadow has
    // room to render — PageView clips to its own bounds by default.
    height: 214,
    child: PageView.builder(
      controller: _controller,
      itemCount: _clientMasters.length,
      // Without this, PageView centers the first/last page instead of
      // starting flush at the left edge, leaving a near-empty-card gap
      // before the first card.
      padEnds: false,
      clipBehavior: Clip.none,
      itemBuilder: (_, index) => Padding(
        padding: const EdgeInsets.only(right: 12, bottom: 12),
        child: _ClientMasterCard(master: _clientMasters[index], tk: widget.tk),
      ),
    ),
  );
}

class _ClientMasterCard extends StatelessWidget {
  const _ClientMasterCard({required this.master, required this.tk});
  final _ClientMaster master;
  final bool tk;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    final language = context.watch<LanguageProvider>().language;
    final rating = _masterRating(master);
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
              child: CircleAvatar(
                radius: 21,
                backgroundColor: const Color(0xffE6D2B1),
                child: AppIcon(Icons.person_outline, size: 19, color: tokens.textPrimary),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              tk ? master.nameTk : master.nameRu,
              style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 3),
            Text(
              tk ? master.specialtyTk : master.specialtyRu,
              style: TextStyle(fontSize: 10.5, color: tokens.textSecondary),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Text(
                  '★ ${rating.toStringAsFixed(1)}',
                  style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: tokens.accent),
                ),
                const SizedBox(width: 6),
                AppIcon(Icons.location_on_outlined, size: 10, color: tokens.textSecondary),
                const SizedBox(width: 3),
                Expanded(
                  child: Text(
                    tk ? master.locationTk : master.locationRu,
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
                onPressed: () => Navigator.push(context, pageRoute(BookingPage(masterName: tk ? master.nameTk : master.nameRu))),
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

class _ClientMasterListRow extends StatelessWidget {
  const _ClientMasterListRow({required this.master, required this.tk});
  final _ClientMaster master;
  final bool tk;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    final language = context.watch<LanguageProvider>().language;
    return InkWell(
      onTap: () => Navigator.push(context, pageRoute(MasterProfileScreen(master: master))),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: tokens.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: tokens.border.withValues(alpha: .6)),
          boxShadow: [
            BoxShadow(
              color: tokens.textPrimary.withValues(alpha: .05),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: tokens.surfaceElevated,
              child: AppIcon(Icons.person_outline, size: 22, color: tokens.textPrimary),
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
                      AppIcon(Icons.chevron_right, size: 16, color: tokens.disabled),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(tk ? master.specialtyTk : master.specialtyRu, style: TextStyle(fontSize: 12, color: tokens.textSecondary)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
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
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        height: 34,
                        child: FilledButton(
                          style: FilledButton.styleFrom(backgroundColor: tokens.textPrimary, shape: const StadiumBorder(), padding: const EdgeInsets.symmetric(horizontal: 16)),
                          onPressed: () => Navigator.push(context, pageRoute(BookingPage(masterName: tk ? master.nameTk : master.nameRu))),
                          child: Text(
                            pickTr(language, tk: 'Ýazyl', ru: 'Записаться', en: 'Book'),
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
