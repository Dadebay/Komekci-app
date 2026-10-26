part of '../../../app/komekci_app.dart';

enum _FreeTimeAction { addAppointment, reserveForSelf }

/// Offers actions for the free interval selected in the master's calendar.
Future<void> _showFreeTimeActions(
  BuildContext context, {
  required DateTime start,
  required DateTime end,
  required DateTime availableEnd,
}) async {
  final language = context.read<LanguageProvider>().language;
  final tokens = context.appTokens;
  String t({required String tk, required String ru, required String en}) =>
      pickTr(language, tk: tk, ru: ru, en: en);

  final action = await showModalBottomSheet<_FreeTimeAction>(
    context: context,
    backgroundColor: tokens.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (sheetContext) {
      Widget option({
        required _FreeTimeAction action,
        required IconData icon,
        required String title,
        required String subtitle,
      }) => InkWell(
        onTap: () => Navigator.pop(sheetContext, action),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: AppIcon(icon, size: 22, color: tokens.textPrimary),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w700,
                        color: tokens.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12.5,
                        color: tokens.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );

      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                t(
                  tk: 'Wagt boýunça hereketler',
                  ru: 'Действия со временем',
                  en: 'Time slot actions',
                ),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: tokens.textPrimary,
                ),
              ),
              const SizedBox(height: 22),
              Divider(height: 1, color: tokens.border),
              option(
                action: _FreeTimeAction.addAppointment,
                icon: Icons.person_add_alt_1,
                title: t(
                  tk: 'Täze ýazgy goşmak',
                  ru: 'Добавить запись',
                  en: 'Add appointment',
                ),
                subtitle: t(
                  tk: 'Saýlanan wagta müşderi ýazmak.',
                  ru: 'Записать клиента на выбранное время.',
                  en: 'Book a client into this time slot.',
                ),
              ),
              Divider(height: 1, color: tokens.border),
              option(
                action: _FreeTimeAction.reserveForSelf,
                icon: Icons.schedule_outlined,
                title: t(
                  tk: 'Wagty özüm üçin ýapmak',
                  ru: 'Закрыть время для себя',
                  en: 'Block time for myself',
                ),
                subtitle: t(
                  tk: 'Öz işleriňiz üçin bu wagty ýapmak.',
                  ru: 'Закрыть это время для личных дел.',
                  en: 'Keep this time for personal tasks.',
                ),
              ),
            ],
          ),
        ),
      );
    },
  );

  if (!context.mounted) return;
  switch (action) {
    case _FreeTimeAction.addAppointment:
      if (!meetsBookingLeadTime(
        start,
        DateTime.now(),
        context.read<ScheduleProvider>().schedule?.minLeadMin ?? 30,
      )) {
        AppToast.of(context).error(
          t(
            tk: 'Bu wagta müşderi ýazmak üçin giç. Başga wagt saýlaň.',
            ru: 'Для записи клиента на это время уже поздно. Выберите другое.',
            en: 'It is too late to book a client for this time. Choose another.',
          ),
        );
        break;
      }
      await _NewSlotAppointmentSheet.show(context, start: start, end: end);
    case _FreeTimeAction.reserveForSelf:
      await _showBlockTimeSheet(
        context,
        start: start,
        end: end,
        availableEnd: availableEnd,
      );
    case null:
      break;
  }
}

Future<void> _showBlockTimeSheet(
  BuildContext context, {
  required DateTime start,
  required DateTime end,
  required DateTime availableEnd,
}) async {
  final language = context.read<LanguageProvider>().language;
  final tokens = context.appTokens;
  String t({required String tk, required String ru, required String en}) =>
      pickTr(language, tk: tk, ru: ru, en: en);
  if (!start.isAfter(DateTime.now()) ||
      !end.isAfter(start) ||
      end.difference(start) > const Duration(hours: 24)) {
    AppToast.of(context).error(
      t(
        tk: 'Bu wagty ýapyp bolmaýar. Geljekdäki wagt saýlaň.',
        ru: 'Это время закрыть нельзя. Выберите время в будущем.',
        en: 'This time cannot be blocked. Choose a future time.',
      ),
    );
    return;
  }
  final noteController = TextEditingController();
  var selectedEnd = end;
  final note = await showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    backgroundColor: tokens.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (sheetContext) => StatefulBuilder(
      builder: (sheetContext, setSheetState) => SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            22,
            20,
            20 + MediaQuery.viewInsetsOf(sheetContext).bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                t(tk: 'Wagty ýapmak', ru: 'Закрыть время', en: 'Block time'),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                '${formatDate(start)} · ${formatTime(TimeOfDay.fromDateTime(start))} – ${formatTime(TimeOfDay.fromDateTime(selectedEnd))}',
                style: TextStyle(color: tokens.textSecondary),
              ),
              if (availableEnd.isAfter(end)) ...[
                const SizedBox(height: 10),
                TextButton.icon(
                  onPressed: () async {
                    final picked = await showTimePicker(
                      context: sheetContext,
                      initialTime: TimeOfDay.fromDateTime(selectedEnd),
                    );
                    if (picked == null || !sheetContext.mounted) return;
                    final candidate = DateTime(
                      start.year,
                      start.month,
                      start.day,
                      picked.hour,
                      picked.minute,
                    );
                    if (!candidate.isAfter(start) ||
                        candidate.isAfter(availableEnd)) {
                      AppToast.of(sheetContext).error(
                        t(
                          tk: 'Tamamlanyş wagty boş aralygyň içinde bolmaly.',
                          ru: 'Конец должен быть внутри свободного промежутка.',
                          en: 'Choose an end time within the free interval.',
                        ),
                      );
                      return;
                    }
                    setSheetState(() => selectedEnd = candidate);
                  },
                  icon: const Icon(Icons.schedule_outlined),
                  label: Text(
                    t(
                      tk: 'Tamamlanyş wagtyny üýtget',
                      ru: 'Изменить время окончания',
                      en: 'Change end time',
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 18),
              TextField(
                controller: noteController,
                maxLength: 500,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: t(
                    tk: 'Şahsy bellik (hökmany däl)',
                    ru: 'Личная заметка (необязательно)',
                    en: 'Private note (optional)',
                  ),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () =>
                      Navigator.pop(sheetContext, noteController.text.trim()),
                  child: Text(t(tk: 'Ýapmak', ru: 'Закрыть', en: 'Block time')),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
  noteController.dispose();
  if (note == null || !context.mounted) return;
  final toast = AppToast.of(context);
  final ok = await runApi(context, () async {
    await context.read<ScheduleProvider>().blockTime(
      start,
      selectedEnd,
      note: note,
    );
  });
  if (ok) {
    toast.success(
      t(
        tk: 'Wagt ýapyldy. Müşderiler bu aralyga ýazylyp bilmez.',
        ru: 'Время закрыто. Клиенты не смогут записаться в этот промежуток.',
        en: 'Time blocked. Clients cannot book this interval.',
      ),
    );
  }
}

Future<void> _reopenClosedTime(BuildContext context, ClosedTime closed) async {
  final language = context.read<LanguageProvider>().language;
  String t({required String tk, required String ru, required String en}) =>
      pickTr(language, tk: tk, ru: ru, en: en);
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(t(tk: 'Wagty açmak', ru: 'Открыть время', en: 'Reopen time')),
      content: Text(
        t(
          tk: 'Bu wagt müşderiler üçin ýene elýeterli bolar.',
          ru: 'Этот промежуток снова станет доступен клиентам.',
          en: 'This time will become available to clients again.',
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, false),
          child: Text(t(tk: 'Ýatyr', ru: 'Отмена', en: 'Cancel')),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(dialogContext, true),
          child: Text(t(tk: 'Açmak', ru: 'Открыть', en: 'Reopen')),
        ),
      ],
    ),
  );
  if (confirmed != true || !context.mounted) return;
  final toast = AppToast.of(context);
  final ok = await runApi(
    context,
    () => context.read<ScheduleProvider>().reopenTime(closed),
  );
  if (ok) {
    toast.success(
      t(tk: 'Wagt açyldy.', ru: 'Время открыто.', en: 'Time reopened.'),
    );
  }
}
