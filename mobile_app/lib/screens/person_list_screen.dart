// EKRAN 1: KİŞİ LİSTESİ (Ana Sayfa)  ->  GET /api/persons

import 'package:flutter/material.dart';
import '../models/person.dart';
import '../services/api_service.dart';
import '../widgets/person_avatar.dart';
import 'person_detail_screen.dart';
import 'person_form_screen.dart';

// StatefulWidget = içeriği ZAMANLA DEĞİŞEN ekran (veri yüklenince, silinince yenilenir).
// Neden Stateless değil? Liste önce boş, sonra dolu, silince tekrar değişiyor.
class PersonListScreen extends StatefulWidget {
  const PersonListScreen({super.key});

  @override
  State<PersonListScreen> createState() => _PersonListScreenState();
}

class _PersonListScreenState extends State<PersonListScreen> {
  // Sunucudan gelecek listeyi temsil eden "söz" (Future). Henüz veri yok, söz var.
  late Future<List<Person>> _personsFuture;

  // initState: ekran ilk açıldığında SADECE BİR KEZ çalışır -> isteği burada başlatırız.
  // NEDEN isteği build() içinde atmıyoruz? build() ekran her yenilendiğinde tekrar tekrar
  // çalışır; her seferinde yeni ağ isteği atılırdı (gereksiz ve yavaş).
  @override
  void initState() {
    super.initState();
    _personsFuture = ApiService.getPersons();
  }

  // Listeyi yeniden yükle: yeni bir Future ata + setState ile "ekranı yenile" de.
  void _reload() {
    if (!mounted) return; // ekran kapandıysa dokunma
    setState(() {
      _personsFuture = ApiService.getPersons();
    });
  }

  // Satıra tıklayınca: seçilen kişinin ID'si ile detay sayfasını aç.
  Future<void> _openDetail(int id) async {
    // Navigator.push: yeni sayfayı üstüne koyar. await: o sayfa kapanana kadar bekler.
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PersonDetailScreen(personId: id)),
    );
    _reload(); // geri dönünce (silme/düzenleme olmuş olabilir) listeyi tazele
  }

  // FAB'a basınca: yeni kişi formunu aç (person vermiyoruz = yeni kayıt).
  Future<void> _openNewForm() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const PersonFormScreen()),
    );
    _reload();
  }

  @override
  Widget build(BuildContext context) {
    // Scaffold = sayfa iskeleti (üst çubuk + gövde + FAB hazır yuvaları var).
    return Scaffold(
      appBar: AppBar(title: const Text('Rehber / Kişi Listesi')),

      // FutureBuilder: "Future'ı izle, durumuna göre ekranı çiz".
      // Neden FutureBuilder? Bekleme / hata / veri geldi durumlarını TEK yerde,
      // ekstra paket olmadan yönetir (Flutter cookbook'un önerdiği yöntem).
      body: FutureBuilder<List<Person>>(
        future: _personsFuture,
        builder: (context, snapshot) {
          // 1) Cevap bekleniyor -> dönen yükleniyor simgesi
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // 2) Hata oldu (sunucu kapalı, internet yok...) -> mesaj + tekrar dene
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 8),
                  Text('Hata: ${snapshot.error}', textAlign: TextAlign.center),
                  const SizedBox(height: 8),
                  ElevatedButton(onPressed: _reload, child: const Text('Tekrar Dene')),
                ],
              ),
            );
          }

          // 3) Veri geldi
          final persons = snapshot.data!;
          if (persons.isEmpty) {
            return const Center(child: Text('Henüz kişi yok. + ile ekleyin.'));
          }

          // ListView.builder: sadece EKRANDA GÖRÜNEN satırları üretir, kaydırdıkça yenisini yapar.
          // Neden ListView(children: [...]) değil? O, 1000 kişide 1000 satırı birden üretir (yavaş).
          return ListView.builder(
            itemCount: persons.length,
            itemBuilder: (context, index) {
              final person = persons[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  // Solda dairesel profil fotoğrafı
                  leading: PersonAvatar(photoUrl: person.photoUrl, name: person.fullName),
                  // Kalın yazıyla Ad-Soyad
                  title: Text(
                    person.fullName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  // Altında Departman  (CANLI KOD TESTİ: telefonu göstermek için person.phone yaz)
                  subtitle: Text(person.department),
                  onTap: () => _openDetail(person.id!), // id! = "id boş değil" garantisi
                ),
              );
            },
          );
        },
      ),

      // Sağ alt köşede sabit + butonu (Scaffold bunu otomatik oraya koyar).
      floatingActionButton: FloatingActionButton(
        onPressed: _openNewForm,
        child: const Icon(Icons.add),
      ),
    );
  }
}
