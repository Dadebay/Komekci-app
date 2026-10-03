part of '../../../app/komekci_app.dart';

/// Find a master by exact @nickname or phone and send a connection request.
class ConnectMasterScreen extends StatefulWidget {
  const ConnectMasterScreen({super.key});
  @override
  State<ConnectMasterScreen> createState() => _ConnectMasterScreenState();
}

class _ConnectMasterScreenState extends State<ConnectMasterScreen> {
  final _controller = TextEditingController();
  bool _searching = false;
  MasterBrief? _result;
  String? _message;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    final query = _controller.text.trim().replaceFirst('@', '');
    final language = context.read<LanguageProvider>().language;
    final masters = context.read<ClientMastersProvider>();
    if (query.length < 3) {
      setState(() {
        _result = null;
        _message = pickTr(
          language,
          tk: 'Iň az 3 simwol giriziň',
          ru: 'Введите минимум 3 символа',
          en: 'Enter at least 3 characters',
        );
      });
      return;
    }
    // Phone numbers are matched exactly, so send them in API form.
    final isPhone = RegExp(r'^[+\d\s]+$').hasMatch(query);
    setState(() {
      _searching = true;
      _message = null;
      _result = null;
    });
    try {
      final found = await masters.lookup(isPhone ? toApiPhone(query) : query.toLowerCase());
      if (!mounted) return;
      setState(() {
        _searching = false;
        _result = found;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _searching = false;
        _message = apiErrorMessage(error, language);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final language = context.watch<LanguageProvider>().language;
    String t({required String tk, required String ru, required String en}) => pickTr(language, tk: tk, ru: ru, en: en);
    final tokens = context.appTokens;
    final result = _result;
    return AppScaffold(
      title: t(tk: 'Ustaňyza baglanyň', ru: 'Подключитесь к мастеру', en: 'Connect to your master'),
      subtitle: t(
        tk: 'Lakamyny ýa-da telefon belgisini giriziň.',
        ru: 'Введите никнейм или номер телефона.',
        en: 'Enter a nickname or phone number.',
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          TextField(
            controller: _controller,
            textInputAction: TextInputAction.search,
            onSubmitted: (_) => _search(),
            decoration: InputDecoration(
              prefixIcon: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: AppIcon(Icons.search, size: 24, color: tokens.textSecondary),
              ),
              prefixIconConstraints: const BoxConstraints(minWidth: 46),
              suffixIcon: _searching
                  ? const Padding(
                      padding: EdgeInsets.all(14),
                      child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                    )
                  : IconButton(
                      onPressed: _search,
                      icon: AppIcon(Icons.arrow_forward, color: tokens.accent),
                    ),
              labelText: t(tk: '@lakam ýa-da telefon', ru: '@никнейм или телефон', en: 'Search @nickname or phone'),
              floatingLabelBehavior: FloatingLabelBehavior.never,
            ),
          ),
          const SizedBox(height: 20),
          if (result != null)
            InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: () => Navigator.push(context, pageRoute(MasterPreviewScreen(master: result))),
              child: MasterPreviewCard(master: result),
            ),
          if (_message != null) _FieldError(_message!),
          const Spacer(),
          TextButton(
            onPressed: () => Navigator.pushAndRemoveUntil(context, pageRoute(const ClientHome()), (_) => false),
            child: Center(child: Text(t(tk: 'Soňrak baglanaryn', ru: 'Подключусь позже', en: 'I’ll connect later'))),
          ),
        ],
      ),
    );
  }
}

class MasterPreviewScreen extends StatefulWidget {
  const MasterPreviewScreen({super.key, required this.master});
  final MasterBrief master;
  @override
  State<MasterPreviewScreen> createState() => _MasterPreviewScreenState();
}

class _MasterPreviewScreenState extends State<MasterPreviewScreen> {
  bool _sending = false;
  String? _error;

  Future<void> _send() async {
    final language = context.read<LanguageProvider>().language;
    final masters = context.read<ClientMastersProvider>();
    setState(() {
      _sending = true;
      _error = null;
    });
    try {
      await masters.connect(widget.master.id);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _sending = false;
        _error = apiErrorMessage(error, language);
      });
      return;
    }
    if (!mounted) return;
    Navigator.push(context, pageRoute(RequestPendingScreen(master: widget.master)));
  }

  @override
  Widget build(BuildContext context) {
    final language = context.watch<LanguageProvider>().language;
    String t({required String tk, required String ru, required String en}) => pickTr(language, tk: tk, ru: ru, en: en);
    final master = widget.master;
    return AppScaffold(
      title: master.name,
      subtitle: '@${master.nickname}${master.address.isEmpty ? '' : ' · ${master.address}'}',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(child: MasterAvatar(url: master.photoUrl, radius: 64)),
          const SizedBox(height: 20),
          if (!master.acceptingBookings)
            Text(
              t(
                tk: 'Usta häzirlikçe täze ýazgylary kabul etmeýär.',
                ru: 'Мастер временно не принимает новые записи.',
                en: 'This master is not accepting new bookings right now.',
              ),
              style: TextStyle(color: context.appTokens.textSecondary, height: 1.45),
            ),
          if (_error != null) _FieldError(_error!),
          const Spacer(),
          PrimaryButton(
            label: t(tk: 'Haýyş iber', ru: 'Отправить запрос', en: 'Send request'),
            loading: _sending,
            onTap: _send,
          ),
        ],
      ),
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
