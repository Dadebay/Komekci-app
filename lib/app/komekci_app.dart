import 'dart:async';
import 'dart:io';
import 'dart:math';

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
import 'package:webview_flutter/webview_flutter.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_theme_tokens.dart';
import '../core/theme/theme_provider.dart';
import '../core/localization/language_provider.dart';
import '../core/network/api_client.dart';
import '../core/network/api_config.dart';
import '../core/network/api_exception.dart';
import '../core/services/device_registrar.dart';
import '../core/services/sms_code_listener.dart';
import '../core/services/analytics_service.dart';
import '../core/services/firebase_messaging_service.dart';
import '../data/models/api/billing_models.dart';
import '../data/models/api/client_models.dart';
import '../data/models/api/json_helpers.dart';
import '../data/models/api/master_models.dart';
import '../data/models/api/user_models.dart';
import '../data/repositories/auth_repository.dart';
import '../data/repositories/billing_repository.dart';
import '../data/repositories/client_repository.dart';
import '../data/repositories/master_repository.dart';
import '../data/repositories/me_repository.dart';
import '../features/app/application/app_settings_provider.dart';
import '../features/auth/application/auth_provider.dart';
import '../features/billing/application/billing_provider.dart';
import '../features/booking/application/booking_provider.dart';
import '../features/booking/application/client_bookings_provider.dart';
import '../features/booking/application/client_masters_provider.dart';
import '../features/cabinet/application/master_profile_provider.dart';
import '../features/customers/application/customer_provider.dart';
import '../features/notifications/application/notification_provider.dart';
import '../features/profile/application/client_profile_provider.dart';
import '../features/requests/application/connection_requests_provider.dart';
import '../features/schedule/application/schedule_provider.dart';
import '../features/services/application/service_provider.dart';
import '../data/models/salon_service.dart';
import '../data/models/customer.dart';
import '../data/models/appointment.dart';
import '../data/models/app_notification.dart';
import '../firebase_options.dart';
import '../shared/widgets/app_icon.dart';
import '../shared/widgets/glass_nav_bar.dart';
import '../shared/widgets/photo_picker.dart';
import '../shared/widgets/state_views.dart';
import '../shared/utils/api_errors.dart';
import '../shared/utils/date_format.dart';
import '../shared/utils/navigation.dart';
import '../shared/utils/weekday_labels.dart';
import '../shared/utils/salon_colors.dart';
import '../shared/utils/app_today.dart';
import '../shared/widgets/primary_button.dart';
import '../shared/widgets/form_widgets.dart';
import '../shared/widgets/cabinet_app_bar.dart';

part '../features/splash/presentation/splash_screen.part.dart';
part '../features/onboarding/presentation/onboarding_screen.part.dart';
part '../features/onboarding/presentation/role_onboarding_screen.part.dart';
part '../features/home/presentation/home_shells.part.dart';
part '../features/home/presentation/home_dashboard_screen.part.dart';
part '../features/home/presentation/home_dashboard_widgets.part.dart';
part '../features/home/presentation/day_timeline_screen.part.dart';
part '../features/home/presentation/client_home_dashboard.part.dart';
part '../features/home/presentation/client_booking_widgets.part.dart';
part '../features/home/presentation/client_master_widgets.part.dart';
part '../features/home/presentation/client_bookings_screen.part.dart';
part '../features/home/presentation/master_profile_screen.part.dart';
part '../features/notifications/presentation/notification_screens.part.dart';
part '../features/profile/presentation/client_profile_screen.part.dart';
part '../features/profile/presentation/client_profile_widgets.part.dart';
part '../features/profile/presentation/client_profile_edit_screen.part.dart';
part '../features/profile/presentation/change_phone_dialog.part.dart';
part '../features/profile/presentation/client_notification_settings_screen.part.dart';
part '../features/profile/presentation/client_support_screen.part.dart';
part '../features/appointments/presentation/appointment_detail_screen.part.dart';
part '../features/appointments/presentation/reschedule_screen.part.dart';
part '../features/appointments/presentation/my_masters_screen.part.dart';
part '../features/appointments/presentation/settings_screen.part.dart';
part '../features/booking/presentation/booking_shared.part.dart';
part '../features/booking/presentation/booking_service_screen.part.dart';
part '../features/booking/presentation/booking_datetime_screen.part.dart';
part '../features/booking/presentation/booking_confirm_screen.part.dart';
part '../features/booking/presentation/booking_success_screen.part.dart';
part '../features/auth/presentation/language_screen.part.dart';
part '../features/auth/presentation/client_registration_screen.part.dart';
part '../features/auth/presentation/otp_code_field.part.dart';
part '../features/auth/presentation/otp_screen.part.dart';
part '../features/auth/presentation/connect_master_flow.part.dart';
part '../features/auth/presentation/login_screen.part.dart';
part '../features/auth/presentation/master_setup_shared.part.dart';
part '../features/auth/presentation/master_phone_screen.part.dart';
part '../features/auth/presentation/master_otp_screen.part.dart';
part '../features/auth/presentation/master_registration_screen.part.dart';
part '../features/auth/presentation/master_subscription_screen.part.dart';
part '../features/auth/presentation/master_subscription_payment_widgets.part.dart';
part '../features/auth/presentation/master_phone_payment_dialog.part.dart';
part '../features/auth/presentation/master_card_payment_dialog.part.dart';
part '../features/auth/presentation/role_screen.part.dart';
part '../features/auth/presentation/role_screen_widgets.part.dart';
part '../features/cabinet/presentation/cabinet_shared.part.dart';
part '../features/cabinet/presentation/cabinet_home_screen.part.dart';
part '../features/cabinet/presentation/cabinet_widgets.part.dart';
part '../features/cabinet/presentation/cabinet_profile_screen.part.dart';
part '../features/cabinet/presentation/cabinet_working_hours_screen.part.dart';
part '../features/cabinet/presentation/cabinet_vacation_screen.part.dart';
part '../features/cabinet/presentation/cabinet_special_days_screen.part.dart';
part '../features/cabinet/presentation/cabinet_client_notify_screen.part.dart';
part '../features/cabinet/presentation/cabinet_send_message_screen.part.dart';
part '../features/cabinet/presentation/cabinet_selected_clients_screen.part.dart';
part '../features/cabinet/presentation/cabinet_recent_clients_screen.part.dart';
part '../features/cabinet/presentation/cabinet_billing_screen.part.dart';
part '../features/cabinet/presentation/cabinet_support_screen.part.dart';
part '../features/billing/presentation/billing_history_screen.part.dart';
part '../features/requests/presentation/connection_requests_screen.part.dart';
part '../features/services/presentation/services_screen.part.dart';
part '../features/services/presentation/service_form_screen.part.dart';
part '../features/customers/presentation/customer_shared.part.dart';
part '../features/customers/presentation/customers_screen.part.dart';
part '../features/customers/presentation/customer_list_widgets.part.dart';
part '../features/customers/presentation/customer_detail_screen.part.dart';
part '../features/customers/presentation/customer_form_screen.part.dart';
part '../features/customers/presentation/new_appointment_screen.part.dart';
part '../features/schedule/presentation/schedule_shared.part.dart';
part '../features/schedule/presentation/schedule_screen.part.dart';
part '../features/schedule/presentation/schedule_week_overview_screen.part.dart';
part '../features/schedule/presentation/schedule_appointment_row.part.dart';
part '../features/schedule/presentation/schedule_customer_picker_sheet.part.dart';
part '../features/schedule/presentation/schedule_new_slot_sheet.part.dart';

class KomekciApp extends StatelessWidget {
  const KomekciApp({super.key});
  @override
  Widget build(BuildContext context) => MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ChangeNotifierProvider(create: (_) => LanguageProvider()),
      ChangeNotifierProvider(create: (_) => AppSettingsProvider()),
      Provider<ApiClient>(
        create: (context) => ApiClient(
          languageCode: () => context.read<LanguageProvider>().language.name,
        ),
        dispose: (_, client) => client.close(),
      ),
      Provider<AuthRepository>(
        create: (context) => AuthRepository(context.read<ApiClient>()),
      ),
      Provider<MeRepository>(
        create: (context) => MeRepository(context.read<ApiClient>()),
      ),
      Provider<MasterRepository>(
        create: (context) => MasterRepository(context.read<ApiClient>()),
      ),
      Provider<BillingRepository>(
        create: (context) => BillingRepository(context.read<ApiClient>()),
      ),
      Provider<ClientRepository>(
        create: (context) => ClientRepository(context.read<ApiClient>()),
      ),
      Provider<DeviceRegistrar>(
        create: (context) => DeviceRegistrar(context.read<MeRepository>()),
      ),
      ChangeNotifierProvider(
        create: (context) => AuthProvider(
          api: context.read<ApiClient>(),
          auth: context.read<AuthRepository>(),
          meRepository: context.read<MeRepository>(),
          devices: context.read<DeviceRegistrar>(),
        ),
      ),
      ChangeNotifierProxyProvider<AuthProvider, BillingProvider>(
        create: (context) =>
            BillingProvider(context.read<BillingRepository>()),
        update: (_, auth, billing) => billing!..onSession(auth.me),
      ),
      ChangeNotifierProxyProvider<AuthProvider, CustomerProvider>(
        create: (context) =>
            CustomerProvider(context.read<MasterRepository>()),
        update: (_, auth, customers) => customers!..onSession(auth.me),
      ),
      ChangeNotifierProxyProvider<AuthProvider, ConnectionRequestsProvider>(
        create: (context) =>
            ConnectionRequestsProvider(context.read<MasterRepository>()),
        update: (_, auth, requests) => requests!..onSession(auth.me),
      ),
      ChangeNotifierProxyProvider<AuthProvider, ScheduleProvider>(
        create: (context) =>
            ScheduleProvider(context.read<MasterRepository>()),
        update: (_, auth, schedule) => schedule!..onSession(auth.me),
      ),
      ChangeNotifierProxyProvider<AuthProvider, ServiceProvider>(
        create: (context) => ServiceProvider(context.read<MasterRepository>()),
        update: (_, auth, services) => services!..onSession(auth.me),
      ),
      ChangeNotifierProxyProvider<AuthProvider, ClientBookingsProvider>(
        create: (context) =>
            ClientBookingsProvider(context.read<ClientRepository>()),
        update: (_, auth, bookings) => bookings!..onSession(auth.me),
      ),
      ChangeNotifierProxyProvider<AuthProvider, NotificationProvider>(
        create: (context) =>
            NotificationProvider(context.read<MeRepository>()),
        update: (_, auth, notifications) =>
            notifications!..onSession(auth.me),
      ),
      ChangeNotifierProxyProvider<AuthProvider, MasterProfileProvider>(
        create: (context) => MasterProfileProvider(
          me: context.read<MeRepository>(),
          master: context.read<MasterRepository>(),
          onMeChanged: context.read<AuthProvider>().applyMe,
        ),
        update: (_, auth, profile) => profile!..sync(auth.me),
      ),
      ChangeNotifierProxyProvider<AuthProvider, ClientProfileProvider>(
        create: (context) => ClientProfileProvider(
          me: context.read<MeRepository>(),
          onMeChanged: context.read<AuthProvider>().applyMe,
        ),
        update: (_, auth, profile) => profile!..sync(auth.me),
      ),
      ChangeNotifierProxyProvider<AuthProvider, ClientMastersProvider>(
        create: (context) =>
            ClientMastersProvider(context.read<ClientRepository>()),
        update: (_, auth, masters) => masters!..onSession(auth.me),
      ),
      ChangeNotifierProxyProvider<AuthProvider, BookingProvider>(
        create: (context) =>
            BookingProvider(context.read<MasterRepository>()),
        update: (_, auth, booking) => booking!..onSession(auth.me),
      ),
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
      _navigatorKey.currentState?.pushAndRemoveUntil(
        pageRoute(const LoginScreen()),
        (_) => false,
      );
    };
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
    navigatorKey: _navigatorKey,
    debugShowCheckedModeBanner: false,
    theme: buildThemeData(tokensFor(context.watch<ThemeProvider>().selected)),
    builder: (context, child) {
      return GlobalSafeAreaWrapper(child: child ?? const SizedBox.shrink());
    },
    home: const SplashScreen(),
  );
}
