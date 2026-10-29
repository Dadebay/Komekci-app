part of 'komekci_app.dart';

class KomekciApp extends StatelessWidget {
  const KomekciApp({super.key});
  @override
  Widget build(BuildContext context) => MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ChangeNotifierProvider(create: (_) => LanguageProvider()),
      ChangeNotifierProvider(create: (_) => AppSettingsProvider()),
      ChangeNotifierProvider(create: (_) => MasterOfflineCache()),
      ChangeNotifierProvider(create: (_) => MasterBookingAlertController()),
      Provider<ApiClient>(
        create: (context) => ApiClient(
          languageCode: () => context.read<LanguageProvider>().language.name,
          offlineCache: context.read<MasterOfflineCache>(),
        ),
        dispose: (_, client) => client.close(),
      ),
      Provider<AuthRepository>(create: (context) => AuthRepository(context.read<ApiClient>())),
      Provider<MeRepository>(create: (context) => MeRepository(context.read<ApiClient>())),
      Provider<MasterRepository>(create: (context) => MasterRepository(context.read<ApiClient>())),
      Provider<BillingRepository>(create: (context) => BillingRepository(context.read<ApiClient>())),
      Provider<ClientRepository>(create: (context) => ClientRepository(context.read<ApiClient>())),
      Provider<DeviceRegistrar>(create: (context) => DeviceRegistrar(context.read<MeRepository>())),
      ChangeNotifierProvider(
        create: (context) => AuthProvider(api: context.read<ApiClient>(), auth: context.read<AuthRepository>(), meRepository: context.read<MeRepository>(), devices: context.read<DeviceRegistrar>()),
      ),
      ChangeNotifierProxyProvider<AuthProvider, BillingProvider>(create: (context) => BillingProvider(context.read<BillingRepository>()), update: (_, auth, billing) => billing!..onSession(auth.me)),
      ChangeNotifierProxyProvider<AuthProvider, CustomerProvider>(
        create: (context) => CustomerProvider(context.read<MasterRepository>()),
        update: (_, auth, customers) => customers!..onSession(auth.me),
      ),
      ChangeNotifierProxyProvider<AuthProvider, ConnectionRequestsProvider>(
        create: (context) => ConnectionRequestsProvider(context.read<MasterRepository>()),
        update: (_, auth, requests) => requests!..onSession(auth.me),
      ),
      ChangeNotifierProxyProvider<AuthProvider, ScheduleProvider>(
        create: (context) => ScheduleProvider(context.read<MasterRepository>()),
        update: (_, auth, schedule) => schedule!..onSession(auth.me),
      ),
      ChangeNotifierProxyProvider<AuthProvider, ServiceProvider>(create: (context) => ServiceProvider(context.read<MasterRepository>()), update: (_, auth, services) => services!..onSession(auth.me)),
      ChangeNotifierProxyProvider<AuthProvider, ClientBookingsProvider>(
        create: (context) => ClientBookingsProvider(context.read<ClientRepository>()),
        update: (_, auth, bookings) => bookings!
          ..onSession(auth.me)
          ..configureReminders(auth.me),
      ),
      ChangeNotifierProxyProvider<AuthProvider, NotificationProvider>(
        create: (context) => NotificationProvider(context.read<MeRepository>()),
        update: (_, auth, notifications) => notifications!..onSession(auth.me),
      ),
      ChangeNotifierProxyProvider<AuthProvider, MasterProfileProvider>(
        create: (context) => MasterProfileProvider(me: context.read<MeRepository>(), master: context.read<MasterRepository>(), onMeChanged: context.read<AuthProvider>().applyMe),
        update: (_, auth, profile) => profile!..sync(auth.me),
      ),
      ChangeNotifierProxyProvider<AuthProvider, ClientProfileProvider>(
        create: (context) => ClientProfileProvider(me: context.read<MeRepository>(), onMeChanged: context.read<AuthProvider>().applyMe),
        update: (_, auth, profile) => profile!..sync(auth.me),
      ),
      ChangeNotifierProxyProvider<AuthProvider, ClientMastersProvider>(
        create: (context) => ClientMastersProvider(context.read<ClientRepository>()),
        update: (_, auth, masters) => masters!..onSession(auth.me),
      ),
      ChangeNotifierProxyProvider<AuthProvider, BookingProvider>(create: (context) => BookingProvider(context.read<MasterRepository>()), update: (_, auth, booking) => booking!..onSession(auth.me)),
    ],
    child: const _KomekciView(),
  );
}

final _navigatorKey = GlobalKey<NavigatorState>();

class _KomekciView extends StatefulWidget {
  const _KomekciView();
  @override
  State<_KomekciView> createState() => _KomekciViewState();
}

class _KomekciViewState extends State<_KomekciView> {
  @override
  void initState() {
    super.initState();
    // The refresh token was rejected: the session is gone, so leave whatever
    // signed-in screen is open and ask for the phone number again.
    context.read<AuthProvider>().onSessionLost = () {
      _navigatorKey.currentState?.pushAndRemoveUntil(pageRoute(const LoginScreen()), (_) => false);
    };
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
    navigatorKey: _navigatorKey,
    debugShowCheckedModeBanner: false,
    theme: buildThemeData(context.watch<AppSettingsProvider>().themeTokensFor(context.watch<ThemeProvider>().selected)),
    builder: (context, child) {
      return MasterBookingAlertOverlay(
        child: GlobalSafeAreaWrapper(child: child ?? const SizedBox.shrink()),
      );
    },
    home: const SplashScreen(),
  );
}
