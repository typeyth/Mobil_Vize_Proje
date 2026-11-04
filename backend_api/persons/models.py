"""
MODEL = veritabanındaki TABLONUN Python'daki tarifi.
Her satır (class) bir tablo, her değişken bir sütundur.
Biz tabloyu elle SQL ile yazmıyoruz; Django bu tariften tabloyu kendisi üretir.

ÖNEMLİ KARAR: Alan adlarını ödev yönergesindeki JSON ile BİREBİR AYNI (camelCase)
yazdık: fullName, photoUrl, birthPlace, birthDate.
  Neden? Veritabanı sütunu = API'deki JSON anahtarı = Dart'taki değişken adı.
  Tek isim, çeviri yok, yazım hatası yapma ihtimali yok.
  Alternatif: Python'da yaygın olan snake_case (full_name) kullanıp serializer'da
  "source=" ile çevirmek. Çalışır ama bir çeviri katmanı daha eklemek demektir;
  basit tutmak için tercih etmedik.
"""
from django.db import models


class Person(models.Model):
    # CharField = kısa metin. max_length zorunlu (veritabanına "en fazla 100 harf" der).
    fullName = models.CharField(max_length=100)
    department = models.CharField(max_length=100)

    # URLField = internet adresi. blank=True: boş bırakılabilir (fotoğrafı olmayan kişi olabilir).
    photoUrl = models.URLField(max_length=500, blank=True)

    birthPlace = models.CharField(max_length=100)

    # DateField = sadece tarih. API'ye "1994-04-12" (YYYY-AA-GG) biçiminde çıkar.
    birthDate = models.DateField()

    # EmailField = e-posta. İçinde @ yoksa Django kaydı reddeder (hazır doğrulama).
    email = models.EmailField()

    # Telefonu sayı (int) değil METİN olarak tutarız: "+90" ve baştaki "0" kaybolmasın.
    phone = models.CharField(max_length=20)

    # "id" alanını yazmıyoruz: Django 1, 2, 3... diye otomatik ekler (birincil anahtar).

    class Meta:
        ordering = ['id']   # liste her zaman id sırasına göre gelsin

    def __str__(self):
        # Admin panelinde kişinin adı görünsün diye
        return self.fullName
