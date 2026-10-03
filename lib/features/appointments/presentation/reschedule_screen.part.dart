part of '../../../app/komekci_app.dart';

/// Picks a new time for one of the client's bookings from the master's real
/// free slots (`GET /masters/{id}/availability`), then moves it
/// (`PATCH /appointments/{id}/move`).
class RescheduleScreen extends StatefulWidget {
  const RescheduleScreen({super.key, required this.booking});
  final ClientBooking booking;

  @override
  State<RescheduleScreen> createState() => _RescheduleScreenState();
}

class _RescheduleScreenState extends State<RescheduleScreen> {
  static const _horizonDays = 14;

  late final DateTime _today = appToday();
  late DateTime _selectedDate = _today;
  DateTime? _selectedSlot;
  Availability? _availability;
  Object? _error;
  bool _saving = false;
  String? _saveError;
  List<DateTime> _suggestions = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _availability = null;
      _error = null;
    });
    try {
      final result = await context.read<ClientRepository>().availability(
        widget.booking.masterId,
        serviceId: widget.booking.serviceId,
        from: _today,
        to: _today.add(const Duration(days: _horizonDays - 1)),
      );
      if (!mounted) return;
      setState(() {
        _availability = result;
        for (var i = 0; i < _horizonDays; i++) {
          final day = _today.add(Duration(days: i));
          if (_slotsFor(day).isNotEmpty) {
            _selectedDate = day;
            break;
          }
        }
      });
    } catch (error) {
      if (mounted) setState(() => _error = error);
    }
  }

  List<DateTime> _slotsFor(DateTime day) {
    final raw = _availability?.dates[formatApiDate(day)] ?? const <String>[];
    return [
      for (final s in raw)
        if (RegExp(r'^\d{1,2}:\d{2}').hasMatch(s)) DateTime(day.year, day.month, day.day, int.parse(s.split(':')[0]), int.parse(s.split(':')[1])),
    ];
  }

  Future<void> _confirm() async {
    final slot = _selectedSlot;
    if (slot == null || _saving) return;
    final language = context.read<LanguageProvider>().language;
    final bookings = context.read<ClientBookingsProvider>();
    final navigator = Navigator.of(context);
    setState(() {
      _saving = true;
      _saveError = null;
      _suggestions = const [];
    });
    try {
      await bookings.reschedule(widget.booking.id, slot);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _saveError = apiErrorMessage(error, language);
        if (error is ApiException && error.code == ApiErrors.slotTaken) {
          _suggestions = [for (final s in error.suggestedSlots) ?parseApiTime(s)];
        }
      });
      return;
    }
    navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    final language = context.watch<LanguageProvider>().language;
    String t({required String tk, required String ru, required String en}) => pickTr(language, tk: tk, ru: ru, en: en);
    final tokens = context.appTokens;
    final weekdayLabels = switch (language) {
      AppLanguage.tk => _weekdaysTk,
      AppLanguage.ru => _weekdaysRu,
      AppLanguage.en => weekdaysEn,
    };
    final days = List.generate(_horizonDays, (i) => _today.add(Duration(days: i)));
    final availability = _availability;
    final slots = _slotsFor(_selectedDate);

    return AppScaffold(
      title: t(tk: 'Randevuny üýtget', ru: 'Изменить запись', en: 'Change appointment'),
      subtitle: widget.booking.masterName,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ListView(
              children: [
                Text(
                  t(tk: 'Täze tarih', ru: 'Новая дата', en: 'New date'),
                  style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 68,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: days.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 8),
                    itemBuilder: (_, index) {
                      final day = days[index];
                      final open = _slotsFor(day).isNotEmpty;
                      final selected = day.year == _selectedDate.year && day.month == _selectedDate.month && day.day == _selectedDate.day;
                      return _DateChip(
                        weekday: weekdayLabels[day.weekday - 1],
                        dayNumber: day.day,
                        selected: selected,
                        enabled: open,
                        onTap: open
                            ? () => setState(() {
                                _selectedDate = day;
                                _selectedSlot = null;
                              })
                            : null,
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  t(tk: 'Täze wagt', ru: 'Новое время', en: 'New time'),
                  style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 10),
                if (_error != null)
                  RetryErrorState(
                    title: t(tk: 'Ýalňyşlyk', ru: 'Ошибка', en: 'Something went wrong'),
                    text: apiErrorMessage(_error!, language),
                    retryLabel: t(tk: 'Täzeden synanyş', ru: 'Повторить', en: 'Try again'),
                    onRetry: _load,
                  )
                else if (availability == null)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (!availability.acceptingBookings || slots.isEmpty)
                  EmptyState(
                    icon: Icons.schedule_outlined,
                    title: t(tk: 'Boş wagt ýok', ru: 'Свободного времени нет', en: 'No free slots'),
                    text: availability.message ?? t(tk: 'Başga gün saýlaň.', ru: 'Выберите другой день.', en: 'Please pick another day.'),
                  )
                else
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: slots.map((slot) {
                      final selected = _selectedSlot == slot;
                      return InkWell(
                        onTap: () => setState(() => _selectedSlot = slot),
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: selected ? tokens.textPrimary : tokens.surface,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: selected ? tokens.textPrimary : tokens.border),
                          ),
                          child: Text(
                            '${slot.hour.toString().padLeft(2, '0')}:${slot.minute.toString().padLeft(2, '0')}',
                            style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: selected ? tokens.surface : tokens.textPrimary),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                if (_saveError != null) ...[
                  const SizedBox(height: 12),
                  _FieldError(_saveError!),
                  if (_suggestions.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final slot in _suggestions)
                          ActionChip(
                            label: Text('${formatDate(slot)} · ${slot.hour.toString().padLeft(2, '0')}:${slot.minute.toString().padLeft(2, '0')}'),
                            onPressed: () => setState(() {
                              _selectedDate = DateTime(slot.year, slot.month, slot.day);
                              _selectedSlot = slot;
                              _saveError = null;
                              _suggestions = const [];
                            }),
                          ),
                      ],
                    ),
                  ],
                ],
              ],
            ),
          ),
          PrimaryButton(
            label: t(tk: 'Täze wagty tassykla', ru: 'Подтвердить новое время', en: 'Confirm new time'),
            loading: _saving,
            onTap: _selectedSlot == null ? () {} : _confirm,
          ),
        ],
      ),
    );
  }
}
