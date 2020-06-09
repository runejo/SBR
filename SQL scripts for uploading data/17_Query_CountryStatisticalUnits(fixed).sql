use demoDB
go

DELETE FROM [CountryStatisticalUnits]
GO

-- The Foreign participation countries field - possible to set multiple countries - connects to Countries catalgoue
--don't think I have data for this,
/*
INSERT INTO [dbo].[CountryStatisticalUnits]
    ([Unit_Id]
    ,[Country_Id])
SELECT 
	su.RegId
	,c.Id	
FROM [regstat].[dbo].[KATME_LAND] kl
INNER JOIN [dbo].[Countries] c
	ON c.[IsoCode] = kl.ZAR_PAR
INNER JOIN [dbo].[StatisticalUnits] su
	ON kl.K_PRED = su.K_PRED
GROUP BY su.RegId, c.Id	

*/
