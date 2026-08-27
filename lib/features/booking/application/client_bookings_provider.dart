import 'package:flutter/foundation.dart';

enum ClientBookingStatus { expected, completed, cancelled }

/// One of the client's own upcoming or past bookings, made with any master —
/// distinct from [Appointment]/`BookingProvider`, which model a single
/// master's day calendar of many different clients. A client's booking list
/// is inherently cross-master, so it needs its own shape and its own store.
class ClientBooking {
  const ClientBooking({
    required this.id,
    required this.masterName,
    required this.serviceName,
    required this.startsAt,
    required this.minutes,
    required this.price,
    this.status = ClientBookingStatus.expected,
    this.note = '',
    this.lateMinutes,
  });

  final String id;
  final String masterName;
  final String serviceName;
  final DateTime startsAt;
  final int minutes;
  final double price;
  final ClientBookingStatus status;
  final String note;

  /// 5 or 10 once the client has signalled they're running late; null
  /// otherwise. Sending again overwrites the previous value.
  final int? lateMinutes;

  DateTime get endsAt => startsAt.add(Duration(minutes: minutes));

  ClientBooking copyWith({
    ClientBookingStatus? status,
    String? note,
    int? lateMinutes,
    bool clearLate = false,
    DateTime? startsAt,
  }) => ClientBooking(
    id: id,
    masterName: masterName,
    serviceName: serviceName,
    startsAt: startsAt ?? this.startsAt,
    minutes: minutes,
    price: price,
    status: status ?? this.status,
    note: note ?? this.note,
    lateMinutes: clearLate ? null : (lateMinutes ?? this.lateMinutes),
  );
}

class ClientBookingsProvider extends ChangeNotifier {
  ClientBookingsProvider() : _bookings = List.of(_seed);
  List<ClientBooking> _bookings;

  List<ClientBooking> get bookings => List.unmodifiable(_bookings);

  List<ClientBooking> get upcoming =>
      _bookings.where((b) => b.status == ClientBookingStatus.expected).toList()
        ..sort((a, b) => a.startsAt.compareTo(b.startsAt));

  List<ClientBooking> get history =>
      _bookings.where((b) => b.status != ClientBookingStatus.expected).toList()
        ..sort((a, b) => b.startsAt.compareTo(a.startsAt));

  void add(ClientBooking booking) {
    _bookings = [..._bookings, booking];
    notifyListeners();
  }

  void cancel(String id) =>
      _replace(id, (b) => b.copyWith(status: ClientBookingStatus.cancelled));

  void reschedule(String id, DateTime startsAt) =>
      _replace(id, (b) => b.copyWith(startsAt: startsAt));

  void setLate(String id, int minutes) =>
      _replace(id, (b) => b.copyWith(lateMinutes: minutes));

  void _replace(String id, ClientBooking Function(ClientBooking) transform) {
    _bookings = _bookings.map((b) => b.id == id ? transform(b) : b).toList();
    notifyListeners();
  }

  static final _seed = [
    ClientBooking(
      id: 'cb1',
      masterName: 'Anna',
      serviceName: 'Saç kesmek',
      startsAt: DateTime(2026, 8, 15, 14, 30),
      minutes: 45,
      price: 60,
    ),
    ClientBooking(
      id: 'cb2',
      masterName: 'Aýgül',
      serviceName: 'Manikýur',
      startsAt: DateTime(2026, 8, 16, 11, 0),
      minutes: 40,
      price: 40,
    ),
    ClientBooking(
      id: 'cb3',
      masterName: 'Jemal',
      serviceName: 'Massaž',
      startsAt: DateTime(2026, 8, 18, 16, 0),
      minutes: 60,
      price: 120,
    ),
    ClientBooking(
      id: 'cb4',
      masterName: 'Selbi',
      serviceName: 'Kirpik lamination',
      startsAt: DateTime(2026, 8, 20, 10, 30),
      minutes: 75,
      price: 150,
    ),
    ClientBooking(
      id: 'cb5',
      masterName: 'Oguljahan',
      serviceName: 'Pedikýur',
      startsAt: DateTime(2026, 8, 9, 13, 0),
      minutes: 50,
      price: 55,
      status: ClientBookingStatus.completed,
    ),
    ClientBooking(
      id: 'cb6',
      masterName: 'Anna',
      serviceName: 'Saç boýamak',
      startsAt: DateTime(2026, 8, 5, 15, 0),
      minutes: 120,
      price: 220,
      status: ClientBookingStatus.completed,
    ),
    ClientBooking(
      id: 'cb7',
      masterName: 'Maral',
      serviceName: 'Kaş dizaýn',
      startsAt: DateTime(2026, 7, 29, 12, 30),
      minutes: 30,
      price: 35,
      status: ClientBookingStatus.completed,
    ),
    ClientBooking(
      id: 'cb8',
      masterName: 'Aýgül',
      serviceName: 'Gel lak',
      startsAt: DateTime(2026, 8, 7, 17, 0),
      minutes: 45,
      price: 50,
      status: ClientBookingStatus.cancelled,
    ),
    ClientBooking(
      id: 'cb9',
      masterName: 'Jemal',
      serviceName: 'Ýüz masažy',
      startsAt: DateTime(2026, 8, 25, 9, 30),
      minutes: 55,
      price: 90,
    ),
    ClientBooking(
      id: 'cb10',
      masterName: 'Dursun',
      serviceName: 'Saç düzeltmek',
      startsAt: DateTime(2026, 8, 2, 11, 30),
      minutes: 35,
      price: 45,
      status: ClientBookingStatus.cancelled,
    ),
  ];
}
