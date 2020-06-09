use demoDB
go


DELETE FROM [dbo].[LegalForms]
GO
DBCC CHECKIDENT ('dbo.LegalForms',RESEED, 1)
GO


 INSERT INTO [dbo].[LegalForms]
   ([Code],[IsDeleted],[Name],[ParentId])
SELECT 
	   Type_Code
	  ,0
      ,Type_Desc
      ,NULL
  FROM uploads.LegalForms
  GO
