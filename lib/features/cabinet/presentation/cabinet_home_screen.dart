part of '../../../app/komekci_app.dart';

class CabinetScreen extends StatefulWidget {
  const CabinetScreen({super.key});

  @override
  State<CabinetScreen> createState() => _CabinetScreenState();
}

class _CabinetScreenState extends State<CabinetScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final requests = context.read<ConnectionRequestsProvider>();
      if (!requests.loading) requests.load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final language = context.watch<LanguageProvider>().language;
    final tokens = context.appTokens;
    final pendingRequests = context.watch<ConnectionRequestsProvider>().count;
    final entries = <(IconData, String, Widget)>[
      (
        Icons.person_outline,
        AppStrings.profileProfile.select(language),
        const CabinetProfileScreen(),
      ),
      (
        Icons.content_cut,
        AppStrings.servicesServices.select(language),
        const ServicesScreen(),
      ),
      (
        Icons.schedule_outlined,
        AppStrings.cabinetWorkingHours.select(language),
        const WorkingHoursScreen(),
      ),
      (
        Icons.send_outlined,
        AppStrings.cabinetClientMessages.select(language),
        const ClientNotifyScreen(),
      ),
      (
        Icons.account_balance_wallet_outlined,
        AppStrings.cabinetBillingSubscription.select(language),
        const BillingScreen(),
      ),
      (
        Icons.person_add_alt_1_outlined,
        AppStrings.requestsConnectionRequests.select(language),
        const RequestsScreen(),
      ),
      (
        Icons.inbox_outlined,
        AppStrings.profileNotifications.select(language),
        const ClientNotificationSettingsScreen(),
      ),
    ];
    return Scaffold(
      backgroundColor: tokens.surface,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 110),
          children: [
            Row(
              children: [
                Tooltip(
                  message: AppStrings.profileSettings.select(language),
                  child: _RoundIconButton(
                    icon: Icons.settings_outlined,
                    onTap: () => Navigator.push(
                      context,
                      pageRoute(const CabinetSettingsScreen()),
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    AppStrings.cabinetCabinet.select(language),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 15,
                      letterSpacing: 1.1,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                _RoundIconButton(
                  icon: Icons.notifications_none,
                  onTap: () => Navigator.push(
                    context,
                    pageRoute(const ClientNotificationSettingsScreen()),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            _MasterCard(
              onTap: () => Navigator.push(
                context,
                pageRoute(const CabinetProfileScreen()),
              ),
            ),
            const SizedBox(height: 14),
            const _SubscriptionDaysCard(),
            const SizedBox(height: 8),
            ...List.generate(entries.length, (index) {
              final entry = entries[index];
              return _CabinetRow(
                index: index + 1,
                icon: entry.$1,
                label: entry.$2,
                badgeCount: entry.$3 is RequestsScreen ? pendingRequests : 0,
                onTap: () => Navigator.push(context, pageRoute(entry.$3)),
              );
            }),
            const SizedBox(height: 10),
            _HelpCard(
              onTap: () =>
                  Navigator.push(context, pageRoute(const SupportScreen())),
            ),
            const SizedBox(height: 14),
            _SubscriptionNotice(),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton.icon(
                onPressed: () => _confirmSignOut(context),
                style: OutlinedButton.styleFrom(
                  foregroundColor: tokens.danger,
                  side: BorderSide.none,
                  shape: const StadiumBorder(),
                ),
                icon: const AppIcon(Icons.logout, size: 18),
                label: Text(AppStrings.cabinetSignOut.select(language)),
              ),
            ),
            Center(
              child: TextButton(
                onPressed: () => _confirmDeleteAccount(context),
                child: Text(
                  AppStrings.profileDeleteAccount.select(language),
                  style: TextStyle(color: tokens.textSecondary, fontSize: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Uploads the master's new profile photo, surfacing a failure as a snackbar.
Future<void> _uploadAvatar(BuildContext context, File file) async {
  final toast = AppToast.of(context);
  final language = context.read<LanguageProvider>().language;
  try {
    await context.read<MasterProfileProvider>().setAvatar(file);
  } catch (error) {
    toast.error(apiErrorMessage(error, language));
  }
}
