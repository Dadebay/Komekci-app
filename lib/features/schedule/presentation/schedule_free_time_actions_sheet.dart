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
