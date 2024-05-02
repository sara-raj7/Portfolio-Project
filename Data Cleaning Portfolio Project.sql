
---------------------------------------------------------------------------------------------------------------------------

-- Data Cleaning with SQL Queries

Select *
From PortfolioProject.dbo.NashvilleHousing
---------------------------------------------------------------------------------------------------------------------------

-- Standardize the date format

Alter Table PortfolioProject.dbo.NashvilleHousing
Add SaleDateConverted Date;

Update PortfolioProject.dbo.NashvilleHousing
Set SaleDateConverted = Convert(Date, SaleDate)

Select SaleDate, SaleDateConverted
From PortfolioProject.dbo.NashvilleHousing

-------------------------------------------------------------------------------------------------------------------------

-- Filling the NUll values in the property address using self join

Select a.PropertyAddress, b.PropertyAddress , ISNULL(a.PropertyAddress , b.PropertyAddress)
From PortfolioProject..NashvilleHousing a
Join PortfolioProject..NashvilleHousing b
on a.ParcelID = b. ParcelID 
AND a.UniqueID <> b.UniqueID
where a.PropertyAddress is null

Update a
Set PropertyAddress = ISNULL(a.PropertyAddress , b.PropertyAddress)
From PortfolioProject..NashvilleHousing a
Join PortfolioProject..NashvilleHousing b
on a.ParcelID = b. ParcelID 
AND a.UniqueID <> b.UniqueID
where a.PropertyAddress is null

-------------------------------------------------------------------------------------------------------------------------

-- Breaking down the Property address and Owner Address into the columns of Address, City , State

-- On Property Address

Select PropertyAddress, 
substring(PropertyAddress, 1, charindex(',', PropertyAddress) -1) as Address,
substring(PropertyAddress,charindex(',', PropertyAddress) +1 , len(PropertyAddress)) as City
From PortfolioProject..NashvilleHousing

Alter Table PortfolioProject.dbo.NashvilleHousing
Add PropertySplitAddress nvarchar(255);

Update PortfolioProject.dbo.NashvilleHousing
Set PropertySplitAddress = substring(PropertyAddress, 1, charindex(',', PropertyAddress) -1)

Alter Table PortfolioProject.dbo.NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update PortfolioProject.dbo.NashvilleHousing
Set PropertySplitCity = substring(PropertyAddress,charindex(',', PropertyAddress) +1 , len(PropertyAddress))

-- On Owner Address using PARSENAME

Select OwnerAddress ,
Parsename(Replace(OwnerAddress,',','.'),3),
Parsename(Replace(OwnerAddress,',','.'),2),
Parsename(Replace(OwnerAddress,',','.'),1)
From PortfolioProject..NashvilleHousing

Alter Table PortfolioProject.dbo.NashvilleHousing
Add OwnerSplitAddress nvarchar(255);

Update PortfolioProject.dbo.NashvilleHousing
Set OwnerSplitAddress = Parsename(Replace(OwnerAddress,',','.'),3)

Alter Table PortfolioProject.dbo.NashvilleHousing
Add OwnerSplitCity nvarchar(255);

Update PortfolioProject.dbo.NashvilleHousing
Set OwnerSplitCity = Parsename(Replace(OwnerAddress,',','.'),2)

Alter Table PortfolioProject.dbo.NashvilleHousing
Add OwnerSplitState nvarchar(255);

Update PortfolioProject.dbo.NashvilleHousing
Set OwnerSplitState = Parsename(Replace(OwnerAddress,',','.'),1)

-- Checking the New Columns

Select * 
From PortfolioProject.dbo.NashvilleHousing

---------------------------------------------------------------------------------------------------------------------------

-- Changing Y and N to Yes and No in SoldAsVacant column

Select SoldAsVacant, count(SoldAsVacant)
From PortfolioProject.dbo.NashvilleHousing
Group By SoldAsVacant

Select SoldAsVacant,
case when SoldAsVacant = 'Y' Then 'Yes'
	 when SoldAsVacant = 'N' Then 'No'
	 Else SoldAsVacant
	 End
From PortfolioProject.dbo.NashvilleHousing

Update PortfolioProject.dbo.NashvilleHousing
Set SoldAsVacant = case when SoldAsVacant = 'Y' Then 'Yes'
	 when SoldAsVacant = 'N' Then 'No'
	 Else SoldAsVacant
	 End


-----------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

With RowNumCTE as
(Select *,
	 Row_NUMBER() over(
	 partition by ParcelID,
				  PropertyAddress,
				  SalePrice,
			      SaleDate,
			      LegalReference
			      Order by 
					UniqueID
					) row_num
From PortfolioProject.dbo.NashvilleHousing
)
Delete
From RowNumCTE
where row_num>1

-------------------------------------------------------------------------------------------------------------------------

-- Droping Unwanted Columns

Alter Table PortfolioProject.dbo.NashvilleHousing
Drop Column PropertyAddress, OwnerAddress, TaxDistrict

Select * 
From PortfolioProject.dbo.NashvilleHousing
