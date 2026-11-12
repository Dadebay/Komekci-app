part of '../../../app/komekci_app.dart';

void _openAppointmentActions(
  BuildContext context,
  Appointment appointment,
  Customer? customer,
  AppLanguage language,
) {
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
                RoundPhoto(
                  url: customer?.photoUrl ?? appointment.clientPhotoUrl,
                  radius: 20,
                  backgroundColor: tokens.accent.withValues(alpha: .2),
                ),
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
                title: AppStrings.scheduleMarkAsArrived.select(language),
                subtitle: AppStrings.scheduleCustomerArrived.select(language),
                onTap: () {
                  Navigator.pop(sheetContext);
                  context.read<BookingProvider>().arrive(appointment.id);
                },
              ),
              _SheetAction(
                icon: Icons.person_off_outlined,
                danger: true,
                title: AppStrings.scheduleMarkAsNoShow.select(language),
                subtitle: AppStrings.scheduleCustomerDidNotShowUp.select(language),
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
                title: AppStrings.scheduleMarkAsCompleted.select(language),
                subtitle: AppStrings.scheduleServiceCompleted.select(language),
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
                title: AppStrings.scheduleChangeTime.select(language),
                subtitle: AppStrings.scheduleMoveThisBookingToAnother.select(language),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _rescheduleAppointment(context, appointment);
                },
              ),
              _SheetAction(
                icon: Icons.close,
                danger: true,
                title: AppStrings.scheduleCancelBooking.select(language),
                subtitle: AppStrings.scheduleCancelThisBooking.select(language),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _confirmCancelAppointment(context, appointment);
                },
              ),
            ],
            if (customer != null)
              _SheetAction(
                icon: Icons.person_outline,
                title: AppStrings.scheduleGoToCustomerProfile.select(language),
                subtitle: AppStrings.scheduleViewCustomerDetails.select(language),
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
                title: AppStrings.scheduleCall.select(language),
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

