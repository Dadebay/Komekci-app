part of '../../../app/komekci_app.dart';

// ── Step 3 — note & confirm ─────────────────────────────────────────────────

class BookingConfirmScreen extends StatefulWidget {
  const BookingConfirmScreen({
    super.key,
    required this.service,
    required this.master,
    required this.startsAt,
  });
  final ApiService service;
  final MasterBrief master;
  final DateTime startsAt;

  @override
  State<BookingConfirmScreen> createState() => _BookingConfirmScreenState();
}

class _BookingConfirmScreenState extends State<BookingConfirmScreen> {
  final _noteController = TextEditingController();
  bool _notifyEarlier = false;
  bool _submitting = false;
  String? _error;

  /// Server's alternatives after `SLOT_TAKEN`.
  List<DateTime> _suggestions = const [];
  late DateTime _startsAt = widget.startsAt;

  /// Same key for every retry of this booking, so a lost response can never
  /// turn into two appointments.
  final String _idempotencyKey =
      '${DateTime.now().microsecondsSinceEpoch}-${Random().nextInt(1 << 32)}';

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _confirm(_Tr t) async {
    if (_submitting) return;
    final language = context.read<LanguageProvider>().language;
    final bookings = context.read<ClientBookingsProvider>();
    setState(() {
      _submitting = true;
      _error = null;
      _suggestions = const [];
    });
    final ClientBooking booking;
    try {
      booking = await bookings.book(
        serviceId: widget.service.id,
        startsAt: _startsAt,
        note: _noteController.text.trim(),
        waitlistEarlier: _notifyEarlier,
        idempotencyKey: '$_idempotencyKey-${_startsAt.millisecondsSinceEpoch}',
      );
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _error = apiErrorMessage(error, language);
        if (error is ApiException && error.code == ApiErrors.slotTaken) {
          _suggestions = _parseSuggestions(error.suggestedSlots);
        }
      });
      return;
    }
    if (!mounted) return;
    setState(() => _submitting = false);
    Navigator.push(
      context,
      pageRoute(BookingSuccessScreen(appointment: booking, masterName: widget.master.name)),
    );
  }

  /// `suggested_slots` come as clock times for the same day or full stamps.
  List<DateTime> _parseSuggestions(List<String> raw) {
    final out = <DateTime>[];
    for (final s in raw) {
      final clock = RegExp(r'^(\d{1,2}):(\d{2})').firstMatch(s);
      if (clock != null && !s.contains('-')) {
        out.add(DateTime(_startsAt.year, _startsAt.month, _startsAt.day,
            int.parse(clock.group(1)!), int.parse(clock.group(2)!)));
      } else {
        final parsed = parseApiTime(s);
        if (parsed != null) out.add(parsed);
      }
    }
    return out;
  }

  @override
  Widget build(BuildContext context) {
    final language = context.watch<LanguageProvider>().language;
    String t({required String tk, required String ru, required String en}) =>
        pickTr(language, tk: tk, ru: ru, en: en);
    final tokens = context.appTokens;
    final dateLabel = formatDate(_startsAt);
    final timeLabel =
        '${_startsAt.hour.toString().padLeft(2, '0')}:${_startsAt.minute.toString().padLeft(2, '0')}';

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: tokens.surface,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: tokens.surface,
        centerTitle: true,
        leading: IconButton(
          icon: const AppIcon(Icons.arrow_back),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: Text(
          t(tk: 'Randevu', ru: 'Запись', en: 'Booking'),
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 18),
              child: _WizardSteps(
                current: 3,
                labels: [
                  t(tk: 'Hyzmat', ru: 'Услуга', en: 'Service'),
                  t(tk: 'Wagt', ru: 'Время', en: 'Time'),
                  t(tk: 'Tassykla', ru: 'Подтв.', en: 'Confirm'),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.fromLTRB(24, 0, 24, 24 + MediaQuery.of(context).viewInsets.bottom),
                children: [
                  Text(
                    t(
                      tk: 'Tassyklaň',
                      ru: 'Подтвердите запись',
                      en: 'Confirm booking',
                    ),
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Colors.black.withValues(alpha: .05)),
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: .07), blurRadius: 20, offset: const Offset(0, 8))],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.service.name,
                          style: const TextStyle(
                            fontSize: 15.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          widget.master.name,
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
                          label: dateLabel,
                        ),
                        const SizedBox(height: 8),
                        _SummaryRow(
                          icon: Icons.schedule_outlined,
                          label:
                              '$timeLabel · ${widget.service.durationMin} ${t(tk: "min", ru: "мин", en: "min")}',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Colors.black.withValues(alpha: .05)),
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: .07), blurRadius: 20, offset: const Offset(0, 8))],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          t(tk: 'Bellik', ru: 'Заметка', en: 'Note'),
                          style: const TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: _noteController,
                          maxLength: 200,
                          maxLines: 3,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: tokens.surfaceElevated,
                            hintText: t(
                              tk: 'Ussa üçin bellik (hökmany däl)',
                              ru: 'Заметка для мастера (необязательно)',
                              en: 'Note for the master (optional)',
                            ),
                          ),
                        ),
                        CheckboxListTile(
                          value: _notifyEarlier,
                          onChanged: (v) =>
                              setState(() => _notifyEarlier = v ?? false),
                          controlAffinity: ListTileControlAffinity.leading,
                          contentPadding: EdgeInsets.zero,
                          dense: true,
                          activeColor: tokens.textPrimary,
                          title: Text(
                            t(
                              tk: 'Has erki wagt açylsa maňa habar ber',
                              ru: 'Сообщить, если освободится более раннее время',
                              en: 'Notify me if an earlier slot opens up',
                            ),
                            style: const TextStyle(fontSize: 13, height: 1.35),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 8),
                    RetryErrorState(
                      title: t(
                        tk: 'Ýalňyşlyk',
                        ru: 'Ошибка',
                        en: 'Something went wrong',
                      ),
                      text: _error!,
                      retryLabel: t(
                        tk: 'Täzeden synanyş',
                        ru: 'Повторить',
                        en: 'Try again',
                      ),
                      onRetry: () => _confirm(t),
                    ),
                    if (_suggestions.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        t(tk: 'Ýakyn boş wagtlar:', ru: 'Ближайшее свободное время:', en: 'Nearest free times:'),
                        style: TextStyle(fontSize: 12.5, color: tokens.textSecondary),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final slot in _suggestions)
                            ActionChip(
                              label: Text('${formatDate(slot)} · ${slot.hour.toString().padLeft(2, '0')}:${slot.minute.toString().padLeft(2, '0')}'),
                              onPressed: () {
                                setState(() {
                                  _startsAt = slot;
                                  _suggestions = const [];
                                  _error = null;
                                });
                              },
                            ),
                        ],
                      ),
                    ],
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: .06), blurRadius: 20, offset: const Offset(0, -6)),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 14, 24, 14),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        t(tk: 'Jemi', ru: 'Итого', en: 'Total'),
                        style: TextStyle(
                          fontSize: 11,
                          color: tokens.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${formatMoney(widget.service.price)} ${context.watch<AppSettingsProvider>().currencyLabel(language)}',
                        style: const TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  height: 56,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: tokens.textPrimary,
                      shape: const StadiumBorder(),
                      padding: const EdgeInsets.symmetric(horizontal: 26),
                    ),
                    onPressed: _submitting ? null : () => _confirm(t),
                    child: _submitting
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.4,
                              color: tokens.surface,
                            ),
                          )
                        : Text(
                            t(
                              tk: 'Randevuny tassykla',
                              ru: 'Подтвердить запись',
                              en: 'Confirm booking',
                            ),
                            style: const TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    return Row(
      children: [
        AppIcon(icon, size: 15, color: t.textSecondary),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

