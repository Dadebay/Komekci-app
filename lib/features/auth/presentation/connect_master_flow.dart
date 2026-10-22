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

  /// Seeds the field with a prefix and puts the caret after it.
  void _fill(String prefix) {
    _controller.value = TextEditingValue(text: prefix, selection: TextSelection.collapsed(offset: prefix.length));
    _focus.requestFocus();
    setState(() {
      _result = null;
      _notFound = false;
      _message = null;
    });
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

    return Scaffold(
      backgroundColor: tokens.surface,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 6),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.maybePop(context),
                    child: Container(
                      width: 44,
                      height: 44,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: tokens.surface,
                        shape: BoxShape.circle,
                        border: Border.all(color: tokens.border.withValues(alpha: .8)),
                        boxShadow: [BoxShadow(color: tokens.textPrimary.withValues(alpha: .06), blurRadius: 10, offset: const Offset(0, 3))],
                      ),
                      child: AppIcon(Icons.arrow_back, size: 19, color: tokens.textPrimary),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      t(tk: 'Master goş', ru: 'Добавить мастера', en: 'Add master'),
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                    ),
                  ),
                  const SizedBox(width: 44),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
                children: [
                  _ConnectHero(
                    title: t(tk: 'Masteriňize baglanyň', ru: 'Подключитесь к мастеру', en: 'Connect to your master'),
                    subtitle: t(
                      tk: 'Masteriň lakamyny ýa-da telefon belgisini giriziň',
                      ru: 'Введите никнейм или номер телефона мастера',
                      en: "Enter your master's nickname or phone number",
                    ),
                  ),
                  const SizedBox(height: 22),
                  _SearchBox(
                    controller: _controller,
                    focusNode: _focus,
                    searching: _searching,
                    hint: t(tk: '@lakam ýa-da +993 telefon', ru: '@никнейм или телефон +993', en: '@nickname or +993 phone'),
                    onSearch: _search,
                    onClear: _clear,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _HintChip(icon: Icons.person_outline, label: t(tk: 'Lakam', ru: 'Никнейм', en: 'Nickname'), onTap: () => _fill('@')),
                      const SizedBox(width: 8),
                      _HintChip(icon: Icons.phone_outlined, label: t(tk: 'Telefon', ru: 'Телефон', en: 'Phone'), onTap: () => _fill('+993 ')),
                    ],
                  ),
                  const SizedBox(height: 24),
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
                      title: t(tk: 'Master tapylmady', ru: 'Мастер не найден', en: 'No master found'),
                      text: t(
                        tk: 'Lakamy ýa-da telefon belgisini doly we dogry ýazandygyňyzy barlaň. Gözleg takyk deňleşdirme bilen işleýär.',
                        ru: 'Проверьте, что никнейм или номер введены полностью и без ошибок. Поиск работает по точному совпадению.',
                        en: 'Check that the nickname or number is complete and correct. Search only matches exactly.',
                      ),
                    )
                  else if (!_searching)
                    _HowItWorks(
                      title: t(tk: 'Nähili işleýär?', ru: 'Как это работает?', en: 'How it works'),
                      steps: [
                        (
                          Icons.chat_bubble_outline,
                          t(tk: 'Masterden lakamyny soraň', ru: 'Узнайте никнейм у мастера', en: 'Ask your master for their nickname'),
                          t(tk: 'Ýa-da onuň telefon belgisini ulanyň.', ru: 'Или воспользуйтесь его номером телефона.', en: 'Or use their phone number.'),
                        ),
                        (
                          Icons.search,
                          t(tk: 'Gözläň we haýyş iberiň', ru: 'Найдите и отправьте запрос', en: 'Search and send a request'),
                          t(tk: 'Master sizi öz müşderileriniň hataryna goşar.', ru: 'Мастер добавит вас в свои клиенты.', en: 'The master adds you to their clients.'),
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
            const SizedBox(height: 6),
          ],
        ),
      ),
    );
  }
}

/// Soft accent card at the top: haloed icon, heading and a line of help.
class _ConnectHero extends StatelessWidget {
  const _ConnectHero({required this.title, required this.subtitle});
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 16, 20),
      decoration: _flatTintDecoration(tokens, tokens.accent),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w800, height: 1.2)),
                const SizedBox(height: 8),
                Text(subtitle, style: TextStyle(fontSize: 13.5, height: 1.4, color: tokens.textSecondary)),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Container(
            width: 84,
            height: 84,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: tokens.accent.withValues(alpha: .16), shape: BoxShape.circle),
            child: Container(
              width: 60,
              height: 60,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: tokens.surface,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: tokens.accent.withValues(alpha: .3), blurRadius: 16, offset: const Offset(0, 6))],
              ),
              child: AppIcon(Icons.person_search_outlined, size: 28, color: tokens.accent),
            ),
          ),
        ],
      ),
    );
  }
}

/// Tap to start the field with "@" or "+993 ".
class _HintChip extends StatelessWidget {
  const _HintChip({required this.icon, required this.label, required this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: tokens.surfaceElevated,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: tokens.border.withValues(alpha: .7)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppIcon(icon, size: 14, color: tokens.textSecondary),
            const SizedBox(width: 6),
            Text(label, style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: tokens.textSecondary)),
          ],
        ),
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
      listenable: Listenable.merge([controller, focusNode]),
      builder: (context, _) => AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          color: tokens.surface,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: focusNode.hasFocus ? tokens.accent : tokens.border, width: focusNode.hasFocus ? 1.6 : 1),
          boxShadow: [BoxShadow(color: tokens.textPrimary.withValues(alpha: .06), blurRadius: 18, offset: const Offset(0, 8))],
        ),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 10),
              child: AppIcon(Icons.search, size: 22, color: focusNode.hasFocus ? tokens.accent : tokens.textSecondary),
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
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: searching ? null : onSearch,
                  child: searching
                      ? SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2.2, color: tokens.surface))
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
    final statusColor = master.acceptingBookings ? tokens.success : tokens.warning;

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: _bookingCardDecoration(tokens).copyWith(borderRadius: BorderRadius.circular(26)),
      child: Column(
        children: [
          Container(
            height: 78,
            color: tokens.surfaceElevated,
          ),
          // Only 46px of layout height: the avatar hangs 40px up into the banner.
          SizedBox(
            height: 46,
            child: OverflowBox(
              alignment: Alignment.topCenter,
              minHeight: 0,
              maxHeight: 100,
              child: Transform.translate(
                offset: const Offset(0, -40),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: tokens.surface,
                    boxShadow: [BoxShadow(color: tokens.textPrimary.withValues(alpha: .12), blurRadius: 14, offset: const Offset(0, 6))],
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: tokens.accent, width: 1.8)),
                    child: MasterAvatar(url: master.photoUrl, radius: 36),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
            child: Column(
              children: [
                Text(
                  master.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _ProfilePill(label: '@${master.nickname}'),
                    if (master.address.isNotEmpty) _ProfilePill(icon: Icons.location_on_outlined, label: master.address),
                    _ProfilePill(
                      dotColor: statusColor,
                      label: master.acceptingBookings
                          ? t(tk: 'Ýazgy kabul edýär', ru: 'Принимает записи', en: 'Accepting bookings')
                          : t(tk: 'Wagtlaýyn ýapyk', ru: 'Запись временно закрыта', en: 'Bookings paused'),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
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
                        ? SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2.2, color: tokens.surface))
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
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 28, 22, 26),
      decoration: _bookingCardDecoration(tokens).copyWith(borderRadius: BorderRadius.circular(26)),
      child: Column(
        children: [
          Container(
            width: 84,
            height: 84,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: tokens.warning.withValues(alpha: .12), shape: BoxShape.circle),
            child: AppIcon(Icons.person_search_outlined, size: 38, color: tokens.warning),
          ),
          const SizedBox(height: 16),
          Text(title, style: const TextStyle(fontSize: 17.5, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Text(text, textAlign: TextAlign.center, style: TextStyle(fontSize: 13, height: 1.5, color: tokens.textSecondary)),
        ],
      ),
    );
  }
}

/// Three steps on a vertical timeline, shown until the first search.
class _HowItWorks extends StatelessWidget {
  const _HowItWorks({required this.title, required this.steps});
  final String title;
  final List<(IconData, String, String)> steps;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(width: 4, height: 16, decoration: BoxDecoration(color: tokens.accent, borderRadius: BorderRadius.circular(2))),
            const SizedBox(width: 8),
            Text(title, style: const TextStyle(fontSize: 16.5, fontWeight: FontWeight.w800)),
          ],
        ),
        const SizedBox(height: 16),
        for (var i = 0; i < steps.length; i++)
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  width: 40,
                  child: Column(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: tokens.accent.withValues(alpha: .14),
                          border: Border.all(color: tokens.accent.withValues(alpha: .4)),
                        ),
                        child: AppIcon(steps[i].$1, size: 19, color: tokens.accent),
                      ),
                      if (i < steps.length - 1)
                        Expanded(
                          child: Container(width: 2, margin: const EdgeInsets.symmetric(vertical: 4), color: tokens.border),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: i < steps.length - 1 ? 20 : 0, top: 2),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${i + 1}. ${steps[i].$2}', style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 3),
                        Text(steps[i].$3, style: TextStyle(fontSize: 12.5, height: 1.4, color: tokens.textSecondary)),
                      ],
                    ),
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
    final tokens = context.appTokens;
    return AppScaffold(
      title: t(tk: 'Haýyş iberildi', ru: 'Запрос отправлен', en: 'Request sent'),
      titleInAppBar: true,
      child: Column(
        children: [
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 132,
                      height: 132,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(shape: BoxShape.circle, color: tokens.accent.withValues(alpha: .10)),
                      child: Container(
                        width: 100,
                        height: 100,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(shape: BoxShape.circle, color: tokens.accent.withValues(alpha: .18)),
                        child: Container(
                          width: 70,
                          height: 70,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: tokens.surface,
                            boxShadow: [BoxShadow(color: tokens.accent.withValues(alpha: .35), blurRadius: 18, offset: const Offset(0, 8))],
                          ),
                          child: AppIcon(Icons.hourglass_top_rounded, size: 32, color: tokens.accent),
                        ),
                      ),
                    ),
                    const SizedBox(height: 26),
                    Text(
                      t(tk: 'Tassyklama garaşylýar', ru: 'Ожидание подтверждения', en: 'Waiting for confirmation'),
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: tokens.textPrimary),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      t(
                        tk: '${master.name} haýyşyňyz barada habarly bolar.',
                        ru: '${master.name} получит уведомление о вашем запросе.',
                        en: '${master.name} will be notified about your request.',
                      ),
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, height: 1.45, color: tokens.textSecondary),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: _bookingCardDecoration(tokens),
                      child: Row(
                        children: [
                          MasterAvatar(url: master.photoUrl, radius: 26),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(master.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w700)),
                                const SizedBox(height: 2),
                                Text('@${master.nickname}', style: TextStyle(fontSize: 12.5, color: tokens.textSecondary)),
                              ],
                            ),
                          ),
                          _ProfilePill(dotColor: tokens.warning, label: t(tk: 'Garaşylýar', ru: 'Ожидание', en: 'Pending')),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          PrimaryButton(
            label: t(tk: 'Baş sahypa', ru: 'На главную', en: 'Go to home'),
            onTap: () => Navigator.pushAndRemoveUntil(context, pageRoute(const ClientHome()), (_) => false),
          ),
        ],
      ),
    );
  }
}
