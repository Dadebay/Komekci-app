import 'package:flutter_test/flutter_test.dart';
import 'package:komekci/data/models/api/billing_models.dart';
import 'package:komekci/data/models/api/client_models.dart';
import 'package:komekci/data/models/api/json_helpers.dart';
import 'package:komekci/data/models/api/master_models.dart';
import 'package:komekci/data/models/api/user_models.dart';

void main() {
  group('time handling', () {
    test('ISO with +05:00 keeps the Ashgabat wall clock', () {
      expect(parseApiTime('2026-10-01T10:00:00+05:00'), DateTime(2026, 10, 1, 10));
    });
    test('UTC input is shifted to UTC+5', () {
      expect(parseApiTime('2026-10-01T05:00:00Z'), DateTime(2026, 10, 1, 10));
    });
    test('offset-less strings are already wall time', () {
      expect(parseApiTime('2026-10-01 10:00:00'), DateTime(2026, 10, 1, 10));
    });
    test('outgoing format', () {
      expect(formatApiDateTime(DateTime(2026, 10, 2, 9, 5)), '2026-10-02 09:05:00');
      expect(formatApiDate(DateTime(2026, 1, 3)), '2026-01-03');
    });
  });

  test('Me (master) parses subscription + profile', () {
    final me = Me.fromJson({
      'id': 12,
      'role': 'master',
      'name': 'Ayna',
      'nickname': 'ayna_style',
      'phone': '+99361234567',
      'locale': 'tk',
      'theme': 'ivory',
      'photo_url': null,
      'notification_prefs': {'N-01': true, 'N-02': false},
      'subscription_status': 'suspended',
      'accepting_bookings': false,
      'profile': {'id': 12, 'name': 'Ayna', 'nickname': 'ayna_style', 'address': 'Ashgabat', 'description': 'Barber', 'banner_url': null, 'instagram_url': null, 'tiktok_url': null, 'other_links': []},
    });
    expect(me.isMaster, isTrue);
    expect(me.subscriptionStatus, SubscriptionStatus.suspended);
    expect(me.notificationPrefs['N-01'], isTrue);
    expect(me.profile!.address, 'Ashgabat');
  });

  test('Me (client) parses active master', () {
    final me = Me.fromJson({
      'id': 3,
      'role': 'client',
      'name': 'Ali',
      'nickname': 'ali_user',
      'phone': '+99361111111',
      'locale': 'ru',
      'theme': 'onyx',
      'active_master': {'id': 12, 'name': 'Ayna', 'nickname': 'ayna_style', 'photo_url': null, 'address': 'Ashgabat', 'accepting_bookings': true},
      'next_appointment': null,
    });
    expect(me.role, ApiRole.client);
    expect(me.activeMaster!.acceptingBookings, isTrue);
    expect(me.nextAppointmentRaw, isNull);
  });

  test('service + schedule', () {
    final s = ApiService.fromJson({'id': 3, 'name': 'Haircut', 'description': null, 'price': '50.00', 'duration_min': 30, 'is_hidden': false, 'sort_order': 1, 'photo_url': 'https://x/p.jpg', 'photo': {'256': 'https://x/p.jpg'}});
    expect(s.price, 50);
    expect(s.description, '');
    final schedule = Schedule.fromJson({
      'grid_step_min': 15,
      'min_lead_min': 30,
      'days': [
        {'weekday': 0, 'is_working': true, 'start_time': '09:00', 'end_time': '18:00', 'break_start': '13:00', 'break_end': '14:00'},
        {'weekday': 1, 'is_working': false, 'start_time': null, 'end_time': null, 'break_start': null, 'break_end': null},
      ],
      'overrides': [
        {'id': 1, 'date': '2026-10-15', 'type': 'day_off', 'start_time': null, 'end_time': null},
      ],
      'vacations': [
        {'id': 2, 'start_date': '2026-11-01', 'end_date': '2026-11-07'},
      ],
    });
    expect(schedule.days.first.breakStart, '13:00');
    expect(schedule.days.first.toJson()['weekday'], 0);
    expect(schedule.days[1].toJson()['start_time'], isNull);
    expect(schedule.overrides.single.type, OverrideType.dayOff);
    expect(schedule.vacations.single.end, DateTime(2026, 11, 7));
  });

  test('master appointment incl. offline client', () {
    final a = MasterAppointment.fromJson({
      'id': 41,
      'starts_at': '2026-10-01T10:00:00+05:00',
      'ends_at': '2026-10-01T10:30:00+05:00',
      'status': 'no_show',
      'note': null,
      'source': 'manual',
      'late_minutes': null,
      'no_show_suggested': false,
      'service': {'id': 3, 'name': 'Haircut', 'price': '50.00', 'duration_min': 30},
      'client': {'id': 'o4', 'name': 'Ali', 'nickname': null, 'phone': '+99361111111', 'photo_url': null, 'offline': true},
    });
    expect(a.status, ApiAppointmentStatus.noShow);
    expect(a.client.offline, isTrue);
    expect(a.endsAt.difference(a.startsAt).inMinutes, 30);
    expect(ApiAppointmentStatus.noShow.wire, 'no_show');
  });

  test('client list + card', () {
    final page = ApiPage.fromJson({
      'data': [
        {'id': 'c12', 'offline': false, 'name': 'Ali', 'nickname': 'ali_user', 'phone': '+99361111111', 'photo_url': null, 'appointment': {'id': 41, 'starts_at': '2026-10-02T10:00:00+05:00', 'service_name': 'Haircut', 'status': 'expected'}, 'last_visit': null, 'visits': 3, 'no_shows': 1, 'spend': '150.00', 'status': 'regular'},
      ],
      'next_cursor': 'abc',
    }, ClientSummary.fromJson);
    expect(page.hasMore, isTrue);
    expect(page.items.single.spend, 150);
    expect(page.items.single.appointment!.serviceName, 'Haircut');
    final card = ClientCard.fromJson({
      'client': {'id': 'c12', 'name': 'Ali'},
      'private_note': null,
      'history': [
        {'id': 1, 'starts_at': '2026-09-01T10:00:00+05:00', 'ends_at': '2026-09-01T10:30:00+05:00', 'status': 'completed', 'service_name': 'Haircut', 'price': '50.00', 'duration_min': 30, 'note': null, 'late_minutes': 5},
      ],
    });
    expect(card.history.single.lateMinutes, 5);
  });

  test('connection request', () {
    final r = ConnectionRequest.fromJson({'id': 8, 'requested_at': '2026-10-01T12:00:00+05:00', 'client': {'name': 'Ali', 'nickname': 'ali_user', 'photo_url': null}});
    expect(r.clientName, 'Ali');
    expect(r.requestedAt, DateTime(2026, 10, 1, 12));
  });

  group('billing', () {
    test('suspended', () {
      final b = Billing.fromJson({'balance': '0.00', 'subscription_price': '20.00', 'subscription_status': 'suspended', 'next_charge_at': null, 'paid_until': null, 'accepting_bookings': false, 'payment_methods': ['mobile', 'card'], 'phone': '+99365000001', 'phone_daily_limit': 7, 'phone_min_amount': '20.00'});
      expect(b.status, SubscriptionStatus.suspended);
      expect(b.phone, '+99365000001');
      expect(b.phoneMinAmount, 20);
    });
    test('ledger', () {
      final p = ApiPage.fromJson({
        'data': [
          {'id': 90, 'type': 'charge', 'amount': '20.00', 'balance_after': '0.00', 'method': 'system', 'status': 'succeeded', 'created_at': '2026-10-01T12:05:00+05:00'},
          {'id': 89, 'type': 'topup', 'amount': '20.00', 'balance_after': '20.00', 'method': 'card', 'status': 'pending', 'created_at': '2026-10-01T12:05:00+05:00'},
        ],
        'next_cursor': null,
      }, LedgerTransaction.fromJson);
      expect(p.hasMore, isFalse);
      expect(p.items[0].type, LedgerType.charge);
      expect(p.items[1].status, LedgerStatus.pending);
    });
    test('mobile topup + phone payments', () {
      final t = MobileTopup.fromJson({'payment_method': 'mobile', 'status': 'pending', 'amount': '20.00', 'phone': '+99365000001', 'phone_used': 2, 'phone_daily_limit': 7, 'phone_min_amount': '20.00', 'balance': '0.00', 'subscription_status': 'suspended'});
      expect(t.phoneUsed, 2);
      final pp = PhonePayments.fromJson({
        'payment_method': 'mobile',
        'balance': '0.00',
        'subscription_status': 'suspended',
        'paid_until': null,
        'payments': [
          {'id': 4, 'amount': '10.00', 'status': 'pending', 'pending_reason': 'amount_too_low', 'receiver': '+99365000001', 'time': '01/10/2026 18:00:00', 'created_at': '2026-10-01T18:00:01+05:00'},
          {'id': 5, 'amount': '20.00', 'status': 'completed', 'pending_reason': null, 'created_at': '2026-10-01T19:00:01+05:00'},
        ],
      });
      expect(pp.payments[0].pendingReason, 'amount_too_low');
      expect(pp.payments[1].status, PhonePaymentStatus.completed);
    });
    test('card topup + result', () {
      final t = CardTopup.fromJson({'payment_method': 'card', 'status': 'unfinished', 'card_transaction_id': 15, 'bank_order_id': 'bank-order-id', 'form_url': 'https://mpi.gov.tm/pay/x', 'amount': '20.00', 'balance': '0.00', 'subscription_status': 'suspended'});
      expect(t.cardTransactionId, 15);
      final r = CardPaymentResult.fromJson({'card_transaction_id': 15, 'status': 'success', 'amount': '20.00', 'bank_error_code': 0, 'bank_order_status': 2, 'balance': '0.00', 'subscription_status': 'active', 'paid_until': '2026-11-01T12:05:00+05:00'});
      expect(r.status, CardPaymentStatus.success);
      expect(r.subscriptionStatus, SubscriptionStatus.active);
      expect(r.paidUntil, DateTime(2026, 11, 1, 12, 5));
      expect(CardPaymentStatus.parse('unknown').isPending, isTrue);
      expect(CardPaymentStatus.parse('failed').isPending, isFalse);
    });
  });

  group('client', () {
    test('connection', () {
      final c = ClientConnection.fromJson({'id': 8, 'status': 'pending', 'active': false, 'master': {'id': 12, 'name': 'Ayna', 'nickname': 'ayna_style', 'photo_url': null, 'address': 'Ashgabat', 'accepting_bookings': false}});
      expect(c.status, ConnectionStatus.pending);
      expect(c.master.id, 12);
    });
    test('availability: day, range, suspended', () {
      final day = Availability.fromJson({'accepting_bookings': true, 'date': '2026-10-02', 'slots': ['10:00', '10:15']});
      expect(day.slots, hasLength(2));
      final range = Availability.fromJson({'accepting_bookings': true, 'dates': {'2026-10-02': ['10:00'], '2026-10-03': []}});
      expect(range.dates['2026-10-02'], ['10:00']);
      final off = Availability.fromJson({'accepting_bookings': false, 'error': 'SUBSCRIPTION_SUSPENDED', 'message': 'x', 'slots': [], 'dates': {}});
      expect(off.acceptingBookings, isFalse);
      expect(off.error, 'SUBSCRIPTION_SUSPENDED');
    });
    test('client appointment', () {
      final a = ClientAppointment.fromJson({'id': 41, 'starts_at': '2026-10-02T10:00:00+05:00', 'ends_at': '2026-10-02T10:30:00+05:00', 'status': 'expected', 'note': 'shorter', 'late_minutes': null, 'waitlist_earlier': true, 'service': {'id': 3, 'name': 'Haircut', 'price': '50.00', 'duration_min': 30}, 'master': {'id': 12, 'name': 'Ayna', 'nickname': 'ayna_style', 'photo_url': null}});
      expect(a.waitlistEarlier, isTrue);
      expect(a.master.name, 'Ayna');
      expect(a.service.price, 50);
    });
    test('notification', () {
      final n = ApiNotification.fromJson({'id': 1, 'event_code': 'N-19', 'title': 't', 'body': 'b', 'payload': {'x': 1}, 'read_at': null, 'sent_at': '2026-10-01T12:00:00+05:00'});
      expect(n.readAt, isNull);
      expect(n.payload['x'], 1);
    });
  });
}
