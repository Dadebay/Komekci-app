part of '../../../app/komekci_app.dart';

/// Mock master directory for the client experience — no backend yet, so the
/// same fixed list backs the home carousel, the full "Masterlar" tab and the
/// "Halanlarym" favourites filter.
class _ClientMaster {
  const _ClientMaster({
    required this.id,
    required this.nameTk,
    required this.nameRu,
    required this.specialtyTk,
    required this.specialtyRu,
    required this.locationTk,
    required this.locationRu,
    required this.locationId,
    required this.serviceIds,
    required this.gender,
    this.favorite = false,
  });
  final String id;
  final String nameTk;
  final String nameRu;
  final String specialtyTk;
  final String specialtyRu;
  final String locationTk;
  final String locationRu;

  /// Matches one of [_locationFilters]' ids — backs the "Ýerleşýän ýeri" filter.
  final String locationId;

  /// Matches one or more of [_serviceFilters]' ids — backs the "Hyzmat" filter.
  final List<String> serviceIds;

  /// 'male' or 'female' — backs the "Jyns" filter.
  final String gender;
  final bool favorite;
}

const _serviceFilters = [
  ('haircut', 'Saç kesmek', 'Стрижка', 'Haircut'),
  ('manicure', 'Manikýur', 'Маникюр', 'Manicure'),
  ('pedicure', 'Pedikýur', 'Педикюр', 'Pedicure'),
  ('cosmetology', 'Kosmetolog', 'Косметолог', 'Cosmetology'),
  ('massage', 'Massaž', 'Массаж', 'Massage'),
  ('skincare', 'Deri idegi', 'Уход за кожей', 'Skincare'),
  ('makeup', 'Meýkap (makýaž)', 'Макияж', 'Makeup'),
];

const _locationFilters = [
  ('merkez', 'Merkez', 'Центр', 'Merkez'),
  ('mir', 'Mir', 'Мир', 'Mir'),
  ('kopetdag', 'Köpetdag', 'Копетдаг', 'Köpetdag'),
  ('buzmeyin', 'Büzmeýin', 'Бузмеин', 'Büzmeýin'),
  ('ahal', 'Ahal', 'Ахал', 'Ahal'),
  ('gypjak', 'Gypjak', 'Гыпджак', 'Gypjak'),
  ('bagtyyarlyk', 'Bagtyýarlyk', 'Багтыярлык', 'Bagtyýarlyk'),
  ('yasamal', 'Ýasamal', 'Ясамал', 'Ýasamal'),
];

const _timeFilters = [
  ('today', 'Şu gün', 'Сегодня', 'Today'),
  ('tomorrow', 'Ertir', 'Завтра', 'Tomorrow'),
  ('in3days', '3 gün içinde', 'В течение 3 дней', 'Within 3 days'),
  ('thisweek', 'Bu hepde', 'На этой неделе', 'This week'),
];

const _clientMasters = [
  _ClientMaster(
    id: 'm1',
    nameTk: 'Rowşen (Barber)',
    nameRu: 'Ровшен (Барбер)',
    specialtyTk: 'Erkekler üçin saç kesmek',
    specialtyRu: 'Стрижка для мужчин',
    locationTk: 'Aşgabat, Merkez',
    locationRu: 'Ашхабад, Центр',
    locationId: 'merkez',
    serviceIds: ['haircut'],
    gender: 'male',
  ),
  _ClientMaster(
    id: 'm2',
    nameTk: 'Anna',
    nameRu: 'Анна',
    specialtyTk: 'Aýallar üçin saç kesmek',
    specialtyRu: 'Стрижка для женщин',
    locationTk: 'Aşgabat, Mir',
    locationRu: 'Ашхабад, Мир',
    locationId: 'mir',
    serviceIds: ['haircut'],
    gender: 'female',
    favorite: true,
  ),
  _ClientMaster(
    id: 'm3',
    nameTk: 'Aýgül',
    nameRu: 'Айгуль',
    specialtyTk: 'Manikýur, pedikýur',
    specialtyRu: 'Маникюр, педикюр',
    locationTk: 'Aşgabat, Köpetdag',
    locationRu: 'Ашхабад, Копетдаг',
    locationId: 'kopetdag',
    serviceIds: ['manicure', 'pedicure'],
    gender: 'female',
    favorite: true,
  ),
  _ClientMaster(
    id: 'm4',
    nameTk: 'Gülşat',
    nameRu: 'Гульшат',
    specialtyTk: 'Kosmetolog, deri ideg',
    specialtyRu: 'Косметолог, уход за кожей',
    locationTk: 'Aşgabat, Gypjak',
    locationRu: 'Ашхабад, Гыпджак',
    locationId: 'gypjak',
    serviceIds: ['cosmetology', 'skincare'],
    gender: 'female',
  ),
  _ClientMaster(
    id: 'm5',
    nameTk: 'Merdan',
    nameRu: 'Мердан',
    specialtyTk: 'Sakal düzetmek',
    specialtyRu: 'Оформление бороды',
    locationTk: 'Aşgabat, Merkez',
    locationRu: 'Ашхабад, Центр',
    locationId: 'merkez',
    serviceIds: ['haircut'],
    gender: 'male',
  ),
  _ClientMaster(
    id: 'm6',
    nameTk: 'Leýla',
    nameRu: 'Лейла',
    specialtyTk: 'Kirpik uzaldmak',
    specialtyRu: 'Наращивание ресниц',
    locationTk: 'Aşgabat, Mir',
    locationRu: 'Ашхабад, Мир',
    locationId: 'mir',
    serviceIds: ['cosmetology'],
    gender: 'female',
  ),
  _ClientMaster(
    id: 'm7',
    nameTk: 'Oguljahan',
    nameRu: 'Огулджахан',
    specialtyTk: 'Massaž, relaksasiýa',
    specialtyRu: 'Массаж, релаксация',
    locationTk: 'Aşgabat, Köpetdag',
    locationRu: 'Ашхабад, Копетдаг',
    locationId: 'kopetdag',
    serviceIds: ['massage'],
    gender: 'female',
  ),
  _ClientMaster(
    id: 'm8',
    nameTk: 'Selbi',
    nameRu: 'Сельби',
    specialtyTk: 'Saç bejergisi we ýaglama',
    specialtyRu: 'Уход за волосами и ламинирование',
    locationTk: 'Aşgabat, Ýasamal',
    locationRu: 'Ашхабад, Ясамал',
    locationId: 'yasamal',
    serviceIds: ['haircut'],
    gender: 'female',
  ),
  _ClientMaster(
    id: 'm9',
    nameTk: 'Yhlas',
    nameRu: 'Ыхлас',
    specialtyTk: 'Erkekler üçin saç bejergisi',
    specialtyRu: 'Уход за волосами для мужчин',
    locationTk: 'Aşgabat, Merkez',
    locationRu: 'Ашхабад, Центр',
    locationId: 'merkez',
    serviceIds: ['haircut'],
    gender: 'male',
  ),
  _ClientMaster(
    id: 'm10',
    nameTk: 'Jennet',
    nameRu: 'Дженнет',
    specialtyTk: 'Meýkap (makýaž)',
    specialtyRu: 'Макияж',
    locationTk: 'Aşgabat, Mir',
    locationRu: 'Ашхабад, Мир',
    locationId: 'mir',
    serviceIds: ['makeup'],
    gender: 'female',
  ),
  _ClientMaster(
    id: 'm11',
    nameTk: 'Jemal',
    nameRu: 'Джемал',
    specialtyTk: 'Massaž',
    specialtyRu: 'Массаж',
    locationTk: 'Aşgabat, Bagtyýarlyk',
    locationRu: 'Ашхабад, Багтыярлык',
    locationId: 'bagtyyarlyk',
    serviceIds: ['massage'],
    gender: 'female',
  ),
];

/// Which masters the client has favourited, keyed by [_ClientMaster.id].
/// Seeded from the mock data's `favorite` flags; mutated in place by the
/// heart toggle on [MasterProfileScreen] and by [ClientFavoritesScreen]
/// itself, so both stay in sync without a backend.
final _favoriteMasterIds = ValueNotifier<Set<String>>(_clientMasters.where((m) => m.favorite).map((m) => m.id).toSet());
