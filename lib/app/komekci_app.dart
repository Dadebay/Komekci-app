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

import '../core/theme/app_colors.dart';
import '../core/theme/app_theme_tokens.dart';
import '../core/theme/theme_provider.dart';
import '../core/localization/language_provider.dart';
import '../core/services/analytics_service.dart';
import '../core/services/firebase_messaging_service.dart';
import '../data/repositories/mock_appointment_repository.dart';
import '../data/repositories/mock_category_repository.dart';
import '../features/auth/application/auth_provider.dart';
import '../features/billing/application/billing_provider.dart';
import '../features/booking/application/booking_provider.dart';
import '../features/booking/application/client_bookings_provider.dart';
import '../features/cabinet/application/master_profile_provider.dart';
import '../features/customers/application/customer_provider.dart';
import '../features/notifications/application/notification_provider.dart';
import '../features/profile/application/client_profile_provider.dart';
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
import '../shared/utils/date_format.dart';
import '../shared/utils/navigation.dart';
import '../shared/utils/salon_hours.dart';
import '../shared/utils/salon_colors.dart';
import '../shared/utils/mock_today.dart';
import '../shared/utils/auth_validation.dart';
import '../shared/widgets/primary_button.dart';
import '../shared/widgets/form_widgets.dart';
import '../shared/widgets/cabinet_app_bar.dart';
import '../shared/widgets/info_row.dart';

part '../features/splash/presentation/splash_screen.part.dart';
part '../features/onboarding/presentation/onboarding_screen.part.dart';
part '../features/onboarding/presentation/role_onboarding_screen.part.dart';
part '../features/home/presentation/home_shells.part.dart';
part '../features/home/presentation/home_content.part.dart';
part '../features/home/presentation/home_dashboard_screen.part.dart';
part '../features/home/presentation/home_dashboard_widgets.part.dart';
part '../features/home/presentation/day_timeline_screen.part.dart';
part '../features/home/presentation/client_mock_data.part.dart';
part '../features/home/presentation/client_home_dashboard.part.dart';
part '../features/home/presentation/client_booking_widgets.part.dart';
part '../features/home/presentation/client_master_widgets.part.dart';
part '../features/home/presentation/client_masters_screen.part.dart';
part '../features/home/presentation/client_bookings_screen.part.dart';
part '../features/home/presentation/client_favorites_screen.part.dart';
part '../features/home/presentation/master_profile_screen.part.dart';
part '../features/notifications/presentation/notification_screens.part.dart';
part '../features/profile/presentation/client_profile_screen.part.dart';
part '../features/profile/presentation/client_profile_widgets.part.dart';
part '../features/profile/presentation/client_profile_edit_screen.part.dart';
part '../features/profile/presentation/client_notification_settings_screen.part.dart';
part '../features/profile/presentation/client_support_screen.part.dart';
part '../features/appointments/presentation/appointment_detail_screen.part.dart';
part '../features/appointments/presentation/reschedule_screen.part.dart';
part '../features/appointments/presentation/my_masters_screen.part.dart';
part '../features/appointments/presentation/legacy_client_screens.part.dart';
part '../features/appointments/presentation/settings_screen.part.dart';
part '../features/booking/presentation/booking_shared.part.dart';
part '../features/booking/presentation/booking_service_screen.part.dart';
part '../features/booking/presentation/booking_datetime_screen.part.dart';
part '../features/booking/presentation/booking_confirm_screen.part.dart';
part '../features/booking/presentation/booking_success_screen.part.dart';
part '../features/auth/presentation/language_screen.part.dart';
part '../features/auth/presentation/client_registration_screen.part.dart';
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
part '../features/auth/presentation/master_bank_picker_dialog.part.dart';
part '../features/auth/presentation/role_screen.part.dart';
part '../features/auth/presentation/role_screen_widgets.part.dart';
part '../features/cabinet/presentation/cabinet_shared.part.dart';
part '../features/cabinet/presentation/cabinet_home_screen.part.dart';
part '../features/cabinet/presentation/cabinet_mode_screen.part.dart';
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
      ChangeNotifierProvider(create: (_) => AuthProvider()),
      ChangeNotifierProvider(
        create: (_) => BookingProvider(MockAppointmentRepository()),
      ),
      ChangeNotifierProvider(create: (_) => ServiceProvider()),
      ChangeNotifierProvider(create: (_) => CustomerProvider()),
      ChangeNotifierProvider(create: (_) => NotificationProvider()),
      ChangeNotifierProvider(create: (_) => ClientBookingsProvider()),
      ChangeNotifierProvider(create: (_) => BillingProvider()),
      ChangeNotifierProvider(create: (_) => MasterProfileProvider()),
      ChangeNotifierProvider(create: (_) => ClientProfileProvider()),
    ],
    child: const _KomekciView(),
  );
}

class _KomekciView extends StatelessWidget {
  const _KomekciView();
  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: buildThemeData(tokensFor(context.watch<ThemeProvider>().selected)),
    builder: (context, child) {
      return GlobalSafeAreaWrapper(child: child ?? const SizedBox.shrink());
    },
    home: const SplashScreen(),
  );
}
