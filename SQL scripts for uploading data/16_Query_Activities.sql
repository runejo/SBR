use demoDB
go

DELETE FROM [dbo].[Activities]
GO


DELETE FROM [dbo].[ActivityStatisticalUnits]
GO

DBCC CHECKIDENT ('dbo.Activities',RESEED, 1)
GO

ALTER TABLE [dbo].[Activities]
ADD statId FLOAT NULL
GO

DECLARE @guid NVARCHAR(450)
SELECT @guid = Id FROM [dbo].[AspNetUsers]

--Primary activity
INSERT INTO [dbo].[Activities]
  ([ActivityCategoryId]
  ,[Activity_Type]
  ,[Activity_Year]
  ,[Employees]
  ,[Id_Date]
  ,[Turnover]
  ,[Updated_By]
  ,[Updated_Date]
  ,[statId])
SELECT
	a.[Id] AS ActivityCategoryId,
	1 AS Activity_Type,
	2017 AS Activity_Year,
	null AS Employees,
	try_cast('2017-05-31 23:59:59'as datetime)  AS Id_Date,
	d2.new_turnover16 * d2.Q7_1 / 100 AS Turnover,	
	@guid AS Updated_By,
	GETDATE() AS Updated_Date,
	su.RegId
FROM StatisticalUnits su
inner join CBR..estab2b_Day2 d2
	 on su.StatId = d2.new_sno
INNER JOIN [dbo].[ActivityCategories] a
	ON cast(d2.isic_g as varchar) = a.[Code]
WHERE d2.isic_g IS NOT NULL
--GO  


--secondary activity
INSERT INTO [dbo].[Activities]
  ([ActivityCategoryId]
  ,[Activity_Type]
  ,[Activity_Year]
  ,[Employees]
  ,[Id_Date]
  ,[Turnover]
  ,[Updated_By]
  ,[Updated_Date]
  ,[statId])
SELECT 
	a.[Id] AS ActivityCategoryId,
	2 AS Activity_Type,	--secondary
	2017 AS Activity_Year,
	0 AS Employees,
	try_cast('2017-05-31 23:59:59'as datetime)  AS Id_Date,
	d2.new_turnover16 * d2.Q7_2 / 100 AS Turnover,	
	@guid AS Updated_By,	
	GETDATE() AS Updated_Date,
	su.RegId	
  FROM StatisticalUnits su
  inner join CBR..estab2b_Day2 d2
	 on su.StatId = d2.new_sno
  INNER JOIN [dbo].[ActivityCategories] a
	  ON cast(d2.Q7_2_ISIC4DIGITS as varchar) = a.[Code]
  WHERE d2.Q7_2_ISIC4DIGITS IS NOT NULL
--GO  


-- more secondary activity
INSERT INTO [dbo].[Activities]
  ([ActivityCategoryId]
  ,[Activity_Type]
  ,[Activity_Year]
  ,[Employees]
  ,[Id_Date]
  ,[Turnover]
  ,[Updated_By]
  ,[Updated_Date]
  ,[statId])
SELECT 
	a.[Id] AS ActivityCategoryId,
	2 AS Activity_Type,	--secondary
	2017 AS Activity_Year,
	0 AS Employees,
	try_cast('2017-05-31 23:59:59'as datetime)  AS Id_Date,
	d2.new_turnover16 * d2.Q7_3 / 100 AS Turnover,	
	@guid AS Updated_By,	
	GETDATE() AS Updated_Date,
	su.RegId	
  FROM StatisticalUnits su
  inner join CBR..estab2b_Day2 d2
	 on su.StatId = d2.new_sno
  INNER JOIN [dbo].[ActivityCategories] a
	  ON cast(d2.Q7_3_ISIC4DIGITS as varchar) = a.[Code]
  WHERE d2.Q7_3_ISIC4DIGITS IS NOT NULL
--GO  


--  even more secondary activity
INSERT INTO [dbo].[Activities]
  ([ActivityCategoryId]
  ,[Activity_Type]
  ,[Activity_Year]
  ,[Employees]
  ,[Id_Date]
  ,[Turnover]
  ,[Updated_By]
  ,[Updated_Date]
  ,[statId])
SELECT 
	a.[Id] AS ActivityCategoryId,
	2 AS Activity_Type,	--secondary
	2017 AS Activity_Year,
	null AS Employees,
	try_cast('2017-05-31 23:59:59'as datetime)  AS Id_Date,
	d2.new_turnover16 * d2.Q7_4 / 100 AS Turnover,	
	@guid AS Updated_By,	
	GETDATE() AS Updated_Date,
	su.RegId	
  FROM StatisticalUnits su
  inner join CBR..estab2b_Day2 d2
	 on su.StatId = d2.new_sno
  INNER JOIN [dbo].[ActivityCategories] a
	  ON cast(d2.Q7_4_ISIC4DIGITS as varchar) = a.[Code]
  WHERE d2.Q7_4_ISIC4DIGITS IS NOT NULL
  GO  


INSERT INTO [dbo].[ActivityStatisticalUnits]
  ([Unit_Id]
  ,[Activity_Id])
SELECT
  s.[RegId],
  a.[Id]
FROM [dbo].[Activities] AS a
  INNER JOIN [dbo].[StatisticalUnits] AS s
    ON a.[statId] = s.[statId]
GO

/*
INSERT INTO dbo.ActivityStatisticalUnits
SELECT
	LegalUnitId,
	Activity_Id
FROM dbo.StatisticalUnits
	INNER JOIN dbo.ActivityStatisticalUnits
		ON Unit_Id = RegId
WHERE Discriminator = 'LocalUnit' AND LegalUnitId IS NOT NULL

INSERT INTO dbo.ActivityStatisticalUnits
SELECT
	loc.RegId,
	Activity_Id
FROM dbo.StatisticalUnits leg
	INNER JOIN dbo.ActivityStatisticalUnits
		ON Unit_Id = RegId
	INNER JOIN dbo.StatisticalUnits loc
		ON loc.LegalUnitId = leg.RegId
			AND loc.statId IS NULL
WHERE leg.Discriminator = 'LegalUnit'

INSERT INTO dbo.ActivityStatisticalUnits
SELECT
	EnterpriseUnitRegId,
	Activity_Id
FROM dbo.StatisticalUnits
	INNER JOIN dbo.ActivityStatisticalUnits
		ON Unit_Id = RegId
WHERE Discriminator = 'LegalUnit' AND EnterpriseUnitRegId IS NOT NULL
*/
