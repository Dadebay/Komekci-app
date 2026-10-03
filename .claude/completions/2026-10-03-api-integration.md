# KÖMEKÇI API entegrasyonu — devir notu

Kaynak sözleşme: `docs/API_DOCUMENTATION.md` (+ Insomnia collection).
Base URL: `https://komekchi.brandsforlesstm.com/api` (`lib/core/network/api_config.dart`).
Tarih: 2026-10-03. Durum: **kod yazıldı, analyze’da hata yok (15 uyarı/bilgi, çoğu eski), 46 test geçiyor; canlı sunucuya karşı yalnızca `GET /settings/public` denendi.**

## Mimari (yukarıdan aşağıya)

```
UI (part dosyaları, lib/features/*/presentation)
  └─ Provider'lar (lib/features/*/application)   ← SessionScoped: giriş yapan hesaba bağlı, çıkışta reset()
       └─ Repository'ler (lib/data/repositories) ← her endpoint grubu için bir sınıf
            └─ ApiClient (lib/core/network/api_client.dart)
                 Bearer, 401'de tek seferlik refresh (eşzamanlı çağrılar paylaşır),
                 multipart, ApiException (lib/core/network/api_exception.dart)
```

- **Modeller**: `lib/data/models/api/*` (user, master, billing, client modelleri + `json_helpers.dart`).
- **Zaman**: uygulama içi her `DateTime` = Asia/Ashgabat duvar saati (UTC+5). `parseApiTime` / `formatApiDateTime` çevirir. "Bugün" = `appToday()` (`shared/utils/app_today.dart`).
- **Token**: `flutter_secure_storage` (`SecureTokenStore`). Açılışta `AuthProvider.restoreSession()` (splash) → `/me` → role göre `MasterHome`/`ClientHome`.
- **Provider kaydı**: `lib/app/komekci_app.dart`. Veri provider'ları `ChangeNotifierProxyProvider<AuthProvider, X>` + `onSession(auth.me)` ile giriş/çıkışta otomatik yüklenir/temizlenir.
- **Hata gösterme**: `apiErrorMessage(e, lang)` ve `runApi(context, () => ...)` (`shared/utils/api_errors.dart`).
- **Oturum düşerse**: `AuthProvider.onSessionLost` → `LoginScreen`'e atar (`_navigatorKey`).
- **Testler**: `test/api_client_test.dart`, `api_models_test.dart`, `providers_test.dart`, `app_settings_test.dart`, `widget_test.dart`. Sahte sunucu: `fakeApi({...})` (providers_test.dart).

## Endpoint durumu (61 adet)

Durum: ✅ uygulamaya bağlı (repo + provider + ekran) · 🟡 repo/provider hazır, ekrandan çağrılmıyor.

| # | Endpoint | Durum | Not |
|---|---|---|---|
| 1 | GET `/settings/public` | ✅ | splash; fiyat/para birimi/diller/support_contact |
| 2 | GET `/auth/nickname/available` | ✅ | kayıt ekranları + profil düzenleme (debounce) |
| 3 | POST `/auth/register` | ✅ | multipart; usta akışı: telefon → profil → (register) → OTP → abonelik |
| 4 | POST `/auth/otp/request` | ✅ | giriş + "tekrar gönder" |
| 5 | POST `/auth/otp/verify` | ✅ | 6 haneli kod |
| 6 | POST `/auth/refresh` | ✅ | ApiClient otomatik |
| 7 | POST `/auth/logout` | ✅ | |
| 8 | GET `/me` | ✅ | |
| 9 | PATCH `/me` | ✅ | ad, nick, foto (multipart), locale, theme, notification_prefs |
| 10 | POST `/me/phone` | ✅ | `ChangePhoneDialog` |
| 11 | POST `/me/phone/verify` | ✅ | |
| 12 | DELETE `/me` | ✅ | "Hesabı sil" (kabinet + müşteri profili) |
| 13 | GET `/me/notifications` | ✅ | |
| 14 | POST `/me/notifications/{id}/read` | ✅ | |
| 15 | POST `/me/devices` | ✅ | `DeviceRegistrar`: girişte token'ı kendisi alır, son kaydedileni saklar (aykitap'taki `_syncTokenWithBackend` mantığı) |
| 16 | DELETE `/me/devices` | ✅ | çıkışta |
| 17 | GET `/me/profile` | 🟡 | profil `/me` içindeki `profile` bloğundan okunuyor |
| 18 | PATCH `/me/profile` | ✅ | |
| 19 | GET `/me/services` | ✅ | |
| 20 | POST `/me/services` | ✅ | foto zorunlu |
| 21 | PATCH `/me/services/{id}` | ✅ | gizle/göster dahil (iyimser, hatada geri alır) |
| 22 | DELETE `/me/services/{id}` | ✅ | |
| 23 | GET `/me/schedule` | ✅ | |
| 24 | PUT `/me/schedule` | ✅ | weekday 0 = Pazartesi (collection örneğinden) |
| 25 | POST `/me/schedule/overrides` | ✅ | `day_off` ve `custom_hours` (Özel günler ekranında "Özel saat ekle") |
| 26 | DELETE `/me/schedule/overrides/{id}` | ✅ | |
| 27 | POST `/me/vacations` | ✅ | |
| 28 | DELETE `/me/vacations/{id}` | ✅ | |
| 29 | GET `/me/calendar` | ✅ | ay ay önbellek (`BookingProvider.ensureLoaded/prefetch`) |
| 30 | GET `/me/clients` | ✅ | tüm sayfalar (en çok 20) |
| 31 | GET `/me/clients/{id}` | ✅ | detay ekranı açılınca |
| 32 | PATCH `/me/clients/{id}` | ✅ | yalnızca özel not |
| 33 | DELETE `/me/clients/{id}` | ✅ | |
| 34 | POST `/me/appointments` | ✅ | yeni müşteri bu çağrıyla oluşur |
| 35 | PATCH `/me/appointments/{id}/status` | ✅ | |
| 36 | PATCH `/me/appointments/{id}/move` | ✅ | |
| 37 | GET `/me/connection-requests` | ✅ | `RequestsScreen` (kabinet menüsü) |
| 38 | POST `…/accept` | ✅ | |
| 39 | POST `…/decline` | ✅ | |
| 40 | GET `/me/billing` | ✅ | |
| 41 | GET `/me/billing/transactions` | ✅ | cursor ile "daha fazla" |
| 42 | POST `/me/billing/topup` | ✅ | `mobile` ve `card` |
| 43 | GET `/me/billing/phone` | ✅ | 5 sn aralıkla yoklanır |
| 44 | GET `/me/billing/cards/{id}` | ✅ | WebView dönüşünden sonra, en çok 8 deneme |
| 45 | GET `/payments/result` | 🟡 | `BillingProvider.checkCardPayment(orderId:)` hazır; UI `cards/{id}` kullanıyor |
| 46 | GET `/masters/lookup` | ✅ | `ConnectMasterScreen` |
| 47 | POST `/connections` | ✅ | |
| 48 | GET `/connections` | ✅ | |
| 49 | PATCH `/connections/{id}/active` | ✅ | |
| 50 | DELETE `/connections/{id}` | ✅ | |
| 51 | GET `/masters/{id}` | ✅ | |
| 52 | GET `/masters/{id}/services` | ✅ | |
| 53 | GET `/masters/{id}/availability` | ✅ | 14 günlük aralık; tek gün (`date`) repo'da var |
| 54 | GET `/appointments` | ✅ | upcoming + history |
| 55 | POST `/appointments` | ✅ | Idempotency-Key, SLOT_TAKEN önerileri |
| 56 | PATCH `/appointments/{id}/move` | ✅ | |
| 57 | POST `/appointments/{id}/cancel` | ✅ | |
| 58 | POST `/appointments/{id}/late` | ✅ | 5/10 dk |
| 59 | POST `/appointments/{id}/rebook` | ✅ | "Tekrar yazıl" |
| 60 | POST `/waitlist/{id}/accept` | ✅ | bildirim kartında; payload anahtarı **tahmin** (`waitlist_id`/`waitlist_offer_id`) |
| 61 | POST `/waitlist/{id}/decline` | ✅ | aynı |

Özet: **59 ✅, 2 🟡, 0 hiç yok.** (`POST /transactions*` ödeme geçidinindir, uygulama kullanmaz.)

## API'nin desteklemediği için bilinçli değişen ekranlar

- **Usta pazaryeri kaldırıldı**: kategori/konum/cinsiyet/zaman filtreleri, puan-yorum, favoriler sekmesi (alt bar 5 → 4 sekme). API bağlantı tabanlı (nick/telefonla usta bulunur).
- **"Rejimi değiştir" (usta ↔ müşteri) kaldırıldı**: rol hesaba bağlı. Yerine kabinete "Çıkış yap".
- **Müşteri ekleme/düzenleme**: ad/telefon/durum (VIP vb.) düzenlenemez; yalnızca not + silme. "Müşteri ekle" → ad+telefon alır, ilk randevuyla birlikte oluşturur.
- **"Geldi" durumu yalnızca cihazda** (`BookingProvider.arrive`); API'de yok. "Tamamlandı" artık `expected`'dan da verilebilir.
- **Müşteriler arası tampon (buffer)** satırı kaldırıldı (API'de yok; `grid_step_min`/`min_lead_min` salt okunur).
- **Tatil notu** yok; tek tatil yerine liste.
- **Bildirim ayarları**: müşteri için 3 anahtar (`reminders`, `earlier_slot`, `master_messages`). Usta `N-01…N-19` için ekran **yok**.
- **Banka seçici diyaloğu kaldırıldı**: kart ödemesi tek `form_url` (WebView), banka seçimi geçit sayfasında.
- **Telefonla ödeme**: eski SMS kısa kodu (`0804`) korunuyor ama alıcı numara API'den (`POST /me/billing/topup` → `phone`) geliyor; SMS gövdesi `"<numara> <tutar>"`. Bu biçim eski koddan; backend dokümanında yok → doğrula.
- Silinen mock dosyalar: `client_mock_data`, `client_favorites_screen`, `client_masters_screen` (eski), `home_content`, `legacy_client_screens`, `cabinet_mode_screen`, `master_bank_picker_dialog`, `mock_*_repository`, `service_category`, `salon_hours` (yalnızca `weekdaysEn` → `weekday_labels.dart`).

## Doğrulanmamış / riskli noktalar (sıradaki model bunlara bakmalı)

1. **Canlı test yok** (yazma uçları). Gerçek hesapla denenmeli: register→OTP→abonelik, usta kalender, müşteri randevu akışı. Production'da hesap açar/SMS atar → kullanıcı onayı gerek.
2. **PATCH + multipart** (`/me`, `/me/profile`, `/me/services/{id}` foto): Laravel PATCH multipart'ı bazen okumaz. Çalışmazsa `POST` + `_method=PATCH` kullan (`ApiClient.request` / repository'ler).
3. **Sunucu sertifikası**: ZeroSSL → kök Sectigo R46. Eski CA paketli cihazlarda (eski Android) TLS hatası olabilir; Insomnia'nın eski CA paketi de reddediyordu. Sunucu tarafı sağlam (curl/Chrome çalışıyor).
4. **Backend gözlemleri** (dev'e iletildi): production'da `phpdebugbar-id` header'ı (Debugbar açık), TLS 1.2'de renegotiation isteği.
5. **Müşteri `status` değerleri** (`new/regular/vip`?) dokümanda yok; `Customer.parseStatus` tahmin ediyor.
6. **Bildirim payload'u** dokümanda yok (waitlist id anahtarı tahmin).
7. **Kayıt sırasında OTP "tekrar gönder"**: bekleyen hesap için `otp/request` 404 verirse `register` yeniden çağrılıyor; backend davranışı doğrulanmadı.
8. **Fotoğraf zorunluluğu**: `photo` istemci için zorunlu mu belli değil; UI zorlamıyor, sunucu VALIDATION dönerse alan altında gösterir.
9. `monthlyFee` tam sayıya yuvarlanır (bakiye hesapları `int`); `subscription_price` küsuratlıysa yanlış. `_topUpAmounts = [20,30,40,50]` sabit (`master_setup_shared.part.dart`).
10. Ağ yokken açılışta token varsa `/me` alınamaz → `LanguageScreen`'e düşer (çevrimdışı rol önbelleği yok).
11. ETag / `If-None-Match` önbelleği yok (dokümanda opsiyonel).
12. **FCM**: `FirebaseMessagingService` (core/services) artık elyeter'deki `PushService` gibi iOS'ta APNs'i bekleyip (arka planda, splash'i geciktirmez) `komekci` konusuna abone oluyor. Konu adı benim seçimim; backend yayınları bu konuya atıyorsa adı eşleştir, atmıyorsa abonelik zararsız.
13. Tema/dil yalnızca hesapla senkron; cihazda kalıcı saklama (shared_preferences) yok.

## Kalan iş listesi

Yapıldı (2026-10-03): `flutter build apk --debug` ve `flutter build ios --debug --no-codesign` derlendi; analyzer uyarıları temizlendi; `custom_hours` UI ve usta bildirim türleri (`N-01…N-19`, yalnızca 13–19 açıklamalı) eklendi; `lib/ARCHITECTURE.md` güncellendi.

Kullanıcı yapacak (cihaz/emülatör testi, simülatörde ben test etmedim):
- [ ] Gerçek akışlar: register → OTP → abonelik, usta takvimi, müşteri randevusu, WebView kart ödemesi, görsel yükleme, FCM kaydı.
- [ ] Yukarıdaki "Doğrulanmamış / riskli noktalar" 1–3 ve 5–8 numaralıları canlı sunucuyla kapat; sorun çıkarsa ilgili dosya/çözüm orada yazıyor.

Kod tarafında açık kalan:
- [ ] Ekran (widget) testleri yok; yalnızca katman/provider testleri var.
- [ ] Usta `N-01…N-12` bildirim türlerinin adları API dokümanında yok (kod olarak gösteriliyor).

## Not: bir kazaya dikkat

Oturumun başında `dart format lib` tüm klasörü biçimlendirdi. Temiz olan dosyalar HEAD'e geri alındı; kullanıcının önceden değiştirdiği 10 dosya (`home_dashboard_widgets`, `schedule_*`, `day_timeline_screen`, `home_dashboard_screen`, `cabinet_client_notify_screen`, `cabinet_working_hours_screen`, `app_icon.dart`, `background_sms.dart`) biçimlenmiş halde kaldı (mantık aynı, satır kırılımı farklı). **`dart format lib` çalıştırma.**
