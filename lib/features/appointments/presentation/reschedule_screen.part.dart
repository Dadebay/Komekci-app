part of '../../../app/komekci_app.dart';

/// A lightweight reschedule picker for the client's own bookings. Unlike the
/// booking wizard's date/time screen, this isn't checked against a real
/// master calendar — `ClientBookingsProvider` only models the client's own
/// cross-master list, not any individual master's live availability.
class RescheduleScreen extends StatefulWidget {
  const RescheduleScreen({super.key, required this.booking});
  final ClientBooking booking;

  @override
  State<RescheduleScreen> createState() => _RescheduleScreenState();
}

class _RescheduleScreenState extends State<RescheduleScreen> {
  static final _today = DateTime(
    dashboardToday.$1,
    dashboardToday.$2,
    dashboardToday.$3,
  );
  static const _timeOptions = [
    '09:00',
    '10:30',
    '12:00',
    '14:00',
    '15:30',
    '17:00',
    '18:30',
  ];
  late DateTime _selectedDate = widget.booking.startsAt.isAfter(_today)
      ? DateTime(
          widget.booking.startsAt.year,
          widget.booking.startsAt.month,
          widget.booking.startsAt.day,
        )
      : _today;
  String? _selectedTime;

  @override
  Widget build(BuildContext context) {
    final language = context.watch<LanguageProvider>().language;
    String t({required String tk, required String ru, required String en}) =>
        pickTr(language, tk: tk, ru: ru, en: en);
    final tokens = context.appTokens;
    final weekdayLabels = switch (language) {
      AppLanguage.tk => _weekdaysTk,
      AppLanguage.ru => _weekdaysRu,
      AppLanguage.en => weekdaysEn,
    };
    final days = List.generate(10, (i) => _today.add(Duration(days: i)));

    return AppScaffold(
      title: t(
        tk: 'Randevuny üýtget',
        ru: 'Изменить запись',
        en: 'Change appointment',
      ),
      subtitle: widget.booking.masterName,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
                final open = isSalonOpen(day);
                final selected =
                    day.year == _selectedDate.year &&
                    day.month == _selectedDate.month &&
                    day.day == _selectedDate.day;
                return _DateChip(
                  weekday: weekdayLabels[day.weekday - 1],
                  dayNumber: day.day,
                  selected: selected,
                  enabled: open,
                  onTap: open
                      ? () => setState(() => _selectedDate = day)
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
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _timeOptions.map((time) {
              final selected = _selectedTime == time;
              return InkWell(
                onTap: () => setState(() => _selectedTime = time),
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: selected ? tokens.textPrimary : tokens.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: selected ? tokens.textPrimary : tokens.border,
                    ),
                  ),
                  child: Text(
                    time,
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: selected ? tokens.surface : tokens.textPrimary,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const Spacer(),
          PrimaryButton(
            label: t(
              tk: 'Täze wagty tassykla',
              ru: 'Подтвердить новое время',
              en: 'Confirm new time',
            ),
            onTap: _selectedTime == null
                ? () {}
                : () {
                    final parts = _selectedTime!.split(':');
                    final newStart = DateTime(
                      _selectedDate.year,
                      _selectedDate.month,
                      _selectedDate.day,
                      int.parse(parts[0]),
                      int.parse(parts[1]),
                    );
                    context.read<ClientBookingsProvider>().reschedule(
                      widget.booking.id,
                      newStart,
                    );
                    Navigator.pop(context);
                  },
          ),
        ],
      ),
    );
  }
}

