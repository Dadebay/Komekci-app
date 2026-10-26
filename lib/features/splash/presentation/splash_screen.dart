part of '../../../app/komekci_app.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _entrance = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1500),
  )..forward();
  late final AnimationController _ambient = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2200),
  )..repeat();
  bool _isOnline = true;
  String _status = 'Baglanyşyk barlanýar...';
  Timer? _minimumTimer;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final settings = context.read<AppSettingsProvider>();
    final language = context.read<LanguageProvider>();
    final theme = context.read<ThemeProvider>();
    final auth = context.read<AuthProvider>();
    final requestedLocale = language.language;
    final result = await Future.wait<Object?>([
      Connectivity().checkConnectivity(),
      _minimumDuration(),
      settings.load(locale: language.language),
      auth.restoreSession(),
    ]);
    final restore = result[3] as SessionRestore;
    // The backend decides which languages exist; don't leave the app on one
    // it has switched off.
    if (settings.locales.isNotEmpty && !settings.locales.contains(language.language)) {
      language.select(settings.locales.first);
    }
    if (settings.themes.isNotEmpty) {
      final preferred = enabledThemeForStyle(
        settings.themes,
        themeStyleFor(theme.selected),
      );
      if (preferred != null && preferred != theme.selected) {
        theme.select(preferred);
      } else if (!settings.themes.contains(theme.selected)) {
        theme.select(settings.themes.first);
      }
    }
    final networks = result.first as List<ConnectivityResult>;
    _isOnline = networks.any((value) => value != ConnectivityResult.none);
    if (_isOnline) await _initializeFirebase();
    final me = restore == SessionRestore.signedIn ? auth.me : null;
    if (me != null) {
      // Signed in already: take the account's saved language and theme.
      for (final candidate in settings.locales) {
        if (candidate.name == me.locale) language.select(candidate);
      }
      for (final candidate in KomekciTheme.values) {
        if (candidate.name == me.theme) {
          final enabled = enabledThemeForStyle(
            settings.themes,
            themeStyleFor(candidate),
          );
          if (enabled != null) theme.select(enabled);
          break;
        }
      }
      if ((settings.locales.isNotEmpty && me.locale != language.language.name) ||
          (settings.themes.isNotEmpty && me.theme != theme.selected.name)) {
        await auth.savePreferences(
          locale: settings.locales.isEmpty ? null : language.language.name,
          theme: settings.themes.isEmpty ? null : theme.selected.name,
        );
      }
    }
    if (requestedLocale != language.language) {
      await settings.load(locale: language.language);
    }
    if (mounted) {
      setState(
        () => _status = _isOnline ? 'Taýýar' : 'Internet ýok - offline režim',
      );
    }
    await Future<void>.delayed(const Duration(milliseconds: 450));
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      pageRoute(me == null ? const LanguageScreen() : homeForAccount(me)),
    );
  }

  Future<void> _initializeFirebase() async {
    final devices = context.read<DeviceRegistrar>();
    final notifications = context.read<NotificationProvider>();
    final auth = context.read<AuthProvider>();
    final bookings = context.read<ClientBookingsProvider>();
    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      }
      await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(true);
      await FirebaseMessagingService(
        onToken: (token) async {
          devices.onToken(token);
        },
        onMessage: (message) {
          final notification = message.notification;
          if (notification == null || !auth.isSignedIn) return;
          notifications.add(
            title: notification.title ?? 'KÖMEKÇI',
            body: notification.body ?? '',
            data: message.data,
          );
          if (!auth.isMaster) unawaited(bookings.load());
        },
      ).initialize();
      await AnalyticsService(FirebaseAnalytics.instance).screen('splash');
    } catch (error) {
      debugPrint('Firebase bootstrap failed: $error');
    }
  }

  Future<void> _minimumDuration() {
    final completer = Completer<void>();
    _minimumTimer = Timer(
      const Duration(milliseconds: 2500),
      completer.complete,
    );
    return completer.future;
  }

  @override
  void dispose() {
    _minimumTimer?.cancel();
    _entrance.dispose();
    _ambient.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // This screen is the fixed brand moment (see app spec 1.1 "Splash":
    // "Ivory arka plan, serif KÖMEKÇI logotype") — it intentionally always
    // renders in Ivory colours (ink/gold/line + the warm gradient below),
    // never the active AppThemeTokens theme, so it is deliberately left
    // un-tokenized rather than migrated to context.appTokens.
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -.2),
            radius: 1.05,
            colors: [Color(0xffF8E9CD), Color(0xffFBFAF7)],
          ),
        ),
        child: AnimatedBuilder(
          animation: Listenable.merge([_entrance, _ambient]),
          builder: (_, _) {
            final pulse = .86 + (_ambient.value * .14);
            return SafeArea(
              child: Column(
                children: [
                  const Spacer(flex: 3),
                  Opacity(
                    opacity: Curves.easeOut.transform(
                      (_entrance.value * 2).clamp(0, 1),
                    ),
                    child: Transform.scale(
                      scale: .72 + (_entrance.value * .28),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 180 * pulse,
                            height: 180 * pulse,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: gold.withValues(alpha: .11),
                            ),
                          ),
                          Container(
                            width: 106,
                            height: 106,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: ink,
                              boxShadow: [
                                BoxShadow(
                                  color: gold.withValues(alpha: .35),
                                  blurRadius: 28,
                                  spreadRadius: 4,
                                ),
                              ],
                            ),
                            child: const Center(
                              child: SizedBox.square(
                                dimension: 72,
                                child: CustomPaint(
                                  painter: _SplashSparklesPainter(),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Opacity(
                    opacity: ((_entrance.value - .25) * 1.35).clamp(0, 1),
                    child: const Text(
                      'KÖMEKÇI',
                      style: TextStyle(
                        fontSize: 40,
                        letterSpacing: 5,
                        fontWeight: FontWeight.w500,
                        color: ink,
                      ),
                    ),
                  ),
                  const SizedBox(height: 11),
                  Opacity(
                    opacity: ((_entrance.value - .45) * 1.8).clamp(0, 1),
                    child: const Text(
                      'SERVICE APPOINTMENTS',
                      style: TextStyle(
                        fontSize: 10,
                        letterSpacing: 1.8,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                  const Spacer(flex: 3),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 46),
                    child: Column(
                      children: [
                        SizedBox(
                          height: 3,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: Stack(
                              children: [
                                Container(color: line),
                                Align(
                                  alignment: Alignment(
                                    -1 + 2 * _ambient.value,
                                    0,
                                  ),
                                  child: Container(
                                    width: 50,
                                    decoration: const BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.transparent,
                                          gold,
                                          Colors.transparent,
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 15),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            AppIcon(
                              _isOnline
                                  ? Icons.wifi_rounded
                                  : Icons.wifi_off_rounded,
                              color: Colors.black45,
                              size: 15,
                            ),
                            const SizedBox(width: 7),
                            Text(
                              _status,
                              style: const TextStyle(
                                color: Colors.black54,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 38),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Two filled sparkles stay distinct and legible inside the small splash mark.
class _SplashSparklesPainter extends CustomPainter {
  const _SplashSparklesPainter();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 64, size.height / 64);
    final paint = Paint()
      ..color = const Color(0xffF6E4BC)
      ..isAntiAlias = true;
    canvas.drawPath(_sparkle(const Offset(42, 23), 18), paint);
    canvas.drawPath(_sparkle(const Offset(18, 47), 9), paint);
    canvas.restore();
  }

  Path _sparkle(Offset center, double radius) {
    final x = center.dx;
    final y = center.dy;
    final inset = radius * .26;
    return Path()
      ..moveTo(x, y - radius)
      ..quadraticBezierTo(x + inset, y - inset, x + radius, y)
      ..quadraticBezierTo(x + inset, y + inset, x, y + radius)
      ..quadraticBezierTo(x - inset, y + inset, x - radius, y)
      ..quadraticBezierTo(x - inset, y - inset, x, y - radius)
      ..close();
  }

  @override
  bool shouldRepaint(covariant _SplashSparklesPainter oldDelegate) => false;
}
