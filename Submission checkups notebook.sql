DECLARE @PeriodStart as varchar(100) = '20241111 00:00:00.000'
DECLARE @PeriodEndPlusOne as varchar(100) = '20241118 00:00:00.000'

PRINT 'Missing SPN'
    SELECT [Registration group ID] as 'Group with Missing SPN'
    FROM [progresSSISdb].[dbo].[RG]
    where year([Created on]) > 2023
    and [Group size] > 0
    and [Registration group ID] not in (
      'FC3-24-3438751','FC3-24-3340634','FC3-24-3579835','FC3-24-3659386','FC3-24-3385600', 'FC3-24-3946749', 'FC3-24-3196559', 'FC3-24-4678593',
      'FC3-24-3284595', 'FC3-24-4678544', 'FC3-24-4595411', 'FC3-24-4678507', 'FC3-24-3709350', 'FC3-24-3199124', 'FC3-24-3752242', 'FC3-24-3558059', 'FC3-24-3703923'
      )
      -- groups to be moved to a table for easier future reference
EXCEPT
    SELECT [Registration group ID]
    FROM [progresSSISdb].[dbo].[SPN]

PRINT 'IND duplicates by Tax ID'
SELECT [Legacy ID] as 'Duplicate Tax ID'
        FROM [progresSSISdb].[dbo].[Ind]
        where [Legal Status] <> 'not of concern'
        and [Legacy ID] not in ('na','NTID A','NTID R','NTID D','NTID L','NTID LB')
        and [Legacy ID] <> ''
        and [Created On] < @PeriodStart
INTERSECT
    SELECT [Legacy ID]
        FROM [progresSSISdb].[dbo].[Ind]
        where [Legal Status] <> 'not of concern'
        and [Legacy ID] not in ('na','NTID A','NTID R','NTID D','NTID L','NTID LB') 
        and [Legacy ID] <> ''
        and [Created On] >= @PeriodStart
        and [Created On] < @PeriodEndPlusOne

PRINT 'IND duplicates by bio data'
SELECT [Individual ID]
      ,[Full Name] as 'Duplicate Name'
      ,[Registration Group ID]
      ,[Date of Birth] 'Duplicate DoB'
  FROM [progresSSISdb].[dbo].[Ind]
  where CONCAT([Full Name],[Date of Birth]) in (
      SELECT CONCAT([Full Name],[Date of Birth]) FNDB
        FROM [progresSSISdb].[dbo].[Ind]
        where [Registration Date] < @PeriodStart
        and [Legal Status] <> 'not of concern'
      INTERSECT
      SELECT CONCAT([Full Name],[Date of Birth]) FNDB
        FROM [progresSSISdb].[dbo].[Ind]
        where [Registration Date] >= @PeriodStart
        and [Registration Date] < @PeriodEndPlusOne
        and [Legal Status] <> 'not of concern'
  )
  order by [Full Name]

PRINT 'Phone number duplicates'
SELECT [Individual ID]
      ,[Full Name]
      ,[Registration Group ID]
      ,[Legal Status]
      ,[Age]
      ,[Sex]
      ,[Legacy ID]
      ,[Relationship to Focal Point]
      ,[Phone Number] as 'Duplicate phone number'
      ,[Created On]
  FROM [progresSSISdb].[dbo].[Ind]
  where [Phone Number] in (
      SELECT [Phone Number]
        FROM [progresSSISdb].[dbo].[Ind]
        where [Registration Date] < @PeriodStart
        and [Phone number] <> '+380000000000'
    INTERSECT
      SELECT [Phone Number]
        FROM [progresSSISdb].[dbo].[Ind]
        where [Registration Date] >= @PeriodStart
        and [Registration Date] < @PeriodEndPlusOne
        and [Phone number] <> '+380000000000'
    )
  order by [Phone Number]

PRINT 'RCp duplicates'
SELECT [Reception ID]
      ,[Group Size]
      ,[Government Form Number]
      ,[Reception Location]
      ,[Registration Group ID]
  FROM [progresSSISdb].[dbo].[RCP]
  join [progresSSISdb].[dbo].[Ind] on [progresSSISdb].[dbo].[Ind].[Legacy ID] = [progresSSISdb].[dbo].[RCP].[Government Form Number]
  where [Government Form Number] in (
        SELECT [Government Form Number]
        FROM [progresSSISdb].[dbo].[RCP]
        INTERSECT
        SELECT [Legacy ID]
            FROM [progresSSISdb].[dbo].[Ind]
            where [Legal Status] <> 'not of concern'
            and [Legacy ID] not in ('na','NTID A','NTID R','NTID D','NTID L','NTID LB') 
            and [Legacy ID] <> ''
        and [Created On] >= @PeriodStart
        and [Created On] < @PeriodEndPlusOne
  )
  order by [Reception Location]

  PRINT 'IDP More than 6 months ago (excluding emergency)'
  SELECT [Individual ID]
      ,[Registration Group ID]
      ,[Legal Status]
      ,[Arrival date]
      ,cast([Created on] as date) as 'Created on'
      ,DATEDIFF(day,[Arrival date],cast([Created on] as date)) as 'Difference in days is greater than 180'
  FROM [progresSSISdb].[dbo].[Ind]
  where 
    [Legal Status] in ('IDP-like', 'Internally displaced person')
    and
    DATEDIFF(day,[Arrival date],cast([Created on] as date)) > 180
    AND
    [Registration Group ID] not in (
        SELECT [Registration group]
        FROM [progresSSISdb].[dbo].[Events]
        where Event = 'ukidp-reg13'
    )
    and [Created On] >= @PeriodStart
    and [Created On] < @PeriodEndPlusOne

PRINT 'Documents'
PRINT 'Duplicates'

SELECT [Individual]
      ,[Full name]
      ,[Date of birth]
      ,[Legal Status]
      ,[Document category]
      ,[Document type]
      ,[Document sub type]
      ,[Number] 'Number-Duplicate'
      ,[Date of issue]
      ,[Date of expiry]
      ,[Is original]
      ,[Is official]
      ,[Original seen]
      ,[progresSSISdb].[dbo].[Doc].[Created on]
  FROM [progresSSISdb].[dbo].[Doc]
  join [progresSSISdb].[dbo].[Ind] on [progresSSISdb].[dbo].[Ind].[Individual ID] = [progresSSISdb].[dbo].[Doc].[Individual]
  where [Number] in (
        SELECT [Number]
        FROM [progresSSISdb].[dbo].[Doc]
        where [Document type] in (
            'Tax Registration Document',
            'National passport',
            'Birth Certificate',
            'National identity card'
        )
        AND [Created On] >= @PeriodStart
        AND [Created On] < @PeriodEndPlusOne

        INTERSECT

        SELECT [Number]
        FROM [progresSSISdb].[dbo].[Doc]
        where [Document type] in (
            'Tax Registration Document',
            'National passport',
            'Birth Certificate',
            'National identity card'
        )
        AND [Created On] < @PeriodStart    
  )
  and [Document type] in (
    'Tax Registration Document',
    'National passport',
    'Birth Certificate',
    'National identity card'
  )
  ORDER by [Number]

PRINT 'Tax ID wrong length'

SELECT [Individual]
      ,[Document category]
      ,[Document type]
      ,[Document sub type]
      ,[Number]
      ,len(Number) 'Tax ID wrong Length'
      ,[Date of issue]
      ,[Date of expiry]
      ,[Is original]
      ,[Is official]
      ,[Original seen]
      ,[Created on]
  FROM [progresSSISdb].[dbo].[Doc]
  where [Document type] = 'Tax Registration Document'
  and len(Number) <> 10
  AND [Created On] >= @PeriodStart
  AND [Created On] < @PeriodEndPlusOne

PRINT 'Passport wrong length'

SELECT [Individual]
      ,[Document category]
      ,[Document type]
      ,[Document sub type]
      ,[Number]
      ,len(Number) 'Passport wrong Length'
      ,[Date of issue]
      ,[Date of expiry]
      ,[Is original]
      ,[Is official]
      ,[Original seen]
      ,[Created on]
  FROM [progresSSISdb].[dbo].[Doc]
  where [Document type] = 'National passport'
  and len(Number) <> 8
  AND [Created On] >= @PeriodStart
  AND [Created On] < @PeriodEndPlusOne

PRINT 'Identity card wrong Length'

SELECT [Individual]
      ,[Document category]
      ,[Document type]
      ,[Document sub type]
      ,[Number]
      ,len(Number) 'Identity card wrong Length'
      ,[Date of issue]
      ,[Date of expiry]
      ,[Is original]
      ,[Is official]
      ,[Original seen]
      ,[Created on]
  FROM [progresSSISdb].[dbo].[Doc]
  where [Document type] = 'National identity card'
  and len(Number) <> 9
  AND [Created On] >= @PeriodStart
  AND [Created On] < @PeriodEndPlusOne

PRINT 'Birth Certificate wrong Length' --Exclude BCs with latin letters

SELECT [Individual]
      ,[Document category]
      ,[Document type]
      ,[Document sub type]
      ,[Number]
      ,len(Number) 'Birth Certificate wrong Length'
      ,[Date of issue]
      ,[Date of expiry]
      ,[Is original]
      ,[Is official]
      ,[Original seen]
      ,[Created on]
  FROM [progresSSISdb].[dbo].[Doc]
  where [Document type] = 'Birth Certificate'
  and len(Number) <> 10
  AND [Created On] >= @PeriodStart
  AND [Created On] < @PeriodEndPlusOne
  AND Number not like '%[a-zA-Z]%'

  PRINT 'Missing UKIDP-REG02 NO TAX ID event' --Missing event

  SELECT [Individual ID] 'Missing UKIDP-REG02 NO TAX ID event'
    FROM [progresSSISdb].[dbo].[Ind]
    where [Legacy ID] in ('na','NTID A','NTID R','NTID D','NTID L','NTID LB')
    AND [Created On] >= @PeriodStart
    AND [Created On] < @PeriodEndPlusOne

  EXCEPT

  SELECT distinct([Individual])
    FROM [progresSSISdb].[dbo].[Events]
    JOIN [progresSSISdb].[dbo].[Ind] on [progresSSISdb].[dbo].[Ind].[Individual ID] = [progresSSISdb].[dbo].[Events].[Individual]
    where [Event] = 'UKIDP-REG02'
    AND [progresSSISdb].[dbo].[Ind].[Created On] >= @PeriodStart
    AND [progresSSISdb].[dbo].[Ind].[Created On] < @PeriodEndPlusOne

PRINT 'Wrong NO TAX ID code'

  SELECT distinct([Individual]) 'Wrong NO TAX ID code' --The event without proper code
    FROM [progresSSISdb].[dbo].[Events]
    JOIN [progresSSISdb].[dbo].[Ind] on [progresSSISdb].[dbo].[Ind].[Individual ID] = [progresSSISdb].[dbo].[Events].[Individual]
    where [Event] = 'UKIDP-REG02'
    AND [progresSSISdb].[dbo].[Ind].[Created On] >= @PeriodStart
    AND [progresSSISdb].[dbo].[Ind].[Created On] < @PeriodEndPlusOne

  EXCEPT

  SELECT [Individual ID]
    FROM [progresSSISdb].[dbo].[Ind]
    where [Legacy ID] in ('na','NTID A','NTID R','NTID D','NTID L','NTID LB')
    AND [Created On] >= @PeriodStart
    AND [Created On] < @PeriodEndPlusOne

PRINT 'Result to Code correspondance check for Missing Tax IDs'

  select [Individual ID]
      ,[Full name]
      ,[Registration Group ID]
      ,[Legal Status]
      ,[Arrival date]
      ,[Legacy ID]
      ,[Result]
      ,[Result short name]
      ,'Result to Code correspondance check for Missing Tax IDs' 'Comments'
from (
    SELECT [Individual ID]
        ,[Full name]
        ,[Registration Group ID]
        ,[Legal Status]
        ,[Arrival date]
        ,[Legacy ID]
        ,[Result]
        ,[Result short name]
            ,CASE
                WHEN ([Legacy ID] = 'NTID R') and (Result = 'UKIDP-REG04') THEN 'OK'
                WHEN ([Legacy ID] = 'NTID A') and (Result = 'UKIDP-REG03') THEN 'OK'
                WHEN ([Legacy ID] = 'NTID D') and (Result = 'UKIDP-REG05') THEN 'OK'
                WHEN ([Legacy ID] = 'NTID L') and (Result = 'UKIDP-REG06') THEN 'OK'
                WHEN ([Legacy ID] = 'NTID LB') and (Result = 'UKIDP-REG07') THEN 'OK'
                ELSE 'NOK'
            END 'Result correspondance check'        
    FROM [progresSSISdb].[dbo].[Ind]
    left join [progresSSISdb].[dbo].[Events] on [progresSSISdb].[dbo].[Ind].[Individual ID] = [progresSSISdb].[dbo].[Events].Individual
              and [progresSSISdb].[dbo].[Events].[Event] = 'UKIDP-REG02'
        where [progresSSISdb].[dbo].[Ind].[Created On] >= @PeriodStart
        AND [progresSSISdb].[dbo].[Ind].[Created On] < @PeriodEndPlusOne
        AND [Legacy ID] like '%[^0-9]%'
    ) as Temp
  WHERE [Result correspondance check] = 'NOK'