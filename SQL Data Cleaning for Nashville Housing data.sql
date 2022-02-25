/*
Cleaning Data in SQL Queries
*/

SELECT TOP 100* FROM NashvilleHousing
--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format
-- Adding a new column SaleDateConverted and updating the SaleDate values in date format

ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(date, SaleDate)

SELECT SaleDateConverted, CONVERT(date, SaleDate)
FROM NashvilleHousing

--------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data

Select *
From NashvilleHousing
Where PropertyAddress is null


SELECT NH1.ParcelID, NH1.PropertyAddress, NH2.ParcelID, NH2.PropertyAddress, ISNULL(NH1.PropertyAddress,NH2.PropertyAddress)
FROM NashvilleHousing NH1
JOIN NashvilleHousing NH2
	ON NH1.ParcelID=NH2.ParcelID
	AND NH1.[UniqueID ] <> NH2.[UniqueID ]
WHERE NH1.PropertyAddress IS NULL

-- Populating the NULL PropertyAddress to correct value with the same Parcel ID's address but different UniqueID

UPDATE NH1
SET PropertyAddress = ISNULL(NH1.PropertyAddress,NH2.PropertyAddress)
FROM NashvilleHousing NH1
JOIN NashvilleHousing NH2
	ON NH1.ParcelID=NH2.ParcelID
	AND NH1.[UniqueID ] <> NH2.[UniqueID ]
WHERE NH1.PropertyAddress IS NULL


--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)

SELECT PropertyAddress
FROM NashvilleHousing

SELECT SUBSTRING(PropertyAddress, 1 , CHARINDEX(',', PropertyAddress) -1) AS ADDRESS,          -- Splitting the correct address before ','
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 ,LEN(PropertyAddress)) AS CITY   -- Splitting the correct city after ','
FROM NashvilleHousing

--Splitting the PropertyAddress to correct Address and City

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress NVARCHAR(255)

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)


ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(255)

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , LEN(PropertyAddress))

SELECT * FROM NashvilleHousing


SELECT OwnerAddress FROM NashvilleHousing

SELECT PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3) AS 'Address',
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2) AS 'City',
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1) AS 'State'
FROM NashvilleHousing


--Splitting the OwnerAddress to correct Address, City and State

ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255)

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255)

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)



ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255)

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)

SELECT * FROM NashvilleHousing


--------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field

SELECT DISTINCT SoldAsVacant, COUNT(SoldAsVacant) FROM NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2 DESC

SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END
FROM NashvilleHousing
WHERE SoldAsVacant IN ('Y' ,'N' )

UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END


-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

-- Storing all the duplicate records in a seperate temp table and not performing hard delete from the original table

DROP TABLE IF EXISTS #DuplicateRecords
CREATE TABLE #DuplicateRecords
(
UniqueID float,
ParcelID NVARCHAR(255),
PropertyAddress NVARCHAR(255),
SalePrice FLOAT,
SaleDate DATETIME,
LegalReference NVARCHAR(255),
Row_num INT
)
 
WITH RowNumCTE (UniqueID, ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference, row_num) AS
(
SELECT UniqueID, ParcelID,PropertyAddress, SalePrice, SaleDate, LegalReference,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) AS 'row_num'

FROM NashvilleHousing
)
INSERT INTO #DuplicateRecords (UniqueID, ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference, Row_num) 
SELECT UniqueID, ParcelID, PropertyAddress,SalePrice,SaleDate,LegalReference, Row_num  FROM RowNumCTE
WHERE row_num > 1
ORDER BY ParcelID

SELECT * FROM #DuplicateRecords ORDER BY ParcelID
SELECT * FROM NashvilleHousing WHERE ParcelID='081 02 0 144.00' --Checking the duplicate record for a single ParcelID


---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns

Select *
From NashvilleHousing

ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate
