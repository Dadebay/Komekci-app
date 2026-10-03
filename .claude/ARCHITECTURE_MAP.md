# Architecture Map

Ayrıntılı devir notu: `.claude/completions/2026-10-03-api-integration.md`

## Katmanlar

```
lib/
├── app/komekci_app.dart        # tüm part dosyaları + Provider ağacı (ApiClient, repository'ler, provider'lar)
├── core/
│   ├── network/                # ApiClient, ApiException, TokenStore, api_config (base URL)
│   ├── session/session_scoped.dart  # giriş yapan hesaba bağlı provider tabanı
│   ├── services/               # FCM, analytics, DeviceRegistrar
│   └── localization/, theme/
├── data/
│   ├── models/api/             # API cevap modelleri (user, master, billing, client, json_helpers)
│   ├── models/                 # UI modelleri (Appointment, Customer, SalonService, AppNotification)
│   └── repositories/           # auth, me, master, billing, client, settings (endpoint başına)
├── features/<alan>/application/   # provider'lar
├── features/<alan>/presentation/  # *.part.dart ekranları (komekci_app.dart'ın parçaları)
└── shared/                     # widget'lar, api_errors.dart (apiErrorMessage, runApi), app_today.dart
```

## Önemli yerler

- Base URL: `lib/core/network/api_config.dart`
- Giriş/oturum: `features/auth/application/auth_provider.dart`, splash'te `restoreSession()`
- Usta takvimi: `features/booking/application/booking_provider.dart`
- Müşteri randevuları: `features/booking/application/client_bookings_provider.dart`
- Ödeme: `features/billing/application/billing_provider.dart`, `features/auth/presentation/master_phone_payment_dialog.part.dart`, `master_card_payment_dialog.part.dart`
- Testler: `test/` (`providers_test.dart` içinde `fakeApi` sahte sunucu)
