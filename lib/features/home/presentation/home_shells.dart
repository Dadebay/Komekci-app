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
        ModalRoute.of(context)?.isCurrent == true) {
      _check(silent: true);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// [silent] is the re-check when the app comes back to the foreground: the
  /// screen stays as it is (no spinner, so the master is not thrown back to
  /// the first tab), and nothing changes unless the server's answer says the
  /// master may no longer enter, or may enter again.
  Future<void> _check({bool silent = false}) async {
    // With nothing on screen yet (first check or the error page) there is
    // nothing to keep: show the normal spinner.
    silent = silent && _billing != null;
    if (!silent && !_checking) {
      setState(() {
        _checking = true;
        _billing = null;
        _error = null;
      });
    }
    try {
      final billing = await context.read<BillingRepository>().billing();
      if (!mounted) return;
      if (silent && _billing != null) {
        if (billing.permitsMasterEntry == _billing!.permitsMasterEntry) return;
      }
      setState(() {
        _billing = billing;
        _error = null;
        _checking = false;
      });
    } catch (error) {
      if (!mounted || silent) return;
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
      title: AppStrings.homeSwitchAccounts.select(language),
      message: AppStrings.homeSignOutOfTheMaster.select(language),
      confirmLabel: AppStrings.profileSignOut2.select(language),
      cancelLabel: AppStrings.servicesCancel.select(language),
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
          : MasterSubscriptionScreen(onboarding: false, onLeave: _leavePayment);
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
                    title: AppStrings.homeCouldNotCheckPayment.select(language),
                    text: apiErrorMessage(_error!, language),
                    retryLabel: AppStrings.profileTryAgain.select(language),
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
          AppStrings.homeHome.select(language),
          AppStrings.profileMyMasters.select(language),
          AppStrings.homeBookings2.select(language),
          AppStrings.profileProfile.select(language),
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
  late final ConnectionRequestsProvider _requestsProvider;
  // Request ids already known; only ones that appear later pop the dialog.
  final Set<int> _knownRequestIds = {};
  bool _requestsBaselined = false;
  bool _requestDialogOpen = false;

  @override
  void initState() {
    super.initState();
    _bookingAlerts = context.read<MasterBookingAlertController>();
    _requestsProvider = context.read<ConnectionRequestsProvider>()
      ..addListener(_onRequestsChanged);
    _onRequestsChanged();
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

  /// The first successful load only records what is already pending; any
  /// request that shows up after that opens a dialog over the master's screen.
  void _onRequestsChanged() {
    if (!mounted || !_requestsProvider.loaded) return;
    final requests = _requestsProvider.requests;
    if (!_requestsBaselined) {
      _requestsBaselined = true;
      _knownRequestIds.addAll(requests.map((r) => r.id));
      return;
    }
    final fresh = [
      for (final r in requests)
        if (!_knownRequestIds.contains(r.id)) r,
    ];
    if (fresh.isEmpty) return;
    // Wait while a dialog is up or another screen is on top; the next
    // refresh (every 30 s) tries again.
    if (_requestDialogOpen || ModalRoute.of(context)?.isCurrent != true) return;
    _knownRequestIds.addAll(fresh.map((r) => r.id));
    _requestDialogOpen = true;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) {
        _requestDialogOpen = false;
        return;
      }
      await showNewConnectionRequestDialog(context, fresh);
      _requestDialogOpen = false;
    });
  }

  void _refreshConnectionRequests() {
    if (!mounted ||
        WidgetsBinding.instance.lifecycleState != AppLifecycleState.resumed) {
      return;
    }
    context.read<ConnectionRequestsProvider>().load(silent: true);
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
    _requestsProvider.removeListener(_onRequestsChanged);
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
                        AppStrings.homeShowingSavedDataInternetIs.select(
                          language,
                        ),
                        style: TextStyle(
                          fontSize: 11.5,
                          color: tokens.textPrimary,
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: AppStrings.homeRefresh.select(language),
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
          AppStrings.homeHome.select(language),
          AppStrings.homeCustomers.select(language),
          AppStrings.homeCalendar.select(language),
          AppStrings.homeAddCustomer.select(language),
          AppStrings.homeCabinet.select(language),
        ],
      ),
    );
    return PermissionReminderHost(needsCalendar: false, child: home);
  }
}
