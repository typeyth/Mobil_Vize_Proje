"""
AYARLAR DOSYASI (settings.py)
Django'nun "kontrol paneli" burasıdır. Hangi uygulamalar var, veritabanı ne,
hangi adreslerden istek kabul edilir... hepsi burada yazılır.

startproject komutu bu dosyayı bizim için uzun uzun açıklamalarla üretmişti.
Biz sadece işimize yarayan kısımları bıraktık ve 3 yeri kendimiz değiştirdik
(aşağıda "BİZİM DEĞİŞİKLİK" yazan yerler).
"""
from pathlib import Path

# Projenin bulunduğu klasör (dosya yollarını hesaplamak için)
BASE_DIR = Path(__file__).resolve().parent.parent

# Gizli anahtar: Django'nun şifreleme işlerinde kullandığı rastgele metin.
# DİKKAT: Gerçek bir projede bu GitHub'a konmaz. Ödev için sorun değil.
SECRET_KEY = 'django-insecure-e%^@w*n6nb495j*a)sk#ik_gv23h2feb51_not+)3if0&wqmew'

# DEBUG=True: Hata olursa ayrıntılı hata sayfası gösterir. Sadece geliştirmede açık olur.
DEBUG = True

# BİZİM DEĞİŞİKLİK 1: Hangi adreslerden gelen isteklere cevap verilecek?
# '*' = hepsi. Emülatör sunucuya 10.0.2.2 adresiyle, gerçek telefon ise
# bilgisayarın IP'siyle (192.168.x.x) ulaşır. Liste boş kalırsa Django bu
# istekleri "400 Bad Request" diye reddeder.
ALLOWED_HOSTS = ['*']

# Web (Chrome) üzerinden gelen isteklere izin ver
CORS_ALLOW_ALL_ORIGINS = True

# Kurulu uygulamalar listesi. Django yalnızca buradakileri tanır.
INSTALLED_APPS = [
    'django.contrib.admin',        # hazır yönetim paneli (/admin)
    'django.contrib.auth',         # kullanıcı sistemi (admin için gerekli)
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.messages',
    'django.contrib.staticfiles',
    'rest_framework',              # BİZİM DEĞİŞİKLİK 2: REST API kütüphanesi (DRF)
    'corsheaders',                 # Web (Chrome) isteklerine izin vermek için CORS
    'persons',                     # BİZİM DEĞİŞİKLİK 3: kendi yazdığımız uygulama
]

# Ara katmanlar: her isteğin başında/sonunda çalışan güvenlik vb. küçük parçalar.
MIDDLEWARE = [
    'corsheaders.middleware.CorsMiddleware',  # CORS middleware en üstte olmalı
    'django.middleware.security.SecurityMiddleware',
    'django.contrib.sessions.middleware.SessionMiddleware',
    'django.middleware.common.CommonMiddleware',
    'django.middleware.csrf.CsrfViewMiddleware',
    'django.contrib.auth.middleware.AuthenticationMiddleware',
    'django.contrib.messages.middleware.MessageMiddleware',
    'django.middleware.clickjacking.XFrameOptionsMiddleware',
]

# İstek geldiğinde Django'nun önce bakacağı ana URL dosyası
ROOT_URLCONF = 'config.urls'

# Şablon (HTML) ayarı. Biz HTML üretmiyoruz ama admin paneli buna ihtiyaç duyar.
TEMPLATES = [
    {
        'BACKEND': 'django.template.backends.django.DjangoTemplates',
        'DIRS': [],
        'APP_DIRS': True,
        'OPTIONS': {
            'context_processors': [
                'django.template.context_processors.request',
                'django.contrib.auth.context_processors.auth',
                'django.contrib.messages.context_processors.messages',
            ],
        },
    },
]

WSGI_APPLICATION = 'config.wsgi.application'

# VERİTABANI: SQLite = tek bir dosya (db.sqlite3). Kurulum gerektirmez.
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.sqlite3',
        'NAME': BASE_DIR / 'db.sqlite3',
    }
}

# Her tablo için otomatik "id" sütununun tipi
DEFAULT_AUTO_FIELD = 'django.db.models.BigAutoField'

# Dil ve saat dilimi
LANGUAGE_CODE = 'tr'
TIME_ZONE = 'Europe/Istanbul'
USE_I18N = True
USE_TZ = True

# Admin panelinin CSS/JS dosyalarının adresi
STATIC_URL = 'static/'
