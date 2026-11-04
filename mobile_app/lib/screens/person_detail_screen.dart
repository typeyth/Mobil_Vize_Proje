// EKRAN 2: KİŞİ DETAY  ->  GET /api/persons/{id}  +  DELETE /api/persons/{id}

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; // telefon / e-posta uygulamasını açmak için
import '../models/person.dart';
import '../services/api_service.dart';
import '../widgets/person_avatar.dart';
import 'person_form_screen.dart';

class PersonDetailScreen extends StatefulWidget {
  // Listeden sadece ID gelir (ödev şartı). Veriyi bu ekran kendisi sunucudan çeker.
  // Neden bütün Person nesnesini geçirmedik? Hem ödev "ID ile" diyor, hem de
  // sunucudaki EN GÜNCEL veriyi görmek istiyoruz (başkası değiştirmiş olabilir).
  final int personId;
  const PersonDetailScreen({super.key, required this.personId});

  @override
  State<PersonDetailScreen> createState() => _PersonDetailScreenState();
}

class _PersonDetailScreenState extends State<PersonDetailScreen> {
  late Future<Person> _personFuture;

  @override
  void initState() {
    super.initState();
    _personFuture = ApiService.getPerson(widget.personId); // widget.xxx = üstteki sınıfın alanı
  }

  // Ekranın altında kısa bilgi mesajı gösterir (SnackBar).
  void _showMessage(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  // E-posta / telefon satırına tıklanınca sistemin ilgili uygulamasını aç.
  // url_launcher: "tel:" ve "mailto:" gibi adresleri telefona açtıran resmi paket.
  // Neden android_intent paketi değil? O SADECE Android'dedir; url_launcher iOS'ta da çalışır.
  Future<void> _launch(Uri uri) async {
    bool ok = false;
    try {
      ok = await launchUrl(uri);
    } catch (_) {
      ok = false; // emülatörde arama/posta uygulaması yoksa hata fırlatabilir
    }
    if (!ok) _showMessage('Uygulama açılamadı');
  }

  // DÜZENLE: formu mevcut kişiyle aç, dönünce bu sayfanın verisini yeniden çek.
  Future<void> _edit(Person person) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PersonFormScreen(person: person)),
    );
    if (!mounted) return;
    setState(() {
      _personFuture = ApiService.getPerson(widget.personId);
    });
  }

  // SİL: önce onay sor, "Sil" denirse DELETE at, sonra listeye dön.
  Future<void> _confirmDelete(Person person) async {
    // showDialog<bool>: açılan pencerenin geri döndüreceği değer true/false.
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Silme Onayı'),
        content: Text('${person.fullName} kalıcı olarak silinecek. Emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false), // Vazgeç -> false
            child: const Text('Vazgeç'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true), // Sil -> true
            // CANLI KOD TESTİ: "buton rengini değiştir" denirse buradaki Colors.red'i değiştir.
            child: const Text('Sil', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed != true) return; // vazgeçti ya da pencere dışına dokundu

    try {
      await ApiService.deletePerson(person.id!);
      if (!mounted) return;
      Navigator.pop(context); // listeye geri dön (liste kendini yeniler)
    } catch (e) {
      _showMessage('Silinemedi: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Alttaki sabit butonlar için kişi verisi lazım; o yüzden FutureBuilder'ı
    // Scaffold'un DIŞINA koyduk ve her durumda Scaffold döndürüyoruz.
    return FutureBuilder<Person>(
      future: _personFuture,
      builder: (context, snapshot) {
        return Scaffold(
          appBar: AppBar(title: const Text('Kişi Detay Bilgileri')),
          body: _buildBody(snapshot),
          // bottomNavigationBar = ekranın EN ALTINDA SABİT durur, kaydırmayla gitmez.
          // Veri henüz gelmediyse butonları gösterme (null = yok).
          bottomNavigationBar: snapshot.hasData ? _buildButtons(snapshot.data!) : null,
        );
      },
    );
  }

  Widget _buildBody(AsyncSnapshot<Person> snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(child: CircularProgressIndicator());
    }
    if (snapshot.hasError) {
      return Center(child: Text('Hata: ${snapshot.error}'));
    }

    final person = snapshot.data!;

    // SingleChildScrollView: ekran küçükse içerik kaydırılabilsin.
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Üstte büyük profil fotoğrafı
          PersonAvatar(photoUrl: person.photoUrl, name: person.fullName, radius: 60),
          const SizedBox(height: 12), // SizedBox = boşluk bırakır
          // Ad-Soyad
          Text(
            person.fullName,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          // Departman unvanı
          Text(person.department, style: const TextStyle(fontSize: 16, color: Colors.grey)),
          const SizedBox(height: 16),

          // Alt panel: bilgi kartları
          _infoCard(Icons.location_city, 'Doğum Yeri', person.birthPlace),
          _infoCard(Icons.cake, 'Doğum Tarihi', person.birthDateTr),
          // onTap verilen satırlar tıklanabilir olur (ödev şartı: e-posta ve telefon)
          _infoCard(
            Icons.email,
            'E-posta',
            person.email,
            onTap: () => _launch(Uri(scheme: 'mailto', path: person.email)),
          ),
          _infoCard(
            Icons.phone,
            'Telefon',
            person.phone,
            onTap: () => _launch(Uri(scheme: 'tel', path: person.phone)),
          ),
        ],
      ),
    );
  }

  // Tekrar eden kart kodunu tek fonksiyona topladık (4 kez kopyala-yapıştır yerine).
  Widget _infoCard(IconData icon, String label, String value, {VoidCallback? onTap}) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(label),
        subtitle: Text(value),
        onTap: onTap, // null ise tıklanamaz
        trailing: onTap != null ? const Icon(Icons.chevron_right) : null,
      ),
    );
  }

  // En altta sabit duran DÜZENLE ve SİL butonları.
  Widget _buildButtons(Person person) {
    return SafeArea( // SafeArea: telefonun alt çentik/çubuğuyla butonlar çakışmasın
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Expanded: iki buton da genişliği eşit paylaşsın
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _edit(person),
                icon: const Icon(Icons.edit),
                label: const Text('DÜZENLE'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _confirmDelete(person),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.delete),
                label: const Text('KİŞİYİ SİL'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
