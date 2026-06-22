# 🛒 SuperStore Satış ve Performans Veri Analizi Projesi

Bu proje, **SuperStore** veri seti üzerinde gerçekleştirilmiş uçtan uca bir veri analizi sürecini kapsamaktadır. Ham verilerin **MSSQL Server** kullanılarak temizlenmesi, performans optimizasyonu için **SQL View (Görünüm)** yapılarının oluşturulması ve elde edilen temiz veri modeliyle **Power BI** üzerinde profesyonel bir kurumsal raporlama paneli (dashboard) geliştirilmesi aşamalarını içerir.

---

## 📂 Proje Klasör Yapısı
Projenin GitHub üzerinde düzenli ve kurumsal görünmesi için klasör mimarisi şu şekilde kurgulanmıştır:
```text
SuperStore_Sales/
│
├── 📁 Assets/           # Proje ekran görüntüleri ve görsel dökümantasyonlar
├── 📁 PowerBI_Report/   # Power BI (.pbix) rapor dosyası
└── 📁 SQL_Scripts/      # Veri Temizleme, EDA ve View oluşturan T-SQL kodları

## 🛠️ 1. Aşama: Veri Temizleme ve Ön İşleme (MSSQL)
Analiz sürecine başlamadan önce veri bütünlüğünü sağlamak ve veri tabanı performansını artırmak amacıyla ham veri seti gelişmiş T-SQL sorgularıyla işlenmiştir:

Şema Düzenleme ve Gereksiz Verilerin Temizlenmesi:

Veri setinde bulunan ve hatalı/bozuk karakterler içeren sütunlar (Örn: Çince karakterli [记录数]) DROP COLUMN ile kaldırılmıştır.
Metin tabanlı alanlardaki gizli boşluklar TRIM() fonksiyonu ile temizlenmiştir.
Finansal hesaplamaların doğru yapılabilmesi için Sales (Satış), Profit (Kâr) ve Discount (İndirim) kolonları FLOAT veri tipine dönüştürülmüştür.
Benzersizliği sağlamak adına Row_ID kolonu NOT NULL yapılarak Birincil Anahtar (Primary Key - PK) olarak tanımlanmıştır.

Dinamik Veri Kalitesi Kontrolleri (Dynamic SQL):

Veri tabanındaki tüm kolonları otomatik olarak tarayan dinamik bir T-SQL betiği yazılmış; her bir kolon için NULL (boş değer) oranları dinamik olarak hesaplanmıştır.
VARCHAR ve NVARCHAR gibi metin sütunları filtrelenerek; başta/sonda kalan boşluklar, boş metinler ('') ve standart dışı yabancı karakter içeren satırlar tespit edilip optimize edilmiştir.

## 👁️ 2. Aşama: Keşifçi Veri Analizi (EDA) ve SQL Görünümleri (Views)
Power BI raporunun daha hızlı çalışması ve veri çekme performansının optimize edilmesi amacıyla, ağır hesaplama mantıkları veri tabanı seviyesinde SQL Views kullanılarak çözülmüştür:

vw_SuperStore_Performance (Ana Satış ve Performans Görünümü): Teslimat gün süresi (DATEDIFF), net kâr ve indirim oranları gibi metrikleri içerir. Ayrıca CASE WHEN mantığı kullanılarak siparişler kârlılık durumuna göre sınıflandırılmıştır (Kârlı Sipariş, Başa Baş Sipariş, Zararlı Sipariş).

vw_SuperStore_Time_Trends (Zaman Serisi ve Büyüme Analizi Görünümü): Satış performansını zamansal olarak incelemek için verileri Yıl, Ay, Ay Adı ve Çeyrek (Quarter) bazında gruplayıp kümülatif toplamları (Satış, Kâr, Sipariş ve Müşteri Sayısı) hazır hale getirir.

vw_SuperStore_Product_Analysis (Ürün ve Kategori Performansı Görünümü): Kategori, Alt Kategori ve Ürün Adı bazında toplam satış ve adetleri gruplar. Sıfıra bölünme hatasını (Division by Zero) engellemek için NULLIF kullanılarak kâr marjı yüzdesi hatasız hesaplanmıştır:

ROUND((SUM(Profit) / NULLIF(SUM(Sales), 0)) * 100, 2) AS Kar_Marji_Yuzdesi

## 📊 3. Aşama: Power BI Rapor Tasarımı
Power BI raporu, sol menüde yer alan özel bir navigasyon paneli ve kurumsal lacivert/mavi tema eşliğinde 3 ana analitik sayfadan oluşmaktadır:

A. Yönetici Özeti (Executive Dashboard)
Şirket yöneticilerinin ve paydaşların genel durumu tek bir bakışta görmesi için tasarlanmıştır.

KPI Kartları: Toplam Ciro (₺12.64M), Toplam Kâr (₺1.47M), Toplam Satış Adedi (178.3K) ve Ortalama Kâr Marjı (%11.61).
Müşteri Segmentasyonu: Cironun müşteri kırılımına göre dağılımı (Donut grafiğinde en büyük payın %51.49 ile Consumer segmentinde olduğu görülmektedir).
Ülke Bazlı Satış Dağılımı: Satış yoğunluğunu kıtalara ve ülkelere göre görselleştiren interaktif harita yapısı.

B. Zaman ve Trend Analizi (Trend & Growth)
Şirketin zamansal büyümesini, dönemsel trendleri ve müşteri sürekliliğini analiz eder.

Zaman İçinde Büyüme Trendi: Toplam Kâr ve Toplam Cironun tarihsel süreçteki dalgalanmalarını gösteren alan-çizgi (Area-Line) kombinasyon grafiği.
Yıllık Bazda Müşteri ve Sipariş Sayısı: 2011-2014 yılları arasında toplam sipariş sayısı ile tekil müşteri sayısını karşılaştırarak müşteri tutundurma oranını inceleyen çift eksenli sütun grafiği.

C. Ürün ve Kategori Performansı (Product Deep-Dive)
Hangi ürün grubunun şirkete değer kazandırdığını veya hangi ürünlerin zarar ettirdiğini saptamak için geliştirilmiştir.

Hiyerarşik Matris Tablosu: Ana Kategori (Furniture, Office Supplies, Technology) ve Alt Kategorilerin ciro, kâr ve kâr marjlarını yeşil/kırmızı renkli koşullu biçimlendirme ile sunan detaylı kırılım tablosu.
En Çok Kâr Getiren İlk 10 Ürün: Şirketin en kârlı amiral gemisi ürünlerini (Örn: Canon imageCLASS) listeleyen yatay bar grafiği.
En Çok Zarar Eden İlk 10 Ürün: Finansal açığı kapatmak adına acil önlem alınması gereken zararlı ürünleri (Örn: Cubify Cubex 3D Printers) listeleyen risk analiz grafiği.


💡 Not: Bu çalışma, MSSQL ile veri mühendisliği tekniklerini ve Power BI ile ileri düzey veri görselleştirme/hikayeleştirme yetkinliklerini sergilemek amacıyla hazırlanmış uçtan uca profesyonel bir portfolyo projesidir.