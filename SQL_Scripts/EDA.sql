--EDA - Keşifçi Veri Analizi

--Ana Satış ve Performans View Yapısı
CREATE VIEW vW_SuperStore_Performance AS
SELECT
	Row_ID,
	Order_ID,
	Order_Date,
	Ship_Date,
	DATEDIFF(DAY,Order_Date,Ship_Date) AS Teslimat_Gün_Süresi,
	Ship_Mode,
	Customer_ID,
	Customer_Name,
	Segment,
	Country,
	City,
	State,
	Region,
	Market,
	Product_ID,
	Category,
	Sub_Category,
	Product_Name,
	Sales AS Ciro,
	Profit AS Net_Kâr,
	Quantity AS Satış_Adedi,
	Discount*100 AS İndirim_Ücreti,
	Shipping_Cost AS Nakliye_Maliyeti,
	Order_Priority AS Sipariş_Önceliği,
	CASE
		WHEN Profit>0 THEN 'Kârlı Sipariş'
		WHEN Profit=0 THEN 'Başa Baş Sipariş'
		ELSE 'Zararlı Sipariş'
	END AS Kârlılık_Durumu
FROM Superstore


--Zaman Serisi ve Büyüme Analizi View Yapısı,

CREATE VIEW vW_SuperStore_Time_Trends AS
SELECT
	YEAR(Order_Date) as YIL,
	MONTH(Order_Date) as AY,
	DATENAME(MONTH,Order_Date) AS Ay_adi,
	DATEPART(QUARTER,Order_Date) AS Ceyrek,
	ROUND(SUM(Sales),2) AS Toplam_Ciro,
	ROUND(SUM(Profit),2) AS Toplam_Kâr,
	COUNT(DISTINCT(Order_ID)) AS Toplam_Sipariş_Sayisi,
	COUNT(DISTINCT(Customer_ID)) AS Toplam_Müşteri_Sayisi
FROM superstore
GROUP BY YEAR(Order_Date),MONTH(Order_Date),DATENAME(MONTH,Order_Date),DATEPART(QUARTER,Order_Date)


CREATE VIEW vW_SuperStore_Product_Analysis AS
SELECT
	Category AS Ana_Kategori,
	Sub_Category AS Alt_Kategori,
	Product_Name AS Ürün_Adi,
	ROUND(SUM(Sales),2) AS Toplam_Satis,
	ROUND(SUM(Profit),2) AS Toplam_Kâr,
	SUM(Quantity) AS Toplam_Adet,
	-- Kâr Marjı Hesabı
	ROUND((SUM(Profit) / NULLIF(SUM(Sales), 0)) * 100, 2) AS Kar_Marji_Yuzdesi
FROM superstore
GROUP BY Category,Sub_Category,Product_Name