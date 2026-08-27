# KÖMEKÇI — Ekran ve Tasarım Denetimi

**Tarih:** 19 Ağustos 2026  
**Amaç:** Mevcut Flutter projesini ürün şartnamesiyle karşılaştırmak; eksik ekranları, eksik tasarımları ve yanlış yöndeki ekranları Sonnet ile uygulanabilecek netlikte listelemek.

## Kısa sonuç

Proje, görsel olarak başlangıç seviyesinde kullanılabilir bir Flutter prototipidir; ancak ürünün gerçek sürümü değildir. Uygulama şu an bellek içi mock verilerle çalışır; kullanıcı hesabı, sunucu API'si, veritabanı, gerçek OTP, gerçek ödeme ve randevu çakışmasını engelleyen bir altyapı yoktur.

En önemli ürün sapması şudur: şartname KÖMEKÇI'yi **keşifsiz, master onaylı özel müşteri defteri** olarak tanımlar. Mevcut client tarafında ise herkese açık master dizini, konum/hizmet/cinsiyet filtreleri ve favoriler bulunur. Bunlar marketplace davranışıdır ve hedef ürünle çelişir. Bu ekranlar kaldırılmalı veya yalnızca kullanıcının onaylanmış master'larını gösterecek biçimde dönüştürülmelidir.

Durum göstergeleri:

- **Var (prototip):** Ekran görünür, fakat veri/iş kuralı çoğunlukla mock veya statiktir.
- **Kısmi:** Akışın yalnızca bir bölümü vardır; bu belge eksik kısmı tanımlar.
- **Yok:** Ekran ya da gerekli tasarım hiç yoktur.
- **Kaldır / dönüştür:** Mevcut tasarım ürün kararıyla çelişir.

## Önce yapılması gerekenler

1. Marketplace mantığını kaldırın: public master listesi, kategori/konum/cinsiyet filtreleri ve favoriler v1 kapsamından çıkarılmalı.
2. Tek bir tasarım sistemi oluşturun: renk, tipografi, boşluk, radius, gölge, durum ve tema token'ları. Mevcut `app_colors.dart` yalnızca dört renk içeriyor; dört tema gerçekte uygulanmıyor.
3. Gerçek domain ve backend katmanını tasarlayın. `BookingProvider`, `CustomerProvider` ve `ServiceProvider` bellek içidir; uygulama kapanınca veri kaybolur.
4. Connection request → onay → booking erişimi akışını bitirin. Bu, ürünün temel erişim kuralıdır.
5. Süre bazlı availability / double-booking engeli yapılmadan booking ekranını “tamamlandı” kabul etmeyin.
6. Master günlük takvimini ana çalışma ekranı olarak tamamlayın; ödeme, müşteriler, servisler ve çalışma programı bunun çevresinde çalışmalıdır.

---

# 1. Ortak ekranlar ve tasarım altyapısı

## 1.1 Splash

**Durum:** Var (prototip).  
**Eksik tasarım/işlev:** İlk açılışta oturum, seçilmiş rol, dil, tema ve abonelik durumuna göre doğru hedef ekrana yönlendirme görünür biçimde tasarlanmamış.

**İstenen tasarım:** Ivory arka plan, serif `KÖMEKÇI` logotype, çok hafif opacity/fade mikro animasyonu. Ağ yüklenirken ürün donmuş görünmemeli; cache'ten son bilinen oturum hedefi açılmalı.

**Kabul kriteri:** 1–1.5 sn içinde onboarding, client home veya master home'a geçer; internet yoksa uygun offline durumu gösterilir.

## 1.2 Rol seçimi

**Durum:** Var (prototip).  
**Eksik:** Seçimin kalıcı saklanması, geri dönüp rol değiştirme kuralı, master için abonelik açıklama ekranına kesin geçiş.

**İstenen tasarım:** İki eşit kart: `MASTER` ve `CLIENT`; ikon, tek cümle açıklama, seçili kartta 1 px gold stroke. Altta koyu pill CTA, sağda ayrı chevron bölümü. Dokunma alanları en az 48 px.

## 1.3 Dil seçimi

**Durum:** Kısmi.  
**Eksik:** Şartname üç dil ister (Türkmence, Rusça, İngilizce); kodda sadece `tk` ve `ru` var. Metinlerin önemli bölümü hard-coded İngilizce/Türkmence.

**Yapılacak:** Tüm UI stringlerini localization dosyalarına çıkarın; `en` ekleyin; seçimi kalıcı saklayın; tarih, para ve telefon formatını dile göre gösterin.

## 1.4 Tema ve temel component tasarımı

**Durum:** Kısmi.

Mevcut enum dört tema tanımlar (`ivory`, `onyx`, `champagne`, `rose`), fakat `ThemeData` yalnızca light/dark seviyesinde ve ekranlar doğrudan `Colors.white`, `ink`, `gold`, `line` kullanır. Sonuç: onyx dışındaki üç tema fiilen çalışmaz.

**Sonnet uygulama brief'i:**

- `AppThemeTokens`: surface, surfaceElevated, textPrimary, textSecondary, border, accent, success, warning, danger, disabled, scrim.
- Dört tema için aynı semantic token seti; widget içinde ham hex veya `Colors.white` kullanılmaz.
- Tipografi: logo/hero için Noto Serif; UI için Gilroy. Başlıklar 28/24/20, body 16/14, label 12; her biri tanımlı line-height ile.
- Spacing ölçeği: 4, 8, 12, 16, 20, 24, 32. Radius: 12, 16, 20, 28. İnce border 1 px.
- Ortak bileşenler: primary/secondary/danger button, icon button, text field, search field, chip, status chip, empty state, error state, skeleton, bottom sheet, confirmation dialog, section header, avatar.
- Low-RAM cihazlar için ağır blur, video ve sürekli animasyon kullanmayın. Sadece 150–220 ms fade/scale/selection geçişleri.

---

# 2. Client tarafı — ekran ekran denetim

## 2.1 Kayıt: fotoğraf, ad, nickname, telefon

**Durum:** Kısmi. Form görünür ancak alanlar gerçek controller/validation/submit işlemine bağlı değildir.

**Eksik ekran tasarımı ve kuralları:**

- Fotoğraf seçimi, kare crop ve yükleme/progress durumu.
- Ad 2–50 karakter; nickname 3–20, küçük harf/numara/alt çizgi; nickname benzersizlik kontrolü.
- `+993 XX XXXXXX` input maskesi ve telefon benzersizlik hatası.
- Nickname doluysa alan altında hata + üç alternatif öneri.
- Klavye açıkken CTA erişilebilir kalmalı; form gönderilirken loading ve çift dokunma koruması olmalı.

## 2.2 OTP doğrulama

**Durum:** Kısmi. Altı noktalı statik kutu var; gerçek input, timer ve servis yok.

**İstenen tasarım:** Altı tek karakter kutusu; otomatik focus ilerleme; SMS auto-fill; “00:60 içinde tekrar gönder”; yanlış kod inline hata; “numarayı değiştir” linki. Başarılı doğrulama sonrası kısa success geçişi.

## 2.3 Master bağlama / arama

**Durum:** Kısmi. Statik sonuç kartı var.

**Eksik:** 400 ms debounce, en az üç karakter, nickname veya telefon lookup, bulunamadı/bağlantı yok/retry durumları, duplicate request engeli.

**Tasarım:** Tek arama alanı; başlangıçta “Master'ınızın @nickname veya telefonunu yazın” yönlendirmesi. Sonuçta fotoğraf, ad, `@nickname`, adres, “İstek gönder” CTA. Bu ekran **public dizin değildir**.

## 2.4 Master önizleme ve istek gönderme

**Durum:** Kısmi.

**Eksik:** Gerçek profil verisi, bağlantı ve onay durumuna göre CTA, gönderim hata/success durumu.

**Tasarım:** Banner + avatar overlap, ad/nickname/adres, açıklama, sosyal linkler ve servis önizlemesi. Bağlantı onaylanmamışken fiyat/uygun saatler gösterilmez. CTA gönderiminde confirmation bottom sheet.

## 2.5 İstek bekliyor / reddedildi / kabul edildi

**Durum:** Kısmi; yalnızca statik pending ekranı mevcut.

**Eksik tasarımlar:**

- Pending kartı ve “isteği geri çek” aksiyonu.
- Reddedildi: nötr mesaj, sebep gösterilmez, yeniden arama CTA.
- Kabul edildi: success ekranı, “Master'ı görüntüle” ve “Randevu al” CTA.
- Push üzerinden açıldığında doğru master detayına deep-link.

## 2.6 Client ana sayfa

**Durum:** Var (prototip), fakat ürün yönü yanlış.

**Kaldır / dönüştür:** `ClientMastersScreen`, konum/hizmet/cinsiyet filtreleri, kategori satırları ve `ClientFavoritesScreen` public discovery davranışıdır. Şartnameye göre olmamalı.

**Yeni ana sayfa tasarımı:**

1. Üstte selamlama, bildirim ikonu ve aktif master değiştirici.
2. Aktif master kartı: avatar, ad, adres, “Profili aç” ve belirgin `Randevu al`.
3. Yaklaşan randevu kartı: tarih/saat, servis, master, durum, “Detay” CTA.
4. Randevu yoksa: master hizmetlerini gösteren boş durum + `Randevu al`.
5. Bağlı master yoksa: açıklama + `Master bağla` CTA.

Alt navigasyon şartnameyle uyumlu olarak **Home / Booking / History / Profile** olmalı. “My masters” Profile içindeki alt ekran olmalı; Favorite kaldırılmalı.

## 2.7 Master public profile (client görünümü)

**Durum:** Kısmi; master preview var, tam profil yok.

**Eksik:** Banner, iletişim bilgisi, sosyal linkler, servis listesi/fiyat/süre, aktif/pasif abonelik mesajı, skeleton/empty/error durumları.

**Tasarım:** Tam genişlik banner (yaklaşık 180 px), avatarın banner üzerine taşması, isim/nickname/adres. Aşağıda “Hakkında”, “Hizmetler”, “Sosyal medya” bölümleri. Sabit alt CTA: `Randevu al`. Master suspended ise CTA yerine kilitli bilgi bandı.

## 2.8 Booking — hizmet seçimi

**Durum:** Kısmi; eski `BookingPage` sabit üç servis ve sabit saat kullanır.

**Eksik:** Bağlı/aktif master denetimi; yalnız aktif servisler; süre ve fiyat; seçili servis state'i; boş servis durumu.

**Tasarım:** Bir adımlı wizard göstergesi (`1 Hizmet · 2 Tarih & saat · 3 Onay`). Servis kartında thumbnail, ad, açıklama (iki satır), `45 dk`, `80 TMT`, seçili check. Devam CTA, servis seçilmeden disabled.

## 2.9 Booking — tarih ve saat seçimi

**Durum:** Yok.

**Tasarım:** Yatay 7/14 günlük date strip, ay seçici ve erişilebilir önce/sonra okları. Seçili servis süresine göre sunucudan gelen uygun slot chip'leri. Dolu/pasif saatler %35 opacity, tıklanamaz. Gün boşsa açık empty state. Geçmiş saatler ve çalışma dışı zamanlar asla seçilemez.

**Zorunlu davranış:** Master takvimi, izin, tatil, break, date override ve mevcut randevular hesaba katılmalı. Rezervasyon anında server tekrar doğrulamalı; conflict olursa slotlar yenilenmelidir.

## 2.10 Booking — not, erken saat bildirimi, onay

**Durum:** Yok.

**Tasarım:** Seçilmiş hizmet/tarih/saat için compact özet; max 200 karakter not alanı; “Daha erken saat açılırsa haber ver” checkbox ve kısa açıklama. Altta toplam fiyat + `Randevuyu onayla`.

**Durumlar:** Gönderiliyor, başarı, slot kapıldı/conflict, ağ yok (kuyruğa alınamaz; kullanıcıya net hata), master suspended.

## 2.11 Booking success

**Durum:** Yok.

**Tasarım:** İnce check animasyonu, randevu özeti, “Takvimime git” ve “Ana sayfa” CTA. Master'a bildirim gönderildi bilgisi.

## 2.12 Randevu detay

**Durum:** Kısmi; genel `AppointmentDetailScreen` var ama client kuralları eksik.

**Eksik:** Sadece başlangıçtan önce değiştir/iptal; iptal onay diyaloğu; aktif randevuda “Geç kalıyorum”; not; master bilgisi; geçmiş durumu.

**Tasarım:** Zaman çizgisi/özet kartı; `Değiştir`, `İptal et` outline aksiyonları. Zaman penceresindeyse dolu secondary CTA `5 veya 10 dk geç kalacağım`; bir kez gönderildikten sonra düzenleme mesajı. İptal destructive confirmation sheet ile yapılmalı.

## 2.13 Daha erken slot teklifi

**Durum:** Yok.

**Tasarım:** Push'tan açılan modal/bottom sheet: eski ve yeni saat karşılaştırması, “10 dk içinde karar ver” sayaç, `Yeni saati kabul et` ve `Şimdilik istemiyorum`. Süre dolduktan sonra sadece bilgi toast'ı. FIFO ve 10 dk soft reservation backend kuralıdır.

## 2.14 Geçmiş ve yeniden randevu

**Durum:** Kısmi. Client bookings alanı görünür; şartnamedeki geçmiş ekranı/filtresi ve gerçek veri yok.

**Tasarım:** En yeni üstte, 20'li sayfalama; master ve durum filtreleri. Her satırda tarih, saat, master, servis, fiyat, Completed/Cancelled/No-show chip. Detayda `Tekrar randevu al` CTA; master + servis önceden seçili booking'e geçer.

## 2.15 My masters

**Durum:** Kısmi fakat mevcut ekran public master listesine dönüşmüş.

**İstenen tasarım:** Yalnız bağlı master'lar. Aktif master radio/highlight, pending chip, remove confirmation, `Master ekle` CTA. Pending master aktif seçilemez. Remove işlemi iki taraftaki bağlantıyı siler.

## 2.16 Client profil ve ayarlar

**Durum:** Kısmi.

**Eksik:** Kişisel veri düzenleme/biriciklik kontrolü, telefon değişim OTP, bildirim tercihleri, gerçek tema/dil, about/legal, logout ve GDPR-benzeri account deletion akışı.

**Tasarım:** Bölümlü ayar listesi: Kişisel bilgiler, Master'larım, Bildirimler, Görünüm, Dil, Hakkında. Destructive `Hesabı sil` en altta ayrı kırmızı alan ve iki adımlı onay.

---

# 3. Master tarafı — ekran ekran denetim

## 3.1 Abonelik açıklaması (kayıt öncesi)

**Durum:** Var (prototip).

**Eksik:** Gerçek fiyat konfigurasyonu, trial bilgisi, şartlar ve ödeme öncesi açıklık.

**Tasarım:** Crown ikon, `FOR MASTERS`, `20 TMT / ay`, beş kısa fayda, “İstediğin zaman bakiyeni yükle” notu, `Başla` CTA. Fiyat backend-configurable olmalı.

## 3.2 Master kayıt wizard'ı — dört adım

**Durum:** Kısmi; telefon/OTP/profil/abonelik ekranları mevcut ama adımlar gerçek veriyle bağlanmıyor.

**Gerekli ekranlar:**

1. Fotoğraf, ad, benzersiz nickname.
2. Telefon OTP, adres.
3. Açıklama ve Instagram/TikTok/diğer linkler.
4. Banner, profil özeti, bitir.

**Tasarım:** Üstte 4 noktalı ilerleme; her adımda geri ve devam; taslak otomatik kaydetme; zorunlu alan inline validation; son adımda gerçek profil preview. Fotoğraf/banner için crop, sıkıştırma, loading ve kaldırma akışı.

## 3.3 Master ana ekran / günlük takvim

**Durum:** Kısmi; dashboard ve `ScheduleScreen` var, fakat bu ekran ürünün birincil day-view ihtiyacını bütün olarak karşılamıyor.

**Tasarım:**

- Üstte tarih, önce/sonra okları, bugün kısayolu; gerekiyorsa week/day toggle.
- Günlük dikey zaman akışı: saat solda, randevu kartı sağda.
- Sıradaki randevu gold accent border ile vurgulu.
- Kart: client avatar/ad/nickname, telefon, servis, süre, not, late marker.
- Completed bölümü altta collapsed; boş zamanlarda hafif free-slot satırı.
- Sağ altta 56 px FAB `Manuel randevu`.

**Kart aksiyon bottom sheet:** tamamlandı, geldi, no-show, iptal, ara, taşı, müşteri kartı. Aksiyonlar status'a göre bağlamsal görünmeli.

## 3.4 Hafta görünümü

**Durum:** Kısmi / belirsiz.

**Eksik tasarım:** Bir haftanın yoğunluğu ve seçili gün yönetimi.

**Tasarım:** 7 gün kolonlu hafif week strip; gün başına randevu sayısı/yoğunluk göstergesi; tıklanınca day view'a iner. Düşük RAM için devasa scrollable calendar yerine virtualized liste.

## 3.5 Manuel randevu oluşturma

**Durum:** Var (prototip) fakat kurallar eksik.

**Eksik:** Mevcut müşteri arama/linkleme, offline contact, seçili servis süresi ile slot doğrulama, çakışma hatası, suspended durumda bloklama.

**Tasarım:** Bottom sheet veya ayrı form: `Mevcut müşteri` / `Yeni müşteri` segmenti; ad, opsiyonel telefon, hizmet, tarih, saat. Telefon eşleşirse müşteri kartını linkleme önerisi. Kaydedince takvim güncellenir; offline kişi için `Offline` etiketi görünür.

## 3.6 Randevu taşıma

**Durum:** Kısmi.

**Tasarım:** Mevcut zaman üstte görünür; hizmet süresine göre uygun slot seçici; “Yeni saati onayla”. Başarılı taşımada client push bildirimi ve eski slotun waitlist değerlendirmesine açılması.

## 3.7 Müşteriler listesi ve arama

**Durum:** Var (prototip).

**Eksik:** Gerçek randevuya göre status; nearest appointment önceliği; nickname araması; offline işaret; server/cache senkronu; şartnamede olmayan loyalty VIP/New filtrelerinin ürün kararıyla teyidi.

**Tasarım düzeltmesi:** Satırda avatar, ad/nickname, telefon, en yakın randevu tarihi-saati-servisi, son ziyaret, toplam ziyaret. `Expected`, `Completed`, `Cancelled` yalnız renk ile değil ikon + metin + tinted chip olarak sunulmalı. Arama local cache üzerinden anlık çalışmalı.

## 3.8 Müşteri kartı ve ziyaret geçmişi

**Durum:** Var (prototip).

**Eksik:** No-show sayısı, randevu durumlarının gerçek kaynağı, private note güvenliği, müşteri silme doğrulaması, manuel randevu ile veri bütünlüğü.

**Tasarım:** Header avatar/ad/@nickname/telefon/ara; dört stat kartı (ziyaret, son ziyaret, no-show, toplam harcama); `Geçmiş` ve `Notlar` segment/tabs; altta `Randevu oluştur` ve destructive `Müşteriyi kaldır`.

## 3.9 Connection requests

**Durum:** Kısmi; `RequestsScreen` görünür, fakat request modeli ve gerçek aksiyon yok.

**Tasarım:** Yeni istekler üstte badge ile; her kartta foto/ad/@nickname/telefon, `Kabul et` primary ve `Reddet` text/danger. Kabulde müşteri listesine eklenir ve booking erişimi açılır; red işleminde confirmation gerekmez ama undo toast olabilir.

## 3.10 Servis listesi

**Durum:** Var (prototip).

**Eksik:** Drag reorder persistence, silinen servisin geçmiş snapshot'ı, aktif/pasif state'in client booking'e etkisi, boş durum.

**Tasarım:** Thumbnail, ad, süre, fiyat, active toggle, drag handle. `Yeni hizmet` FAB/CTA. Silme için confirmation; aktif kapatma için açıklama: yeni booking'e kapanır, geçmiş korunur.

## 3.11 Servis ekle/düzenle

**Durum:** Var (prototip).

**Eksik:** Tüm değerler backend'e kaydolmuyor; price validation, image upload, maximum sınırlar ve unsaved-changes koruması tamamlanmalı.

**Tasarım:** Fotoğraf alanı, ad (2–60), açıklama (0–300), TMT para alanı, 15/30/45/60/90/120 + custom süre chip'leri, görünürlük toggle. Sticky `Kaydet` CTA.

## 3.12 Haftalık çalışma programı

**Durum:** Var (prototip) ancak availability motoruna bağlı değil.

**Tasarım:** Pazartesi–Pazar satırları; açık/kapalı switch; açık günlerde başlangıç/bitiş ve opsiyonel break aralığı. Tüm güne uygula kısayolu. Bitiş başlangıçtan önceyse inline hata.

## 3.13 Tarihe özel override / izin günü

**Durum:** Var (prototip) fakat booking hesaplamasına bağlı değil.

**Tasarım:** Mini ay takvimi, özel gün listesi. Bir tarih için `Çalışmıyorum` veya `Özel saatler` seçim kartı. Mevcut randevu varsa etki öncesinde uyarı ve randevu yönetimi CTA'sı.

## 3.14 Tatil

**Durum:** Var (prototip) fakat server rule yok.

**Tasarım:** Başlangıç-bitiş tarih seçici, aktif tatil kartı, düzenle/iptal. Tatil süresinde client profile/booking tarafında net “Bu tarihlerde randevu alınamaz” açıklaması.

## 3.15 Abonelik ve bakiye

**Durum:** Var (prototip).

**Eksik:** Gerçek bakiye, next debit, paid-until, ledger, provider entegrasyonu, loading/failure/retry durumları.

**Tasarım:** Büyük bakiye kartı; `Bakiye yükle`; aylık fiyat, sonraki çekim, aktiflik bitişi; “İşlem geçmişi” listesi: tarih, tür, tutar, sonuç bakiyesi, status.

## 3.16 Bakiye yükleme

**Durum:** Kısmi.

**Tasarım:** Tutar input (TMT), hızlı tutarlar isteğe bağlı, yöntem kartları: mobil bakiye / banka kartı. Harici ödeme dönüşünde success, pending, failed ekranları. Tahsilat sağlayıcısı seçilmeden üretim entegrasyonu yapılmamalı.

## 3.17 Restricted / suspended durum

**Durum:** Yok.

**Tasarım:** Master'da her ekranda persistent warning banner: “Bakiye yetersiz; yeni randevular kapalı.” + `Bakiye yükle`. Takvim, müşteri ve geçmiş read-only kalır; manuel booking ve yeni online booking girişleri disabled açıklamasıyla görünür. Client'ta master profile ve booking girişinde “Master geçici olarak yeni randevu almıyor.”

## 3.18 Master profil düzenleme

**Durum:** Kısmi; cabinet/profile ekranları var.

**Eksik:** Client'a gösterilen profil ile tek veri kaynağı, banner/avatar upload state, sosyal link validation, preview.

**Tasarım:** Düzenlenebilir bölümler: banner, avatar, ad/nickname, adres/iletişim, açıklama, sosyal linkler. `Profili önizle` client görünümünü açar. Nickname değişiminde global uniqueness doğrulaması.

## 3.19 Master ayarları, bildirimler ve destek

**Durum:** Kısmi.

**Eksik:** Event bazlı bildirim toggle'ları, gerçek dil/tema, support kanalına güvenli yönlendirme, legal/account işlemleri.

**Tasarım:** Subscription & payment, Public profile, Connection requests, Notifications, Appearance, Language, Support bölümleri. Push izni kapalıysa sistem ayarına yönlendiren açıklayıcı inline card.

---

# 4. Ekran dışı ancak zorunlu tasarım ve teknik işler

## 4.1 Booking engine

Bu görünmez katman tamamlanmadan client/master ekranları doğru çalışmış sayılmaz.

- Service duration ile 15 dk grid üzerinden uygun slot üretimi.
- Öncelik: mevcut randevu → tatil → tarih override → break → haftalık program.
- Bugün için `now + minimum lead time` öncesi slotların kaldırılması.
- Create / move / waitlist accept işlemlerinde database transaction ve server-side overlap kontrolü.
- Appointment modeline master ID, client ID, service snapshot, duration, end time, note, source (online/manual), offline-contact, late minutes, cancellation metadata eklenmeli.

## 4.2 Randevu lifecycle ve bildirimler

- Durumlar: expected, arrived, completed, cancelled, no-show. Mevcut modelde arrived var ama UI/kurallar bütün değil.
- Client “late” sinyali yalnız `start - 60 dk` ile `start + 30 dk` arasında, 5/10 dk seçenekleriyle gönderilir; tekrar gönderim önceki değeri değiştirir.
- Bildirim merkezi kalıcı olmalı; mevcut `NotificationProvider` uygulama oturumu bitince veriyi kaybeder.
- Gün başı ve 30 dk önce reminder ayarları admin/backend tarafından yönetilebilir; client opt-out dikkate alınır.
- Push açılamazsa lokal scheduled reminder fallback olmalı.

## 4.3 Waitlist

**Tamamen yok.** Booking onayında opt-in; daha erken uygun slot açıldığında FIFO sırayla tek kişiye 10 dk soft reservation. Teklif modalı, expiration, accept conflict ve decline sonrası kuyruk geçişi tasarlanmalı.

## 4.4 Veri, güvenlik ve offline

- Mock repository'ler production repository/API ile değiştirilmeli.
- Auth token, secure storage, session restore, logout, account deletion/anonymisation gerekli.
- Profil ve servis görselleri 200 KB hedefiyle sıkıştırılmalı; CDN boyut varyantı kullanılmalı.
- Cache-first read ve optimistic update + rollback tasarlanmalı. Ancak randevu create/move konfliktinde server sonucu otoritedir.
- Gerçek API hataları için ortak empty/loading/offline/error UI gerekir.

## 4.5 Navigasyon ve bilgi mimarisi

```text
CLIENT
Home ── Master profil ── Booking (hizmet → tarih/saat → onay → başarı)
  ├── Randevu detay / değiştir / iptal / geç kalıyorum
  ├── History ── History detail ── Book again
  └── Profile ── My masters / Notifications / Appearance / Language / Account

MASTER
Calendar (day/week) ── Randevu detay / taşı / manuel randevu
  ├── Clients ── Client card ── Visit history
  ├── Services ── Add/Edit service
  ├── Schedule ── Weekly hours / Override / Vacation
  └── Profile ── Billing / Top-up / Requests / Settings / Support
```

---

# 5. Sonnet için uygulama sırası

## Faz 0 — Temel

1. Tasarım token'ları ve dört gerçek tema.
2. Tüm metinleri `tk`, `ru`, `en` localization'a taşıma.
3. Ortak loading/error/empty/confirmation componentleri.
4. Marketplace ekranlarını kaldırma veya sadece bağlı master'lar bağlamına dönüştürme.

## Faz 1 — Çalışan çekirdek

1. Auth + client/master registration + OTP.
2. Connection request / accept / decline.
3. Master profile, services, weekly schedule, override, vacation.
4. Availability API ve çift rezervasyon koruması.
5. Client booking wizard ve master day calendar.

## Faz 2 — Günlük kullanım

1. Appointment detail, change, cancel, status transitions, late signal.
2. Master customer list/card, offline contacts, manual booking.
3. Client history, filters, book again, my masters.
4. Persisted notifications/reminders.

## Faz 3 — Gelir modeli

1. Bakiye, provider abstraction, top-up, otomatik aylık çekim.
2. Ledger/transaction history.
3. Suspended state ve client-facing booking closure.

## Faz 4 — İyileştirme ve release

1. Waitlist / earlier-slot offer.
2. Offline cache/sync, low-end Android performans testleri.
3. Erişilebilirlik, localisation QA, analitik ve hata izleme.

---

# 6. Sonnet'e verilecek sabit ürün kuralları

Bu kuralları her implementasyon isteğine ekleyin:

1. KÖMEKÇI bir marketplace değildir. Client yalnızca master'ın onayladığı bağlantıdan sonra o master'ın profilini, servislerini ve uygunluğunu görebilir.
2. Public arama kataloğu, map, puan/review, herkese açık master filtreleri, favori/discovery v1'de yoktur.
3. Randevu çakışması UI ile değil server transaction ile engellenir; create/move/waitlist accept her seferinde yeniden doğrulanır.
4. Master subscription suspended ise yeni online ve manuel booking kapalıdır; eski randevular, müşteri ve geçmiş görünür kalır.
5. Dört tema semantic token'lar üzerinden uygulanır; ekran widget'larında hard-coded renk kullanılmaz.
6. Android 8 / 1 GB RAM hedeflenir: ağır efekt, video, gereksiz animation ve büyük görseller yoktur.
7. Her async ekranın loading, empty, retryable error ve offline durumu bulunur.
8. Şartname üç dildir: Türkmence, Rusça, İngilizce.

