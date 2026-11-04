// Dairesel profil fotoğrafı. Liste de detay sayfası da kullandığı için
// ayrı bir parçaya (widget) çıkardık: aynı kodu iki yerde yazmamak için.
// Tek fark boyut (radius): listede küçük, detayda büyük.

import 'package:flutter/material.dart';

class PersonAvatar extends StatelessWidget {
  final String photoUrl;
  final String name;
  final double radius;

  const PersonAvatar({
    super.key,
    required this.photoUrl,
    required this.name,
    this.radius = 24,
  });

  @override
  Widget build(BuildContext context) {
    final hasPhoto = photoUrl.isNotEmpty;
    return CircleAvatar( // CircleAvatar = daire biçimli hazır widget
      radius: radius,
      // NetworkImage = internetten resim indirir (ağ resmi, ödevde istenen bu).
      backgroundImage: hasPhoto ? NetworkImage(photoUrl) : null,
      // Resim indirilemezse (internet yok vb.) uygulama hata basmasın.
      onBackgroundImageError: hasPhoto ? (error, stack) {} : null,
      // Fotoğrafı olmayan kişide adının baş harfi görünsün.
      child: hasPhoto ? null : Text(name.isNotEmpty ? name[0] : '?'),
    );
  }
}
