const weekdaysEn = ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su'];

/// Working hours applied to every day the salon is open. No real weekly
/// schedule provider exists yet, so this mirrors the same Mon–Sat 09:00–19:00
/// hours shown on the schedule screen. Sunday is closed.
bool isSalonOpen(DateTime day) => day.weekday != DateTime.sunday;
