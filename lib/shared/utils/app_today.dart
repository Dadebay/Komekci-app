/// Today's date (no time), on the same wall clock the API uses. Turkmenistan
/// has no DST and sits on UTC+5 year-round, which is also the phone's zone
/// for its users; deriving it from the device clock keeps tests easy.
DateTime appToday() {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
}
