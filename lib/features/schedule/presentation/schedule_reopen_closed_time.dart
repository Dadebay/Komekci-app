part of '../../../app/komekci_app.dart';

Future<void> _reopenClosedTime(BuildContext context, ClosedTime closed) async {
  final language = context.read<LanguageProvider>().language;
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(AppStrings.scheduleReopenTime.select(language)),
      content: Text(
        AppStrings.scheduleThisTimeWillBecomeAvailable.select(language),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, false),
          child: Text(AppStrings.servicesCancel.select(language)),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(dialogContext, true),
          child: Text(AppStrings.scheduleReopen.select(language)),
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
    toast.success(AppStrings.scheduleTimeReopened.select(language));
  }
}
