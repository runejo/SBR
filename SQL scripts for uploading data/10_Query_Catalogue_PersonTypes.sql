use demoDB
go

DELETE FROM [dbo].[PersonTypes]
GO
DBCC CHECKIDENT ('dbo.PersonTypes',RESEED, 1)
GO

-- inserting the most used from Q24_designation in the CBR..persons table
-- see also 15_query_persons script

INSERT INTO [dbo].[PersonTypes]
  ([IsDeleted],[Name])
VALUES
	(0, 'DIRECTOR'),
	(0, 'OWNER'),
	(0, 'MANAGER'),
	(0, 'PROPRIETOR'),
	(0, 'ACCOUNTANT'),
	(0, 'PRINCIPAL'),
	(0, 'SUPERVISOR'),
	(0, 'EMPLOYEE'),
	(0, 'HEADTEACHER'),
	(0, 'CONTACT PERSON/UNKNOWN')
GO
