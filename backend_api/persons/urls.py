"""
persons uygulamasının adres defteri. Ana urls.py "api/" kısmını zaten yuttu,
burada geri kalanı eşleştiriyoruz:  api/ + persons  => /api/persons
"""
from django.urls import path
from .views import PersonListCreateView, PersonDetailView

urlpatterns = [
    # SONUNDA "/" YOK: ödev tablosundaki adreslerle birebir aynı olsun diye.
    # (Sonunda / olsaydı ve mobilden / olmadan istek atsaydık, Django POST isteğini
    #  yönlendirmeye çalışır ve veri kaybolurdu.)
    path('persons', PersonListCreateView.as_view()),

    # <int:pk> = adresin o kısmı bir tam sayıdır ve "pk" (primary key = id) adıyla view'a gider.
    path('persons/<int:pk>', PersonDetailView.as_view()),
]
