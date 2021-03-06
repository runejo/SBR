--NB: Remember to include a code for unknown activity
--(Added to the end of the script bot commented away in case it is already taken care of)
use demoDB
go

DELETE FROM [dbo].[DictionaryVersions]
GO
DBCC CHECKIDENT ('dbo.DictionaryVersions',RESEED, 1)
GO

INSERT INTO [dbo].[DictionaryVersions] ([VersionId],[VersionName])
VALUES (1,'Migration version')
GO
  
DELETE FROM [dbo].[ActivityCategories]
GO
DBCC CHECKIDENT ('dbo.ActivityCategories',RESEED, 1)
GO

ALTER TABLE [dbo].[ActivityCategories] ADD OldParentId NVARCHAR(20) NULL
GO

--first level/section
INSERT INTO [dbo].[ActivityCategories]
  ([Code]
  ,[IsDeleted]
  ,[Name] 
  ,[ParentId]
  ,[Section]
  ,[OldParentId]
  ,[VersionId]
  ,[DicParentId]
  ,[ActivityCategoryLevel])
SELECT   
  Code
  ,0
  ,Description
  ,0
  ,F3
  ,0
  ,1
  ,NULL
  ,NULL
FROM CBR..ISIC_rev4
where len(Code) = 1
GO


--second level
INSERT INTO [dbo].[ActivityCategories]
  ([Code]
  ,[IsDeleted]
  ,[Name] 
  ,[ParentId]
  ,[Section]
  ,[OldParentId]
  ,[VersionId]
  ,[DicParentId]
  ,[ActivityCategoryLevel])
SELECT   
  i.Code
  ,0
  ,Description
  ,ac.Id
  ,F3
  ,0
  ,1
  ,NULL
  ,NULL
FROM CBR..ISIC_rev4 i
join ActivityCategories ac
on i.F3 = ac.Code COLLATE Danish_Norwegian_CI_AS --SQL_Latin1_General_CP1_CI_A
where len(i.Code) = 2
GO


--third level
INSERT INTO [dbo].[ActivityCategories]
  ([Code]
  ,[IsDeleted]
  ,[Name] 
  ,[ParentId]
  ,[Section]
  ,[OldParentId]
  ,[VersionId]
  ,[DicParentId]
  ,[ActivityCategoryLevel])
SELECT   
  i.Code
  ,0
  ,i.Description
  ,ac.Id
  ,F3
  ,0
  ,1
  ,NULL
  ,NULL
FROM CBR..ISIC_rev4 i
join ActivityCategories ac
on SUBSTRING(i.Code,1,2) = ac.Code COLLATE Danish_Norwegian_CI_AS --SQL_Latin1_General_CP1_CI_A
where len(i.Code) = 3
GO


--Foruth lvl
INSERT INTO [dbo].[ActivityCategories]
  ([Code]
  ,[IsDeleted]
  ,[Name] 
  ,[ParentId]
  ,[Section]
  ,[OldParentId]
  ,[VersionId]
  ,[DicParentId]
  ,[ActivityCategoryLevel])
SELECT   
  i.Code
  ,0
  ,i.Description
  ,ac.Id
  ,F3
  ,0
  ,1
  ,NULL
  ,NULL
FROM CBR..ISIC_rev4 i
join ActivityCategories ac
on SUBSTRING(i.Code,1,3) = ac.Code COLLATE Danish_Norwegian_CI_AS --SQL_Latin1_General_CP1_CI_A
where len(i.Code) = 4
GO


--adding "unknown" activity. Uncomment away as needed
/*
insert into ActivityCategories (Name, isDeleted, Code, section, parentId, DicParentId, VersionId, ActivityCategoryLevel)
values ('Unknown',0, '0', '0', 0, null, 1, 1);

insert into ActivityCategories (Name, isDeleted, Code, section, parentId, DicParentId, VersionId, ActivityCategoryLevel)
select
	'Unknown',0, '00', 0, id, null, 1, 2
from ActivityCategories
where Code = '0'

insert into ActivityCategories (Name, isDeleted, Code, section, parentId, DicParentId, VersionId, ActivityCategoryLevel)
select
	'Unknown',0, '000', 0, id, null, 1, 3
from ActivityCategories
where Code = '00'

insert into ActivityCategories (Name, isDeleted, Code, section, parentId, DicParentId, VersionId, ActivityCategoryLevel)
select
	'Unknown',0, '0000', 0, id, null, 1, 4
from ActivityCategories
where Code = '000'
go
*/
--Fixing DicParentId

UPDATE [dbo].[ActivityCategories]
SET [DicParentId] = [Id]
GO


-- Delete unneeded column


-- ACTIVITY CATEGORY LEVEL DEFINE PART --

-- Add a function that gets the level number, passing the ID
-- The activitycategoryLevel is used to create statistical reports
CREATE FUNCTION GetActivityCategoryLevel (@input_id INT)   
  RETURNS INT
AS BEGIN   
  DECLARE @in_id INT = @input_id;
  DECLARE @level INT = 1;

  WHILE @in_id > 0 
  BEGIN
    SELECT top 1 @in_id = ParentId FROM ActivityCategories WHERE Id = @in_id
    IF @in_id > 0 SET @level = @level + 1;
  END

  RETURN @level  
END  
GO

-- Update ActivityCategories with correct level number
UPDATE ActivityCategories
SET ActivityCategoryLevel = dbo.GetActivityCategoryLevel(Id)
GO

-- Remove unnecessary function
DROP FUNCTION [dbo].[GetActivityCategoryLevel]
