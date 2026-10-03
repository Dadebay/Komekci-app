import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:komekci/core/network/api_client.dart';
import 'package:komekci/core/network/api_exception.dart';
import 'package:komekci/core/network/token_store.dart';
import 'package:komekci/core/services/device_registrar.dart';
import 'package:komekci/data/models/api/billing_models.dart';
import 'package:komekci/data/models/api/user_models.dart';
import 'package:komekci/data/models/appointment.dart';
import 'package:komekci/data/repositories/auth_repository.dart';
import 'package:komekci/data/repositories/billing_repository.dart';
import 'package:komekci/data/repositories/client_repository.dart';
import 'package:komekci/data/repositories/master_repository.dart';
import 'package:komekci/data/repositories/me_repository.dart';
import 'package:komekci/features/auth/application/auth_provider.dart';
import 'package:komekci/features/billing/application/billing_provider.dart';
import 'package:komekci/features/booking/application/booking_provider.dart';
import 'package:komekci/features/booking/application/client_bookings_provider.dart';
import 'package:komekci/features/services/application/service_provider.dart';

typedef Handler = http.Response Function(http.Request request);

http.Response json(Object body, [int status = 200]) =>
    http.Response(jsonEncode(body), status, headers: {'content-type': 'application/json'});

/// An [ApiClient] whose "server" is a table of `METHOD /path` → response.
Future<ApiClient> fakeApi(Map<String, Handler> routes, {List<String>? log}) async {
  final api = ApiClient(
    tokenStore: MemoryTokenStore(),
    client: MockClient((request) async {
      final key = '${request.method} ${request.url.path.replaceFirst('/api', '')}';
      log?.add(key);
      final handler = routes[key];
      if (handler == null) return json({'error': 'NOT_FOUND', 'message': 'no route $key'}, 404);
      return handler(request);
    }),
  );
  await api.saveSession(const AuthTokens(access: 'A', refresh: 'R'));
  return api;
}

Map<String, dynamic> masterAppointment(int id, String start, String end, {String status = 'expected'}) => {
  'id': id,
  'starts_at': start,
  'ends_at': end,
  'status': status,
  'note': null,
  'source': 'manual',
  'late_minutes': null,
  'no_show_suggested': false,
  'service': {'id': 3, 'name': 'Haircut', 'price': '50.00', 'duration_min': 30},
  'client': {'id': 'o4', 'name': 'Ali', 'nickname': null, 'phone': '+99361111111', 'photo_url': null, 'offline': true},
};

Map<String, dynamic> clientAppointment(int id, String start, {String status = 'expected'}) => {
  'id': id,
  'starts_at': start,
  'ends_at': start,
  'status': status,
  'note': null,
  'late_minutes': null,
  'waitlist_earlier': false,
  'service': {'id': 3, 'name': 'Haircut', 'price': '50.00', 'duration_min': 30},
  'master': {'id': 12, 'name': 'Ayna', 'nickname': 'ayna_style', 'photo_url': null},
};

void main() {
  group('BookingProvider (master calendar)', () {
    test('loads a month, books, changes status', () async {
      final log = <String>[];
      final api = await fakeApi({
        'GET /me/calendar': (r) {
          expect(r.url.queryParameters['from'], '2026-10-01');
          expect(r.url.queryParameters['to'], '2026-10-31');
          return json({
            'data': [masterAppointment(1, '2026-10-05T10:00:00+05:00', '2026-10-05T10:30:00+05:00')],
          });
        },
        'POST /me/appointments': (r) {
          final body = jsonDecode(r.body) as Map<String, dynamic>;
          expect(body['service_id'], 3);
          expect(body['starts_at'], '2026-10-06 11:00:00');
          return json({'data': masterAppointment(2, '2026-10-06T11:00:00+05:00', '2026-10-06T11:30:00+05:00')}, 201);
        },
        'PATCH /me/appointments/2/status': (r) {
          expect(jsonDecode(r.body), {'status': 'no_show'});
          return json({'status': 'ok'});
        },
      }, log: log);
      final provider = BookingProvider(MasterRepository(api));

      await provider.ensureLoaded(DateTime(2026, 10, 15));
      await provider.ensureLoaded(DateTime(2026, 10, 20)); // cached: no 2nd call
      expect(log.where((l) => l == 'GET /me/calendar'), hasLength(1));
      expect(provider.onDay(DateTime(2026, 10, 5)), hasLength(1));

      final created = await provider.create(
        serviceId: 3,
        clientName: 'Ali',
        phone: '+99361111111',
        startsAt: DateTime(2026, 10, 6, 11),
      );
      expect(created.id, '2');
      expect(provider.hasConflict(DateTime(2026, 10, 6, 11, 15), 30), isTrue);

      await provider.markNoShow('2');
      expect(provider.onDay(DateTime(2026, 10, 6)).single.status, AppointmentStatus.noShow);
      // A no-show frees the slot again.
      expect(provider.hasConflict(DateTime(2026, 10, 6, 11, 15), 30), isFalse);
    });

    test('arrived is local only', () async {
      final api = await fakeApi({
        'GET /me/calendar': (_) => json({
          'data': [masterAppointment(1, '2026-10-05T10:00:00+05:00', '2026-10-05T10:30:00+05:00')],
        }),
      });
      final provider = BookingProvider(MasterRepository(api));
      await provider.ensureLoaded(DateTime(2026, 10, 5));
      provider.arrive('1');
      expect(provider.onDay(DateTime(2026, 10, 5)).single.status, AppointmentStatus.arrived);
    });

    test('SLOT_TAKEN surfaces suggested slots', () async {
      final api = await fakeApi({
        'POST /me/appointments': (_) => json({
          'error': 'SLOT_TAKEN',
          'message': 'busy',
          'details': {'suggested_slots': ['10:15', '10:30']},
        }, 409),
      });
      final provider = BookingProvider(MasterRepository(api));
      await expectLater(
        provider.create(serviceId: 3, clientName: 'Ali', startsAt: DateTime(2026, 10, 6, 10)),
        throwsA(isA<ApiException>().having((e) => e.suggestedSlots, 'slots', ['10:15', '10:30'])),
      );
    });
  });

  group('BillingProvider', () {
    Map<String, dynamic> billing(String balance, String status) => {
      'balance': balance,
      'subscription_price': '20.00',
      'subscription_status': status,
      'next_charge_at': null,
      'paid_until': null,
      'accepting_bookings': status != 'suspended',
      'payment_methods': ['mobile', 'card'],
      'phone': '+99365000001',
      'phone_daily_limit': 7,
      'phone_min_amount': '20.00',
    };

    test('loads billing + ledger and refreshes after a successful card payment', () async {
      var paid = false;
      final api = await fakeApi({
        'GET /me/billing': (_) => json(billing(paid ? '0.00' : '0.00', paid ? 'active' : 'suspended')),
        'GET /me/billing/transactions': (_) => json({'data': [], 'next_cursor': null}),
        'POST /me/billing/topup': (r) {
          expect(jsonDecode(r.body), {'amount': 20, 'method': 'card'});
          return json({
            'payment_method': 'card',
            'status': 'unfinished',
            'card_transaction_id': 15,
            'bank_order_id': 'o-1',
            'form_url': 'https://mpi.gov.tm/pay/x',
            'amount': '20.00',
            'balance': '0.00',
            'subscription_status': 'suspended',
          });
        },
        'GET /me/billing/cards/15': (_) {
          paid = true;
          return json({
            'card_transaction_id': 15,
            'status': 'success',
            'amount': '20.00',
            'bank_error_code': 0,
            'bank_order_status': 2,
            'balance': '0.00',
            'subscription_status': 'active',
            'paid_until': '2026-11-01T12:05:00+05:00',
          });
        },
      });
      final provider = BillingProvider(BillingRepository(api));
      await provider.load();
      expect(provider.status, SubscriptionStatus.suspended);
      expect(provider.acceptingBookings, isFalse);

      final topup = await provider.startCardPayment(20);
      expect(topup.formUrl, startsWith('https://mpi.gov.tm'));
      final result = await provider.checkCardPayment(cardTransactionId: topup.cardTransactionId);
      expect(result.status, CardPaymentStatus.success);
      // The app never edits status itself: it re-read /me/billing.
      expect(provider.status, SubscriptionStatus.active);
      expect(provider.acceptingBookings, isTrue);
    });

    test('a pending card result leaves the subscription alone', () async {
      var billingCalls = 0;
      final api = await fakeApi({
        'GET /me/billing': (_) {
          billingCalls++;
          return json(billing('0.00', 'suspended'));
        },
        'GET /me/billing/transactions': (_) => json({'data': [], 'next_cursor': null}),
        'GET /me/billing/cards/15': (_) => json({
          'card_transaction_id': 15,
          'status': 'unfinished',
          'amount': '20.00',
          'balance': '0.00',
          'subscription_status': 'suspended',
        }),
      });
      final provider = BillingProvider(BillingRepository(api));
      await provider.load();
      final before = billingCalls;
      final result = await provider.checkCardPayment(cardTransactionId: 15);
      expect(result.status.isPending, isTrue);
      expect(billingCalls, before);
    });

    test('formatMoney', () {
      expect(formatMoney(20), '20');
      expect(formatMoney(20.5), '20.50');
    });
  });

  group('ServiceProvider', () {
    Map<String, dynamic> service({required bool hidden}) => {
      'id': 3,
      'name': 'Haircut',
      'description': null,
      'price': '50.00',
      'duration_min': 30,
      'is_hidden': hidden,
      'sort_order': 0,
      'photo_url': 'https://x/p.jpg',
    };

    test('toggle is optimistic and rolls back on failure', () async {
      var fail = true;
      final api = await fakeApi({
        'GET /me/services': (_) => json({'data': [service(hidden: false)]}),
        'PATCH /me/services/3': (r) {
          expect(jsonDecode(r.body), {'is_hidden': true});
          return fail
              ? json({'error': 'ERROR', 'message': 'boom'}, 500)
              : json({'data': service(hidden: true)});
        },
      });
      final provider = ServiceProvider(MasterRepository(api));
      await provider.load();
      expect(provider.services.single.active, isTrue);

      await expectLater(provider.toggleActive('3'), throwsA(isA<ApiException>()));
      expect(provider.services.single.active, isTrue);

      fail = false;
      await provider.toggleActive('3');
      expect(provider.services.single.active, isFalse);
    });
  });

  group('ClientBookingsProvider', () {
    test('books with an idempotency key, then cancels', () async {
      String? key;
      final api = await fakeApi({
        'GET /appointments': (r) => json({
          'data': r.url.queryParameters['scope'] == 'history' ? [] : [],
          'next_cursor': null,
        }),
        'POST /appointments': (r) {
          key = r.headers['Idempotency-Key'];
          final body = jsonDecode(r.body) as Map<String, dynamic>;
          expect(body['waitlist_earlier'], true);
          return json({'data': clientAppointment(41, '2026-10-02T10:00:00+05:00')}, 201);
        },
        'POST /appointments/41/cancel': (_) => json({'status': 'ok'}),
      });
      final provider = ClientBookingsProvider(ClientRepository(api));
      await provider.load();
      final booking = await provider.book(
        serviceId: 3,
        startsAt: DateTime(2026, 10, 2, 10),
        waitlistEarlier: true,
        idempotencyKey: 'k-1',
      );
      expect(key, 'k-1');
      expect(booking.masterName, 'Ayna');
      expect(provider.upcoming, hasLength(1));

      await provider.cancel('41');
      expect(provider.upcoming, isEmpty);
      expect(provider.history.single.status, ClientBookingStatus.cancelled);
    });
  });

  group('AuthProvider', () {
    Future<AuthProvider> auth(Map<String, Handler> routes, {MemoryTokenStore? store}) async {
      final api = ApiClient(
        tokenStore: store ?? MemoryTokenStore(),
        client: MockClient((request) async {
          final key = '${request.method} ${request.url.path.replaceFirst('/api', '')}';
          final handler = routes[key];
          return handler == null ? json({'error': 'NOT_FOUND', 'message': key}, 404) : handler(request);
        }),
      );
      final me = MeRepository(api);
      return AuthProvider(
        api: api,
        auth: AuthRepository(api),
        meRepository: me,
        devices: DeviceRegistrar(me),
      );
    }

    final masterMe = {
      'id': 12,
      'role': 'master',
      'name': 'Ayna',
      'nickname': 'ayna_style',
      'phone': '+99361234567',
      'locale': 'tk',
      'theme': 'ivory',
      'subscription_status': 'suspended',
      'accepting_bookings': false,
      'profile': {'id': 12, 'name': 'Ayna', 'nickname': 'ayna_style', 'address': 'A', 'description': 'B'},
    };

    test('OTP sign-in stores tokens, loads /me and switches role', () async {
      final store = MemoryTokenStore();
      final provider = await auth({
        'POST /auth/otp/request': (_) => json({'status': 'otp_sent'}),
        'POST /auth/otp/verify': (r) {
          expect(jsonDecode(r.body), {'phone': '+99361234567', 'code': '123456'});
          return json({'access_token': 'A', 'refresh_token': 'R', 'token_type': 'Bearer', 'expires_in': 900});
        },
        'GET /me': (r) {
          expect(r.headers['Authorization'], 'Bearer A');
          return json({'data': masterMe});
        },
      }, store: store);
      await provider.requestOtp('+99361234567');
      expect(provider.step, AuthStep.otpSent);
      final me = await provider.verifyOtp('+99361234567', '123456');
      expect(me.isMaster, isTrue);
      expect(provider.step, AuthStep.signedIn);
      expect(provider.isMaster, isTrue);
      expect((await store.read())!.refresh, 'R');
    });

    test('restoreSession: none, signed in, and rejected token', () async {
      final empty = await auth({});
      expect(await empty.restoreSession(), SessionRestore.none);

      final store = MemoryTokenStore();
      await store.write(const AuthTokens(access: 'A', refresh: 'R'));
      final ok = await auth({'GET /me': (_) => json({'data': masterMe})}, store: store);
      expect(await ok.restoreSession(), SessionRestore.signedIn);
      expect(ok.me!.nickname, 'ayna_style');

      final deadStore = MemoryTokenStore();
      await deadStore.write(const AuthTokens(access: 'A', refresh: 'R'));
      final dead = await auth({
        'GET /me': (_) => json({'error': 'UNAUTHENTICATED', 'message': 'x'}, 401),
        'POST /auth/refresh': (_) => json({'error': 'UNAUTHENTICATED', 'message': 'x'}, 401),
      }, store: deadStore);
      var lost = 0;
      dead.onSessionLost = () => lost++;
      expect(await dead.restoreSession(), SessionRestore.none);
      expect(lost, 1);
      expect(await deadStore.read(), isNull);
    });

    test('signOut clears the session even when the server is down', () async {
      final store = MemoryTokenStore();
      await store.write(const AuthTokens(access: 'A', refresh: 'R'));
      final provider = await auth({
        'GET /me': (_) => json({'data': masterMe}),
        'POST /auth/logout': (_) => json({'error': 'ERROR', 'message': 'down'}, 500),
      }, store: store);
      await provider.restoreSession();
      await provider.signOut();
      expect(provider.step, AuthStep.signedOut);
      expect(provider.me, isNull);
      expect(await store.read(), isNull);
    });
  });
}
