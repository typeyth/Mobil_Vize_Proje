# Mobil Programlama – Vize Projesi: Kişi Yönetim Sistemi

Telefon rehberi benzeri bir uygulama. Kişileri **listele, detay gör, ekle, düzenle, sil**.

```
 ┌──────────────┐     HTTP (GET/POST/PUT/DELETE)     ┌──────────────────┐   ┌────────────┐
 │ MOBİL UYGULAMA│ ─────────────────────────────────► │ DJANGO (backend) │◄─►│ SQLite DB  │
 │   (Flutter)   │ ◄───────────────────────────────── │  /api/persons    │   │ db.sqlite3 │
 └──────────────┘         JSON cevap                  └──────────────────┘   └────────────┘
```

| Klasör | Teknoloji | Görev |
|---|---|---|
| `backend_api/` | Django + Django REST Framework + SQLite | Veriyi saklar, REST/JSON API sunar |
| `mobile_app/`  | Flutter (Dart) | Listeler, detay gösterir, ekler/düzenler/siler |

---

## 1) Backend (API) Kurulumu

```bash
cd backend_api

# Sanal ortam oluştur ve aktifleştir
python -m venv venv
venv\Scripts\activate            # Windows
# source venv/bin/activate       # Mac / Linux

# Kütüphaneleri kur
pip install -r requirements.txt

# Veritabanı tablolarını oluştur
python manage.py migrate

# 5 örnek kişiyi yükle
python manage.py loaddata ornek_kisiler

# Sunucuyu başlat (0.0.0.0 = emülatör ve telefon da bağlanabilsin)
python manage.py runserver 0.0.0.0:8000
```

Tarayıcıda `http://127.0.0.1:8000/api/persons` → JSON dizisi görmelisin.

### API Endpoint Tablosu

| Metot | Adres | Açıklama | Başarı Kodu |
|---|---|---|---|
| GET | `/api/persons` | Tüm kişileri listeler | 200 |
| GET | `/api/persons/{id}` | Tek kişi detayını döner | 200 |
| POST | `/api/persons` | Yeni kişi oluşturur (JSON body) | 201 |
| PUT | `/api/persons/{id}` | Kişi bilgilerini günceller | 200 |
| DELETE | `/api/persons/{id}` | Kişiyi kalıcı olarak siler | 204 |

### Örnek JSON

```json
{
  "id": 1,
  "fullName": "Ahmet Yılmaz",
  "department": "Yazılım Geliştirme",
  "photoUrl": "https://randomuser.me/api/portraits/men/32.jpg",
  "birthPlace": "Adana",
  "birthDate": "1994-04-12",
  "email": "ahmet.yilmaz@sirket.com",
  "phone": "+905550123456"
}
```

---

## 2) Mobil Uygulama (Flutter) Kurulumu

```bash
cd mobile_app

# Paketleri indir
flutter pub get

# Emülatörde çalıştır (backend açık olmalı!)
flutter run

# APK üret
flutter build apk
```

APK çıktısı: `mobile_app/build/app/outputs/flutter-apk/app-release.apk`

### baseUrl Ayarı (`lib/services/api_service.dart`)

| Ortam | baseUrl |
|---|---|
| Android emülatör | `http://10.0.2.2:8000/api/persons` (varsayılan) |
| Gerçek telefon (aynı Wi-Fi) | `http://BILGISAYAR_IP:8000/api/persons` |
| iOS simülatör | `http://127.0.0.1:8000/api/persons` |

---

## 3) Proje Yapısı

```
Mobil_Vize_Proje/
├── backend_api/
│   ├── config/              Django ayarları (settings, urls)
│   ├── persons/             Kişi uygulaması (model, view, serializer, url)
│   ├── db.sqlite3           SQLite veritabanı dosyası
│   ├── manage.py            Django yönetim komutu
│   └── requirements.txt     Python bağımlılıkları
├── mobile_app/
│   └── lib/
│       ├── main.dart              Uygulama giriş noktası
│       ├── models/person.dart     Veri sınıfı (JSON ↔ Dart nesnesi)
│       ├── services/api_service.dart  Tüm HTTP istekleri
│       ├── screens/
│       │   ├── person_list_screen.dart    Kişi listesi (ana sayfa)
│       │   ├── person_detail_screen.dart  Kişi detay
│       │   └── person_form_screen.dart    Ekle / düzenle formu
│       └── widgets/person_avatar.dart     Dairesel profil fotoğrafı
├── README.md
```
