// SERVİS KATMANI: Sunucuyla konuşan TÜM kod burada, ekranlarda tek satır ağ kodu yok.
// Neden ayrı dosya? Ekran kodu sadece "kişileri getir" der, nasıl getirildiğini bilmez.
// Adres değişirse sadece bu dosyaya dokunuruz.

import 'dart:convert'; // jsonEncode / jsonDecode / utf8
import 'package:flutter/foundation.dart' show kIsWeb; // Web (Chrome) mu kontrolü
import 'package:http/http.dart' as http; // HTTP istekleri için resmi paket
import '../models/person.dart';

// Neden "http" paketi, neden "dio" değil?
//  - http: Flutter'ın resmi dokümanındaki (cookbook) paket, çok sade, ödev için yeter.
//  - dio: interceptor, iptal, dosya yükleme gibi gelişmiş özellikler sunar;
//    bu ödevde bunların hiçbirine ihtiyaç yok, öğrenmesi ve savunması daha zor.
//  - dart:io HttpClient: yerleşik ama çok düşük seviyeli, her şeyi elle yapmak gerekir.

class ApiService {
  // ADRES:
  // - Chrome (Web) üzerinde çalışıyorsa: 'http://127.0.0.1:8000/api/persons'
  // - Android Emülatör üzerinde çalışıyorsa: 'http://10.0.2.2:8000/api/persons'
  static String get baseUrl => kIsWeb
      ? 'http://127.0.0.1:8000/api/persons'
      : 'http://10.0.2.2:8000/api/persons';

  // Sunucuya "gövdem JSON ve UTF-8" diyen başlık (POST ve PUT'ta lazım).
  static const Map<String, String> _headers = {
    'Content-Type': 'application/json; charset=UTF-8',
  };

  // Sunucu cevap vermezse sonsuza kadar beklemeyelim: 10 saniye sonra hata ver.
  static const Duration _timeout = Duration(seconds: 10);

  // Gelen cevabı JSON'a çeviren yardımcı fonksiyon.
  // NEDEN response.body DEĞİL de utf8.decode(response.bodyBytes)?
  //  Django "Content-Type: application/json" gönderir ama "charset=utf-8" demez.
  //  Bu durumda http paketi metni Latin-1 sanıp okur ve "Ayşe" -> "AyÅŸe" olur.
  //  Ham baytları (bodyBytes) biz UTF-8 olarak çözersek Türkçe karakterler bozulmaz.
  static dynamic _decode(http.Response response) {
    return jsonDecode(utf8.decode(response.bodyBytes));
  }

  // ---------------------------------------------------------------- GET /api/persons
  // "Future" = "sonuç şimdi hazır değil, biraz sonra gelecek" sözü.
  // "async" = bu fonksiyonun içinde "await" kullanılabilir.
  // "await" = cevap gelene kadar BU fonksiyonu beklet ama uygulamayı (arayüzü) DONDURMA.
  static Future<List<Person>> getPersons() async {
    final response = await http.get(Uri.parse(baseUrl)).timeout(_timeout);

    // 200 = OK. Başka bir kod geldiyse hata fırlat; ekran bunu yakalayıp gösterir.
    if (response.statusCode != 200) {
      throw Exception('Liste alınamadı (HTTP ${response.statusCode})');
    }

    // JSON dizisi -> List<dynamic>; her elemanı Person'a çevirip yeni liste yap.
    final List<dynamic> data = _decode(response);
    return data.map((item) => Person.fromJson(item)).toList();
  }

  // ---------------------------------------------------------------- GET /api/persons/{id}
  static Future<Person> getPerson(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/$id')).timeout(_timeout);
    if (response.statusCode != 200) {
      throw Exception('Kişi alınamadı (HTTP ${response.statusCode})');
    }
    return Person.fromJson(_decode(response));
  }

  // ---------------------------------------------------------------- POST /api/persons
  static Future<Person> createPerson(Person person) async {
    final response = await http
        .post(
          Uri.parse(baseUrl),
          headers: _headers,
          body: jsonEncode(person.toJson()), // Map -> JSON metni
        )
        .timeout(_timeout);

    // 201 = Created (oluşturuldu). Sunucu 400 verirse doğrulama hatası vardır.
    if (response.statusCode != 201) {
      throw Exception('Kayıt eklenemedi (HTTP ${response.statusCode}): ${utf8.decode(response.bodyBytes)}');
    }
    return Person.fromJson(_decode(response));
  }

  // ---------------------------------------------------------------- PUT /api/persons/{id}
  static Future<Person> updatePerson(int id, Person person) async {
    final response = await http
        .put(
          Uri.parse('$baseUrl/$id'),
          headers: _headers,
          body: jsonEncode(person.toJson()),
        )
        .timeout(_timeout);

    if (response.statusCode != 200) {
      throw Exception('Güncellenemedi (HTTP ${response.statusCode}): ${utf8.decode(response.bodyBytes)}');
    }
    return Person.fromJson(_decode(response));
  }

  // ---------------------------------------------------------------- DELETE /api/persons/{id}
  static Future<void> deletePerson(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/$id')).timeout(_timeout);

    // 204 = No Content: "silindi, geri vereceğim bir içerik yok".
    if (response.statusCode != 204) {
      throw Exception('Silinemedi (HTTP ${response.statusCode})');
    }
  }
}
