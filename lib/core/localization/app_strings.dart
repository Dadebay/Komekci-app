import 'app_language.dart';

/// All user-facing text lives here. Edit the tk, ru, or en value in one place.
/// Parameterized messages use p0, p1, etc. in the order of the call arguments.
/// Keep those placeholders when editing a translation so names, dates and amounts show correctly.
class AppTranslation {
  const AppTranslation({required this.tk, required this.ru, required this.en});
  final String tk;
  final String ru;
  final String en;
  String select(AppLanguage language) => switch (language) {
    AppLanguage.tk => tk,
    AppLanguage.ru => ru,
    AppLanguage.en => en,
  };

  String selectCode(String locale) => switch (locale) {
    'ru' => ru,
    'en' => en,
    _ => tk,
  };
}

abstract final class AppStrings {
  static const weekdaysShortTk = ['Du', 'Si', 'Ça', 'Pe', 'An', 'Şe', 'Ýe'];
  static const weekdaysShortRu = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'];
  static const weekdaysShortEn = ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su'];
  static const weekdaysFullTk = [
    'Duşenbe',
    'Sişenbe',
    'Çarşenbe',
    'Penşenbe',
    'Anna',
    'Şenbe',
    'Ýekşenbe',
  ];
  static const weekdaysFullRu = [
    'Понедельник',
    'Вторник',
    'Среда',
    'Четверг',
    'Пятница',
    'Суббота',
    'Воскресенье',
  ];
  static const weekdaysFullEn = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];
  static const monthsShortTk = [
    'Ýan',
    'Few',
    'Mart',
    'Apr',
    'Maý',
    'Iýun',
    'Iýul',
    'Awg',
    'Sen',
    'Okt',
    'Noý',
    'Dek',
  ];
  static const monthsShortRu = [
    'Янв',
    'Фев',
    'Мар',
    'Апр',
    'Май',
    'Июн',
    'Июл',
    'Авг',
    'Сен',
    'Окт',
    'Ноя',
    'Дек',
  ];
  static const monthsShortEn = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  static const monthsFullTk = [
    'Ýanwar',
    'Fewral',
    'Mart',
    'Aprel',
    'Maý',
    'Iýun',
    'Iýul',
    'Awgust',
    'Sentýabr',
    'Oktýabr',
    'Noýabr',
    'Dekabr',
  ];
  static const monthsFullRu = [
    'Январь',
    'Февраль',
    'Март',
    'Апрель',
    'Май',
    'Июнь',
    'Июль',
    'Август',
    'Сентябрь',
    'Октябрь',
    'Ноябрь',
    'Декабрь',
  ];
  static const monthsFullEn = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];
  static const calendarMonthsTk = [
    'ýanwar',
    'fewral',
    'mart',
    'aprel',
    'maý',
    'iýun',
    'iýul',
    'awgust',
    'sentýabr',
    'oktýabr',
    'noýabr',
    'dekabr',
  ];
  static const calendarMonthsRu = [
    'января',
    'февраля',
    'марта',
    'апреля',
    'мая',
    'июня',
    'июля',
    'августа',
    'сентября',
    'октября',
    'ноября',
    'декабря',
  ];
  static const recentPeriodLabelsTk = ['7 gün', '30 gün', '3 aý', '6 aý'];
  static const recentPeriodLabelsRu = ['7 дней', '30 дней', '3 мес.', '6 мес.'];
  static const recentPeriodLabelsEn = ['7 days', '30 days', '3 mo.', '6 mo.'];
  static const audienceTitlesTk = [
    'Ähli müşderiler',
    'Saýlanan müşderiler',
    'Soňky döwürde gelen müşderiler',
  ];
  static const audienceTitlesRu = [
    'Все клиенты',
    'Выбранные клиенты',
    'Клиенты за период',
  ];
  static const audienceTitlesEn = [
    'All clients',
    'Selected clients',
    'Recent clients',
  ];

  static const languageTurkmen = 'Türkmençe';
  static const languageTurkmenDescription = 'Türkmen dili';
  static const languageRussian = 'Русский';
  static const languageRussianDescription = 'Русский язык';
  static const languageEnglish = 'English';
  static const languageEnglishDescription = 'English language';

  static const faq = [
    (
      question: AppTranslation(
        tk: 'Abuna üçin nädip tölemeli?',
        ru: 'Как оплатить подписку?',
        en: 'How do I pay for my subscription?',
      ),
      answer: AppTranslation(
        tk: 'Kabinet → Töleg bölüminde balansyňyzy dolduryň.',
        ru: 'Кабинет → Оплата, пополните баланс.',
        en: 'Cabinet → Billing, top up your balance there.',
      ),
    ),
    (
      question: AppTranslation(
        tk: 'Hyzmaty nädip goşmaly?',
        ru: 'Как добавить услугу?',
        en: 'How do I add a service?',
      ),
      answer: AppTranslation(
        tk: 'Kabinet → Hyzmatlar → Täze hyzmat goş.',
        ru: 'Кабинет → Услуги → Добавить услугу.',
        en: 'Cabinet → Services → Add service.',
      ),
    ),
    (
      question: AppTranslation(
        tk: 'Iş wagtymy üýtgedip bilerinmi?',
        ru: 'Можно ли менять график?',
        en: 'Can I change my working hours?',
      ),
      answer: AppTranslation(
        tk: 'Hawa, Kabinet → Iş wagty bölüminde islendik wagt üýtgedip bilersiňiz.',
        ru: 'Да, в разделе Кабинет → График работы.',
        en: 'Yes, any time from Cabinet → Working hours.',
      ),
    ),
  ];

  static const splashChecking = AppTranslation(
    tk: 'Baglanyşyk barlanýar...',
    ru: 'Проверка соединения...',
    en: 'Checking connection...',
  );
  static const splashReady = AppTranslation(
    tk: 'Taýýar',
    ru: 'Готово',
    en: 'Ready',
  );
  static const splashOffline = AppTranslation(
    tk: 'Internet ýok — internet bolmazdan işleýär',
    ru: 'Нет интернета — автономный режим',
    en: 'No internet — offline mode',
  );
  static const serviceReminderTitle = AppTranslation(
    tk: 'Hyzmatyňyzy goşuň',
    ru: 'Добавьте свою услугу',
    en: 'Add your service',
  );
  static const serviceReminderBody = AppTranslation(
    tk: 'Kömekçide hyzmatyňyzy goşuň we programmanyň mümkinçiliklerinden peýdalanyň.',
    ru: 'Добавьте услугу в Kömekçi и начните пользоваться приложением.',
    en: 'Add a service in Kömekçi and start using the app.',
  );
  static const appointmentReminderTitle = AppTranslation(
    tk: 'Ýazylma ýatlatmasy',
    ru: 'Напоминание о записи',
    en: 'Appointment reminder',
  );
  static AppTranslation appointmentReminderBody(
    Object? masterName,
    Object? serviceName,
    Object? time,
  ) => AppTranslation(
    tk: '$masterName bilen $serviceName hyzmatyna ýazylan wagtyňyz $time. Bir sagat galdy.',
    ru: 'Через час у вас запись к $masterName на $time: $serviceName.',
    en: 'Your $serviceName appointment with $masterName is at $time, in one hour.',
  );
  static AppTranslation calendarDayPlanTitle(Object? masterName) =>
      AppTranslation(
        tk: 'Şu gün $masterName bilen ýazylmaňyz bar',
        ru: 'Сегодня у вас запись — мастер $masterName',
        en: 'You have a booking today — $masterName',
      );
  static AppTranslation calendarDayPlanDescription(
    Object? start,
    Object? masterName,
    Object? serviceName,
  ) => AppTranslation(
    tk: 'Şu gün sagat $start-da $masterName bilen $serviceName hyzmatyna ýazylmaňyz bar. Wagtynda geliň.',
    ru: 'Сегодня в $start у вас запись к мастеру $masterName ($serviceName). Пожалуйста, приходите вовремя.',
    en: 'Today at $start you have a booking with $masterName ($serviceName). Please arrive on time.',
  );
  static AppTranslation calendarTitle(
    Object? serviceName,
    Object? masterName,
  ) => AppTranslation(
    tk: '$serviceName — $masterName master',
    ru: '$serviceName — мастер $masterName',
    en: '$serviceName — $masterName master',
  );
  static AppTranslation calendarDescription(Object? start) => AppTranslation(
    tk: 'Ýazylan wagtyňyz $start. Wagtynda geliň.',
    ru: 'Ваша запись в $start. Пожалуйста, приходите вовремя.',
    en: 'Your booking is at $start. Please arrive on time.',
  );
  static const bookingAlertDefaultTitle = AppTranslation(
    tk: 'Täze ýazgy',
    ru: 'Новая запись',
    en: 'New booking',
  );

  /// Server wording corrected before an inbox notification is displayed.
  static const notificationWording = <(String, String)>[
    ('Kabul ýakynlaşýar', 'Nobatyňyz ýakynlaşýar'),
    ('Kabulynyz', 'Nobatyňyz'),
    ('kabulynyz', 'nobatyňyz'),
    ('Kabulyňyz', 'Nobatyňyz'),
    ('kabulyňyz', 'nobatyňyz'),
  ];
  static const authOneMonth = AppTranslation(
    tk: '1 aý',
    ru: '1 месяц',
    en: '1 month',
  );
  static AppTranslation authSeveralMonths(Object? months) => AppTranslation(
    tk: '$months aý',
    ru: '$months мес.',
    en: '$months months',
  );
  // features/app/application/app_settings_provider.dart
  static const appTmt = AppTranslation(tk: 'manat', ru: 'манат', en: 'TMT');

  // features/appointments/presentation/my_masters_screen.dart
  static const appointmentsAdd = AppTranslation(
    tk: 'Master goş',
    ru: 'Добавить',
    en: 'Add',
  );

  // features/appointments/presentation/appointment_detail_screen.dart
  static const appointmentsAddToPhoneCalendar = AppTranslation(
    tk: 'Telefon senenamasyna goş',
    ru: 'Добавить в календарь телефона',
    en: 'Add to phone calendar',
  );

  // features/appointments/presentation/appointment_detail_screen.dart
  static const appointmentsAddedToCalendarWithA = AppTranslation(
    tk: 'Senenama goşuldy. 1 sagat öň ýatladar.',
    ru: 'Добавлено в календарь с напоминанием за час.',
    en: 'Added to calendar with a one-hour reminder.',
  );

  // features/appointments/presentation/appointment_detail_screen.dart
  static const appointmentsAllowCalendarAccessInPhone = AppTranslation(
    tk: 'Telefon sazlamalarynda senenama rugsadyny açyň.',
    ru: 'Разрешите доступ к календарю в настройках телефона.',
    en: 'Allow calendar access in phone settings.',
  );

  // features/appointments/presentation/settings_screen.dart
  static const appointmentsAppointmentReminders = AppTranslation(
    tk: 'Ýazgy ýatlatmalary',
    ru: 'Напоминания о записи',
    en: 'Appointment reminders',
  );

  // features/appointments/presentation/my_masters_main_master_card.dart
  static const appointmentsBook = AppTranslation(
    tk: 'Ýazyl',
    ru: 'Записаться',
    en: 'Book',
  );

  // features/appointments/presentation/appointment_detail_screen.dart
  static const appointmentsBookAgain = AppTranslation(
    tk: 'Täzeden ýazyl',
    ru: 'Записаться снова',
    en: 'Book again',
  );

  // features/appointments/presentation/appointment_detail_screen.dart
  static const appointmentsBooking = AppTranslation(
    tk: 'Ýazgy',
    ru: 'Запись',
    en: 'Booking',
  );

  // features/appointments/presentation/appointment_detail_actions.dart
  static const appointmentsCancel = AppTranslation(
    tk: 'Ýatyr',
    ru: 'Отменить',
    en: 'Cancel',
  );

  // features/appointments/presentation/appointment_detail_screen.dart
  static const appointmentsCancelAppointment = AppTranslation(
    tk: 'Ýazgyny ýatyr',
    ru: 'Отменить запись',
    en: 'Cancel appointment',
  );

  // features/appointments/presentation/my_masters_masters_empty.dart
  static const appointmentsCancelRequest = AppTranslation(
    tk: 'Haýyşy yzyna al',
    ru: 'Отозвать запрос',
    en: 'Cancel request',
  );

  // features/appointments/presentation/appointment_detail_actions.dart
  static const appointmentsCancelThisBooking = AppTranslation(
    tk: 'Ýazgyny ýatyrmaly?',
    ru: 'Отменить запись?',
    en: 'Cancel this booking?',
  );

  // features/appointments/presentation/reschedule_screen.dart
  static const appointmentsChangeAppointment = AppTranslation(
    tk: 'Ýazgyny üýtget',
    ru: 'Изменить запись',
    en: 'Change appointment',
  );

  // features/appointments/presentation/reschedule_screen.dart
  static const appointmentsConfirmNewTime = AppTranslation(
    tk: 'Täze wagty tassykla',
    ru: 'Подтвердить новое время',
    en: 'Confirm new time',
  );

  // features/appointments/presentation/my_masters_screen.dart
  static const appointmentsConnectedMasters = AppTranslation(
    tk: 'Baglanan masterler',
    ru: 'Подключённые мастера',
    en: 'Connected masters',
  );

  // features/appointments/presentation/settings_screen.dart
  static const appointmentsContactOrNote = AppTranslation(
    tk: 'Habarlaşmak ýa-da bellik',
    ru: 'Контакт или заметка',
    en: 'Contact or note',
  );

  // features/appointments/presentation/appointment_detail_screen.dart
  static const appointmentsCouldNotAddToCalendar = AppTranslation(
    tk: 'Senenama goşup bolmady.',
    ru: 'Не удалось добавить в календарь.',
    en: 'Could not add to calendar.',
  );

  // features/appointments/presentation/settings_screen.dart
  static const appointmentsEarlierSlotOffers = AppTranslation(
    tk: 'Has irki wagt teklipleri',
    ru: 'Предложения более раннего времени',
    en: 'Earlier-slot offers',
  );

  // features/appointments/presentation/my_masters_screen.dart
  static const appointmentsEnterYourMasterSNickname = AppTranslation(
    tk: 'Masteriň lakamyny ýa-da telefonyny giriziň, haýyş iberiň — kabul eden badyna ýazyp bilersiňiz.',
    ru: 'Введите никнейм или телефон мастера и отправьте запрос — после принятия вы сможете записываться.',
    en: 'Enter your master’s nickname or phone and send a request — once accepted you can book.',
  );

  // features/appointments/presentation/appointment_detail_actions.dart
  static const appointmentsHowManyMinutesLate = AppTranslation(
    tk: 'Näçe minut gijä galýarsyňyz?',
    ru: 'На сколько минут вы опаздываете?',
    en: 'How many minutes late?',
  );

  // features/appointments/presentation/my_masters_main_master_card.dart
  static const appointmentsMainMaster = AppTranslation(
    tk: 'Esasy master',
    ru: 'Основной мастер',
    en: 'Main master',
  );

  // features/appointments/presentation/my_masters_masters_empty.dart
  static const appointmentsMakeMainMaster = AppTranslation(
    tk: 'Esasy master et',
    ru: 'Сделать основным',
    en: 'Make main master',
  );

  // features/appointments/presentation/settings_screen.dart
  static const appointmentsManageYourPreferences = AppTranslation(
    tk: 'Sazlamalaryňyzy dolandyryň.',
    ru: 'Управляйте своими настройками.',
    en: 'Manage your preferences.',
  );

  // features/appointments/presentation/appointment_detail_screen.dart
  static const appointmentsMaster = AppTranslation(
    tk: 'Master',
    ru: 'Мастер',
    en: 'Master',
  );

  // features/appointments/presentation/my_masters_screen.dart
  static AppTranslation appointmentsMessage(Object? p0, Object? p1) =>
      AppTranslation(tk: '$p0 master', ru: 'Мастеров: $p0', en: '$p0 $p1');

  // features/appointments/presentation/reschedule_screen.dart
  static const appointmentsNewDate = AppTranslation(
    tk: 'Täze sene',
    ru: 'Новая дата',
    en: 'New date',
  );

  // features/appointments/presentation/reschedule_screen.dart
  static const appointmentsNewTime = AppTranslation(
    tk: 'Täze wagt',
    ru: 'Новое время',
    en: 'New time',
  );

  // features/appointments/presentation/my_masters_screen.dart
  static const appointmentsNoConnectedMastersYet = AppTranslation(
    tk: 'Baglanan masteriňiz ýok',
    ru: 'Связанных мастеров нет',
    en: 'No connected masters yet',
  );

  // features/appointments/presentation/my_masters_screen.dart
  static const appointmentsNoMastersYet = AppTranslation(
    tk: 'Heniz master goşulmady',
    ru: 'Мастеров пока нет',
    en: 'No masters yet',
  );

  // features/appointments/presentation/my_masters_screen.dart
  static const appointmentsOtherMasters = AppTranslation(
    tk: 'Beýleki masterler',
    ru: 'Другие мастера',
    en: 'Other masters',
  );

  // features/appointments/presentation/my_masters_screen.dart
  static const appointmentsPendingRequests = AppTranslation(
    tk: 'Garaşylýan haýyşlar',
    ru: 'Ожидают ответа',
    en: 'Pending requests',
  );

  // features/appointments/presentation/reschedule_screen.dart
  static const appointmentsPleasePickAnotherDay = AppTranslation(
    tk: 'Başga gün saýlaň.',
    ru: 'Выберите другой день.',
    en: 'Please pick another day.',
  );

  // features/appointments/presentation/my_masters_masters_empty.dart
  static const appointmentsRemove = AppTranslation(
    tk: 'Aýyr',
    ru: 'Удалить',
    en: 'Remove',
  );

  // features/appointments/presentation/my_masters_masters_empty.dart
  static const appointmentsRemoveConnection = AppTranslation(
    tk: 'Baglanyşygy aýyr',
    ru: 'Удалить связь',
    en: 'Remove connection',
  );

  // features/appointments/presentation/my_masters_masters_empty.dart
  static const appointmentsRemoveThisConnection = AppTranslation(
    tk: 'Baglanyşygy aýyrmalymy?',
    ru: 'Удалить связь?',
    en: 'Remove this connection?',
  );

  // features/appointments/presentation/appointment_detail_screen.dart
  static const appointmentsRunningLate = AppTranslation(
    tk: 'Gijä galýaryn',
    ru: 'Опаздываю',
    en: 'Running late',
  );

  // features/appointments/presentation/appointment_detail_time_card.dart
  static const appointmentsServiceTime = AppTranslation(
    tk: 'Hyzmat wagty',
    ru: 'Время услуги',
    en: 'Service time',
  );

  // features/appointments/presentation/appointment_detail_actions.dart
  static const appointmentsThatTimeIsTakenNearest = AppTranslation(
    tk: 'Şol wagt eýýäm alnan. Ýakyn boş wagtlar:',
    ru: 'Это время занято. Ближайшее свободное:',
    en: 'That time is taken. Nearest free times:',
  );

  // features/appointments/presentation/appointment_detail_actions.dart
  static const appointmentsThisActionCannotBeUndone = AppTranslation(
    tk: 'Bu hereketi yzyna gaýtaryp bolmaz.',
    ru: 'Это действие нельзя отменить.',
    en: 'This action cannot be undone.',
  );

  // features/appointments/presentation/appointment_detail_time_card.dart
  static const appointmentsTimeToArrive = AppTranslation(
    tk: 'Barmaly wagtyňyz',
    ru: 'Время прихода',
    en: 'Time to arrive',
  );

  // features/appointments/presentation/my_masters_main_master_card.dart
  static const appointmentsWaitingForTheMasterTo = AppTranslation(
    tk: 'Masteriň kabul etmegine garaşylýar',
    ru: 'Ждём ответа мастера',
    en: 'Waiting for the master to accept',
  );

  // features/appointments/presentation/appointment_detail_screen.dart
  static const appointmentsWeLlTellYouIf = AppTranslation(
    tk: 'Has irki wagt açylsa, size habar berler',
    ru: 'Сообщим, если освободится более раннее время',
    en: 'We’ll tell you if an earlier slot opens up',
  );

  // features/appointments/presentation/appointment_detail_screen.dart
  static AppTranslation appointmentsYouSignalledYouLlBe(Object? p0) =>
      AppTranslation(
        tk: '$p0 min gijä galýaryn diýip habar berdiňiz',
        ru: 'Вы сообщили, что опоздаете на $p0 мин',
        en: 'You signalled you’ll be $p0 min late',
      );

  // features/appointments/presentation/my_masters_masters_empty.dart
  static AppTranslation appointmentsYouWonTBeAble(Object? p0) => AppTranslation(
    tk: '$p0 bilen ýazyp bilmersiňiz, täzeden haýyş ibermeli bolarsyňyz.',
    ru: 'Вы больше не сможете записываться к $p0 — потребуется новый запрос.',
    en: 'You won’t be able to book $p0 until you send a new request.',
  );

  // features/auth/presentation/master_registration_screen.dart
  static const auth320CharactersAZ = AppTranslation(
    tk: '3–20 nyşan: a–z, 0–9 we _. San bilen başlap bolmaýar.',
    ru: '3–20 символов: a–z, 0–9 и _ (не с цифры)',
    en: '3–20 characters: a–z, 0–9 and _ (no leading digit)',
  );

  // features/auth/presentation/master_registration_submit.dart
  static const auth320CharsLowercaseLetters = AppTranslation(
    tk: '3–20 nyşan: kiçi harp, san we _. San bilen başlap bolmaýar.',
    ru: '3-20 символов: строчные буквы, цифры и _ (не с цифры)',
    en: '3-20 chars: lowercase letters, numbers and _ (no leading digit)',
  );

  // features/auth/presentation/master_registration_screen.dart
  static const authAFewWordsAboutYour = AppTranslation(
    tk: 'Tejribäňiz, hyzmatlaryňyz barada gysgaça ýazyň',
    ru: 'Коротко об опыте и услугах',
    en: 'A few words about your experience and services',
  );

  // features/auth/presentation/client_registration_widgets.dart
  static const authANewAccountCannotBe = AppTranslation(
    tk: 'Täze hasap açmak mümkin däl. Şol hasaba SMS kod bilen girip bilersiňiz.',
    ru: 'Создать новый аккаунт нельзя. Вы можете войти в существующий по SMS-коду.',
    en: 'A new account cannot be created. You can sign in to the existing one with an SMS code.',
  );

  // features/auth/presentation/client_registration_submit.dart
  static const authAProfilePhotoIsRequired = AppTranslation(
    tk: 'Profil suraty hökmany',
    ru: 'Фото профиля обязательно',
    en: 'A profile photo is required',
  );

  // features/auth/presentation/master_phone_payment_dialog.dart
  static AppTranslation authASingleTransferMustBe(Object? p0, Object? p1) =>
      AppTranslation(
        tk: 'Bir geçirimde iň az $p0 $p1 bolmaly.',
        ru: 'Один перевод должен быть не меньше $p0 $p1.',
        en: 'A single transfer must be at least $p0 $p1.',
      );

  // features/auth/presentation/master_subscription_top_up_balance_summary.dart
  static const authAcceptOnlineBookings = AppTranslation(
    tk: 'Onlaýn ýazgylary kabul ediň',
    ru: 'Принимайте онлайн-записи',
    en: 'Accept online bookings',
  );

  // features/auth/presentation/connect_master_connect_hero.dart
  static const authAcceptingBookings = AppTranslation(
    tk: 'Ýazgy kabul edýär',
    ru: 'Принимает записи',
    en: 'Accepting bookings',
  );

  // features/auth/presentation/master_registration_form_widgets.dart
  static const authAddABanner = AppTranslation(
    tk: 'Baner suraty goşuň *',
    ru: 'Добавьте баннер *',
    en: 'Add a banner *',
  );

  // features/auth/presentation/master_registration_form_widgets.dart
  static const authAddAProfilePhoto = AppTranslation(
    tk: 'Profil suratyny goşuň *',
    ru: 'Добавьте фото профиля *',
    en: 'Add a profile photo *',
  );

  // features/auth/presentation/client_registration_screen.dart
  static const authAddAProfilePhoto2 = AppTranslation(
    tk: 'Profil suratyny goşuň',
    ru: 'Добавьте фото профиля',
    en: 'Add a profile photo',
  );

  // features/auth/presentation/connect_master_flow.dart
  static const authAddMaster = AppTranslation(
    tk: 'Master goş',
    ru: 'Добавить мастера',
    en: 'Add master',
  );

  // features/auth/presentation/connect_master_connect_hero.dart
  static const authAlreadyConnected = AppTranslation(
    tk: 'Eýýäm baglanyşykly',
    ru: 'Уже подключены',
    en: 'Already connected',
  );

  // features/auth/presentation/client_registration_widgets.dart
  static const authAnAccountWithThisNumber = AppTranslation(
    tk: 'Bu belgi bilen hasap açylypdyr, ýöne tassyklanmandyr. Goldaw bilen habarlaşyň.',
    ru: 'Аккаунт с этим номером создан, но не подтверждён. Обратитесь в поддержку.',
    en: 'An account with this number was started but never confirmed. Please contact support.',
  );

  // features/auth/presentation/client_registration_widgets.dart
  static const authAnAccountWithThisNumber2 = AppTranslation(
    tk: 'Bu belgi bilen hasap eýýäm bar. Şol hasaba girip bilersiňiz.',
    ru: 'С этим номером уже есть аккаунт. Вы можете войти в него.',
    en: 'An account with this number already exists. You can sign in to it.',
  );

  // features/auth/presentation/connect_master_flow.dart
  static const authAskYourMasterForTheir = AppTranslation(
    tk: 'Masterden lakamyny soraň',
    ru: 'Узнайте никнейм у мастера',
    en: 'Ask your master for their nickname',
  );

  // features/auth/presentation/master_phone_payment_dialog.dart
  static const authAtmAndTerminal = AppTranslation(
    tk: 'Bankomat we terminal',
    ru: 'Банкомат и терминал',
    en: 'ATM and terminal',
  );

  // features/auth/presentation/master_subscription_screen.dart
  static const authBankCard = AppTranslation(
    tk: 'Bank kartasy',
    ru: 'Банковская карта',
    en: 'Bank card',
  );

  // features/auth/presentation/master_registration_screen.dart
  static const authBasics = AppTranslation(
    tk: 'Esasy maglumat',
    ru: 'Основное',
    en: 'Basics',
  );

  // features/auth/presentation/connect_master_flow.dart
  static const authBookAppointments = AppTranslation(
    tk: 'Ýazylyň',
    ru: 'Записывайтесь',
    en: 'Book appointments',
  );

  // features/auth/presentation/connect_master_connect_hero.dart
  static const authBookingsPaused = AppTranslation(
    tk: 'Wagtlaýyn ýapyk',
    ru: 'Запись временно закрыта',
    en: 'Bookings paused',
  );

  // features/auth/presentation/login_screen.dart
  static const authByContinuingYouAcceptThe = AppTranslation(
    tk: 'Dowam etmek bilen hyzmat şertlerini kabul edýärsiňiz.',
    ru: 'Продолжая, вы принимаете условия сервиса.',
    en: 'By continuing, you accept the terms of service.',
  );

  // features/auth/presentation/otp_screen.dart
  static const authChangeNumber = AppTranslation(
    tk: 'Belgini üýtgetmek',
    ru: 'Изменить номер',
    en: 'Change number',
  );

  // features/auth/presentation/master_subscription_payment_widgets.dart
  static const authCheckAgain = AppTranslation(
    tk: 'Täzeden barla',
    ru: 'Проверить снова',
    en: 'Check again',
  );

  // features/auth/presentation/master_card_payment_dialog.dart
  static const authCheckPayment = AppTranslation(
    tk: 'Tölegi barla',
    ru: 'Проверить оплату',
    en: 'Check payment',
  );

  // features/auth/presentation/connect_master_flow.dart
  static const authCheckThatTheNicknameOr = AppTranslation(
    tk: 'Lakamy ýa-da telefon belgisini doly we dogry ýazandygyňyzy barlaň. Gözleg takyk deňleşdirme bilen işleýär.',
    ru: 'Проверьте, что никнейм или номер введены полностью и без ошибок. Поиск работает по точному совпадению.',
    en: 'Check that the nickname or number is complete and correct. Search only matches exactly.',
  );

  // features/auth/presentation/master_phone_payment_dialog.dart
  static const authChecking = AppTranslation(
    tk: 'Barlanýar...',
    ru: 'Проверяем...',
    en: 'Checking...',
  );

  // features/auth/presentation/master_card_payment_dialog.dart
  static AppTranslation authChooseABankToPay(Object? p0, Object? p1) =>
      AppTranslation(
        tk: '$p0 $p1 tölemek üçin banky saýlaň.',
        ru: 'Выберите банк для оплаты $p0 $p1.',
        en: 'Choose a bank to pay $p0 $p1.',
      );

  // features/auth/presentation/master_subscription_screen.dart
  static const authChooseAnAmount = AppTranslation(
    tk: 'Möçberi saýlaň',
    ru: 'Выберите сумму',
    en: 'Choose an amount',
  );

  // features/auth/presentation/language_screen.dart
  static const authChooseYourPreferredLanguageFor = AppTranslation(
    tk: 'Programmany ulanmak üçin öz diliňizi saýlaň',
    ru: 'Выберите предпочтительный язык для приложения',
    en: 'Choose your preferred language for the app',
  );

  // features/auth/presentation/master_registration_screen.dart
  static const authCityDistrictStreet = AppTranslation(
    tk: 'Şäher, etrap, köçe',
    ru: 'Город, район, улица',
    en: 'City, district, street',
  );

  // features/auth/presentation/master_registration_screen.dart
  static const authClientsWillFindYouBy = AppTranslation(
    tk: 'Müşderiler sizi şu lakam bilen tapar',
    ru: 'Клиенты найдут вас по этому никнейму',
    en: 'Clients will find you by this nickname',
  );

  // features/auth/presentation/master_subscription_payment_widgets.dart
  static const authClose = AppTranslation(
    tk: 'Ýapmak',
    ru: 'Закрыть',
    en: 'Close',
  );

  // features/auth/presentation/sms_otp_screen.dart
  static const authCode = AppTranslation(tk: 'Kod', ru: 'Код', en: 'Code');

  // features/auth/presentation/sms_otp_screen.dart
  static const authConfirmBySms = AppTranslation(
    tk: 'SMS iberip tassyklaň',
    ru: 'Подтвердите по SMS',
    en: 'Confirm by SMS',
  );

  // features/auth/presentation/master_phone_payment_dialog.dart
  static const authConfirmPayment = AppTranslation(
    tk: 'Tölegi tassykla',
    ru: 'Подтвердить оплату',
    en: 'Confirm payment',
  );

  // features/auth/presentation/connect_master_connect_hero.dart
  static const authConnect = AppTranslation(
    tk: 'Baglan',
    ru: 'Подключиться',
    en: 'Connect',
  );

  // features/auth/presentation/connect_master_flow.dart
  static const authConnectToYourMaster = AppTranslation(
    tk: 'Masteriňize baglanyň',
    ru: 'Подключитесь к мастеру',
    en: 'Connect to your master',
  );

  // features/auth/presentation/master_subscription_screen.dart
  static const authContinueToPay = AppTranslation(
    tk: 'Tölege geç',
    ru: 'Перейти к оплате',
    en: 'Continue to pay',
  );

  // features/auth/presentation/master_card_payment_dialog.dart
  static const authContinueToPayment = AppTranslation(
    tk: 'Tölemäge geç',
    ru: 'Перейти к оплате',
    en: 'Continue to payment',
  );

  // features/auth/presentation/login_screen.dart
  static const authContinueWithYourPhoneNumber = AppTranslation(
    tk: 'Telefon belgiňiz bilen dowam ediň.',
    ru: 'Продолжите с номером телефона.',
    en: 'Continue with your phone number.',
  );

  // features/auth/presentation/sms_otp_screen.dart
  static const authCopied = AppTranslation(
    tk: 'Göçürildi',
    ru: 'Скопировано',
    en: 'Copied',
  );

  // features/auth/presentation/master_phone_payment_dialog_notes_list.dart
  static const authCopy = AppTranslation(
    tk: 'Göçür',
    ru: 'Копировать',
    en: 'Copy',
  );

  // features/auth/presentation/sms_otp_screen.dart
  static const authCouldNotVerifyNoAccount = AppTranslation(
    tk: 'Tassyklanmady. Bu belgi bilen hasap tapylmady ýa-da kod nädogry.',
    ru: 'Не удалось подтвердить. Аккаунт с этим номером не найден или код неверный.',
    en: 'Could not verify. No account for this number, or the code was wrong.',
  );

  // features/auth/presentation/master_registration_screen.dart
  static const authCreateYourProfile = AppTranslation(
    tk: 'Profiliňizi dörediň',
    ru: 'Создайте профиль',
    en: 'Create your profile',
  );

  // features/auth/presentation/master_otp_screen.dart
  static const authDidnTGetACode = AppTranslation(
    tk: 'Kod gelmedi?',
    ru: 'Код не пришёл?',
    en: "Didn't get a code?",
  );

  // features/auth/presentation/login_screen.dart
  static const authEnterAn8DigitPhone = AppTranslation(
    tk: '8 sanly telefon belgisini ýazyň',
    ru: 'Введите 8-значный номер',
    en: 'Enter an 8-digit phone number',
  );

  // features/auth/presentation/connect_master_flow.dart
  static const authEnterAtLeast3Characters = AppTranslation(
    tk: 'Iň az 3 simwol giriziň',
    ru: 'Введите минимум 3 символа',
    en: 'Enter at least 3 characters',
  );

  // features/auth/presentation/master_otp_screen.dart
  static const authEnterThe6DigitCode = AppTranslation(
    tk: 'Size SMS arkaly iberilen 6 sanly kody giriziň.\\n',
    ru: 'Введите 6-значный код из SMS.\n',
    en: 'Enter the 6-digit code sent to you by SMS.\n',
  );

  // features/auth/presentation/master_phone_screen.dart
  static const authEnterThe8DigitNumber = AppTranslation(
    tk: '8 sanly belgini giriziň',
    ru: 'Введите 8 цифр номера',
    en: 'Enter the 8-digit number',
  );

  // features/auth/presentation/connect_master_flow.dart
  static const authEnterYourMasterSNickname = AppTranslation(
    tk: 'Masteriň lakamyny ýa-da telefon belgisini giriziň',
    ru: 'Введите никнейм или номер телефона мастера',
    en: "Enter your master's nickname or phone number",
  );

  // features/auth/presentation/master_registration_screen.dart
  static const authEnterYourName = AppTranslation(
    tk: 'Adyňyzy ýazyň',
    ru: 'Введите имя',
    en: 'Enter your name',
  );

  // features/auth/presentation/master_phone_screen.dart
  static const authEnterYourPhoneNumber = AppTranslation(
    tk: 'Telefon belgiňizi giriziň',
    ru: 'Введите номер телефона',
    en: 'Enter your phone number',
  );

  // features/auth/presentation/master_registration_screen.dart
  static const authFillInTheFieldsMarked = AppTranslation(
    tk: 'Dowam etmek üçin * bilen bellenen meýdanlary dolduryň.',
    ru: 'Заполните поля, отмеченные *, чтобы продолжить.',
    en: 'Fill in the fields marked * to continue.',
  );

  // features/auth/presentation/master_subscription_screen.dart
  static AppTranslation authForMonth(Object? p0, Object? p1) => AppTranslation(
    tk: '$p0 aý üçin',
    ru: 'за $p0 мес.',
    en: 'for $p0 month$p1',
  );

  // features/auth/presentation/master_subscription_payment_widgets.dart
  static AppTranslation authFreeMonthIsActiveDays(Object? p0) => AppTranslation(
    tk: 'Mugt aý işjeň: $p0 gün galdy. Soň abuna üçin balansyňyzy dolduryň.',
    ru: 'Бесплатный месяц активен: осталось $p0 дн. Затем пополните баланс для подписки.',
    en: 'Free month is active: $p0 days left. Afterwards top up your balance to continue.',
  );

  // features/auth/presentation/master_phone_payment_dialog.dart
  static const authFromWhichNumber = AppTranslation(
    tk: 'Haýsy belgiden',
    ru: 'С какого номера',
    en: 'From which number',
  );

  // features/auth/presentation/sms_otp_screen.dart
  static const authGetANewCode = AppTranslation(
    tk: 'Täze kod al',
    ru: 'Получить новый код',
    en: 'Get a new code',
  );

  // features/auth/presentation/connect_master_not_found_note.dart
  static const authGoToHome = AppTranslation(
    tk: 'Baş sahypa',
    ru: 'На главную',
    en: 'Go to home',
  );

  // features/auth/presentation/master_subscription_payment_widgets.dart
  static AppTranslation authHasBeenAddedToYour(Object? p0, Object? p1) =>
      AppTranslation(
        tk: 'Balansyňyza $p0 $p1 goşuldy.',
        ru: 'На ваш баланс зачислено $p0 $p1.',
        en: '$p0 $p1 has been added to your balance.',
      );

  // features/auth/presentation/master_phone_payment_dialog.dart
  static const authHaveQuestions = AppTranslation(
    tk: 'Soraglaryňyz barmy?',
    ru: 'Есть вопросы?',
    en: 'Have questions?',
  );

  // features/auth/presentation/master_subscription_amount_option.dart
  static const authHowDoesTheBalanceWork = AppTranslation(
    tk: 'Balans nähili işleýär?',
    ru: 'Как работает баланс?',
    en: 'How does the balance work?',
  );

  // features/auth/presentation/connect_master_flow.dart
  static const authHowItWorks = AppTranslation(
    tk: 'Nähili işleýär?',
    ru: 'Как это работает?',
    en: 'How it works',
  );

  // features/auth/presentation/master_subscription_screen.dart
  static const authHowManyMonths = AppTranslation(
    tk: 'Näçe aý üçin tölemek isleýärsiňiz?',
    ru: 'На сколько месяцев оплатить?',
    en: 'How many months?',
  );

  // features/auth/presentation/connect_master_flow.dart
  static const authILlConnectLater = AppTranslation(
    tk: 'Soňrak baglanaryn',
    ru: 'Подключусь позже',
    en: 'I’ll connect later',
  );

  // features/auth/presentation/client_registration_screen.dart
  static const authItOnlyTakesAMinute = AppTranslation(
    tk: 'Bary-ýogy bir minut gerek',
    ru: 'Это займёт одну минуту',
    en: 'It only takes a minute',
  );

  // features/auth/presentation/master_subscription_top_up_balance_summary.dart
  static const authManageYourClientList = AppTranslation(
    tk: 'Müşderi bazaňyzy dolandyryň',
    ru: 'Ведите базу клиентов',
    en: 'Manage your client list',
  );

  // features/auth/presentation/master_registration_screen.dart
  static const authMasterProfile = AppTranslation(
    tk: 'MASTER HASABY',
    ru: 'ПРОФИЛЬ МАСТЕРА',
    en: 'MASTER PROFILE',
  );

  // features/auth/presentation/master_phone_screen.dart
  static const authMasterRegistration = AppTranslation(
    tk: 'MASTER HASABY',
    ru: 'РЕГИСТРАЦИЯ МАСТЕРА',
    en: 'MASTER REGISTRATION',
  );

  // features/auth/presentation/master_subscription_top_up_balance_summary.dart
  static const authMasterSubscription = AppTranslation(
    tk: 'MASTER ABUNA',
    ru: 'ПОДПИСКА МАСТЕРА',
    en: 'MASTER SUBSCRIPTION',
  );

  // features/auth/presentation/client_registration_screen.dart
  static const authMastersWillFindYouBy = AppTranslation(
    tk: 'Masterler sizi şu lakam arkaly tapar',
    ru: 'Мастера найдут вас по этому никнейму',
    en: 'Masters will find you by this nickname',
  );

  // features/auth/presentation/master_phone_payment_dialog.dart
  static const authMinimumAmount = AppTranslation(
    tk: 'Iň az möçber',
    ru: 'Минимальная сумма',
    en: 'Minimum amount',
  );

  // features/auth/presentation/master_subscription_screen.dart
  static AppTranslation authMoneyGoesToYourBalance(
    Object? p0,
    Object? p1,
  ) => AppTranslation(
    tk: 'Pul balansyňyza goşulýar. Abuna üçin her aý $p0 $p1 tutulýar.',
    ru: 'Деньги поступят на баланс. Подписка списывает $p0 $p1 каждый месяц.',
    en: 'Money goes to your balance. The subscription charges $p0 $p1 monthly.',
  );

  // features/auth/presentation/master_subscription_amount_option.dart
  static AppTranslation authMoneyYouAddIsKept(
    Object? p0,
    Object? p1,
    Object? p2,
    Object? p3,
  ) => AppTranslation(
    tk: 'Goşan puluňyz balansyňyzda saklanýar. Her aý abuna üçin $p0 $p1 awtomatiki tutulýar. Mysal üçin, balansyňyza $p2 $p1 goşsaňyz, birinji aý $p0 $p1, indiki aý ýene $p0 $p1 tutular. Galan $p3 $p1 balansyňyzda saklanar.',
    ru: 'Внесённые деньги хранятся на балансе. Каждый месяц за подписку автоматически списывается $p0 $p1. Например, при пополнении на $p2 $p1: $p0 $p1 спишется в первый месяц, ещё $p0 — во второй, оставшиеся $p3 останутся на балансе.',
    en: 'Money you add is kept on your balance. Each month, $p0 $p1 is automatically deducted for the subscription. For example, if you top up $p2 $p1, $p0 $p1 is deducted the first month, another $p0 $p1 the next, and the remaining $p3 $p1 stays on your balance.',
  );

  // features/auth/presentation/master_subscription_top_up_balance_summary.dart
  static const authMonth = AppTranslation(tk: 'aý', ru: 'мес.', en: 'month');

  // features/auth/presentation/master_subscription_top_up_balance_summary.dart
  static const authMonthly = AppTranslation(
    tk: 'Aýlyk abuna',
    ru: 'В месяц',
    en: 'Monthly',
  );

  // features/auth/presentation/sms_otp_screen.dart
  static AppTranslation authNewCodeInS(Object? p0) => AppTranslation(
    tk: 'Täze kod $p0 sek soň',
    ru: 'Новый код через $p0 сек',
    en: 'New code in ${p0}s',
  );

  // features/auth/presentation/master_registration_screen.dart
  static const authNickname = AppTranslation(
    tk: 'Lakam (nickname)',
    ru: 'Никнейм',
    en: 'Nickname',
  );

  // features/auth/presentation/connect_master_flow.dart
  static const authNickname2 = AppTranslation(
    tk: 'Lakam',
    ru: 'Никнейм',
    en: 'Nickname',
  );

  // features/auth/presentation/master_registration_screen.dart
  static const authNicknameIsAvailable = AppTranslation(
    tk: 'Bu lakam elýeterli',
    ru: 'Никнейм свободен',
    en: 'Nickname is available',
  );

  // features/auth/presentation/connect_master_flow.dart
  static const authNicknameOr993Phone = AppTranslation(
    tk: '@lakam ýa-da +993 telefon',
    ru: '@никнейм или телефон +993',
    en: '@nickname or +993 phone',
  );

  // features/auth/presentation/connect_master_flow.dart
  static const authNoMasterFound = AppTranslation(
    tk: 'Master tapylmady',
    ru: 'Мастер не найден',
    en: 'No master found',
  );

  // features/auth/presentation/master_subscription_screen.dart
  static const authNoPaymentPhoneNumberIs = AppTranslation(
    tk: 'Töleg üçin telefon belgisi elýeterli däl',
    ru: 'Нет доступного номера для оплаты',
    en: 'No payment phone number is available',
  );

  // features/auth/presentation/master_phone_payment_dialog.dart
  static const authNote = AppTranslation(
    tk: 'ÜNS BERIŇ',
    ru: 'ВНИМАНИЕ',
    en: 'NOTE',
  );

  // features/auth/presentation/master_phone_screen.dart
  static const authNumberLooksGood = AppTranslation(
    tk: 'Belgi dogry görünýär',
    ru: 'Номер выглядит верно',
    en: 'Number looks good',
  );

  // features/auth/presentation/master_phone_payment_dialog_notes_list.dart
  static const authNumberToSendTo = AppTranslation(
    tk: 'Pul geçirilmeli belgi',
    ru: 'Номер для перевода',
    en: 'Number to send to',
  );

  // features/auth/presentation/connect_master_flow.dart
  static const authOnceAcceptedYouCanSee = AppTranslation(
    tk: 'Kabul edilenden soň hyzmatlary we boş wagtlary görersiňiz.',
    ru: 'После принятия вы увидите услуги и свободное время.',
    en: 'Once accepted you can see services and free times.',
  );

  // features/auth/presentation/master_phone_payment_dialog_notes_list.dart
  static const authOpenTheSmsAgain = AppTranslation(
    tk: 'SMS-i täzeden aç',
    ru: 'Открыть SMS снова',
    en: 'Open the SMS again',
  );

  // features/auth/presentation/connect_master_flow.dart
  static const authOrUseTheirPhoneNumber = AppTranslation(
    tk: 'Ýa-da onuň telefon belgisini ulanyň.',
    ru: 'Или воспользуйтесь его номером телефона.',
    en: 'Or use their phone number.',
  );

  // features/auth/presentation/master_subscription_screen.dart
  static const authPay = AppTranslation(tk: 'Töle', ru: 'Оплатить', en: 'Pay');

  // features/auth/presentation/master_card_payment_dialog.dart
  static const authPayByBankCard = AppTranslation(
    tk: 'Bank kartasy bilen töleg',
    ru: 'Оплата банковской картой',
    en: 'Pay by bank card',
  );

  // features/auth/presentation/master_phone_payment_dialog.dart
  static const authPayByPhone = AppTranslation(
    tk: 'Telefon arkaly töleg',
    ru: 'Оплата с телефона',
    en: 'Pay by phone',
  );

  // features/auth/presentation/master_card_payment_dialog.dart
  static const authPayment = AppTranslation(
    tk: 'Töleg',
    ru: 'Оплата',
    en: 'Payment',
  );

  // features/auth/presentation/master_subscription_top_up_balance_summary.dart
  static const authPaymentDue = AppTranslation(
    tk: 'Töleg wagty ýetdi',
    ru: 'Пора оплатить',
    en: 'Payment due',
  );

  // features/auth/presentation/master_subscription_payment_widgets.dart
  static const authPaymentFailed = AppTranslation(
    tk: 'Töleg başa barmady',
    ru: 'Платёж не прошёл',
    en: 'Payment failed',
  );

  // features/auth/presentation/master_subscription_screen.dart
  static const authPaymentMethod = AppTranslation(
    tk: 'Töleg usuly',
    ru: 'Способ оплаты',
    en: 'Payment method',
  );

  // features/auth/presentation/master_subscription_payment_widgets.dart
  static const authPaymentPending = AppTranslation(
    tk: 'Tölege garaşylýar',
    ru: 'Платёж в обработке',
    en: 'Payment pending',
  );

  // features/auth/presentation/master_subscription_payment_widgets.dart
  static const authPaymentSuccessful = AppTranslation(
    tk: 'Töleg kabul edildi!',
    ru: 'Оплата прошла успешно!',
    en: 'Payment successful!',
  );

  // features/auth/presentation/master_phone_payment_dialog.dart
  static const authPaymentViaAtmOrTerminal = AppTranslation(
    tk: 'Bankomat ýa-da terminal arkaly töleg kabul edilmeýär.',
    ru: 'Оплата через банкомат или терминал не принимается.',
    en: 'Payment via ATM or terminal is not accepted.',
  );

  // features/auth/presentation/connect_master_not_found_note.dart
  static const authPending = AppTranslation(
    tk: 'Garaşylýar',
    ru: 'Ожидание',
    en: 'Pending',
  );

  // features/auth/presentation/master_subscription_screen.dart
  static const authPhoneBalance = AppTranslation(
    tk: 'Telefon balansy',
    ru: 'Баланс телефона',
    en: 'Phone balance',
  );

  // features/auth/presentation/client_registration_screen.dart
  static const authRegister = AppTranslation(
    tk: 'Hasaba dur',
    ru: 'Зарегистрироваться',
    en: 'Register',
  );

  // features/auth/presentation/connect_master_not_found_note.dart
  static const authRequestSent = AppTranslation(
    tk: 'Haýyş iberildi',
    ru: 'Запрос отправлен',
    en: 'Request sent',
  );

  // features/auth/presentation/master_otp_screen.dart
  static const authResend = AppTranslation(
    tk: 'Kody täzeden iber',
    ru: 'Отправить снова',
    en: 'Resend',
  );

  // features/auth/presentation/otp_screen.dart
  static AppTranslation authResendCodeIn(Object? p0) => AppTranslation(
    tk: 'Kody täzeden ibermek: $p0',
    ru: 'Отправить код повторно: $p0',
    en: 'Resend code in $p0',
  );

  // features/auth/presentation/connect_master_flow.dart
  static const authSearchAndSendARequest = AppTranslation(
    tk: 'Gözläň we haýyş iberiň',
    ru: 'Найдите и отправьте запрос',
    en: 'Search and send a request',
  );

  // features/auth/presentation/master_phone_payment_dialog.dart
  static AppTranslation authSendItFromYourRegistered(Object? p0) =>
      AppTranslation(
        tk: 'Töleg hasaba alnan telefon belgiňizden ($p0) geçirilmeli.',
        ru: 'Перевод нужно делать с вашего номера ($p0).',
        en: 'Send it from your registered number ($p0).',
      );

  // features/auth/presentation/sms_otp_screen.dart
  static const authSendSms = AppTranslation(
    tk: 'SMS ibermek',
    ru: 'Отправить SMS',
    en: 'Send SMS',
  );

  // features/auth/presentation/sms_otp_screen.dart
  static const authSendTheCodeBelowBy = AppTranslation(
    tk: 'Aşakdaky kody SMS arkaly şu belgä iberiň. Tassyklanandan soň awtomatiki girersiňiz.',
    ru: 'Отправьте код ниже SMS-сообщением на этот номер. После проверки вход произойдёт сам.',
    en: 'Send the code below by SMS to this number. You will be signed in automatically.',
  );

  // features/auth/presentation/sms_otp_screen.dart
  static const authSendTo = AppTranslation(
    tk: 'Şu belgä iberiň',
    ru: 'Отправить на номер',
    en: 'Send to',
  );

  // features/auth/presentation/master_phone_payment_dialog_notes_list.dart
  static AppTranslation authSendToThisNumberIn(
    Object? p0,
    Object? p1,
    Object? p2,
    Object? p3,
  ) => AppTranslation(
    tk: 'Bu belgä bir geçirimde $p0 $p1 iberiň (iň az $p2 $p1). SMS programmasy açyldy: "$p3" belgisine ugradyň.',
    ru: 'Переведите на этот номер $p0 $p1 одним переводом (минимум $p2 $p1). Откроется SMS на номер "$p3" — отправьте его.',
    en: 'Send $p0 $p1 to this number in a single transfer (minimum $p2 $p1). The SMS to "$p3" opens pre-filled — just send it.',
  );

  // features/auth/presentation/master_registration_screen.dart
  static const authSending = AppTranslation(
    tk: 'Iberilýär...',
    ru: 'Отправка...',
    en: 'Sending...',
  );

  // features/auth/presentation/master_subscription_top_up_balance_summary.dart
  static const authSetYourHoursAndDays = AppTranslation(
    tk: 'Iş wagtyňyzy we dynç günlerini sazlaň',
    ru: 'Настраивайте график и выходные',
    en: 'Set your hours and days off',
  );

  // features/auth/presentation/master_registration_form_widgets.dart
  static const authShownAtTheTopOf = AppTranslation(
    tk: 'Profiliňiziň ýokarsynda görner',
    ru: 'Отображается вверху профиля',
    en: 'Shown at the top of your profile',
  );

  // features/auth/presentation/client_registration_widgets.dart
  static const authSignInWithThisNumber = AppTranslation(
    tk: 'Şu belgi bilen giriş',
    ru: 'Войти по этому номеру',
    en: 'Sign in with this number',
  );

  // features/auth/presentation/master_subscription_top_up_balance_summary.dart
  static const authSubscriptionActive = AppTranslation(
    tk: 'Abuna işjeň',
    ru: 'Подписка активна',
    en: 'Subscription active',
  );

  // features/auth/presentation/master_subscription_top_up_balance_summary.dart
  static const authSubscriptionInactive = AppTranslation(
    tk: 'Abuna işjeň däl',
    ru: 'Подписка не активна',
    en: 'Subscription inactive',
  );

  // features/auth/presentation/master_subscription_screen.dart
  static const authSubscriptionPayment = AppTranslation(
    tk: 'ABUNA WE TÖLEG',
    ru: 'ПОДПИСКА И ОПЛАТА',
    en: 'SUBSCRIPTION & PAYMENT',
  );

  // features/auth/presentation/master_registration_form_widgets.dart
  static const authTapToChangeThePhoto = AppTranslation(
    tk: 'Suraty üýtgetmek üçin basyň',
    ru: 'Нажмите, чтобы изменить фото',
    en: 'Tap to change the photo',
  );

  // features/auth/presentation/master_subscription_screen.dart
  static const authTheAmountGoesToYour = AppTranslation(
    tk: 'Töleg balansyňyza goşular. Abuna tölegi her aý awtomatiki tutular.',
    ru: 'Сумма зачисляется на баланс, подписка списывается ежемесячно.',
    en: 'The amount goes to your balance; the subscription is charged monthly.',
  );

  // features/auth/presentation/sms_otp_screen.dart
  static const authTheCodeHasExpired = AppTranslation(
    tk: 'Koduň möhleti gutardy',
    ru: 'Срок действия кода истёк',
    en: 'The code has expired',
  );

  // features/auth/presentation/connect_master_flow.dart
  static const authTheMasterAddsYouTo = AppTranslation(
    tk: 'Master sizi öz müşderileriniň hataryna goşar.',
    ru: 'Мастер добавит вас в свои клиенты.',
    en: 'The master adds you to their clients.',
  );

  // features/auth/presentation/master_registration_screen.dart
  static const authThisIsHowClientsWill = AppTranslation(
    tk: 'Müşderiler sizi şeýle görer',
    ru: 'Так вас увидят клиенты',
    en: 'This is how clients will see you',
  );

  // features/auth/presentation/master_registration_submit.dart
  static const authThisNicknameIsTaken = AppTranslation(
    tk: 'Bu lakam eýýäm ulanylýar',
    ru: 'Этот никнейм уже занят',
    en: 'This nickname is taken',
  );

  // features/auth/presentation/client_registration_widgets.dart
  static const authThisNumberIsAlreadyRegistered = AppTranslation(
    tk: 'Bu belgi eýýäm hasaba alnypdyr',
    ru: 'Этот номер уже зарегистрирован',
    en: 'This number is already registered',
  );

  // features/auth/presentation/master_subscription_screen.dart
  static const authToPay = AppTranslation(
    tk: 'Tölenmeli',
    ru: 'К оплате',
    en: 'To pay',
  );

  // features/auth/presentation/master_subscription_screen.dart
  static const authTransferFromYourSimCard = AppTranslation(
    tk: 'SIM kartyňyzyň balansyndan geçiriň',
    ru: 'Перевод с баланса SIM-карты',
    en: 'Transfer from your SIM card balance',
  );

  // features/auth/presentation/master_subscription_top_up_balance_summary.dart
  static AppTranslation authUntil(Object? p0) =>
      AppTranslation(tk: '$p0 çenli', ru: 'до $p0', en: 'until $p0');

  // features/auth/presentation/client_registration_widgets.dart
  static const authUseAnotherNumber = AppTranslation(
    tk: 'Başga belgi ulan',
    ru: 'Другой номер',
    en: 'Use another number',
  );

  // features/auth/presentation/master_otp_screen.dart
  static const authVerification = AppTranslation(
    tk: 'TASSYKLAMA',
    ru: 'ПОДТВЕРЖДЕНИЕ',
    en: 'VERIFICATION',
  );

  // features/auth/presentation/master_otp_screen.dart
  static const authVerify = AppTranslation(
    tk: 'Tassyklaň',
    ru: 'Подтвердить',
    en: 'Verify',
  );

  // features/auth/presentation/otp_screen.dart
  static const authVerify2 = AppTranslation(
    tk: 'Tassykla',
    ru: 'Подтвердить',
    en: 'Verify',
  );

  // features/auth/presentation/otp_screen.dart
  static const authVerifyYourNumber = AppTranslation(
    tk: 'Belgiňizi tassyklaň',
    ru: 'Подтвердите номер',
    en: 'Verify your number',
  );

  // features/auth/presentation/master_otp_screen.dart
  static const authVerifyYourPhoneNumber = AppTranslation(
    tk: 'Telefon belgiňizi tassyklaň',
    ru: 'Подтвердите номер телефона',
    en: 'Verify your phone number',
  );

  // features/auth/presentation/master_otp_screen.dart
  static const authVerifying = AppTranslation(
    tk: 'Barlanýar...',
    ru: 'Проверка...',
    en: 'Verifying...',
  );

  // features/auth/presentation/connect_master_not_found_note.dart
  static const authWaitingForConfirmation = AppTranslation(
    tk: 'Tassyklama garaşylýar',
    ru: 'Ожидание подтверждения',
    en: 'Waiting for confirmation',
  );

  // features/auth/presentation/sms_otp_screen.dart
  static AppTranslation authWaitingForSms(Object? p0) => AppTranslation(
    tk: 'SMS garaşylýar · $p0',
    ru: 'Ждём SMS · $p0',
    en: 'Waiting for SMS · $p0',
  );

  // features/auth/presentation/master_phone_payment_dialog_notes_list.dart
  static const authWaitingForYourTransferThis = AppTranslation(
    tk: 'Töleg garaşylýar. Ýagdaý özi täzelener.',
    ru: 'Ждём перевод. Статус обновится сам.',
    en: 'Waiting for your transfer. This updates by itself.',
  );

  // features/auth/presentation/master_subscription_payment_widgets.dart
  static const authWeCouldnTCompleteThe = AppTranslation(
    tk: 'Tölegi amala aşyryp bolmady.',
    ru: 'Не удалось выполнить платёж.',
    en: 'We couldn’t complete the payment.',
  );

  // features/auth/presentation/client_registration_screen.dart
  static const authWeLlTextACode = AppTranslation(
    tk: 'Telefon belgiňize SMS kody iberiler.',
    ru: 'На ваш номер придёт SMS с кодом.',
    en: "We'll text a code to your number.",
  );

  // features/auth/presentation/master_phone_screen.dart
  static const authWeLlTextAVerification = AppTranslation(
    tk: 'Profiliňizi dolduranyňyzdan soň şu belgä tassyklama kody iberiler.',
    ru: 'После заполнения профиля на этот номер придёт код подтверждения.',
    en: "We'll text a verification code to this number once your profile is filled in.",
  );

  // features/auth/presentation/otp_screen.dart
  static const authWeSentA6Digit = AppTranslation(
    tk: '6 sanly kody şu belgä iberdik',
    ru: 'Мы отправили 6-значный код на номер',
    en: 'We sent a 6-digit code to',
  );

  // features/auth/presentation/login_screen.dart
  static const authWelcome = AppTranslation(
    tk: 'Hoş geldiňiz',
    ru: 'Добро пожаловать',
    en: 'Welcome',
  );

  // features/auth/presentation/master_phone_payment_dialog.dart
  static AppTranslation authWillBeDeductedFromYour(Object? p0, Object? p1) =>
      AppTranslation(
        tk: 'SIM kartyňyzyň balansyndan $p0 $p1 tutulýar.',
        ru: 'С баланса SIM-карты спишется $p0 $p1.',
        en: '$p0 $p1 will be deducted from your SIM card balance.',
      );

  // features/auth/presentation/connect_master_not_found_note.dart
  static AppTranslation authWillBeNotifiedAboutYour(Object? p0) =>
      AppTranslation(
        tk: '$p0 haýyşyňyz barada habarly bolar.',
        ru: '$p0 получит уведомление о вашем запросе.',
        en: '$p0 will be notified about your request.',
      );

  // features/auth/presentation/master_registration_screen.dart
  static const authWorkAddress = AppTranslation(
    tk: 'Iş salgyňyz',
    ru: 'Рабочий адрес',
    en: 'Work address',
  );

  // features/auth/presentation/master_phone_payment_dialog.dart
  static const authYouCanReachUsThrough = AppTranslation(
    tk: 'Habarlaşmak bölüminden bize ýazyp bilersiňiz.',
    ru: 'Напишите нам в разделе поддержки.',
    en: 'You can reach us through the support section.',
  );

  // features/auth/presentation/master_otp_privacy_note.dart
  static const authYourDataIsStoredSecurely = AppTranslation(
    tk: 'Siziň maglumatlaryňyz ygtybarly saklanýar we üçünji taraplar bilen paýlaşylmaýar.',
    ru: 'Ваши данные хранятся надёжно и не передаются третьим лицам.',
    en: 'Your data is stored securely and never shared with third parties.',
  );

  // features/auth/presentation/master_subscription_payment_widgets.dart
  static const authYourFreeMonthHasEnded = AppTranslation(
    tk: 'Mugt aý gutardy. Onlaýn ýazgylary dowam etmek üçin balansyňyzy dolduryň.',
    ru: 'Бесплатный месяц закончился. Пополните баланс, чтобы продолжить онлайн-запись.',
    en: 'Your free month has ended. Top up your balance to keep online booking open.',
  );

  // features/auth/presentation/master_registration_screen.dart
  static const authYourName = AppTranslation(
    tk: 'Adyňyz',
    ru: 'Имя',
    en: 'Your name',
  );

  // features/auth/presentation/client_registration_screen.dart
  static const authYourName2 = AppTranslation(
    tk: 'Adyňyz',
    ru: 'Ваше имя',
    en: 'Your name',
  );

  // features/auth/presentation/master_subscription_payment_widgets.dart
  static const authYourPaymentIsBeingVerified = AppTranslation(
    tk: 'Tölegiňiz barlanýar, biraz wagt alyp biler.',
    ru: 'Ваш платёж проверяется, это может занять некоторое время.',
    en: 'Your payment is being verified — this may take a moment.',
  );

  // features/auth/presentation/master_phone_payment_dialog.dart
  static AppTranslation authYourTransferArrivedButA(
    Object? p0,
    Object? p1,
  ) => AppTranslation(
    tk: 'Tölegiňiz gelip ýetdi, emma bir geçirimde iň az $p0 $p1 bolmaly. Balansa goşulmady.',
    ru: 'Перевод пришёл, но один перевод должен быть не меньше $p0 $p1. На баланс он не зачислен.',
    en: 'Your transfer arrived, but a single transfer must be at least $p0 $p1. It was not added to your balance.',
  );

  // features/billing/presentation/billing_history_screen.dart
  static const billingBalance = AppTranslation(
    tk: "Balans",
    ru: "Баланс",
    en: "Balance",
  );

  // features/billing/presentation/billing_history_screen.dart
  static const billingBalanceTopUp = AppTranslation(
    tk: 'Balans doldurmak',
    ru: 'Пополнение баланса',
    en: 'Balance top-up',
  );

  // features/billing/presentation/billing_history_screen.dart
  static const billingFailed = AppTranslation(
    tk: 'Şowsuz',
    ru: 'Не удалось',
    en: 'Failed',
  );

  // features/billing/presentation/billing_history_screen.dart
  static const billingLoading = AppTranslation(
    tk: 'Ýüklenýär...',
    ru: 'Загрузка...',
    en: 'Loading...',
  );

  // features/billing/presentation/billing_history_screen.dart
  static const billingNoPaymentHistory = AppTranslation(
    tk: 'Entek töleg ýok',
    ru: 'История платежей пуста',
    en: 'No payment history',
  );

  // features/billing/presentation/billing_history_screen.dart
  static const billingOnceYouMakeAPayment = AppTranslation(
    tk: 'Töleg edeniňizden soň, ol şu ýerde görüner.',
    ru: 'После оплаты она появится здесь.',
    en: 'Once you make a payment, it will appear here.',
  );

  // features/billing/presentation/billing_history_screen.dart
  static const billingPaymentHistory = AppTranslation(
    tk: 'Töleg taryhy',
    ru: 'История платежей',
    en: 'Payment history',
  );

  // features/billing/presentation/billing_history_screen.dart
  static const billingPending = AppTranslation(
    tk: 'Garaşylýar',
    ru: 'В обработке',
    en: 'Pending',
  );

  // features/billing/presentation/billing_history_screen.dart
  static const billingRefund = AppTranslation(
    tk: 'Yzyna gaýtarylan töleg',
    ru: 'Возврат',
    en: 'Refund',
  );

  // features/billing/presentation/billing_history_screen.dart
  static const billingShowMore = AppTranslation(
    tk: 'Köpräk görkez',
    ru: 'Показать ещё',
    en: 'Show more',
  );

  // features/billing/presentation/billing_history_screen.dart
  static const billingSubscriptionPayment = AppTranslation(
    tk: 'Abuna tölegi',
    ru: 'Оплата подписки',
    en: 'Subscription payment',
  );

  // features/billing/presentation/billing_history_screen.dart
  static const billingSuccessful = AppTranslation(
    tk: 'Üstünlikli',
    ru: 'Успешно',
    en: 'Successful',
  );

  // features/booking/presentation/booking_success_screen.dart
  static const bookingAddedToCalendarReminder1 = AppTranslation(
    tk: 'Senenama goşuldy · 1 sagat öň ýatlatma',
    ru: 'Добавлено в календарь · напоминание за 1 час',
    en: 'Added to calendar · reminder 1 hour before',
  );

  // features/booking/presentation/booking_success_screen.dart
  static const bookingAddingToCalendar = AppTranslation(
    tk: 'Senenama goşulýar…',
    ru: 'Добавляем в календарь…',
    en: 'Adding to calendar…',
  );

  // features/booking/presentation/booking_datetime_screen.dart
  static const bookingAfternoon = AppTranslation(
    tk: 'Günortan soň',
    ru: 'День',
    en: 'Afternoon',
  );

  // features/booking/presentation/booking_success_screen.dart
  static const bookingBackToHome = AppTranslation(
    tk: 'Baş sahypa',
    ru: 'На главную',
    en: 'Back to home',
  );

  // features/booking/presentation/booking_success_screen.dart
  static const bookingBookingConfirmed = AppTranslation(
    tk: 'Ýazgy tassyklandy!',
    ru: 'Запись подтверждена!',
    en: 'Booking confirmed!',
  );

  // features/booking/presentation/booking_service_screen.dart
  static const bookingBookingsArePaused = AppTranslation(
    tk: 'Ýazgy wagtlaýyn ýapyk',
    ru: 'Запись временно закрыта',
    en: 'Bookings are paused',
  );

  // features/booking/presentation/booking_success_screen.dart
  static const bookingCalendarAccessIsNeeded = AppTranslation(
    tk: 'Senenama rugsady gerek',
    ru: 'Нужен доступ к календарю',
    en: 'Calendar access is needed',
  );

  // features/booking/presentation/booking_confirm_screen.dart
  static const bookingCheckTheDetailsBelow = AppTranslation(
    tk: 'Maglumatlary barlaň',
    ru: 'Проверьте детали записи',
    en: 'Check the details below',
  );

  // features/booking/presentation/booking_confirm_screen.dart
  static const bookingConfirm = AppTranslation(
    tk: 'Tassykla',
    ru: 'Подтв.',
    en: 'Confirm',
  );

  // features/booking/presentation/booking_confirm_screen.dart
  static const bookingConfirmBooking = AppTranslation(
    tk: 'Tassyklaň',
    ru: 'Подтвердите запись',
    en: 'Confirm booking',
  );

  // features/booking/presentation/booking_confirm_screen.dart
  static const bookingConfirmBooking2 = AppTranslation(
    tk: 'Ýazgyny tassykla',
    ru: 'Подтвердить запись',
    en: 'Confirm booking',
  );

  // features/booking/presentation/booking_service_screen.dart
  static const bookingContinue = AppTranslation(
    tk: 'Dowam et',
    ru: 'Далее',
    en: 'Continue',
  );

  // features/booking/presentation/booking_success_screen.dart
  static const bookingCouldNotAddToCalendar = AppTranslation(
    tk: 'Senenama goşup bolmady',
    ru: 'Не удалось добавить в календарь',
    en: 'Could not add to calendar',
  );

  // features/booking/presentation/booking_success_screen.dart
  static const bookingDate = AppTranslation(tk: 'Sene', ru: 'Дата', en: 'Date');

  // features/booking/presentation/booking_confirm_screen.dart
  static const bookingDate2 = AppTranslation(
    tk: 'Senesi',
    ru: 'Дата',
    en: 'Date',
  );

  // features/booking/presentation/booking_datetime_screen.dart
  static const bookingEvening = AppTranslation(
    tk: 'Agşam',
    ru: 'Вечер',
    en: 'Evening',
  );

  // features/booking/presentation/booking_success_screen.dart
  static const bookingGoToMyBookings = AppTranslation(
    tk: 'Ýazgylaryma git',
    ru: 'К моим записям',
    en: 'Go to my bookings',
  );

  // features/booking/presentation/booking_success_screen.dart
  static const bookingMin = AppTranslation(tk: "min", ru: "мин", en: "min");

  // features/booking/presentation/booking_service_screen.dart
  static const bookingMin2 = AppTranslation(tk: 'min', ru: 'мин', en: 'min');

  // features/booking/presentation/booking_datetime_screen.dart
  static const bookingMorning = AppTranslation(
    tk: 'Irden',
    ru: 'Утро',
    en: 'Morning',
  );

  // features/booking/presentation/booking_confirm_screen.dart
  static const bookingNearestFreeTimes = AppTranslation(
    tk: 'Ýakyn boş wagtlar:',
    ru: 'Ближайшее свободное время:',
    en: 'Nearest free times:',
  );

  // features/booking/presentation/booking_datetime_screen.dart
  static const bookingNoFreeSlots = AppTranslation(
    tk: 'Boş wagt ýok',
    ru: 'Свободного времени нет',
    en: 'No free slots',
  );

  // features/booking/presentation/booking_service_screen.dart
  static const bookingNoServices = AppTranslation(
    tk: 'Hyzmat ýok',
    ru: 'Услуг нет',
    en: 'No services',
  );

  // features/booking/presentation/booking_confirm_screen.dart
  static const bookingNote = AppTranslation(
    tk: 'Bellik',
    ru: 'Заметка',
    en: 'Note',
  );

  // features/booking/presentation/booking_confirm_screen.dart
  static const bookingNoteForTheMasterOptional = AppTranslation(
    tk: 'Master üçin bellik (hökmany däl)',
    ru: 'Заметка для мастера (необязательно)',
    en: 'Note for the master (optional)',
  );

  // features/booking/presentation/booking_confirm_screen.dart
  static const bookingNotifyMeIfAnEarlier = AppTranslation(
    tk: 'Has irki wagt açylsa, maňa habar ber',
    ru: 'Сообщить, если освободится более раннее время',
    en: 'Notify me if an earlier slot opens up',
  );

  // features/booking/presentation/booking_datetime_screen.dart
  static const bookingPickADateTime = AppTranslation(
    tk: 'Sene we wagt saýlaň',
    ru: 'Выберите дату и время',
    en: 'Pick a date & time',
  );

  // features/booking/presentation/booking_service_screen.dart
  static const bookingPickAService = AppTranslation(
    tk: 'Hyzmat saýlaň',
    ru: 'Выберите услугу',
    en: 'Pick a service',
  );

  // features/booking/presentation/booking_success_screen.dart
  static const bookingRetry = AppTranslation(
    tk: 'Täzeden synanyş',
    ru: 'Повторить',
    en: 'Retry',
  );

  // features/booking/presentation/booking_service_screen.dart
  static const bookingSelectAService = AppTranslation(
    tk: 'Hyzmaty saýlaň',
    ru: 'Выберите услугу',
    en: 'Select a service',
  );

  // features/booking/presentation/booking_datetime_screen.dart
  static const bookingSelectedTime = AppTranslation(
    tk: 'Saýlanan wagt',
    ru: 'Выбранное время',
    en: 'Selected time',
  );

  // features/booking/presentation/booking_confirm_screen.dart
  static const bookingService = AppTranslation(
    tk: 'Hyzmat',
    ru: 'Услуга',
    en: 'Service',
  );

  // features/booking/presentation/booking_service_screen.dart
  static AppTranslation bookingServicesAvailable(Object? p0) => AppTranslation(
    tk: '$p0 hyzmat elýeterli',
    ru: 'Доступно услуг: $p0',
    en: '$p0 services available',
  );

  // features/booking/presentation/booking_datetime_screen.dart
  static const bookingThereIsNoFreeTime = AppTranslation(
    tk: 'Bu gün üçin boş wagt ýok. Başga gün synanyşyň.',
    ru: 'На этот день свободного времени нет. Попробуйте другой день.',
    en: 'There is no free time on this day. Try another day.',
  );

  // features/booking/presentation/booking_service_screen.dart
  static const bookingThisMasterHasnTAdded = AppTranslation(
    tk: 'Bu master heniz hyzmat goşmady.',
    ru: 'Мастер пока не добавил услуги.',
    en: 'This master hasn’t added any services yet.',
  );

  // features/booking/presentation/booking_service_screen.dart
  static const bookingThisMasterIsNotAccepting = AppTranslation(
    tk: 'Master häzirlikçe täze ýazgylary kabul etmeýär.',
    ru: 'Мастер временно не принимает новые записи.',
    en: 'This master is not accepting new bookings right now.',
  );

  // features/booking/presentation/booking_success_screen.dart
  static const bookingTime = AppTranslation(
    tk: 'Wagt',
    ru: 'Время',
    en: 'Time',
  );

  // features/booking/presentation/booking_confirm_screen.dart
  static const bookingTime2 = AppTranslation(
    tk: 'Wagt',
    ru: 'Время',
    en: 'Time',
  );

  // features/booking/presentation/booking_confirm_screen.dart
  static const bookingTime3 = AppTranslation(
    tk: 'Barmaly wagtyňyz',
    ru: 'Время',
    en: 'Time',
  );

  // features/booking/presentation/booking_confirm_screen.dart
  static const bookingTotal = AppTranslation(
    tk: 'Jemi',
    ru: 'Итого',
    en: 'Total',
  );

  // features/booking/presentation/booking_success_screen.dart
  static const bookingYourMasterHasBeenNotified = AppTranslation(
    tk: 'Mastere habar berildi.',
    ru: 'Мастер получил уведомление.',
    en: 'Your master has been notified.',
  );

  // features/cabinet/presentation/cabinet_profile_screen.dart
  static const cabinet320CharsLowercaseLetters = AppTranslation(
    tk: '3–20 nyşan: kiçi harp, san we _',
    ru: '3-20 символов: строчные буквы, цифры и _',
    en: '3-20 chars: lowercase letters, numbers and _',
  );

  // features/cabinet/presentation/cabinet_profile_preview.dart
  static const cabinetAbout = AppTranslation(
    tk: 'Hakynda',
    ru: 'О себе',
    en: 'About',
  );

  // features/cabinet/presentation/cabinet_profile_screen.dart
  static const cabinetAboutYou = AppTranslation(
    tk: 'Özüňiz barada',
    ru: 'О себе',
    en: 'About you',
  );

  // features/cabinet/presentation/cabinet_billing_subscription_status_chip.dart
  static const cabinetActive = AppTranslation(
    tk: 'Işjeň',
    ru: 'Активна',
    en: 'Active',
  );

  // features/cabinet/presentation/cabinet_profile_screen.dart
  static const cabinetAddBanner = AppTranslation(
    tk: 'Banner goş',
    ru: 'Добавить баннер',
    en: 'Add banner',
  );

  // features/cabinet/presentation/cabinet_special_days_screen.dart
  static const cabinetAddDay = AppTranslation(
    tk: 'Gün goş',
    ru: 'Добавить день',
    en: 'Add day',
  );

  // features/cabinet/presentation/cabinet_special_days_screen.dart
  static const cabinetAddSpecialHours = AppTranslation(
    tk: 'Aýratyn iş wagty goş',
    ru: 'Добавить особые часы',
    en: 'Add special hours',
  );

  // features/cabinet/presentation/cabinet_vacation_state.dart
  static const cabinetAddVacation = AppTranslation(
    tk: 'Dynç alyş goş',
    ru: 'Добавить отпуск',
    en: 'Add vacation',
  );

  // features/cabinet/presentation/cabinet_vacation_state.dart
  static const cabinetAddedPeriods = AppTranslation(
    tk: 'Goşulan döwürler',
    ru: 'Добавленные периоды',
    en: 'Added periods',
  );

  // features/cabinet/presentation/cabinet_working_break_settings.dart
  static const cabinetAdditionalSettings = AppTranslation(
    tk: 'Goşmaça sazlamalar',
    ru: 'Дополнительные настройки',
    en: 'Additional settings',
  );

  // features/cabinet/presentation/cabinet_profile_screen.dart
  static const cabinetAddress = AppTranslation(
    tk: 'Salgysy',
    ru: 'Адрес',
    en: 'Address',
  );

  // features/cabinet/presentation/cabinet_profile_screen.dart
  static const cabinetAddressBio = AppTranslation(
    tk: 'Salgy we beýan',
    ru: 'Адрес и описание',
    en: 'Address & bio',
  );

  // features/cabinet/presentation/cabinet_working_hours_screen.dart
  static const cabinetApplyToAll = AppTranslation(
    tk: 'Hemme güne ulan',
    ru: 'Применить ко всем',
    en: 'Apply to all',
  );

  // features/cabinet/presentation/cabinet_client_notify_screen.dart
  static const cabinetAutomaticReminders = AppTranslation(
    tk: 'Awtomatiki ýatlatmalar',
    ru: 'Автоматические напоминания',
    en: 'Automatic reminders',
  );

  // features/cabinet/presentation/cabinet_home_master_card.dart
  static const cabinetBalance = AppTranslation(
    tk: 'Balans',
    ru: 'Баланс',
    en: 'Balance',
  );

  // features/cabinet/presentation/cabinet_profile_screen.dart
  static const cabinetBasics = AppTranslation(
    tk: 'Esasy maglumatlar',
    ru: 'Основное',
    en: 'Basics',
  );

  // features/cabinet/presentation/cabinet_home_screen.dart
  static const cabinetBillingSubscription = AppTranslation(
    tk: 'Töleg we Abuna',
    ru: 'Оплата и подписка',
    en: 'Billing & subscription',
  );

  // features/cabinet/presentation/cabinet_client_notify_screen.dart
  static const cabinetBookingRemindersAreSentTo = AppTranslation(
    tk: 'Ýazgy ýatlatmalary müşderilere ulgam tarapyndan awtomatiki iberilýär.',
    ru: 'Напоминания о записи отправляются клиентам автоматически.',
    en: 'Booking reminders are sent to clients automatically.',
  );

  // features/cabinet/presentation/cabinet_special_days_screen.dart
  static const cabinetBookingsAreNotAcceptedOn = AppTranslation(
    tk: 'Bu günlerde hyzmat kabul edilmez. Islendik senäni goşup ýa-da aýryp bilersiňiz.',
    ru: 'В эти дни запись недоступна. Добавляйте или удаляйте любые даты.',
    en: 'Bookings are not accepted on these days. You can add or remove any date.',
  );

  // features/cabinet/presentation/cabinet_working_break_settings.dart
  static const cabinetBreakTime = AppTranslation(
    tk: 'Arakesme wagty',
    ru: 'Время перерыва',
    en: 'Break time',
  );

  // features/cabinet/presentation/cabinet_home_screen.dart
  static const cabinetCabinet = AppTranslation(
    tk: 'KABINET',
    ru: 'КАБИНЕТ',
    en: 'CABINET',
  );

  // features/cabinet/presentation/cabinet_send_message_audience_actions.dart
  static const cabinetCancel = AppTranslation(
    tk: 'Ýok',
    ru: 'Отмена',
    en: 'Cancel',
  );

  // features/cabinet/presentation/cabinet_profile_screen.dart
  static const cabinetChangeBanner = AppTranslation(
    tk: 'Banneri üýtget',
    ru: 'Изменить баннер',
    en: 'Change banner',
  );

  // features/cabinet/presentation/cabinet_recent_clients_screen.dart
  static const cabinetChooseAPeriod = AppTranslation(
    tk: 'Döwrüni saýlaň',
    ru: 'Выберите период',
    en: 'Choose a period',
  );

  // features/cabinet/presentation/cabinet_client_notify_screen.dart
  static const cabinetChooseClientsAndSendA = AppTranslation(
    tk: 'Müşderileri saýlap, olara push habar ýa-da SMS iberiň.',
    ru: 'Выберите клиентов и отправьте push-уведомление или SMS.',
    en: 'Choose clients and send a push notification or SMS.',
  );

  // features/cabinet/presentation/cabinet_selected_clients_screen.dart
  static const cabinetChooseClientsToSendTo = AppTranslation(
    tk: 'Habar ibermek üçin müşderileri saýlaň. Soňra habar tekstini ýazyň we iberiň.',
    ru: 'Выберите клиентов для отправки. Затем напишите текст сообщения и отправьте.',
    en: 'Choose clients to send to. Then write the message text and send it.',
  );

  // features/cabinet/presentation/cabinet_send_message_audience_actions.dart
  static const cabinetChooseClientsToSendTo2 = AppTranslation(
    tk: 'Müşderileri saýlap iberiň.',
    ru: 'Выберите клиентов для отправки.',
    en: 'Choose clients to send to.',
  );

  // features/cabinet/presentation/cabinet_send_message_screen.dart
  static const cabinetChooseUpTo50Clients = AppTranslation(
    tk: 'Bir gezekde iň köp 50 müşderini saýlaň.',
    ru: 'Выберите не более 50 клиентов за раз.',
    en: 'Choose up to 50 clients at a time.',
  );

  // features/cabinet/presentation/cabinet_home_screen.dart
  static const cabinetClientMessages = AppTranslation(
    tk: 'Müşderilere habar',
    ru: 'Сообщения клиентам',
    en: 'Client messages',
  );

  // features/cabinet/presentation/cabinet_send_message_screen.dart
  static const cabinetClientsAreListedButTheir = AppTranslation(
    tk: 'Müşderiler bar, ýöne push alyjynyň hasaby kesgitlenmedi. SMS saýlap bilersiňiz.',
    ru: 'Клиенты есть, но аккаунт получателя для push не определён. Можно выбрать SMS.',
    en: 'Clients are listed, but their push account cannot be identified. You can choose SMS.',
  );

  // features/cabinet/presentation/cabinet_profile_screen.dart
  static const cabinetClientsFindYouByThis = AppTranslation(
    tk: 'Müşderiler sizi şu at bilen tapar',
    ru: 'По этому имени клиенты найдут вас',
    en: 'Clients find you by this name',
  );

  // features/cabinet/presentation/cabinet_recent_clients_screen.dart
  static AppTranslation cabinetClientsFromTheLast(Object? p0, Object? p1) =>
      AppTranslation(
        tk: 'Soňky $p0 içinde hyzmat alanlar ($p1)',
        ru: 'Клиенты за последние $p0 ($p1)',
        en: 'Clients from the last $p0 ($p1)',
      );

  // features/cabinet/presentation/cabinet_send_message_audience_actions.dart
  static AppTranslation cabinetClientsSelected(Object? p0) => AppTranslation(
    tk: '$p0 müşderi saýlandy.',
    ru: 'Выбрано клиентов: $p0.',
    en: '$p0 clients selected.',
  );

  // features/cabinet/presentation/cabinet_send_message_audience_actions.dart
  static const cabinetClientsWithinASpecificTime = AppTranslation(
    tk: 'Belli bir wagtyň içinde ýazylan müşderiler.',
    ru: 'Клиенты за определённый период.',
    en: 'Clients within a specific time period.',
  );

  // features/cabinet/presentation/cabinet_vacation_state.dart
  static const cabinetCloseAnyway = AppTranslation(
    tk: 'Ýene-de ýap',
    ru: 'Всё равно закрыть',
    en: 'Close anyway',
  );

  // features/cabinet/presentation/cabinet_send_message_audience_actions.dart
  static const cabinetConfirmSending = AppTranslation(
    tk: 'Habary tassyklaň',
    ru: 'Подтвердите отправку',
    en: 'Confirm sending',
  );

  // features/cabinet/presentation/cabinet_support_screen.dart
  static const cabinetContactDetailsAreNotAvailable = AppTranslation(
    tk: 'Aragatnaşyk maglumatlary häzir elýeterli däl.',
    ru: 'Контактные данные сейчас недоступны.',
    en: 'Contact details are not available right now.',
  );

  // features/cabinet/presentation/cabinet_support_screen.dart
  static const cabinetContactSupport = AppTranslation(
    tk: 'Goldaw bilen habarlaş',
    ru: 'Связаться с поддержкой',
    en: 'Contact support',
  );

  // features/cabinet/presentation/cabinet_selected_clients_screen.dart
  static const cabinetContinue = AppTranslation(
    tk: "Dowam et",
    ru: "Продолжить",
    en: "Continue",
  );

  // features/cabinet/presentation/cabinet_billing_screen.dart
  static const cabinetCouldNotLoadBillingDetails = AppTranslation(
    tk: 'Töleg maglumatlaryny ýükläp bolmady.',
    ru: 'Не удалось загрузить данные об оплате.',
    en: 'Could not load billing details.',
  );

  // features/cabinet/presentation/cabinet_selected_clients_screen.dart
  static const cabinetCouldNotLoadClients = AppTranslation(
    tk: 'Müşderileri ýükläp bolmady',
    ru: 'Не удалось загрузить клиентов',
    en: 'Could not load clients',
  );

  // features/cabinet/presentation/cabinet_working_load_card.dart
  static const cabinetCouldNotLoadWorkingHours = AppTranslation(
    tk: 'Iş wagtyny ýükläp bolmady.',
    ru: 'Не удалось загрузить график.',
    en: 'Could not load working hours.',
  );

  // features/cabinet/presentation/cabinet_send_message_audience_actions.dart
  static const cabinetCouldNotSendTheSms = AppTranslation(
    tk: 'SMS iberilip bilmedi.',
    ru: 'Не удалось отправить SMS.',
    en: 'Could not send the SMS.',
  );

  // features/cabinet/presentation/cabinet_billing_screen.dart
  static const cabinetCurrentBalance = AppTranslation(
    tk: 'Häzirki balans',
    ru: 'Текущий баланс',
    en: 'Current balance',
  );

  // features/cabinet/presentation/cabinet_working_day_rows.dart
  static const cabinetDayOff = AppTranslation(
    tk: 'Dynç güni',
    ru: 'Выходной',
    en: 'Day off',
  );

  // features/cabinet/presentation/cabinet_working_hours_screen.dart
  static const cabinetDays = AppTranslation(tk: "gün", ru: "дн.", en: "days");

  // features/cabinet/presentation/cabinet_home_subscription_card.dart
  static AppTranslation cabinetDaysLeft(Object? p0) => AppTranslation(
    tk: '$p0 gün galdy',
    ru: 'Осталось $p0 дн.',
    en: '$p0 days left',
  );

  // features/cabinet/presentation/cabinet_send_message_channels.dart
  static const cabinetDeliveryMethod = AppTranslation(
    tk: 'Iberiş usuly',
    ru: 'Способ отправки',
    en: 'Delivery method',
  );

  // features/cabinet/presentation/cabinet_shared.dart
  static const cabinetDone = AppTranslation(
    tk: 'Bolýar',
    ru: 'Готово',
    en: 'Done',
  );

  // features/cabinet/presentation/cabinet_special_days_screen.dart
  static const cabinetDone2 = AppTranslation(
    tk: 'Taýýar',
    ru: 'Готово',
    en: 'Done',
  );

  // features/cabinet/presentation/cabinet_vacation_state.dart
  static const cabinetDuringThisTimeYouWill = AppTranslation(
    tk: 'Bu döwürde ýazgy kabul etmersiňiz. Müşderiler bu günlere ýazylyp bilmezler.',
    ru: 'В это время вы не принимаете заявки. Клиенты не смогут записаться на эти дни.',
    en: 'During this time you will not accept bookings. Clients will not be able to book these days.',
  );

  // features/cabinet/presentation/cabinet_shared.dart
  static const cabinetEnd = AppTranslation(
    tk: 'Tamamlanyş',
    ru: 'Конец',
    en: 'End',
  );

  // features/cabinet/presentation/cabinet_vacation_state.dart
  static const cabinetEndDate = AppTranslation(
    tk: 'Gutarýan senesi',
    ru: 'Дата окончания',
    en: 'End date',
  );

  // features/cabinet/presentation/cabinet_shared.dart
  static const cabinetEndTime = AppTranslation(
    tk: 'Tamamlanyş wagty',
    ru: 'Время окончания',
    en: 'End time',
  );

  // features/cabinet/presentation/cabinet_shared.dart
  static const cabinetEndTimeMustBeAfter = AppTranslation(
    tk: 'Tamamlanyş wagty başlangyçdan soň bolmaly',
    ru: 'Время окончания должно быть позже начала',
    en: 'End time must be after the start time',
  );

  // features/cabinet/presentation/cabinet_support_screen.dart
  static const cabinetFindAnAnswerOrReach = AppTranslation(
    tk: 'Soragyňyza jogap tapyň ýa-da elýeterli usul bilen bize ýüz tutuň.',
    ru: 'Найдите ответ на вопрос или свяжитесь с нами удобным способом.',
    en: 'Find an answer or reach us using an available contact method.',
  );

  // features/cabinet/presentation/cabinet_billing_subscription_status_chip.dart
  static const cabinetFreeMonth = AppTranslation(
    tk: 'Mugt aý',
    ru: 'Бесплатный месяц',
    en: 'Free month',
  );

  // features/cabinet/presentation/cabinet_billing_subscription_status_chip.dart
  static const cabinetFreeMonthAvailable = AppTranslation(
    tk: 'Mugt aý bar',
    ru: 'Месяц доступен',
    en: 'Free month available',
  );

  // features/cabinet/presentation/cabinet_home_subscription_card.dart
  static const cabinetFreePeriod = AppTranslation(
    tk: 'Mugt döwür',
    ru: 'Бесплатный период',
    en: 'Free period',
  );

  // features/cabinet/presentation/cabinet_support_screen.dart
  static const cabinetFrequentlyAskedQuestions = AppTranslation(
    tk: 'Köp soralýan soraglar',
    ru: 'Частые вопросы',
    en: 'Frequently asked questions',
  );

  // features/cabinet/presentation/cabinet_billing_subscription_status_chip.dart
  static const cabinetGracePeriod = AppTranslation(
    tk: 'Goşmaça möhlet',
    ru: 'Льготный период',
    en: 'Grace period',
  );

  // features/cabinet/presentation/cabinet_profile_screen.dart
  static const cabinetHandle = AppTranslation(
    tk: 'lakamyňyz',
    ru: 'ник',
    en: 'handle',
  );

  // features/cabinet/presentation/cabinet_support_screen.dart
  static const cabinetHowCanWeHelp = AppTranslation(
    tk: 'Size nädip kömek edip bileris?',
    ru: 'Чем мы можем помочь?',
    en: 'How can we help?',
  );

  // features/cabinet/presentation/cabinet_send_message_audience_actions.dart
  static AppTranslation cabinetInboxPushConfirmedFailedSkipped(
    Object? p0,
    Object? p1,
    Object? p2,
    Object? p3,
  ) => AppTranslation(
    tk: 'Gelen habarlar: $p0, push tassyklandy: $p1, şowsuz: $p2, geçildi: $p3.',
    ru: 'Входящие: $p0, push подтверждено: $p1, не доставлено: $p2, пропущено: $p3.',
    en: 'Inbox: $p0, push confirmed: $p1, failed: $p2, skipped: $p3.',
  );

  // features/cabinet/presentation/cabinet_selected_clients_screen.dart
  static const cabinetLastVisit = AppTranslation(
    tk: "Soňky gezek",
    ru: "Последний визит",
    en: "Last visit",
  );

  // features/cabinet/presentation/cabinet_recent_clients_screen.dart
  static const cabinetLastVisit2 = AppTranslation(
    tk: "Soňky sapar",
    ru: "Последний визит",
    en: "Last visit",
  );

  // features/cabinet/presentation/cabinet_working_load_card.dart
  static const cabinetLoadingWorkingHours = AppTranslation(
    tk: 'Iş wagty ýüklenýär...',
    ru: 'Загружаем график...',
    en: 'Loading working hours...',
  );

  // features/cabinet/presentation/cabinet_working_hours_screen.dart
  static const cabinetMarkAdditionalDaysOrChanges = AppTranslation(
    tk: 'Goşmaça günleri ýa-da üýtgeşmeleri belläň',
    ru: 'Отметьте дополнительные дни или изменения',
    en: 'Mark additional days or changes',
  );

  // features/cabinet/presentation/cabinet_send_message_screen.dart
  static const cabinetMessageText = AppTranslation(
    tk: 'Habar teksti',
    ru: 'Текст сообщения',
    en: 'Message text',
  );

  // features/cabinet/presentation/cabinet_send_message_screen.dart
  static const cabinetMessageTitle = AppTranslation(
    tk: 'Habaryň sözbaşysy',
    ru: 'Заголовок сообщения',
    en: 'Message title',
  );

  // features/cabinet/presentation/cabinet_client_notify_screen.dart
  static const cabinetMessageYourClients = AppTranslation(
    tk: 'Müşderilere habar iberiň',
    ru: 'Напишите клиентам',
    en: 'Message your clients',
  );

  // features/cabinet/presentation/cabinet_client_notify_screen.dart
  static const cabinetMessagesToClients = AppTranslation(
    tk: 'Müşderilere habar',
    ru: 'Сообщения клиентам',
    en: 'Messages to clients',
  );

  // features/cabinet/presentation/cabinet_billing_screen.dart
  static const cabinetMo = AppTranslation(tk: "aý", ru: "мес.", en: "mo.");

  // features/cabinet/presentation/cabinet_home_master_card.dart
  static const cabinetNeedHelp = AppTranslation(
    tk: 'Kömek gerekmi?',
    ru: 'Нужна помощь?',
    en: 'Need help?',
  );

  // features/cabinet/presentation/cabinet_client_notify_screen.dart
  static const cabinetNewMessage = AppTranslation(
    tk: 'Täze habar',
    ru: 'Новое сообщение',
    en: 'New message',
  );

  // features/cabinet/presentation/cabinet_vacation_state.dart
  static const cabinetNewVacationPeriod = AppTranslation(
    tk: 'Täze dynç alyş döwri',
    ru: 'Новый период отпуска',
    en: 'New vacation period',
  );

  // features/cabinet/presentation/cabinet_billing_screen.dart
  static const cabinetNextPayment = AppTranslation(
    tk: 'Indiki töleg',
    ru: 'Следующий платёж',
    en: 'Next payment',
  );

  // features/cabinet/presentation/cabinet_profile_preview.dart
  static const cabinetNickname = AppTranslation(
    tk: 'lakam',
    ru: 'ник',
    en: 'nickname',
  );

  // features/cabinet/presentation/cabinet_profile_screen.dart
  static const cabinetNickname2 = AppTranslation(
    tk: 'Lakamyňyz',
    ru: 'Никнейм',
    en: 'Nickname',
  );

  // features/cabinet/presentation/cabinet_profile_preview.dart
  static const cabinetNoName = AppTranslation(
    tk: 'Ady ýok',
    ru: 'Без имени',
    en: 'No name',
  );

  // features/cabinet/presentation/cabinet_billing_screen.dart
  static const cabinetNoPaymentsYetTheyWill = AppTranslation(
    tk: 'Entek töleg ýok. Tölegleriňiz şu ýerde görkeziler.',
    ru: 'Платежей пока нет. Они появятся здесь.',
    en: 'No payments yet. They will appear here.',
  );

  // features/cabinet/presentation/cabinet_selected_clients_screen.dart
  static const cabinetNoPhoneNumber = AppTranslation(
    tk: 'Telefon belgisi ýok',
    ru: 'Нет номера телефона',
    en: 'No phone number',
  );

  // features/cabinet/presentation/cabinet_special_days_screen.dart
  static const cabinetNoSpecialDaysAddedYet = AppTranslation(
    tk: 'Entek aýratyn gün goşulmady.',
    ru: 'Особые дни ещё не добавлены.',
    en: 'No special days added yet.',
  );

  // features/cabinet/presentation/cabinet_working_hours_screen.dart
  static const cabinetNotSet = AppTranslation(
    tk: 'Bellenmedik',
    ru: 'Не задано',
    en: 'Not set',
  );

  // features/cabinet/presentation/cabinet_working_break_settings.dart
  static const cabinetNotSet2 = AppTranslation(
    tk: 'Goşulmady',
    ru: 'Не добавлен',
    en: 'Not set',
  );

  // features/cabinet/presentation/cabinet_send_message_audience_actions.dart
  static AppTranslation cabinetNothingWasSentUnavailableAccounts(Object? p0) =>
      AppTranslation(
        tk: 'Habar iberilmedi. Rugsat berilmedik hasaplar: $p0.',
        ru: 'Ничего не отправлено. Недоступные аккаунты: $p0.',
        en: 'Nothing was sent. Unavailable accounts: $p0.',
      );

  // features/cabinet/presentation/cabinet_working_break_settings.dart
  static const cabinetOnWorkingDays = AppTranslation(
    tk: 'Iş günlerinde',
    ru: 'В рабочие дни',
    en: 'On working days',
  );

  // features/cabinet/presentation/cabinet_profile_screen.dart
  static const cabinetOptional = AppTranslation(
    tk: 'Islege görä',
    ru: 'Необязательно',
    en: 'Optional',
  );

  // features/cabinet/presentation/cabinet_billing_screen.dart
  static const cabinetPaymentIsDueButBookings = AppTranslation(
    tk: 'Tölegiň wagty ýetdi, ýöne ýazgylar entek kabul edilýär. Tiz wagtda balansyňyzy dolduryň.',
    ru: 'Пора платить, но записи пока принимаются. Пополните баланс как можно скорее.',
    en: 'Payment is due but bookings are still open. Please top up soon.',
  );

  // features/cabinet/presentation/cabinet_working_hours_screen.dart
  static const cabinetPeriods = AppTranslation(
    tk: "döwür",
    ru: "периодов",
    en: "periods",
  );

  // features/cabinet/presentation/cabinet_send_message_channels.dart
  static const cabinetPermissionIsNeededToSend = AppTranslation(
    tk: 'SMS ibermek üçin rugsat gerek.',
    ru: 'Для отправки SMS нужно разрешение.',
    en: 'Permission is needed to send SMS.',
  );

  // features/cabinet/presentation/cabinet_profile_screen.dart
  static const cabinetPhoneNumber = AppTranslation(
    tk: 'Telefon belgiňiz',
    ru: 'Телефон',
    en: 'Phone number',
  );

  // features/cabinet/presentation/cabinet_profile_actions.dart
  static const cabinetPhoneNumberUpdatedPayFrom = AppTranslation(
    tk: 'Telefon belgisi üýtgedildi. Tölegi täze belgiden geçiriň.',
    ru: 'Номер изменён. Оплачивайте теперь с нового номера.',
    en: 'Phone number updated. Pay from the new number from now on.',
  );

  // features/cabinet/presentation/cabinet_selected_clients_screen.dart
  static const cabinetPleaseTryAgain = AppTranslation(
    tk: 'Täzeden synanyşyň.',
    ru: 'Попробуйте ещё раз.',
    en: 'Please try again.',
  );

  // features/cabinet/presentation/cabinet_profile_preview.dart
  static const cabinetPreview = AppTranslation(
    tk: 'Öňünden görnüş',
    ru: 'Предпросмотр',
    en: 'Preview',
  );

  // features/cabinet/presentation/cabinet_profile_screen.dart
  static const cabinetPreview2 = AppTranslation(
    tk: 'Öňünden gör',
    ru: 'Просмотр',
    en: 'Preview',
  );

  // features/cabinet/presentation/cabinet_send_message_channels.dart
  static const cabinetPushNotification = AppTranslation(
    tk: 'Push habar',
    ru: 'Push-уведомление',
    en: 'Push notification',
  );

  // features/cabinet/presentation/cabinet_selected_clients_screen.dart
  static const cabinetPushUnavailable = AppTranslation(
    tk: 'Push üçin elýeterli däl',
    ru: 'Push недоступен',
    en: 'Push unavailable',
  );

  // features/cabinet/presentation/cabinet_recent_clients_screen.dart
  static const cabinetRecentClients = AppTranslation(
    tk: 'Soňky müşderiler',
    ru: 'Недавние клиенты',
    en: 'Recent clients',
  );

  // features/cabinet/presentation/cabinet_billing_screen.dart
  static const cabinetRetry = AppTranslation(
    tk: 'Gaýtadan synanyş',
    ru: 'Повторить',
    en: 'Retry',
  );

  // features/cabinet/presentation/cabinet_working_hours_screen.dart
  static const cabinetSaveChanges = AppTranslation(
    tk: 'Üýtgeşmeleri sakla',
    ru: 'Сохранить изменения',
    en: 'Save changes',
  );

  // features/cabinet/presentation/cabinet_selected_clients_screen.dart
  static const cabinetSearch = AppTranslation(
    tk: 'Gözleg',
    ru: 'Поиск',
    en: 'Search',
  );

  // features/cabinet/presentation/cabinet_selected_clients_screen.dart
  static const cabinetSelectAll = AppTranslation(
    tk: 'Ählisini saýlamak',
    ru: 'Выбрать всех',
    en: 'Select all',
  );

  // features/cabinet/presentation/cabinet_shared.dart
  static const cabinetSelectTime = AppTranslation(
    tk: 'Wagty saýlaň',
    ru: 'Выберите время',
    en: 'Select time',
  );

  // features/cabinet/presentation/cabinet_selected_clients_screen.dart
  static AppTranslation cabinetSelected(Object? p0) => AppTranslation(
    tk: 'Saýlananlar: $p0',
    ru: 'Выбрано: $p0',
    en: 'Selected: $p0',
  );

  // features/cabinet/presentation/cabinet_selected_clients_screen.dart
  static const cabinetSelectedClients = AppTranslation(
    tk: 'Saýlanan müşderiler',
    ru: 'Выбранные клиенты',
    en: 'Selected clients',
  );

  // features/cabinet/presentation/cabinet_send_message_audience_actions.dart
  static const cabinetSend = AppTranslation(
    tk: 'Iber',
    ru: 'Отправить',
    en: 'Send',
  );

  // features/cabinet/presentation/cabinet_recent_clients_screen.dart
  static const cabinetSendAMessageToClients = AppTranslation(
    tk: 'Ýakynda hyzmat alan müşderileriňize habar iberiň.',
    ru: 'Отправьте сообщение клиентам, которые недавно получали услугу.',
    en: 'Send a message to clients who recently received a service.',
  );

  // features/cabinet/presentation/cabinet_send_message_screen.dart
  static const cabinetSendMessage = AppTranslation(
    tk: 'Habar ibermek',
    ru: 'Отправить сообщение',
    en: 'Send message',
  );

  // features/cabinet/presentation/cabinet_send_message_screen.dart
  static const cabinetSendPush = AppTranslation(
    tk: 'Push iber',
    ru: 'Отправить push',
    en: 'Send push',
  );

  // features/cabinet/presentation/cabinet_client_notify_screen.dart
  static const cabinetSendPushOrSms = AppTranslation(
    tk: 'Push ýa-da SMS iber',
    ru: 'Отправить push или SMS',
    en: 'Send push or SMS',
  );

  // features/cabinet/presentation/cabinet_send_message_screen.dart
  static const cabinetSendSms = AppTranslation(
    tk: 'SMS iber',
    ru: 'Отправить SMS',
    en: 'Send SMS',
  );

  // features/cabinet/presentation/cabinet_profile_screen.dart
  static const cabinetShownAtTheTopOf = AppTranslation(
    tk: 'Profiliň ýokarsynda görner',
    ru: 'Отображается наверху профиля',
    en: 'Shown at the top of the profile',
  );

  // features/cabinet/presentation/cabinet_home_screen.dart
  static const cabinetSignOut = AppTranslation(
    tk: 'Ulgamdan çyk',
    ru: 'Выйти',
    en: 'Sign out',
  );

  // features/cabinet/presentation/cabinet_send_message_channels.dart
  static AppTranslation cabinetSmsConfirmedSent(Object? p0, Object? p1) =>
      AppTranslation(
        tk: '$p0/$p1 SMS iberilendigi tassyklandy.',
        ru: 'Подтверждено SMS: $p0 из $p1.',
        en: '$p0/$p1 SMS confirmed sent.',
      );

  // features/cabinet/presentation/cabinet_send_message_channels.dart
  static AppTranslation cabinetSmsConfirmedSentUnconfirmedCheck(
    Object? p0,
    Object? p1,
    Object? p2,
  ) => AppTranslation(
    tk: '$p0/$p1 SMS iberilendigi tassyklandy. $p2 SMS-iň netijesi näbelli; gaýtadan ibermezden öň SMS taryhyny barlaň.',
    ru: 'Подтверждено SMS: $p0 из $p1. Результат $p2 неизвестен; проверьте историю SMS перед повторной отправкой.',
    en: '$p0/$p1 SMS confirmed sent. $p2 unconfirmed; check SMS history before retrying.',
  );

  // features/cabinet/presentation/cabinet_send_message_audience_actions.dart
  static const cabinetSmsRequiresAndroidAndA = AppTranslation(
    tk: 'SMS ibermek üçin Android we müşderiniň telefon belgisi gerek.',
    ru: 'Для SMS нужен Android и номер телефона клиента.',
    en: 'SMS requires Android and a client phone number.',
  );

  // features/cabinet/presentation/cabinet_send_message_channels.dart
  static AppTranslation cabinetSmsSentTheRestFailed(Object? p0, Object? p1) =>
      AppTranslation(
        tk: '$p0/$p1 SMS iberildi, galanlaryny iberip bolmady.',
        ru: 'Отправлено SMS: $p0 из $p1; остальные не отправлены.',
        en: '$p0/$p1 SMS sent; the rest failed.',
      );

  // features/cabinet/presentation/cabinet_profile_preview.dart
  static const cabinetSocialMedia = AppTranslation(
    tk: 'Sosial ulgamlar',
    ru: 'Соцсети',
    en: 'Social media',
  );

  // features/cabinet/presentation/cabinet_working_hours_screen.dart
  static const cabinetSpecialDays = AppTranslation(
    tk: 'Aýratyn günler',
    ru: 'Особые дни',
    en: 'Special days',
  );

  // features/cabinet/presentation/cabinet_shared.dart
  static const cabinetStart = AppTranslation(
    tk: 'Başlangyç',
    ru: 'Начало',
    en: 'Start',
  );

  // features/cabinet/presentation/cabinet_vacation_state.dart
  static const cabinetStartDate = AppTranslation(
    tk: 'Başlangyç senesi',
    ru: 'Дата начала',
    en: 'Start date',
  );

  // features/cabinet/presentation/cabinet_shared.dart
  static const cabinetStartTime = AppTranslation(
    tk: 'Başlangyç wagty',
    ru: 'Время начала',
    en: 'Start time',
  );

  // features/cabinet/presentation/cabinet_home_subscription_card.dart
  static const cabinetSubscription = AppTranslation(
    tk: 'Abuna',
    ru: 'Подписка',
    en: 'Subscription',
  );

  // features/cabinet/presentation/cabinet_home_subscription_notice.dart
  static const cabinetSubscriptionIsNotActiveNew = AppTranslation(
    tk: 'Abuna işjeň däl: täze ýazgylar ýapyk. Açmak üçin balansy dolduryň.',
    ru: 'Подписка не активна: новые записи закрыты. Пополните баланс, чтобы открыть.',
    en: 'Subscription is not active: new bookings are closed. Top up to reopen.',
  );

  // features/cabinet/presentation/cabinet_billing_screen.dart
  static const cabinetSubscriptionPrice = AppTranslation(
    tk: 'Abuna bahasy',
    ru: 'Стоимость подписки',
    en: 'Subscription price',
  );

  // features/cabinet/presentation/cabinet_billing_subscription_status_chip.dart
  static const cabinetSuspended = AppTranslation(
    tk: 'Duruzylan',
    ru: 'Приостановлена',
    en: 'Suspended',
  );

  // features/cabinet/presentation/cabinet_home_subscription_card.dart
  static const cabinetTapForSubscriptionDetails = AppTranslation(
    tk: 'Abuna maglumatlary üçin basyň',
    ru: 'Нажмите для сведений о подписке',
    en: 'Tap for subscription details',
  );

  // features/cabinet/presentation/cabinet_send_message_screen.dart
  static const cabinetTheClientListIsEmpty = AppTranslation(
    tk: 'Sanawda entek müşderi ýok. Push üçin baglanan müşderi gerek.',
    ru: 'Список клиентов пуст. Для push нужен подключённый клиент.',
    en: 'The client list is empty. Push needs a connected client.',
  );

  // features/cabinet/presentation/cabinet_send_message_screen.dart
  static const cabinetTheClientListIsEmpty2 = AppTranslation(
    tk: 'Sanawda entek müşderi ýok.',
    ru: 'Список клиентов пока пуст.',
    en: 'The client list is empty.',
  );

  // features/cabinet/presentation/cabinet_home_subscription_card.dart
  static AppTranslation cabinetThenMonth(Object? p0, Object? p1) =>
      AppTranslation(
        tk: 'Soňra $p0 $p1 / aý',
        ru: 'Затем $p0 $p1 / мес.',
        en: 'Then $p0 $p1 / month',
      );

  // features/cabinet/presentation/cabinet_vacation_state.dart
  static AppTranslation cabinetThereAreBookingSFor(
    Object? p0,
    Object? p1,
  ) => AppTranslation(
    tk: '$p0 üçin $p1 ýazgy bar. Dowam etseňiz, ol ýazgylar awtomatik ýatyrylmaýar — özüňiz dolandyrmaly bolarsyňyz.',
    ru: 'На $p0 уже есть $p1 запис(ей). Продолжив, вы не отменяете их автоматически — вам нужно будет управлять ими вручную.',
    en: 'There are $p1 booking(s) for $p0. Continuing will not cancel them automatically — you will need to manage them yourself.',
  );

  // features/cabinet/presentation/cabinet_vacation_state.dart
  static const cabinetThereAreBookingsInThis = AppTranslation(
    tk: 'Bu wagtda ýazgylar bar',
    ru: 'На этот период уже есть записи',
    en: 'There are bookings in this period',
  );

  // features/cabinet/presentation/cabinet_send_message_screen.dart
  static const cabinetTheseClientsHaveNoPhone = AppTranslation(
    tk: 'Müşderileriň telefon belgisi ýok.',
    ru: 'У клиентов нет номеров телефонов.',
    en: 'These clients have no phone numbers.',
  );

  // features/cabinet/presentation/cabinet_profile_screen.dart
  static const cabinetThisNicknameIsAlreadyTaken = AppTranslation(
    tk: 'Bu lakam eýýäm ulanylýar',
    ru: 'Этот никнейм уже занят',
    en: 'This nickname is already taken',
  );

  // features/cabinet/presentation/cabinet_working_week_overview.dart
  static const cabinetThisScheduleSetsTheTimes = AppTranslation(
    tk: 'Bu tertip müşderilere görünýän boş wagtlary kesgitleýär.',
    ru: 'Этот график определяет доступное клиентам время.',
    en: 'This schedule sets the times clients can book.',
  );

  // features/cabinet/presentation/cabinet_working_hours_screen.dart
  static const cabinetTimeForAllDays = AppTranslation(
    tk: 'Ähli günler üçin wagt',
    ru: 'Время для всех дней',
    en: 'Time for all days',
  );

  // features/cabinet/presentation/cabinet_send_message_screen.dart
  static const cabinetTitle = AppTranslation(
    tk: 'Sözbaşy',
    ru: 'Заголовок',
    en: 'Title',
  );

  // features/cabinet/presentation/cabinet_send_message_audience_actions.dart
  static const cabinetToAllClients = AppTranslation(
    tk: 'ähli müşderilere',
    ru: 'всем клиентам',
    en: 'to all clients',
  );

  // features/cabinet/presentation/cabinet_send_message_audience_actions.dart
  static const cabinetToClientsFromTheRecent = AppTranslation(
    tk: 'ýakynda gelen müşderilere',
    ru: 'клиентам за период',
    en: 'to clients from the recent period',
  );

  // features/cabinet/presentation/cabinet_send_message_audience_actions.dart
  static const cabinetToSelectedClients = AppTranslation(
    tk: 'saýlanan müşderilere',
    ru: 'выбранным клиентам',
    en: 'to selected clients',
  );

  // features/cabinet/presentation/cabinet_home_master_card.dart
  static const cabinetTopUp = AppTranslation(
    tk: 'Doldur',
    ru: 'Пополнить',
    en: 'Top up',
  );

  // features/cabinet/presentation/cabinet_billing_screen.dart
  static const cabinetTopUpBalance = AppTranslation(
    tk: 'Balans doldur',
    ru: 'Пополнить баланс',
    en: 'Top up balance',
  );

  // features/cabinet/presentation/cabinet_working_hours_screen.dart
  static const cabinetVacation = AppTranslation(
    tk: 'Dynç alyş',
    ru: 'Отпуск',
    en: 'Vacation',
  );

  // features/cabinet/presentation/cabinet_vacation_state.dart
  static const cabinetVacation2 = AppTranslation(
    tk: 'Dynç alyş',
    ru: 'Отпуск',
    en: 'Vacation',
  );

  // features/cabinet/presentation/cabinet_billing_screen.dart
  static const cabinetViewAll = AppTranslation(
    tk: 'Ählisi',
    ru: 'Все',
    en: 'View all',
  );

  // features/cabinet/presentation/cabinet_vacation_state.dart
  static const cabinetViewBookings = AppTranslation(
    tk: 'Ýazgylara seret',
    ru: 'Посмотреть записи',
    en: 'View bookings',
  );

  // features/cabinet/presentation/cabinet_send_message_audience_options.dart
  static const cabinetWhoToSendTo = AppTranslation(
    tk: 'Kimlere ibermeli?',
    ru: 'Кому отправить?',
    en: 'Who to send to?',
  );

  // features/cabinet/presentation/cabinet_send_message_audience_actions.dart
  static AppTranslation cabinetWillBeSentPeopleContinue(
    Object? p0,
    Object? p1,
    Object? p2,
  ) => AppTranslation(
    tk: '$p0 $p1 iberiler · $p2 adam. Dowam etmek isleýärsiňizmi?',
    ru: '$p0 будет отправлено $p1 · $p2 чел. Продолжить?',
    en: '$p0 will be sent $p1 · $p2 people. Continue?',
  );

  // features/cabinet/presentation/cabinet_send_message_audience_actions.dart
  static AppTranslation cabinetWillBeSentToAll(Object? p0) => AppTranslation(
    tk: 'Ähli müşderilere iberiler ($p0 adam).',
    ru: 'Будет отправлено всем клиентам ($p0 чел.).',
    en: 'Will be sent to all clients ($p0 people).',
  );

  // features/cabinet/presentation/cabinet_working_day_rows.dart
  static const cabinetWorkingDay = AppTranslation(
    tk: 'Iş güni',
    ru: 'Рабочий день',
    en: 'Working day',
  );

  // features/cabinet/presentation/cabinet_working_week_overview.dart
  static const cabinetWorkingDays = AppTranslation(
    tk: 'iş güni',
    ru: 'рабочих дней',
    en: 'working days',
  );

  // features/cabinet/presentation/cabinet_working_hours_screen.dart
  static const cabinetWorkingDaysOfTheWeek = AppTranslation(
    tk: 'Hepdäniň iş günleri',
    ru: 'Рабочие дни недели',
    en: 'Working days of the week',
  );

  // features/cabinet/presentation/cabinet_working_hours_screen.dart
  static const cabinetWorkingHours = AppTranslation(
    tk: 'Iş wagty',
    ru: 'График работы',
    en: 'Working hours',
  );

  // features/cabinet/presentation/cabinet_special_days_screen.dart
  static const cabinetWorkingHoursForThatDay = AppTranslation(
    tk: 'Şol gün üçin iş wagty',
    ru: 'Часы работы в этот день',
    en: 'Working hours for that day',
  );

  // features/cabinet/presentation/cabinet_working_hours_screen.dart
  static const cabinetWorkingHoursSaved = AppTranslation(
    tk: 'Iş wagty ýatda saklandy.',
    ru: 'График сохранён.',
    en: 'Working hours saved.',
  );

  // features/cabinet/presentation/cabinet_send_message_screen.dart
  static const cabinetWriteYourMessage = AppTranslation(
    tk: 'Habaryňyzy ýazyň...',
    ru: 'Напишите сообщение...',
    en: 'Write your message...',
  );

  // features/cabinet/presentation/cabinet_recent_clients_screen.dart
  static const cabinetYouCanMessageUpTo = AppTranslation(
    tk: 'Bir gezekde 50 müşderä çenli habar iberip bilersiňiz.',
    ru: 'За раз можно отправить сообщение максимум 50 клиентам.',
    en: 'You can message up to 50 clients at a time.',
  );

  // features/cabinet/presentation/cabinet_billing_screen.dart
  static const cabinetYourSubscriptionIsActive = AppTranslation(
    tk: 'Abunaňyz işjeň.',
    ru: 'Ваша подписка активна.',
    en: 'Your subscription is active.',
  );

  // features/cabinet/presentation/cabinet_billing_screen.dart
  static const cabinetYourSubscriptionIsNotActive = AppTranslation(
    tk: 'Abuna işjeň däl. Täze ýazgylar ýapyk. Açmak üçin balansyňyzy dolduryň.',
    ru: 'Подписка не активна, новые записи закрыты. Пополните баланс, чтобы открыть их.',
    en: 'Your subscription is not active and new bookings are closed. Top up your balance to reopen them.',
  );

  // features/cabinet/presentation/cabinet_home_subscription_notice.dart
  static const cabinetYourSubscriptionPaymentIsDue = AppTranslation(
    tk: 'Tölegiň wagty ýakynlaşdy. Balansy dolduryň.',
    ru: 'Скоро нужно оплатить подписку. Пополните баланс.',
    en: 'Your subscription payment is due soon. Please top up.',
  );

  // features/cabinet/presentation/cabinet_billing_screen.dart
  static AppTranslation cabinetYourSubscriptionWillAutomaticallyRenew(
    Object? p0,
    Object? p1,
  ) => AppTranslation(
    tk: 'Siziň abunaňyz $p0 gün soň awtomatiki täzelener. Indiki töleg senesi: $p1',
    ru: 'Ваша подписка автоматически продлится через $p0 дней. Дата следующего платежа: $p1',
    en: 'Your subscription will automatically renew in $p0 days. Next payment date: $p1',
  );

  // features/cabinet/presentation/cabinet_working_week_overview.dart
  static const cabinetYourWeek = AppTranslation(
    tk: 'Hepdelik tertip',
    ru: 'Неделя',
    en: 'Your week',
  );

  // core/localization/language_provider.dart
  static const coreAlreadyHaveAnAccountLog = AppTranslation(
    tk: 'Hasabyňyz barmy? Giriň',
    ru: 'Уже есть аккаунт? Войти',
    en: 'Already have an account? Log in',
  );

  // core/localization/language_provider.dart
  static const coreBookServicesWithEase = AppTranslation(
    tk: 'Hyzmatlara aňsat ýazylyň',
    ru: 'Выбирайте нужную услугу',
    en: 'Book services with ease',
  );

  // core/localization/language_provider.dart
  static const coreChooseYourLanguage = AppTranslation(
    tk: 'Dili saýlaň',
    ru: 'Выберите язык',
    en: 'Choose your language',
  );

  // core/localization/language_provider.dart
  static const coreChooseYourRole = AppTranslation(
    tk: 'Roluňyzy saýlaň',
    ru: 'Выберите свою роль',
    en: 'Choose your role',
  );

  // core/localization/language_provider.dart
  static const coreClient = AppTranslation(
    tk: 'KLIENT',
    ru: 'КЛИЕНТ',
    en: 'CLIENT',
  );

  // core/localization/language_provider.dart
  static const coreManageYourWorkAndClients = AppTranslation(
    tk: 'Işiňizi we müşderileriňizi dolandyryň',
    ru: 'Управляйте услугами и клиентами',
    en: 'Manage your work and clients',
  );

  // core/localization/language_provider.dart
  static const coreMaster = AppTranslation(
    tk: 'MASTER',
    ru: 'МАСТЕР',
    en: 'MASTER',
  );

  // core/localization/language_provider.dart
  static const coreMessage = AppTranslation(tk: '...', ru: '...', en: '...');

  // core/localization/language_provider.dart
  static const coreServiceAppointments = AppTranslation(
    tk: 'HYZMAT ÝAZYLYŞLARY',
    ru: 'ЗАПИСЬ НА УСЛУГИ',
    en: 'SERVICE APPOINTMENTS',
  );

  // core/localization/language_provider.dart
  static const coreTapToContinue = AppTranslation(
    tk: 'Dowam etmek üçin basyň',
    ru: 'Нажмите, чтобы продолжить',
    en: 'Tap to continue',
  );

  // features/customers/presentation/customer_form_screen.dart
  static const customersANewCustomerIsAdded = AppTranslation(
    tk: 'Täze müşderi ýazgy bilen goşulýar.',
    ru: 'Новый клиент добавляется вместе с записью.',
    en: 'A new customer is added with a booking.',
  );

  // features/customers/presentation/customer_form_screen.dart
  static const customersAddANoteAboutThis = AppTranslation(
    tk: 'Müşderi barada bellik goşuň...',
    ru: 'Добавьте заметку о клиенте...',
    en: 'Add a note about this customer...',
  );

  // features/customers/presentation/new_appointment_screen.dart
  static const customersBookingCreated = AppTranslation(
    tk: 'Ýazgy döredildi',
    ru: 'Запись создана',
    en: 'Booking created',
  );

  // features/customers/presentation/customer_detail_screen.dart
  static const customersContact = AppTranslation(
    tk: 'Habarlaşmak',
    ru: 'Связаться',
    en: 'Contact',
  );

  // features/customers/presentation/customer_detail_screen.dart
  static const customersCustomerDetails = AppTranslation(
    tk: 'Müşderi maglumatlary',
    ru: 'Информация о клиенте',
    en: 'Customer details',
  );

  // features/customers/presentation/customer_form_screen.dart
  static const customersCustomerNote = AppTranslation(
    tk: 'Müşderi barada bellik',
    ru: 'Заметка о клиенте',
    en: 'Customer note',
  );

  // features/customers/presentation/customer_list_status_badge.dart
  static const customersCustomerStatus = AppTranslation(
    tk: 'Müşderi statusy',
    ru: 'Статус клиента',
    en: 'Customer status',
  );

  // features/customers/presentation/new_appointment_screen.dart
  static const customersDateAndTime = AppTranslation(
    tk: 'Sene we wagt',
    ru: 'Дата и время',
    en: 'Date and time',
  );

  // features/customers/presentation/customer_form_screen.dart
  static const customersDeleteCustomer = AppTranslation(
    tk: 'Müşderini pozmaly?',
    ru: 'Удалить клиента?',
    en: 'Delete customer?',
  );

  // features/customers/presentation/customer_form_screen.dart
  static const customersDeleteCustomer2 = AppTranslation(
    tk: 'Müşderini poz',
    ru: 'Удалить клиента',
    en: 'Delete customer',
  );

  // features/customers/presentation/customer_form_screen.dart
  static const customersEnterANameAndPhone = AppTranslation(
    tk: 'Adyny we telefon belgisini giriziň, soňra wagty saýlaň.',
    ru: 'Введите имя и телефон, затем выберите время записи.',
    en: 'Enter a name and phone number, then choose a booking time.',
  );

  // features/customers/presentation/customer_form_screen.dart
  static const customersEnterCustomerName = AppTranslation(
    tk: 'Müşderiniň adyny ýazyň',
    ru: 'Введите имя клиента',
    en: 'Enter customer name',
  );

  // features/customers/presentation/customer_form_screen.dart
  static const customersGoBackWithoutSaving = AppTranslation(
    tk: 'Saklaman yzyna dolan',
    ru: 'Вернуться без сохранения',
    en: 'Go back without saving',
  );

  // features/customers/presentation/customers_screen.dart
  static const customersInactive = AppTranslation(
    tk: 'Uzak wagt gelmedi',
    ru: 'Давно не приходили',
    en: 'Inactive',
  );

  // features/customers/presentation/customer_list_status_badge.dart
  static const customersJustGettingToKnow = AppTranslation(
    tk: 'Entek tanalmadyk müşderi',
    ru: 'Только знакомитесь',
    en: 'Just getting to know',
  );

  // features/customers/presentation/customer_detail_screen.dart
  static const customersLastService = AppTranslation(
    tk: 'Soňky hyzmat',
    ru: 'Последняя услуга',
    en: 'Last service',
  );

  // features/customers/presentation/customer_list_widgets.dart
  static const customersLastVisit = AppTranslation(
    tk: 'Soňky sapar',
    ru: 'Последний визит',
    en: 'Last visit',
  );

  // features/customers/presentation/customer_form_screen.dart
  static const customersName = AppTranslation(tk: 'Ady', ru: 'Имя', en: 'Name');

  // features/customers/presentation/customer_form_screen.dart
  static const customersNamePhoneAndPhotoCome = AppTranslation(
    tk: 'Ady, telefon belgisi we suraty müşderiniň özünden gelýär. Diňe şahsy bellik üýtgedilýär.',
    ru: 'Имя, телефон и фото берутся из профиля клиента. Изменить можно только личную заметку.',
    en: 'Name, phone and photo come from the customer profile. You can only edit your private note.',
  );

  // features/customers/presentation/customers_customer_controls.dart
  static const customersNew = AppTranslation(
    tk: 'Täze',
    ru: 'Новые',
    en: 'New',
  );

  // features/customers/presentation/customer_shared.dart
  static const customersNew2 = AppTranslation(
    tk: 'Täze',
    ru: 'Новый',
    en: 'New',
  );

  // features/customers/presentation/customer_detail_screen.dart
  static const customersNewBooking = AppTranslation(
    tk: 'Täze ýazgy etmek',
    ru: 'Новая запись',
    en: 'New booking',
  );

  // features/customers/presentation/new_appointment_screen.dart
  static const customersNewBooking2 = AppTranslation(
    tk: 'Täze ýazgy',
    ru: 'Новая запись',
    en: 'New booking',
  );

  // features/customers/presentation/customer_form_screen.dart
  static const customersNewCustomer = AppTranslation(
    tk: 'Täze müşderi',
    ru: 'Новый клиент',
    en: 'New customer',
  );

  // features/customers/presentation/customer_list_widgets.dart
  static const customersNext = AppTranslation(
    tk: 'Indiki',
    ru: 'Следующий',
    en: 'Next',
  );

  // features/customers/presentation/customer_detail_screen.dart
  static const customersNextBooking = AppTranslation(
    tk: 'Indiki ýazgy',
    ru: 'Следующая запись',
    en: 'Next booking',
  );

  // features/customers/presentation/customer_detail_screen.dart
  static const customersNoVisitsYet = AppTranslation(
    tk: 'Sapar ýok',
    ru: 'Визитов пока нет',
    en: 'No visits yet',
  );

  // features/customers/presentation/customer_detail_screen.dart
  static const customersNone = AppTranslation(tk: 'Ýok', ru: 'Нет', en: 'None');

  // features/customers/presentation/customer_form_screen.dart
  static const customersOptional = AppTranslation(
    tk: '(islege görä)',
    ru: '(необязательно)',
    en: '(optional)',
  );

  // features/customers/presentation/customer_form_screen.dart
  static const customersPhoneNumber = AppTranslation(
    tk: 'Telefon belgisi',
    ru: 'Номер телефона',
    en: 'Phone number',
  );

  // features/customers/presentation/customer_list_status_badge.dart
  static const customersPriorityClient = AppTranslation(
    tk: 'Aýratyn ünsi talap edýän müşderi',
    ru: 'Особый клиент с приоритетом',
    en: 'Priority client',
  );

  // features/customers/presentation/customer_form_screen.dart
  static const customersPrivateNote = AppTranslation(
    tk: 'Şahsy bellik',
    ru: 'Личная заметка',
    en: 'Private note',
  );

  // features/customers/presentation/customers_customer_controls.dart
  static const customersRegular = AppTranslation(
    tk: 'Hemişelik',
    ru: 'Постоянные',
    en: 'Regular',
  );

  // features/customers/presentation/customers_customer_controls.dart
  static const customersSearchCustomers = AppTranslation(
    tk: 'Müşderi gözlemek',
    ru: 'Поиск клиента',
    en: 'Search customers',
  );

  // features/customers/presentation/customer_detail_screen.dart
  static const customersThisCustomerHasNotVisited = AppTranslation(
    tk: 'Bu müşderi entek gelmedi.',
    ru: 'Клиент ещё не приходил.',
    en: 'This customer has not visited yet.',
  );

  // features/customers/presentation/new_appointment_screen.dart
  static const customersThisServiceDoesNotFit = AppTranslation(
    tk: 'Bu hyzmat saýlanan wagta sygmaýar. Başga wagt saýlaň.',
    ru: 'Услуга не помещается в выбранное время. Выберите другое время.',
    en: 'This service does not fit the selected time. Choose another time.',
  );

  // features/customers/presentation/customers_screen.dart
  static const customersTryADifferentSearchOr = AppTranslation(
    tk: 'Gözlegi ýa-da süzgüçi üýtgediň.',
    ru: 'Измените поиск или фильтр.',
    en: 'Try a different search or filter.',
  );

  // features/customers/presentation/customer_detail_screen.dart
  static const customersViewAll = AppTranslation(
    tk: 'Ählisini görmek',
    ru: 'Смотреть все',
    en: 'View all',
  );

  // features/customers/presentation/customer_detail_screen.dart
  static const customersVisitHistory = AppTranslation(
    tk: 'Sapar taryhy',
    ru: 'История визитов',
    en: 'Visit history',
  );

  // features/customers/presentation/customer_list_widgets.dart
  static const customersVisits = AppTranslation(
    tk: 'Saparlar',
    ru: 'Визитов',
    en: 'Visits',
  );

  // features/customers/presentation/customer_detail_hero.dart
  static const customersVisits2 = AppTranslation(
    tk: 'Sapar',
    ru: 'Визитов',
    en: 'Visits',
  );

  // features/customers/presentation/customer_list_status_badge.dart
  static const customersVisitsRegularly = AppTranslation(
    tk: 'Yzygiderli gelýän müşderi',
    ru: 'Приходит регулярно',
    en: 'Visits regularly',
  );

  // features/customers/presentation/customer_form_screen.dart
  static AppTranslation customersWillBeRemovedFromYour(
    Object? p0,
  ) => AppTranslation(
    tk: '"$p0" sanawdan aýrylar. Bu hereketi yzyna gaýtaryp bolmaýar.',
    ru: '«$p0» будет удалён из списка без возможности восстановления.',
    en: '"$p0" will be removed from your customer list. This cannot be undone.',
  );

  // features/home/presentation/day_timeline_screen.dart
  static const homeAFreeDay = AppTranslation(
    tk: 'Boş gün.',
    ru: 'Свободный день.',
    en: 'A free day.',
  );

  // features/home/presentation/master_profile_screen.dart
  static const homeAbout = AppTranslation(
    tk: 'Hakynda',
    ru: 'О мастере',
    en: 'About',
  );

  // features/home/presentation/home_shells.dart
  static const homeAddCustomer = AppTranslation(
    tk: 'Müşderi goşmak',
    ru: 'Добавить клиента',
    en: 'Add customer',
  );

  // features/home/presentation/client_bookings_filter_sheet.dart
  static const homeAll = AppTranslation(tk: 'Ähli', ru: 'Все', en: 'All');

  // features/home/presentation/client_home_dashboard.dart
  static const homeAllBookings = AppTranslation(
    tk: 'Ähli ýazgylar',
    ru: 'Все записи',
    en: 'All bookings',
  );

  // features/home/presentation/client_home_dashboard.dart
  static const homeAllMasters = AppTranslation(
    tk: 'Ähli masterlar',
    ru: 'Все мастера',
    en: 'All masters',
  );

  // features/home/presentation/client_bookings_filter_sheet.dart
  static const homeApply = AppTranslation(
    tk: 'Ulan',
    ru: 'Применить',
    en: 'Apply',
  );

  // features/home/presentation/day_timeline_screen.dart
  static const homeBookings = AppTranslation(
    tk: 'ÝAZGYLAR',
    ru: 'ЗАПИСИ',
    en: 'BOOKINGS',
  );

  // features/home/presentation/home_shells.dart
  static const homeBookings2 = AppTranslation(
    tk: 'Ýazgylarym',
    ru: 'Мои записи',
    en: 'Bookings',
  );

  // features/home/presentation/master_profile_screen.dart
  static const homeBookingsPaused = AppTranslation(
    tk: 'Wagtlaýyn ýapyk',
    ru: 'Запись закрыта',
    en: 'Bookings paused',
  );

  // features/home/presentation/home_shells.dart
  static const homeCabinet = AppTranslation(
    tk: 'Kabinet',
    ru: 'Кабинет',
    en: 'Cabinet',
  );

  // features/home/presentation/home_shells.dart
  static const homeCalendar = AppTranslation(
    tk: 'Senenama',
    ru: 'Календарь',
    en: 'Calendar',
  );

  // features/home/presentation/client_bookings_screen.dart
  static const homeChooseAMasterAndBook = AppTranslation(
    tk: 'Master saýlap ýazylyň.',
    ru: 'Выберите мастера и запишитесь.',
    en: 'Choose a master and book an appointment.',
  );

  // features/home/presentation/client_bookings_filter_sheet.dart
  static const homeClear = AppTranslation(
    tk: 'Arassala',
    ru: 'Сбросить',
    en: 'Clear',
  );

  // features/home/presentation/client_booking_widgets.dart
  static const homeConfirmed = AppTranslation(
    tk: 'Tassyklanan',
    ru: 'Подтверждено',
    en: 'Confirmed',
  );

  // features/home/presentation/home_dashboard_screen.dart
  static const homeConnectToTheInternetAnd = AppTranslation(
    tk: 'Internet bilen birigip, täzeden synanyşyň.',
    ru: 'Подключитесь к интернету и попробуйте ещё раз.',
    en: 'Connect to the internet and try again.',
  );

  // features/home/presentation/home_dashboard_widgets.dart
  static const homeContactUs = AppTranslation(
    tk: 'Habarlaşmak',
    ru: 'Связаться',
    en: 'Contact us',
  );

  // features/home/presentation/home_shells.dart
  static const homeCouldNotCheckPayment = AppTranslation(
    tk: 'Töleg ýagdaýyny barlap bolmady',
    ru: 'Не удалось проверить оплату',
    en: 'Could not check payment',
  );

  // features/home/presentation/home_dashboard_refresh.dart
  static const homeCouldNotRefreshDataPrevious = AppTranslation(
    tk: 'Maglumatlary täzelemek başartmady. Öňki maglumatlar görkezilýär.',
    ru: 'Не удалось обновить данные. Показаны прежние значения.',
    en: 'Could not refresh data. Previous values are shown.',
  );

  // features/home/presentation/home_dashboard_screen.dart
  static const homeCouldNotShowTodayS = AppTranslation(
    tk: 'Şu günki ýazgylary görüp bolmaýar',
    ru: 'Не удалось показать записи на сегодня',
    en: 'Could not show today’s bookings',
  );

  // features/home/presentation/home_shells.dart
  static const homeCustomers = AppTranslation(
    tk: 'Müşderiler',
    ru: 'Клиенты',
    en: 'Customers',
  );

  // features/home/presentation/home_dashboard_free_row.dart
  static const homeEdit = AppTranslation(
    tk: 'Üýtgetmek',
    ru: 'Изменить',
    en: 'Edit',
  );

  // features/home/presentation/home_dashboard_screen.dart
  static const homeEndOfWorkDay = AppTranslation(
    tk: 'iş wagtynyň ahyry',
    ru: 'конец рабочего дня',
    en: 'end of work day',
  );

  // features/home/presentation/client_bookings_filter_sheet.dart
  static const homeFilter = AppTranslation(
    tk: 'Süzgüç',
    ru: 'Фильтр',
    en: 'Filter',
  );

  // features/home/presentation/client_home_dashboard.dart
  static const homeFindAMasterByNickname = AppTranslation(
    tk: 'Masteri lakamy ýa-da telefony boýunça tap',
    ru: 'Найти мастера по никнейму или телефону',
    en: 'Find a master by nickname or phone',
  );

  // features/home/presentation/client_master_widgets.dart
  static const homeFindAMasterByNickname2 = AppTranslation(
    tk: 'Lakamy ýa-da telefon belgisi bilen masteri tapyp baglanyň.',
    ru: 'Найдите мастера по никнейму или телефону и подключитесь.',
    en: 'Find a master by nickname or phone and connect.',
  );

  // features/home/presentation/client_bookings_screen.dart
  static const homeFinishedBookingsShowUpHere = AppTranslation(
    tk: 'Tamamlanan ýazgylaryňyz şu ýerde görünýär.',
    ru: 'Здесь будут завершённые записи.',
    en: 'Finished bookings show up here.',
  );

  // features/home/presentation/home_dashboard_table_header.dart
  static const homeFree = AppTranslation(tk: 'boş', ru: 'своб.', en: 'free');

  // features/home/presentation/home_dashboard_free_row.dart
  static const homeFreeSlot = AppTranslation(
    tk: 'Boş aralyk',
    ru: 'Свободно',
    en: 'Free slot',
  );

  // features/home/presentation/home_dashboard_screen.dart
  static const homeFreeSlots = AppTranslation(
    tk: 'Boş wagtlar',
    ru: 'Свободные окна',
    en: 'Free slots',
  );

  // features/home/presentation/home_dashboard_screen.dart
  static const homeFreeSlots2 = AppTranslation(
    tk: 'boş wagt',
    ru: 'окон свободно',
    en: 'free slots',
  );

  // features/home/presentation/master_profile_screen.dart
  static const homeFrom = AppTranslation(tk: 'Başlangyç', ru: 'От', en: 'From');

  // features/home/presentation/client_home_dashboard.dart
  static const homeHello = AppTranslation(
    tk: 'Salam',
    ru: 'Привет',
    en: 'Hello',
  );

  // features/home/presentation/home_shells.dart
  static const homeHome = AppTranslation(
    tk: 'Baş sahypa',
    ru: 'Главная',
    en: 'Home',
  );

  // features/home/presentation/client_booking_widgets.dart
  static AppTranslation homeInDays(Object? p0) =>
      AppTranslation(tk: '$p0 gün soň', ru: 'через $p0 дн.', en: 'in $p0 days');

  // features/home/presentation/client_booking_widgets.dart
  static AppTranslation homeInH(Object? p0, Object? p1, Object? p2) =>
      AppTranslation(
        tk: '$p0 sag$p1 soň',
        ru: 'через $p0 ч$p2',
        en: 'in $p0 h$p1',
      );

  // features/home/presentation/client_booking_widgets.dart
  static AppTranslation homeInMin(Object? p0) =>
      AppTranslation(tk: '$p0 min soň', ru: 'через $p0 мин', en: 'in $p0 min');

  // features/home/presentation/client_booking_widgets.dart
  static const homeInProgress = AppTranslation(
    tk: 'Häzir dowam edýär',
    ru: 'Идёт сейчас',
    en: 'In progress',
  );

  // features/home/presentation/client_bookings_screen.dart
  static const homeMoreBookings = AppTranslation(
    tk: 'Has köp ýazgy',
    ru: 'Другие записи',
    en: 'More bookings',
  );

  // features/home/presentation/client_bookings_screen.dart
  static const homeMyBookings = AppTranslation(
    tk: 'Ýazgylarym',
    ru: 'Мои записи',
    en: 'My bookings',
  );

  // features/home/presentation/client_home_dashboard.dart
  static const homeMyBookings2 = AppTranslation(
    tk: 'Meniň ýazgylarym',
    ru: 'Мои записи',
    en: 'My bookings',
  );

  // features/home/presentation/client_home_dashboard.dart
  static const homeMyMasters = AppTranslation(
    tk: 'Meniň masterlarym',
    ru: 'Мои мастера',
    en: 'My masters',
  );

  // features/home/presentation/client_booking_widgets.dart
  static const homeNextBooking = AppTranslation(
    tk: 'Indiki ýazgy',
    ru: 'Ближайшая запись',
    en: 'Next booking',
  );

  // features/home/presentation/home_dashboard_screen.dart
  static const homeNextCustomer = AppTranslation(
    tk: 'Indiki müşderi',
    ru: 'Следующий клиент',
    en: 'Next customer',
  );

  // features/home/presentation/client_master_widgets.dart
  static const homeNicknameOrPhone = AppTranslation(
    tk: 'Lakam ýa-da telefon',
    ru: 'Никнейм или телефон',
    en: 'Nickname or phone',
  );

  // features/home/presentation/client_bookings_screen.dart
  static const homeNoBookingsFound = AppTranslation(
    tk: 'Ýazgy tapylmady',
    ru: 'Записи не найдены',
    en: 'No bookings found',
  );

  // features/home/presentation/day_timeline_screen.dart
  static const homeNoBookingsThisDay = AppTranslation(
    tk: 'Bu gün ýazgy ýok',
    ru: 'На этот день записей нет',
    en: 'No bookings this day',
  );

  // features/home/presentation/home_dashboard_screen.dart
  static const homeNoBookingsToday = AppTranslation(
    tk: 'Şu gün ýazgy ýok',
    ru: 'На сегодня записей нет',
    en: 'No bookings today',
  );

  // features/home/presentation/client_bookings_screen.dart
  static const homeNoPastBookings = AppTranslation(
    tk: 'Öňki ýazgy ýok',
    ru: 'Прошедших записей нет',
    en: 'No past bookings',
  );

  // features/home/presentation/master_profile_screen.dart
  static const homeNoServicesYet = AppTranslation(
    tk: 'Heniz hyzmat goşulmady.',
    ru: 'Услуги пока не добавлены.',
    en: 'No services yet.',
  );

  // features/home/presentation/client_bookings_screen.dart
  static const homeNoUpcomingBookings = AppTranslation(
    tk: 'Indiki ýazgy ýok',
    ru: 'Предстоящих записей нет',
    en: 'No upcoming bookings',
  );

  // features/home/presentation/home_dashboard_screen.dart
  static const homeNone = AppTranslation(
    tk: 'Nobat ýok',
    ru: 'Никого',
    en: 'None',
  );

  // features/home/presentation/home_dashboard_screen.dart
  static const homeNotLoaded = AppTranslation(
    tk: 'Ýüklenmedi',
    ru: 'Не загружено',
    en: 'Not loaded',
  );

  // features/home/presentation/client_bookings_screen.dart
  static const homePast = AppTranslation(
    tk: 'Geçen',
    ru: 'Прошедшие',
    en: 'Past',
  );

  // features/home/presentation/client_master_widgets.dart
  static const homePaused = AppTranslation(
    tk: 'Wagtlaýyn ýapyk',
    ru: 'Запись закрыта',
    en: 'Paused',
  );

  // features/home/presentation/home_dashboard_table_header.dart
  static const homePeople = AppTranslation(
    tk: 'adam',
    ru: 'чел.',
    en: 'people',
  );

  // features/home/presentation/home_dashboard_timeline.dart
  static const homePeople2 = AppTranslation(
    tk: "adam",
    ru: "человек",
    en: "people",
  );

  // features/home/presentation/home_dashboard_screen.dart
  static const homePeople3 = AppTranslation(
    tk: 'adam',
    ru: 'человек',
    en: 'people',
  );

  // features/home/presentation/home_dashboard_table_header.dart
  static const homeQueueOrder = AppTranslation(
    tk: 'NOBAT TERTIBI',
    ru: 'ПОРЯДОК ОЧЕРЕДИ',
    en: 'QUEUE ORDER',
  );

  // features/home/presentation/home_shells.dart
  static const homeRefresh = AppTranslation(
    tk: 'Täzele',
    ru: 'Обновить',
    en: 'Refresh',
  );

  // features/home/presentation/master_profile_screen.dart
  static const homeServices = AppTranslation(
    tk: 'Hyzmatlar',
    ru: 'Услуг',
    en: 'Services',
  );

  // features/home/presentation/master_profile_screen.dart
  static const homeShortest = AppTranslation(
    tk: 'Iň gysga',
    ru: 'От',
    en: 'Shortest',
  );

  // features/home/presentation/client_bookings_screen.dart
  static const homeShowMore = AppTranslation(
    tk: 'Has köp görkez',
    ru: 'Показать ещё',
    en: 'Show more',
  );

  // features/home/presentation/home_shells.dart
  static const homeShowingSavedDataInternetIs = AppTranslation(
    tk: 'Saklanan maglumatlar görkezilýär. Täzelemek we üýtgetmek üçin internet gerek.',
    ru: 'Показаны сохранённые данные. Для обновления и изменений нужен интернет.',
    en: 'Showing saved data. Internet is needed to refresh or make changes.',
  );

  // features/home/presentation/home_shells.dart
  static const homeSignOutOfTheMaster = AppTranslation(
    tk: 'Master hasabyndan çykyp, müşderi hasabyňyzyň telefon belgisi bilen girip bilersiňiz.',
    ru: 'Выйдите из аккаунта мастера, затем войдите с номером телефона клиентского аккаунта.',
    en: 'Sign out of the master account, then use your client account phone number to sign in.',
  );

  // features/home/presentation/master_profile_screen.dart
  static const homeStartingFrom = AppTranslation(
    tk: 'Başlangyç bahasy',
    ru: 'Цена от',
    en: 'Starting from',
  );

  // features/home/presentation/client_bookings_filter_sheet.dart
  static const homeStatus = AppTranslation(
    tk: 'Ýagdaý',
    ru: 'Статус',
    en: 'Status',
  );

  // features/home/presentation/home_shells.dart
  static const homeSwitchAccounts = AppTranslation(
    tk: 'Başga hasaba geçmelimi?',
    ru: 'Войти в другой аккаунт?',
    en: 'Switch accounts?',
  );

  // features/home/presentation/master_profile_screen.dart
  static const homeTakingBookings = AppTranslation(
    tk: 'Ýazgy açyk',
    ru: 'Запись открыта',
    en: 'Taking bookings',
  );

  // features/home/presentation/home_dashboard_screen.dart
  static const homeToday = AppTranslation(
    tk: 'ŞU GÜN',
    ru: 'СЕГОДНЯ',
    en: 'TODAY',
  );

  // features/home/presentation/home_dashboard_screen.dart
  static const homeTodaySQueue = AppTranslation(
    tk: 'Şu günki nobat',
    ru: 'Очередь сегодня',
    en: "Today's queue",
  );

  // features/home/presentation/client_booking_widgets.dart
  static const homeTomorrow = AppTranslation(
    tk: 'Ertir',
    ru: 'Завтра',
    en: 'Tomorrow',
  );

  // features/home/presentation/client_bookings_screen.dart
  static const homeTryADifferentFilter = AppTranslation(
    tk: 'Süzgüçi üýtgediň.',
    ru: 'Измените фильтр.',
    en: 'Try a different filter.',
  );

  // features/home/presentation/client_bookings_screen.dart
  static const homeUpcoming = AppTranslation(
    tk: 'Indiki',
    ru: 'Предстоящие',
    en: 'Upcoming',
  );

  // features/home/presentation/home_dashboard_screen.dart
  static const homeViewAvailableTimesInThe = AppTranslation(
    tk: 'Boş wagtlary senenamadan görüp bilersiňiz.',
    ru: 'Свободное время можно посмотреть в расписании.',
    en: 'View available times in the schedule.',
  );

  // features/home/presentation/home_dashboard_screen.dart
  static const homeViewFullSchedule = AppTranslation(
    tk: 'Iş tertibini doly gör',
    ru: 'Смотреть всё расписание',
    en: 'View full schedule',
  );

  // features/home/presentation/home_dashboard_screen.dart
  static const homeWorkEnds = AppTranslation(
    tk: 'Iş gutarýar',
    ru: 'Работа заканчивается',
    en: 'Work ends',
  );

  // features/notifications/presentation/master_booking_alert_overlay.dart
  static const notificationsAClientJustBookedYou = AppTranslation(
    tk: 'Müşderi size ýazyldy',
    ru: 'Клиент записался к вам',
    en: 'A client just booked you',
  );

  // features/notifications/presentation/notification_screens.dart
  static const notificationsAccept = AppTranslation(
    tk: 'Kabul et',
    ru: 'Принять',
    en: 'Accept',
  );

  // features/notifications/presentation/master_booking_alert_overlay.dart
  static const notificationsClose = AppTranslation(
    tk: 'Ýap',
    ru: 'Закрыть',
    en: 'Close',
  );

  // features/notifications/presentation/notification_screens.dart
  static const notificationsDecline = AppTranslation(
    tk: 'Ret et',
    ru: 'Отказаться',
    en: 'Decline',
  );

  // features/notifications/presentation/master_booking_alert_overlay.dart
  static const notificationsGotIt = AppTranslation(
    tk: 'Düşnükli',
    ru: 'Понятно',
    en: 'Got it',
  );

  // features/onboarding/presentation/onboarding_screen.dart
  static const onboardingBookOnlyWithSpecialistsYou = AppTranslation(
    tk: 'Diňe tanaýan we ynanýan hünärmenleriňize ýazylyň.',
    ru: 'Записывайтесь только к знакомым и проверенным специалистам.',
    en: 'Book only with specialists you know and trust.',
  );

  // features/onboarding/presentation/role_onboarding_screen.dart
  static const onboardingChooseATimeThatWorks = AppTranslation(
    tk: 'Amatly wagty saýlaň',
    ru: 'Выбирайте удобное время',
    en: 'Choose a time that works',
  );

  // features/onboarding/presentation/onboarding_screen.dart
  static const onboardingContinue = AppTranslation(
    tk: 'Dowam et',
    ru: 'Продолжить',
    en: 'Continue',
  );

  // features/onboarding/presentation/onboarding_screen.dart
  static const onboardingGetStarted = AppTranslation(
    tk: 'Başla',
    ru: 'Начать',
    en: 'Get started',
  );

  // features/onboarding/presentation/role_onboarding_screen.dart
  static const onboardingGetTimelyRemindersForBooked = AppTranslation(
    tk: 'Ýazylan hyzmatlaryňyz üçin wagtynda ýatlatma alyň we meýilnamaňyzy rahat saklaň.',
    ru: 'Получайте напоминания вовремя и спокойно планируйте свой день.',
    en: 'Get timely reminders for booked services and plan your day with ease.',
  );

  // features/onboarding/presentation/onboarding_screen.dart
  static const onboardingKeepEveryBeautyAppointmentIn = AppTranslation(
    tk: 'Ähli gözellik hyzmatlaryna ýazgylaryňyzy bir ýerde saklaň.',
    ru: 'Храните все записи на услуги красоты в одном месте.',
    en: 'Keep every beauty appointment in one private place.',
  );

  // features/onboarding/presentation/role_onboarding_screen.dart
  static const onboardingKnowYourClients = AppTranslation(
    tk: 'Müşderileriňizi biliň',
    ru: 'Знайте своих клиентов',
    en: 'Know your clients',
  );

  // features/onboarding/presentation/role_onboarding_screen.dart
  static const onboardingManageBookingsFreeTimeAnd = AppTranslation(
    tk: 'Ýazgylary, boş wagtlary we müşderi maglumatlaryny bir ekrandan dolandyryň.',
    ru: 'Управляйте записями, свободным временем и данными клиентов в одном месте.',
    en: 'Manage bookings, free time and client details all from one screen.',
  );

  // features/onboarding/presentation/role_onboarding_screen.dart
  static const onboardingNeverForgetABooking = AppTranslation(
    tk: 'Ýazgyňyzy ýatdan çykarmaň',
    ru: 'Не забывайте о записи',
    en: 'Never forget a booking',
  );

  // features/onboarding/presentation/onboarding_screen.dart
  static const onboardingNeverMissABooking = AppTranslation(
    tk: 'Ýazgylaryňyzy sypdyrmaň',
    ru: 'Не пропускайте записи',
    en: 'Never miss a booking',
  );

  // features/onboarding/presentation/role_onboarding_screen.dart
  static const onboardingNeverMissABooking2 = AppTranslation(
    tk: 'Ýazgyňyzy sypdyrmaň',
    ru: 'Ничего не упускайте',
    en: 'Never miss a booking',
  );

  // features/onboarding/presentation/role_onboarding_screen.dart
  static const onboardingOrganiseYourDay = AppTranslation(
    tk: 'Işiňizi tertipläň',
    ru: 'Организуйте свой день',
    en: 'Organise your day',
  );

  // features/onboarding/presentation/role_onboarding_screen.dart
  static const onboardingPickAMasterYouTrust = AppTranslation(
    tk: 'Ynanýan masteriňizi saýlaň we birnäçe sekuntda amatly wagtyňyzy belläň.',
    ru: 'Выберите мастера, которому доверяете, и забронируйте время за несколько секунд.',
    en: 'Pick a master you trust and book your slot in seconds.',
  );

  // features/onboarding/presentation/role_onboarding_screen.dart
  static const onboardingSeeOpenSlotsAtA = AppTranslation(
    tk: 'Boş wagtlary göni görüň we günüňize iň amatly sagady aňsatlyk bilen saýlaň.',
    ru: 'Сразу смотрите свободные слоты и выбирайте время, которое подходит именно вам.',
    en: 'See open slots at a glance and pick whatever suits your day best.',
  );

  // features/onboarding/presentation/role_onboarding_screen.dart
  static const onboardingSeePastServicesAndNotes = AppTranslation(
    tk: 'Öňki hyzmatlary we bellikleri görüp, her müşderä has ünsli hyzmat hödürläň.',
    ru: 'Смотрите историю услуг и заметки, чтобы делать сервис более персональным.',
    en: 'See past services and notes to make every visit more personal.',
  );

  // features/onboarding/presentation/onboarding_screen.dart
  static const onboardingSkip = AppTranslation(
    tk: 'Geç',
    ru: 'Пропустить',
    en: 'Skip',
  );

  // features/onboarding/presentation/onboarding_screen.dart
  static const onboardingSmartRemindersAndEarlierSlot = AppTranslation(
    tk: 'Ýatlatmalar we has irki boş wagt barada bildirişler alyň.',
    ru: 'Получайте напоминания и уведомления о более раннем свободном времени.',
    en: 'Smart reminders and earlier-slot notifications.',
  );

  // features/onboarding/presentation/role_onboarding_screen.dart
  static const onboardingSmartRemindersAndNotificationsKeep = AppTranslation(
    tk: 'Akylly ýatlatmalar we bildirişler günüňizi hemişe tertipde saklar.',
    ru: 'Умные напоминания и уведомления помогут держать день под контролем.',
    en: 'Smart reminders and notifications keep your day on track.',
  );

  // features/onboarding/presentation/role_onboarding_screen.dart
  static const onboardingStayConnectedWithYourMaster = AppTranslation(
    tk: 'Öz masteriňiz bilen baglanyşykda boluň',
    ru: 'Будьте на связи с мастером',
    en: 'Stay connected with your master',
  );

  // features/onboarding/presentation/onboarding_screen.dart
  static const onboardingYourPersonalCircle = AppTranslation(
    tk: 'Öz masterleriňiz',
    ru: 'Ваш круг мастеров',
    en: 'Your personal circle',
  );

  // features/onboarding/presentation/onboarding_screen.dart
  static const onboardingYourTimeBeautifullyOrganised = AppTranslation(
    tk: 'Wagtyňyzy tertipli saklaň',
    ru: 'Ваше время под контролем',
    en: 'Your time, beautifully organised',
  );

  // features/permissions/presentation/permission_reminder_host.dart
  static const permissionsAllow = AppTranslation(
    tk: 'Rugsat ber',
    ru: 'Разрешить',
    en: 'Allow',
  );

  // features/permissions/presentation/permission_reminder_host.dart
  static const permissionsAllowCalendarAccess = AppTranslation(
    tk: 'Senenama rugsat beriň',
    ru: 'Разрешите доступ к календарю',
    en: 'Allow calendar access',
  );

  // features/permissions/presentation/permission_reminder_host.dart
  static const permissionsAllowNotifications = AppTranslation(
    tk: 'Bildirişlere rugsat beriň',
    ru: 'Разрешите уведомления',
    en: 'Allow notifications',
  );

  // features/permissions/presentation/permission_reminder_host.dart
  static const permissionsBookingsAndOneHourReminders = AppTranslation(
    tk: 'Ýazgylar we 1 sagat öňki ýatlatmalar senenamada saklanar.',
    ru: 'Записи и напоминания за час сохранятся в календаре.',
    en: 'Bookings and one-hour reminders stay in your calendar.',
  );

  // features/permissions/presentation/permission_reminder_host.dart
  static const permissionsNewBookingsAndRemindersArrive = AppTranslation(
    tk: 'Täze ýazgylar we ýatlatmalar wagtynda geler.',
    ru: 'Новые записи и напоминания придут вовремя.',
    en: 'New bookings and reminders arrive on time.',
  );

  // features/permissions/presentation/permission_reminder_host.dart
  static const permissionsPermissionsNeeded = AppTranslation(
    tk: 'Rugsatlar gerek',
    ru: 'Нужны разрешения',
    en: 'Permissions needed',
  );

  // features/profile/presentation/about_screen.dart
  static const profileAboutUs = AppTranslation(
    tk: 'Biz barada',
    ru: 'О нас',
    en: 'About us',
  );

  // features/profile/presentation/client_profile_screen.dart
  static const profileAccount = AppTranslation(
    tk: 'Hasap',
    ru: 'Аккаунт',
    en: 'Account',
  );

  // features/profile/presentation/client_support_screen.dart
  static const profileAddress = AppTranslation(
    tk: 'Salgy',
    ru: 'Адрес',
    en: 'Address',
  );

  // features/profile/presentation/client_notification_settings_master_notification_toggle.dart
  static const profileAllNotificationTypes = AppTranslation(
    tk: 'Ähli bildiriş görnüşleri',
    ru: 'Все типы уведомлений',
    en: 'All notification types',
  );

  // features/profile/presentation/client_profile_screen.dart
  static const profileApp = AppTranslation(
    tk: 'Programma',
    ru: 'Приложение',
    en: 'App',
  );

  // features/profile/presentation/client_profile_screen.dart
  static const profileAppearance = AppTranslation(
    tk: 'Görnüşi',
    ru: 'Оформление',
    en: 'Appearance',
  );

  // features/profile/presentation/client_profile_screen.dart
  static const profileBlue = AppTranslation(
    tk: 'Mawy',
    ru: 'Синяя',
    en: 'Blue',
  );

  // features/profile/presentation/client_profile_screen.dart
  static const profileBlueAccents = AppTranslation(
    tk: 'Mawy öwüşgin',
    ru: 'Синие акценты',
    en: 'Blue accents',
  );

  // features/profile/presentation/client_notification_settings_screen.dart
  static const profileBookingReminders = AppTranslation(
    tk: 'Ýazgy ýatlatmalary',
    ru: 'Напоминания о записи',
    en: 'Booking reminders',
  );

  // features/profile/presentation/client_profile_widgets.dart
  static const profileBookings = AppTranslation(
    tk: 'Ýazgy',
    ru: 'Записей',
    en: 'Bookings',
  );

  // features/profile/presentation/client_support_screen.dart
  static const profileCanIChangeMyPhone = AppTranslation(
    tk: 'Telefon belgimi üýtgedip bolarmy?',
    ru: 'Можно ли изменить номер телефона?',
    en: 'Can I change my phone number?',
  );

  // features/profile/presentation/client_profile_edit_screen.dart
  static const profileChange = AppTranslation(
    tk: 'Üýtget',
    ru: 'Изменить',
    en: 'Change',
  );

  // features/profile/presentation/change_phone_dialog.dart
  static const profileChangeNumber = AppTranslation(
    tk: 'Belgini üýtget',
    ru: 'Изменить номер',
    en: 'Change number',
  );

  // features/profile/presentation/change_phone_dialog.dart
  static const profileChangePhoneNumber = AppTranslation(
    tk: 'Telefon belgisini üýtgetmek',
    ru: 'Смена номера',
    en: 'Change phone number',
  );

  // features/profile/presentation/client_profile_screen.dart
  static const profileChangeTheAppLanguage = AppTranslation(
    tk: 'Programmanyň dilini üýtgediň.',
    ru: 'Измените язык приложения.',
    en: 'Change the app language.',
  );

  // features/profile/presentation/client_notification_settings_screen.dart
  static const profileCheckYourConnectionAndTry = AppTranslation(
    tk: 'Baglanyşygy barlap, täzeden synanyşyň.',
    ru: 'Проверьте соединение и попробуйте ещё раз.',
    en: 'Check your connection and try again.',
  );

  // features/profile/presentation/client_profile_screen.dart
  static const profileChooseATheme = AppTranslation(
    tk: 'Görnüşi saýlaň',
    ru: 'Выберите тему',
    en: 'Choose a theme',
  );

  // features/profile/presentation/client_profile_screen.dart
  static const profileChooseLanguage = AppTranslation(
    tk: 'Dil saýlaň',
    ru: 'Выберите язык',
    en: 'Choose language',
  );

  // features/profile/presentation/client_profile_screen.dart
  static const profileClassicLook = AppTranslation(
    tk: 'Adaty görnüş',
    ru: 'Классический стиль',
    en: 'Classic look',
  );

  // features/profile/presentation/change_phone_dialog.dart
  static const profileConfirm = AppTranslation(
    tk: 'Tassykla',
    ru: 'Подтвердить',
    en: 'Confirm',
  );

  // features/profile/presentation/client_notification_settings_screen.dart
  static const profileCouldNotLoadNotifications = AppTranslation(
    tk: 'Bildirişleri ýükläp bolmady',
    ru: 'Не удалось загрузить уведомления',
    en: 'Could not load notifications',
  );

  // features/profile/presentation/client_profile_screen.dart
  static const profileDark = AppTranslation(
    tk: 'Garaňky',
    ru: 'Тёмная',
    en: 'Dark',
  );

  // features/profile/presentation/client_profile_screen.dart
  static const profileDarkTheme = AppTranslation(
    tk: 'Gara görnüş',
    ru: 'Тёмная тема',
    en: 'Dark theme',
  );

  // features/profile/presentation/client_profile_screen.dart
  static const profileDeleteAccount = AppTranslation(
    tk: 'Hasaby poz',
    ru: 'Удалить аккаунт',
    en: 'Delete account',
  );

  // features/profile/presentation/client_notification_settings_screen.dart
  static const profileEarlierSlots = AppTranslation(
    tk: 'Has irki wagt',
    ru: 'Более раннее время',
    en: 'Earlier slots',
  );

  // features/profile/presentation/client_profile_edit_screen.dart
  static const profileEditProfile = AppTranslation(
    tk: 'Profili üýtget',
    ru: 'Редактировать профиль',
    en: 'Edit profile',
  );

  // features/profile/presentation/client_support_screen.dart
  static const profileEmail = AppTranslation(
    tk: 'E-poçta',
    ru: 'Эл. почта',
    en: 'Email',
  );

  // features/profile/presentation/change_phone_dialog.dart
  static AppTranslation profileEnterThe6DigitCode(Object? p0) => AppTranslation(
    tk: '$p0 belgisine iberilen 6 sanly kody giriziň.',
    ru: 'Введите 6-значный код, отправленный на $p0.',
    en: 'Enter the 6-digit code sent to $p0.',
  );

  // features/profile/presentation/change_phone_dialog.dart
  static const profileEnterTheFullNumber8 = AppTranslation(
    tk: 'Telefon belgiňizi doly giriziň (8 san)',
    ru: 'Введите номер полностью (8 цифр)',
    en: 'Enter the full number (8 digits)',
  );

  // features/profile/presentation/change_phone_dialog.dart
  static const profileEnterYourNewNumberWe = AppTranslation(
    tk: 'Täze belgiňizi giriziň. Oňa tassyklama kody iberiler.',
    ru: 'Введите новый номер. На него придёт код подтверждения.',
    en: "Enter your new number. We'll text it a confirmation code.",
  );

  // features/profile/presentation/client_profile_screen.dart
  static const profileFaq = AppTranslation(
    tk: 'Soraglar',
    ru: 'Вопросы',
    en: 'FAQ',
  );

  // features/profile/presentation/client_support_screen.dart
  static const profileFrequentlyAskedQuestions = AppTranslation(
    tk: 'Ýygy-ýygydan soralýan soraglar',
    ru: 'Частые вопросы',
    en: 'Frequently asked questions',
  );

  // features/profile/presentation/client_support_screen.dart
  static const profileGetInTouch = AppTranslation(
    tk: 'Bize habarlaşyň',
    ru: 'Свяжитесь с нами',
    en: 'Get in touch',
  );

  // features/profile/presentation/client_profile_screen.dart
  static const profileGold = AppTranslation(
    tk: 'Altyn',
    ru: 'Золотая',
    en: 'Gold',
  );

  // features/profile/presentation/client_profile_screen.dart
  static const profileHelp = AppTranslation(
    tk: 'Kömek',
    ru: 'Помощь',
    en: 'Help',
  );

  // features/profile/presentation/client_support_screen.dart
  static const profileHowDoICancelA = AppTranslation(
    tk: 'Ýazgyny nädip ýatyrmaly?',
    ru: 'Как отменить запись?',
    en: 'How do I cancel a booking?',
  );

  // features/profile/presentation/client_support_screen.dart
  static const profileHowDoesPaymentWork = AppTranslation(
    tk: 'Töleg nädip amala aşyrylýar?',
    ru: 'Как происходит оплата?',
    en: 'How does payment work?',
  );

  // features/profile/presentation/client_support_screen.dart
  static const profileImoContactCopied = AppTranslation(
    tk: 'IMO belgisi nusgalandy.',
    ru: 'Контакт IMO скопирован.',
    en: 'IMO contact copied.',
  );

  // features/profile/presentation/client_profile_screen.dart
  static const profileLanguage = AppTranslation(
    tk: 'Dil',
    ru: 'Язык',
    en: 'Language',
  );

  // features/profile/presentation/client_notification_settings_screen.dart
  static const profileMarkAllRead = AppTranslation(
    tk: 'Ählisini okaldy diýip belle',
    ru: 'Прочитать все',
    en: 'Mark all read',
  );

  // features/profile/presentation/client_notification_settings_screen.dart
  static const profileMasterMessages = AppTranslation(
    tk: 'Master habarlary',
    ru: 'Сообщения мастера',
    en: 'Master messages',
  );

  // features/profile/presentation/client_profile_widgets.dart
  static const profileMasters = AppTranslation(
    tk: 'Master',
    ru: 'Мастеров',
    en: 'Masters',
  );

  // features/profile/presentation/client_notification_settings_screen.dart
  static const profileMessagesFromYourMasters = AppTranslation(
    tk: 'Masterlerden gelýän habarlar',
    ru: 'Сообщения от ваших мастеров',
    en: 'Messages from your masters',
  );

  // features/profile/presentation/client_profile_screen.dart
  static const profileMyMasters = AppTranslation(
    tk: 'Masterlerim',
    ru: 'Мои мастера',
    en: 'My masters',
  );

  // features/profile/presentation/client_profile_edit_screen.dart
  static const profileName = AppTranslation(
    tk: 'Adyňyz',
    ru: 'Имя',
    en: 'Name',
  );

  // features/profile/presentation/client_profile_edit_screen.dart
  static const profileNameMustBe250 = AppTranslation(
    tk: 'Adyňyz 2–50 nyşandan ybarat bolmaly',
    ru: 'Имя должно быть от 2 до 50 символов',
    en: 'Name must be 2-50 characters',
  );

  // features/profile/presentation/client_notification_settings_screen.dart
  static const profileNew = AppTranslation(tk: 'täze', ru: 'новых', en: 'new');

  // features/profile/presentation/client_notification_settings_screen.dart
  static const profileNewNotificationsWillAppearHere = AppTranslation(
    tk: 'Täze bildirişler şu ýerde peýda bolar.',
    ru: 'Новые уведомления появятся здесь.',
    en: 'New notifications will appear here.',
  );

  // features/profile/presentation/about_screen.dart
  static const profileNoInformationYet = AppTranslation(
    tk: 'Maglumat entek goşulmady',
    ru: 'Информация пока не добавлена',
    en: 'No information yet',
  );

  // features/profile/presentation/client_notification_settings_screen.dart
  static const profileNoNotificationsYet = AppTranslation(
    tk: 'Heniz bildiriş ýok',
    ru: 'Уведомлений пока нет',
    en: 'No notifications yet',
  );

  // features/profile/presentation/client_profile_screen.dart
  static const profileNotifications = AppTranslation(
    tk: 'Bildirişler',
    ru: 'Уведомления',
    en: 'Notifications',
  );

  // features/profile/presentation/client_profile_screen.dart
  static const profileOff = AppTranslation(
    tk: 'Öçürilen',
    ru: 'Отключены',
    en: 'Off',
  );

  // features/profile/presentation/client_profile_screen.dart
  static const profileOn = AppTranslation(
    tk: 'Işjeň',
    ru: 'Включены',
    en: 'On',
  );

  // features/profile/presentation/client_support_screen.dart
  static const profileOpenTheBookingUnderThe = AppTranslation(
    tk: '"Ýazgylarym" bölüminde degişli ýazgyny açyp, "Ýatyr" düwmesine basyň. Ýazgyny bellenen wagtdan azyndan 2 sagat öň ýatyrsaňyz, töleg alynmaýar.',
    ru: 'Откройте нужную запись во вкладке «Записи» и нажмите «Отменить». Если отменить не позднее чем за 2 часа до визита, плата не взимается.',
    en: 'Open the booking under the "Bookings" tab and tap "Cancel". Cancelling at least 2 hours before the appointment is free of charge.',
  );

  // features/profile/presentation/client_support_screen.dart
  static const profilePaymentsAreCurrentlyTakenIn = AppTranslation(
    tk: 'Häzirki wagtda tölegler salon ýerinde nagt ýa-da kart bilen alynýar. Programmanyň içinden onlaýn töleg ýakynda goşular.',
    ru: 'Сейчас оплата принимается наличными или картой прямо в салоне. Онлайн-оплата в приложении появится позже.',
    en: 'Payments are currently taken in person at the salon, by cash or card. In-app online payment is coming soon.',
  );

  // features/profile/presentation/client_support_screen.dart
  static const profilePhone = AppTranslation(
    tk: 'Telefon',
    ru: 'Телефон',
    en: 'Phone',
  );

  // features/profile/presentation/client_profile_edit_screen.dart
  static const profilePhoneNumber = AppTranslation(
    tk: 'Telefon belgiňiz',
    ru: 'Номер телефона',
    en: 'Phone number',
  );

  // features/profile/presentation/client_profile_edit_screen.dart
  static const profilePhoneNumberUpdated = AppTranslation(
    tk: 'Telefon belgisi üýtgedildi.',
    ru: 'Номер телефона изменён.',
    en: 'Phone number updated.',
  );

  // features/profile/presentation/client_profile_screen.dart
  static const profileProfile = AppTranslation(
    tk: 'Profil',
    ru: 'Профиль',
    en: 'Profile',
  );

  // features/profile/presentation/client_profile_edit_screen.dart
  static const profileProfileSaved = AppTranslation(
    tk: 'Profil ýatda saklandy.',
    ru: 'Профиль сохранён.',
    en: 'Profile saved.',
  );

  // features/profile/presentation/client_notification_settings_screen.dart
  static const profileRecentNotifications = AppTranslation(
    tk: 'Soňky bildirişler',
    ru: 'Последние уведомления',
    en: 'Recent notifications',
  );

  // features/profile/presentation/client_profile_screen.dart
  static const profileRed = AppTranslation(
    tk: 'Gyzyl',
    ru: 'Красная',
    en: 'Red',
  );

  // features/profile/presentation/client_profile_screen.dart
  static const profileRedAccents = AppTranslation(
    tk: 'Gyzyl öwüşgin',
    ru: 'Красные акценты',
    en: 'Red accents',
  );

  // features/profile/presentation/client_notification_settings_screen.dart
  static const profileRemindMeOneHourBefore = AppTranslation(
    tk: 'Ýazgydan 1 sagat öň ýatlat',
    ru: 'Напомнить за час до визита',
    en: 'Remind me one hour before my appointment',
  );

  // features/profile/presentation/change_phone_dialog.dart
  static const profileResendCode = AppTranslation(
    tk: 'Kody täzeden iber',
    ru: 'Отправить код снова',
    en: 'Resend code',
  );

  // features/profile/presentation/change_phone_dialog.dart
  static const profileSendCode = AppTranslation(
    tk: 'Kod iber',
    ru: 'Отправить код',
    en: 'Send code',
  );

  // features/profile/presentation/client_notification_settings_screen.dart
  static const profileSettings = AppTranslation(
    tk: 'Sazlamalar',
    ru: 'Настройки',
    en: 'Settings',
  );

  // features/profile/presentation/client_profile_widgets.dart
  static const profileSignOut = AppTranslation(
    tk: 'Ulgamdan çykmaly?',
    ru: 'Выйти из аккаунта?',
    en: 'Sign out?',
  );

  // features/profile/presentation/client_profile_widgets.dart
  static const profileSignOut2 = AppTranslation(
    tk: 'Çyk',
    ru: 'Выйти',
    en: 'Sign out',
  );

  // features/profile/presentation/client_profile_widgets.dart
  static const profileSignOut3 = AppTranslation(
    tk: 'Ulgamdan çyk',
    ru: 'Выйти из аккаунта',
    en: 'Sign out',
  );

  // features/profile/presentation/client_profile_screen.dart
  static const profileSupport = AppTranslation(
    tk: 'Goldaw',
    ru: 'Поддержка',
    en: 'Support',
  );

  // features/profile/presentation/client_support_screen.dart
  static const profileTapTheHeartIconIn = AppTranslation(
    tk: 'Aşaky menýudaky ýürek nyşanyna basyp, halanlaryňyzy islendik wagt görüp bilersiňiz. Masteriň profilindäki ýürek belligi bilen goşup/aýryp bolýar.',
    ru: 'Нажмите на значок сердца в нижнем меню, чтобы увидеть избранное в любое время. Добавляйте и убирайте мастеров сердцем на странице их профиля.',
    en: 'Tap the heart icon in the bottom menu to see your favourites anytime. Add or remove a master with the heart on their profile page.',
  );

  // features/profile/presentation/client_notification_settings_screen.dart
  static const profileTellMeWhenAnEarlier = AppTranslation(
    tk: 'Has irki wagt boşanda habar ber',
    ru: 'Сообщать, когда освободится время пораньше',
    en: 'Tell me when an earlier time opens up',
  );

  // features/profile/presentation/client_profile_screen.dart
  static const profileThemesAreUnavailableRightNow = AppTranslation(
    tk: 'Häzir tema saýlawy elýeterli däl.',
    ru: 'Темы сейчас недоступны.',
    en: 'Themes are unavailable right now.',
  );

  // features/profile/presentation/client_notification_settings_screen.dart
  static const profileTryAgain = AppTranslation(
    tk: 'Täzeden synanyş',
    ru: 'Повторить',
    en: 'Try again',
  );

  // features/profile/presentation/client_notification_settings_master_notification_toggle.dart
  static const profileTurnEveryTypeOnOr = AppTranslation(
    tk: 'Hemmesini bir wagtda aç ýa-da öçür',
    ru: 'Включить или выключить все сразу',
    en: 'Turn every type on or off at once',
  );

  // features/profile/presentation/client_profile_widgets.dart
  static const profileUpcoming = AppTranslation(
    tk: 'Indiki',
    ru: 'Предстоящих',
    en: 'Upcoming',
  );

  // features/profile/presentation/client_support_screen.dart
  static const profileWhereAreMyFavouriteMasters = AppTranslation(
    tk: 'Halanan masterlerim nirede saklanýar?',
    ru: 'Где хранятся мои избранные мастера?',
    en: 'Where are my favourite masters saved?',
  );

  // features/profile/presentation/client_support_screen.dart
  static const profileYouCanEditYourName = AppTranslation(
    tk: '"Profil" bölüminden adyňyzy we belgiňizi redaktläp bilersiňiz. Uly üýtgeşmeler üçin goldaw gullugy bilen habarlaşyň.',
    ru: 'Вы можете изменить имя и номер в разделе «Профиль». Для более сложных случаев свяжитесь со службой поддержки.',
    en: 'You can edit your name and number from the "Profile" tab. For anything more complex, contact support below.',
  );

  // features/profile/presentation/client_profile_widgets.dart
  static const profileYouLlNeedToVerify = AppTranslation(
    tk: 'Ýene-de girmek üçin telefon belgiňizi tassyklamaly bolarsyňyz.',
    ru: 'Чтобы войти снова, потребуется подтвердить номер телефона.',
    en: "You'll need to verify your phone number again to sign back in.",
  );

  // features/profile/presentation/client_profile_screen.dart
  static const profileYourChoiceAppliesImmediately = AppTranslation(
    tk: 'Saýlan reňkiňiz derrew ulanylýar.',
    ru: 'Цвет применится сразу.',
    en: 'Your choice applies immediately.',
  );

  // features/requests/presentation/connection_requests_screen.dart
  static const requestsClientsCanFindYouBy = AppTranslation(
    tk: 'Müşderiler lakamyňyz bilen sizi tapyp baglanyşyk haýyşyny iberip bilerler.',
    ru: 'Клиенты находят вас по никнейму и отправляют запрос на связь.',
    en: 'Clients can find you by nickname and send a connection request.',
  );

  // features/requests/presentation/connection_requests_screen.dart
  static const requestsConnectionRequests = AppTranslation(
    tk: 'Baglanyşyk haýyşlary',
    ru: 'Запросы на связь',
    en: 'Connection requests',
  );

  // features/requests/presentation/new_connection_request_dialog.dart
  static const requestsDecline = AppTranslation(
    tk: 'Ret et',
    ru: 'Отклонить',
    en: 'Decline',
  );

  // features/requests/presentation/connection_requests_screen.dart
  static const requestsDeleteYourAccount = AppTranslation(
    tk: 'Hasaby pozmaly?',
    ru: 'Удалить аккаунт?',
    en: 'Delete your account?',
  );

  // features/requests/presentation/new_connection_request_dialog.dart
  static const requestsFoundYouAndWantsTo = AppTranslation(
    tk: 'Sizi tapdy we baglanyşmak isleýär. Kabul etseňiz müşderiler sanawyňyza goşular we onlaýn ýazylyp biler.',
    ru: 'Нашёл вас и хочет связаться. После принятия клиент попадёт в ваш список и сможет записываться онлайн.',
    en: 'Found you and wants to connect. If you accept, they join your clients and can book online.',
  );

  // features/requests/presentation/new_connection_request_dialog.dart
  static const requestsLater = AppTranslation(
    tk: 'Soňra',
    ru: 'Позже',
    en: 'Later',
  );

  // features/requests/presentation/new_connection_request_dialog.dart
  static const requestsNewConnectionRequest = AppTranslation(
    tk: 'Täze baglanyşyk haýyşy',
    ru: 'Новый запрос на связь',
    en: 'New connection request',
  );

  // features/requests/presentation/connection_requests_screen.dart
  static const requestsNoRequests = AppTranslation(
    tk: 'Haýyş ýok',
    ru: 'Запросов нет',
    en: 'No requests',
  );

  // features/requests/presentation/new_connection_request_dialog.dart
  static const requestsPleaseWait = AppTranslation(
    tk: 'Garaşyň...',
    ru: 'Подождите...',
    en: 'Please wait...',
  );

  // features/requests/presentation/new_connection_request_dialog.dart
  static AppTranslation requestsSeeAllRequests(Object? p0) => AppTranslation(
    tk: 'Ähli haýyşlara seret (+$p0)',
    ru: 'Все запросы (+$p0)',
    en: 'See all requests (+$p0)',
  );

  // features/requests/presentation/connection_requests_screen.dart
  static const requestsSomethingWentWrong = AppTranslation(
    tk: 'Ýalňyşlyk',
    ru: 'Ошибка',
    en: 'Something went wrong',
  );

  // features/requests/presentation/connection_requests_screen.dart
  static const requestsYourAccountAndItsData = AppTranslation(
    tk: 'Hasabyňyz we ähli maglumatlaryňyz pozular. Bu hereketi yzyna gaýtaryp bolmaýar.',
    ru: 'Аккаунт и все данные будут удалены. Это действие нельзя отменить.',
    en: 'Your account and its data will be deleted. This cannot be undone.',
  );

  // features/schedule/presentation/schedule_new_slot_customer_fields.dart
  static const scheduleAddANewCustomer = AppTranslation(
    tk: 'Täze müşderi goşuň',
    ru: 'Добавить нового клиента',
    en: 'Add a new customer',
  );

  // features/schedule/presentation/schedule_new_slot_customer_fields.dart
  static const scheduleAddANewCustomerManually = AppTranslation(
    tk: 'Täze müşderini el bilen goşuň',
    ru: 'Добавьте нового клиента вручную',
    en: 'Add a new customer manually',
  );

  // features/schedule/presentation/schedule_new_slot_sheet.dart
  static const scheduleAddANote = AppTranslation(
    tk: 'Bellik goşuň...',
    ru: 'Добавьте заметку...',
    en: 'Add a note...',
  );

  // features/schedule/presentation/schedule_new_slot_service_picker.dart
  static const scheduleAddAServiceFirst = AppTranslation(
    tk: 'Ilki bilen hyzmat goşuň.',
    ru: 'Сначала добавьте услугу.',
    en: 'Add a service first.',
  );

  // features/schedule/presentation/schedule_free_time_actions_sheet.dart
  static const scheduleAddAppointment = AppTranslation(
    tk: 'Täze ýazgy goşmak',
    ru: 'Добавить запись',
    en: 'Add appointment',
  );

  // features/schedule/presentation/schedule_screen.dart
  static const scheduleAddWorkingHours = AppTranslation(
    tk: 'Iş wagty goş',
    ru: 'Добавить рабочие часы',
    en: 'Add working hours',
  );

  // features/schedule/presentation/schedule_customer_picker_view.dart
  static const scheduleAllCustomers = AppTranslation(
    tk: 'Ähli müşderiler',
    ru: 'Все клиенты',
    en: 'All customers',
  );

  // features/schedule/presentation/schedule_date_helpers.dart
  static const scheduleArrived = AppTranslation(
    tk: 'Geldi',
    ru: 'Пришёл',
    en: 'Arrived',
  );

  // features/schedule/presentation/schedule_block_time_sheet.dart
  static const scheduleBlockTime = AppTranslation(
    tk: 'Wagty ýapmak',
    ru: 'Закрыть время',
    en: 'Block time',
  );

  // features/schedule/presentation/schedule_block_time_sheet.dart
  static const scheduleBlockTime2 = AppTranslation(
    tk: 'Ýapmak',
    ru: 'Закрыть',
    en: 'Block time',
  );

  // features/schedule/presentation/schedule_free_time_actions_sheet.dart
  static const scheduleBlockTimeForMyself = AppTranslation(
    tk: 'Wagty özüm üçin ýapmak',
    ru: 'Закрыть время для себя',
    en: 'Block time for myself',
  );

  // features/schedule/presentation/schedule_appointment_row_closed_time_row.dart
  static const scheduleBlockedTime = AppTranslation(
    tk: 'Ýapyk wagt',
    ru: 'Закрытое время',
    en: 'Blocked time',
  );

  // features/schedule/presentation/schedule_free_time_actions_sheet.dart
  static const scheduleBookAClientIntoThis = AppTranslation(
    tk: 'Saýlanan wagta müşderi ýazmak.',
    ru: 'Записать клиента на выбранное время.',
    en: 'Book a client into this time slot.',
  );

  // features/schedule/presentation/schedule_appointment_actions.dart
  static const scheduleCall = AppTranslation(
    tk: 'Jaň etmek',
    ru: 'Позвонить',
    en: 'Call',
  );

  // features/schedule/presentation/schedule_appointment_actions.dart
  static const scheduleCancelBooking = AppTranslation(
    tk: 'Ýazgyny ýatyrmak',
    ru: 'Отменить запись',
    en: 'Cancel booking',
  );

  // features/schedule/presentation/schedule_appointment_actions.dart
  static const scheduleCancelThisBooking = AppTranslation(
    tk: 'Bu ýazgyny ýatyrmak',
    ru: 'Отменить эту запись',
    en: 'Cancel this booking',
  );

  // features/schedule/presentation/schedule_date_helpers.dart
  static const scheduleCancelled = AppTranslation(
    tk: 'Ýatyryldy',
    ru: 'Отменено',
    en: 'Cancelled',
  );

  // features/schedule/presentation/schedule_block_time_sheet.dart
  static const scheduleChangeEndTime = AppTranslation(
    tk: 'Tamamlanyş wagtyny üýtget',
    ru: 'Изменить время окончания',
    en: 'Change end time',
  );

  // features/schedule/presentation/schedule_appointment_actions.dart
  static const scheduleChangeTime = AppTranslation(
    tk: 'Wagty üýtgetmek',
    ru: 'Изменить время',
    en: 'Change time',
  );

  // features/schedule/presentation/schedule_customer_picker_view.dart
  static const scheduleChooseACustomer = AppTranslation(
    tk: 'Müşderi saýlaň',
    ru: 'Выберите клиента',
    en: 'Choose a customer',
  );

  // features/schedule/presentation/schedule_customer_picker_sheet.dart
  static const scheduleChooseADateAndTime = AppTranslation(
    tk: 'Sene we wagt saýlaň',
    ru: 'Выберите дату и время',
    en: 'Choose a date and time',
  );

  // features/schedule/presentation/schedule_new_slot_service_fields.dart
  static const scheduleChooseAService = AppTranslation(
    tk: 'Hyzmat saýlaň',
    ru: 'Выберите услугу',
    en: 'Choose a service',
  );

  // features/schedule/presentation/schedule_block_time_sheet.dart
  static const scheduleChooseAnEndTimeWithin = AppTranslation(
    tk: 'Tamamlanyş wagty boş aralygyň içinde bolmaly.',
    ru: 'Конец должен быть внутри свободного промежутка.',
    en: 'Choose an end time within the free interval.',
  );

  // features/schedule/presentation/schedule_screen.dart
  static const scheduleChooseAnotherDayOrUpdate = AppTranslation(
    tk: 'Başga güni saýlaň ýa-da iş wagtyňyzy sazlaň.',
    ru: 'Выберите другой день или настройте рабочее время.',
    en: 'Choose another day or update your working hours.',
  );

  // features/schedule/presentation/schedule_new_slot_customer_fields.dart
  static const scheduleChooseFromCustomers = AppTranslation(
    tk: 'Müşderilerden saýlaň',
    ru: 'Выбрать из клиентов',
    en: 'Choose from customers',
  );

  // features/schedule/presentation/schedule_customer_picker_view.dart
  static const scheduleClear = AppTranslation(
    tk: 'Arassala',
    ru: 'Очистить',
    en: 'Clear',
  );

  // features/schedule/presentation/schedule_header_actions.dart
  static const scheduleCloseSearch = AppTranslation(
    tk: 'Gözlegi ýap',
    ru: 'Закрыть поиск',
    en: 'Close search',
  );

  // features/schedule/presentation/schedule_date_helpers.dart
  static const scheduleCompleted = AppTranslation(
    tk: 'Tamamlandy',
    ru: 'Завершено',
    en: 'Completed',
  );

  // features/schedule/presentation/schedule_screen.dart
  static const scheduleConnectToTheInternetTo = AppTranslation(
    tk: 'Internet bilen birigip, ýazgylary ýükläň.',
    ru: 'Подключитесь к интернету, чтобы загрузить записи.',
    en: 'Connect to the internet to load bookings.',
  );

  // features/schedule/presentation/schedule_screen.dart
  static const scheduleCouldNotLoadBlockedTimes = AppTranslation(
    tk: 'Ýapyk wagtlary alyp bolmady',
    ru: 'Не удалось загрузить закрытое время',
    en: 'Could not load blocked times',
  );

  // features/schedule/presentation/schedule_screen.dart
  static const scheduleCouldNotShowThisMonth = AppTranslation(
    tk: 'Bu aýyň ýazgylaryny görüp bolmaýar',
    ru: 'Не удалось показать записи за этот месяц',
    en: 'Could not show this month’s bookings',
  );

  // features/schedule/presentation/schedule_customer_picker_sheet.dart
  static const scheduleCurrentTime = AppTranslation(
    tk: 'Häzirki wagt',
    ru: 'Текущее время',
    en: 'Current time',
  );

  // features/schedule/presentation/schedule_appointment_actions.dart
  static const scheduleCustomerArrived = AppTranslation(
    tk: 'Müşderi geldi',
    ru: 'Клиент пришёл',
    en: 'Customer arrived',
  );

  // features/schedule/presentation/schedule_appointment_actions.dart
  static const scheduleCustomerDidNotShowUp = AppTranslation(
    tk: 'Müşderi gelmedi',
    ru: 'Клиент не пришёл',
    en: 'Customer did not show up',
  );

  // features/schedule/presentation/schedule_customer_picker_view.dart
  static const scheduleFindACustomerForThis = AppTranslation(
    tk: 'Ýazgy üçin müşderini tapyň',
    ru: 'Найдите клиента для записи',
    en: 'Find a customer for this booking',
  );

  // features/schedule/presentation/schedule_new_slot_customer_fields.dart
  static const scheduleFirstAndLastName = AppTranslation(
    tk: 'Ady we familiýasy',
    ru: 'Имя и фамилия',
    en: 'First and last name',
  );

  // features/schedule/presentation/schedule_new_slot_time_card.dart
  static const scheduleFree = AppTranslation(
    tk: 'Boş',
    ru: 'Свободно',
    en: 'Free',
  );

  // features/schedule/presentation/schedule_appointment_row.dart
  static const scheduleFree2 = AppTranslation(
    tk: "Boş wagt",
    ru: "Свободно",
    en: "Free",
  );

  // features/schedule/presentation/schedule_appointment_actions.dart
  static const scheduleGoToCustomerProfile = AppTranslation(
    tk: 'Müşderi profiline geçmek',
    ru: 'Перейти в профиль клиента',
    en: 'Go to customer profile',
  );

  // features/schedule/presentation/schedule_free_time_actions_sheet.dart
  static const scheduleItIsTooLateTo = AppTranslation(
    tk: 'Bu wagta müşderi ýazmak üçin giç. Başga wagt saýlaň.',
    ru: 'Для записи клиента на это время уже поздно. Выберите другое.',
    en: 'It is too late to book a client for this time. Choose another.',
  );

  // features/schedule/presentation/schedule_free_time_actions_sheet.dart
  static const scheduleKeepThisTimeForPersonal = AppTranslation(
    tk: 'Öz işleriňiz üçin bu wagty ýapmak.',
    ru: 'Закрыть это время для личных дел.',
    en: 'Keep this time for personal tasks.',
  );

  // features/schedule/presentation/schedule_appointment_actions.dart
  static const scheduleMarkAsArrived = AppTranslation(
    tk: 'Geldi diýip belle',
    ru: 'Отметить «Пришёл»',
    en: 'Mark as arrived',
  );

  // features/schedule/presentation/schedule_appointment_actions.dart
  static const scheduleMarkAsCompleted = AppTranslation(
    tk: 'Tamamlandy diýip belle',
    ru: 'Отметить «Завершено»',
    en: 'Mark as completed',
  );

  // features/schedule/presentation/schedule_appointment_actions.dart
  static const scheduleMarkAsNoShow = AppTranslation(
    tk: 'Gelmedi diýip belle',
    ru: 'Отметить «Не пришёл»',
    en: 'Mark as no-show',
  );

  // features/schedule/presentation/schedule_appointment_actions.dart
  static const scheduleMoveThisBookingToAnother = AppTranslation(
    tk: 'Bu ýazgyny başga wagta geçirmek',
    ru: 'Перенести эту запись',
    en: 'Move this booking to another time',
  );

  // features/schedule/presentation/schedule_customer_picker_view.dart
  static const scheduleNameOrPhoneNumber = AppTranslation(
    tk: 'Ady ýa-da telefon belgisi',
    ru: 'Имя или номер телефона',
    en: 'Name or phone number',
  );

  // features/schedule/presentation/schedule_new_slot_header.dart
  static const scheduleNewBooking = AppTranslation(
    tk: 'Täze ýazgy goşmak',
    ru: 'Добавить запись',
    en: 'New booking',
  );

  // features/schedule/presentation/schedule_date_helpers.dart
  static const scheduleNewClient = AppTranslation(
    tk: 'Täze müşderi',
    ru: 'Новый клиент',
    en: 'New client',
  );

  // features/schedule/presentation/schedule_appointment_changes.dart
  static const scheduleNo = AppTranslation(tk: 'Ýok', ru: 'Нет', en: 'No');

  // features/schedule/presentation/schedule_customer_picker_results.dart
  static const scheduleNoCustomersAddedYet = AppTranslation(
    tk: 'Entek müşderi goşulmady',
    ru: 'Клиенты ещё не добавлены',
    en: 'No customers added yet',
  );

  // features/schedule/presentation/schedule_customer_picker_results.dart
  static const scheduleNoCustomersFound = AppTranslation(
    tk: 'Müşderi tapylmady',
    ru: 'Клиенты не найдены',
    en: 'No customers found',
  );

  // features/schedule/presentation/schedule_screen.dart
  static const scheduleNoResultsFound = AppTranslation(
    tk: 'Netije tapylmady',
    ru: 'Ничего не найдено',
    en: 'No results found',
  );

  // features/schedule/presentation/schedule_date_helpers.dart
  static const scheduleNoShow = AppTranslation(
    tk: 'Gelmedi',
    ru: 'Не пришёл',
    en: 'No-show',
  );

  // features/schedule/presentation/schedule_screen.dart
  static const scheduleNoWorkingHoursLeftToday = AppTranslation(
    tk: 'Bu gün iş wagtyňyz galmady',
    ru: 'На сегодня рабочих часов не осталось',
    en: 'No working hours left today',
  );

  // features/schedule/presentation/schedule_screen.dart
  static const scheduleNoWorkingHoursOnThis = AppTranslation(
    tk: 'Bu gün iş wagtyňyz ýok',
    ru: 'На этот день рабочих часов нет',
    en: 'No working hours on this day',
  );

  // features/schedule/presentation/schedule_new_slot_service_picker.dart
  static const scheduleNotEnoughTimeForThis = AppTranslation(
    tk: 'Bu wagt hyzmat üçin ýeterlik däl',
    ru: 'Недостаточно времени для услуги',
    en: 'Not enough time for this service',
  );

  // features/schedule/presentation/schedule_new_slot_sheet.dart
  static const scheduleNoteOptional = AppTranslation(
    tk: 'Bellik (islege görä)',
    ru: 'Заметка (необязательно)',
    en: 'Note (optional)',
  );

  // features/schedule/presentation/schedule_new_slot_customer_fields.dart
  static const schedulePickAnExistingCustomer = AppTranslation(
    tk: 'Bar bolan müşderini saýlaň',
    ru: 'Выберите существующего клиента',
    en: 'Pick an existing customer',
  );

  // features/schedule/presentation/schedule_block_time_sheet.dart
  static const schedulePrivateNoteOptional = AppTranslation(
    tk: 'Şahsy bellik (hökmany däl)',
    ru: 'Личная заметка (необязательно)',
    en: 'Private note (optional)',
  );

  // features/schedule/presentation/schedule_date_helpers.dart
  static const scheduleRegular = AppTranslation(
    tk: 'Hemişelik',
    ru: 'Постоянный',
    en: 'Regular',
  );

  // features/schedule/presentation/schedule_reopen_closed_time.dart
  static const scheduleReopen = AppTranslation(
    tk: 'Açmak',
    ru: 'Открыть',
    en: 'Reopen',
  );

  // features/schedule/presentation/schedule_reopen_closed_time.dart
  static const scheduleReopenTime = AppTranslation(
    tk: 'Wagty açmak',
    ru: 'Открыть время',
    en: 'Reopen time',
  );

  // features/schedule/presentation/schedule_screen.dart
  static const scheduleRetry = AppTranslation(
    tk: 'Gaýtadan synanyş',
    ru: 'Повторить',
    en: 'Retry',
  );

  // features/schedule/presentation/schedule_screen.dart
  static const scheduleRetryToShowAvailableTimes = AppTranslation(
    tk: 'Boş wagtlary görkezmek üçin täzeden synanyşyň.',
    ru: 'Повторите попытку, чтобы увидеть свободное время.',
    en: 'Retry to show available times.',
  );

  // features/schedule/presentation/schedule_new_slot_sheet.dart
  static const scheduleSaveBooking = AppTranslation(
    tk: 'Ýazgyny sakla',
    ru: 'Сохранить запись',
    en: 'Save booking',
  );

  // features/schedule/presentation/schedule_screen.dart
  static const scheduleSchedule = AppTranslation(
    tk: 'Senenama',
    ru: 'Расписание',
    en: 'Schedule',
  );

  // features/schedule/presentation/schedule_header_actions.dart
  static const scheduleSearch = AppTranslation(
    tk: 'Gözle',
    ru: 'Поиск',
    en: 'Search',
  );

  // features/schedule/presentation/schedule_screen.dart
  static const scheduleSearchCustomerOrService = AppTranslation(
    tk: 'Müşderi ýa-da hyzmat gözle',
    ru: 'Поиск клиента или услуги',
    en: 'Search customer or service',
  );

  // features/schedule/presentation/schedule_customer_picker_view.dart
  static const scheduleSearchResults = AppTranslation(
    tk: 'Gözleg netijeleri',
    ru: 'Результаты поиска',
    en: 'Search results',
  );

  // features/schedule/presentation/schedule_appointment_actions.dart
  static const scheduleServiceCompleted = AppTranslation(
    tk: 'Hyzmat tamamlandy',
    ru: 'Услуга завершена',
    en: 'Service completed',
  );

  // features/schedule/presentation/schedule_appointment_changes.dart
  static AppTranslation scheduleTheBookingForWillBe(Object? p0) =>
      AppTranslation(
        tk: '$p0 üçin bu ýazgy ýatyrylar.',
        ru: 'Запись для $p0 будет отменена.',
        en: 'The booking for $p0 will be cancelled.',
      );

  // features/schedule/presentation/schedule_new_slot_sheet.dart
  static const scheduleThisServiceDoesNotFit = AppTranslation(
    tk: 'Bu hyzmat saýlanan wagta sygmaýar. Başga wagt ýa-da hyzmat saýlaň.',
    ru: 'Услуга не помещается в выбранное время. Выберите другое время или услугу.',
    en: 'This service does not fit the selected time. Choose another time or service.',
  );

  // features/schedule/presentation/schedule_block_time_sheet.dart
  static const scheduleThisTimeCannotBeBlocked = AppTranslation(
    tk: 'Bu wagty ýapyp bolmaýar. Geljekdäki wagt saýlaň.',
    ru: 'Это время закрыть нельзя. Выберите время в будущем.',
    en: 'This time cannot be blocked. Choose a future time.',
  );

  // features/schedule/presentation/schedule_appointment_changes.dart
  static const scheduleThisTimeIsAlreadyTaken = AppTranslation(
    tk: 'Bu wagt eýýäm alyndy.',
    ru: 'Это время уже занято.',
    en: 'This time is already taken.',
  );

  // features/schedule/presentation/schedule_new_slot_sheet.dart
  static const scheduleThisTimeIsNoLonger = AppTranslation(
    tk: 'Bu wagt indi elýeterli däl. Başga wagt saýlaň.',
    ru: 'Это время уже недоступно. Выберите другое.',
    en: 'This time is no longer available. Choose another.',
  );

  // features/schedule/presentation/schedule_reopen_closed_time.dart
  static const scheduleThisTimeWillBecomeAvailable = AppTranslation(
    tk: 'Bu wagt müşderiler üçin ýene elýeterli bolar.',
    ru: 'Этот промежуток снова станет доступен клиентам.',
    en: 'This time will become available to clients again.',
  );

  // features/schedule/presentation/schedule_block_time_sheet.dart
  static const scheduleTimeBlockedClientsCannotBook = AppTranslation(
    tk: 'Wagt ýapyldy. Müşderiler bu aralyga ýazylyp bilmez.',
    ru: 'Время закрыто. Клиенты не смогут записаться в этот промежуток.',
    en: 'Time blocked. Clients cannot book this interval.',
  );

  // features/schedule/presentation/schedule_reopen_closed_time.dart
  static const scheduleTimeReopened = AppTranslation(
    tk: 'Wagt açyldy.',
    ru: 'Время открыто.',
    en: 'Time reopened.',
  );

  // features/schedule/presentation/schedule_free_time_actions_sheet.dart
  static const scheduleTimeSlotActions = AppTranslation(
    tk: 'Wagt boýunça hereketler',
    ru: 'Действия со временем',
    en: 'Time slot actions',
  );

  // features/schedule/presentation/schedule_header_actions.dart
  static const scheduleToday = AppTranslation(
    tk: 'Şu gün',
    ru: 'Сегодня',
    en: 'Today',
  );

  // features/schedule/presentation/schedule_customer_picker_results.dart
  static const scheduleTryAnotherNameOrNumber = AppTranslation(
    tk: 'Başga at ýa-da belgi bilen gözläň',
    ru: 'Попробуйте другое имя или номер',
    en: 'Try another name or number',
  );

  // features/schedule/presentation/schedule_screen.dart
  static const scheduleTryAnotherNameOrService = AppTranslation(
    tk: 'Başga at ýa-da hyzmat bilen gözläň.',
    ru: 'Попробуйте другое имя или услугу.',
    en: 'Try another name or service.',
  );

  // features/schedule/presentation/schedule_date_helpers.dart
  static const scheduleUpcoming = AppTranslation(
    tk: 'Öňümizdäki',
    ru: 'Ожидание',
    en: 'Upcoming',
  );

  // features/schedule/presentation/schedule_appointment_actions.dart
  static const scheduleViewCustomerDetails = AppTranslation(
    tk: 'Müşderiniň maglumatlaryny görmek',
    ru: 'Посмотреть данные клиента',
    en: 'View customer details',
  );

  // features/schedule/presentation/schedule_header_actions.dart
  static const scheduleWeekView = AppTranslation(
    tk: 'Hepdelik görnüş',
    ru: 'Неделя',
    en: 'Week view',
  );

  // features/schedule/presentation/schedule_week_overview_screen.dart
  static const scheduleWeekView2 = AppTranslation(
    tk: 'Hepde görnüşi',
    ru: 'Недельный вид',
    en: 'Week view',
  );

  // features/schedule/presentation/schedule_working_hours_action.dart
  static const scheduleWorkingHoursForThisDay = AppTranslation(
    tk: 'Şu gün üçin iş wagty',
    ru: 'Рабочие часы на этот день',
    en: 'Working hours for this day',
  );

  // features/services/presentation/services_screen.dart
  static const services1MonthFree = AppTranslation(
    tk: '1 aý mugt',
    ru: '1 месяц бесплатно',
    en: '1 month free',
  );

  // features/services/presentation/service_form_screen.dart
  static const servicesAboutTheService = AppTranslation(
    tk: 'Hyzmat barada',
    ru: 'Об услуге',
    en: 'About the service',
  );

  // features/services/presentation/services_screen.dart
  static const servicesActivateTheFreeMonth = AppTranslation(
    tk: 'Mugt aýy işjeňleşdiriň',
    ru: 'Активируйте бесплатный месяц',
    en: 'Activate the free month',
  );

  // features/services/presentation/service_form_screen.dart
  static const servicesAddService = AppTranslation(
    tk: 'Hyzmaty goş',
    ru: 'Добавить услугу',
    en: 'Add service',
  );

  // features/services/presentation/services_screen.dart
  static const servicesAddService2 = AppTranslation(
    tk: 'Täze hyzmat goş',
    ru: 'Добавить услугу',
    en: 'Add service',
  );

  // features/services/presentation/services_screen.dart
  static const servicesAddYourService = AppTranslation(
    tk: 'Hyzmatyňyzy goşuň',
    ru: 'Добавьте услугу',
    en: 'Add your service',
  );

  // features/services/presentation/service_form_screen.dart
  static const servicesAtLeast2Characters = AppTranslation(
    tk: 'Iň az 2 nyşan',
    ru: 'Минимум 2 символа',
    en: 'At least 2 characters',
  );

  // features/services/presentation/service_form_screen.dart
  static AppTranslation servicesBetweenAndMinutes(Object? p0, Object? p1) =>
      AppTranslation(
        tk: '$p0–$p1 minut aralygynda',
        ru: 'От $p0 до $p1 минут',
        en: 'Between $p0 and $p1 minutes',
      );

  // features/services/presentation/service_form_screen.dart
  static const servicesBrieflyDescribeTheService = AppTranslation(
    tk: 'Hyzmat barada gysgaça düşündiriň...',
    ru: 'Кратко опишите услугу...',
    en: 'Briefly describe the service...',
  );

  // features/services/presentation/services_service_card.dart
  static const servicesCancel = AppTranslation(
    tk: 'Ýatyr',
    ru: 'Отмена',
    en: 'Cancel',
  );

  // features/services/presentation/service_form_screen.dart
  static const servicesChangePhoto = AppTranslation(
    tk: 'Suraty üýtget',
    ru: 'Изменить фото',
    en: 'Change photo',
  );

  // features/services/presentation/service_form_screen.dart
  static const servicesChooseADuration = AppTranslation(
    tk: 'Dowamlylygy saýlaň',
    ru: 'Выберите длительность',
    en: 'Choose a duration',
  );

  // features/services/presentation/service_form_screen.dart
  static const servicesCustomDurationMin = AppTranslation(
    tk: 'Başga wagt (minut)',
    ru: 'Своя длительность (мин)',
    en: 'Custom duration (min)',
  );

  // features/services/presentation/services_service_card.dart
  static const servicesDelete = AppTranslation(
    tk: 'Poz',
    ru: 'Удалить',
    en: 'Delete',
  );

  // features/services/presentation/services_service_card.dart
  static const servicesDeleteThisService = AppTranslation(
    tk: 'Hyzmaty pozmaly?',
    ru: 'Удалить услугу?',
    en: 'Delete this service?',
  );

  // features/services/presentation/service_form_screen.dart
  static const servicesDescriptionOptional = AppTranslation(
    tk: 'Düşündiriş (islege görä)',
    ru: 'Описание (необязательно)',
    en: 'Description (optional)',
  );

  // features/services/presentation/service_form_screen.dart
  static const servicesDurationMin = AppTranslation(
    tk: 'Dowamlylygy (minut)',
    ru: 'Длительность (мин)',
    en: 'Duration (min)',
  );

  // features/services/presentation/services_service_card.dart
  static const servicesEdit = AppTranslation(
    tk: 'Üýtget',
    ru: 'Изменить',
    en: 'Edit',
  );

  // features/services/presentation/service_form_screen.dart
  static const servicesEditService = AppTranslation(
    tk: 'Hyzmaty üýtget',
    ru: 'Изменить услугу',
    en: 'Edit service',
  );

  // features/services/presentation/service_form_screen.dart
  static const servicesExample80 = AppTranslation(
    tk: 'Mysal: 80',
    ru: 'Например: 80',
    en: 'Example: 80',
  );

  // features/services/presentation/service_form_screen.dart
  static const servicesExampleHaircut = AppTranslation(
    tk: 'Mysal: Saç kesmek',
    ru: 'Например: Стрижка',
    en: 'Example: Haircut',
  );

  // features/services/presentation/services_screen.dart
  static AppTranslation servicesHidden(Object? p0) =>
      AppTranslation(tk: '$p0 gizlin', ru: 'Скрыто: $p0', en: '$p0 hidden');

  // features/services/presentation/services_service_card.dart
  static const servicesHidden2 = AppTranslation(
    tk: 'Gizlin',
    ru: 'Скрыта',
    en: 'Hidden',
  );

  // features/services/presentation/service_form_screen.dart
  static const servicesJpgOrPngThePhoto = AppTranslation(
    tk: 'JPG ýa-da PNG. Surat awtomatiki kiçeldiler.',
    ru: 'JPG или PNG. Фото уменьшится автоматически.',
    en: 'JPG or PNG. The photo is resized automatically.',
  );

  // features/services/presentation/services_screen.dart
  static const servicesLater = AppTranslation(
    tk: 'Soň',
    ru: 'Позже',
    en: 'Later',
  );

  // features/services/presentation/service_form_screen.dart
  static const servicesNewService = AppTranslation(
    tk: 'Täze hyzmat goş',
    ru: 'Новая услуга',
    en: 'New service',
  );

  // features/services/presentation/services_screen.dart
  static const servicesNoServicesYet = AppTranslation(
    tk: 'Heniz hyzmat ýok',
    ru: 'Услуг пока нет',
    en: 'No services yet',
  );

  // features/services/presentation/service_form_screen.dart
  static const servicesOther = AppTranslation(
    tk: 'Başga',
    ru: 'Другое',
    en: 'Other',
  );

  // features/services/presentation/services_screen.dart
  static const servicesPaymentIsNeededAfterThe = AppTranslation(
    tk: 'Aý gutarandan soň töleg gerek',
    ru: 'После месяца потребуется оплата',
    en: 'Payment is needed after the month ends',
  );

  // features/services/presentation/service_form_screen.dart
  static const servicesPrice = AppTranslation(
    tk: 'Bahasy',
    ru: 'Цена',
    en: 'Price',
  );

  // features/services/presentation/service_form_screen.dart
  static const servicesPriceTime = AppTranslation(
    tk: 'Baha we wagt',
    ru: 'Цена и время',
    en: 'Price & time',
  );

  // features/services/presentation/service_form_field_label.dart
  static const servicesRequiredField = AppTranslation(
    tk: 'Bu meýdan hökmany',
    ru: 'Обязательное поле',
    en: 'Required field',
  );

  // features/services/presentation/service_form_screen.dart
  static const servicesSave = AppTranslation(
    tk: 'Ýatda sakla',
    ru: 'Сохранить',
    en: 'Save',
  );

  // features/services/presentation/service_form_screen.dart
  static const servicesSaving = AppTranslation(
    tk: 'Saklanýar...',
    ru: 'Сохранение...',
    en: 'Saving...',
  );

  // features/services/presentation/service_form_screen.dart
  static const servicesServiceName = AppTranslation(
    tk: 'Hyzmatyň ady',
    ru: 'Название услуги',
    en: 'Service name',
  );

  // features/services/presentation/service_form_screen.dart
  static const servicesServicePhoto = AppTranslation(
    tk: 'Hyzmatyň suraty',
    ru: 'Фото услуги',
    en: 'Service photo',
  );

  // features/services/presentation/services_screen.dart
  static const servicesServices = AppTranslation(
    tk: 'Hyzmatlar',
    ru: 'Услуги',
    en: 'Services',
  );

  // features/services/presentation/services_screen.dart
  static AppTranslation servicesServices2(Object? p0) =>
      AppTranslation(tk: '$p0 hyzmat', ru: 'Услуг: $p0', en: '$p0 services');

  // features/services/presentation/services_screen.dart
  static const servicesTapAddServiceBelowTo = AppTranslation(
    tk: 'Aşakdaky "Täze hyzmat goş" düwmesine basyp ilkinji hyzmatyňyzy goşuň.',
    ru: 'Нажмите «Добавить услугу» внизу, чтобы создать первую услугу.',
    en: 'Tap "Add service" below to create your first one.',
  );

  // features/services/presentation/service_form_field_label.dart
  static const servicesThisFieldIsRequired = AppTranslation(
    tk: 'Bu meýdan hökmany',
    ru: 'Обязательное поле',
    en: 'This field is required',
  );

  // features/services/presentation/services_screen.dart
  static const servicesUseFreeMonth = AppTranslation(
    tk: 'Mugt aýy ulan',
    ru: 'Использовать месяц',
    en: 'Use free month',
  );

  // features/services/presentation/services_screen.dart
  static const servicesUseYourFirstMonthFor = AppTranslation(
    tk: 'Ilkinji aýy tölegsiz ulanyň.',
    ru: 'Пользуйтесь первым месяцем бесплатно.',
    en: 'Use your first month for free.',
  );

  // features/services/presentation/services_screen.dart
  static AppTranslation servicesVisible(Object? p0) =>
      AppTranslation(tk: '$p0 görünýär', ru: 'Видно: $p0', en: '$p0 visible');

  // features/services/presentation/services_service_card.dart
  static const servicesVisible2 = AppTranslation(
    tk: 'Görünýär',
    ru: 'Видна',
    en: 'Visible',
  );

  // features/services/presentation/services_service_card.dart
  static AppTranslation servicesWillBeRemovedFromThe(Object? p0) =>
      AppTranslation(
        tk: '"$p0" hyzmaty sanawdan aýrylar.',
        ru: '«$p0» будет удалена из списка.',
        en: '"$p0" will be removed from the list.',
      );

  // features/services/presentation/services_screen.dart
  static const servicesYourServiceWasAddedActivate = AppTranslation(
    tk: 'Hyzmat goşuldy. Mugt aýy indi işjeňleşdiriň.',
    ru: 'Услуга добавлена. Теперь активируйте бесплатный месяц.',
    en: 'Your service was added. Activate your free month now.',
  );

  // shared/widgets/photo_picker.dart
  static const sharedChooseFromGallery = AppTranslation(
    tk: 'Galereýadan saýla',
    ru: 'Выбрать из галереи',
    en: 'Choose from gallery',
  );

  // shared/utils/api_errors.dart
  static const sharedNoInternetConnectionPleaseTry = AppTranslation(
    tk: 'Internet baglanyşygy ýok. Täzeden synanyşyň.',
    ru: 'Нет соединения с интернетом. Попробуйте снова.',
    en: 'No internet connection. Please try again.',
  );

  // shared/utils/api_errors.dart
  static const sharedSomethingWentWrongPleaseTry = AppTranslation(
    tk: 'Näbelli ýalňyşlyk. Täzeden synanyşyň.',
    ru: 'Неизвестная ошибка. Попробуйте снова.',
    en: 'Something went wrong. Please try again.',
  );

  // shared/widgets/photo_picker.dart
  static const sharedTakeAPhoto = AppTranslation(
    tk: 'Surat düşür',
    ru: 'Сделать фото',
    en: 'Take a photo',
  );

  // shared/widgets/photo_picker.dart
  static const sharedThePhotoIsTooLarge = AppTranslation(
    tk: 'Surat gaty uly ýa-da okalmady. Başga surat saýlaň.',
    ru: 'Фото слишком большое или не читается. Выберите другое.',
    en: 'The photo is too large or cannot be read. Choose another one.',
  );

  // shared/utils/api_errors.dart
  static AppTranslation sharedTooManyAttemptsTryAgain(Object? p0) =>
      AppTranslation(
        tk: 'Gaty köp synanyşyk. $p0 sekuntdan soň täzeden synanyşyň.',
        ru: 'Слишком часто. Повторите через $p0 сек.',
        en: 'Too many attempts. Try again in $p0 s.',
      );
}
