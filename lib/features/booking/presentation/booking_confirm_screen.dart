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

    final currency = context.watch<AppSettingsProvider>().currencyLabel(language);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: tokens.surface,
      body: SafeArea(
        child: Column(
          children: [
            _BookingHeader(
              master: widget.master,
              current: 3,
              labels: [
                AppStrings.bookingService.select(language),
                AppStrings.bookingTime2.select(language),
                AppStrings.bookingConfirm.select(language),
              ],
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.fromLTRB(20, 0, 20, 24 + MediaQuery.of(context).viewInsets.bottom),
                children: [
                  _BookingTitle(
                    title: AppStrings.bookingConfirmBooking.select(language),
                    subtitle: AppStrings.bookingCheckTheDetailsBelow.select(language),
                  ),
                  const SizedBox(height: 18),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: _bookingCardDecoration(tokens),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                widget.service.name,
                                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, height: 1.2),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              '${formatMoney(widget.service.price)} $currency',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: tokens.accent),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                child: _BookingInfoTile(
                                  icon: Icons.calendar_today_outlined,
                                  caption: AppStrings.bookingDate2.select(language),
                                  value: dateLabel,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _BookingInfoTile(
                                  icon: Icons.schedule_outlined,
                                  caption: AppStrings.bookingTime3.select(language),
                                  value: '$timeLabel · ${widget.service.durationMin} ${AppStrings.bookingMin.select(language)}',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
                    decoration: _bookingCardDecoration(tokens),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppStrings.bookingNote.select(language),
                          style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: _noteController,
                          maxLength: 200,
                          maxLines: 3,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: tokens.surfaceElevated,
                            hintText: AppStrings.bookingNoteForTheMasterOptional.select(language),
                          ),
                        ),
                        Material(
                          type: MaterialType.transparency,
                          child: CheckboxListTile(
                            value: _notifyEarlier,
                            onChanged: (v) => setState(() => _notifyEarlier = v ?? false),
                            controlAffinity: ListTileControlAffinity.leading,
                            contentPadding: EdgeInsets.zero,
                            dense: true,
                            activeColor: tokens.textPrimary,
                            title: Text(
                              AppStrings.bookingNotifyMeIfAnEarlier.select(language),
                              style: const TextStyle(fontSize: 13, height: 1.35),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 8),
                    RetryErrorState(
                      title: AppStrings.requestsSomethingWentWrong.select(language),
                      text: _error!,
                      retryLabel: AppStrings.profileTryAgain.select(language),
                      onRetry: () => _confirm(t),
                    ),
                    if (_suggestions.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        AppStrings.bookingNearestFreeTimes.select(language),
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
      bottomNavigationBar: _BookingBottomBar(
        caption: AppStrings.bookingTotal.select(language),
        value: '${formatMoney(widget.service.price)} $currency',
        label: AppStrings.bookingConfirmBooking2.select(language),
        loading: _submitting,
        onPressed: () => _confirm(t),
      ),
    );
  }
}

/// Caption + value tile with a tinted icon, used for date and time.
