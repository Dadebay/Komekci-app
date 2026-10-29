part of '../../../app/komekci_app.dart';

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

