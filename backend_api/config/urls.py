"""
ANA URL DOSYASI
Bir istek geldiğinde Django "bu adres kime gidecek?" diye BU dosyaya bakar.
Sıra: adresi soldan sağa oku, eşleşen satırdaki yere yönlendir.
"""
from django.contrib import admin
from django.urls import path, include

urlpatterns = [
    # /admin/...  -> Django'nun hazır yönetim paneli
    path('admin/', admin.site.urls),

    # /api/... ile başlayan her şeyi persons uygulamasının kendi urls.py'sine devret.
    # Neden devrettik? Ana dosya kalabalıklaşmasın, her uygulama kendi adreslerini yönetsin.
    path('api/', include('persons.urls')),
]
