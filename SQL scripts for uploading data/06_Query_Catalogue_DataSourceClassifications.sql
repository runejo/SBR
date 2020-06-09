use demoDB
go

DELETE FROM [DataSourceClassifications]
GO
DBCC CHECKIDENT ('dbo.DataSourceClassifications',RESEED, 1)
GO

INSERT INTO [dbo].[DataSourceClassifications]
  ([Code],[IsDeleted],[Name])
VALUES
  ('1', 0, 'Census 2017')  
GO
