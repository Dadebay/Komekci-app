part of '../../../app/komekci_app.dart';

// ── Step 3 — note & confirm ─────────────────────────────────────────────────

class BookingConfirmScreen extends StatefulWidget {
  const BookingConfirmScreen({
    super.key,
    required this.service,
    required this.masterName,
    required this.startsAt,
  });
  final SalonService service;
  final String masterName;
  final DateTime startsAt;

  @override
  State<BookingConfirmScreen> createState() => _BookingConfirmScreenState();
}

class _BookingConfirmScreenState extends State<BookingConfirmScreen> {
  final _noteController = TextEditingController();
  bool _notifyEarlier = false;
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _confirm(_Tr t) async {
    if (_submitting) return;
    setState(() {
      _submitting = true;
      _error = null;
    });

    final connectivity = await Connectivity().checkConnectivity();
    final offline = connectivity.every((r) => r == ConnectivityResult.none);
    if (offline) {
      setState(() {
        _submitting = false;
        _error = t(
          tk: 'Internet ýok. Baglanyşygy barlap gaýtadan synanyşyň.',
          ru: 'Нет подключения к интернету. Проверьте связь и попробуйте снова.',
          en: 'No internet connection. Check your connection and try again.',
        );
      });
      return;
    }

    if (!mounted) return;
    final bookingProvider = context.read<BookingProvider>();
    if (bookingProvider.hasConflict(widget.startsAt, widget.service.minutes)) {
      setState(() {
        _submitting = false;
        _error = t(
          tk: 'Bu wagt eýýäm alyndy. Başga wagt saýlaň.',
          ru: 'Это время уже занято. Выберите другое.',
          en: 'This time was just taken. Please choose another.',
        );
      });
      return;
    }

    await Future<void>.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;

    final appointment = bookingProvider.create(
      service: widget.service.name,
      startsAt: widget.startsAt,
      price: widget.service.price.toDouble(),
      minutes: widget.service.minutes,
      note: _noteController.text.trim(),
      notifyEarlierSlot: _notifyEarlier,
    );

    setState(() => _submitting = false);
    if (appointment == null) {
      setState(
        () => _error = t(
          tk: 'Bu wagt eýýäm alyndy. Başga wagt saýlaň.',
          ru: 'Это время уже занято. Выберите другое.',
          en: 'This time was just taken. Please choose another.',
        ),
      );
      return;
    }

    context.read<ClientBookingsProvider>().add(
      ClientBooking(
        id: appointment.id,
        masterName: widget.masterName,
        serviceName: widget.service.name,
        startsAt: appointment.startsAt,
        minutes: appointment.minutes,
        price: appointment.price,
        note: appointment.note,
      ),
    );

    Navigator.push(
      context,
      pageRoute(
        BookingSuccessScreen(
          appointment: appointment,
          masterName: widget.masterName,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final language = context.watch<LanguageProvider>().language;
    String t({required String tk, required String ru, required String en}) =>
        pickTr(language, tk: tk, ru: ru, en: en);
    final tokens = context.appTokens;
    final dateLabel = formatDate(widget.startsAt);
    final timeLabel =
        '${widget.startsAt.hour.toString().padLeft(2, '0')}:${widget.startsAt.minute.toString().padLeft(2, '0')}';

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
                          label: dateLabel,
                        ),
                        const SizedBox(height: 8),
                        _SummaryRow(
                          icon: Icons.schedule_outlined,
                          label:
                              '$timeLabel · ${widget.service.minutes} ${t(tk: "min", ru: "мин", en: "min")}',
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
                        '${widget.service.price} ${t(tk: "manat", ru: "манат", en: "TMT")}',
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

