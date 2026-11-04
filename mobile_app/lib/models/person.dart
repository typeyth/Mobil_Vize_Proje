// MODEL SINIFI: Sunucudan gelen JSON metnini Dart'ın anlayacağı bir NESNEYE çevirir.
//
// Neden sınıf yazdık, neden doğrudan Map (json['fullName']) kullanmadık?
//  - Map ile yazı hatası yaparsan ("fulName") uygulama çalışırken patlar.
//    Sınıfta yanlış yazarsan editör daha yazarken kırmızı çizer.
//  - person.fullName, json['fullName']'dan hem kısa hem güvenli.
// Neden json_serializable gibi otomatik üretici paket kullanmadık?
//  - Ekstra paket + "kod üretme" komutu gerekir; fromJson'u elle yazmak 10 satır.
//    Sunumda "bu satır ne yapıyor?" sorusuna cevap verebilmek için elle yazdık.

class Person {
  // "final" = nesne oluşturulduktan sonra değiştirilemez (daha güvenli).
  // id yeni kayıtta henüz yoktur (sunucu verir), bu yüzden "int?" = boş olabilir.
  final int? id;
  final String fullName;
  final String department;
  final String photoUrl;
  final String birthPlace;
  final String birthDate; // sunucudan "1994-04-12" biçiminde gelir
  final String email;
  final String phone;

  Person({
    this.id,
    required this.fullName,
    required this.department,
    required this.photoUrl,
    required this.birthPlace,
    required this.birthDate,
    required this.email,
    required this.phone,
  });

  // factory + fromJson: "JSON'dan (Map'ten) Person üret" kuralı.
  // Anahtar isimleri backend'deki model alan adlarıyla BİREBİR aynı olmalı.
  factory Person.fromJson(Map<String, dynamic> json) {
    return Person(
      id: json['id'] as int,
      fullName: json['fullName'] as String,
      department: json['department'] as String,
      photoUrl: json['photoUrl'] as String, // boşsa "" gelir, null gelmez
      birthPlace: json['birthPlace'] as String,
      birthDate: json['birthDate'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
    );
  }

  // toJson: Tersi. Person'ı sunucuya göndermek için Map'e çevirir.
  // "id"yi göndermiyoruz: yeni kayıtta sunucu verir, güncellemede adreste zaten var.
  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'department': department,
      'photoUrl': photoUrl,
      'birthPlace': birthPlace,
      'birthDate': birthDate,
      'email': email,
      'phone': phone,
    };
  }

  // Ekranda "12.04.1994" göstermek için. intl paketi eklemek yerine
  // metni "-" işaretinden parçalayıp ters çevirdik (1 satırlık iş için paket gereksiz).
  String get birthDateTr {
    final parts = birthDate.split('-'); // ["1994", "04", "12"]
    if (parts.length != 3) return birthDate;
    return '${parts[2]}.${parts[1]}.${parts[0]}'; // gün.ay.yıl
  }
}
