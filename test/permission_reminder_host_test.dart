import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:komekci/core/localization/language_provider.dart';
import 'package:komekci/features/permissions/application/required_permissions.dart';
import 'package:komekci/features/permissions/presentation/permission_reminder_host.dart';
import 'package:provider/provider.dart';

class _FakePermissions implements RequiredPermissions {
  MissingAppPermissions current = const MissingAppPermissions(
    notifications: true,
    calendar: true,
  );
  int checks = 0;
  int requests = 0;
  int settingsOpens = 0;
  bool? lastNeedsCalendar;

  @override
  Future<MissingAppPermissions> missing({required bool needsCalendar}) async {
    checks++;
    lastNeedsCalendar = needsCalendar;
    return MissingAppPermissions(
      notifications: current.notifications,
      calendar: needsCalendar && current.calendar,
    );
  }

  @override
  Future<void> request(MissingAppPermissions permissions) async {
    requests++;
    current = const MissingAppPermissions(
      notifications: false,
      calendar: false,
    );
  }

  @override
  Future<void> openSettings() async {
    settingsOpens++;
  }
}

Future<void> _showHome(
  WidgetTester tester,
  _FakePermissions permissions, {
  required bool needsCalendar,
}) => tester.pumpWidget(
  ChangeNotifierProvider(
    create: (_) => LanguageProvider(),
    child: MaterialApp(
      home: PermissionReminderHost(
        needsCalendar: needsCalendar,
        permissions: permissions,
        child: const Scaffold(body: Text('Home')),
      ),
    ),
  ),
);

void main() {
  testWidgets(
    'client gets one reminder after 30 seconds, then stops when granted',
    (tester) async {
      final permissions = _FakePermissions();
      await _showHome(tester, permissions, needsCalendar: true);

      await tester.pump(const Duration(seconds: 29));
      expect(find.text('Rugsatlar gerek'), findsNothing);
      await tester.pump(const Duration(seconds: 1));
      await tester.pump();
      expect(find.text('Rugsatlar gerek'), findsOneWidget);
      expect(permissions.lastNeedsCalendar, true);
      expect(find.textContaining('Senenama rugsat beriň'), findsOneWidget);
      await tester.pump(const Duration(seconds: 60));
      expect(find.text('Rugsatlar gerek'), findsOneWidget);
      expect(permissions.checks, 1);

      await tester.tap(find.text('Rugsat ber'));
      await tester.pumpAndSettle();
      expect(permissions.requests, 1);
      expect(permissions.settingsOpens, 0);

      await tester.pump(const Duration(seconds: 30));
      await tester.pump();
      expect(permissions.checks, 2);
      expect(find.text('Rugsatlar gerek'), findsNothing);
    },
  );

  testWidgets('master is asked only for notifications and can open settings', (
    tester,
  ) async {
    final permissions = _FakePermissions();
    await _showHome(tester, permissions, needsCalendar: false);

    await tester.pump(const Duration(seconds: 30));
    await tester.pump();
    expect(permissions.lastNeedsCalendar, false);
    expect(find.textContaining('Senenama rugsat beriň'), findsNothing);

    await tester.tap(find.text('Soňra'));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 30));
    await tester.pump();
    expect(find.text('Rugsatlar gerek'), findsOneWidget);

    await tester.tap(find.text('Sazlamalar'));
    await tester.pumpAndSettle();
    expect(permissions.settingsOpens, 1);
  });

  testWidgets('reminder reaches a signed-in user on a pushed page', (
    tester,
  ) async {
    final permissions = _FakePermissions();
    await _showHome(tester, permissions, needsCalendar: true);
    Navigator.of(tester.element(find.text('Home'))).push(
      MaterialPageRoute<void>(
        builder: (_) => const Scaffold(body: Text('Booking page')),
      ),
    );
    await tester.pumpAndSettle();

    await tester.pump(const Duration(seconds: 30));
    await tester.pump();
    expect(find.text('Rugsatlar gerek'), findsOneWidget);
    expect(find.text('Booking page'), findsOneWidget);
  });

  testWidgets('permission actions stay visible on a compact phone', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 480);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    await _showHome(tester, _FakePermissions(), needsCalendar: true);
    await tester.pump(const Duration(seconds: 30));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Rugsat ber'), findsOneWidget);
    expect(find.text('Sazlamalar'), findsOneWidget);
    expect(find.text('Soňra'), findsOneWidget);
    expect(tester.getRect(find.byType(Dialog)).bottom, lessThanOrEqualTo(480));
  });
}
