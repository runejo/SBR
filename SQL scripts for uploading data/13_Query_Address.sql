use demoDB
go

DELETE FROM [Address]
GO
DBCC CHECKIDENT ('dbo.Address',RESEED, 1)
GO

-- DROP INDEX [IX_Address_Address_part1_Address_part2_Address_part3_Region_id_Latitude_Longitude] ON [dbo].[Address]
-- GO

-- DROP INDEX [IX_Address_Region_id] ON [dbo].[Address]
-- GO

-- ALTER TABLE [dbo].[Address] DROP CONSTRAINT [FK_Address_Regions_Region_id]
-- GO

ALTER TABLE [dbo].[Address]
ADD statId FLOAT NULL

Alter table dbo.Address
	add addressType varchar(1)
GO

--postal first
INSERT INTO [dbo].[Address]
	([Address_part1]
	,[Address_part2]
	,[Address_part3]
	,[Latitude]
	,[Longitude]
	,[Region_id]
	,[statId]
	,[addressType])
SELECT
	Q5_8POSTAL_ADDRESS,
	Q5_8POSTAL_CODE,
	Q5_8TOWN,
	null,
	null,
	r.Id,
	new_sno, 
	'p'	
FROM CBR..estab2b_Day2 est
	inner join [dbo].[Regions] r
	on r.Code = '000'
	where est.Q5_8TOWN not like '   %'
GO


--Then physical
--First those with geo code correct (=3 obs)
With CTE (countyCode, consistuency, ward, Q5_6_NAME_OF_STREET, house, town, new_sno)
as
 (select '0' + COUNTY_COD as countyCode,
	case
		when Q5_2_CONSTITUENCY < 10 then '00' + cast(Q5_2_CONSTITUENCY as varchar)
		when Q5_2_CONSTITUENCY >=10 and Q5_2_CONSTITUENCY < 100 then '0' + cast(Q5_2_CONSTITUENCY as varchar)
		else cast(Q5_2_CONSTITUENCY as varchar)
	end  as consistuency,
	case
		when Q5_3_WARD < 10 then '000' + cast(Q5_3_WARD as varchar)
		when Q5_3_WARD >= 10 and Q5_3_WARD < 100 then '00' + cast(Q5_3_WARD as varchar)
		when Q5_3_WARD >= 100 and Q5_3_WARD < 1000 then '0' + cast(Q5_3_WARD as varchar)
		else cast(Q5_3_WARD as varchar)
	end as ward,
	trim(Q5_6_NAME_OF_STREET),
	trim(Q5_7A_BUILD_NAME) + ', ' + trim(Q5_7B_BUILD_NO) + ', ' + trim(Q5_7C_FLOO_NO) as house,
	trim(Q5_4_TOWN) + ', '  + trim(Q5_5_ZONE) as town,
	new_sno
 from CBR..estab2b_Day2_CBR cbr
 join CBR..estab2b_Day2 d2
 on cbr.ID = d2.new_sno
 where Q5_2_CONSTITUENCY is not null and Q5_3_WARD is not null
 )
 INSERT INTO [dbo].[Address]
	([Address_part1]
	,[Address_part2]
	,[Address_part3]
	,[Latitude]
	,[Longitude]
	,[Region_id]
	,[statId]
	,[addressType])
SELECT 
	Q5_6_NAME_OF_STREET, 
	house, 
	town, 
	null,
	null,
	r.Id, 
	new_sno, 
	'v'
 FROM CTE
 inner join Regions r
 on r.Code = ward collate Danish_Norwegian_CI_AS
 where r.Id is not null
go


 --then physical addresses
--Those with 2 lvl geo code (ie not ward)
With CTE (countyCode, consistuency, Q5_6_NAME_OF_STREET, house, town, new_sno)
as
 (select '0' + COUNTY_COD as countyCode,
	case
		when Q5_2_CONSTITUENCY < 10 then '00' + cast(Q5_2_CONSTITUENCY as varchar)
		when Q5_2_CONSTITUENCY >=10 and Q5_2_CONSTITUENCY < 100 then '0' + cast(Q5_2_CONSTITUENCY as varchar)
		else cast(Q5_2_CONSTITUENCY as varchar)
	end  as consistuency,
	
	trim(Q5_6_NAME_OF_STREET),
	trim(Q5_7A_BUILD_NAME) + ', ' + trim(Q5_7B_BUILD_NO) + ', ' + trim(Q5_7C_FLOO_NO) as house,
	trim(Q5_4_TOWN) + ', '  + trim(Q5_5_ZONE) as town,
	new_sno
 from CBR..estab2b_Day2_CBR cbr
 join CBR..estab2b_Day2 d2
 on cbr.ID = d2.new_sno
 where Q5_2_CONSTITUENCY is not null and Q5_3_WARD is not null
 )
  INSERT INTO [dbo].[Address]
	([Address_part1]
	,[Address_part2]
	,[Address_part3]
	,[Latitude]
	,[Longitude]
	,[Region_id]
	,[statId]
	,[addressType])
 SELECT 
	Q5_6_NAME_OF_STREET, 
	house, 
	town, 
	null,
	null,
	r.Id, 
	new_sno, 
	'v'
 FROM CTE
 inner join Regions r
 on r.Code = consistuency collate Danish_Norwegian_CI_AS
 where r.Id is not null
go 

 
 --Those with only county geo code
With CTE (countyCode, Q5_6_NAME_OF_STREET, house, town, new_sno)
as
 (select '0' + COUNTY_COD as countyCode,
	trim(Q5_6_NAME_OF_STREET),
	trim(Q5_7A_BUILD_NAME) + ', ' + trim(Q5_7B_BUILD_NO) + ', ' + trim(Q5_7C_FLOO_NO) as house,
	trim(Q5_4_TOWN) + ', '  + trim(Q5_5_ZONE) as town,
	new_sno
 from CBR..estab2b_Day2_CBR cbr
 join CBR..estab2b_Day2 d2
 on cbr.ID = d2.new_sno
 where COUNTY_COD is not null and Q5_6_NAME_OF_STREET not like '   %%      '
 )
 INSERT INTO [dbo].[Address]
	([Address_part1]
	,[Address_part2]
	,[Address_part3]
	,[Latitude]
	,[Longitude]
	,[Region_id]
	,[statId]
	,[addressType])
 SELECT 
	Q5_6_NAME_OF_STREET, 
	house, 
	town, 
	null,
	null,
	r.Id, 
	new_sno, 
	'v'
 FROM CTE
 inner join Regions r
 on r.Code = countyCode collate Danish_Norwegian_CI_AS
 where r.Id is not null
go 


--ALTER TABLE [dbo].[Address] DROP COLUMN K_PRED
