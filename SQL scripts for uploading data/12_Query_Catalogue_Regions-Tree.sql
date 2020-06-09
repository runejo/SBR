use demoDB
go


DELETE FROM [dbo].[Regions]
GO
DBCC CHECKIDENT ('dbo.Regions',RESEED, 1)
GO

ALTER TABLE [dbo].[Regions] ADD OldParentId NVARCHAR(20) NULL
GO

INSERT INTO [dbo].[Regions]
  ([AdminstrativeCenter]
  ,[Code]
  ,[IsDeleted]
  ,[Name]
  ,[ParentId]
  ,[OldParentId]
  ,[FullPath]
  ,[RegionLevel])
SELECT
	null,
	case
		when len(County_Code) = 1 then '0' + County_Code
		else County_Code
	end, 
	0,
	County_Name,
	null, 
	null,
	County_Name,
	null
 FROM cbr..County
GO


--Clean up duplicate from consistuency table. (Randomly now. Need to work out what is right)
WITH g AS (
	SELECT ROW_NUMBER() OVER(PARTITION BY const_code ORDER BY const_code) AS row
	FROM CBR..Constituency) 
DELETE FROM g
WHERE row > 1;

INSERT INTO [dbo].[Regions]
  ([AdminstrativeCenter]
  ,[Code]
  ,[IsDeleted]
  ,[Name]
  ,[ParentId]
  ,[OldParentId]
  ,[FullPath]
  ,[RegionLevel])
SELECT
	null,
	case
		when len(Const_Code) = 1 then '00' + Const_Code
		when len(const_code) = 2 then '0' + Const_Code
		else Const_Code
	end, 
	0, 
	Const_Name, 
	Regions.Id as parentId, 
	0 as OldParentId,
	Regions.Name + ', ' + Const_Name,
	null
from CBR..Constituency
left join Regions
on Code = County_Code collate Danish_Norwegian_CI_AS
go

--as of now, we don't have names of ward. using the code instead
--again: deleting a random duplicate
With tmp as (
	select distinct Q5_3_WARD as wardcode, 
	case 
		when Q5_2_CONSTITUENCY < 10 then '00' + cast(Q5_2_CONSTITUENCY as varchar)
		when Q5_2_CONSTITUENCY >= 10 and Q5_2_CONSTITUENCY < 100 then '0' + cast(Q5_2_CONSTITUENCY as varchar)
		else cast(Q5_2_CONSTITUENCY as varchar)
	end as constcode 
	from CBR..estab2b_Day2
	where Q5_3_WARD is not null
	and not (Q5_3_WARD = 309 and Q5_2_CONSTITUENCY = 62)
	and not (Q5_3_WARD = 484 and (Q5_2_CONSTITUENCY = 94 or Q5_2_CONSTITUENCY = 97))
	and not (Q5_3_WARD = 844 and Q5_2_CONSTITUENCY = 170)
	and not (Q5_3_WARD = 911 and Q5_2_CONSTITUENCY = 186)
	and not (Q5_3_WARD = 677 and Q5_2_CONSTITUENCY = 140)
	and not (Q5_3_WARD = 491 and Q5_2_CONSTITUENCY = 96))
INSERT INTO [dbo].[Regions]
  ([AdminstrativeCenter]
  ,[Code]
  ,[IsDeleted]
  ,[Name]
  ,[ParentId]
  ,[OldParentId]
  ,[FullPath]
  ,[RegionLevel])
SELECT
	null,
   case 
		when wardcode < 10 then '000' + cast(wardcode as varchar)
		when wardcode >= 10 and wardcode < 100 then '00' + cast(wardcode as varchar)
		when wardcode >= 100 and wardcode < 1000 then '0' + cast(wardcode as varchar)
		else cast(wardcode as varchar)
	end as CODE,
	0, 
	wardcode as NAME, 
	r.Id as parent_ID, 
	null as OldParentId,
	r.FullPath + ', ' + cast(wardcode as varchar),
	null as RegionLevel
from tmp
inner join kenya_SBR..Regions r
on tmp.constcode = r.Code and r.Code is not null
where tmp.wardcode is not null
go

-- Delete unneeded column

ALTER TABLE [dbo].[Regions] DROP COLUMN OldParentId
GO

-- FullPath collecting CTE
-- This was already done during the initial inserts. Keeping the code anyway

--WITH CTE AS (
--  SELECT Id, AdminstrativeCenter, Code, IsDeleted, Name, ParentId, Name AS FullPath, ParentId AS LastParentId, 1 AS num
--  FROM Regions 

--  UNION ALL

--  SELECT CTE.Id, CTE.AdminstrativeCenter, CTE.Code, CTE.IsDeleted, CTE.Name, CTE.ParentId, r.Name + ', ' + CTE.FullPath, r.ParentId, num + 1
--  FROM CTE 
--  INNER JOIN Regions AS r
--    ON CTE.LastParentId = r.Id
--),
--CTE2 AS (
--  SELECT Id, AdminstrativeCenter, Code, IsDeleted, Name, ParentId, FullPath, ROW_NUMBER() OVER(PARTITION BY Id ORDER BY num DESC) AS rn
--  FROM CTE
--)

---- FullPath define

--UPDATE r
--	SET r.FullPath = cte.FullPath
--FROM Regions r
--	INNER JOIN CTE2 cte
--		ON cte.Id = r.Id
--WHERE rn = 1
--GO


-- REGION CATEGORY LEVEL DEFINE PART --

-- Add a function that gets the level number, passing the ID
CREATE FUNCTION GetRegionLevel (@input_id INT)
	RETURNS INT
AS BEGIN
    DECLARE @in_id INT = @input_id;
	DECLARE @level INT = 1;

	WHILE @in_id > 0
	BEGIN
		SELECT top 1 @in_id = ParentId FROM Regions WHERE Id = @in_id
		IF @in_id > 0 SET @level = @level + 1;
	END

  RETURN @level
END  
GO

-- Update ActivityCategories with correct level number
UPDATE [dbo].[Regions]
SET [RegionLevel] = dbo.GetRegionLevel(Id)
GO

-- Remove unnecessary function
DROP FUNCTION [dbo].[GetRegionLevel]
GO
