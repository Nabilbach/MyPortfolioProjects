/*

Cleaning Data in SQL Queries

*/

--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format
Select SaleDateConverted, CONVERT(Date,SaleDate)
FROM [ProtfolioProject].[dbo].[NashvilleHousing]

Update [ProtfolioProject].[dbo].[NashvilleHousing]
Set SaleDate = CONVERT(Date,SaleDate)

Alter Table NashvilleHousing

Add SaleDateConverted Date;

Update [ProtfolioProject].[dbo].[NashvilleHousing]

Set saleDateConverted = CONVERT(Date,SaleDate)


 --------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data 

Select *
FROM [ProtfolioProject].[dbo].[NashvilleHousing]
--Where PropertyAddress is null
Order by ParcelID
Select A.ParcelID,A.PropertyAddress,B.ParcelID, B.PropertyAddress, ISNULL(A.PropertyAddress,B.PropertyAddress)
From [ProtfolioProject].[dbo].[NashvilleHousing] A
Join [ProtfolioProject].[dbo].[NashvilleHousing] B
	on A.ParcelID = B.ParcelID
	AND A.[UniqueID ] <> B.[UniqueID ]
Where A.PropertyAddress is Null




Update  A
Set PropertyAddress = ISNULL(A.PropertyAddress, B.PropertyAddress)
from [ProtfolioProject].[dbo].[NashvilleHousing] A
Join [ProtfolioProject].[dbo].[NashvilleHousing] B
	on A.ParcelID = B.ParcelID
	AND A.[UniqueID ] <> B.[UniqueID ]
Where A.PropertyAddress is Null






--------------------------------------------------------------------------------------------------------------------------
--- Show duplicate Values
Select ParcelID, Count(*)
FROM [ProtfolioProject].[dbo].[NashvilleHousing]
Group by ParcelID
Having count(*) > 1

SELECT *
FROM [ProtfolioProject].[dbo].[NashvilleHousing]
WHERE ParcelID IN (
    SELECT ParcelID
    FROM [ProtfolioProject].[dbo].[NashvilleHousing]
    GROUP BY ParcelID
    HAVING COUNT(*) > 1
);

-- Breaking out Address into Individual Columns (Address, City, State)
SELECT 
    LEFT(OwnerAddress, CHARINDEX(',', OwnerAddress) - 1) AS Address,
    SUBSTRING(OwnerAddress, CHARINDEX(',', OwnerAddress) + 2, CHARINDEX(',', OwnerAddress, CHARINDEX(',', OwnerAddress) + 1) - CHARINDEX(',', OwnerAddress) - 2) AS City,
	RIGHT(OwnerAddress, LEN(OwnerAddress) - CHARINDEX(',', OwnerAddress, CHARINDEX(',', OwnerAddress) + 1)) AS State
FROM [ProtfolioProject].[dbo].[NashvilleHousing];

Select 

SUBSTRING(PropertyAddress,1,CHARINDEX(',', PropertyAddress) - 1) AS Address
,SUBSTRING(PropertyAddress,CHARINDEX(',', PropertyAddress) + 1,LEN(PropertyAddress)) AS City
from [ProtfolioProject].[dbo].[NashvilleHousing]

Alter Table [ProtfolioProject].[dbo].[NashvilleHousing]
Add PropertySplitAddress Nvarchar(255);

Update [ProtfolioProject].[dbo].[NashvilleHousing]

Set PropertySplitAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',', PropertyAddress) - 1)

Alter Table [ProtfolioProject].[dbo].[NashvilleHousing]

Add PropertySplitCity Nvarchar(255);


Update [ProtfolioProject].[dbo].[NashvilleHousing]

Set PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',', PropertyAddress) + 1,LEN(PropertyAddress))

Select*
From [ProtfolioProject].[dbo].[NashvilleHousing]
-- Split the Owner Address

-- OwnerSplitAddress
Alter Table [ProtfolioProject].[dbo].[NashvilleHousing]
Add OwnerSplitAddress Nvarchar(255);
Update [ProtfolioProject].[dbo].[NashvilleHousing]
Set OwnerSplitAddress = LEFT(OwnerAddress, CHARINDEX(',', OwnerAddress) - 1)

--OwnerSplitCity
Alter Table [ProtfolioProject].[dbo].[NashvilleHousing]
Add OwnerSplitCity Nvarchar(255);
Update [ProtfolioProject].[dbo].[NashvilleHousing]
Set OwnerSplitCity = SUBSTRING(OwnerAddress, CHARINDEX(',', OwnerAddress) + 2, CHARINDEX(',', OwnerAddress, CHARINDEX(',', OwnerAddress) + 1) - CHARINDEX(',', OwnerAddress) - 2)

---OwnerSplitState

Alter Table [ProtfolioProject].[dbo].[NashvilleHousing]
Add OwnerSplitState Nvarchar(255);
Update [ProtfolioProject].[dbo].[NashvilleHousing]
Set OwnerSplitState = RIGHT(OwnerAddress, LEN(OwnerAddress) - CHARINDEX(',', OwnerAddress, CHARINDEX(',', OwnerAddress) + 1))

Select*
From  [ProtfolioProject].[dbo].[NashvilleHousing]
--- Another way to split OwnerAddress

Select
PARSENAME(REPLACE(OwnerAddress,',','.'),1) AS State
,PARSENAME(REPLACE(OwnerAddress,',','.'),2) AS City
,PARSENAME(REPLACE(OwnerAddress,',','.'),3) AS OwnerAdress
From  [ProtfolioProject].[dbo].[NashvilleHousing]





--------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field
Select Distinct(SoldAsVacant),Count(SoldAsVacant)
From [ProtfolioProject].[dbo].[NashvilleHousing]
Group by SoldAsVacant
Order by 2

Select SoldAsVacant,
CASE When SoldAsVacant = 'Y' Then 'Yes'
	 When SoldAsVacant = 'N' Then 'No'
	 Else SoldAsVacant
	 END
From [ProtfolioProject].[dbo].[NashvilleHousing]

Update [ProtfolioProject].[dbo].[NashvilleHousing]
SET SoldAsVacant = CASE
	 When SoldAsVacant = 'Y' Then 'Yes'
	 When SoldAsVacant = 'N' Then 'No'
	 Else SoldAsVacant
	 END
-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates
Select*



with RowNumCTE AS (
	Select*,
			ROW_NUMBER() Over (
			Partition by ParcelID,
						 PropertyAddress,
						 SalePrice,
						 SaleDate,
						 LegalReference
						 Order by
						       UniqueID ) row_num

From [ProtfolioProject].[dbo].[NashvilleHousing]
)
Select*
From RowNumCTE
Where row_num > 1


---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns
Select*
From [ProtfolioProject].[dbo].[NashvilleHousing]

ALTER TABLE [ProtfolioProject].[dbo].[NashvilleHousing]
DROP COLUMN OwnerAddress,
			TaxDistrict,
			OwnerSplitAddress,
			OwnerSplitCity,
			OwnerSplitState












-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------

--- Importing Data using OPENROWSET and BULK INSERT	

--  More advanced and looks cooler, but have to configure server appropriately to do correctly
--  Wanted to provide this in case you wanted to try it


--sp_configure 'show advanced options', 1;
--RECONFIGURE;
--GO
--sp_configure 'Ad Hoc Distributed Queries', 1;
--RECONFIGURE;
--GO


--USE PortfolioProject 

--GO 

--EXEC master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'AllowInProcess', 1 

--GO 

--EXEC master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'DynamicParameters', 1 

--GO 


---- Using BULK INSERT

--USE PortfolioProject;
--GO
--BULK INSERT nashvilleHousing FROM 'C:\Temp\SQL Server Management Studio\Nashville Housing Data for Data Cleaning Project.csv'
--   WITH (
--      FIELDTERMINATOR = ',',
--      ROWTERMINATOR = '\n'
--);
--GO


---- Using OPENROWSET
--USE PortfolioProject;
--GO
--SELECT * INTO nashvilleHousing
--FROM OPENROWSET('Microsoft.ACE.OLEDB.12.0',
--    'Excel 12.0; Database=C:\Users\alexf\OneDrive\Documents\SQL Server Management Studio\Nashville Housing Data for Data Cleaning Project.csv', [Sheet1$]);
--GO


















