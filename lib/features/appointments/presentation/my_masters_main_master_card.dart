part of '../../../app/komekci_app.dart';

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
                      t(tk: 'Esasy master', ru: 'Основной мастер', en: 'Main master'),
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
                      t(tk: 'Masteriň kabul etmegine garaşylýar', ru: 'Ждём ответа мастера', en: 'Waiting for the master to accept'),
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
