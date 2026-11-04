// EKRAN 3: EKLE / DÜZENLE FORMU
//   Yeni kişi  -> POST /api/persons
//   Düzenleme  -> PUT  /api/persons/{id}
//
// Neden iki ayrı ekran değil de TEK form? İki ekran birebir aynı alanlara sahip.
// Ayrı yazsaydık kodun yarısı kopya olurdu. "person" dolu mu boş mu diye bakarak ayırırız.

import 'package:flutter/material.dart';
import '../models/person.dart';
import '../services/api_service.dart';

class PersonFormScreen extends StatefulWidget {
  final Person? person; // null = yeni kayıt, dolu = düzenleme
  const PersonFormScreen({super.key, this.person});

  @override
  State<PersonFormScreen> createState() => _PersonFormScreenState();
}

class _PersonFormScreenState extends State<PersonFormScreen> {
  // GlobalKey<FormState>: formu "doğrula" (validate) diyebilmek için forma verilen kimlik.
  final _formKey = GlobalKey<FormState>();

  // Controller = kutudaki yazıyı okumamızı ve önceden doldurmamızı sağlayan kumanda.
  late final TextEditingController _nameCtrl;
  late final TextEditingController _deptCtrl;
  late final TextEditingController _photoCtrl;
  late final TextEditingController _placeCtrl;
  late final TextEditingController _dateCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _phoneCtrl;

  bool _saving = false; // kaydederken butonu kilitlemek için

  bool get _isEdit => widget.person != null;

  @override
  void initState() {
    super.initState();
    final p = widget.person; // düzenlemedeyse kutuları mevcut bilgiyle doldur
    _nameCtrl = TextEditingController(text: p?.fullName ?? '');
    _deptCtrl = TextEditingController(text: p?.department ?? '');
    _photoCtrl = TextEditingController(text: p?.photoUrl ?? '');
    _placeCtrl = TextEditingController(text: p?.birthPlace ?? '');
    _dateCtrl = TextEditingController(text: p?.birthDate ?? '');
    _emailCtrl = TextEditingController(text: p?.email ?? '');
    _phoneCtrl = TextEditingController(text: p?.phone ?? '');
  }

  // dispose: ekran kapanırken kumandaları serbest bırak (bellek sızıntısı olmasın).
  @override
  void dispose() {
    _nameCtrl.dispose();
    _deptCtrl.dispose();
    _photoCtrl.dispose();
    _placeCtrl.dispose();
    _dateCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  // Takvimden tarih seç. Elle yazdırmak yerine takvim: yanlış biçim girme ihtimali yok.
  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.tryParse(_dateCtrl.text) ?? DateTime(2000, 1, 1),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      // toIso8601String() = "2000-01-05T00:00:00.000"; ilk 10 karakter = API'nin istediği YYYY-AA-GG
      _dateCtrl.text = picked.toIso8601String().substring(0, 10);
    }
  }

  Future<void> _save() async {
    // Tüm validator'ları çalıştır; biri hata verirse kaydetme.
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);

    // Kutulardaki yazılardan yeni bir Person nesnesi kur. trim() = baş/son boşlukları at.
    final person = Person(
      fullName: _nameCtrl.text.trim(),
      department: _deptCtrl.text.trim(),
      photoUrl: _photoCtrl.text.trim(),
      birthPlace: _placeCtrl.text.trim(),
      birthDate: _dateCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
    );

    try {
      if (_isEdit) {
        await ApiService.updatePerson(widget.person!.id!, person); // PUT
      } else {
        await ApiService.createPerson(person); // POST
      }
      if (!mounted) return;
      Navigator.pop(context); // başarılı -> bir önceki ekrana dön
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Hata: $e')));
    }
  }

  // Doğrulayıcı: boş bırakılamaz.
  String? _required(String? value) {
    if (value == null || value.trim().isEmpty) return 'Bu alan zorunlu';
    return null; // null = hata yok
  }

  // Tekrar eden metin kutusu kodunu tek fonksiyona topladık.
  Widget _field(
    TextEditingController controller,
    String label, {
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType, // e-posta için @'li klavye, telefon için rakam klavyesi
        validator: validator,
        readOnly: readOnly,
        onTap: onTap,
        decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEdit ? 'Kişiyi Düzenle' : 'Yeni Kişi')),
      body: SingleChildScrollView( // klavye açılınca taşma olmasın
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _field(_nameCtrl, 'Ad Soyad', validator: _required),
              _field(_deptCtrl, 'Departman', validator: _required),
              _field(_photoCtrl, 'Fotoğraf URL (isteğe bağlı)', keyboardType: TextInputType.url),
              _field(_placeCtrl, 'Doğum Yeri', validator: _required),
              // Tarih kutusu: elle yazılmaz (readOnly), tıklayınca takvim açılır.
              _field(_dateCtrl, 'Doğum Tarihi (YYYY-AA-GG)',
                  readOnly: true, onTap: _pickDate, validator: _required),
              _field(
                _emailCtrl,
                'E-posta',
                keyboardType: TextInputType.emailAddress,
                validator: (v) {
                  if (_required(v) != null) return 'Bu alan zorunlu';
                  if (!v!.contains('@')) return 'Geçerli bir e-posta girin';
                  return null;
                },
              ),
              _field(_phoneCtrl, 'Telefon', keyboardType: TextInputType.phone, validator: _required),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  // _saving true iken onPressed null -> buton pasif (çift tıklamayı engeller)
                  onPressed: _saving ? null : _save,
                  child: _saving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(_isEdit ? 'GÜNCELLE' : 'KAYDET'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
