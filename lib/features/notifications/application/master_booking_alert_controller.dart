import 'package:flutter/foundation.dart';

/// A new client booking delivered by push to the signed-in master.
class MasterBookingAlert {
  const MasterBookingAlert({
    required this.id,
    required this.title,
    required this.body,
  });

  final String id;
  final String title;
  final String body;

  static MasterBookingAlert? fromPush({
    required String id,
    required String title,
    required String body,
    required Map<String, dynamic> data,
  }) {
    final eventCode = '${data['event_code'] ?? data['eventCode'] ?? ''}'
        .trim()
        .toUpperCase();
    if (eventCode.isNotEmpty && eventCode != 'N-04') return null;

    final type = '${data['type'] ?? data['event'] ?? ''}'.trim().toLowerCase();
    final bookingType = const {
      'new_booking',
      'new_appointment',
      'booking_created',
      'appointment_created',
    }.contains(type);
    final bookingTitle = const {
      'täze ýazgy',
      'новая запись',
      'new booking',
      'yeni randevu',
    }.contains(title.trim().toLowerCase());
    if (eventCode.isEmpty && !bookingType && !bookingTitle) return null;
    return MasterBookingAlert(
      id: id,
      title: title.trim().isEmpty ? 'Täze ýazgy' : title,
      body: body,
    );
  }
}

/// Holds an alert until the master shell exists. The visual overlay starts
/// its five-second timer only when it can actually be seen.
class MasterBookingAlertController extends ChangeNotifier {
  MasterBookingAlert? _alert;
  String? _lastMessageId;
  bool _homeReady = false;

  MasterBookingAlert? get visibleAlert => _homeReady ? _alert : null;

  void show(MasterBookingAlert alert, {bool force = false}) {
    if (!force && _lastMessageId == alert.id) return;
    _lastMessageId = alert.id;
    _alert = alert;
    notifyListeners();
  }

  void setHomeReady(bool ready) {
    if (_homeReady == ready) return;
    _homeReady = ready;
    if (!ready) {
      _alert = null;
      _lastMessageId = null;
    }
    notifyListeners();
  }

  void dismiss(String id) {
    if (_alert?.id != id) return;
    _alert = null;
    notifyListeners();
  }
}
