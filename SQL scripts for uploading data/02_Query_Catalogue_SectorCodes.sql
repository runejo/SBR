use demoDB
go

DELETE FROM [dbo].[SectorCodes]
GO
DBCC CHECKIDENT ('dbo.SectorCodes',RESEED, 1)
GO

 INSERT INTO [dbo].[SectorCodes]
   ([Code],[IsDeleted],[Name],[ParentId])
  SELECT 
	  Sect_Code
	 ,0
     ,Sect_Name
	 ,NULL
  FROM CBR..Sector
  GO
