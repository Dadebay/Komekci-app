part of '../../../app/komekci_app.dart';

/// Where a new client lands after signing up: find your master by exact
/// @nickname or phone number and send a connection request.
///
/// The API has no master directory (`GET /masters/lookup` only answers an
/// exact match), so there is nothing to browse; the page instead explains
/// how connecting works and shows a result card with a one-tap "Connect".
class ConnectMasterScreen extends StatefulWidget {
  const ConnectMasterScreen({super.key});
  @override
  State<ConnectMasterScreen> createState() => _ConnectMasterScreenState();
}

class _ConnectMasterScreenState extends State<ConnectMasterScreen> {
  final _controller = TextEditingController();
  final _focus = FocusNode();
  bool _searching = false;
  bool _connecting = false;
  bool _notFound = false;
  MasterBrief? _result;
  String? _message;

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _clear() {
    _controller.clear();
    setState(() {
      _result = null;
      _notFound = false;
      _message = null;
    });
  }

  Future<void> _search() async {
    final query = _controller.text.trim().replaceFirst('@', '');
    final language = context.read<LanguageProvider>().language;
    final masters = context.read<ClientMastersProvider>();
    if (query.length < 3) {
      setState(() {
        _result = null;
        _notFound = false;
        _message = pickTr(
          language,
          tk: 'Iň az 3 simwol giriziň',
          ru: 'Введите минимум 3 символа',
          en: 'Enter at least 3 characters',
        );
      });
      return;
    }
    FocusScope.of(context).unfocus();
    // Phone numbers are matched exactly, so send them in API form.
    final isPhone = RegExp(r'^[+\d\s]+$').hasMatch(query);
    setState(() {
      _searching = true;
      _message = null;
      _notFound = false;
      _result = null;
    });
    try {
      final found = await masters.lookup(isPhone ? toApiPhone(query) : query.toLowerCase());
      if (!mounted) return;
      setState(() {
        _searching = false;
        _result = found;
        _notFound = found == null;
      });
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() {
        _searching = false;
        if (error.code == ApiErrors.masterNotFound) {
          _notFound = true;
        } else {
          _message = apiErrorMessage(error, language);
        }
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _searching = false;
        _message = apiErrorMessage(error, language);
      });
    }
  }

  Future<void> _connect(MasterBrief master) async {
    if (_connecting) return;
    final language = context.read<LanguageProvider>().language;
    final masters = context.read<ClientMastersProvider>();
    setState(() {
      _connecting = true;
      _message = null;
    });
    try {
      await masters.connect(master.id);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _connecting = false;
        _message = apiErrorMessage(error, language);
      });
      return;
    }
    if (!mounted) return;
    setState(() => _connecting = false);
    Navigator.push(context, pageRoute(RequestPendingScreen(master: master)));
  }

  @override
  Widget build(BuildContext context) {
    final language = context.watch<LanguageProvider>().language;
    String t({required String tk, required String ru, required String en}) => pickTr(language, tk: tk, ru: ru, en: en);
    final tokens = context.appTokens;
    final masters = context.watch<ClientMastersProvider>();
    final result = _result;
    ClientConnection? existing;
    if (result != null) {
      for (final c in masters.connections) {
        if (c.master.id == result.id) existing = c;
      }
    }

    return AppScaffold(
      titleInAppBar: true,
      title: t(tk: 'Ussaňyza baglanyň', ru: 'Подключитесь к мастеру', en: 'Connect to your master'),
      subtitle: t(
        tk: 'Ussanyň lakamyny ýa-da telefon belgisini giriziň',
        ru: 'Введите никнейм или номер телефона мастера',
        en: "Enter your master's nickname or phone number",
      ),
      child: Column(
        children: [
          Expanded(
            child: ListView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.only(top: 8, bottom: 16),
              children: [
                _SearchBox(
                  controller: _controller,
                  focusNode: _focus,
                  searching: _searching,
                  hint: t(
                    tk: '@lakam ýa-da +993 telefon',
                    ru: '@никнейм или телефон +993',
                    en: '@nickname or +993 phone',
                  ),
                  onSearch: _search,
                  onClear: _clear,
                ),
                const SizedBox(height: 22),
                if (_message != null) ...[
                  _FieldError(_message!),
                  const SizedBox(height: 14),
                ],
                if (result != null)
                  _MasterResultCard(
                    master: result,
                    connection: existing,
                    connecting: _connecting,
                    onConnect: () => _connect(result),
                  )
                else if (_notFound)
                  _NotFoundNote(
                    title: t(tk: 'Usta tapylmady', ru: 'Мастер не найден', en: 'No master found'),
                    text: t(
                      tk: 'Lakamy ýa-da telefon belgisini doly we dogry ýazandygyňyzy barlaň. Gözleg takyk deňleşdirme bilen işleýär.',
                      ru: 'Проверьте, что никнейм или номер введены полностью и без ошибок. Поиск работает по точному совпадению.',
                      en: 'Check that the nickname or number is complete and correct. Search only matches exactly.',
                    ),
                  )
                else if (!_searching)
                  _HowItWorks(
                    steps: [
                      (
                        Icons.chat_bubble_outline,
                        t(tk: 'Ussadan lakamyny soraň', ru: 'Узнайте никнейм у мастера', en: 'Ask your master for their nickname'),
                        t(
                          tk: 'Ýa-da onuň telefon belgisini ulanyň.',
                          ru: 'Или воспользуйтесь его номером телефона.',
                          en: 'Or use their phone number.',
                        ),
                      ),
                      (
                        Icons.search,
                        t(tk: 'Gözläň we haýyş iberiň', ru: 'Найдите и отправьте запрос', en: 'Search and send a request'),
                        t(
                          tk: 'Ussa sizi öz müşderileriniň hataryna goşar.',
                          ru: 'Мастер добавит вас в свои клиенты.',
                          en: 'The master adds you to their clients.',
                        ),
                      ),
                      (
                        Icons.calendar_month_outlined,
                        t(tk: 'Ýazylyň', ru: 'Записывайтесь', en: 'Book appointments'),
                        t(
                          tk: 'Kabul edilenden soň hyzmatlary we boş wagtlary görersiňiz.',
                          ru: 'После принятия вы увидите услуги и свободное время.',
                          en: 'Once accepted you can see services and free times.',
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pushAndRemoveUntil(context, pageRoute(const ClientHome()), (_) => false),
            child: Text(
              t(tk: 'Soňrak baglanaryn', ru: 'Подключусь позже', en: 'I’ll connect later'),
              style: TextStyle(color: tokens.textSecondary, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchBox extends StatelessWidget {
  const _SearchBox({
    required this.controller,
    required this.focusNode,
    required this.searching,
    required this.hint,
    required this.onSearch,
    required this.onClear,
  });
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool searching;
  final String hint;
  final VoidCallback onSearch;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) => Container(
        decoration: BoxDecoration(
          color: tokens.surfaceElevated,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: tokens.border),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: .04), blurRadius: 14, offset: const Offset(0, 6))],
        ),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 10),
              child: AppIcon(Icons.search, size: 22, color: tokens.textSecondary),
            ),
            Expanded(
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                autocorrect: false,
                enableSuggestions: false,
                textInputAction: TextInputAction.search,
                onSubmitted: (_) => onSearch(),
                style: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w600),
                decoration: InputDecoration(
                  hintText: hint,
                  hintStyle: TextStyle(color: tokens.disabled, fontWeight: FontWeight.w400),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  filled: false,
                  contentPadding: const EdgeInsets.symmetric(vertical: 18),
                ),
              ),
            ),
            if (controller.text.isNotEmpty && !searching)
              IconButton(
                onPressed: onClear,
                icon: AppIcon(Icons.close, size: 18, color: tokens.textSecondary),
              ),
            Padding(
              padding: const EdgeInsets.all(6),
              child: SizedBox(
                width: 46,
                height: 46,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: tokens.textPrimary,
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  onPressed: searching ? null : onSearch,
                  child: searching
                      ? SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2.2, color: tokens.surface),
                        )
                      : AppIcon(Icons.arrow_forward, size: 20, color: tokens.surface),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The master found by the search, with a one-tap connect button.
class _MasterResultCard extends StatelessWidget {
  const _MasterResultCard({
    required this.master,
    required this.connection,
    required this.connecting,
    required this.onConnect,
  });
  final MasterBrief master;
  final ClientConnection? connection;
  final bool connecting;
  final VoidCallback onConnect;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    final language = context.watch<LanguageProvider>().language;
    String t({required String tk, required String ru, required String en}) => pickTr(language, tk: tk, ru: ru, en: en);
    final status = connection?.status;
    final connected = status == ConnectionStatus.accepted;
    final pending = status == ConnectionStatus.pending;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.black.withValues(alpha: .05)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: .08), blurRadius: 24, offset: const Offset(0, 10))],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: tokens.accent.withValues(alpha: .6), width: 1.6),
                ),
                child: MasterAvatar(url: master.photoUrl, radius: 32),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      master.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 2),
                    Text('@${master.nickname}', style: TextStyle(fontSize: 13.5, color: tokens.textSecondary)),
                    if (master.address.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          AppIcon(Icons.location_on_outlined, size: 13, color: tokens.textSecondary),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              master.address,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 12.5, color: tokens.textSecondary),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: (master.acceptingBookings ? freeSlotColorDark : tokens.warning).withValues(alpha: .12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                master.acceptingBookings
                    ? t(tk: 'Ýazgy kabul edýär', ru: 'Принимает записи', en: 'Accepting bookings')
                    : t(tk: 'Wagtlaýyn ýapyk', ru: 'Запись временно закрыта', en: 'Bookings paused'),
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: master.acceptingBookings ? freeSlotColorDark : tokens.warning,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: tokens.textPrimary,
                disabledBackgroundColor: tokens.surfaceElevated,
                shape: const StadiumBorder(),
              ),
              onPressed: connected || pending || connecting ? null : onConnect,
              icon: connecting
                  ? SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2.2, color: tokens.surface),
                    )
                  : AppIcon(
                      connected ? Icons.check : (pending ? Icons.hourglass_empty : Icons.person_add_alt_1),
                      size: 19,
                      color: connected || pending ? tokens.textSecondary : tokens.surface,
                    ),
              label: Text(
                connected
                    ? t(tk: 'Eýýäm baglanyşykly', ru: 'Уже подключены', en: 'Already connected')
                    : pending
                    ? t(tk: 'Haýyş iberildi', ru: 'Запрос отправлен', en: 'Request sent')
                    : t(tk: 'Baglan', ru: 'Подключиться', en: 'Connect'),
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: connected || pending ? tokens.textSecondary : tokens.surface,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NotFoundNote extends StatelessWidget {
  const _NotFoundNote({required this.title, required this.text});
  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 26, 20, 24),
      decoration: BoxDecoration(
        color: tokens.surfaceElevated,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: tokens.border),
      ),
      child: Column(
        children: [
          AppIcon(Icons.person_search_outlined, size: 44, color: tokens.textSecondary),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(fontSize: 16.5, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, height: 1.45, color: tokens.textSecondary),
          ),
        ],
      ),
    );
  }
}

/// Three numbered steps shown until the first search.
class _HowItWorks extends StatelessWidget {
  const _HowItWorks({required this.steps});
  final List<(IconData, String, String)> steps;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    return Column(
      children: [
        for (var i = 0; i < steps.length; i++)
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: tokens.surfaceElevated,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: tokens.border),
            ),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: tokens.surface,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: tokens.accent.withValues(alpha: .35)),
                  ),
                  child: AppIcon(steps[i].$1, size: 22, color: tokens.accent),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${i + 1}. ${steps[i].$2}', style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 3),
                      Text(
                        steps[i].$3,
                        style: TextStyle(fontSize: 12.5, height: 1.35, color: tokens.textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class RequestPendingScreen extends StatelessWidget {
  const RequestPendingScreen({super.key, required this.master});
  final MasterBrief master;
  @override
  Widget build(BuildContext context) {
    final language = context.watch<LanguageProvider>().language;
    String t({required String tk, required String ru, required String en}) => pickTr(language, tk: tk, ru: ru, en: en);
    return AppScaffold(
      title: t(tk: 'Haýyş iberildi', ru: 'Запрос отправлен', en: 'Request sent'),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xffF3E7D2)),
              child: AppIcon(Icons.hourglass_top_rounded, size: 38, color: context.appTokens.accent),
            ),
            const SizedBox(height: 24),
            Text(
              t(tk: 'Tassyklama garaşylýar', ru: 'Ожидание подтверждения', en: 'Waiting for confirmation'),
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 9),
            Text(
              t(
                tk: '${master.name} haýyşyňyz barada habarly bolar.',
                ru: '${master.name} получит уведомление о вашем запросе.',
                en: '${master.name} will be notified about your request.',
              ),
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 34),
            PrimaryButton(
              label: t(tk: 'Baş sahypa', ru: 'На главную', en: 'Go to home'),
              onTap: () => Navigator.pushAndRemoveUntil(context, pageRoute(const ClientHome()), (_) => false),
            ),
          ],
        ),
      ),
    );
  }
}
