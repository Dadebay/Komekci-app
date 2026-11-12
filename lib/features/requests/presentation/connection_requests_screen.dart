part of '../../../app/komekci_app.dart';

/// Clients who asked to connect to this master. Accepting adds them to the
/// client book and lets them book online; declining just closes the request.
class RequestsScreen extends StatelessWidget {
  const RequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final language = context.watch<LanguageProvider>().language;
    final tokens = context.appTokens;
    final provider = context.watch<ConnectionRequestsProvider>();
    final requests = provider.requests;
    return Scaffold(
      backgroundColor: tokens.surface,
      appBar: CabinetAppBar(
        title: AppStrings.requestsConnectionRequests.select(language),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: provider.load,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            children: [
              if (provider.error != null && requests.isEmpty)
                RetryErrorState(
                  title: AppStrings.requestsSomethingWentWrong.select(language),
                  text: apiErrorMessage(provider.error!, language),
                  retryLabel: AppStrings.profileTryAgain.select(language),
                  onRetry: provider.load,
                )
              else if (requests.isEmpty)
                provider.loading
                    ? const Padding(
                        padding: EdgeInsets.only(top: 40),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    : _ConnectionRequestsEmptyState(
                        title: AppStrings.requestsNoRequests.select(language),
                        text: AppStrings.requestsClientsCanFindYouBy.select(language),
                      )
              else
                for (final r in requests)
                  Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: tokens.surfaceElevated,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: tokens.border),
                    ),
                    child: Row(
                      children: [
                        MasterAvatar(url: r.clientPhotoUrl, radius: 24),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(r.clientName, style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700)),
                              if ((r.clientNickname ?? '').isNotEmpty)
                                Text('@${r.clientNickname}', style: TextStyle(fontSize: 12, color: tokens.textSecondary)),
                              const SizedBox(height: 2),
                              Text(
                                formatDate(r.requestedAt),
                                style: TextStyle(fontSize: 11, color: tokens.textSecondary),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          tooltip: AppStrings.requestsDecline.select(language),
                          icon: AppIcon(Icons.close, color: tokens.danger),
                          onPressed: () => runApi(context, () => provider.decline(r.id)),
                        ),
                        FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: tokens.textPrimary,
                            shape: const StadiumBorder(),
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                          ),
                          onPressed: () async {
                            final ok = await runApi(context, () => provider.accept(r.id));
                            if (ok && context.mounted) context.read<CustomerProvider>().load();
                          },
                          child: Text(AppStrings.notificationsAccept.select(language)),
                        ),
                      ],
                    ),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ConnectionRequestsEmptyState extends StatelessWidget {
  const _ConnectionRequestsEmptyState({required this.title, required this.text});

  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    return Padding(
      padding: const EdgeInsets.only(top: 32),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
        decoration: BoxDecoration(
          color: tokens.surfaceElevated,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: tokens.border),
        ),
        child: Column(
          children: [
            Image.asset(
              'assets/images/empty_connection_requests_3d.png',
              width: 184,
              height: 184,
              fit: BoxFit.contain,
              excludeFromSemantics: true,
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: tokens.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                height: 1.4,
                color: tokens.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Signs out and returns to the start of the app.
Future<void> _confirmSignOut(BuildContext context) async {
  final language = context.read<LanguageProvider>().language;
  final confirmed = await _showConfirmDialog(
    context,
    icon: Icons.logout,
    title: AppStrings.profileSignOut.select(language),
    message: AppStrings.profileYouLlNeedToVerify.select(language),
    confirmLabel: AppStrings.profileSignOut2.select(language),
    cancelLabel: AppStrings.servicesCancel.select(language),
    danger: true,
  );
  if (!confirmed || !context.mounted) return;
  final navigator = Navigator.of(context);
  await context.read<AuthProvider>().signOut();
  navigator.pushAndRemoveUntil(pageRoute(const RoleScreen()), (route) => false);
}

/// Permanently deletes the account (`DELETE /me`) after a second confirmation.
Future<void> _confirmDeleteAccount(BuildContext context) async {
  final language = context.read<LanguageProvider>().language;
  final confirmed = await _showConfirmDialog(
    context,
    icon: Icons.delete_forever_outlined,
    title: AppStrings.requestsDeleteYourAccount.select(language),
    message: AppStrings.requestsYourAccountAndItsData.select(language),
    confirmLabel: AppStrings.servicesDelete.select(language),
    cancelLabel: AppStrings.servicesCancel.select(language),
    danger: true,
  );
  if (!confirmed || !context.mounted) return;
  final navigator = Navigator.of(context);
  final auth = context.read<AuthProvider>();
  final ok = await runApi(context, auth.deleteAccount);
  if (ok) {
    navigator.pushAndRemoveUntil(pageRoute(const RoleScreen()), (route) => false);
  }
}
