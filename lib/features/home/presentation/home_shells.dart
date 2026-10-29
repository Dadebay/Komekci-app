part of '../../../app/komekci_app.dart';

/// Entry point after sign-in or session restore.
Widget homeForAccount(Me me) =>
    me.isMaster ? const MasterEntryGate() : const ClientHome();

/// Checks fresh server billing before a master can enter the app.
class MasterEntryGate extends StatefulWidget {
  const MasterEntryGate({super.key});

  @override
  State<MasterEntryGate> createState() => _MasterEntryGateState();
}

class _MasterEntryGateState extends State<MasterEntryGate>
    with WidgetsBindingObserver {
  Billing? _billing;
  Object? _error;
  bool _checking = true;
  bool _leaving = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _check();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed &&
        !_checking &&
        _billing != null &&
        !_billing!.permitsMasterEntry &&
        ModalRoute.of(context)?.isCurrent == true) {
      _check();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _check() async {
    if (!_checking) {
      setState(() {
        _checking = true;
        _billing = null;
        _error = null;
      });
    }
    try {
      final billing = await context.read<BillingRepository>().billing();
      if (!mounted) return;
      setState(() {
        _billing = billing;
        _error = null;
        _checking = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error;
        _checking = false;
      });
    }
  }

  Future<void> _leavePayment() async {
    if (_leaving) return;
    final language = context.read<LanguageProvider>().language;
    final confirmed = await _showConfirmDialog(
      context,
      icon: Icons.logout,
      title: pickTr(
        language,
        tk: 'Başga hasaba geçmelimi?',
        ru: 'Войти в другой аккаунт?',
        en: 'Switch accounts?',
      ),
      message: pickTr(
        language,
        tk: 'Master hasabyndan çykyp, müşderi hasabyňyzyň telefon belgisi bilen girip bilersiňiz.',
        ru: 'Выйдите из аккаунта мастера, затем войдите с номером телефона клиентского аккаунта.',
        en: 'Sign out of the master account, then use your client account phone number to sign in.',
      ),
      confirmLabel: pickTr(language, tk: 'Çyk', ru: 'Выйти', en: 'Sign out'),
      cancelLabel: pickTr(language, tk: 'Ýatyr', ru: 'Отмена', en: 'Cancel'),
    );
    if (!confirmed || !mounted || _leaving) return;
    setState(() => _leaving = true);
    final navigator = Navigator.of(context);
    try {
      await context.read<AuthProvider>().signOut();
      if (!mounted) return;
      navigator.pushAndRemoveUntil(pageRoute(const RoleScreen()), (_) => false);
    } catch (error) {
      if (!mounted) return;
      setState(() => _leaving = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(apiErrorMessage(error, language))));
    }
  }

  @override
  Widget build(BuildContext context) {
    final billing = _billing;
    if (billing != null) {
      return billing.permitsMasterEntry
          ? const MasterHome()
          : MasterSubscriptionScreen(
              onLeave: _leavePayment,
              onPromoActivated: _check,
            );
    }
    final tokens = context.appTokens;
    final language = context.watch<LanguageProvider>().language;
    return Scaffold(
      backgroundColor: tokens.surface,
      body: SafeArea(
        child: Center(
          child: _checking
              ? const CircularProgressIndicator()
              : Padding(
                  padding: const EdgeInsets.all(24),
                  child: RetryErrorState(
                    title: pickTr(
                      language,
                      tk: 'Töleg ýagdaýyny barlap bolmady',
                      ru: 'Не удалось проверить оплату',
                      en: 'Could not check payment',
                    ),
                    text: apiErrorMessage(_error!, language),
                    retryLabel: pickTr(
                      language,
                      tk: 'Täzeden synanyş',
                      ru: 'Повторить',
                      en: 'Try again',
                    ),
                    onRetry: _check,
                  ),
                ),
        ),
      ),
    );
  }
}

class ClientHome extends StatefulWidget {
  const ClientHome({super.key, this.initialTab = 0});
  final int initialTab;
  @override
  State<ClientHome> createState() => _ClientHomeState();
}

class _ClientHomeState extends State<ClientHome> {
  late int tab = widget.initialTab;
  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    final language = context.watch<LanguageProvider>().language;
    String t({required String tk, required String ru, required String en}) =>
        pickTr(language, tk: tk, ru: ru, en: en);
    final pages = [
      const ClientHomeDashboard(),
      const ClientMastersScreen(),
      const ClientBookingsScreen(),
      const ClientProfile(),
    ];
    final home = Scaffold(
      extendBody: true,
      backgroundColor: tokens.surface,
      body: SafeArea(bottom: false, child: pages[tab]),
      bottomNavigationBar: GlassNavBar(
        docked: true,
        currentIndex: tab,
        onSelected: (v) => setState(() => tab = v),
        icons: const [
          HugeIcons.strokeRoundedHome03,
          HugeIcons.strokeRoundedUserStar01,
          HugeIcons.strokeRoundedCalendar05,
          HugeIcons.strokeRoundedUserCircle,
        ],
        labels: [
          t(tk: 'Baş sahypa', ru: 'Главная', en: 'Home'),
          t(tk: 'Masterlerim', ru: 'Мои мастера', en: 'My masters'),
          t(tk: 'Ýazgylarym', ru: 'Мои записи', en: 'Bookings'),
          t(tk: 'Profil', ru: 'Профиль', en: 'Profile'),
        ],
      ),
    );
    return PermissionReminderHost(needsCalendar: true, child: home);
  }
}

class MasterHome extends StatefulWidget {
  const MasterHome({super.key});
  @override
  State<MasterHome> createState() => _MasterHomeState();
}

class _MasterHomeState extends State<MasterHome> with WidgetsBindingObserver {
  int tab = 0;
  Timer? _connectionRequestsRefresh;
  StreamSubscription<List<ConnectivityResult>>? _connectivityChanges;
  bool _refreshingSavedData = false;
  late final MasterBookingAlertController _bookingAlerts;

  @override
  void initState() {
    super.initState();
    _bookingAlerts = context.read<MasterBookingAlertController>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _bookingAlerts.setHomeReady(true);
    });
    WidgetsBinding.instance.addObserver(this);
    _connectionRequestsRefresh = Timer.periodic(
      const Duration(seconds: 30),
      (_) => _refreshConnectionRequests(),
    );
    _connectivityChanges = Connectivity().onConnectivityChanged.listen((
      networks,
    ) {
      if (mounted &&
          networks.any((network) => network != ConnectivityResult.none) &&
          context.read<MasterOfflineCache>().usingCachedData) {
        unawaited(_refreshSavedData());
      }
    });
  }

  Future<void> _refreshSavedData() async {
    if (_refreshingSavedData || !mounted) return;
    setState(() => _refreshingSavedData = true);
    try {
      try {
        await context.read<AuthProvider>().refreshMe();
      } catch (_) {
        // Keep the locally restored session while the network is unavailable.
      }
      if (!mounted) return;
      await Future.wait([
        context.read<BookingProvider>().refresh(),
        context.read<CustomerProvider>().load(),
        context.read<ScheduleProvider>().load(),
        context.read<ScheduleProvider>().loadClosedTimes(
          appToday(),
          force: true,
        ),
        context.read<ServiceProvider>().load(),
        context.read<MasterProfileProvider>().refresh(),
      ]);
    } finally {
      if (mounted) setState(() => _refreshingSavedData = false);
    }
  }

  void _refreshConnectionRequests() {
    if (!mounted ||
        WidgetsBinding.instance.lifecycleState != AppLifecycleState.resumed) {
      return;
    }
    context.read<ConnectionRequestsProvider>().load();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshConnectionRequests();
      if (context.read<MasterOfflineCache>().usingCachedData) {
        unawaited(_refreshSavedData());
      }
    }
  }

  @override
  void dispose() {
    _bookingAlerts.setHomeReady(false);
    _connectionRequestsRefresh?.cancel();
    _connectivityChanges?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// Set right before jumping to the Senenama tab from the home dashboard's
  /// day list, so that tab opens on the tapped day instead of "today".
  DateTime? _scheduleInitialDate;

  void _goToSchedule(DateTime day) => setState(() {
    _scheduleInitialDate = day;
    tab = 2;
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    final language = context.watch<LanguageProvider>().language;
    final pendingRequests = context.select<ConnectionRequestsProvider, int>(
      (requests) => requests.count,
    );
    final showingSavedData = context
        .watch<MasterOfflineCache>()
        .usingCachedData;
    String t({required String tk, required String ru, required String en}) =>
        pickTr(language, tk: tk, ru: ru, en: en);
    // Index 3 ("Müşderi goşmak") is a push-style action, not a persistent tab —
    // the form has its own back arrow and pops rather than swapping content.
    final pages = [
      HomeDashboardScreen(onViewSchedule: _goToSchedule),
      const CustomersScreen(),
      ScheduleScreen(initialDate: _scheduleInitialDate),
      const SizedBox.shrink(),
      const CabinetScreen(),
    ];
    final home = Scaffold(
      extendBody: true,
      backgroundColor: tokens.surface,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            if (showingSavedData)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
                color: tokens.warning.withValues(alpha: .12),
                child: Row(
                  children: [
                    AppIcon(
                      Icons.wifi_off_outlined,
                      color: tokens.textPrimary,
                      size: 18,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        t(
                          tk: 'Saklanan maglumatlar görkezilýär. Täzelemek we üýtgetmek üçin internet gerek.',
                          ru: 'Показаны сохранённые данные. Для обновления и изменений нужен интернет.',
                          en: 'Showing saved data. Internet is needed to refresh or make changes.',
                        ),
                        style: TextStyle(
                          fontSize: 11.5,
                          color: tokens.textPrimary,
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: t(tk: 'Täzele', ru: 'Обновить', en: 'Refresh'),
                      onPressed: _refreshingSavedData
                          ? null
                          : _refreshSavedData,
                      icon: _refreshingSavedData
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : AppIcon(
                              Icons.refresh,
                              color: tokens.textPrimary,
                              size: 19,
                            ),
                    ),
                  ],
                ),
              ),
            Expanded(child: pages[tab]),
          ],
        ),
      ),
      bottomNavigationBar: GlassNavBar(
        docked: true,
        currentIndex: tab,
        badgeCounts: {4: pendingRequests},
        onSelected: (v) {
          if (v == 3) {
            Navigator.push(context, pageRoute(const CustomerFormScreen()));
            return;
          }
          if (v == 2) _scheduleInitialDate = null;
          setState(() => tab = v);
        },
        icons: const [
          HugeIcons.strokeRoundedHome03,
          HugeIcons.strokeRoundedUserGroup,
          HugeIcons.strokeRoundedCalendar05,
          HugeIcons.strokeRoundedUserAdd01,
          HugeIcons.strokeRoundedUserCircle,
        ],
        labels: [
          t(tk: 'Baş sahypa', ru: 'Главная', en: 'Home'),
          t(tk: 'Müşderiler', ru: 'Клиенты', en: 'Customers'),
          t(tk: 'Senenama', ru: 'Календарь', en: 'Calendar'),
          t(tk: 'Müşderi goşmak', ru: 'Добавить клиента', en: 'Add customer'),
          t(tk: 'Kabinet', ru: 'Кабинет', en: 'Cabinet'),
        ],
      ),
    );
    return PermissionReminderHost(needsCalendar: false, child: home);
  }
}
