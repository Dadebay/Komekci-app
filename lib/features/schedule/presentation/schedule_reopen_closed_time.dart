part of '../../../app/komekci_app.dart';

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
