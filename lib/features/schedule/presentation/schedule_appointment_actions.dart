part of '../../../app/komekci_app.dart';

void _openAppointmentActions(
  BuildContext context,
  Appointment appointment,
  Customer? customer,
  AppLanguage language,
) {
  String t({required String tk, required String ru, required String en}) =>
      pickTr(language, tk: tk, ru: ru, en: en);
  final tokens = context.appTokens;
  final phone = _appointmentPhone(appointment, customer);
  showModalBottomSheet(
    context: context,
    backgroundColor: tokens.surface,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (sheetContext) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
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
            const SizedBox(height: 18),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                customer == null
                    ? CircleAvatar(
                        radius: 20,
                        backgroundColor: tokens.accent.withValues(alpha: .2),
                        child: AppIcon(
                          Icons.person_outline,
                          size: 18,
                          color: tokens.textPrimary,
                        ),
                      )
                    : _CustomerAvatar(customer: customer, radius: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        appointment.clientName,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (customer != null)
                        Text(
                          _handleFor(customer),
                          style: TextStyle(
                            fontSize: 11.5,
                            color: tokens.textSecondary,
                          ),
                        ),
                      Text(
                        appointment.serviceName,
                        style: TextStyle(
                          fontSize: 12.5,
                          color: tokens.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (customer != null)
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: _StatusBadge2(
                      label: _scheduleCustomerLabel(customer.status, language),
                      color: _statusColor(customer.status, tokens),
                      bg: _statusBg(customer.status, tokens),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            if (appointment.status == AppointmentStatus.expected) ...[
              _SheetAction(
                icon: Icons.check_circle_outline,
                title: t(
                  tk: 'Geldi diýip belle',
                  ru: 'Отметить «Пришёл»',
                  en: 'Mark as arrived',
                ),
                subtitle: t(
                  tk: 'Müşderi geldi',
                  ru: 'Клиент пришёл',
                  en: 'Customer arrived',
                ),
                onTap: () {
                  Navigator.pop(sheetContext);
                  context.read<BookingProvider>().arrive(appointment.id);
                },
              ),
              _SheetAction(
                icon: Icons.person_off_outlined,
                danger: true,
                title: t(
                  tk: 'Gelmedi diýip belle',
                  ru: 'Отметить «Не пришёл»',
                  en: 'Mark as no-show',
                ),
                subtitle: t(
                  tk: 'Müşderi gelmedi',
                  ru: 'Клиент не пришёл',
                  en: 'Customer did not show up',
                ),
                onTap: () {
                  Navigator.pop(sheetContext);
                  runApi(
                    context,
                    () => context.read<BookingProvider>().markNoShow(
                      appointment.id,
                    ),
                  );
                },
              ),
            ],
            if (appointment.status == AppointmentStatus.arrived ||
                appointment.status == AppointmentStatus.expected)
              _SheetAction(
                icon: Icons.task_alt_outlined,
                title: t(
                  tk: 'Tamamlandy diýip belle',
                  ru: 'Отметить «Завершено»',
                  en: 'Mark as completed',
                ),
                subtitle: t(
                  tk: 'Hyzmat tamamlandy',
                  ru: 'Услуга завершена',
                  en: 'Service completed',
                ),
                onTap: () {
                  Navigator.pop(sheetContext);
                  runApi(
                    context,
                    () => context.read<BookingProvider>().complete(
                      appointment.id,
                    ),
                  );
                },
              ),
            if (appointment.status == AppointmentStatus.expected ||
                appointment.status == AppointmentStatus.arrived) ...[
              _SheetAction(
                icon: Icons.calendar_month_outlined,
                title: t(
                  tk: 'Wagty üýtgetmek',
                  ru: 'Изменить время',
                  en: 'Change time',
                ),
                subtitle: t(
                  tk: 'Bu ýazgyny başga wagtga geçirmek',
                  ru: 'Перенести эту запись',
                  en: 'Move this booking to another time',
                ),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _rescheduleAppointment(context, appointment);
                },
              ),
              _SheetAction(
                icon: Icons.close,
                danger: true,
                title: t(
                  tk: 'Ýazgyny ýatyrmak',
                  ru: 'Отменить запись',
                  en: 'Cancel booking',
                ),
                subtitle: t(
                  tk: 'Bu ýazgyny ýatyrmak',
                  ru: 'Отменить эту запись',
                  en: 'Cancel this booking',
                ),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _confirmCancelAppointment(context, appointment);
                },
              ),
            ],
            if (customer != null)
              _SheetAction(
                icon: Icons.person_outline,
                title: t(
                  tk: 'Müşderi profiline geçmek',
                  ru: 'Перейти в профиль клиента',
                  en: 'Go to customer profile',
                ),
                subtitle: t(
                  tk: 'Müşderiniň maglumatlaryny görmek',
                  ru: 'Посмотреть данные клиента',
                  en: 'View customer details',
                ),
                onTap: () {
                  Navigator.pop(sheetContext);
                  Navigator.push(
                    context,
                    pageRoute(CustomerDetailScreen(customerId: customer.id)),
                  );
                },
              ),
            if (phone.isNotEmpty)
              _SheetAction(
                icon: Icons.phone_outlined,
                callAction: true,
                title: t(tk: 'Jaň etmek', ru: 'Позвонить', en: 'Call'),
                subtitle: displayPhone(phone),
                onTap: () => launchUrl(
                  Uri(scheme: 'tel', path: phone.replaceAll(' ', '')),
                ),
              ),
          ],
        ),
      ),
    ),
  );
}

