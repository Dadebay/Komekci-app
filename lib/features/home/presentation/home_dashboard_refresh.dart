part of '../../../app/komekci_app.dart';

extension _HomeDashboardRefresh on _HomeDashboardScreenState {
  void _refreshForNewBooking() {
    final alert = _bookingAlerts.visibleAlert;
    if (alert == null) {
      _refreshedAlertId = null;
      return;
    }
    if (_refreshedAlertId == alert.id) return;
    _refreshedAlertId = alert.id;
    // The FCM handler already refreshes the master's appointment months.
    unawaited(_refresh(refreshBookings: false));
  }

  Future<void> _refreshDashboard({
    required void Function(VoidCallback) update,
    bool refreshBookings = true,
  }) async {
    if (_refreshingNumbers) return;
    final bookings = context.read<BookingProvider>();
    final customers = context.read<CustomerProvider>();
    final schedule = context.read<ScheduleProvider>();
    final billing = context.read<BillingProvider>();
    final profile = context.read<MasterProfileProvider>();
    final requests = context.read<ConnectionRequestsProvider>();
    _numberCountUp.stop();
    update(() => _refreshingNumbers = true);
    _numberShimmer.repeat();
    try {
      await Future.wait<void>([
        if (refreshBookings) bookings.refreshDay(appToday()),
        customers.load(),
        schedule.load(),
        billing.refresh(),
        profile.refresh(),
        requests.load(),
        Future<void>.delayed(const Duration(milliseconds: 450)),
      ]);
      if (mounted &&
          (bookings.error != null ||
              customers.error != null ||
              schedule.error != null ||
              billing.error != null ||
              requests.error != null)) {
        final language = context.read<LanguageProvider>().language;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              pickTr(
                language,
                tk: 'Maglumatlary täzelemek başartmady. Öňki maglumatlar görkezilýär.',
                ru: 'Не удалось обновить данные. Показаны прежние значения.',
                en: 'Could not refresh data. Previous values are shown.',
              ),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        _numberShimmer.stop();
        update(() => _refreshingNumbers = false);
        _numberCountUp.forward(from: 0);
      }
    }
  }
}
