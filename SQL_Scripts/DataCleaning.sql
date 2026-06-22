------DATA CLEANING

ALTER TABLE superstore
DROP COLUMN [记录数];

UPDATE superstore
SET
	Sales=TRIM(Sales),
	Profit=TRIM(Profit),
	Discount=TRIM(Discount)

ALTER TABLE superstore
ALTER COLUMN  Sales FLOAT;

ALTER TABLE superstore
ALTER COLUMN Profit FLOAT;

ALTER TABLE superstore
ALTER COLUMN Discount FLOAT;

ALTER TABLE superstore 
ALTER COLUMN Row_ID INT NOT NULL

ALTER TABLE superstore
ADD CONSTRAINT PK_superstore_RowID PRIMARY KEY (Row_ID);

DECLARE @TableName NVARCHAR(256) = 'dbo.superstore';
DECLARE @SQL NVARCHAR(MAX) = '';
SELECT @SQL = @SQL + 
    'SELECT ''' + COLUMN_NAME + ''' AS [Kolon_Adi], ' +
    '''' + DATA_TYPE + COALESCE('(' + CAST(CHARACTER_MAXIMUM_LENGTH AS VARCHAR) + ')', '') + ''' AS [Veri_Tipi], ' +
    'COUNT(*) - COUNT(' + QUOTENAME(COLUMN_NAME) + ') AS [Null_Deger_Sayisi], ' +
    'CAST((COUNT(*) - COUNT(' + QUOTENAME(COLUMN_NAME) + ')) * 100.0 / COUNT(*) AS DECIMAL(5,2)) AS [Null_Orani_%] ' +
    'FROM ' + @TableName + ' UNION ALL '
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = PARSENAME(@TableName, 2) 
  AND TABLE_NAME = PARSENAME(@TableName, 1);
IF LEN(@SQL) > 0
BEGIN
    SET @SQL = LEFT(@SQL, LEN(@SQL) - 10) + ' ORDER BY [Null_Deger_Sayisi] DESC;';
    EXEC sp_executesql @SQL;
END
ELSE
BEGIN
    PRINT 'Tablo bulunamadı veya tablo adı hatalı!';
END;


DECLARE @TableName NVARCHAR(256) = 'dbo.superstore';
DECLARE @SQL NVARCHAR(MAX) = '';

-- Sadece metin tabanlı sütunları filtreleyip dinamik sorgu oluşturuyoruz
SELECT @SQL = @SQL + 
    'SELECT ''' + COLUMN_NAME + ''' AS [Kolon_Adi], ' +
    'COUNT(CASE WHEN ' + QUOTENAME(COLUMN_NAME) + ' = '''' THEN 1 END) AS [Bos_Metin_Sayisi_('''')], ' +
    'COUNT(CASE WHEN ' + QUOTENAME(COLUMN_NAME) + ' LIKE '' %'' OR ' + QUOTENAME(COLUMN_NAME) + ' LIKE ''% '' THEN 1 END) AS [Basinda_Sonunda_Bosluk_Olanlar], ' +
    -- Bu kısım standart harfler, rakamlar ve yaygın noktalama işaretleri dışındaki karakterleri yakalar (Örn: Çince karakterler)
    'COUNT(CASE WHEN ' + QUOTENAME(COLUMN_NAME) + ' LIKE ''%[^a-zA-Z0-9çÇğĞıİöÖşŞüÜ .,_()#/-]%'' THEN 1 END) AS [Ozel_Veya_Yabanci_Karakterli_Satirlar] ' +
    'FROM ' + @TableName + ' UNION ALL '
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = PARSENAME(@TableName, 2) 
  AND TABLE_NAME = PARSENAME(@TableName, 1)
  -- Sadece metin veri tiplerini hedef alıyoruz
  AND DATA_TYPE IN ('nvarchar', 'varchar', 'char', 'nchar', 'text', 'ntext');

IF LEN(@SQL) > 0
BEGIN
    SET @SQL = LEFT(@SQL, LEN(@SQL) - 10) + ';';
    EXEC sp_executesql @SQL;
END
ELSE
BEGIN
    PRINT 'Metin sütunu bulunamadı veya tablo adı hatalı!';
END;

