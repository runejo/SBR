use demoDB
go

DELETE FROM [Persons]
GO

delete from [PersonStatisticalUnits]
go

DBCC CHECKIDENT ('dbo.Persons',RESEED, 1)
GO

ALTER TABLE [dbo].[Persons] ADD statId FLOAT NULL
GO

INSERT INTO [dbo].[Persons]
	([Address]
	,[BirthDate]
	,[CountryId]
	,[GivenName]
	,[IdDate]
	,[MiddleName]
	,[PersonalId]
	,[PhoneNumber]
	,[PhoneNumber1]
	,[Sex]
	,[Surname]
	,statId)
SELECT
	'' AS Address,
	null AS BirthDate,
	c.Id AS CountryId,
	case
		when PATINDEX('% %',f.Q24_Contact_person) = 0 then f.Q24_Contact_person
		else  SUBSTRING(f.Q24_Contact_person,0,PATINDEX('% %',f.Q24_Contact_person))  
	end AS GivenName,
	GETDATE() AS IdDate,
	NULL AS MiddleName,
	'' AS PersonalId,
	f.Q24_PHONE AS PhoneNumber,
	NULL AS PhoneNumber1,
	1  Sex,
	case 
		when PATINDEX('% %',f.Q24_Contact_person) = 0 then ''
		else SUBSTRING(f.Q24_Contact_person,PATINDEX('% %',f.Q24_Contact_person),len(f.Q24_Contact_person)) 
	 end AS Surname,
	CAST(RegId AS FLOAT)
FROM StatisticalUnits su
left join CBR..estab2b_Day2 e
	on su.StatId = e.new_sno
LEFT JOIN CBR..persons  f 
	ON e.new_sno =f.New_Sno
LEFT join Countries c
	on c.Name = 'KENYA'	--assuming all people are from Kenya :)
where  f.q24_contact_person <> '' or f.Q24_Phone <> ''
go


INSERT INTO [dbo].[PersonStatisticalUnits]
	([Unit_Id]
	,[Person_Id]
	,[GroupUnit_Id]
	,[PersonTypeId]
	)
SELECT
	s.[RegId],
	p.[Id],
	NULL AS groupUnit_id,
	case	--sorry. Hard coding the options. See person types for details
		when CHARINDEX('DIRECTOR', cp.Q24_DESIGNATION) > 0 then 1
	when CHARINDEX('OWNER', cp.Q24_DESIGNATION) > 0 then 2
	when CHARINDEX('MANAGER', cp.Q24_DESIGNATION) > 0 then 3
	when CHARINDEX('PROPRIETOR', cp.Q24_DESIGNATION) > 0 
		or CHARINDEX('PROPRIATOR', cp.Q24_DESIGNATION) > 0 then 4
	when CHARINDEX('ACCOUNTANT', cp.Q24_DESIGNATION) > 0 then 5
	when CHARINDEX('PRINCIPAL', cp.Q24_DESIGNATION) > 0 then 6
	when CHARINDEX('SUPERVISOR', cp.Q24_DESIGNATION) > 0 then 7
	when CHARINDEX('EMPLOYEE', cp.Q24_DESIGNATION) > 0 then 8
	when CHARINDEX('HEADTEACHER', cp.Q24_DESIGNATION) > 0
		or CHARINDEX('HEAD TEACHER', cp.Q24_DESIGNATION) > 0 then 9
	else 10
	end AS PersonTypeId --Make sure the matches the [PersonType] table value
	
FROM [dbo].[StatisticalUnits] AS s
INNER JOIN [dbo].[Persons] AS p
	ON s.StatId = p.statId
inner join CBR..estab2b_Day2 est
	on est.new_sno = s.StatId
inner join CBR..persons cp
	on est.new_sno = cp.new_sno
go
