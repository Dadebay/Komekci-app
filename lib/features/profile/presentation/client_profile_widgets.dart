part of '../../../app/komekci_app.dart';

/// Profile hero: big avatar, name, phone and three live counters, tapping
/// through to [ClientEditProfileScreen].
class _ClientProfileCard extends StatelessWidget {
  const _ClientProfileCard({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    final profile = context.watch<ClientProfileProvider>();
    final language = context.watch<LanguageProvider>().language;
    String t({required String tk, required String ru, required String en}) => pickTr(language, tk: tk, ru: ru, en: en);
    final bookings = context.watch<ClientBookingsProvider>().bookings;
    final upcoming = bookings.where((b) => b.status == ClientBookingStatus.expected).length;
    final masters = context.watch<ClientMastersProvider>().accepted.length;

    Widget stat(String value, String label) => Expanded(
      child: Column(
        children: [
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, height: 1.1)),
          const SizedBox(height: 3),
          Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 11.5, color: tokens.textSecondary)),
        ],
      ),
    );

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(18, 22, 18, 18),
        decoration: _bookingCardDecoration(tokens).copyWith(borderRadius: BorderRadius.circular(28)),
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: tokens.surface,
                    border: Border.all(color: tokens.accent, width: 2),
                  ),
                  child: RoundPhoto(file: profile.avatar, url: profile.avatarUrl, radius: 44),
                ),
                Positioned(
                  right: 0,
                  bottom: 2,
                  child: Container(
                    width: 30,
                    height: 30,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: tokens.accent,
                      shape: BoxShape.circle,
                      border: Border.all(color: tokens.surface, width: 2.5),
                    ),
                    child: AppIcon(Icons.edit_outlined, size: 13, color: tokens.accentOn),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              profile.name,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: tokens.surfaceElevated, borderRadius: BorderRadius.circular(20)),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppIcon(Icons.phone_outlined, size: 13, color: tokens.textSecondary),
                  const SizedBox(width: 6),
                  Text(displayPhone(profile.phone), style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: tokens.textSecondary)),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Container(height: 1, color: tokens.border),
            const SizedBox(height: 16),
            Row(
              children: [
                stat('${bookings.length}', t(tk: 'Ýazgy', ru: 'Записей', en: 'Bookings')),
                Container(width: 1, height: 32, color: tokens.border),
                stat('$upcoming', t(tk: 'Indiki', ru: 'Предстоящих', en: 'Upcoming')),
                Container(width: 1, height: 32, color: tokens.border),
                stat('$masters', t(tk: 'Master', ru: 'Мастеров', en: 'Masters')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// A titled group of settings rows sharing one rounded card.
class _ClientProfileGroup extends StatelessWidget {
  const _ClientProfileGroup({required this.title, required this.children});
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(6, 0, 0, 10),
          child: Text(title, style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: tokens.textSecondary)),
        ),
        Container(
          clipBehavior: Clip.antiAlias,
          decoration: _bookingCardDecoration(tokens),
          child: Material(
            color: Colors.transparent,
            child: Column(
              children: [
                for (var i = 0; i < children.length; i++) ...[
                  children[i],
                  if (i != children.length - 1) Divider(height: 1, thickness: 1, indent: 64, color: tokens.border.withValues(alpha: .7)),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// One row inside a [_ClientProfileGroup]: icon tile, title, the current value
/// on the right and a chevron.
class _ClientProfileMenuRow extends StatelessWidget {
  const _ClientProfileMenuRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: tokens.accent.withValues(alpha: .13), borderRadius: BorderRadius.circular(12)),
              child: AppIcon(icon, color: tokens.accent, size: 18),
            ),
            const SizedBox(width: 14),
            Expanded(child: Text(title, style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700))),
            const SizedBox(width: 8),
            // Not flexible: the title's Expanded pushes the value and chevron
            // to the right edge, the value capped so a long one can't squeeze
            // the title.
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 150),
              child: Text(
                subtitle,
                textAlign: TextAlign.right,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 12.5, color: tokens.textSecondary),
              ),
            ),
            const SizedBox(width: 4),
            AppIcon(Icons.chevron_right, size: 17, color: tokens.disabled),
          ],
        ),
      ),
    );
  }
}

/// Signs the client out — clears [AuthProvider]'s step and drops the entire
/// navigation stack back to [RoleScreen], so a signed-out user can't swipe
/// "back" into the previous session's screens.
class _ClientLogoutButton extends StatelessWidget {
  const _ClientLogoutButton({required this.t});
  final String Function({required String tk, required String ru, required String en}) t;

  Future<void> _confirmAndLogout(BuildContext context) async {
    final confirmed = await _showConfirmDialog(
      context,
      icon: Icons.logout,
      title: t(
        tk: 'Ulgamdan çykmaly?',
        ru: 'Выйти из аккаунта?',
        en: 'Sign out?',
      ),
      message: t(
        tk: 'Ýene-de girmek üçin telefon belgiňizi tassyklamaly bolarsyňyz.',
        ru: 'Чтобы войти снова, потребуется подтвердить номер телефона.',
        en: "You'll need to verify your phone number again to sign back in.",
      ),
      confirmLabel: t(tk: 'Çyk', ru: 'Выйти', en: 'Sign out'),
      cancelLabel: t(tk: 'Ýatyr', ru: 'Отмена', en: 'Cancel'),
      danger: true,
    );
    if (!confirmed || !context.mounted) return;
    final navigator = Navigator.of(context);
    await context.read<AuthProvider>().signOut();
    navigator.pushAndRemoveUntil(pageRoute(const RoleScreen()), (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    return GestureDetector(
      onTap: () => _confirmAndLogout(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: _bookingCardDecoration(tokens),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: tokens.danger.withValues(alpha: .12), borderRadius: BorderRadius.circular(12)),
              child: AppIcon(Icons.logout, size: 18, color: tokens.danger),
            ),
            const SizedBox(width: 14),
            Text(
              t(tk: 'Ulgamdan çyk', ru: 'Выйти из аккаунта', en: 'Sign out'),
              style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700, color: tokens.danger),
            ),
          ],
        ),
      ),
    );
  }
}
