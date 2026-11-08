import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:komekci/core/localization/language_provider.dart';
import 'package:komekci/features/notifications/application/master_booking_alert_controller.dart';
import 'package:komekci/features/notifications/presentation/master_booking_alert_overlay.dart';
import 'package:provider/provider.dart';

void main() {
  test('only a new booking push becomes a master booking alert', () {
    MasterBookingAlert? push(Map<String, dynamic> data) =>
        MasterBookingAlert.fromPush(
          id: 'push-1',
          title: 'Täze ýazgy',
          body: 'Suleyman booked 14:30',
          data: data,
        );
    expect(push({'event_code': 'N-04'}), isNotNull);
    expect(push({'event_code': 'N-10'}), isNull);
    expect(push({}), isNotNull);
    expect(
      MasterBookingAlert.fromPush(
        id: 'push-3',
        title: '',
        body: 'Booked',
        data: {'event_code': 'N-04'},
      )?.title,
      'Täze ýazgy',
    );
    expect(
      MasterBookingAlert.fromPush(
        id: 'push-4',
        title: '',
        body: 'Other event',
        data: {},
      ),
      isNull,
    );
    expect(
      MasterBookingAlert.fromPush(
        id: 'push-2',
        title: 'Billing update',
        body: 'Done',
        data: {},
      ),
      isNull,
    );
  });

  testWidgets(
    'queued alert appears on master home and closes after eight seconds',
    (tester) async {
      final controller = MasterBookingAlertController();
      addTearDown(controller.dispose);
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: controller),
            ChangeNotifierProvider(create: (_) => LanguageProvider()),
          ],
          child: MaterialApp(
            builder: (_, child) => MasterBookingAlertOverlay(child: child!),
            home: const Scaffold(body: Center(child: Text('Home'))),
          ),
        ),
      );

      const alert = MasterBookingAlert(
        id: 'push-1',
        title: 'Täze ýazgy',
        body: 'Suleyman booked 14:30',
      );
      controller.show(alert);
      await tester.pump();
      expect(find.text('Täze ýazgy'), findsNothing);

      controller.setHomeReady(true);
      await tester.pump();
      expect(find.text('Täze ýazgy'), findsOneWidget);
      await tester.pump(const Duration(seconds: 7));
      expect(find.text('Täze ýazgy'), findsOneWidget);
      await tester.pump(const Duration(seconds: 1));
      await tester.pump();
      expect(find.text('Täze ýazgy'), findsNothing);

      controller.show(alert);
      await tester.pump();
      expect(find.text('Täze ýazgy'), findsNothing);

      controller.show(alert, force: true);
      await tester.pump();
      expect(find.text('Täze ýazgy'), findsOneWidget);
    },
  );

  testWidgets('long booking text fits on a compact phone', (tester) async {
    tester.view.physicalSize = const Size(320, 480);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    final controller = MasterBookingAlertController();
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: controller),
          ChangeNotifierProvider(create: (_) => LanguageProvider()),
        ],
        child: MaterialApp(
          builder: (_, child) => MasterBookingAlertOverlay(child: child!),
          home: const Scaffold(body: SizedBox.expand()),
        ),
      ),
    );
    controller.setHomeReady(true);
    controller.show(
      MasterBookingAlert(
        id: 'long-booking',
        title: 'Täze ýazgy',
        body: List.filled(
          18,
          'Suleyman 27.10.2026 sagat 14:30 üçin saç daramak hyzmatyna ýazyldy.',
        ).join(' '),
      ),
    );
    await tester.pump();
    expect(tester.takeException(), isNull);
    expect(find.byType(SingleChildScrollView), findsOneWidget);
  });
}
