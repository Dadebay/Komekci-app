import 'dart:async';
import 'dart:io';

import 'package:background_sms/background_sms.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:komekci/global_safe_area_wrapper.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/theme_provider.dart';
import '../core/localization/language_provider.dart';
import '../core/services/analytics_service.dart';
import '../core/services/firebase_messaging_service.dart';
import '../data/repositories/mock_appointment_repository.dart';
import '../data/repositories/mock_category_repository.dart';
import '../features/auth/application/auth_provider.dart';
import '../features/booking/application/booking_provider.dart';
import '../features/customers/application/customer_provider.dart';
import '../features/services/application/service_provider.dart';
import '../data/models/salon_service.dart';
import '../data/models/customer.dart';
import '../data/models/appointment.dart';
import '../firebase_options.dart';
import '../shared/widgets/app_icon.dart';
import '../shared/widgets/glass_nav_bar.dart';
import '../shared/widgets/photo_picker.dart';

part '../features/splash/presentation/splash_screen.part.dart';
part '../features/onboarding/presentation/onboarding_flow.part.dart';
part '../features/home/presentation/home_shells.part.dart';
part '../features/home/presentation/home_content.part.dart';
part '../features/appointments/presentation/appointment_management.part.dart';
part '../features/auth/presentation/language_screen.part.dart';
part '../features/auth/presentation/auth_flow.part.dart';
part '../features/auth/presentation/login_screen.part.dart';
part '../features/auth/presentation/master_setup.part.dart';
part '../features/auth/presentation/role_screen.part.dart';
part '../features/cabinet/presentation/cabinet_screens.part.dart';
part '../features/services/presentation/service_screens.part.dart';
part '../features/customers/presentation/customer_screens.part.dart';
part '../features/schedule/presentation/schedule_screens.part.dart';

class KomekciApp extends StatelessWidget {
  const KomekciApp({super.key});
  @override
  Widget build(BuildContext context) => MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ChangeNotifierProvider(create: (_) => LanguageProvider()),
      ChangeNotifierProvider(create: (_) => AuthProvider()),
      ChangeNotifierProvider(create: (_) => BookingProvider(MockAppointmentRepository())),
      ChangeNotifierProvider(create: (_) => ServiceProvider()),
      ChangeNotifierProvider(create: (_) => CustomerProvider()),
    ],
    child: const _KomekciView(),
  );
}

class _KomekciView extends StatelessWidget {
  const _KomekciView();
  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      useMaterial3: true,
      fontFamily: 'Gilroy',
      scaffoldBackgroundColor: Colors.white,
      colorScheme: const ColorScheme.light(primary: ink, secondary: gold),
      textTheme: const TextTheme(
        displaySmall: TextStyle(fontWeight: FontWeight.w700),
        headlineSmall: TextStyle(fontWeight: FontWeight.w700),
        titleLarge: TextStyle(fontWeight: FontWeight.w600),
        titleMedium: TextStyle(fontWeight: FontWeight.w600),
        titleSmall: TextStyle(fontWeight: FontWeight.w600),
        bodyLarge: TextStyle(fontWeight: FontWeight.w500),
        bodyMedium: TextStyle(fontWeight: FontWeight.w400),
        labelLarge: TextStyle(fontWeight: FontWeight.w600),
      ),
    ),
    themeMode: context.watch<ThemeProvider>().mode,
    darkTheme: ThemeData.dark(useMaterial3: true),
    builder: (context, child) {
      return GlobalSafeAreaWrapper(child: child ?? const SizedBox.shrink());
    },
    home: const SplashScreen(),
  );
}
