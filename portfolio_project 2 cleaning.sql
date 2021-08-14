select *
from Portfolio_project..Housing_data


----------------------------------------------Standarize Salaes Date------------------------------------------

select SaleDateconverted,CAST(saledate as date) as new_saledate
from Portfolio_project..Housing_data

--It doesen't work like this 
update Portfolio_project..Housing_data
set SaleDate=CAST(saledate as date) 

--Altering table and creating new coloumn

alter table housing_data
add SaleDateConverted date

--Now using update function to add new Date format in new coloumn

update Portfolio_project..Housing_data
set SaleDateConverted=CAST(saledate as date) 


------------------------------------Populate Property Address Data---------------------------------

select *
from Portfolio_project..Housing_data
--where PropertyAddress is null

---Property address cannot be null and it is dony by mistake of data entry person during feeding of data
--Solution- With the refernce of ParcelID we will match the Property address and fill the null places

--Using self join and very important isnull function to fill null spaces

select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress,ISNULL(a.PropertyAddress,b.PropertyAddress)
from Portfolio_project..Housing_data a
join Portfolio_project..Housing_data b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ] --unique id is very important primary key
where a.PropertyAddress is null

--Updating the table with isnull function 

update a --Using alias to update main sheet
set PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
from Portfolio_project..Housing_data a
join Portfolio_project..Housing_data b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ] --unique id is very important primary key
where a.PropertyAddress is null

-----------------------------Splitting property address into (address,city)-------------------------------

select PropertyAddress
from Portfolio_project..Housing_data

--Use of substring 

select
SUBSTRING(propertyaddress,1,CHARINDEX(',',propertyaddress)-1) as address,  --for address , - 1 is to exit the index before ','
SUBSTRING(propertyaddress,CHARINDEX(',',PropertyAddress)+1,LEN(propertyaddress)) as City --for city , +1 is to start index after ','
from Portfolio_project..Housing_data


--Altering table and creating new coloumn

--For address

alter table housing_data
add PropertySplitAddress nvarchar(100)

update Portfolio_project..Housing_data
set PropertySplitaddress=SUBSTRING(propertyaddress,1,CHARINDEX(',',propertyaddress)-1)

--For city

alter table housing_data
add PropertySplitcity nvarchar(100)

update Portfolio_project..Housing_data
set PropertySplitcity=SUBSTRING(propertyaddress,CHARINDEX(',',PropertyAddress)+1,LEN(propertyaddress))


------------------------------------------Splitting owner addresss---------------------------------------

select OwnerAddress 
from Portfolio_project..Housing_data

---Using parsing (works only when there is de-eliminator) also it seperates everything from backwards
--Concept is to change the de-eliminator(,) into period(.)

select
PARSEname(replace(owneraddress,',','.'),3) ---for address
,PARSEname(replace(owneraddress,',','.'),2) ----for city
,PARSEname(replace(owneraddress,',','.'),1) ----for state
from Portfolio_project..Housing_data


--Altering table and creating new coloumn

--For address


alter table housing_data
add OwnerSplitaddress nvarchar(100)

update Portfolio_project..Housing_data
set OwnerSplitaddress=PARSEname(replace(owneraddress,',','.'),3)

--for city

alter table housing_data
add OwnerSplitcity nvarchar(100)

update Portfolio_project..Housing_data
set OwnerSplitcity=PARSEname(replace(owneraddress,',','.'),2)

--for state

alter table housing_data
add OwnerSplitstate nvarchar(100)

update Portfolio_project..Housing_data
set OwnerSplitstate=PARSEname(replace(owneraddress,',','.'),1)


--------------------------------Changing 'Y' and 'N' for yes and no in Sold in Vacant-----------------------------------------

select distinct(SoldAsVacant),COUNT(SoldAsVacant)
from Portfolio_project..Housing_data
group by SoldAsVacant
order by 2


select SoldAsVacant,
	case when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	else SoldAsVacant
	end
from Portfolio_project..Housing_data

--updating the values

update Portfolio_project..Housing_data
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	else SoldAsVacant
	end

----------------------------------------------------Removing Duplicates----------------------------------------------------

--creating CTE for deltion

with duplicate_row_noCTE as(
select *,
	ROW_NUMBER() over(
	partition by ParcelId,
				 landuse,
				 propertyaddress,
				 saledate,
				 saleprice,
				 legalreference
				 order by 
				 parcelid
				 ) as duplicate_row_no
from Portfolio_project..Housing_data
)
select *
from duplicate_row_noCTE
where duplicate_row_no > 1
order by PropertyAddress

--For Deletion of dupliucates but it is advised never to delete any data from the main file

--deleting with the help of CTE

with duplicate_row_noCTE as(
select *,
	ROW_NUMBER() over(
	partition by ParcelId,
				 landuse,
				 propertyaddress,
				 saledate,
				 saleprice,
				 legalreference
				 order by 
				 parcelid
				 ) as duplicate_row_no
from Portfolio_project..Housing_data
)
delete
from duplicate_row_noCTE
where duplicate_row_no > 1

-----------------------------------------------Deleting unused coloumn-------------------------------------------------


--Deleting some unused coloumn as again we should never do this withous the permission from higher authority

alter table Portfolio_project..Housing_data
drop column owneraddress,propertyaddress,taxdistrict

alter table Portfolio_project..Housing_data
drop column saledate












