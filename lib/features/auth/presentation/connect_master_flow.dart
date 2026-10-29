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
