// UYGULAMANIN GİRİŞ NOKTASI. Flutter çalışınca ilk burayı okur.

import 'package:flutter/material.dart';
import 'screens/person_list_screen.dart';

// main(): program buradan başlar. runApp(): verilen widget'ı ekrana koyar.
void main() {
  runApp(const MyApp());
}

// StatelessWidget = içeriği zamanla DEĞİŞMEYEN widget (burada sadece uygulama kabuğu).
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // MaterialApp: Google'ın Material tasarım dilini (AppBar, buton, tema) getirir.
    return MaterialApp(
      title: 'Kişi Yönetim Sistemi',
      debugShowCheckedModeBanner: false, // sağ üstteki "DEBUG" bandını gizle
      theme: ThemeData(
        colorSchemeSeed: Colors.indigo, // tüm renkleri tek renkten türet
        useMaterial3: true,
      ),
      home: const PersonListScreen(), // açılış ekranı = Kişi Listesi
    );
  }
}
