part of '../../../app/komekci_app.dart';

// ── Step 4 — success ────────────────────────────────────────────────────────

class BookingSuccessScreen extends StatefulWidget {
  const BookingSuccessScreen({
    super.key,
    required this.appointment,
    required this.masterName,
  });
  final ClientBooking appointment;
  final String masterName;

  @override
  State<BookingSuccessScreen> createState() => _BookingSuccessScreenState();
}

class _BookingSuccessScreenState extends State<BookingSuccessScreen>
    with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 420),
  )..forward();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final language = context.watch<LanguageProvider>().language;
    String t({required String tk, required String ru, required String en}) =>
        pickTr(language, tk: tk, ru: ru, en: en);
    final tokens = context.appTokens;
    final a = widget.appointment;
    final timeLabel =
        '${a.startsAt.hour.toString().padLeft(2, '0')}:${a.startsAt.minute.toString().padLeft(2, '0')}';

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            children: [
              const Spacer(),
              ScaleTransition(
                scale: CurvedAnimation(
                  parent: _controller,
                  curve: Curves.elasticOut,
                ),
                child: Container(
                  width: 92,
                  height: 92,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: tokens.accent,
                    shape: BoxShape.circle,
                  ),
                  child: AppIcon(Icons.check, size: 42, color: tokens.accentOn),
                ),
              ),
              const SizedBox(height: 26),
              Text(
                t(
                  tk: 'Randevu tassyklandy!',
                  ru: 'Запись подтверждена!',
                  en: 'Booking confirmed!',
                ),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                t(
                  tk: 'Master bildiriş aldy.',
                  ru: 'Мастер получил уведомление.',
                  en: 'Your master has been notified.',
                ),
                textAlign: TextAlign.center,
                style: TextStyle(color: tokens.textSecondary, height: 1.4),
              ),
              const SizedBox(height: 28),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: tokens.surfaceElevated,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: tokens.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      a.serviceName,
                      style: const TextStyle(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      widget.masterName,
                      style: TextStyle(
                        color: tokens.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(height: 1, color: tokens.border),
                    const SizedBox(height: 12),
                    _SummaryRow(
                      icon: Icons.calendar_today_outlined,
                      label: formatDate(a.startsAt),
                    ),
                    const SizedBox(height: 8),
                    _SummaryRow(
                      icon: Icons.schedule_outlined,
                      label:
                          '$timeLabel · ${a.minutes} ${t(tk: "min", ru: "мин", en: "min")}',
                    ),
                  ],
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: tokens.textPrimary,
                    shape: const StadiumBorder(),
                  ),
                  onPressed: () => Navigator.pushAndRemoveUntil(
                    context,
                    pageRoute(const ClientHome(initialTab: 2)),
                    (route) => false,
                  ),
                  child: Text(
                    t(
                      tk: 'Ýazgylaryma git',
                      ru: 'К моим записям',
                      en: 'Go to my bookings',
                    ),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () => Navigator.pushAndRemoveUntil(
                  context,
                  pageRoute(const ClientHome()),
                  (route) => false,
                ),
                child: Text(
                  t(tk: 'Baş sahypa', ru: 'На главную', en: 'Back to home'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
