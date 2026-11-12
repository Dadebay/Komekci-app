part of '../../../app/komekci_app.dart';

/// Client sign-in by SMS: the user texts the shown six-digit code to the
/// number the server names, and the app polls every 2 s until the server has
/// seen that SMS. On success the whole stack is replaced by [nextBuilder].
class SmsOtpScreen extends StatefulWidget {
  const SmsOtpScreen({
    super.key,
    required this.phone,
    required this.challenge,
    required this.nextBuilder,
    this.purpose = 'login',
  });

  /// API form, `+993XXXXXXXX`.
  final String phone;
  final SmsOtpChallenge challenge;
  final Widget Function(Me me) nextBuilder;
  final String purpose;

  @override
  State<SmsOtpScreen> createState() => _SmsOtpScreenState();
}

class _SmsOtpScreenState extends State<SmsOtpScreen> {
  static const _pollInterval = Duration(seconds: 2);
  static const _resendAfter = 60;

  late SmsOtpChallenge _challenge = widget.challenge;
  Timer? _poll;
  Timer? _clock;
  bool _polling = false;
  bool _resending = false;
  bool _expired = false;
  int _failedPolls = 0;
  int _secondsLeft = 0;
  int _sinceRequest = 0;
  String? _error;

  @override
  void initState() {
    super.initState();
    _start();
  }

  @override
  void dispose() {
    _poll?.cancel();
    _clock?.cancel();
    super.dispose();
  }

  void _start() {
    _expired = false;
    _failedPolls = 0;
    _sinceRequest = 0;
    _secondsLeft = _challenge.expiresIn;
    _poll?.cancel();
    _clock?.cancel();
    _poll = Timer.periodic(_pollInterval, (_) => _check());
    _clock = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        _sinceRequest += 1;
        if (_secondsLeft > 0) _secondsLeft -= 1;
        if (_secondsLeft == 0 && !_expired) {
          _expired = true;
          _poll?.cancel();
        }
      });
    });
  }

  void _stop() {
    _poll?.cancel();
    _clock?.cancel();
  }

  Future<void> _check() async {
    if (_polling || _expired || !mounted) return;
    _polling = true;
    final auth = context.read<AuthProvider>();
    final language = context.read<LanguageProvider>().language;
    final challenge = _challenge;
    try {
      final state = await auth.pollSmsOtp(challenge);
      // A resend may have replaced the challenge while this poll was in flight.
      if (!mounted || challenge != _challenge) return;
      switch (state) {
        case SmsOtpState.pending:
          if (_failedPolls != 0 || _error != null) {
            setState(() {
              _failedPolls = 0;
              _error = null;
            });
          }
        case SmsOtpState.verified:
          _stop();
          Navigator.of(context).pushAndRemoveUntil(
            pageRoute(widget.nextBuilder(auth.me!)),
            (route) => false,
          );
        case SmsOtpState.expired:
          _stop();
          setState(() {
            _expired = true;
            _error = null;
          });
        case SmsOtpState.failed:
          _stop();
          setState(() {
            _expired = true;
            _error = AppStrings.authCouldNotVerifyNoAccount.select(language);
          });
      }
    } catch (error) {
      if (!mounted) return;
      // One dropped poll is normal on a weak connection; say something only
      // when they keep failing.
      _failedPolls += 1;
      if (_failedPolls >= 3) {
        setState(() => _error = apiErrorMessage(error, language));
      }
      if (error is ApiException && error.statusCode == 404) {
        _stop();
        setState(() => _expired = true);
      }
    } finally {
      _polling = false;
    }
  }

  Future<void> _resend() async {
    if (_resending) return;
    final auth = context.read<AuthProvider>();
    final language = context.read<LanguageProvider>().language;
    setState(() {
      _resending = true;
      _error = null;
    });
    try {
      final next = await auth.requestSmsOtp(
        widget.phone,
        purpose: widget.purpose,
      );
      if (!mounted) return;
      if (next == null) {
        _stop();
        Navigator.of(context).pushAndRemoveUntil(
          pageRoute(widget.nextBuilder(auth.me!)),
          (route) => false,
        );
        return;
      }
      setState(() {
        _challenge = next;
        _resending = false;
      });
      _start();
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _resending = false;
        _error = apiErrorMessage(error, language);
      });
    }
  }

  Future<void> _openSmsApp() async {
    final uri = Uri(
      scheme: 'sms',
      path: _challenge.smsDestination,
      queryParameters: {'body': _challenge.otp},
    );
    try {
      if (await launchUrl(uri)) return;
    } catch (_) {}
    if (!mounted) return;
    _copy(_challenge.otp);
  }

  void _copy(String value) {
    final language = context.read<LanguageProvider>().language;
    Clipboard.setData(ClipboardData(text: value));
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 1),
          content: Text(AppStrings.authCopied.select(language)),
        ),
      );
  }

  String get _countdown =>
      '${(_secondsLeft ~/ 60).toString().padLeft(2, '0')}:${(_secondsLeft % 60).toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final language = context.watch<LanguageProvider>().language;
    final tokens = context.appTokens;
    final canResend = _expired || _sinceRequest >= _resendAfter;

    return Scaffold(
      backgroundColor: tokens.surface,
      appBar: AppBar(
        backgroundColor: tokens.surface,
        leading: IconButton(
          icon: const AppIcon(Icons.arrow_back),
          onPressed: () => Navigator.maybePop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
          child: Column(
            children: [
              AppIcon(Icons.sms_outlined, size: 68, color: tokens.accent),
              const SizedBox(height: 16),
              Text(
                AppStrings.authConfirmBySms.select(language),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -.3,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                AppStrings.authSendTheCodeBelowBy.select(language),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: tokens.textSecondary,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 22),
              _SmsInfoCard(
                label: AppStrings.authCode.select(language),
                value: _challenge.otp,
                big: true,
                dimmed: _expired,
                onCopy: () => _copy(_challenge.otp),
              ),
              const SizedBox(height: 12),
              _SmsInfoCard(
                label: AppStrings.authSendTo.select(language),
                value: _challenge.smsDestination,
                onCopy: () => _copy(_challenge.smsDestination),
              ),
              const SizedBox(height: 22),
              if (_error != null) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AppIcon(
                      Icons.error_outline,
                      size: 15,
                      color: tokens.danger,
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        _error!,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12.5, color: tokens.danger),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
              ],
              if (_expired)
                Text(
                  AppStrings.authTheCodeHasExpired.select(language),
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: tokens.textSecondary,
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: tokens.surfaceElevated,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: tokens.accent,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        AppStrings.authWaitingForSms(
                          _countdown,
                        ).select(language),
                        style: TextStyle(
                          fontSize: 12.5,
                          color: tokens.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: canResend && !_resending ? _resend : null,
                icon: AppIcon(
                  Icons.refresh,
                  size: 18,
                  color: canResend ? tokens.accent : tokens.disabled,
                ),
                label: Text(
                  _resending
                      ? AppStrings.authSending.select(language)
                      : canResend
                      ? AppStrings.authGetANewCode.select(language)
                      : AppStrings.authNewCodeInS(
                          _resendAfter - _sinceRequest,
                        ).select(language),
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: canResend ? tokens.accent : tokens.disabled,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 14),
          child: PrimaryButton(
            label: AppStrings.authSendSms.select(language),
            onTap: _expired ? _resend : _openSmsApp,
          ),
        ),
      ),
    );
  }
}

class _SmsInfoCard extends StatelessWidget {
  const _SmsInfoCard({
    required this.label,
    required this.value,
    required this.onCopy,
    this.big = false,
    this.dimmed = false,
  });
  final String label;
  final String value;
  final VoidCallback onCopy;
  final bool big;
  final bool dimmed;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 14, 8, 14),
      decoration: BoxDecoration(
        color: tokens.surfaceElevated,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: tokens.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: tokens.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: big ? 30 : 18,
                    fontWeight: FontWeight.w800,
                    letterSpacing: big ? 6 : .3,
                    color: dimmed ? tokens.disabled : tokens.textPrimary,
                    decoration: dimmed ? TextDecoration.lineThrough : null,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onCopy,
            icon: AppIcon(Icons.copy_rounded, size: 19, color: tokens.accent),
          ),
        ],
      ),
    );
  }
}
