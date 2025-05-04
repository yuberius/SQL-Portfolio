--Variables declaration
DECLARE @PeriodStart as varchar(100) = '20241011'
DECLARE @PeriodEnd as varchar(100) = '20241015'

--Drop all temp tables if any
DROP TABLE IF EXISTS #RapidRG
DROP TABLE IF EXISTS #ZeroRG
DROP TABLE IF EXISTS #IndRGPL
DROP TABLE IF EXISTS #FinalPL

--RG list creation - temp table RapidRG
SELECT [Registration group]
INTO #RapidRG
  FROM [progresSSISdb].[dbo].[Events]
  where Result in ('UKIDP-REG19', 'UKIDP-REG18')
    and [Created on] >= @PeriodStart
    and [Created on] <= @PeriodEnd

--looking for RGs with the size zero
SELECT [Registration Group ID]
INTO #ZeroRG
    FROM [progresSSISdb].[dbo].[RG]
    WHERE [Group size] < 1
    and [Registration Group ID] in (
        SELECT * from #RapidRG
    )

--listing RGs with the size zero
IF (SELECT COUNT(*) FROM #ZeroRG) = 0
    Print 'There are no zero sized RGs';
    ELSE SELECT * FROM #ZeroRG;

--IND + RG part of payment list creation
SELECT rg.[Registration Group ID]
      ,rg.[Group size]
      ,rg.[Owning office]
      ,rg.[Registration date]
      ,[Individual ID (FP)] as 'Focal Point ID'
      ,ind.[Full name]
      ,ind.Age
      ,ind.Sex
      ,ind.[Legal Status]
      ,ind.[Legacy ID]
      ,ind.[Phone number]
INTO #IndRGPL      
  FROM [progresSSISdb].[dbo].[RG] as rg
  join [progresSSISdb].[dbo].[Ind] as ind
    on rg.[Individual ID (FP)] = ind.[Individual ID]
    where rg.[Registration Group ID] in (
        SELECT * from #RapidRG
        EXCEPT
        SELECT * from #ZeroRG
    )

--Payment List Compilation
SELECT [Registration Group ID]
      ,[Group size]
      ,[Owning office]
      ,[Registration date]
      ,[Focal Point ID]
      ,[Full name]
      ,Age
      ,Sex
      ,[Legal Status]
      ,[Legacy ID]
      ,[Phone number]
      ,[Result short name]
      ,CASE
        WHEN [Registration date] < @PeriodStart Then 'Registered earlier'
        ELSE 'Registered within the period'
       END 'Registration period'
INTO #FinalPL
FROM #IndRGPL 
    JOIN [progresSSISdb].[dbo].[Events] as Events
        on Events.[Registration group] = #IndRGPL.[Registration Group ID]
    where Events.Result in ('UKIDP-REG19', 'UKIDP-REG18')
        and Events.[Created on] >= @PeriodStart
        and Events.[Created on] <= @PeriodEnd

--Payment List
SELECT *
FROM #FinalPL
order by [Registration date] asc

--Drop all temp tables
DROP TABLE #RapidRG
DROP TABLE #ZeroRG
DROP TABLE #IndRGPL
DROP TABLE #FinalPL