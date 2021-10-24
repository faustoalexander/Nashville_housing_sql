--Cleaning Data for Nashville housing

SELECT *
FROM PortafolioProject.dbo.Nashvillehousing
----------------Standardize Date Format-----------------------------
SELECT SalesDateConverted, CONVERT(DATE,SaleDate)
FROM PortafolioProject.dbo.Nashvillehousing

UPDATE Nashvillehousing
SET SaleDate = CONVERT(DATE,SaleDate)

ALTER TABLE Nashvillehousing
ADD SalesDateConverted DATE;

UPDATE Nashvillehousing
SET SalesDateConverted = CONVERT(DATE,SaleDate)

------------------Populate Property Address data

SELECT *
FROM PortafolioProject.dbo.Nashvillehousing
--WHERE PropertyAddress is null
ORDER BY ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortafolioProject.dbo.Nashvillehousing a
JOIN PortafolioProject.dbo.Nashvillehousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortafolioProject.dbo.Nashvillehousing a
JOIN PortafolioProject.dbo.Nashvillehousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

------Breaking out Adress Into Indi**vidual Colums

SELECT PropertyAddress
FROM PortafolioProject.dbo.Nashvillehousing
--WHERE PropertyAddress is null
--ORDER BY ParcelID

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) AS address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) AS address
FROM PortafolioProject.dbo.Nashvillehousing

ALTER TABLE Nashvillehousing
ADD PropertySplitaddress NVARCHAR(255);

UPDATE Nashvillehousing
SET PropertySplitaddress= SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE Nashvillehousing
ADD PropertySplitcityy NVARCHAR(255);

UPDATE Nashvillehousing
SET PropertySplitCityy = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))

SELECT *
FROM PortafolioProject.dbo.Nashvillehousing

SELECT
PARSENAME(REPLACE(OwnerAddress,',','.'), 3)
,PARSENAME(REPLACE(OwnerAddress,',','.'), 2)
,PARSENAME(REPLACE(OwnerAddress,',','.'), 1)
FROM PortafolioProject.dbo.Nashvillehousing





ALTER TABLE Nashvillehousing
ADD OwnerSplitaddress NVARCHAR(255);

UPDATE Nashvillehousing
SET PropertySplitaddress= SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE Nashvillehousing
ADD OwnerSplitcity NVARCHAR(255);

UPDATE Nashvillehousing
SET OwnerSplitcity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))
ALTER TABLE Nashvillehousing
ADD PropertySplitaddress NVARCHAR(255);

--Change Y and N to Yes and No in 'Sold as vacant'

SELECT DISTINCT (SoldAsVacant), COUNT(SoldAsVacant)
FROM PortafolioProject.dbo.Nashvillehousing
GROUP BY SoldAsVacant
ORDER BY 2

--CHECKING QUERY
SELECT SoldAsVacant
, CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END AS Newsold
FROM PortafolioProject.dbo.Nashvillehousing

------CHANGING DATA
UPDATE PortafolioProject.dbo.Nashvillehousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END

---REMOVE DUPLICATES

WITH RownumCTE AS (
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

FROM PortafolioProject.dbo.Nashvillehousing
--ORDER BY ParcelID
)

DELETE
FROM RownumCTE
WHERE row_num > 1


--DELETE UNUSED COLUMNS

SELECT *
FROM PortafolioProject.dbo.Nashvillehousing

ALTER TABLE PortafolioProject.dbo.Nashvillehousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate