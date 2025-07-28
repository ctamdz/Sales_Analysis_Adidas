DROP TABLE DimRetailer

CREATE TABLE DimRetailer (
    RetailerID INT IDENTITY(1,1) PRIMARY KEY,
    Retailer NVARCHAR(100) NOT NULL
);

DROP TABLE DimProduct

CREATE TABLE DimProduct (
    ProductID INT IDENTITY(1,1) PRIMARY KEY,
    Product NVARCHAR(100) NOT NULL
);

DROP TABLE DimGeography

CREATE TABLE DimGeography (
    GeographyID INT IDENTITY(1,1) PRIMARY KEY,
    Region NVARCHAR(50) NOT NULL,
    State NVARCHAR(50) NOT NULL,
    City NVARCHAR(50) NOT NULL
);

DROP TABLE DimDate

CREATE TABLE DimDate (
    DateID INT IDENTITY(1,1) PRIMARY KEY,
    InvoiceDate DATE NOT NULL,
    Year INT NOT NULL,
    Month INT NOT NULL,
    Day INT NOT NULL
);

DROP TABLE DimSalesMethod

CREATE TABLE DimSalesMethod (
    SalesMethodID INT IDENTITY(1,1) PRIMARY KEY,
    SalesMethod NVARCHAR(50) NOT NULL
);

DROP TABLE FactSales

-- tạo bảng fact table 
CREATE TABLE FactSales (
    RetailerID INT NOT NULL,
    ProductID INT NOT NULL,
    GeographyID INT NOT NULL,
    DateID INT NOT NULL,
    SalesMethodID INT NOT NULL,
	PricePerUnit DECIMAL(18,2), -- Thêm cột PricePerUnit
	UnitsSold INT,
    TotalSales DECIMAL(18,2),
    OperatingProfit DECIMAL(18,2),
    CONSTRAINT FK_FactSales_Retailer FOREIGN KEY (RetailerID) REFERENCES DimRetailer(RetailerID),
    CONSTRAINT FK_FactSales_Product FOREIGN KEY (ProductID) REFERENCES DimProduct(ProductID),
    CONSTRAINT FK_FactSales_Geography FOREIGN KEY (GeographyID) REFERENCES DimGeography(GeographyID),
    CONSTRAINT FK_FactSales_Date FOREIGN KEY (DateID) REFERENCES DimDate(DateID),
    CONSTRAINT FK_FactSales_SalesMethod FOREIGN KEY (SalesMethodID) REFERENCES DimSalesMethod(SalesMethodID)
);


-- Bật IDENTITY_INSERT cho bảng DimRetailer
SET IDENTITY_INSERT DimRetailer ON;

INSERT INTO DimRetailer (RetailerID, Retailer)
SELECT [Retailer ID], MIN(Retailer) AS Retailer
FROM SalesData
WHERE [Retailer ID] IS NOT NULL AND Retailer IS NOT NULL
GROUP BY [Retailer ID];
SET IDENTITY_INSERT DimRetailer OFF;

INSERT INTO DimRetailer (Retailer)
SELECT DISTINCT Retailer
FROM SalesData
WHERE Retailer IS NOT NULL;

SELECT * FROM DimRetailer

-- 2. DimProduct
INSERT INTO DimProduct (Product)
SELECT DISTINCT Product
FROM SalesData
WHERE Product IS NOT NULL;

-- 3. DimGeography
INSERT INTO DimGeography (Region, State, City)
SELECT DISTINCT Region, State, City
FROM SalesData
WHERE Region IS NOT NULL AND State IS NOT NULL AND City IS NOT NULL;

-- 4. DimDate
INSERT INTO DimDate (InvoiceDate, Year, Month, Day)
SELECT DISTINCT [Invoice Date],
       YEAR([Invoice Date]) AS Year,
       MONTH([Invoice Date]) AS Month,
       DAY([Invoice Date]) AS Day
FROM SalesData
WHERE [Invoice Date] IS NOT NULL;

-- 5. DimSalesMethod
INSERT INTO DimSalesMethod (SalesMethod)
SELECT DISTINCT [Sales Method]
FROM SalesData
WHERE [Sales Method] IS NOT NULL;

--6. FactSale 
WITH MappedData AS (
    SELECT 
        (SELECT RetailerID FROM DimRetailer WHERE Retailer = sd.Retailer) AS RetailerID,
        (SELECT ProductID FROM DimProduct WHERE Product = sd.Product) AS ProductID,
        (SELECT GeographyID FROM DimGeography WHERE Region = sd.Region AND State = sd.State AND City = sd.City) AS GeographyID,
        (SELECT DateID FROM DimDate WHERE InvoiceDate = sd.[Invoice Date]) AS DateID,
        (SELECT SalesMethodID FROM DimSalesMethod WHERE SalesMethod = sd.[Sales Method]) AS SalesMethodID,
        sd.[Price Per Unit],
        sd.[Total Sales],
        sd.[Operating Profit],
        sd.[Units Sold]
    FROM SalesData sd
)
INSERT INTO FactSales (RetailerID, ProductID, GeographyID, DateID, SalesMethodID, PricePerUnit, TotalSales, OperatingProfit, UnitsSold)
SELECT 
    RetailerID,
    ProductID,
    GeographyID,
    DateID,
    SalesMethodID,
    [Price Per Unit],
    [Total Sales],
    [Operating Profit],
    [Units Sold]
FROM MappedData;

----------------------


SELECT* FROM DimRetailer;
SELECT* FROM DimProduct;
SELECT TOP 64 * FROM DimGeography;
SELECT TOP 10 * FROM DimDate;
SELECT TOP 10 * FROM DimSalesMethod;
SELECT TOP 10 * FROM FactSales;

