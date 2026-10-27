# Booking alert dialog redesign

File: lib/features/notifications/presentation/master_booking_alert_overlay.dart

- Centered layout: accent disc badge with halo, accent gradient wash behind header, title + subtitle ("Müşderi size ýazyldy").
- Body in tinted bordered card with event icon.
- Static "Closes in 8 seconds" text + linear bar replaced by a "Düşnükli / Понятно / Got it" stadium button whose trailing ring counts down the live seconds.
- Entrance: fade + scale(.94→1) + slide-up 320ms easeOutCubic, scrim fades in; replays per alert id; disabled under reduce-motion.
- 8s auto-dismiss timer unchanged (_displayDuration).
