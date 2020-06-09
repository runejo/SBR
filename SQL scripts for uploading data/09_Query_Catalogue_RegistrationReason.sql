use demoDB
go

DELETE FROM [dbo].[RegistrationReasons]
GO
DBCC CHECKIDENT ('dbo.RegistrationReasons',RESEED, 1)
GO

INSERT INTO [dbo].[RegistrationReasons]
  ([Code],[IsDeleted],[Name])
VALUES
  (1, 0, 'Initial Registration')
GO
