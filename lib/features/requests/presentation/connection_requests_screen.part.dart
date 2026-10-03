part of '../../../app/komekci_app.dart';

/// Clients who asked to connect to this master. Accepting adds them to the
/// client book and lets them book online; declining just closes the request.
class RequestsScreen extends StatelessWidget {
  const RequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final language = context.watch<LanguageProvider>().language;
    String t({required String tk, required String ru, required String en}) =>
        pickTr(language, tk: tk, ru: ru, en: en);
    final tokens = context.appTokens;
    final provider = context.watch<ConnectionRequestsProvider>();
    final requests = provider.requests;
    return Scaffold(
      backgroundColor: tokens.surface,
      appBar: CabinetAppBar(
        title: t(tk: 'Baglanyşyk haýyşlary', ru: 'Запросы на связь', en: 'Connection requests'),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: provider.load,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            children: [
              if (provider.error != null && requests.isEmpty)
                RetryErrorState(
                  title: t(tk: 'Ýalňyşlyk', ru: 'Ошибка', en: 'Something went wrong'),
                  text: apiErrorMessage(provider.error!, language),
                  retryLabel: t(tk: 'Täzeden synanyş', ru: 'Повторить', en: 'Try again'),
                  onRetry: provider.load,
                )
              else if (requests.isEmpty)
                provider.loading
                    ? const Padding(
                        padding: EdgeInsets.only(top: 40),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    : EmptyState(
                        icon: Icons.person_add_alt_1_outlined,
                        title: t(tk: 'Haýyş ýok', ru: 'Запросов нет', en: 'No requests'),
                        text: t(
                          tk: 'Müşderiler lakamyňyz bilen sizi tapyp baglanyşyk haýyşyny iberip bilerler.',
                          ru: 'Клиенты находят вас по никнейму и отправляют запрос на связь.',
                          en: 'Clients can find you by nickname and send a connection request.',
                        ),
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
                          tooltip: t(tk: 'Ret et', ru: 'Отклонить', en: 'Decline'),
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
                          child: Text(t(tk: 'Kabul et', ru: 'Принять', en: 'Accept')),
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

/// Signs out and returns to the start of the app.
Future<void> _confirmSignOut(BuildContext context) async {
  final language = context.read<LanguageProvider>().language;
  String t({required String tk, required String ru, required String en}) =>
      pickTr(language, tk: tk, ru: ru, en: en);
  final confirmed = await _showConfirmDialog(
    context,
    icon: Icons.logout,
    title: t(tk: 'Ulgamdan çykmaly?', ru: 'Выйти из аккаунта?', en: 'Sign out?'),
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

/// Permanently deletes the account (`DELETE /me`) after a second confirmation.
Future<void> _confirmDeleteAccount(BuildContext context) async {
  final language = context.read<LanguageProvider>().language;
  String t({required String tk, required String ru, required String en}) =>
      pickTr(language, tk: tk, ru: ru, en: en);
  final confirmed = await _showConfirmDialog(
    context,
    icon: Icons.delete_forever_outlined,
    title: t(tk: 'Hasaby pozmaly?', ru: 'Удалить аккаунт?', en: 'Delete your account?'),
    message: t(
      tk: 'Hasabyňyz we ähli maglumatlaryňyz pozular. Bu hereketi yzyna gaýtaryp bolmaýar.',
      ru: 'Аккаунт и все данные будут удалены. Это действие нельзя отменить.',
      en: 'Your account and its data will be deleted. This cannot be undone.',
    ),
    confirmLabel: t(tk: 'Poz', ru: 'Удалить', en: 'Delete'),
    cancelLabel: t(tk: 'Ýatyr', ru: 'Отмена', en: 'Cancel'),
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
