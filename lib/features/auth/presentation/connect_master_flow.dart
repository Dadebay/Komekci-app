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
        _message = AppStrings.authEnterAtLeast3Characters.select(language);
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
      final found = await masters.lookup(
        isPhone ? toApiPhone(query) : query.toLowerCase(),
      );
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
    _controller.value = TextEditingValue(
      text: prefix,
      selection: TextSelection.collapsed(offset: prefix.length),
    );
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
                        border: Border.all(
                          color: tokens.border.withValues(alpha: .8),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: tokens.textPrimary.withValues(alpha: .06),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: AppIcon(
                        Icons.arrow_back,
                        size: 19,
                        color: tokens.textPrimary,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      AppStrings.authAddMaster.select(language),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 44),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
                children: [
                  _ConnectHero(
                    title: AppStrings.authConnectToYourMaster.select(language),
                    subtitle: AppStrings.authEnterYourMasterSNickname.select(
                      language,
                    ),
                  ),
                  const SizedBox(height: 22),
                  _SearchBox(
                    controller: _controller,
                    focusNode: _focus,
                    searching: _searching,
                    hint: AppStrings.authNicknameOr993Phone.select(language),
                    onSearch: _search,
                    onClear: _clear,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _HintChip(
                        icon: Icons.person_outline,
                        label: AppStrings.authNickname2.select(language),
                        onTap: () => _fill('@'),
                      ),
                      const SizedBox(width: 8),
                      _HintChip(
                        icon: Icons.phone_outlined,
                        label: AppStrings.profilePhone.select(language),
                        onTap: () => _fill('+993 '),
                      ),
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
                      title: AppStrings.authNoMasterFound.select(language),
                      text: AppStrings.authCheckThatTheNicknameOr.select(
                        language,
                      ),
                    )
                  else if (!_searching)
                    _HowItWorks(
                      title: AppStrings.authHowItWorks.select(language),
                      steps: [
                        (
                          Icons.chat_bubble_outline,
                          AppStrings.authAskYourMasterForTheir.select(language),
                          AppStrings.authOrUseTheirPhoneNumber.select(language),
                        ),
                        (
                          Icons.search,
                          AppStrings.authSearchAndSendARequest.select(language),
                          AppStrings.authTheMasterAddsYouTo.select(language),
                        ),
                        (
                          Icons.calendar_month_outlined,
                          AppStrings.authBookAppointments.select(language),
                          AppStrings.authOnceAcceptedYouCanSee.select(language),
                        ),
                      ],
                    ),
                ],
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pushAndRemoveUntil(
                context,
                pageRoute(const ClientHome()),
                (_) => false,
              ),
              child: Text(
                AppStrings.authILlConnectLater.select(language),
                style: TextStyle(
                  color: tokens.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
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
