"""
Django'nun hazır yönetim paneli (http://127.0.0.1:8000/admin).
Tek satırla Person tablosunu panelde görürüz: tarayıcıdan kişi ekleyip silebiliriz.
Bonus: Veriyi elle SQL yazmadan kontrol etmenin en kolay yolu.
"""
from django.contrib import admin
from .models import Person

admin.site.register(Person)
