import 'json_helpers.dart';

enum ApiRole { client, master }

/// Subscription state of a master (`subscription_status`).
enum SubscriptionStatus {
  active,
  grace,
  suspended;

  static SubscriptionStatus parse(Object? value) => switch (value) {
    'active' => active,
    'grace' => grace,
    _ => suspended,
  };
}

/// Short master card used in lookup, connections and a client's `/me`.
class MasterBrief {
  const MasterBrief({
    required this.id,
    required this.name,
    required this.nickname,
    this.photoUrl,
    this.address = '',
    this.acceptingBookings = false,
  });

  final int id;
  final String name;
  final String nickname;
  final String? photoUrl;
  final String address;
  final bool acceptingBookings;

  factory MasterBrief.fromJson(Map<String, dynamic> json) => MasterBrief(
    id: parseIntOrNull(json['id']) ?? 0,
    name: json['name'] as String? ?? '',
    nickname: json['nickname'] as String? ?? '',
    photoUrl: json['photo_url'] as String?,
    address: json['address'] as String? ?? '',
    acceptingBookings: json['accepting_bookings'] as bool? ?? false,
  );
}

/// A master's public profile (`/me/profile`, `/masters/{id}`, `/me` → profile).
class MasterProfile {
  const MasterProfile({
    required this.id,
    required this.name,
    required this.nickname,
    this.address = '',
    this.description = '',
    this.photoUrl,
    this.bannerUrl,
    this.instagramUrl,
    this.tiktokUrl,
    this.otherLinks = const [],
    this.acceptingBookings = false,
  });

  final int id;
  final String name;
  final String nickname;
  final String address;
  final String description;
  final String? photoUrl;
  final String? bannerUrl;
  final String? instagramUrl;
  final String? tiktokUrl;
  final List<String> otherLinks;
  final bool acceptingBookings;

  factory MasterProfile.fromJson(Map<String, dynamic> json) => MasterProfile(
    id: parseIntOrNull(json['id']) ?? 0,
    name: json['name'] as String? ?? '',
    nickname: json['nickname'] as String? ?? '',
    address: json['address'] as String? ?? '',
    description: json['description'] as String? ?? '',
    photoUrl: json['photo_url'] as String?,
    bannerUrl: json['banner_url'] as String?,
    instagramUrl: json['instagram_url'] as String?,
    tiktokUrl: json['tiktok_url'] as String?,
    otherLinks: [for (final l in (json['other_links'] as List? ?? const [])) '$l'],
    acceptingBookings: json['accepting_bookings'] as bool? ?? false,
  );
}

/// The signed-in account, `GET /me`.
class Me {
  const Me({
    required this.id,
    required this.role,
    required this.name,
    required this.nickname,
    required this.phone,
    required this.locale,
    required this.theme,
    this.photoUrl,
    this.notificationPrefs = const {},
    this.subscriptionStatus,
    this.acceptingBookings = false,
    this.profile,
    this.activeMaster,
    this.nextAppointmentRaw,
  });

  final int id;
  final ApiRole role;
  final String name;
  final String nickname;
  final String phone;
  final String locale;
  final String theme;
  final String? photoUrl;
  final Map<String, bool> notificationPrefs;

  // master only
  final SubscriptionStatus? subscriptionStatus;
  final bool acceptingBookings;
  final MasterProfile? profile;

  // client only
  final MasterBrief? activeMaster;
  final Map<String, dynamic>? nextAppointmentRaw;

  bool get isMaster => role == ApiRole.master;

  factory Me.fromJson(Map<String, dynamic> json) {
    final profile = json['profile'];
    final active = json['active_master'];
    final next = json['next_appointment'];
    final prefs = asMap(json['notification_prefs']);
    return Me(
      id: parseIntOrNull(json['id']) ?? 0,
      role: json['role'] == 'master' ? ApiRole.master : ApiRole.client,
      name: json['name'] as String? ?? '',
      nickname: json['nickname'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      locale: json['locale'] as String? ?? 'tk',
      theme: json['theme'] as String? ?? 'ivory',
      photoUrl: json['photo_url'] as String?,
      notificationPrefs: {
        for (final e in prefs.entries) e.key: e.value == true,
      },
      subscriptionStatus: json['subscription_status'] == null
          ? null
          : SubscriptionStatus.parse(json['subscription_status']),
      acceptingBookings: json['accepting_bookings'] as bool? ?? false,
      profile: profile is Map<String, dynamic> ? MasterProfile.fromJson(profile) : null,
      activeMaster: active is Map<String, dynamic> ? MasterBrief.fromJson(active) : null,
      nextAppointmentRaw: next is Map<String, dynamic> ? next : null,
    );
  }
}
