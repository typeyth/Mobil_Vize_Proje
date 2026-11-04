# SAVUNMA REHBERİ – Her Satırı Anlatabilmek İçin

Bu rehber sana şunu sağlar: hoca hangi satırı gösterip "bu ne?" derse, cevabını burada bulursun.

Her bölüm aynı kalıpta:
> **Ne yaptım** → **Neden yaptım** → **Alternatif neydi, neden seçmedim** → **Hoca sorarsa kısa cevap**

---

## 1. Büyük Resim: Bu Proje Ne Yapıyor?

Bir **telefon rehberi** uygulaması: kişi ekle, listele, detayını gör, düzenle, sil.

İki parçadan oluşur:

| Parça | Ne yapar | Teknoloji |
|---|---|---|
| **Backend (Sunucu)** | Veritabanını tutar, isteklere cevap verir | Django + SQLite |
| **Mobil Uygulama** | Kullanıcıya ekranları gösterir, sunucuyla konuşur | Flutter (Dart) |

**Restoran benzetmesi:**

| Restoran | Bizim proje |
|---|---|
| Müşteri (menüye bakar, sipariş verir) | Mobil uygulama (ekranlar) |
| Garson (siparişi mutfağa taşır, yemeği getirir) | HTTP istekleri (REST API) |
| Mutfak + depo (yemeği yapar, malzemeyi saklar) | Django + SQLite (veri işleme + saklama) |
| Sipariş fişi (herkesin anladığı ortak biçim) | JSON (verinin yazıldığı format) |

**Hoca sorarsa:** "Mobil uygulama doğrudan veritabanına bağlanmıyor. Arada bir API (sunucu) var. Neden? Çünkü veritabanı şifresini telefona gömsek herkes APK'yı açıp görebilir. Ayrıca kurallar (e-posta geçerli mi?) tek yerde, sunucuda durur."

> ⚠️ Django bir **veritabanı değil**, bir **web çerçevesidir (framework)**. Veritabanı **SQLite**'tır. Django SQLite ile konuşur. Sunumda bu ayrımı doğru söylemek önemli.

---

## 2. Teknoloji Seçimleri

| Ne | Seçtiğimiz | Alternatif | Neden alternatifi seçmedik |
|---|---|---|---|
| Backend | Django REST Framework | FastAPI, ASP.NET | Django'da admin paneli, doğrulama, migration hazır gelir. Ödev için yeterli. |
| Veritabanı | SQLite | PostgreSQL, MySQL, Firebase | SQLite tek dosya, kurulum gerektirmez. Firebase "bağımsız backend" şartına uymaz. |
| Veri formatı | JSON | XML | Ödev şartı. Dart'ta `jsonDecode` yerleşik, XML'den kısa. |
| Mobil | Flutter (Dart) | React Native, Kotlin | Ödev Flutter terimleriyle yazılmış. Tek kodla Android+iOS. |
| HTTP paketi | `http` | `dio` | `http` Flutter'ın resmi cookbook paketi, çok basit. `dio` bizim kullanmadığımız özellikleri getiriyor. |
| Durum yönetimi | `setState` + `FutureBuilder` | Provider, Bloc, Riverpod | 3 ekranlık uygulama için ek paket gereksiz. En basit ve en anlatılabilir yöntem. |
| Navigasyon | `Navigator.push` | go_router | 3 ekran için yönlendirme paketi fazlalık. |
| Telefon/e-posta açma | `url_launcher` | `android_intent` | `url_launcher` hem Android hem iOS'ta çalışır. Ödev de adını anıyor. |

---

## 3. Proje Klasör Yapısı

```
Mobil_Vize_Proje/
├── backend_api/                  Django projesi
│   ├── config/
│   │   ├── settings.py           Ayarlar (veritabanı, kurulu uygulamalar)
│   │   ├── urls.py               Ana adres yönlendirmesi
│   │   ├── wsgi.py               Sunucu giriş noktası
│   │   └── __init__.py
│   ├── persons/
│   │   ├── models.py             Veritabanı tablo tarifi (Person sınıfı)
│   │   ├── serializers.py        JSON ↔ Python nesnesi çevirici
│   │   ├── views.py              İstekleri karşılayan sınıflar
│   │   ├── urls.py               /api/persons adres tanımları
│   │   ├── admin.py              Admin paneli kaydı
│   │   └── fixtures/ornek_kisiler.json  5 örnek kişi
│   ├── db.sqlite3                Veritabanı dosyası
│   ├── manage.py                 Django komut çalıştırıcı
│   └── requirements.txt          Bağımlılıklar listesi
├── mobile_app/                   Flutter projesi
│   └── lib/
│       ├── main.dart             Uygulama giriş noktası
│       ├── models/person.dart    Veri sınıfı
│       ├── services/api_service.dart  Tüm ağ kodları
│       ├── screens/
│       │   ├── person_list_screen.dart   Liste ekranı
│       │   ├── person_detail_screen.dart Detay ekranı
│       │   └── person_form_screen.dart   Ekle/Düzenle formu
│       └── widgets/person_avatar.dart    Dairesel fotoğraf
└── README.md
```

**Neden her dosya ayrı?** Her dosyanın tek bir işi var. Hata çıkınca nereye bakacağını bilirsin. Her şeyi `main.dart`'a yazmak: 800 satırlık, kimsenin okuyamadığı dosya demek.

---

# BACKEND — ADIM ADIM

## Adım 1: settings.py — Django'nun Kontrol Paneli

**Dosya:** `backend_api/config/settings.py`

Bu dosya Django'ya "neyi biliyorsun, neyi kullanıyorsun" diyor. 3 değişiklik yaptık:

### Değişiklik 1: INSTALLED_APPS
```python
INSTALLED_APPS = [
    ...
    'rest_framework',   # REST API kütüphanesi — JSON gönder/al yeteneği
    'persons',          # bizim yazdığımız kişi uygulaması
]
```
**Neden?** Django sadece bu listede yazanları tanır. `rest_framework` yazmazsak DRF'nin hiçbir özelliğini kullanamayız. `persons` yazmazsak Django modelimizi görmez, tabloyu oluşturmaz.

### Değişiklik 2: ALLOWED_HOSTS
```python
ALLOWED_HOSTS = ['*']
```
**Neden?** Emülatör sunucuya `10.0.2.2` adresiyle gelir, gerçek telefon `192.168.x.x` ile gelir. Liste boşsa Django bu istekleri `400 Bad Request` ile reddeder. `'*'` = herkesten kabul et.

**Hoca sorarsa:** "Üretimde `'*'` yazmayız, gerçek alan adını yazarız. Geliştirme ortamı için uygundur."

### Değişiklik 3: Veritabanı
```python
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.sqlite3',
        'NAME': BASE_DIR / 'db.sqlite3',
    }
}
```
**Ne yapıyor?** Veritabanı olarak SQLite kullan ve dosyayı `db.sqlite3` adıyla proje klasörüne koy.

**Hoca sorarsa:** "SQLite tek dosyadır, ayrı program kurmaya gerek yok. Gerçek projede PostgreSQL kullanılır ve sadece bu 3 satır değişir, başka hiçbir kod değişmez — çünkü Django ORM arada çeviri yapar."

---

## Adım 2: models.py — Veritabanı Tablosunun Tarifi

**Dosya:** `backend_api/persons/models.py`

```python
class Person(models.Model):
    fullName  = models.CharField(max_length=100)    # kısa metin, en fazla 100 karakter
    department = models.CharField(max_length=100)
    photoUrl  = models.URLField(max_length=500, blank=True)  # internet adresi, boş olabilir
    birthPlace = models.CharField(max_length=100)
    birthDate = models.DateField()                  # sadece tarih: 1994-04-12
    email     = models.EmailField()                 # @ yoksa Django kaydı reddeder
    phone     = models.CharField(max_length=20)     # metin (sayı değil!)
```

**Satır satır açıklama:**

| Alan | Tip | Neden bu tip |
|---|---|---|
| `fullName` | `CharField(max_length=100)` | Kısa metin. `max_length` zorunlu — veritabanına "en fazla 100 harf" der. |
| `photoUrl` | `URLField(blank=True)` | URL formatı doğrulanır. `blank=True` = boş bırakılabilir (fotoğrafı olmayan kişi). |
| `birthDate` | `DateField` | Sadece tarih tutar. API'ye `"1994-04-12"` biçiminde çıkar. |
| `email` | `EmailField` | İçinde `@` yoksa Django kaydı reddeder — hazır doğrulama. |
| `phone` | `CharField` (sayı DEĞİL) | `+90555...` ve baştaki `0` sayıda kaybolur. Telefonla toplama-çıkarma yapılmaz. |

**`id` nerede?** Yazmadık — Django otomatik ekler (1, 2, 3...). Her tablonun birincil anahtarı (primary key).

**Alan adları neden `fullName` (camelCase)?** Ödevdeki JSON şemasıyla birebir aynı olsun diye. Veritabanı sütunu = JSON anahtarı = Dart değişkeni. Tek isim, çeviri katmanı yok, yazım hatası riski yok.

**Hoca sorarsa:** "Python geleneği `full_name` (snake_case) yazmaktır. O da olurdu ama serializer'da `source='full_name'` ile çeviri yapmak gerekirdi. Basit tutmak için camelCase tercih ettim."

---

## Adım 3: Migration — Tabloyu Oluşturma

```bash
python manage.py makemigrations persons   # plan dosyası üret (0001_initial.py)
python manage.py migrate                  # planı veritabanına uygula
```

**makemigrations ne yapar?** Modele bakıp "şu sütunları olan şu tabloyu oluşturacağım" planını dosyaya yazar.

**migrate ne yapar?** O plan dosyasını okuyup SQL çalıştırır ve tabloyu gerçekten oluşturur.

**Neden iki ayrı komut?** Plan dosyası Git'e girer. Takım arkadaşın da aynı `migrate` komutuyla aynı tabloyu oluşturabilir. Model değiştirince (alan ekleyince) iki komut yeniden çalışır, eski veriler silinmez.

**Hoca sorarsa:** "Alternatif: tabloyu elle `CREATE TABLE` SQL ile yazmak. Her değişiklikte elle `ALTER TABLE` gerekir. Migration bunu otomatik yapar."

---

## Adım 4: serializers.py — Çevirmen

**Dosya:** `backend_api/persons/serializers.py`

```python
class PersonSerializer(serializers.ModelSerializer):
    class Meta:
        model = Person
        fields = '__all__'
```

**Ne yapar?** İki yönlü çevirmen:
- **GET isteğinde:** Veritabanındaki Python nesnesi → JSON metni
- **POST/PUT isteğinde:** Gelen JSON metni → doğrulanmış Python nesnesi

**`ModelSerializer` ne?** Modeli okuyup alanları kendisi çıkarır. `fields = '__all__'` = modeldeki bütün alanlar (id dahil) JSON'a girsin.

**Doğrulama da yapar mı?** Evet! E-posta geçerli mi? Zorunlu alan boş mu? Tarih formatı doğru mu? Hepsini kontrol eder. Geçersizse `400 Bad Request` döner.

**Hoca sorarsa:** "Düz `Serializer` da kullanabilirdim ama her alanı tekrar yazmam gerekirdi. `ModelSerializer` modelden otomatik çıkarıyor — kopya kod yok."

---

## Adım 5: views.py — İstekleri Karşılayan Sınıflar

**Dosya:** `backend_api/persons/views.py`

```python
class PersonListCreateView(generics.ListCreateAPIView):
    queryset = Person.objects.all()
    serializer_class = PersonSerializer

class PersonDetailView(generics.RetrieveUpdateDestroyAPIView):
    queryset = Person.objects.all()
    serializer_class = PersonSerializer
```

**Bu 2 sınıf ödevin 5 endpoint'ini karşılar:**

| Sınıf | Endpoint | HTTP Metot | İş |
|---|---|---|---|
| `PersonListCreateView` | `/api/persons` | GET | Tüm kişileri listele |
| | `/api/persons` | POST | Yeni kişi ekle |
| `PersonDetailView` | `/api/persons/{id}` | GET | Tek kişi detayı |
| | `/api/persons/{id}` | PUT | Kişiyi güncelle |
| | `/api/persons/{id}` | DELETE | Kişiyi sil |

**`queryset = Person.objects.all()` ne demek?**
- `Person.objects` = Person tablosuna erişim kapısı (Django ORM'in Manager'ı)
- `.all()` = tablodaki tüm kayıtlar
- `queryset` = "bu view hangi verilere bakacak?"

**`serializer_class` ne demek?** "Veriyi JSON'a çevirirken hangi çevirmen kullanılsın?"

**Hoca sorarsa:** "Neden `ModelViewSet` + `Router` kullanmadın?"
→ "3 satırla hepsi olurdu ama sihirli: DELETE'in hangi satırda çalıştığını gösteremem. Generic view'da adresler `urls.py`'de açıkça yazılı, gösterebilirim."

**Hoca sorarsa:** "Neden elle fonksiyon (`@api_view`) yazmadın?"
→ "O zaman her `if request.method == 'GET': ...` dalını kendim yazardım, 100+ satır olurdu. Generic view aynı işi 4 satırda yapıyor."

---

## Adım 6: urls.py — Adres Tanımları

**Dosya 1: `backend_api/config/urls.py` (ana)**
```python
urlpatterns = [
    path('admin/', admin.site.urls),
    path('api/', include('persons.urls')),  # api/ ile başlayanı persons'a devret
]
```

**Dosya 2: `backend_api/persons/urls.py`**
```python
urlpatterns = [
    path('persons', PersonListCreateView.as_view()),
    path('persons/<int:pk>', PersonDetailView.as_view()),
]
```

**Nasıl çalışır?** İstek gelince Django şöyle okur:
1. `GET /api/persons/1` → ana urls.py: `api/` eşleşti, kalanı (`persons/1`) persons'a devret
2. persons urls.py: `persons/<int:pk>` eşleşti, `pk=1` olarak view'a git
3. View veritabanından `id=1` kaydını bul ve döndür

**`<int:pk>` ne?** "Adresin bu kısmı bir tam sayıdır ve `pk` (primary key = id) adıyla view'a gönderilir."

**Sonunda `/` neden yok?** Ödev tablosundaki adreslerle birebir aynı olsun. Sonunda `/` olsaydı ve mobilden `/` olmadan istek atsaydık, Django POST isteğini yönlendirmeye çalışır ve veri kaybolurdu.

---

# MOBİL — ADIM ADIM

## Adım 7: Kullandığımız Paketler

`pubspec.yaml`'deki iki ek paket:
- **`http`** — HTTP istekleri (GET, POST, PUT, DELETE) için. Flutter cookbook'un resmi paketi.
- **`url_launcher`** — Telefon arama ve e-posta uygulamasını açmak için. Ödevde istenen özellik.

**Neden sadece 2 paket?** Gereksiz paket = savunulması gereken fazladan kod. Bu iki paket dışında her şeyi Flutter'ın kendi araçlarıyla yaptık.

---

## Adım 8: person.dart — Veri Sınıfı (Model)

**Dosya:** `mobile_app/lib/models/person.dart`

```dart
class Person {
  final int? id;          // ? = boş olabilir (yeni kayıtta sunucu verir)
  final String fullName;
  final String department;
  final String photoUrl;
  final String birthPlace;
  final String birthDate;  // "1994-04-12" biçiminde
  final String email;
  final String phone;
```

**`final` ne?** Nesne oluşturulduktan sonra bu değer değiştirilemez. Yanlışlıkla değiştirme hatasını önler.

**`int?` neden soru işaretli?** `?` = bu değer `null` (boş) olabilir. Yeni kişi eklerken id'yi biz vermiyoruz, sunucu veriyor. O yüzden başta id yok.

### fromJson — JSON'dan nesne üret
```dart
factory Person.fromJson(Map<String, dynamic> json) {
  return Person(
    id: json['id'] as int,
    fullName: json['fullName'] as String,
    ...
  );
}
```

**Ne yapıyor?** Sunucudan gelen JSON (aslında Dart'ta `Map`) → `Person` nesnesi. `json['fullName']` diyerek Map'ten değeri alıp ilgili alana atıyor.

**Neden sınıf yazdık, doğrudan `json['fullName']` kullanmadık?** Map'te `'fulName'` diye yazım hatası yaparsan uygulama **çalışırken** patlar. Sınıfta `person.fulName` yazarsan editör **yazarken** kırmızıyla uyarır.

### toJson — Nesneyi JSON'a çevir
```dart
Map<String, dynamic> toJson() {
  return {
    'fullName': fullName,
    'department': department,
    ...
  };
}
```

**Ne yapıyor?** POST ve PUT'ta sunucuya göndermek için Person → Map çevrimi. `id`'yi göndermiyoruz: yeni kayıtta sunucu verir, güncellemede id zaten URL'de var.

### birthDateTr — Tarih formatı çevirme
```dart
String get birthDateTr {
  final parts = birthDate.split('-');  // ["1994", "04", "12"]
  return '${parts[2]}.${parts[1]}.${parts[0]}';  // "12.04.1994"
}
```
**Ne yapıyor?** Sunucudan gelen `1994-04-12`'yi ekranda `12.04.1994` olarak gösterir. `intl` paketi yerine 1 satırlık çözüm — paket eklemek gereksiz.

---

## Adım 9: api_service.dart — Sunucuyla Konuşan Kod

**Dosya:** `mobile_app/lib/services/api_service.dart`

Bu dosya tüm ağ kodlarını içerir. Ekranlarda tek satır ağ kodu yok — ekran sadece "kişileri getir" der, nasıl getirildiğini bilmez.

### baseUrl
```dart
static const String baseUrl = 'http://10.0.2.2:8000/api/persons';
```

**`10.0.2.2` ne?** Android emülatöründe `localhost` = emülatörün kendisi, bilgisayar değil! `10.0.2.2` = emülatörün bilgisayara açılan özel kapısı.

| Ortam | Adres |
|---|---|
| Android emülatör | `10.0.2.2` |
| Gerçek telefon (aynı Wi-Fi) | Bilgisayarın IP'si (192.168.x.x) |
| iOS simülatör | `127.0.0.1` |

### Asenkron Kavramı (EN ÖNEMLİ KONU)

**Asenkron ne demek?** Sunucudan cevap gelmesi 100ms – 10 saniye sürebilir. Bu sürede ekran **donarsa** uygulama bozuk görünür. Asenkron = beklerken ekranı dondurma.

Üç anahtar kelime:

| Kelime | Ne yapar | Gerçek hayat benzetmesi |
|---|---|---|
| `Future` | "Cevap şimdi yok, birazdan gelecek" sözü | Restoranda sipariş fişi — yemek henüz hazır değil ama söz verildi |
| `async` | Bu fonksiyon beklemeli iş yapıyor | Garsona "bekle, mutfağa soracağım" demek |
| `await` | Cevap gelene kadar **bu satırı** beklet, ama ekranı dondurma | Garsonu beklerken telefonuna bakabilirsin, ama sipariş teslimi duruyor |

### getPersons — Listeyi getir
```dart
static Future<List<Person>> getPersons() async {
  final response = await http.get(Uri.parse(baseUrl)).timeout(_timeout);
  if (response.statusCode != 200) {
    throw Exception('Liste alınamadı (HTTP ${response.statusCode})');
  }
  final List<dynamic> data = _decode(response);
  return data.map((item) => Person.fromJson(item)).toList();
}
```

**Satır satır:**
1. `Future<List<Person>>` — bu fonksiyon gelecekte bir `List<Person>` döndürecek
2. `async` — içinde `await` kullanacağız
3. `await http.get(...)` — GET isteği at ve cevabı bekle (ekranı dondurma)
4. `.timeout(_timeout)` — 10 saniye cevap gelmezse hata ver
5. `statusCode != 200` — başarılı değilse hata fırlat
6. `_decode(response)` — JSON metnini Dart Map'ine çevir
7. `data.map((item) => Person.fromJson(item))` — her Map'i Person nesnesine çevir
8. `.toList()` — sonucu listeye dönüştür

### _decode — Türkçe karakter sorunu
```dart
static dynamic _decode(http.Response response) {
  return jsonDecode(utf8.decode(response.bodyBytes));
}
```

**Neden `response.body` değil?** Django `Content-Type: application/json` gönderir ama `charset=utf-8` demez. `http` paketi bu durumda metni Latin-1 sanır. Sonuç: "Ayşe" → "AyÅŸe". Ham baytları (`bodyBytes`) kendimiz UTF-8 olarak çözersek Türkçe bozulmaz.

**Hoca sorarsa:** "Bu satırı `response.body` yapsam ne olur?" → "Türkçe karakterler bozulur. Ayşe yerine AyÅŸe yazar."

### createPerson — Yeni kişi ekle
```dart
static Future<Person> createPerson(Person person) async {
  final response = await http.post(
    Uri.parse(baseUrl),
    headers: _headers,       // Content-Type: application/json
    body: jsonEncode(person.toJson()),  // Person → Map → JSON metni
  ).timeout(_timeout);
  if (response.statusCode != 201) { ... }  // 201 = Created
  return Person.fromJson(_decode(response));
}
```

**201 ne?** "Oluşturuldu" (Created). POST'ta başarı kodu 200 değil 201'dir. Sunucu yeni kaydı JSON olarak geri döner (id dahil).

### HTTP Durum Kodları

| Kod | Anlam | Hangi işlemde |
|---|---|---|
| 200 | Başarılı | GET, PUT |
| 201 | Oluşturuldu | POST |
| 204 | Başarılı, içerik yok | DELETE |
| 400 | Hatalı istek (geçersiz veri) | POST/PUT'ta doğrulama hatası |
| 404 | Bulunamadı | Olmayan ID ile istek |

### Neden `static`?
`ApiService.getPersons()` diye nesne üretmeden çağırabilmek için. Durum tutmayan fonksiyon grubu — her çağrı bağımsız.

---

## Adım 10: person_list_screen.dart — Kişi Listesi (Ana Sayfa)

**Dosya:** `mobile_app/lib/screens/person_list_screen.dart`

### StatefulWidget neden?
```dart
class PersonListScreen extends StatefulWidget { ... }
```
Ekranın içeriği zamanla değişiyor: önce boş, sonra liste dolu, silince değişiyor. **StatelessWidget** = hiç değişmeyen widget (örn: uygulama kabuğu `MyApp`). **StatefulWidget** = değişen veri tutan widget.

### initState — Neden burada istek atıyoruz?
```dart
@override
void initState() {
  super.initState();
  _personsFuture = ApiService.getPersons();
}
```

**Neden `build()` içinde değil?** `build()` ekran her yenilendiğinde tekrar çalışır. Her seferinde yeni ağ isteği giderdi — gereksiz ve yavaş. `initState` ekran açılırken **bir kez** çalışır.

**Future'ı neden değişkende tutuyoruz?** `FutureBuilder`'a `future: ApiService.getPersons()` doğrudan yazsaydık, her `build()` çağrısında yeni istek giderdi.

### FutureBuilder — 3 durumu tek yerde yönet
```dart
FutureBuilder<List<Person>>(
  future: _personsFuture,
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return CircularProgressIndicator();  // 1) Bekleniyor
    }
    if (snapshot.hasError) {
      return Text('Hata: ${snapshot.error}');  // 2) Hata
    }
    final persons = snapshot.data!;  // 3) Veri geldi
    ...
  },
)
```

**Ne yapıyor?** Future'ı izler, durumuna göre ekranı çizer:
1. **Bekleniyor** → dönen yükleniyor simgesi
2. **Hata** → hata mesajı + "Tekrar Dene" butonu
3. **Veri geldi** → listeyi göster

**Hoca sorarsa:** "Alternatif neydi?" → "Bool `loading` değişkeni + `setState` ile elle yönetmek. Daha uzun ve hata riskli. Ya da Provider/Bloc paketi kullanmak — 3 ekran için fazlalık."

### ListView.builder — Neden normal ListView değil?
```dart
ListView.builder(
  itemCount: persons.length,
  itemBuilder: (context, index) { ... },
)
```
**`ListView.builder`** sadece ekranda görünen satırları üretir, kaydırdıkça yenisini yapar. **Normal `ListView(children: [...])`** 1000 kişiyi birden çizer → yavaş.

### Satıra tıklayınca detay açma
```dart
onTap: () => _openDetail(person.id!),
```

**`person.id!` sonundaki `!` ne?** "Bu değerin null (boş) olmadığına eminim" garantisi. Sunucudan gelen kişinin kesinlikle id'si var.

### _reload — Neden Navigator.push'tan sonra yeniliyoruz?
```dart
Future<void> _openDetail(int id) async {
  await Navigator.push(context, ...);  // detay sayfasını aç, kapanmasını bekle
  _reload();                           // geri dönünce listeyi yenile
}
```

`await Navigator.push` = detay sayfası kapanana kadar bekle. Kapandığında silme/düzenleme olmuş olabilir → listeyi yeniden çek.

### mounted kontrolü ne?
```dart
if (!mounted) return;
```
`await`'ten sonra kullanıcı ekranı kapatmış olabilir. Kapalı ekranda `setState` çağırmak hata verir. `mounted` = "bu widget hâlâ ekranda mı?"

---

## Adım 11: person_detail_screen.dart — Detay Sayfası

**Dosya:** `mobile_app/lib/screens/person_detail_screen.dart`

### Neden sadece ID alıyor, tüm kişiyi değil?
```dart
final int personId;  // listeden sadece ID gelir
```
Ödev "benzersiz ID'si ile" diyor. Ayrıca sunucudaki **en güncel** veriyi görmek istiyoruz — başkası değiştirmiş olabilir.

### E-posta / telefon tıklama
```dart
_infoCard(
  Icons.email, 'E-posta', person.email,
  onTap: () => _launch(Uri(scheme: 'mailto', path: person.email)),
),
_infoCard(
  Icons.phone, 'Telefon', person.phone,
  onTap: () => _launch(Uri(scheme: 'tel', path: person.phone)),
),
```

**`Uri(scheme: 'tel', path: '+905550123456')` ne üretir?** → `tel:+905550123456`. Telefon bunu görünce arama ekranını açar. `mailto:` ise e-posta uygulamasını açar.

**`launchUrl` ne?** `url_launcher` paketinin fonksiyonu. Android'de "intent" göndermek gibi — işletim sistemine "bu adresi aç" der.

### Silme akışı
```dart
final confirmed = await showDialog<bool>(
  context: context,
  builder: (dialogContext) => AlertDialog(
    title: Text('Silme Onayı'),
    content: Text('${person.fullName} kalıcı olarak silinecek. Emin misiniz?'),
    actions: [
      TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: Text('Vazgeç')),
      TextButton(onPressed: () => Navigator.pop(dialogContext, true), child: Text('Sil')),
    ],
  ),
);
if (confirmed != true) return;          // vazgeçti veya dışına dokundu
await ApiService.deletePerson(person.id!);  // DELETE isteği
Navigator.pop(context);                 // listeye geri dön
```

**Adım adım:** Onay penceresi → "Sil" basılırsa `true` döner → DELETE isteği → listeye dön. `confirmed != true` = hem "Vazgeç" (false) hem pencerenin dışına dokununca (null) silmeyi engeller.

---

## Adım 12: person_form_screen.dart — Ekle / Düzenle

**Dosya:** `mobile_app/lib/screens/person_form_screen.dart`

### Neden tek form, iki ekran değil?
```dart
final Person? person;  // null = yeni kayıt, dolu = düzenleme
bool get _isEdit => widget.person != null;
```
İki ekran aynı alanlara sahip olurdu — kodun yarısı kopya. `person` dolu mu boş mu diye bakarak ayırırız.

### TextEditingController ne?
```dart
late final TextEditingController _nameCtrl;
```
Metin kutusundaki yazıyı okumamızı ve düzenlemede kutuyu önceden doldurmamızı sağlayan kumanda. Her kutu için bir controller.

### dispose neden var?
```dart
@override
void dispose() {
  _nameCtrl.dispose();
  ...
  super.dispose();
}
```
Ekran kapanırken controller'ları serbest bırak. Yoksa **bellek sızıntısı** olur — uygulama yavaşlar.

### Tarih seçme
```dart
final picked = await showDatePicker(
  context: context,
  initialDate: DateTime.tryParse(_dateCtrl.text) ?? DateTime(2000, 1, 1),
  firstDate: DateTime(1900),
  lastDate: DateTime.now(),
);
if (picked != null) {
  _dateCtrl.text = picked.toIso8601String().substring(0, 10);  // "2000-01-05"
}
```
**Neden elle yazdırmıyoruz?** Kullanıcı "12/04/94" gibi yanlış format girebilir. Takvim her zaman geçerli tarih verir ve `toIso8601String().substring(0,10)` ile API'nin istediği `YYYY-AA-GG` biçimine çevrilir.

### Kaydetme
```dart
if (_isEdit) {
  await ApiService.updatePerson(widget.person!.id!, person);  // PUT
} else {
  await ApiService.createPerson(person);  // POST
}
Navigator.pop(context);  // başarılıysa geri dön
```

### _saving bayrağı ne işe yarar?
```dart
bool _saving = false;
onPressed: _saving ? null : _save,
```
Kaydederken butonu pasif yapar. Çift tıklama ile aynı kişinin iki kez eklenmesini önler. `onPressed: null` = buton pasif.

### Form doğrulama
```dart
final _formKey = GlobalKey<FormState>();
if (!_formKey.currentState!.validate()) return;
```
Tüm validator'ları çalıştırır. Biri hata verirse (boş alan, geçersiz e-posta) kaydetmez ve hata mesajını kutuların altında gösterir.

---

## Adım 13: AndroidManifest.xml — Platform İzinleri

**Dosya:** `mobile_app/android/app/src/main/AndroidManifest.xml`

Bunlar kod değil, **izin** işleri. Yoksa kod doğru olsa da çalışmaz:

```xml
<!-- 1. İnternet izni — yoksa APK'da ağa bağlanamaz -->
<uses-permission android:name="android.permission.INTERNET"/>

<!-- 2. HTTP izni — Android 9+ https olmayan adreslere izin vermez -->
android:usesCleartextTraffic="true"

<!-- 3. tel: ve mailto: intent'leri — Android 11+ paket görünürlüğü kuralı -->
<queries>
  <intent><action .../><data android:scheme="tel"/></intent>
  <intent><action .../><data android:scheme="mailto"/></intent>
</queries>
```

**Hoca sorarsa:** "Debug'da neden çalışıyordu?" → "Flutter debug mode'da INTERNET iznini otomatik ekler ama **release APK'da eklemez**. `usesCleartextTraffic` ise Android 9+ güvenlik kuralı — üretimde HTTPS kullanılır, bu satır kaldırılır."

---

## Adım 14: person_avatar.dart — Tekrar Kullanılan Parça

**Dosya:** `mobile_app/lib/widgets/person_avatar.dart`

```dart
CircleAvatar(
  radius: radius,
  backgroundImage: hasPhoto ? NetworkImage(photoUrl) : null,
  child: hasPhoto ? null : Text(name[0]),  // fotoğraf yoksa baş harf
)
```

**Neden ayrı widget?** Liste ekranı da detay ekranı da kullanıyor. Ayrı yazmayıp iki yere kopyalasaydık, değişiklikte iki yeri düzeltmek gerekecekti.

**`NetworkImage` ne?** İnternetten resim indiren sınıf. URL'yi verirsin, resmi indirir ve gösterir.

---

# HOCA SORULARI — KISA CEVAPLAR

### Genel Sorular

**S: REST nedir?**
Kaynakları (kişileri) adreslerle (`/api/persons/1`) ve HTTP metotlarıyla (GET oku, POST ekle, PUT güncelle, DELETE sil) yöneten bir iletişim tarzı. Her istek kendi başına yeterli, sunucu önceki isteği hatırlamak zorunda değil (durum tutmaz).

**S: GET ile POST farkı?**
GET veri **okur**, gövdesi yoktur. POST sunucuya **yeni veri gönderir** (JSON gövdede).

**S: PUT ile PATCH farkı?**
PUT kaydın **tamamını** gönderir ve değiştirir. PATCH sadece **değişen alanları** gönderir. Biz PUT kullandık çünkü ödev öyle istiyor ve formdan zaten tüm alanları gönderiyoruz.

**S: JSON nedir?**
Anahtar-değer formatında, insanın da makinenin de okuyabildiği hafif metin formatı. `{"ad": "Ahmet", "yaş": 30}`. XML'den kısa, Dart'ta `jsonDecode` yerleşik.

**S: API nedir?**
Application Programming Interface. İki yazılımın birbiriyle konuşmasının kurallarını belirleyen arayüz. Bizim API: "şu adrese şu formatta istek at, sana şu formatta cevap döneyim."

**S: ORM nedir?**
Object-Relational Mapper. SQL yazmadan Python sınıflarıyla veritabanını yönetmemizi sağlar. `Person.objects.all()` = `SELECT * FROM persons_person`.

### Flutter Soruları

**S: Asenkron ne demek?**
İşin bitmesini beklerken uygulamanın donmaması. `Future` = gelecekteki sonuç sözü, `await` = o sonucu bekle ama ekranı dondurma.

**S: `setState` ne yapar?**
Flutter'a "veri değişti, bu ekranı yeniden çiz" der. `setState` olmadan değişkeni değiştirsen değer değişir ama ekran güncellenmez.

**S: `StatelessWidget` / `StatefulWidget` farkı?**
Stateless = içeriği hiç değişmez (örn: uygulama kabuğu). Stateful = değişen veri tutar, `setState` ile yenilenir (örn: liste ekranı).

**S: `FutureBuilder` ne?**
Bir `Future`'ı izleyen widget. Bekleniyor/hata/veri geldi durumlarını tek yerde yönetir.

**S: `Navigator.push` ne yapar?**
Yeni ekranı mevcut ekranın üstüne koyar (kart destesi gibi). `Navigator.pop` geri döner.

**S: `context` ne?**
Widget'ın ağaçtaki konumunu temsil eden nesne. "Ben neredeyim?" bilgisi. Tema rengini almak, ekran boyutunu öğrenmek, diyalog açmak için lazım.

### Backend Soruları

**S: Serializer ne?**
Model nesnesi ↔ JSON çevrimi ve gelen veriyi doğrulama yapan sınıf.

**S: Migration ne?**
Model değişikliklerinin veritabanına uygulanma planı. `makemigrations` planı dosyaya yazar, `migrate` uygular.

**S: `manage.py` ne?**
Django'nun komut çalıştırıcısı. `runserver`, `migrate`, `loaddata` gibi komutları çalıştırır.

**S: Kimlik doğrulama yok, herkes silebilir mi?**
Evet. Ödev kapsamı dışı. Gerçek projede token (JWT) + yetki kontrolü eklenir.

**S: `DEBUG=True` güvenli mi?**
Hayır. Hata olunca ayrıntılı bilgi gösterir. Üretimde `False` yapılır.

**S: `SECRET_KEY` neden kodda?**
Normalde çevre değişkeninde saklanır. Ödev için sorun değil.

### Türkçe Karakter Sorusu

**S: Türkçe karakterler neden `utf8.decode` ile?**
Django `charset` belirtmiyor → `http` paketi Latin-1 sanıyor → "Ayşe" = "AyÅŸe". Baytları kendimiz UTF-8 çözünce düzeliyor.

### Adres Sorusu

**S: `10.0.2.2` nedir?**
Android emülatörde bilgisayarın localhost'unu gösteren özel adres. Emülatörde `localhost` kendisidir, bilgisayar değil.

**S: Neden `http://` kullanıyoruz, güvenli mi?**
Geliştirme sunucusu HTTPS'siz. Üretimde HTTPS kullanılır ve `usesCleartextTraffic` kaldırılır.

---

# CANLI KOD MÜDAHALESİ HAZIRLIĞI

Hoca "şunu değiştir" diyecek. Bunları **bir kere kendin yap**, çalıştığını gör:

| Hoca ne derse | Hangi dosya | Ne yaparsın |
|---|---|---|
| "Kartta departman yerine telefon göster" | `person_list_screen.dart` | `subtitle: Text(person.department)` → `Text(person.phone)` |
| "Kartta hem departman hem e-posta göster" | `person_list_screen.dart` | `Text('${person.department}\n${person.email}')` + `isThreeLine: true` |
| "Silme butonunun rengini değiştir" | `person_detail_screen.dart` | `Colors.red` → `Colors.orange` (veya istenen renk) |
| "Üst başlık metnini değiştir" | ilgili ekranın `AppBar(title: ...)` | `Text('...')` içini değiştir |
| "Avatarı büyüt/küçült" | `PersonAvatar(radius: ...)` | Sayıyı değiştir (liste: 24, detay: 60) |
| "Doğum tarihini YYYY-AA-GG göster" | `person_detail_screen.dart` | `person.birthDateTr` → `person.birthDate` |
| "Zaman aşımını 5 saniye yap" | `api_service.dart` | `Duration(seconds: 10)` → `Duration(seconds: 5)` |
| "Adres değiştir (gerçek telefon)" | `api_service.dart` | `baseUrl`'deki `10.0.2.2`'yi bilgisayar IP'sine çevir |

**Önemli:** Dart kodunu değiştirdikten sonra terminalde **`r`** tuşuna bas (hot reload). Değişiklik anında yansır.

---

# DÜRÜST NOTLAR (Hoca "eksikleriniz?" derse)

Bunları **kendin söyle** — bilmediğin için değil, **bildiğin için** eksik bıraktığını gösterir:

1. **Kimlik doğrulama yok** — herkes ekleyip silebilir. Gerçek projede JWT token eklenir.
2. **HTTPS yok** — geliştirme ortamı, üretimde HTTPS zorunlu.
3. **`ALLOWED_HOSTS=['*']`** — üretimde gerçek alan adı yazılır.
4. **`DEBUG=True`** — üretimde `False` yapılır.
5. **Sayfalama yok** — binlerce kayıtta performans sorunu olur, DRF `PageNumberPagination` eklenir.
6. **Otomatik test yok** — elle test ettik.
7. **Çevrimdışı mod yok** — internet yoksa liste gelmez, yerel önbellek eklenebilir.
