Select * from [Nashville Housing]

----standardize date format--------

select saledateconverted,CONVERT(date,saledate) 
from [Nashville Housing]

update [Nashville Housing]
set saledate=CONVERT(date,saledate)

alter table [Nashville housing]
add saledateconverted date

update [Nashville Housing]
set saledateconverted=CONVERT(date,saledate)

------ Populate Property Address data

select * from [Nashville Housing] 
where PropertyAddress is null

select * from [Nashville Housing] 
--where PropertyAddress is null
order by ParcelID

select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress,ISNULL(a.propertyaddress,b.PropertyAddress)
from [Nashville Housing] a
join [Nashville Housing] b on
a.ParcelID=b.ParcelID 
and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null

update a
set PropertyAddress=ISNULL(a.propertyaddress,b.PropertyAddress)
from [Nashville Housing] a
join [Nashville Housing] b on
a.ParcelID=b.ParcelID 
and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null

----- Breaking out Address into Individual Columns (Address, City, State)-----
select propertyaddress from [Nashville Housing]

select SUBSTRING(propertyaddress ,1,CHARINDEX(',',propertyaddress)-1) as address,
SUBSTRING(propertyaddress,CHARINDEX(',',propertyaddress)+1,LEN(propertyaddress)) as address 
from [Nashville Housing]

alter table [Nashville housing]
add propertysplitaddress nvarchar(255)

update [Nashville Housing]
set propertysplitaddress= SUBSTRING(propertyaddress ,1,CHARINDEX(',',propertyaddress)-1) 

alter table [Nashville housing]
add propertysplitcity nvarchar(255)

update [Nashville Housing]
set propertysplitcity= SUBSTRING(propertyaddress,CHARINDEX(',',propertyaddress)+1,LEN(propertyaddress))

select * from [Nashville Housing]

select owneraddress from [Nashville Housing]

Select
PARSENAME(replace(OwnerAddress, ',', '.') , 3)
,PARSENAME(replace(OwnerAddress, ',', '.') , 2)
,PARSENAME(replace(OwnerAddress, ',', '.') , 1)
From [Nashville Housing]

alter table [Nashville housing]
add ownersplitaddress nvarchar(255)

update [Nashville Housing]
set ownersplitaddress= PARSENAME(replace(OwnerAddress, ',', '.') , 3)

alter table [Nashville housing]
add ownersplitcity nvarchar(255)

update [Nashville Housing]
set ownersplitcity= PARSENAME(replace(OwnerAddress, ',', '.') , 2)

alter table [Nashville housing]
add ownersplitstate nvarchar(255)

update [Nashville Housing]
set ownersplitstate= PARSENAME(replace(OwnerAddress, ',', '.') , 1)

select * from [Nashville Housing]

-- Change Y and N to Yes and No in "Sold as Vacant" field--
select distinct(soldasvacant),COUNT(SoldAsVacant) 
from [Nashville Housing]
group by SoldAsVacant
order by 2 

select soldasvacant,
case 
when soldasvacant ='y' then 'Yes'
when soldasvacant ='N' then 'No'
else soldasvacant
End
from [Nashville Housing]

update [Nashville Housing]
set SoldAsVacant= case 
when soldasvacant ='y' then 'Yes'
when soldasvacant ='N' then 'No'
else soldasvacant
End

---remove duplicates--
with rownumcte as(
select *, row_number() 
over( partition by parcelid, propertyaddress, saleprice, saledate, legalreference
order by uniqueid) row_num from [Nashville Housing]
) 
delete  from rownumcte where row_num>1 
----------checking if the duplicates are removed or not-----

with rownumcte as(
select *,
row_number() 
over( partition by parcelid, propertyaddress, saleprice, saledate, legalreference
order by uniqueid) row_num from [Nashville Housing]
) 
select *  from rownumcte where row_num>1 

-----Delete Unused Columns-----

select * from [Nashville Housing]

alter table [Nashville Housing]
drop column owneraddress,taxdistrict,propertyaddress

alter table [Nashville Housing]
drop column saledate



