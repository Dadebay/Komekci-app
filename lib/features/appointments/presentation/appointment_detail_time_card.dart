part of '../../../app/komekci_app.dart';

class _AppointmentTimeCard extends StatelessWidget {
  const _AppointmentTimeCard({required this.current, required this.language});

  final ClientBooking current;
  final AppLanguage language;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    final tk = language == AppLanguage.tk;
    final statusColor = _bookingStatusColor(tokens, current.status);
    final countdown = _bookingCountdown(current, language);
    String clock(DateTime d) => '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
    String t({required String tk, required String ru, required String en}) =>
        pickTr(language, tk: tk, ru: ru, en: en);
    return Container(
                    padding: const EdgeInsets.all(20),
                    decoration: _flatTintDecoration(tokens, statusColor),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _ClientBookingStatusChip(status: current.status, tk: tk),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                t(
                                  tk: 'Barmaly wagtyňyz',
                                  ru: 'Время прихода',
                                  en: 'Time to arrive',
                                ),
                                textAlign: TextAlign.end,
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: tokens.textPrimary),
                              ),
                            ),
                          ],
                        ),
                        if (countdown != null) ...[
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              AppIcon(Icons.timer_outlined, size: 15, color: tokens.textPrimary),
                              const SizedBox(width: 4),
                              Flexible(child: Text(countdown, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800))),
                            ],
                          ),
                        ],
                        const SizedBox(height: 18),
                        Text(formatDate(current.startsAt), style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, height: 1.1)),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            AppIcon(Icons.schedule_outlined, size: 22, color: statusColor),
                            const SizedBox(width: 8),
                            Text(
                              clock(current.startsAt),
                              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: statusColor),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${t(tk: 'Hyzmat wagty', ru: 'Время услуги', en: 'Service time')}: ${clock(current.startsAt)} – ${clock(current.endsAt)}',
                          style: TextStyle(fontSize: 12, color: tokens.textSecondary),
                        ),
                      ],
                    ),
                  );
  }
}
