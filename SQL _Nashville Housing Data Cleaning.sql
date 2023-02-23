/*

Cleaning Data in SQL Queries

*/

SELECT *
FROM PortfolioProject.dbo.NashvilleHousing


-- Standardize Data Format
-- Remove the time from SaleDate to make date neat
-- Option 1. but it's not effective today
--SELECT SaleDate, CONVERT(date, SaleDate)
--FROM PortfolioProject.dbo.NashvilleHousing

--Update NashvilleHousing
--SET SaleDate = CONVERT(date, SaleDate)

--Option 2. use alter table to create col SaleDateConverted
ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = CONVERT(date, SaleDate)

SELECT SaleDateConverted, CONVERT(date, SaleDate)
FROM PortfolioProject.dbo.NashvilleHousing


-- Populate Property Address Data
-- Deal with the null value in PropertyAddress
SELECT *
FROM PortfolioProject.dbo.NashvilleHousing
--WHERE PropertyAddress is null
ORDER BY ParcelID

-- Found that if two house have the same ParcelID (with different UniqueID) than they will have the same PropertyAddress
-- Self join the table so that if the two ParcelID matches then they'll have same PropertyAddress
SELECT p1.ParcelID, p1.PropertyAddress, p2.ParcelID, p2.PropertyAddress, ISNULL(p1.PropertyAddress, p2.PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHousing p1
JOIN PortfolioProject.dbo.NashvilleHousing p2
	ON p1.ParcelID = p2.ParcelID
	AND p1.[UniqueID ] <> p2.[UniqueID ]
WHERE p1.PropertyAddress is null

-- update the SQL database
UPDATE p1
SET PropertyAddress = ISNULL(p1.PropertyAddress, p2.PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHousing p1
JOIN PortfolioProject.dbo.NashvilleHousing p2
	ON p1.ParcelID = p2.ParcelID
	AND p1.[UniqueID ] <> p2.[UniqueID ]
WHERE p1.PropertyAddress is null


-- Breaking out Address into Individual Columns (Address, City, State )
SELECT PropertyAddress
FROM PortfolioProject.dbo.NashvilleHousing

-- Use SUBSTRING & CHARINDEX function to seperate the address from city
SELECT
	SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address
	,SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) AS City
FROM PortfolioProject.dbo.NashvilleHousing

-- use ALTER TABLE to add the new columns
-- Add new address col
ALTER TABLE NashvilleHousing
ADD PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
SET PropertySplitAddress = 	SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

--Add new City col
ALTER TABLE NashvilleHousing
ADD PropertySplitCity Nvarchar(255);

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))

-- Double check if the new cols are added
-- Should have PropertySplitAddress & PropertySplitCity at the end of the table
SELECT *
FROM PortfolioProject.dbo.NashvilleHousing


-- Split the col "OwnerAddress" in different way
-- PARSENAME seperate and return a specific part of the string based on its position, by defult it's seperate by (.)
SELECT OwnerAddress
FROM PortfolioProject.dbo.NashvilleHousing

SELECT 
PARSENAME(REPLACE(OwnerAddress, ',', '.'),3)
, PARSENAME(REPLACE(OwnerAddress, ',', '.'),2)
, PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)
FROM PortfolioProject.dbo.NashvilleHousing

--Add OwnerAddress's address
ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'),3)


-- Add OwnerAddress's City
ALTER TABLE NashvilleHousing
ADD OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'),2)

-- Add OwnerAddress's States
ALTER TABLE NashvilleHousing
ADD OwnerSplitState Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)

SELECT *
FROM PortfolioProject.dbo.NashvilleHousing


-- Change the Y & N -> Yes & No in the col "SoldAsVacent"
SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant) 
FROM PortfolioProject.dbo.NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

--Found that we have Y:52, N:399 and change it all to Yes & No
SELECT 
SoldAsVacant
,	CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END
FROM PortfolioProject.dbo.NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END


-- Romove Duplicates
-- Create CTE table to see the duplicate rows and delete them
WITH RowNumCTE AS (
SELECT *,	
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
		     PropertyAddress,
		     SalePrice, 
		     SaleDate,
		     LegalReference
	ORDER BY UniqueID
			) row_num
FROM PortfolioProject.dbo.NashvilleHousing
)
DELETE 
FROM RowNumCTE
WHERE row_num>1



-- Delete unused col
SELECT *
FROM PortfolioProject.dbo.NashvilleHousing

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate 
