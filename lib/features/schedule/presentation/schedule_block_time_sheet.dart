part of '../../../app/komekci_app.dart';

Future<void> _showBlockTimeSheet(
  BuildContext context, {
  required DateTime start,
  required DateTime end,
  required DateTime availableEnd,
}) async {
  final language = context.read<LanguageProvider>().language;
  final tokens = context.appTokens;
  if (!start.isAfter(DateTime.now()) ||
      !end.isAfter(start) ||
      end.difference(start) > const Duration(hours: 24)) {
    AppToast.of(
      context,
    ).error(AppStrings.scheduleThisTimeCannotBeBlocked.select(language));
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
                AppStrings.scheduleBlockTime.select(language),
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
                    final picked = await showClearTimePicker(
                      sheetContext,
                      initial: TimeOfDay.fromDateTime(selectedEnd),
                      language: language,
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
                        AppStrings.scheduleChooseAnEndTimeWithin.select(
                          language,
                        ),
                      );
                      return;
                    }
                    setSheetState(() => selectedEnd = candidate);
                  },
                  icon: const Icon(Icons.schedule_outlined),
                  label: Text(
                    AppStrings.scheduleChangeEndTime.select(language),
                  ),
                ),
              ],
              const SizedBox(height: 18),
              TextField(
                controller: noteController,
                maxLength: 500,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: AppStrings.schedulePrivateNoteOptional.select(
                    language,
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
                  child: Text(AppStrings.scheduleBlockTime2.select(language)),
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
      AppStrings.scheduleTimeBlockedClientsCannotBook.select(language),
    );
  }
}
