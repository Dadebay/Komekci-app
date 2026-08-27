part of '../../../app/komekci_app.dart';

/// Avatar + name + phone summary, tapping through to [ClientEditProfileScreen].
/// Mirrors the master side's `_MasterCard` so both roles share one visual
/// language for "this is your account" cards.
class _ClientProfileCard extends StatelessWidget {
  const _ClientProfileCard({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    final profile = context.watch<ClientProfileProvider>();
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: Colors.black.withValues(alpha: .05)),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: .07), blurRadius: 20, offset: const Offset(0, 8))],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 32,
              backgroundColor: const Color(0xffE6D2B1),
              backgroundImage: profile.avatar != null
                  ? FileImage(profile.avatar!)
                  : null,
              child: profile.avatar == null
                  ? AppIcon(
                      Icons.person_outline,
                      size: 28,
                      color: tokens.textPrimary,
                    )
                  : null,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    profile.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      AppIcon(
                        Icons.phone_outlined,
                        size: 13,
                        color: tokens.textSecondary,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        profile.phone,
                        style: TextStyle(
                          fontSize: 12.5,
                          color: tokens.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              width: 34,
              height: 34,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: tokens.accent.withValues(alpha: .12),
                shape: BoxShape.circle,
              ),
              child: AppIcon(Icons.edit_outlined, size: 15, color: tokens.accent),
            ),
          ],
        ),
      ),
    );
  }
}

/// One row of [ClientProfile]'s menu: icon chip, title + status subtitle,
/// chevron. Card-styled (unlike the old bare `ListTile` `SettingRow`) so it
/// matches the rest of the client app's bordered, rounded card language.
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
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withValues(alpha: .05)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: .07), blurRadius: 20, offset: const Offset(0, 8))],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: tokens.accent.withValues(alpha: .12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: AppIcon(icon, color: tokens.accent, size: 18),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 11.5,
                          color: tokens.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                AppIcon(Icons.chevron_right, size: 17, color: tokens.disabled),
              ],
            ),
          ),
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
    context.read<AuthProvider>().signOut();
    Navigator.of(
      context,
    ).pushAndRemoveUntil(pageRoute(const RoleScreen()), (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: OutlinedButton.icon(
        onPressed: () => _confirmAndLogout(context),
        style: OutlinedButton.styleFrom(
          foregroundColor: tokens.danger,
          side: BorderSide.none,
          shape: const StadiumBorder(),
        ),
        icon: AppIcon(Icons.logout, size: 17, color: tokens.danger.withValues(alpha: .6)),
        label: Text(
          t(tk: 'Ulgamdan çyk', ru: 'Выйти из аккаунта', en: 'Sign out'),
          style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: tokens.danger.withValues(alpha: .6)),
        ),
      ),
    );
  }
}
