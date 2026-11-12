part of '../../../app/komekci_app.dart';

/// Pops up on the master's screen when a client sends a new connection
/// request, so it is not only a badge on the Cabinet tab. [fresh] are the
/// requests not seen yet; the newest is shown, the rest are counted.
Future<void> showNewConnectionRequestDialog(
  BuildContext context,
  List<ConnectionRequest> fresh,
) {
  final latest = fresh.reduce(
    (a, b) => b.requestedAt.isAfter(a.requestedAt) ? b : a,
  );
  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'close',
    barrierColor: Colors.black.withValues(alpha: .45),
    transitionDuration: const Duration(milliseconds: 260),
    pageBuilder: (_, _, _) =>
        _NewConnectionRequestDialog(request: latest, others: fresh.length - 1),
    transitionBuilder: (_, animation, _, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutBack,
        reverseCurve: Curves.easeIn,
      );
      return FadeTransition(
        opacity: animation,
        child: ScaleTransition(
          scale: Tween(begin: .9, end: 1.0).animate(curved),
          child: child,
        ),
      );
    },
  );
}

class _NewConnectionRequestDialog extends StatefulWidget {
  const _NewConnectionRequestDialog({
    required this.request,
    required this.others,
  });
  final ConnectionRequest request;
  final int others;

  @override
  State<_NewConnectionRequestDialog> createState() =>
      _NewConnectionRequestDialogState();
}

class _NewConnectionRequestDialogState
    extends State<_NewConnectionRequestDialog> {
  bool _busy = false;

  Future<void> _answer({required bool accept}) async {
    final provider = context.read<ConnectionRequestsProvider>();
    final customers = context.read<CustomerProvider>();
    final id = widget.request.id;
    setState(() => _busy = true);
    final ok = await runApi(
      context,
      () => accept ? provider.accept(id) : provider.decline(id),
    );
    if (!mounted) return;
    if (ok) {
      if (accept) customers.load();
      Navigator.of(context).pop();
    } else {
      setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final language = context.watch<LanguageProvider>().language;
    final tokens = context.appTokens;
    final r = widget.request;
    final nickname = (r.clientNickname ?? '').trim();
    return Dialog(
      backgroundColor: tokens.surface,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 26, 22, 14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: tokens.accent.withValues(alpha: .12),
                  ),
                  child: MasterAvatar(url: r.clientPhotoUrl, radius: 40),
                ),
                Positioned(
                  right: -2,
                  bottom: -2,
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: tokens.accent,
                      border: Border.all(color: tokens.surface, width: 3),
                    ),
                    child: const Icon(
                      Icons.person_add_alt_1_rounded,
                      size: 14,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              AppStrings.requestsNewConnectionRequest.select(language),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: tokens.accent,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              r.clientName,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
            ),
            if (nickname.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(
                '@$nickname',
                style: TextStyle(fontSize: 13.5, color: tokens.textSecondary),
              ),
            ],
            const SizedBox(height: 10),
            Text(
              AppStrings.requestsFoundYouAndWantsTo.select(language),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12.5,
                height: 1.45,
                color: tokens.textSecondary,
              ),
            ),
            const SizedBox(height: 20),
            MasterActionButton(
              label: _busy
                  ? AppStrings.requestsPleaseWait.select(language)
                  : AppStrings.notificationsAccept.select(language),
              enabled: !_busy,
              leading: Icons.check_rounded,
              onTap: () => _answer(accept: true),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton(
                onPressed: _busy ? null : () => _answer(accept: false),
                style: OutlinedButton.styleFrom(
                  foregroundColor: tokens.danger,
                  side: BorderSide(color: tokens.danger.withValues(alpha: .5)),
                  shape: const StadiumBorder(),
                ),
                child: Text(
                  AppStrings.requestsDecline.select(language),
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
            const SizedBox(height: 4),
            TextButton(
              onPressed: _busy
                  ? null
                  : () {
                      final navigator = Navigator.of(context);
                      navigator.pop();
                      if (widget.others > 0) {
                        navigator.push(pageRoute(const RequestsScreen()));
                      }
                    },
              child: Text(
                widget.others > 0
                    ? AppStrings.requestsSeeAllRequests(
                        widget.others,
                      ).select(language)
                    : AppStrings.requestsLater.select(language),
                style: TextStyle(
                  color: tokens.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
