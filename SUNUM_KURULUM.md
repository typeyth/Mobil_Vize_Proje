# 🖥️ SUNUM PC'SİNDE SIFIRDAN KURULUM REHBERİ

Hiçbir şey kurulu olmasa bile bu adımları sırayla takip et. Her adımda **ne yazacağın** ve **ne göreceğin** yazıyor.

---

## ADIM 0 — Gerekli Programları Kontrol Et

PowerShell veya CMD aç, şunları yaz:

```
python --version
```
✅ `Python 3.10.x` veya üstü yazmalı. Yazmazsa → **Python kur** (aşağıda).

```
flutter --version
```
✅ `Flutter 3.x.x` yazmalı. Yazmazsa → **Flutter kur** (aşağıda).

```
git --version
```
✅ `git version 2.x.x` yazmalı. Yazmazsa → **Git kur** (aşağıda).

---

## ADIM 0.1 — Python Kurulumu (kurulu değilse)

1. https://www.python.org/downloads/ adresine git
2. **Download Python 3.12+** butonuna tıkla
3. İndirilen `.exe` dosyasını çalıştır
4. ⚠️ **"Add Python to PATH" kutusunu İŞARETLE** (en altta, çok önemli!)
5. "Install Now" tıkla
6. Bittikten sonra PowerShell'i **kapat ve yeniden aç**
7. `python --version` ile kontrol et

---

## ADIM 0.2 — Flutter Kurulumu (kurulu değilse)

1. https://docs.flutter.dev/get-started/install/windows adresine git
2. Flutter SDK zip'ini indir
3. `C:\flutter` klasörüne çıkar (masaüstüne değil!)
4. Sistem ortam değişkenlerinde PATH'e `C:\flutter\bin` ekle:
   - Windows Arama → "ortam değişkenleri" yaz → "Sistem ortam değişkenlerini düzenle"
   - "Ortam Değişkenleri" → "Path" → "Düzenle" → "Yeni" → `C:\flutter\bin`
5. PowerShell'i **kapat ve yeniden aç**
6. Çalıştır:
```
flutter doctor
```
Android toolchain uyarısı veriyorsa:
```
flutter doctor --android-licenses
```
Her soruya `y` yaz.

> ⚠️ Android Studio ve en az bir emülatör kurulu olmalı. Yoksa Android Studio'yu
> https://developer.android.com/studio adresinden indir, kurulumda "Android Virtual Device" seçeneğini işaretle.

---

## ADIM 0.3 — Git Kurulumu (kurulu değilse)

1. https://git-scm.com/download/win adresine git
2. İndir, çalıştır, her şeye "Next" de, kur
3. PowerShell'i kapat ve yeniden aç

---

## ADIM 1 — Projeyi Aç

Eğer proje USB'den geliyorsa, klasörü masaüstüne kopyala.
Eğer GitHub'taysa:

```
cd C:\Users\%USERNAME%\Desktop
git clone https://github.com/KULLANICI_ADIN/Mobil_Vize_Proje.git
```

Sonra proje klasörüne gir:

```
cd C:\Users\%USERNAME%\Desktop\Mobil_Vize_Proje
```

Klasör yapısı şöyle olmalı:

```
Mobil_Vize_Proje/
├── backend_api/       ← Django backend
├── mobile_app/        ← Flutter mobil uygulama
├── README.md
└── SAVUNMA_REHBERI.md
```

---

## ADIM 2 — Backend Kurulumu (Django API)

### 2.1 — Backend klasörüne gir

```
cd backend_api
```

### 2.2 — Sanal ortam oluştur

```
python -m venv venv
```

> **Ne yapıyor?** Projenin kütüphanelerini bilgisayardaki diğer projelerden ayıran izole bir ortam oluşturur.

### 2.3 — Sanal ortamı aktifleştir

```
venv\Scripts\activate
```

✅ Satırın başında `(venv)` yazısı görmelisin. Bu, sanal ortamın aktif olduğu anlamına gelir.

### 2.4 — Kütüphaneleri kur

```
pip install -r requirements.txt
```

✅ Django ve djangorestframework kurulacak. "Successfully installed" yazısı görmelisin.

> **Ne kuruyor?**
> - `Django` = web sunucusu çerçevesi (framework). HTTP isteklerini karşılar, veritabanıyla konuşur.
> - `djangorestframework` = Django'ya REST API (JSON gönder/al) yeteneği ekleyen ek kütüphane.

### 2.5 — Veritabanı tablolarını oluştur

```
python manage.py migrate
```

✅ "Applying persons.0001_initial... OK" gibi satırlar göreceksin. Bu, `models.py`'deki Person sınıfına göre veritabanında tablo oluşturur.

> **Ne yapıyor?** `db.sqlite3` dosyasının içine `persons_person` adlı tabloyu oluşturur.
> Sütunlar: id, fullName, department, photoUrl, birthPlace, birthDate, email, phone.
> SQL yazmadık — Django modelden tabloyu kendisi üretti (ORM).

### 2.6 — Örnek verileri yükle

```
python manage.py loaddata ornek_kisiler
```

✅ "Installed 5 object(s) from 1 fixture(s)" yazısı görmelisin.

> **Ne yapıyor?** `persons/fixtures/ornek_kisiler.json` dosyasındaki 5 kişiyi veritabanına ekler.
> Boş listeyle sunum yapmamak için hazır veri.

### 2.7 — Sunucuyu başlat

```
python manage.py runserver 0.0.0.0:8000
```

✅ Şunu görmelisin:
```
Starting development server at http://0.0.0.0:8000/
```

> **Neden `0.0.0.0`?** Sadece `runserver` yazsaydık sunucu yalnız `127.0.0.1`'den geleni kabul ederdi.
> `0.0.0.0` = "herhangi bir adresten gelen isteğe cevap ver". Emülatör `10.0.2.2` adresiyle gelir,
> gerçek telefon `192.168.x.x` ile gelir — ikisi de kabul edilsin.

### 2.8 — Tarayıcıdan test et

Yeni bir tarayıcı sekmesi aç:

```
http://127.0.0.1:8000/api/persons
```

✅ 5 kişilik JSON listesi görmelisin. DRF'nin güzel sarı-beyaz arayüzü açılır.

**Bu terminal AÇIK KALACAK!** Sunucuyu kapatma. Yeni komutlar için **yeni bir terminal** aç.

---

## ADIM 3 — Mobil Uygulama Kurulumu (Flutter)

### 3.1 — Yeni bir terminal aç ve mobile_app klasörüne gir

```
cd C:\Users\%USERNAME%\Desktop\Mobil_Vize_Proje\mobile_app
```

### 3.2 — Paketleri indir

```
flutter pub get
```

✅ "Got dependencies!" yazısı görmelisin.

> **Ne yapıyor?** `pubspec.yaml`'deki bağımlılıkları (http, url_launcher) internetten indirir.

### 3.3 — Emülatörü aç

Android Studio'yu aç → Device Manager → emülatörü başlat (veya zaten açıksa atla).

Ya da komutla:

```
flutter emulators --launch <emülatör_adı>
```

Emülatör adını bilmiyorsan:

```
flutter emulators
```

### 3.4 — Uygulamayı çalıştır

```
flutter run
```

✅ "✓ Built build\app\outputs\flutter-apk\app-debug.apk" ve ardından emülatörde uygulama açılmalı.

⏱️ İlk çalıştırma 2-3 dakika sürebilir (derleme). Sonrakiler çok daha hızlı.

> Eğer birden fazla cihaz bağlıysa:
> ```
> flutter run -d <cihaz_id>
> ```
> Cihaz listesi: `flutter devices`

### 3.5 — Test et

Emülatörde şunları dene:

1. ✅ **Liste** — 5 kişi görünüyor mu?
2. ✅ **Detay** — Bir kişiye tıkla → fotoğraf, ad, bilgiler görünüyor mu?
3. ✅ **Ekle** — Sağ alttaki + butonu → form → bilgi gir → KAYDET → listede görünüyor mu?
4. ✅ **Düzenle** — Detay → DÜZENLE → bir alanı değiştir → GÜNCELLE → değişti mi?
5. ✅ **Sil** — Detay → KİŞİYİ SİL → "Emin misiniz?" → Sil → listeden gitti mi?

---

## ADIM 4 — APK Üretme (Teslim İçin)

```
flutter build apk
```

✅ APK şurada oluşur:
```
mobile_app\build\app\outputs\flutter-apk\app-release.apk
```

---

## 🚨 SORUN GİDERME

| Sorun | Çözüm |
|---|---|
| `python` komutu tanınmıyor | Python'u PATH'e ekleyerek yeniden kur |
| `flutter` komutu tanınmıyor | PATH'e `C:\flutter\bin` ekle, terminali yeniden aç |
| Emülatörde liste boş / hata | Backend terminal açık mı kontrol et. `runserver 0.0.0.0:8000` ile başlat |
| "Connection refused" hatası | `api_service.dart`'ta `baseUrl` doğru mu? Emülatör için `10.0.2.2` olmalı |
| Gerçek telefonda çalışmıyor | `baseUrl`'i bilgisayarın IP'sine değiştir (ör: `192.168.1.20`). Aynı Wi-Fi'da ol. Windows güvenlik duvarında 8000 portunu aç |
| Türkçe karakterler bozuk | `utf8.decode(response.bodyBytes)` kullanıldığından sorun olmaz. `response.body` kullanılırsa bozulur |
| `flutter run` hata veriyor | `flutter clean` sonra `flutter pub get` sonra tekrar `flutter run` |
| Gradle hatası | `mobile_app/android` içinde `gradlew clean` çalıştır |

---

## ⏱️ HIZLI BAŞLATMA (Her Şey Zaten Kuruluysa)

İki terminal aç:

**Terminal 1 (Backend):**
```
cd C:\Users\%USERNAME%\Desktop\Mobil_Vize_Proje\backend_api
venv\Scripts\activate
python manage.py runserver 0.0.0.0:8000
```

**Terminal 2 (Mobil):**
```
cd C:\Users\%USERNAME%\Desktop\Mobil_Vize_Proje\mobile_app
flutter run
```
