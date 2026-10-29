part of '../../../app/komekci_app.dart';

class _ConnectHero extends StatelessWidget {
  const _ConnectHero({required this.title, required this.subtitle});
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 16, 20),
      decoration: _flatTintDecoration(tokens, tokens.accent),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13.5,
                    height: 1.4,
                    color: tokens.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Container(
            width: 84,
            height: 84,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: tokens.accent.withValues(alpha: .16),
              shape: BoxShape.circle,
            ),
            child: Container(
              width: 60,
              height: 60,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: tokens.surface,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: tokens.accent.withValues(alpha: .3),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: AppIcon(
                Icons.person_search_outlined,
                size: 28,
                color: tokens.accent,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Tap to start the field with "@" or "+993 ".
class _HintChip extends StatelessWidget {
  const _HintChip({
    required this.icon,
    required this.label,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: tokens.surfaceElevated,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: tokens.border.withValues(alpha: .7)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppIcon(icon, size: 14, color: tokens.textSecondary),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: tokens.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchBox extends StatelessWidget {
  const _SearchBox({
    required this.controller,
    required this.focusNode,
    required this.searching,
    required this.hint,
    required this.onSearch,
    required this.onClear,
  });
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool searching;
  final String hint;
  final VoidCallback onSearch;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    return ListenableBuilder(
      listenable: Listenable.merge([controller, focusNode]),
      builder: (context, _) => AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          color: tokens.surface,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: focusNode.hasFocus ? tokens.accent : tokens.border,
            width: focusNode.hasFocus ? 1.6 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: tokens.textPrimary.withValues(alpha: .06),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 10),
              child: AppIcon(
                Icons.search,
                size: 22,
                color: focusNode.hasFocus
                    ? tokens.accent
                    : tokens.textSecondary,
              ),
            ),
            Expanded(
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                autocorrect: false,
                enableSuggestions: false,
                textInputAction: TextInputAction.search,
                onSubmitted: (_) => onSearch(),
                style: const TextStyle(
                  fontSize: 15.5,
                  fontWeight: FontWeight.w600,
                ),
                decoration: InputDecoration(
                  hintText: hint,
                  hintStyle: TextStyle(
                    color: tokens.disabled,
                    fontWeight: FontWeight.w400,
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  filled: false,
                  contentPadding: const EdgeInsets.symmetric(vertical: 18),
                ),
              ),
            ),
            if (controller.text.isNotEmpty && !searching)
              IconButton(
                onPressed: onClear,
                icon: AppIcon(
                  Icons.close,
                  size: 18,
                  color: tokens.textSecondary,
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(6),
              child: SizedBox(
                width: 46,
                height: 46,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: tokens.textPrimary,
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: searching ? null : onSearch,
                  child: searching
                      ? SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.2,
                            color: tokens.surface,
                          ),
                        )
                      : AppIcon(
                          Icons.arrow_forward,
                          size: 20,
                          color: tokens.surface,
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The master found by the search, with a one-tap connect button.
class _MasterResultCard extends StatelessWidget {
  const _MasterResultCard({
    required this.master,
    required this.connection,
    required this.connecting,
    required this.onConnect,
  });
  final MasterBrief master;
  final ClientConnection? connection;
  final bool connecting;
  final VoidCallback onConnect;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    final language = context.watch<LanguageProvider>().language;
    String t({required String tk, required String ru, required String en}) =>
        pickTr(language, tk: tk, ru: ru, en: en);
    final status = connection?.status;
    final connected = status == ConnectionStatus.accepted;
    final pending = status == ConnectionStatus.pending;
    final statusColor = master.acceptingBookings
        ? tokens.success
        : tokens.warning;

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: _bookingCardDecoration(
        tokens,
      ).copyWith(borderRadius: BorderRadius.circular(26)),
      child: Column(
        children: [
          Container(height: 78, color: tokens.surfaceElevated),
          // Only 46px of layout height: the avatar hangs 40px up into the banner.
          SizedBox(
            height: 46,
            child: OverflowBox(
              alignment: Alignment.topCenter,
              minHeight: 0,
              maxHeight: 100,
              child: Transform.translate(
                offset: const Offset(0, -40),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: tokens.surface,
                    boxShadow: [
                      BoxShadow(
                        color: tokens.textPrimary.withValues(alpha: .12),
                        blurRadius: 14,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: tokens.accent, width: 1.8),
                    ),
                    child: MasterAvatar(url: master.photoUrl, radius: 36),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
            child: Column(
              children: [
                Text(
                  master.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _ProfilePill(label: '@${master.nickname}'),
                    if (master.address.isNotEmpty)
                      _ProfilePill(
                        icon: Icons.location_on_outlined,
                        label: master.address,
                      ),
                    _ProfilePill(
                      dotColor: statusColor,
                      label: master.acceptingBookings
                          ? t(
                              tk: 'Ýazgy kabul edýär',
                              ru: 'Принимает записи',
                              en: 'Accepting bookings',
                            )
                          : t(
                              tk: 'Wagtlaýyn ýapyk',
                              ru: 'Запись временно закрыта',
                              en: 'Bookings paused',
                            ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: tokens.textPrimary,
                      disabledBackgroundColor: tokens.surfaceElevated,
                      shape: const StadiumBorder(),
                    ),
                    onPressed: connected || pending || connecting
                        ? null
                        : onConnect,
                    icon: connecting
                        ? SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.2,
                              color: tokens.surface,
                            ),
                          )
                        : AppIcon(
                            connected
                                ? Icons.check
                                : (pending
                                      ? Icons.hourglass_empty
                                      : Icons.person_add_alt_1),
                            size: 19,
                            color: connected || pending
                                ? tokens.textSecondary
                                : tokens.surface,
                          ),
                    label: Text(
                      connected
                          ? t(
                              tk: 'Eýýäm baglanyşykly',
                              ru: 'Уже подключены',
                              en: 'Already connected',
                            )
                          : pending
                          ? t(
                              tk: 'Haýyş iberildi',
                              ru: 'Запрос отправлен',
                              en: 'Request sent',
                            )
                          : t(tk: 'Baglan', ru: 'Подключиться', en: 'Connect'),
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: connected || pending
                            ? tokens.textSecondary
                            : tokens.surface,
                      ),
                    ),
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
