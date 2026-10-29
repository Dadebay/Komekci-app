import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/session/session_scoped.dart';
import '../../../data/models/api/client_models.dart';
import '../../../data/models/api/master_models.dart';
import '../../../data/models/api/user_models.dart';
import '../../../data/repositories/client_repository.dart';
import 'appointment_reminder_scheduler.dart';
import 'client_calendar_service.dart';
part 'client_bookings_store.dart';

enum ClientBookingStatus { expected, completed, cancelled, noShow }

/// One of the client's own upcoming or past bookings, made with any master —
/// distinct from `Appointment`/`BookingProvider`, which model a single
/// master's day calendar of many different clients. A client's booking list
/// is inherently cross-master, so it needs its own shape and its own store.
class ClientBooking {
  const ClientBooking({
    required this.id,
    required this.masterId,
    required this.masterName,
    required this.serviceId,
    required this.serviceName,
    required this.startsAt,
    required this.minutes,
    required this.price,
    this.status = ClientBookingStatus.expected,
    this.note = '',
    this.lateMinutes,
    this.masterPhotoUrl,
    this.waitlistEarlier = false,
  });

  final String id;
  final int masterId;
  final String masterName;
  final String? masterPhotoUrl;
  final int serviceId;
  final String serviceName;
  final DateTime startsAt;
  final int minutes;
  final double price;
  final ClientBookingStatus status;
  final String note;
  final bool waitlistEarlier;

  /// 5 or 10 once the client has signalled they're running late; null
  /// otherwise. Sending again overwrites the previous value.
  final int? lateMinutes;

  DateTime get endsAt => startsAt.add(Duration(minutes: minutes));

  CalendarBookingDetails get calendarDetails {
    // Calculate in Ashgabat wall time, independent of the phone's DST rules.
    final endWall = DateTime.utc(
      startsAt.year,
      startsAt.month,
      startsAt.day,
      startsAt.hour,
      startsAt.minute,
    ).add(Duration(minutes: minutes));
    return CalendarBookingDetails(
      id: id,
      masterName: masterName,
      serviceName: serviceName,
      startsAt: startsAt,
      endsAt: endWall,
    );
  }

  factory ClientBooking.fromApi(ClientAppointment a) => ClientBooking(
    id: '${a.id}',
    masterId: a.master.id,
    masterName: a.master.name,
    masterPhotoUrl: a.master.photoUrl,
    serviceId: a.service.id,
    serviceName: a.service.name,
    startsAt: a.startsAt,
    minutes: a.service.durationMin > 0
        ? a.service.durationMin
        : a.endsAt.difference(a.startsAt).inMinutes,
    price: a.service.price,
    status: switch (a.status) {
      ApiAppointmentStatus.expected => ClientBookingStatus.expected,
      ApiAppointmentStatus.completed => ClientBookingStatus.completed,
      ApiAppointmentStatus.cancelled => ClientBookingStatus.cancelled,
      ApiAppointmentStatus.noShow => ClientBookingStatus.noShow,
    },
    note: a.note ?? '',
    lateMinutes: a.lateMinutes,
    waitlistEarlier: a.waitlistEarlier,
  );

  ClientBooking copyWith({
    ClientBookingStatus? status,
    int? lateMinutes,
    DateTime? startsAt,
  }) => ClientBooking(
    id: id,
    masterId: masterId,
    masterName: masterName,
    masterPhotoUrl: masterPhotoUrl,
    serviceId: serviceId,
    serviceName: serviceName,
    startsAt: startsAt ?? this.startsAt,
    minutes: minutes,
    price: price,
    status: status ?? this.status,
    note: note,
    lateMinutes: lateMinutes ?? this.lateMinutes,
    waitlistEarlier: waitlistEarlier,
  );
}

/// The client's appointments (`/appointments`).
