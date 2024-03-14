--CLEANING DATA IN SQL QUERIES 
SELECT*
FROM PortfolioProjects..NashvilleHousing



-----------------------------------------------------------------------------------------------------------
--STANDARDIZE DATE FORMAT

SELECT SaleDateConverted, CONVERT(DATE,SaleDate)
FROM PortfolioProjects..NashvilleHousing

UPDATE NashvilleHousing
SET SaleDate= CONVERT(DATE,SaleDate)

ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date;

UPDATE NashvilleHousing
SET SaleDateConverted= CONVERT(DATE,SaleDate)



---------------------------------------------------------------------------------------------------------------------------
--POPULATE PROPERTY ADDRESS DATA

SELECT *
FROM PortfolioProjects..NashvilleHousing
--WHERE PropertyAddress IS NULL
ORDER BY ParcelID


SELECT a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM PortfolioProjects..NashvilleHousing a
JOIN PortfolioProjects..NashvilleHousing b
ON a.ParcelID=b.ParcelID
AND a.[UniqueID ]<>b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

UPDATE a 
SET PropertyAddress=ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM PortfolioProjects..NashvilleHousing a
JOIN PortfolioProjects..NashvilleHousing b
ON a.ParcelID=b.ParcelID
AND a.[UniqueID ]<>b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

----------------------------------------------------------------------------------------------------------------------------------------------------------------
--BREAKING OUT ADDRESS INTO INDIVIDUAL COLUMNS(ADDRESS,CITY,STATE)

SELECt PropertyAddress
FROM PortfolioProjects..NashvilleHousing
--WHERE PropertyAddress IS NULL

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) AS Address
--CHARINDEX(',', PropertyAddress)
FROM PortfolioProjects..NashvilleHousing

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress NVARCHAR(255);;

UPDATE NashvilleHousing
SET PropertySplitAddress= SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE NashvilleHousing
ADD PropertySplitCity NVARCHAR(255);

UPDATE NashvilleHousing
SET PropertySplitCity= SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))


SELECT*
FROM PortfolioProjects..NashvilleHousing


SELECT OwnerAddress
FROM PortfolioProjects..NashvilleHousing

SELECT 
PARSENAME(REPLACE(OwnerAddress, ',', '.') ,3) AS Address,
PARSENAME(REPLACE(OwnerAddress, ',', '.') ,2) AS City,
PARSENAME(REPLACE(OwnerAddress, ',', '.') ,1) AS State
FROM PortfolioProjects..NashvilleHousing

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitAddress= PARSENAME(REPLACE(OwnerAddress, ',', '.') ,3) 

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitCity= PARSENAME(REPLACE(OwnerAddress, ',', '.') ,2) 

ALTER TABLE NashvilleHousing
ADD PropertySplitState NVARCHAR(255);

UPDATE NashvilleHousing
SET PropertySplitState= PARSENAME(REPLACE(OwnerAddress, ',', '.') ,1) 


SELECT*
FROM PortfolioProjects..NashvilleHousing


-----------------------------------------------------------------------------------------------------------------------------------------------------
--CHANGE Y AND N TO YES AND NO IN "SOLD AS VACANT" FIELD"


SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM PortfolioProjects..NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant,
CASE
WHEN SoldAsVacant='Y' THEN 'YES'
WHEN SoldAsVacant='N' THEN 'NO'
ELSE SoldAsVacant
END
FROM PortfolioProjects..NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant=CASE
WHEN SoldAsVacant='Y' THEN 'YES'
WHEN SoldAsVacant='N' THEN 'NO'
ELSE SoldAsVacant
END


----------------------------------------------------------------------------------------------------------------------------------------------------
--REMOVE DUPLICATION
WITH RowNumCTE AS(
SELECT*,
ROW_NUMBER() OVER(
PARTITION BY ParcelID,
             PropertyAddress,
             SaleDate,
	         LegalReference
			 ORDER BY 
			 UniqueID
			 )row_num
FROM PortfolioProjects..NashvilleHousing
--ORDER BY ParcelID
)
SELECT*
FROM RowNumCTE
WHERE row_num>1 
ORDER BY PropertyAddress


SELECT*
FROM PortfolioProjects..NashvilleHousing


-------------------------------------------------------------------------------------------------------------------------------------------------------
--DELETE UNUSUAL COLUMNS

SELECT*
FROM PortfolioProjects..NashvilleHousing

ALTER TABLE PortfolioProjects..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict,PropertyAddress

ALTER TABLE PortfolioProjects..NashvilleHousing
DROP COLUMN SaleDate