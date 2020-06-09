use demoDB
go

DELETE FROM [ReorgTypes]
GO
DBCC CHECKIDENT ('dbo.ReorgTypes',RESEED, 1)
GO


INSERT INTO [dbo].[ReorgTypes]
  ([Code],[IsDeleted],[Name])
VALUES
  ('1', 0, 'Merger'),
  ('2', 0, 'Aquisition'),
  ('3', 0, 'Re-branding')
  
GO

-- OR select from other database

-- INSERT INTO [dbo].[ReorgTypes]
--   ([Code],[IsDeleted],[Name],[NameLanguage1],[NameLanguage2])
-- SELECT
--   NULL,
--   0
--   ,[N_DEM]
--   ,NULL
--   ,NULL
-- FROM [regstat].[dbo].[SPRDEM]
-- GO
