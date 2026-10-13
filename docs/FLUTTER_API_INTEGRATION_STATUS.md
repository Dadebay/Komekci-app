# Flutter API entegrasyon durumu

Kaynak: kullanıcı tarafından sağlanan `FLUTTER_API_DOCUMENTATION.md` (13 Ekim 2026). Durumlar Flutter kod bağlantısını belirtir. Herkese açık ayarlar endpoint'i canlı sunucuda 200 yanıtıyla doğrulandı; kimlik isteyen endpoint'ler, SMS ve FCM teslimatı canlı test edilmedi.

| API / özellik | Durum | Uygulamada test yeri |
| --- | --- | --- |
| `GET /settings/public` fiyat, para birimi, etkin diller/temalar | Bağlı | Açılış; müşteri Profil → Dil / Görnüşi |
| Aynı yanıtın `contact` alanı | Bağlı | Müşteri Profil → Goldaw; usta Kabinet → Kömek |
| Aynı yanıtın `about` alanı | Bağlı | Goldaw/Kömek → Biz barada |
| `PATCH /me` dil/tema tercihi | Bağlı | Profil → Dil / Görnüşi; devre dışı kalan kayıtlı tercih açılışta düzeltilir |
| `POST /me/notifications/send` | Kısmi | Usta Kabinet → Bildiriş → müşterilere mesaj. Gönderim kodu bağlı, fakat müşteri hesabı ID eşlemesi backend yanıtına bağlı. |
| `POST /me/devices`, `DELETE /me/devices` | Bağlı | Oturum açma / çıkış sırasında otomatik |
| FCM `komekci` topic | Bağlı (istemci) | Firebase başlangıcında otomatik; HTTP endpoint olmadığı için Insomnia isteği yok |
| `POST /auth/register` | Bağlı | Müşteri/usta kayıt akışı |
| `POST /auth/otp/request`, `POST /auth/otp/verify` | Bağlı | Telefonla giriş ve OTP ekranı |
| `POST /me/phone`, `POST /me/phone/verify` | Bağlı | Profil → telefon numarası değiştirme |

## Push için backend alanı gerekli

Yeni bildirim endpoint'i sayısal `account_ids` istiyor. Mevcut `GET /me/clients` belgesi ise `id: "c12"` gibi bir müşteri satır kimliği tanımlıyor ve sayısal `account_id` göstermiyor. Flutter `c12` değerini hesap ID'si kabul etmiyor; yanlış kişiye bildirim göndermemek için sadece yanıtında gerçek `account_id` bulunan bağlı müşterileri seçilebilir yapıyor. Backend'in `GET /me/clients` yanıtına bağlı hesaplar için sayısal `account_id` eklemesi (çevrimdışı müşteriler için `null`) veya gönderim endpoint'inin mevcut `c12` kimliklerini kabul etmesi gerekiyor. Insomnia koleksiyonundaki `[KONTROL] Ustanın müşteri listesi` isteğiyle canlı yanıt doğrulanabilir.

## Insomnia

`docs/insomnia/Komekchi_Flutter_API.json` dosyasını **Import → File** ile açın. `Base Environment` içindeki `access_token`, telefon, OTP ve cihaz tokenı alanlarını test hesabınızla doldurun. Köşeli durum etiketleri kod entegrasyonunu gösterir. OTP ve bildirim istekleri gerçek SMS/push tetikleyebilir; yalnızca test hesabıyla çalıştırın.

## Doğrulama

- `GET /api/settings/public?locale=tk`: canlı sunucuda HTTP 200 ve beklenen `locales`, `themes`, `contact`, `about` alanları görüldü.
- `flutter analyze --no-pub`: uygulama kodunda hata yok; üçüncü taraf `background_sms` paketinde dört bilgi uyarısı bulunuyor.
- `flutter test --no-pub --enable-experiment=dot-shorthands test/app_settings_test.dart`: 4 test geçti.
