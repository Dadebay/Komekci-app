# Devam Notu (oturumlar arası handoff)

Bu dosya, `PROJE_EKRAN_VE_TASARIM_DENETIMI.md` üzerinde çalışan Claude oturumları arasında "nerede kalındı" bilgisini taşımak için var. Yeni bir oturuma geçerken önce bu dosyayı, sonra denetim raporunu okuyun.

**Kullanıcı kısıtı (önemli):** Mevcut tasarıma ait hiçbir şeyi silmeyin/kaldırmayın. Denetim raporunun "marketplace'i kaldırın" maddesi (2.6, 2.15, Faz 0 #4) kullanıcı tarafından ertelendi — public master dizini, filtreler ve favoriler ekranları **kasıtlı olarak dokunulmadan** bırakıldı.

## Bu oturumda yapılanlar (19 Ağustos 2026)

1. **Derleme hatası düzeltildi:** [booking_flow.part.dart](lib/features/booking/presentation/booking_flow.part.dart) — `BookingPage` widget'ına `preselectedServiceName` parametresi eklendi ("Tekrar randevu al" akışı, spec 2.14). Önceki oturum tam bu satırda kesilmişti.

2. **Tema token migrasyonu (Faz 0 madde 1):** `lib/core/theme/app_theme_tokens.dart` içindeki `AppThemeTokens` sistemi zaten mevcuttu ama çoğu ekran hâlâ eski sabitleri (`ink`, `gold`, `cream`, `line`, `Colors.white`) doğrudan kullanıyordu — bu yüzden ivory dışındaki 3 tema (onyx/champagne/rose) çalışmıyordu. Bu, ekranların *yapısını değiştirmeden*, sadece renk kaynaklarını `context.appTokens` üzerinden okumaya çeviren bir refactor. Mapping:
   - `ink` → `tokens.textPrimary`
   - `gold` → `tokens.accent`
   - `cream` → `tokens.surfaceElevated`
   - `line` → `tokens.border`
   - `Colors.white` → bağlama göre `tokens.surface` / `tokens.surfaceElevated` / `tokens.accentOn`
   - Değişken adı **`tokens`** kullanılıyor, `t` değil (kod tabanında `t` zaten çeviri closure'ı: `String t({required tk, ru, en})`).
   - Referans dosya: [booking_flow.part.dart](lib/features/booking/presentation/booking_flow.part.dart) (zaten bu convention'la yazılmış).

   **Tamamlanan dosyalar (0 kalan):** `master_setup.part.dart`, `language_screen.part.dart`, `notification_screens.part.dart`, `role_screen.part.dart`, `home_content.part.dart`, `home_shells.part.dart`, `home_dashboard.part.dart`, `service_screens.part.dart`, `cabinet_screens.part.dart`.

   **Kısmen kalan dosyalar** (aşağıdaki komutla tekrar sayılabilir):
   ```bash
   grep -coE "Colors\.white|\bink\b|\bgold\b|\bcream\b|\bline\b" <dosya>
   ```
   - `appointment_management.part.dart` — ~6 kalan (kalanlar muhtemelen kasıtlı `ThemeScreen` swatch istisnaları, kontrol edin)
   - `auth_flow.part.dart` — ~11 kalan (hiç başlanmadı)
   - `login_screen.part.dart` — ~4 kalan (hiç başlanmadı)
   - `customer_screens.part.dart` — ~2 kalan (neredeyse bitmiş, son kontrol edilmedi)
   - `client_dashboard.part.dart` — ~10 kalan (master directory/favorites/master profile bölümleri dahil — **yapısına dokunmadan** sadece renk)
   - `onboarding_flow.part.dart` — ~5 kalan (hiç başlanmadı)
   - `schedule_screens.part.dart` — ~3 kalan
   - `splash_screen.part.dart` — kasıtlı olarak dokunulmadı: splash ekranı marka anı olarak sabit ivory/altın renklerle tasarlanmış (spec 1.1), tema-bağımsız kalması muhtemelen doğru — ama kesin karar verilmedi, kontrol edin.

   **Bilinen kasıtlı istisnalar (bunlara dokunmayın):**
   - `cabinet_screens.part.dart` içindeki `ThemeScreen` — 4 temanın kendi renk örneklerini (swatch) aynı anda gösteren ekran; `context.appTokens` kullanılırsa hepsi aktif temanın rengiyle görünür, bu yanlış olur. `cream`/`ink`/`Colors.white` tuple'ları bilerek literal bırakıldı.
   - Fotoğraf/banner üzerine bindirilmiş sabit koyu overlay + beyaz ikon rozetleri (örn. `photo_picker.dart` içindeki düzenle rozeti) — bunlar temadan bağımsız, kasıtlı literal.

3. **flutter analyze / flutter test:** Bu oturumun sonunda ikisi de temiz geçiyor (sadece third_party klasöründeki eski uyarılar ve 4 adet `curly_braces_in_flow_control_structures` info kaldı, hata yok).

## Not: paralel arka plan ajanları kararsız davrandı

Bu oturumda 6 paralel ajana dosya grupları verildi; çoğu birkaç kez "600s ilerleme yok" veya "API error" nedeniyle durdu ve resume edilmek zorunda kaldı. Kullanıcı sonunda ikisini elle durdurdu. Yeni bir oturum aynı yaklaşımı tekrarlarsa, dosya başına daha küçük görev parçaları (tek dosya, ~30-50 occurrence) ve daha sık kontrol önerilir.

## 19 Ağustos 2026 — devam oturumu (renk migrasyonu tamamlandı)

Yukarıdaki "kısmen kalan dosyalar" listesi bitirildi:
- `auth_flow.part.dart`, `onboarding_flow.part.dart`, `schedule_screens.part.dart`, `client_dashboard.part.dart` — tüm `ink`/`gold`/`cream`/`line`/`Colors.white` kalıntıları `context.appTokens` üzerinden okunacak şekilde değiştirildi.
- `appointment_management.part.dart`, `login_screen.part.dart`, `customer_screens.part.dart` — kalan occurrence'lar tek tek kontrol edildi, hepsi zaten meşru istisna (ThemeScreen swatch'ları, fotoğraf/banner üzerindeki sabit beyaz overlay, her zaman yeşil sabit "ara" rozeti). Değişiklik gerekmedi.
- `splash_screen.part.dart` — hâlâ kasıtlı olarak dokunulmadı (marka anı, tema-bağımsız kalması makul).
- Doğrulama: `flutter analyze` (4 pre-existing info dışında temiz) ve `flutter test` (`All tests passed!`) bu oturumun sonunda tekrar çalıştırıldı, ikisi de temiz.

**Sonuç: Faz 0 madde 1 (tema token migrasyonu) tamamen bitti.** `grep -coE "Colors\.white|\bink\b|\bgold\b|\bcream\b|\bline\b" <dosya>` artık hiçbir ekran dosyasında gerçek bir eksik göstermiyor (yalnızca yukarıdaki bilinen istisnalar kalıyor).

## 19 Ağustos 2026 — devam oturumu #2 (client geçmiş filtreleri)

`ClientBookingsScreen` (`client_dashboard.part.dart`) StatefulWidget'a çevrildi: master + durum filtresi (bottom sheet, `StatefulBuilder` ile canlı chip güncellemesi), 20'li "Has köp görkez" sayfalama, en yeni üstte sıralama, boş sonuç empty-state. `flutter analyze` + `flutter test` temiz.

## 19 Ağustos 2026 — devam oturumu #3 (master kayıt + takvim)

Beklenenden çok daha tamamlanmış çıktı: `master_setup.part.dart` (4 adımlı wizard: telefon/OTP/profil/abonelik) ve `schedule_screens.part.dart` (action sheet, randevu taşıma, manuel randevu formu) zaten büyük ölçüde gerçek ve işlevseldi. Bulunan ve kapatılan gerçek eksikler:

- `MasterRegistrationScreen`'de nickname benzersizlik kontrolü yoktu — `_takenNicknames` (auth_flow.part.dart) ile eklendi.
- Randevu aksiyon sheet'inde (`_openActions`, schedule_screens) **tamamlandı/geldi/gelmedi durum geçişleri hiç yoktu** — sadece taşı/iptal/ara/müşteri profili vardı. `BookingProvider.markNoShow()` eklendi, action'lar status'a göre bağlamsal gösteriliyor (expected → geldi/gelmedi; arrived → tamamlandı; expected/arrived → taşı/iptal; completed/cancelled/noShow → salt-okunur, sadece profil+ara kalıyor).
- `ScheduleScreen`'e "Bugün" kısayolu ve **yeni bir hafta görünümü ekranı** (`WeekOverviewScreen`) eklendi — 7 satırlık hafif yoğunluk listesi (ağır takvim widget'ı değil), her satır o günün randevu sayısını gösteriyor, tıklayınca day view'a dönüyor.
- Randevu taşıma sheet'i (`_pickAppointmentDateTime`) artık mevcut zamanı üstte gösteriyor ve **çakışan saat chip'lerini pasifleştiriyor** (`BookingProvider.hasConflict`, `excludeId` ile kendi randevusu hariç) + onay anında tekrar doğruluyor. Bu fonksiyonun `customer_screens.part.dart` içindeki ikinci çağrı yeri de (`NewAppointmentScreen._pickDateTime`) yeni zorunlu parametrelere göre güncellendi.
- Doğrulama: `flutter analyze` + `flutter test` bu oturumun sonunda temiz.

**Kullanıcı bu noktada oturumu durdurmamı istedi** — devam eden bir görev yoktu, her şey tutarlı ve derlenir durumda bırakıldı.

## Paralel çalışma uyarısı (aktif — 19 Ağustos 2026, oturum #4'ten itibaren)

Kullanıcı kalan işi iki oturuma bölüyor:
- **Bu oturum (ben):** `cabinet_screens.part.dart` içindeki `WorkingHoursScreen`, `VacationScreen`, `SpecialDaysScreen`, `CabinetProfileScreen` sınıfları üzerinde çalışıyorum.
- **Ayrı bir AI/oturum:** `BillingScreen` + `_BalanceChip` + `_SubscriptionDateRow` üzerinde çalışacak (görev tanımı kullanıcıya `billing_task.md` olarak verildi — yeni bir `BillingProvider` oluşturup bakiye/ödeme geçmişini gerçek state'e bağlıyor, `master_setup.part.dart`'taki `_PhonePaymentDialog`/`_BankPickerDialog`'a da dokunacak).

**Eğer bu notu okuyorsan ve az önce bahsi geçen sınıflardan birini değiştirmen gerekiyorsa:** önce `git diff` ile kimin ne değiştirdiğini kontrol et, aynı sınıfa iki oturum birden dokunmasın. İş bitince bu bölümü silebilirsin.

**Güncelleme:** Billing görevi bitti (ayrı AI). `cabinet_screens.part.dart` kümem (WorkingHoursScreen/VacationScreen/SpecialDaysScreen/CabinetProfileScreen) de bitti — yeni `MasterProfileProvider` eklendi (`lib/features/cabinet/application/master_profile_provider.dart`), `_mockMasterName` vb. sabitler kaldırıldı. Şimdi `customer_screens.part.dart` (müşteriler listesi/kartı) ayrı bir AI'ya verildi (görev tanımı `customers_task.md`), o dosyaya da dokunmuyorum. Ben şimdi `schedule_screens.part.dart`'a geçiyorum (master günlük takvim: complete/arrived/no-show aksiyonları + hafta görünümü).

## 20 Ağustos 2026 — üçüncü dile (İngilizce) geçiş tamamlandı

Kullanıcı "client ve master tarafında eksik çevirileri ekle" diye istedi — bu, ekranların binary `tk ? 'X' : 'Y'` (Türkmen/Rus) kalıbından `AppLanguage` 3 dilli (`tk`/`ru`/`en`) `pickTr`/`t()` kalıbına geçirilmesi işiydi (`customer_screens.part.dart` hariç, o dosya ayrı bir AI'ya verildi).

**Tamamlanan dosyalar (artık `tk ? '...' : '...'` kalıbı sıfır, sadece bilinçli istisnalar kaldı):**
- `booking_flow.part.dart`, `appointment_management.part.dart` — kaçırılan çift tırnaklı kalıntılar düzeltildi.
- `schedule_screens.part.dart` (48 occurrence) — master günlük takvim, hafta görünümü, randevu aksiyon sheet'i, yeni randevu formu. Paylaşılan widget'lar (`_AppointmentRow`, `_FreeSlotRow`, `_pickAppointmentDateTime`) `tk: bool` yerine `language: AppLanguage` alıyor artık — bu yüzden `customer_screens.part.dart` ve `home_dashboard.part.dart`'taki çağrı noktaları da (sadece parametre ismi/tipi) senkronize edildi, bunlar mekanik derleme düzeltmesiydi.
- `service_screens.part.dart` (25 occurrence) — `pickCompressedImage()` (`lib/shared/widgets/photo_picker.dart`) da `turkmen: bool` yerine `language: AppLanguage` alacak şekilde güncellendi.
- `cabinet_screens.part.dart` (102 occurrence, en büyük dosya) — `CabinetScreen`, `_MasterCard`, `ChangeModeScreen`, `WorkingHoursScreen`, `VacationScreen`, `SpecialDaysScreen`, `ClientNotifyScreen`, `SendMessageScreen`, `SelectedClientsScreen`, `RecentClientsScreen`, `BillingScreen`, `SupportScreen` dahil hepsi.
- `lib/features/billing/presentation/billing_history_screen.part.dart` (9 occurrence) — `_LedgerEntryTile`, `BillingHistoryScreen`.

**Bilinçli tek istisna:** `_ErrorText` widget'ı (`service_screens.part.dart`) hâlâ `bool tk` alıyor — çünkü `customer_screens.part.dart` da aynı widget'ı çağırıyor ve o dosyaya dokunmuyorum. Onun imzasını değiştirmek o dosyada da bir düzeltme gerektirirdi.

**Doğrulama:** `flutter analyze lib/` (4 önceden var olan `curly_braces_in_flow_control_structures` info dışında temiz) ve `flutter test` (`All tests passed!`) bu işin sonunda tekrar çalıştırıldı.

**Not:** `customer_screens.part.dart` hâlâ dokunulmadı (ayrı AI'ya ait). Onun kendi çeviri durumu bilinmiyor — kontrol edilmeli.

## Sonraki adımlar (öncelik sırasına göre, kullanıcının "tasarımı silme" kısıtına uygun)

1. `PROJE_EKRAN_VE_TASARIM_DENETIMI.md` içindeki Faz 1 kalemlerine geçin: bağlantı isteği akışı (2.3-2.5, `ConnectMasterScreen`/`MasterPreviewScreen`/`RequestPendingScreen` hâlâ statik/prototip).
2. Kalan master tarafı maddeleri: müşteri listesi/kartı rafine (no-show sayacı, durum chip'leri ikon+metin), connection requests rafine, servis drag-reorder, haftalık program/override/tatil rafine, abonelik/bakiye ledger geçmişi (top-up akışı zaten var, "işlem geçmişi" listesi eksik olabilir — kontrol edin), suspended-state banner (bakiye yetersizken hiçbir yerde uyarı yok), master profil düzenleme + "profili önizle".
3. Not: `MasterRegistrationScreen`/`MasterSubscriptionScreen`/`ScheduleScreen`'in beklenenden çok daha olgun olduğu görüldü — yeni bir oturuma başlarken "eksik" varsaymadan önce dosyayı gerçekten okuyun, denetim raporunun madde başlıkları yanıltıcı olabilir (kod, raporun yazıldığı andan sonra da gelişmiş olabilir).
