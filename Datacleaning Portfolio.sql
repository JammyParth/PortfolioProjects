

--Cleaning data in sql queries

Select * from PortfolioProject.dbo.Nashvillehousing


-- Standardize data format---------------------------------------------------------------------------


ALTER TABLE nashvillehousing
Add saledateconverted date;

update Nashvillehousing
SET	saledateconverted = CONVERT(Date, SaleDate)

Select saledateconverted
from PortfolioProject.dbo.Nashvillehousing


--populate Property address data-------------------------------------------------------------------------------------------------

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.propertyaddress, b.PropertyAddress)
from PortfolioProject.dbo.Nashvillehousing a
JOIN PortfolioProject.dbo.Nashvillehousing b
	on a.ParcelID = b.ParcelID AND
		a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null


update a
SET a.propertyaddress = ISNULL(a.Propertyaddress, b.PropertyAddress)
from PortfolioProject.dbo.Nashvillehousing a
JOIN PortfolioProject.dbo.Nashvillehousing b
	on a.ParcelID = b.ParcelID AND
		a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null



-- Breaking out Address into individual columns (Address, City, State)-----------------------------------------------------------


Select PropertyAddress
from PortfolioProject.dbo.Nashvillehousing



Select 
SUBSTRING(propertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address,
SUBSTRING(propertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(propertyaddress)) as Address

from PortfolioProject.dbo.Nashvillehousing


ALTER TABLE portfolioproject.dbo.nashvillehousing
Add PropertySplitAddress nvarchar(255);

update portfolioproject.dbo.nashvillehousing
SET	PropertySplitAddress = SUBSTRING(propertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

Alter table portfolioproject.dbo.nashvillehousing
add propertySplitCity nvarchar(255);


update portfolioproject.dbo.nashvillehousing
SET propertySplitCity = SUBSTRING(propertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(propertyaddress))


Select * 
from portfolioproject.dbo.nashvillehousing





--Breaking out OwnerAddress into individual columns State, City, Address-----------------------------------------------------


Select OwnerAddress 
from portfolioproject.dbo.nashvillehousing


Select
PARSENAME(REPLACE(owneraddress, ',', '.') , 3),
PARSENAME(REPLACE(owneraddress, ',', '.') , 2),
PARSENAME(REPLACE(owneraddress, ',', '.') , 1)
from portfolioproject.dbo.nashvillehousing



ALTER TABLE portfolioproject.dbo.nashvillehousing
Add ownerSplitAddress nvarchar(255);

update portfolioproject.dbo.nashvillehousing
SET	ownerSplitAddress = PARSENAME(REPLACE(owneraddress, ',', '.') , 3)

Alter table portfolioproject.dbo.nashvillehousing
add ownerSplitCity nvarchar(255);


update portfolioproject.dbo.nashvillehousing
SET ownerSplitCity = PARSENAME(REPLACE(owneraddress, ',', '.') , 2)


Alter table portfolioproject.dbo.nashvillehousing
add ownerSplitstate nvarchar(255);

update portfolioproject.dbo.nashvillehousing
SET  ownerSplitstate = PARSENAME(REPLACE(owneraddress, ',', '.') , 1)



Select * from PortfolioProject.dbo.Nashvillehousing


--Change Y and N to Yes and No in "Sold as Vacant" field--------------------------------------------------------------



Select Distinct(SoldAsVacant), COUNT(SoldAsVacant)
from portfolioproject.dbo.nashvillehousing
group by SoldAsVacant
order by 2



Select SoldAsVacant, 
	CASE When SoldAsVacant = 'Y' then 'Yes'
		 When SoldAsVacant = 'N' then 'No'
		 Else SoldAsVacant
	END
from portfolioproject.dbo.nashvillehousing



Update portfolioproject.dbo.nashvillehousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' then 'Yes'
						When SoldAsVacant = 'N' then 'No'
					Else SoldAsVacant
					END


-- Remove Duplicates------------------------------------------------------------------------------------------------

WITH row_numCTE AS(
Select *, 
		ROW_NUMBER() OVER (Partition by parcelID, PropertyAddress, SalePrice, SaleDate,LegalReference
							Order by UniqueID) row_num


from portfolioproject.dbo.nashvillehousing


)

DELETE 
from row_numCTE
where row_num > 1
--order by PropertyAddress






--Delete unused columns--------------------------------------------------------------------------------------------------


Select * from portfolioproject.dbo.nashvillehousing


ALTER TABLE 
portfolioproject.dbo.nashvillehousing
DROP column OwnerAddress, Taxdistrict, PropertyAddress, SaleDate
 

ALTER TABLE 
portfolioproject.dbo.nashvillehousing
DROP column SaleDate




--Changing the column positions----------------------------------------------------------------------------------------------

CREATE TABLE Portfolioproject.dbo.NashVilleHousing_Cleaned(
		UniqueID float,
		ParcelID nvarchar(255),
		LandUse nvarchar(255),
		SalePrice float,
		SaleDate date,
		PropertyAddress nvarchar(255),
		PropertyCity nvarchar(255),
		LegalReference nvarchar(255),
		SoldAsVacant nvarchar(255),
		OwnerName nvarchar(255),
		OwnerAddress nvarchar(255),
		OwnerCity nvarchar(255),
		OwnerState nvarchar(255),
		Acreage float,
		LandValue float,
		BuildingValue float, 
		TotalValue float,
		YearBuilt float, 
		Bedrooms float,
		FullBath float,
		HalfBath float,
		)


INSERT INTO Portfolioproject.dbo.NashVilleHousing_Cleaned
Select  UniqueID,
		ParcelID,
		LandUse,
		SalePrice,
		saledateconverted,
		PropertySplitAddress,
		propertySplitCity,
		LegalReference,
		SoldAsVacant,
		OwnerName,
		ownerSplitAddress,
		ownerSplitCity,
		ownerSplitstate,
		Acreage,
		LandValue,
		BuildingValue,
		TotalValue,
		YearBuilt,
		Bedrooms,
		FullBath,
		HalfBath

from portfolioproject.dbo.nashvillehousing;


Select * from Portfolioproject.dbo.NashVilleHousing_Cleaned

