"""
VIEW = "isteği karşılayan ve cevabı hazırlayan" kısım.

DRF'nin hazır "generic" sınıflarını kullandık. Her sınıf, ödevdeki tablonun
bir satırına karşılık gelir:

  ListCreateAPIView            -> GET  /api/persons   (listele)
                                  POST /api/persons   (yeni kayıt)
  RetrieveUpdateDestroyAPIView -> GET    /api/persons/{id} (tek kişi)
                                  PUT    /api/persons/{id} (güncelle)
                                  DELETE /api/persons/{id} (sil)

Neden bunlar, neden ViewSet/Router veya elle yazılan fonksiyon değil?
  - Elle fonksiyon (@api_view): her şeyi kendin yazarsın, 100+ satır, hata riski yüksek.
  - ModelViewSet + Router: 3 satırla hepsi olur ama "sihirli"dir; sunumda
    "DELETE nerede çalışıyor?" sorusuna cevap vermek zorlaşır.
  - Generic view: orta yol. Kısa, ama adresler urls.py'de açıkça görünür.
"""
from rest_framework import generics
from .models import Person
from .serializers import PersonSerializer


class PersonListCreateView(generics.ListCreateAPIView):
    queryset = Person.objects.all()          # hangi veriler? -> tablodaki herkes
    serializer_class = PersonSerializer      # hangi çevirmen? -> yukarıdaki


class PersonDetailView(generics.RetrieveUpdateDestroyAPIView):
    queryset = Person.objects.all()          # URL'deki id'ye göre bunun içinden bulur
    serializer_class = PersonSerializer
