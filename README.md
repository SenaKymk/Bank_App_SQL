# 📊 Banka Mobil Uygulaması ve Yönetim Sistemi

Bu proje, **Veri Tabanı Yönetim Sistemleri (DBMS)** dersi kapsamında geliştirilmiş;  
müşteri verilerinin **SQL tabanlı olarak saklandığı, analiz edildiği ve raporlandığı**  
uçtan uca bir **mobil + backend** uygulamasıdır.

Projenin temel amacı; ilişkisel veri tabanı tasarımı, SQL sorguları, agregasyon işlemleri  
ve bunların gerçek bir uygulamada nasıl kullanıldığını göstermektir.

---

## 🧱 Sistem Mimarisi

- **Frontend:** Flutter (Mobil Uygulama)
- **Backend:** Django REST Framework
- **Veri Tabanı:** SQLite (İlişkisel SQL)
- **İletişim:** RESTful API (HTTP – JSON)

**Genel Akış:**

Flutter (Mobil Arayüz)  
↓  
Django REST API  
↓  
SQLite Veritabanı (SQL sorguları)

---

## 🗄️ Veri Tabanı Yapısı ve SQL Kullanımı

Projede **ilişkisel veri tabanı yaklaşımı** aktif olarak kullanılmaktadır.

### 📌 Ana Tablolar
- **Users** → Kullanıcı kimlik ve rol bilgileri  
- **CustomerProfile** → Demografik müşteri bilgileri  
- **CustomerActivity** → Aylık işlem kayıtları  
- **CustomerTimeSeriesSummary** → Zaman serisi özetleri  
- **CustomerChurnLabel** → Churn sonuçları  
- **AuditLogs** → Sistem ve admin logları  

### 📌 Kullanılan SQL Kavramları
- `SELECT`, `WHERE`
- `JOIN`
- `GROUP BY`
- `ORDER BY`
- `SUM`, `COUNT`, `AVG`
- Tarih bazlı filtreleme (ay / yıl)
- Sıralama (ranking) mantığı

Bu SQL yapıları özellikle:
- Aylık EFT / Kart işlem analizleri
- Müşteri sıralamaları (kampanyalar)
- Trend hesaplamaları
- Churn tahmini için feature üretimi

amaçlarıyla kullanılmıştır.

---

## 📱 Mobil Uygulama (Flutter)

### 👤 Customer (Müşteri) Ekranları
- **Profil Bilgileri**
  - Kullanıcı bilgilerini görüntüleme ve güncelleme
- **Aylık İşlem Özeti**
  - Yazılı açıklamalar
  - İşlem sayısı ve tutar karşılaştırma grafikleri
- **Trend Analizi**
  - EFT / Kart işlem trendleri
  - Zaman serisi line chart’lar
- **Kampanyalar**
  - SQL `ORDER BY` ile oluşturulan müşteri sıralamaları
  - Kullanıcının kendi sırası ve ödül durumu

### 🛠️ Admin Ekranları
- Müşteri listesi
- Müşteri detay ekranı
- Sistem istatistikleri
- Churn tahmini
- Audit log kayıtları

---

## 📈 Analitik ve Raporlama

Uygulama içerisinde:

- Zaman serisi analizleri
- Karşılaştırmalı grafikler
- Özet bilgi kartları
- Müşteri sıralama (ranking) ekranları
- Churn risk değerlendirmeleri

yer almaktadır.

Tüm bu analizler **doğrudan SQL sorguları ile üretilen veriler** üzerinden yapılmaktadır.

---

## 🎯 Ders Kapsamındaki Kazanımlar

Bu proje sayesinde:

- Gerçek hayata uygun **ilişkisel veritabanı tasarımı**
- SQL sorgularının uygulama içinde kullanımı
- Backend – Frontend veri akışı
- `ORDER BY`, `GROUP BY` gibi DBMS konularının pratik karşılığı
- Veri analizi ve görselleştirme entegrasyonu

başarıyla uygulanmıştır.

---

## 🚀 Sonuç

Bu proje, **Veri Tabanı Yönetim Sistemleri** dersinde öğrenilen teorik bilgilerin;  
**SQL + Backend + Mobil uygulama** bütünlüğü içinde gerçekçi bir senaryo ile hayata geçirilmiş örnek bir çalışmadır.

---

**Powered by Pınar Kocagöz & Hasna Sena Kaymak**
