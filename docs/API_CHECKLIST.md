# API checklist (Insomnia collection order)

Legend — **Bağlı**: wired in the app (repository + provider + screen). **Repo**: written and tested, no screen calls it.
**Logda 200**: seen working against the real server in the app's request log (2026-10-04).
Tick the boxes yourself as you check each request in Insomnia.

63 Insomnia requests = 61 distinct endpoints (`topup` and `availability` each appear twice).

## 00 - Public
- [ ] GET `/settings/public` — Settings - public — **Bağlı**, **Logda 200** (splash)

## 01 - Auth
- [ ] GET `/auth/nickname/available` — Nickname musait mi — **Bağlı**, **Logda 200** (kayıt formları, profil)
- [ ] POST `/auth/register` — Register (multipart) — **Bağlı**, **Logda 201** (ve 422 `PHONE_TAKEN`)
- [ ] POST `/auth/otp/request` — OTP request — **Bağlı** (giriş, tekrar gönder, "Şu belgi bilen giriş")
- [ ] POST `/auth/otp/verify` — OTP verify — **Bağlı**, **Logda 200**
- [ ] POST `/auth/refresh` — Refresh — **Bağlı** (ApiClient otomatik, 401'de)
- [ ] POST `/auth/logout` — Logout — **Bağlı** (Çıkış yap)

## 02 - Me
- [ ] GET `/me` — Me — **Bağlı**, **Logda 200**
- [ ] PATCH `/me` — Me - guncelle — **Bağlı** (ad, lakam, foto, dil, tema, bildirim ayarları)
- [ ] POST `/me/phone` — Telefon degistir - SMS iste — **Bağlı** (profil → telefon "Üýtget")
- [ ] POST `/me/phone/verify` — Telefon degistir - dogrula — **Bağlı**
- [ ] DELETE `/me` — Hesabi sil — **Bağlı** ("Hasaby poz")
- [ ] GET `/me/notifications` — Bildirimler — **Bağlı**, **Logda 200**
- [ ] POST `/me/notifications/{id}/read` — Bildirimi okundu isaretle — **Bağlı**
- [ ] POST `/me/devices` — FCM token kaydet — **Bağlı**, **Logda 200**
- [ ] DELETE `/me/devices` — FCM token sil — **Bağlı** (çıkışta)

## 03 - Master / Profil
- [ ] GET `/me/profile` — Profil — **Bağlı** (kabinet → Profil formu açılırken `MasterProfileProvider.refresh()`; yalnızca usta, müşteri `FORBIDDEN` alır)
- [ ] PATCH `/me/profile` — Profil guncelle (multipart) — **Bağlı** (kabinet → Profil; banner varsa `POST` + `_method=PATCH` gider)

## 04 - Master / Hyzmatlar
- [ ] GET `/me/services` — Hizmetler — **Bağlı**
- [ ] POST `/me/services` — Hizmet ekle (multipart) — **Bağlı**
- [ ] PATCH `/me/services/{id}` — Hizmet guncelle — **Bağlı** (düzenle, gizle/göster)
- [ ] DELETE `/me/services/{id}` — Hizmet sil — **Bağlı**

## 05 - Master / Is wagty
- [ ] GET `/me/schedule` — Grafik — **Bağlı**
- [ ] PUT `/me/schedule` — Grafigi kaydet — **Bağlı** (weekday 0 = Pazartesi)
- [ ] POST `/me/schedule/overrides` — Istisna gun ekle — **Bağlı** (`day_off` ve `custom_hours`)
- [ ] DELETE `/me/schedule/overrides/{id}` — Istisna sil — **Bağlı**
- [ ] POST `/me/vacations` — Tatil ekle — **Bağlı**
- [ ] DELETE `/me/vacations/{id}` — Tatil sil — **Bağlı**

## 06 - Master / Senenama
- [ ] GET `/me/calendar` — Takvim — **Bağlı**, **Logda 200** (ay ay)

## 07 - Master / Musderiler
- [ ] GET `/me/clients` — Musteriler — **Bağlı**, **Logda 200**
- [ ] GET `/me/clients/{id}` — Musteri karti — **Bağlı**
- [ ] PATCH `/me/clients/{id}` — Ozel not yaz — **Bağlı**
- [ ] DELETE `/me/clients/{id}` — Musteriyi kaldir — **Bağlı**

## 08 - Master / Yazgylar
- [ ] POST `/me/appointments` — Elle kayit ekle — **Bağlı**
- [ ] PATCH `/me/appointments/{id}/status` — Kayit durumu — **Bağlı**
- [ ] PATCH `/me/appointments/{id}/move` — Kaydi ertele — **Bağlı**

## 09 - Master / Baglanti istekleri
- [ ] GET `/me/connection-requests` — Gelen istekler — **Bağlı** (kabinet → Baglanyşyk haýyşlary)
- [ ] POST `/me/connection-requests/{id}/accept` — Istegi kabul et — **Bağlı**
- [ ] POST `/me/connection-requests/{id}/decline` — Istegi reddet — **Bağlı**

## 10 - Master / Toleg
- [ ] GET `/me/billing` — Billing — **Bağlı**, **Logda 200** (`phone: null` → telefonla ödeme kapalı)
- [ ] GET `/me/billing/transactions` — Islem gecmisi — **Bağlı**, **Logda 200**
- [ ] POST `/me/billing/topup` (mobile) — Topup - telefon — **Bağlı**
- [ ] GET `/me/billing/phone` — Telefon odeme durumu — **Bağlı** (5 sn'de bir yoklanır)
- [ ] POST `/me/billing/topup` (card) — Topup - kart — **Bağlı** (WebView)
- [ ] GET `/me/billing/cards/{id}` — Kart odeme sonucu (token ile) — **Bağlı**
- [ ] GET `/payments/result` — Kart odeme sonucu (orderId ile) — **Repo** (`BillingProvider.checkCardPayment(orderId:)`)

## 11 - Client / Baglanti
- [ ] GET `/masters/lookup` — Master ara — **Bağlı** ("Ussaňyza baglanyň")
- [ ] POST `/connections` — Baglanti istegi gonder — **Bağlı**
- [ ] GET `/connections` — Masterlarim — **Bağlı**
- [ ] PATCH `/connections/{id}/active` — Aktif master yap — **Bağlı** (usta kartı → ⋯)
- [ ] DELETE `/connections/{id}` — Baglantiyi sil — **Bağlı**

## 12 - Client / Master, hizmet, slot
- [ ] GET `/masters/{id}` — Master profili — **Bağlı**
- [ ] GET `/masters/{id}/services` — Master hizmetleri — **Bağlı**
- [ ] GET `/masters/{id}/availability` (tek gün) — **Bağlı** (repo'da `date`; ekranlar aralık kullanıyor)
- [ ] GET `/masters/{id}/availability` (aralık) — **Bağlı** (14 gün)

## 13 - Client / Yazgylar
- [ ] GET `/appointments` — Kayitlarim — **Bağlı**, **Logda 200** (`upcoming` ve `history`)
- [ ] POST `/appointments` — Randevu al — **Bağlı** (Idempotency-Key)
- [ ] PATCH `/appointments/{id}/move` — Kaydimi ertele — **Bağlı**
- [ ] POST `/appointments/{id}/cancel` — Kaydi iptal et — **Bağlı**
- [ ] POST `/appointments/{id}/late` — Gecikme bildir — **Bağlı**
- [ ] POST `/appointments/{id}/rebook` — Tekrar randevu al — **Bağlı**
- [ ] POST `/waitlist/{id}/accept` — Erken slotu kabul et — **Bağlı** (bildirim kartı; payload anahtarı tahmin)
- [ ] POST `/waitlist/{id}/decline` — Erken slotu reddet — **Bağlı** (aynı)

## Özet
- Bağlı: **60** endpoint · Repo (ekran yok): **1** (`GET /payments/result`) · Hiç yok: **0**
- Gerçek sunucuda uygulama logunda görülen: 12 (`settings/public`, `nickname/available`, `register`, `otp/verify`, `/me`,
  `/me/devices`, `/me/notifications`, `/me/billing`, `/me/billing/transactions`, `/me/calendar`, `/me/clients`,
  `/appointments`).
- Henüz gerçek sunucuda denenmemiş yazma uçları: hizmet/grafik/tatil/randevu/ödeme/bağlantı işlemleri.
