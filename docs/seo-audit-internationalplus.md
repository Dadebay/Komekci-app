# SEO Audit — internationalplus.net

Tarih: 2026-10-14 · Kapsam: teknik SEO, on-page, schema, çok dilli yapı, içerik, itibar

## Metodoloji ve sınırlar (önce bunu oku)

- **Semrush bu oturumda bağlı değil.** Anahtar kelime hacmi, organik trafik, backlink profili, Authority Score, rakip karşılaştırması bu raporda **yok**. Semrush'ta çalıştırılacak kısım en altta ("Semrush'ta tamamlanacaklar").
- Veri kaynağı: canlı site (HTML, header, robots, sitemap), 128 URL'lik örnek tarama, web araması.
- Örnek: sitemap'teki **1.836 URL**'den 128'i çekildi; **109'u yüklendi, 19'u 30 sn'de zaman aşımına uğradı.** Yüzdeler bu 109 sayfaya aittir. Zaman aşımı kısmen benim 6 paralel istekten olabilir, kesin sunucu hatası diye okuma.
- PageSpeed Insights API günlük kota hatası verdi → **Core Web Vitals / Lighthouse skoru ölçülemedi.** Aşağıdaki hız bulguları ham ölçümlerdir (TTFB, HTML boyutu).
- `site:` araması çalışmadı → **indeks sayısı doğrulanamadı** (Search Console'dan bakılmalı).

## Genel görünüm

| Alan | Durum |
|---|---|
| Crawl/indeks temelleri | İyi |
| Çok dilli (hreflang) | İyi kurulmuş, kontrol edilecek noktalar var |
| Sunucu hızı / sayfa ağırlığı | **Zayıf** |
| Structured data | Kapsamlı ama **riskli** (sitewide self-serving rating) |
| İçerik stratejisi | Hacimli ama **YMYL/itibar riski** (ünlü içerikleri) |
| On-page detay (title, alt, H1) | Orta |
| İtibar / E-E-A-T | Karışık (Trustpilot uyarısı) |

## İyi olanlar

- http→https ve www→non-www **301** ile tek hosta toplanıyor; var olmayan sayfa gerçek **404** dönüyor.
- `robots.txt` temiz (yalnızca `/wp-admin/` kapalı, sitemap bildirilmiş).
- Rank Math sitemap indeksi: 10 alt sitemap (post ×4, page ×5, category). `llms.txt` mevcut.
- Örneklenen 109 sayfanın tamamında **canonical var ve kendine işaret ediyor**, hiçbirinde `noindex` yok, başlıklar benzersiz, ortalama **~2.960 kelime**.
- 13 dil için `hreflang` + `x-default`, çevrilmiş slug'lar (ör. `/de/zahnmedizinisch/zahnimplantat/`).
- BreadcrumbList 108/109 sayfada; doktor profilleri (23) `Physician` schema ile bağlı → E-E-A-T için güçlü zemin.
- NAP tutarlı: Halkalı Merkez Mah., Küçükçekmece/İstanbul · +90 850 309 44 61.

## Bulgular (öncelik sırasıyla)

### 🔴 Kritik / Yüksek

**1. Sunucu yanıtı ve sayfa ağırlığı**
- Ana sayfa TTFB ≈ **2,7 sn**, tam HTML indirme ≈ 3–4,4 sn; `/dental/dental-implant/` TTFB ≈ 2,4 sn.
- Ana sayfa HTML'i **758 KB**; örnek sayfa ortalaması **427 KB**. Ana sayfada **183 görsel, 59 script, 28 CSS dosyası.**
- Header çelişkisi: `X-LiteSpeed-Cache-Control: public,max-age=36000` ama `Cache-Control: max-age=600, private, must-revalidate` → `private` CDN/edge önbelleğini engeller.
- Sıkıştırma `gzip` (Brotli yok).
- Etki: LCP/INP zayıf olma ihtimali yüksek; mobil + sağlık turizmi (yurt dışından, yavaş bağlantılı kullanıcılar) için doğrudan dönüşüm kaybı.
- Aksiyon: CDN (Cloudflare vb.) + `public` cache, Brotli, ana sayfada lazy-load/slider'ı sadeleştir, kullanılmayan eklenti scriptlerini kaldır (Pix popup ×~50 sertifika popup'ı ana sayfada), kritik CSS. PageSpeed'i tarayıcıdan tekrar çalıştır.

**2. Sitewide self-serving `AggregateRating` (ceza riski)**
- `Dentist` + `AggregateRating` (**4,8 / 5.504 yorum**) örneklenen **109/109** sayfada var — blog yazıları ve ünlü yazıları dahil.
- Google, kuruluşun kendi sitesinde kendi hakkında verdiği (self-serving) LocalBusiness/Organization puanlarını yıldız olarak göstermiyor; tüm sitede kopyalamak "spammy structured data" manuel işlemi riski taşır.
- 5.504 rakamı yalnızca marka kaynaklı görünen üçüncü taraf listicle'da da geçiyor; Trustpilot'ta ise sayfa "kurallara aykırılık nedeniyle puan gösterilmiyor" notuyla işaretli. Doğrulanamayan rakam YMYL'de güven sorunu.
- Aksiyon: `AggregateRating`'i tüm sayfalardan kaldır; yalnızca gerçek, doğrulanabilir ve sayfada görünen yorum içeren sayfada tut (veya hiç tutma). Rakam kaynağını belgelendir.

**3. Ünlü içerik kümesi (YMYL + itibar riski)**
- Slug desenine göre EN sitemap'in **~244 URL'si** (~%27) ünlü isimli: `*-plastic-surgery`, `*-before-after`, `*-hair-transplant` (ör. Lewis Hamilton, Margot Robbie, Lil Kim…). Bazı slug'lar uygunsuz kelimeler içeriyor ve **37 slug 75 karakterden uzun**.
- Gerçek kişilerin tıbbi işlemleri hakkında spekülasyon; "before/after" ifadesi kliniğin yaptığı izlenimi yaratabilir. Kalite sinyali (Helpful Content / site genel kalitesi) ve hukuki/itibar riski.
- Not: bu sayıyı slug desenine göre saydım, her sayfayı tek tek okumadım.
- Aksiyon: sayfa bazlı trafik/dönüşüm verisine bak; trafiği olmayanları birleştir/`noindex`/410; kalanlara "kliniğimiz tedavi yapmadı, kamuya açık görüntülerin analizi" notu, editoryal kaynak ve doktor onayı ekle.

**4. İtibar ve güven sinyalleri**
- Trustpilot'ta karışık yorumlar ve puan gösterim uyarısı; bazı yorumlarda sonuç/komplikasyon şikâyeti.
- Aksiyon: Google Business Profile'ı (puan, yanıtlar) güçlendir; şikâyet yönetimi; lisans/Sağlık Bakanlığı belgesi numarasını görünür ve doğrulanabilir yap.

### 🟠 Orta

**5. Schema tutarsızlıkları**
- `@id` hosts karışık: `https://www.internationalplus.net/#medicalorganization` (www) vs. site geneli `https://internationalplus.net/#…` (non-www, canonical).
- 21 `Physician` kaydı `#dentalclinic` düğümüne bağlanıyor; ana sayfada bu `@id` ile eşleşen bir düğüm tanımı doğrulanamadı → kopuk grafik olabilir.
- Aynı sayfada 5 ayrı JSON-LD bloğu (MedicalOrganization, Dentist, Physician grafiği, Organization/WebSite, FAQPage) → tek bir birleşik `@graph` olmalı.
- Klinik diş, saç, estetik, bariatrik, göz, beyin stimülasyonu sunuyor ama tür `Dentist` → `MedicalClinic`/`MedicalOrganization` + `medicalSpecialty` daha doğru.
- İki farklı Facebook sayfası: footer `InternationalPluss`, schema `sameAs` `internationalplusofficial`; `sameAs` listesinde Instagram/YouTube/X yok.
- Ana sayfada `twitter:data2` "Time to read: **134 minutes**" ve 5 adet `og:video` → temizle.
- FAQPage: 2023'ten beri FAQ zengin sonucu çoğunlukla devlet/sağlık otoritesi sitelerine gösteriliyor; SERP faydası beklenmemeli. Ana sayfada FAQ bloğu **kelimesi kelimesine iki kez** var.

**6. Title / description / başlık yapısı** (109 sayfa örnek)
- **38 sayfa (%35)** title > 60 karakter; **21** description > 160; **5** description eksik; **2** sayfada H1 yok, **1** sayfada 2 H1.
- Şablon tutarsız: "- International Plus | Turkey | Istanbul" ve "- International Plus". Örn. Rhinoplasty: `Rhinoplasty - International Plus | Turkey | Istanbul` (niyet kelimesi yok: cost/price/before-after).
- H1 yazım hataları: "Hair Transplant in **istanbul,Turkey**".
- Blog H1'i yalnızca "Blog"; About H1 "About Us".
- Ana sayfa: title "Health Tourism Clinic", H1 "Top Dental Clinic" ve ikinci H1 "Leading Dental Health Care Provider…" → konumlandırma çelişkisi, **2 adet H1**.
- Menüde yazım hataları (Türkçe noktalı/noktasız I karışmış): "Haır Transplantatıon", "Deep Braın Stimulatıon", "Consultatıon", "Aesthetıc", "Barıatrıc Surgerıes". Marka güveni + anchor metin kalitesi.

**7. Görsel alt metinleri**
- Örnekte **5.595 görselin 2.354'ü (%42) alt metinsiz.** Ana sayfada 183 görselin 68'i alt'sız (before/after ve galeri dahil); bazıları dosya adı ("Particle element", "dental icon").
- Aksiyon: tedavi + şehir + bağlam içeren alt metinler, before/after için betimleyici alt; dekoratif görsellerde `alt=""` bilinçli.

**8. URL yapısı / indeks şişmesi**
- EN 909 URL'nin **829'u kökte tek segment** (blog, ünlü, tedavi sayfaları karışık); tedavi sayfaları ise `/aesthetic/body-aesthetic/...` gibi 3 seviyeli → tutarsız mimari, topikal küme sinyali zayıf, iç link otoritesi dağınık.
- Aksiyon: blog/ünlü içeriği `/blog/` altına (301 ile) toplamayı değerlendir veya en azından kategori/hub sayfalarıyla bağla; tedavi sayfalarında tutarlı hiyerarşi.

**9. Çok dilli yapı — doğrulanacaklar**
- Ana sayfada "27 dil" iddiası, anahtar 13 dil sunuyor.
- 109 sayfanın 78'i yalnızca 4 `hreflang` girdisi taşıyor (yani çoğu içerik 13 dile çevrilmemiş olabilir); hreflang'ların **karşılıklılığı (return tag)** Screaming Frog/Semrush Site Audit ile doğrulanmalı.
- `.us`, `.ro` ve Lehçe alan adları ayrı → ana domaine karşı kanibalizasyon / otorite bölünmesi; hreflang veya 301 stratejisi netleştirilmeli.

### 🟡 Düşük / hijyen

- `/wp-json/wp/v2/users` **herkese açık** (yazar adı/URL sızdırıyor) → kapat.
- Güvenlik header'ları: HSTS, CSP, X-Frame-Options, Referrer-Policy yanıtta görünmedi (yalnızca `X-Content-Type-Options`). Bunlar doğrudan sıralama faktörü değil, ama güven ve tarayıcı uyarıları için eklenmeli.
- Sitemap alt dosyalarının `lastmod` değerleri en son 2026-06-26 → yaklaşık 3,5 aydır içerik güncellemesi görünmüyor olabilir (ana sayfa ise 2026-10-06'da güncellenmiş). Blog yayın temposunu kontrol et.
- Comment feed ve tüm feed'ler açık; gerek yoksa kapat.
- Ana sayfada onlarca sertifika popup'ı DOM'u şişiriyor (bkz. #1).

## Aksiyon planı

**İlk 2 hafta (hızlı kazanç)**
1. `AggregateRating`'i sitewide kaldır; schema'yı tek `@graph`'a topla, `@id` hostunu non-www yap, `MedicalClinic` türüne geç, `sameAs`'ı tamamla.
2. Ana sayfa: tek H1, title/H1 hizalaması, tekrarlanan FAQ bloğunu sil, menü yazım hatalarını düzelt, `twitter:data2` / fazladan `og:video` temizle.
3. `/wp-json/wp/v2/users`'ı kapat, güvenlik header'larını ekle.
4. Search Console'da indeks/kapsam, manuel işlem ve "Core Web Vitals" raporlarına bak.

**2–6 hafta**
5. CDN + doğru `Cache-Control`, Brotli, script/CSS azaltma, görsel optimizasyonu; PageSpeed'i yeniden ölç.
6. 244 ünlü sayfasını trafik/dönüşüm verisiyle sınıflandır (tut / birleştir / noindex / sil).
7. Title/description şablonu: `{Tedavi} in Turkey/Istanbul: Cost, Process & Results | International Plus` gibi, ≤60/≤155 karakter; eksik açıklamaları tamamla.
8. Alt metin kampanyası: önce tedavi sayfaları ve before/after galerisi.

**6–12 hafta**
9. Topikal hiyerarşi: tedavi hub'ları, her tedaviye "fiyat/cost", "süreç", "risk/SSS", "UK/Almanya/ABD'den Türkiye'ye" niyet sayfaları (anahtar kelime hacmi Semrush'ta doğrulanmalı).
10. Alan adı stratejisi (.us/.ro/pl) ve hreflang karşılıklılık denetimi.
11. Google Business Profile, yorum toplama ve yanıt süreci; doktor sayfalarına kimlik/lisans/yayın/uzmanlık bilgisi.

## Semrush'ta tamamlanacaklar (bu raporda eksik)

1. **Site Audit** (domain: internationalplus.net, 13 dil dahil): Site Health, hreflang return-tag hataları, kırık link, redirect zincirleri, Core Web Vitals.
2. **Organic Research**: sıralanan anahtar kelimeler, trafik trendi, en çok trafik alan sayfalar — özellikle ünlü sayfalarının payı.
3. **Backlink Analytics + Backlink Audit**: toksik link oranı, kaynak dağılımı, anchor profili.
4. **Keyword Gap / Competitors**: Turkey dental/hair/aesthetic rakipleriyle (ülke bazlı: UK, DE, US).
5. **Position Tracking**: hedef ülke × cihaz × anahtar kelime.
6. **Listing Management / Local**: NAP tutarlılığı, GBP.

Semrush hesabını bağlarsan (veya bu bölümlerden CSV/ekran görüntüsü paylaşırsan) bu kısımları rapora ekleyebilirim.
