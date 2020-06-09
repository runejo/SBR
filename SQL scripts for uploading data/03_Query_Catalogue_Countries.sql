use demoDB
go

DELETE FROM [Countries]
GO

DBCC CHECKIDENT ('dbo.Countries',RESEED, 1)
GO


 INSERT INTO [dbo].[Countries]
   ([Code],[IsDeleted],[IsoCode],[Name])
SELECT 
	Code, 0, IsoCode, Name
  from uploaded..[3_Countries]
