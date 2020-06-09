use demoDB
go

--ALTER TABLE [dbo].[StatisticalUnits]
--ADD statId FLOAT NULL
--GO

DELETE FROM [StatisticalUnits]
GO

DBCC CHECKIDENT ('dbo.StatisticalUnits',RESEED, 1)
GO

DECLARE @guid NVARCHAR(450)
SELECT @guid = Id FROM [dbo].[AspNetUsers]

--Enterprise
INSERT INTO [dbo].[StatisticalUnits]
  ([ActualAddressId]
	,[AddressId]
	,[ChangeReason]
	,[Classified]
	,[DataSource]
	,[DataSourceClassificationId]
	,[Discriminator]
	,[EditComment]
	,[EmailAddress]
  ,[Employees]
	,[EmployeesDate]
	,[EmployeesYear]
	,[EndPeriod]
	,[ExternalId]
	,[ExternalIdDate]
	,[ExternalIdType]	
  ,[ForeignParticipationId]
	,[FreeEconZone]
	,[InstSectorCodeId]
	,[IsDeleted]
	,[LegalFormId]
	,[LiqDate]
	,[LiqReason]
	,[Name]
	,[Notes]
	,[NumOfPeopleEmp]
  ,[ParentOrgLink]
	,[PostalAddressId]
	,[RefNo]
	,[RegIdDate]
	,[RegistrationDate]
	,[ReorgDate]
	,[ReorgReferences]
  ,[ReorgTypeCode]
	,[ReorgTypeId]
	,[ShortName]
	,[SizeId]
	,[StartPeriod]
	,[StatId]
	,[StatIdDate]
	,[StatusDate]
	,[SuspensionEnd]
	,[SuspensionStart]
  ,[TaxRegDate]
	,[TaxRegId]
	,[TelephoneNo]
	,[Turnover]
	,[TurnoverDate]
	,[TurnoverYear]
	,[UnitStatusId]
	,[UserId]
	,[WebAddress]
	,[Commercial]
  ,[EntGroupId]
	,[EntGroupIdDate]
	,[EntGroupRole]
	,[ForeignCapitalCurrency]
	,[ForeignCapitalShare]
	,[MunCapitalShare]
	,[PrivCapitalShare]
	,[StateCapitalShare]
	,[TotalCapital]
	,[EntRegIdDate]
	,[EnterpriseUnitRegId]
	,[Market]
	,[LegalUnitId]
	,[LegalUnitIdDate]
	,[RegistrationReasonId])
SELECT
	av.Address_id AS ActualAddressId,
	av.Address_id AS AddressId,
	1 AS ChangeReason,
	0 AS Classified,
  'Census' AS DataSource, -- Data source upload functionality, places name of file from which was uploaded
  NULL AS DataSourceClassificationId, -- Data source classifications catalogue row Id
  'EnterpriseUnit' AS Discriminator,
	NULL AS EditComment,
	d2.Q5_11_EMAIL AS EmailAddress,
	try_cast(est.TOT_EMPS as int) as employees, --This number includes the nonpaid worker which needs to be substituted, but we don't have the variables
    try_cast('2017-05-31 23:59:59'as datetime)  as EmployeesDate,
    2016 as EmployeesYear,
    '9999-12-31 23:59:59.9999999' AS EndPeriod,
	case 
		when d2.Q5_13_NSSF <> '' then d2.Q5_13_NSSF 
		when d2.Q5_13_NSSF <> '' and d2.Q5_15_BUSINESS_NUMBER <> '' then d2.Q5_15_BUSINESS_NUMBER
		else ''  
	end as ExternalId,
    cast('2017-05-31 23:59:59'as datetime) as ExternalIdDate,
	case 
		when d2.Q5_13_NSSF <> '' then 1   --NB: This should be "NSSF" or "BUSINESS NUMBER", but currently the database has wrong number
		when d2.Q5_13_NSSF <> '' and d2.Q5_15_BUSINESS_NUMBER <> '' then 2
		else null 
	end as ExternalIdType,
    fp.Id AS ForeignParticipationId, -- Foreign participations catalogue row Id
	0 AS FreeEconZone,
	1 AS InstSectorCodeId, -- Sector codes catalogue row Id
	0 AS IsDeleted,
	lf.Id AS LegalFormId,
	NULL AS LiqDate, -- LIQDATE set a column name if it exists in source db
	'' AS LiqReason,
	est.FIRM_NAME AS Name,
	case 
		when d2.Q5_13_NSSF <> '' and d2.Q5_15_BUSINESS_NUMBER <> '' then
			'BUSINESS Number: ' + cast(d2.Q5_15_BUSINESS_NUMBER as varchar) 
		else '' 
	End as Notes,
	try_cast(est.TOT_EMPS as int) as NumOfPeopleEmp,
	NULL as ParentOrgLink,
 	ap.Address_id AS PostalAddressId,
    0 AS RefNo,
	GETDATE() AS RegIdDate,
	case
		when d2.Q9B_YEAR is not null and  d2.Q9B_MON is not null 
				then cast(d2.Q9B_YEAR + d2.Q9B_MON + '-01' as datetime)
		else cast('2017-05-31 23:59:59'as datetime)
	end as RegistrationDate,
	null AS ReorgDate,
	NULL AS ReorgReferences,
	NULL AS ReorgTypeCode,
	NULL AS ReorgTypeId, -- Reorg type catalogue row Id
	est.FIRM_NAME AS ShortName,
    case 
		when est.tot_emps between 0 and 19 then 1
		when est.tot_emps between 20 and 99 then 2
		when est.tot_emps > 99 then 3
		else 1
	End as Size,
  GETDATE() AS StartPeriod,
	est.ID AS StatId,
	cast('2017-05-31 23:59:59'as datetime) AS StatIdDate,
	GETDATE() AS StatusDate,
	null AS SuspensionEnd,
	null AS SuspensionStart,
  cast('2017-05-31 23:59:59'as datetime) AS TaxRegDate,
	d2.pin_no AS TaxRegId,
	ISNULL(d2.Q5_10_MOBILE_PHONE, '') AS TelephoneNo,
  new_turnover16 AS Turnover,
  cast('2017-05-31 23:59:59'as datetime) AS TurnoverDate,
	2016 AS TurnoverYear,
	case
		when q2 = 1 then 1	--active
		when q2 = 2 then 2	--dormant
		when q2 = 3 then 5	--Historical
		else 9	--unknown
	end AS UnitStatusId, -- Statuses catalogue row Id
	@guid AS UserId,
	d2.Q5_12_WEBSITE AS WebAddress,
	0 AS Commercial,
	NULL AS EntGroupId,
	NULL AS EntGroupIdDate,
	NULL AS EntGroupRole,
	NULL AS ForeignCapitalCurrency,
	est.[FOREIGN] AS ForeignCapitalShare,
	NULL AS MunCapitalShare,
	est.LOCAL AS PrivCapitalShare,
	est.GOK AS StateCapitalShare,
	null AS TotalCapital,
	getdate() AS EntRegIdDate,
	NULL AS EnterpriseUnitRegId,
	0 AS Market,
	NULL AS LegalUnitId,
	null AS LegalUnitIdDate,
	NULL AS RegistrationReasonId -- Registration reason catalogue row Id
FROM CBR..estab2b_Day2_CBR est 
join CBR..estab2b_Day2 d2
on d2.new_sno = est.ID --collate Danish_Norwegian_CI_AS
left join Address av
on av.statid = est.ID and av.addressType = 'v' collate Danish_Norwegian_CI_AS
left join Address ap
on ap.statid = est.ID and ap.addressType = 'p' collate Danish_Norwegian_CI_AS
left join LegalForms lf
on est.TYPE_CODE = lf.Code collate Danish_Norwegian_CI_AS
left join CBR..estab2_extra_columns ec
on est.ID = ec.new_sno 
left join ForeignParticipations fp  
on ec.Q11 = fp.Code collate Danish_Norwegian_CI_AS
left join CBR..Ownership os
on os.Id = est.ID collate Danish_Norwegian_CI_AS
--The following units are identified as duplicates. See separate
where est.ID not in (75	, 111	, 134	, 426	, 447	, 455	, 612	, 848	, 882	, 972	, 1072	, 
		1099	, 1202	, 1257	, 1353	, 1364	, 1540	, 1632	, 1710	, 1724	, 1736	, 1863	, 1873	, 
		1940	, 1955	, 1957	, 2075	, 2083	, 2123	, 2133	, 2136	, 2182	, 2254	, 2317	, 2402	, 
		2501	, 2608	, 2635	, 2713	, 2820	, 2854	, 3015	, 3034	, 3064	, 3099	, 3133	, 3149	,
		 3172	, 3180	, 3184	, 3219	, 3260	, 3267	, 3297	, 3305	, 3434	, 3502	, 3568	, 3606	, 
		 3772	, 3791	, 3843	, 3947	, 3975	, 3988	, 4012	, 4106	, 4141	, 4351	, 4518	, 4649	, 
		 4825	, 4930	, 4938	, 4953	, 5044	, 5189	, 5233	, 5245	, 5379	, 5382	, 5457	, 5701	, 
		 5769	, 5850	, 6374	, 6521	, 7291	, 7575	, 7861	, 10619	, 11854	, 12649	, 12660	, 13721	, 
		 13822	, 15888	, 18736	, 19171	, 19238	, 19786	, 19883	, 19904	, 19908	, 20215	, 22551	, 22562	, 
		 22866	, 22868	, 23000	, 23039	, 23165	, 23174	, 23179	, 23191	, 23652	, 24444	, 26406	, 26413	, 
		 26429	, 26461	, 26505	, 27583	, 32888	, 37148	, 37164	, 38950	, 38958	, 39030	, 39092	, 39145	, 
		 39357	, 39533	, 39700	, 39703	, 40041	, 40095	, 40247	, 40330	, 42219	, 44686	, 44811	, 44815	, 
		 45009	, 45138	, 45321	, 46835	, 47236	, 48188	, 48235	, 48625	, 48641	, 48925	, 49077	, 49464	, 
		 49619	, 49627	, 49710	, 49745	, 49974	, 49976	, 50147	, 50366	, 50390	, 50443	, 54091	, 54181	, 
		 58906	, 59312	, 59314	, 59494	, 59523	, 62501	, 63125	, 63177	, 63186	, 63254	, 63317	, 63369	, 
		 63411	, 63458	, 63500	, 63511	, 63568	, 63710	, 63994	) 
GO

-- Add Legal Units
INSERT INTO [dbo].[StatisticalUnits]
  ([ActualAddressId]
  ,[AddressId]
  ,[ChangeReason]
  ,[Classified]
  ,[DataSource]
  ,[DataSourceClassificationId]
  ,[Discriminator]
  ,[EditComment]
  ,[EmailAddress]
  ,[Employees]
  ,[EmployeesDate]
  ,[EmployeesYear]
  ,[EndPeriod]
  ,[ExternalId]
  ,[ExternalIdDate]
  ,[ExternalIdType]
  ,[ForeignParticipationId]
  ,[FreeEconZone]
  ,[InstSectorCodeId]
  ,[IsDeleted]
  ,[LegalFormId]
  ,[LiqDate]
  ,[LiqReason]
  ,[Name]
  ,[Notes]
  ,[NumOfPeopleEmp]
  ,[ParentOrgLink]
  ,[RefNo]
  ,[RegIdDate]
  ,[RegistrationDate]
  ,[ReorgDate]
  ,[ReorgReferences]
  ,[ReorgTypeCode]
  ,[ReorgTypeId]
  ,[ShortName]
  ,[SizeId]
  ,[StartPeriod]
  ,[StatId]
  ,[StatIdDate]
  ,[StatusDate]
  ,[SuspensionEnd]
  ,[SuspensionStart]
  ,[TaxRegDate]
  ,[TaxRegId]
  ,[TelephoneNo]
  ,[Turnover]
  ,[TurnoverDate]
  ,[TurnoverYear]
  ,[UnitStatusId]
  ,[UserId]
  ,[WebAddress]
  ,[Commercial]
  ,[EntGroupId]
  ,[EntGroupIdDate]
  ,[EntGroupRole]
  ,[ForeignCapitalCurrency]
  ,[ForeignCapitalShare]
  ,[HistoryLegalUnitIds]
  ,[MunCapitalShare]
  ,[PrivCapitalShare]
  ,[StateCapitalShare]
  ,[TotalCapital]
  ,[EntRegIdDate]
  ,[EnterpriseUnitRegId]
  ,[HistoryLocalUnitIds]
  ,[Market]
  ,[LegalUnitId]
  ,[LegalUnitIdDate]
  ,[RegistrationReasonId]
  ,[PostalAddressId])
SELECT
  [ActualAddressId]
  ,[AddressId]
  ,[ChangeReason]
  ,[Classified]
  ,[DataSource]
  ,[DataSourceClassificationId]
  ,'LegalUnit' AS [Discriminator]
  ,[EditComment]
  ,[EmailAddress]
  ,[Employees]
  ,[EmployeesDate]
  ,[EmployeesYear]
  ,[EndPeriod]
  ,[ExternalId]
  ,[ExternalIdDate]
  ,[ExternalIdType]
  ,[ForeignParticipationId]
  ,[FreeEconZone]
  ,[InstSectorCodeId]
  ,[IsDeleted]
  ,[LegalFormId]
  ,[LiqDate]
  ,[LiqReason]
  ,[Name]
  ,[Notes]
  ,[NumOfPeopleEmp]
  ,[ParentOrgLink]
  ,[RefNo]
  ,[RegIdDate]
  ,[RegistrationDate]
  ,[ReorgDate]
  ,[ReorgReferences]
  ,[ReorgTypeCode]
  ,[ReorgTypeId]
  ,[ShortName]
  ,[SizeId]
  ,[StartPeriod]
  ,[StatId]
  ,[StatIdDate]
  ,[StatusDate]
  ,[SuspensionEnd]
  ,[SuspensionStart]
  ,[TaxRegDate]
  ,[TaxRegId]
  ,[TelephoneNo]
  ,[Turnover]
  ,[TurnoverDate]
  ,[TurnoverYear]
  ,[UnitStatusId]
  ,[UserId]
  ,[WebAddress]
  ,[Commercial]
  ,[EntGroupId]
  ,[EntGroupIdDate]
  ,[EntGroupRole]
  ,[ForeignCapitalCurrency]
  ,[ForeignCapitalShare]
  ,[HistoryLegalUnitIds]
  ,[MunCapitalShare]
  ,[PrivCapitalShare]
  ,[StateCapitalShare]
  ,[TotalCapital]
  ,[EntRegIdDate]
  ,RegId
  ,[HistoryLocalUnitIds]
  ,0 as [Market]
  ,[LegalUnitId]
  ,[LegalUnitIdDate]
  ,[RegistrationReasonId]
  ,[PostalAddressId]
FROM dbo.StatisticalUnits
WHERE Discriminator = 'EnterpriseUnit'
GO


-- Add Local Units
INSERT INTO [dbo].[StatisticalUnits]
  ([ActualAddressId]
  ,[AddressId]
  ,[ChangeReason]
  ,[Classified]
  ,[DataSource]
  ,[DataSourceClassificationId]
  ,[Discriminator]
  ,[EditComment]
  ,[EmailAddress]
  ,[Employees]
  ,[EmployeesDate]
  ,[EmployeesYear]
  ,[EndPeriod]
  ,[ExternalId]
  ,[ExternalIdDate]
  ,[ExternalIdType]
  ,[ForeignParticipationId]
  ,[FreeEconZone]
  ,[InstSectorCodeId]
  ,[IsDeleted]
  ,[LegalFormId]
  ,[LiqDate]
  ,[LiqReason]
  ,[Name]
  ,[Notes]
  ,[NumOfPeopleEmp]
  ,[ParentOrgLink]
  ,[RefNo]
  ,[RegIdDate]
  ,[RegistrationDate]
  ,[ReorgDate]
  ,[ReorgReferences]
  ,[ReorgTypeCode]
  ,[ReorgTypeId]
  ,[ShortName]
  ,[SizeId]
  ,[StartPeriod]
  ,[StatId]
  ,[StatIdDate]
  ,[StatusDate]
  ,[SuspensionEnd]
  ,[SuspensionStart]
  ,[TaxRegDate]
  ,[TaxRegId]
  ,[TelephoneNo]
  ,[Turnover]
  ,[TurnoverDate]
  ,[TurnoverYear]
  ,[UnitStatusId]
  ,[UserId]
  ,[WebAddress]
  ,[Commercial]
  ,[EntGroupId]
  ,[EntGroupIdDate]
  ,[EntGroupRole]
  ,[ForeignCapitalCurrency]
  ,[ForeignCapitalShare]
  ,[HistoryLegalUnitIds]
  ,[MunCapitalShare]
  ,[PrivCapitalShare]
  ,[StateCapitalShare]
  ,[TotalCapital]
  ,[EntRegIdDate]
  ,[EnterpriseUnitRegId]
  ,[HistoryLocalUnitIds]
  ,[Market]
  ,[LegalUnitId]
  ,[LegalUnitIdDate]
  ,[RegistrationReasonId]
  ,[PostalAddressId])
SELECT
  [ActualAddressId]
  ,[AddressId]
  ,[ChangeReason]
  ,[Classified]
  ,[DataSource]
  ,[DataSourceClassificationId]
  ,'LocalUnit' AS [Discriminator]
  ,[EditComment]
  ,[EmailAddress]
  ,[Employees]
  ,[EmployeesDate]
  ,[EmployeesYear]
  ,[EndPeriod]
  ,[ExternalId]
  ,[ExternalIdDate]
  ,[ExternalIdType]
  ,[ForeignParticipationId]
  ,[FreeEconZone]
  ,[InstSectorCodeId]
  ,[IsDeleted]
  ,[LegalFormId]
  ,[LiqDate]
  ,[LiqReason]
  ,[Name]
  ,[Notes]
  ,[NumOfPeopleEmp]
  ,[ParentOrgLink]
  ,[RefNo]
  ,[RegIdDate]
  ,[RegistrationDate]
  ,[ReorgDate]
  ,[ReorgReferences]
  ,[ReorgTypeCode]
  ,[ReorgTypeId]
  ,[ShortName]
  ,[SizeId]
  ,[StartPeriod]
  ,[StatId]
  ,[StatIdDate]
  ,[StatusDate]
  ,[SuspensionEnd]
  ,[SuspensionStart]
  ,[TaxRegDate]
  ,[TaxRegId]
  ,[TelephoneNo]
  ,[Turnover]
  ,[TurnoverDate]
  ,[TurnoverYear]
  ,[UnitStatusId]
  ,[UserId]
  ,[WebAddress]
  ,[Commercial]
  ,[EntGroupId]
  ,[EntGroupIdDate]
  ,[EntGroupRole]
  ,[ForeignCapitalCurrency]
  ,[ForeignCapitalShare]
  ,[HistoryLegalUnitIds]
  ,[MunCapitalShare]
  ,[PrivCapitalShare]
  ,[StateCapitalShare]
  ,[TotalCapital]
  ,[EntRegIdDate]
  ,[EnterpriseUnitRegId]
  ,[HistoryLocalUnitIds]
  ,0 AS [Market]
  ,RegId
  ,[LegalUnitIdDate]
  ,[RegistrationReasonId]
  ,[PostalAddressId]
FROM	dbo.StatisticalUnits
WHERE Discriminator = 'LegalUnit'
GO



