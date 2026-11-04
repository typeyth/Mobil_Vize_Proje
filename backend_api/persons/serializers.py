"""
SERIALIZER = ÇEVİRMEN.
Veritabanındaki Person nesnesi  <->  JSON metni
Giden yönde (GET):  Person nesnesi -> JSON
Gelen yönde (POST/PUT): JSON -> doğrulanmış Person nesnesi
Doğrulamayı da o yapar (e-posta geçerli mi? zorunlu alan boş mu?).
"""
from rest_framework import serializers
from .models import Person


class PersonSerializer(serializers.ModelSerializer):
    # ModelSerializer = modeli okuyup çevirmeni KENDİ kuran hazır sınıf.
    # Alternatif olan düz "Serializer"da her alanı tek tek yeniden yazmak gerekir.
    class Meta:
        model = Person
        fields = '__all__'   # modeldeki bütün alanlar (id dahil) JSON'a girsin
