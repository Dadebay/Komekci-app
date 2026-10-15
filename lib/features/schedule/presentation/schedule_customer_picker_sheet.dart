part of '../../../app/komekci_app.dart';

class _SheetAction extends StatelessWidget {
  const _SheetAction({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.danger = false,
    this.callAction = false,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool danger;
  final bool callAction;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: danger
                    ? tokens.danger.withValues(alpha: .14)
                    : tokens.surfaceElevated,
                shape: BoxShape.circle,
              ),
              child: AppIcon(
                icon,
                size: 17,
                color: danger ? tokens.danger : tokens.textPrimary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: danger ? tokens.danger : tokens.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11.5,
                      color: tokens.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (callAction)
              // Deliberately fixed white icon: sits on the always-green call
              // avatar (0xff2FAE60), which is not part of the token system.
              const CircleAvatar(
                radius: 17,
                backgroundColor: Color(0xff2FAE60),
                child: AppIcon(
                  Icons.phone_outlined,
                  size: 15,
                  color: Colors.white,
                ),
              )
            else
              AppIcon(
                Icons.chevron_right,
                size: 16,
                color: tokens.textSecondary,
              ),
          ],
        ),
      ),
    );
  }
}

/// Custom date + time sheet used everywhere the app needs to pick a moment
/// in time — deliberately replaces the plain OS date/time pickers with a
/// sheet that matches the rest of the app (reuses [_MonthCalendar]).
Future<DateTime?> _pickAppointmentDateTime(
  BuildContext context, {
  required AppLanguage language,
  required DateTime initial,
  required int minutes,
  required String excludeId,
  required BookingProvider bookingProvider,
}) {
  var month = DateTime(initial.year, initial.month);
  var selectedDate = DateTime(initial.year, initial.month, initial.day);
  var selectedTime = TimeOfDay.fromDateTime(initial);
  final quickTimes = List.generate(20, (i) {
    final total = 9 * 60 + i * 30;
    return TimeOfDay(hour: total ~/ 60, minute: total % 60);
  });
  final tokens = context.appTokens;

  DateTime candidateFor(TimeOfDay time) => DateTime(
    selectedDate.year,
    selectedDate.month,
    selectedDate.day,
    time.hour,
    time.minute,
  );

  bool canChoose(TimeOfDay time) {
    final candidate = candidateFor(time);
    return appointmentFitsWorkingTime(
          context.read<ScheduleProvider>().schedule,
          candidate,
          minutes,
        ) &&
        !bookingProvider.hasConflict(candidate, minutes, excludeId: excludeId);
  }

  return showModalBottomSheet<DateTime>(
    context: context,
    backgroundColor: tokens.surface,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (sheetContext) => StatefulBuilder(
      builder: (sheetContext, setSheetState) => SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            12,
            20,
            MediaQuery.of(sheetContext).viewInsets.bottom + 16,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: tokens.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  pickTr(
                    language,
                    tk: 'Sene we wagt saýlaň',
                    ru: 'Выберите дату и время',
                    en: 'Choose a date and time',
                  ),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${pickTr(language, tk: 'Häzirki wagt', ru: 'Текущее время', en: 'Current time')}: ${formatDate(initial)} · ${formatTime(TimeOfDay.fromDateTime(initial))}',
                  style: TextStyle(fontSize: 12.5, color: tokens.textSecondary),
                ),
                const SizedBox(height: 16),
                _MonthCalendar(
                  month: month,
                  selected: selectedDate,
                  language: language,
                  onSelect: (d) {
                    setSheetState(() => selectedDate = d);
                    // Busy slots are drawn from the cached calendar; make
                    // sure that month has been fetched.
                    bookingProvider.ensureLoaded(d).then((_) {
                      if (sheetContext.mounted) setSheetState(() {});
                    });
                  },
                  onPrevMonth: () {
                    setSheetState(
                      () => month = DateTime(month.year, month.month - 1),
                    );
                    bookingProvider.ensureLoaded(month).then((_) {
                      if (sheetContext.mounted) setSheetState(() {});
                    });
                  },
                  onNextMonth: () {
                    setSheetState(
                      () => month = DateTime(month.year, month.month + 1),
                    );
                    bookingProvider.ensureLoaded(month).then((_) {
                      if (sheetContext.mounted) setSheetState(() {});
                    });
                  },
                ),
                const SizedBox(height: 18),
                Text(
                  pickTr(language, tk: 'Wagt', ru: 'Время', en: 'Time'),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: quickTimes.map((t) {
                    final selected =
                        selectedTime.hour == t.hour &&
                        selectedTime.minute == t.minute;
                    final taken = !canChoose(t);
                    return GestureDetector(
                      onTap: taken
                          ? null
                          : () => setSheetState(() => selectedTime = t),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 13,
                          vertical: 9,
                        ),
                        decoration: BoxDecoration(
                          color: taken
                              ? tokens.disabled.withValues(alpha: .12)
                              : selected
                              ? tokens.textPrimary
                              : tokens.surface,
                          borderRadius: BorderRadius.circular(11),
                          border: Border.all(
                            color: taken
                                ? tokens.border
                                : selected
                                ? tokens.textPrimary
                                : tokens.border,
                          ),
                        ),
                        child: Text(
                          formatTime(t),
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            decoration: taken
                                ? TextDecoration.lineThrough
                                : null,
                            color: taken
                                ? tokens.disabled
                                : selected
                                ? tokens.surface
                                : tokens.textPrimary,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 22),
                _MasterActionButton(
                  label: pickTr(
                    language,
                    tk: 'Tassykla',
                    ru: 'Подтвердить',
                    en: 'Confirm',
                  ),
                  enabled: canChoose(selectedTime),
                  leading: Icons.check,
                  onTap: () =>
                      Navigator.pop(sheetContext, candidateFor(selectedTime)),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

class _ChoiceCard extends StatelessWidget {
  const _ChoiceCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected
              ? tokens.accent.withValues(alpha: .08)
              : tokens.surfaceElevated,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? tokens.accent : tokens.border,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected
                    ? tokens.accent.withValues(alpha: .14)
                    : tokens.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: AppIcon(
                icon,
                size: 16,
                color: selected ? tokens.accent : tokens.textPrimary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: tokens.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11.5,
                      color: tokens.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            AppIcon(
              selected ? Icons.check_circle : Icons.chevron_right,
              size: selected ? 20 : 17,
              color: selected ? tokens.accent : tokens.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

/// Search-and-pick sheet for choosing an existing [Customer].
class _CustomerPickerSheet extends StatefulWidget {
  const _CustomerPickerSheet({required this.customers, required this.language});
  final List<Customer> customers;
  final AppLanguage language;

  @override
  State<_CustomerPickerSheet> createState() => _CustomerPickerSheetState();
}

class _CustomerPickerSheetState extends State<_CustomerPickerSheet> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    final language = widget.language;
    final tk = language == AppLanguage.tk;
    String t({required String tk, required String ru, required String en}) =>
        pickTr(language, tk: tk, ru: ru, en: en);
    final query = _controller.text.trim().toLowerCase();
    final digits = query.replaceAll(RegExp(r'\D'), '');
    final results = query.isEmpty
        ? widget.customers
        : widget.customers
              .where(
                (c) =>
                    c.name.toLowerCase().contains(query) ||
                    (digits.isNotEmpty &&
                        c.phone.replaceAll(RegExp(r'\D'), '').contains(digits)),
              )
              .toList();
    final keyboardInset = MediaQuery.viewInsetsOf(context).bottom;
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.only(bottom: keyboardInset),
        child: SizedBox(
          height: (MediaQuery.sizeOf(context).height - keyboardInset) * .82,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: tokens.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 12, 18),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            t(
                              tk: 'Müşderi saýlaň',
                              ru: 'Выберите клиента',
                              en: 'Choose a customer',
                            ),
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: tokens.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            t(
                              tk: 'Ýazgy üçin müşderini tapyň',
                              ru: 'Найдите клиента для записи',
                              en: 'Find a customer for this booking',
                            ),
                            style: TextStyle(
                              fontSize: 12.5,
                              color: tokens.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: t(tk: 'Ýap', ru: 'Закрыть', en: 'Close'),
                      onPressed: () => Navigator.pop(context),
                      icon: AppIcon(
                        Icons.close,
                        size: 20,
                        color: tokens.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  height: 52,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: tokens.surfaceElevated,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: tokens.border),
                  ),
                  child: TextField(
                    controller: _controller,
                    onChanged: (_) => setState(() {}),
                    textInputAction: TextInputAction.search,
                    style: TextStyle(fontSize: 14, color: tokens.textPrimary),
                    decoration: InputDecoration(
                      filled: false,
                      hintText: t(
                        tk: 'Ady ýa-da telefon belgisi',
                        ru: 'Имя или номер телефона',
                        en: 'Name or phone number',
                      ),
                      hintStyle: TextStyle(color: tokens.textSecondary),
                      prefixIcon: Center(
                        widthFactor: 1,
                        heightFactor: 1,
                        child: SizedBox.square(
                          dimension: 18,
                          child: AppIcon(
                            Icons.search,
                            size: 18,
                            color: tokens.textSecondary,
                          ),
                        ),
                      ),
                      prefixIconConstraints: const BoxConstraints(
                        minWidth: 44,
                        minHeight: 44,
                      ),
                      suffixIcon: query.isEmpty
                          ? null
                          : IconButton(
                              tooltip: t(
                                tk: 'Arassala',
                                ru: 'Очистить',
                                en: 'Clear',
                              ),
                              onPressed: () {
                                _controller.clear();
                                setState(() {});
                              },
                              icon: AppIcon(
                                Icons.close,
                                size: 18,
                                color: tokens.textSecondary,
                              ),
                            ),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 10),
                child: Row(
                  children: [
                    Text(
                      query.isEmpty
                          ? t(
                              tk: 'Ähli müşderiler',
                              ru: 'Все клиенты',
                              en: 'All customers',
                            )
                          : t(
                              tk: 'Gözleg netijeleri',
                              ru: 'Результаты поиска',
                              en: 'Search results',
                            ),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: tokens.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: tokens.surfaceElevated,
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: Text(
                        '${results.length}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: tokens.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: results.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 64,
                                height: 64,
                                decoration: BoxDecoration(
                                  color: tokens.surfaceElevated,
                                  shape: BoxShape.circle,
                                ),
                                child: AppIcon(
                                  query.isEmpty
                                      ? Icons.people_outline
                                      : Icons.person_search_outlined,
                                  size: 27,
                                  color: tokens.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                t(
                                  tk: 'Müşderi tapylmady',
                                  ru: 'Клиенты не найдены',
                                  en: 'No customers found',
                                ),
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: tokens.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                query.isEmpty
                                    ? t(
                                        tk: 'Entek müşderi goşulmady',
                                        ru: 'Клиенты ещё не добавлены',
                                        en: 'No customers added yet',
                                      )
                                    : t(
                                        tk: 'Başga at ýa-da belgi bilen gözläň',
                                        ru: 'Попробуйте другое имя или номер',
                                        en: 'Try another name or number',
                                      ),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 12.5,
                                  color: tokens.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: EdgeInsets.fromLTRB(
                          20,
                          0,
                          20,
                          16 + MediaQuery.paddingOf(context).bottom,
                        ),
                        keyboardDismissBehavior:
                            ScrollViewKeyboardDismissBehavior.onDrag,
                        itemCount: results.length,
                        itemBuilder: (_, i) {
                          final c = results[i];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Material(
                              color: tokens.surfaceElevated,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                                side: BorderSide(color: tokens.border),
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: InkWell(
                                onTap: () => Navigator.pop(context, c),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 11,
                                  ),
                                  child: Row(
                                    children: [
                                      _CustomerAvatar(customer: c, radius: 22),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              c.name,
                                              style: TextStyle(
                                                fontSize: 14.5,
                                                fontWeight: FontWeight.w700,
                                                color: tokens.textPrimary,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            Text(
                                              c.phone,
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: tokens.textSecondary,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      _StatusBadge2(
                                        label: _statusLabel(c.status, tk),
                                        color: _statusColor(c.status, tokens),
                                        bg: _statusBg(c.status, tokens),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
