DECLARE @PeriodEnd as varchar(100) = '20241021 00:00:00.000' COLLATE Ukrainian_100_CI_AS;

DECLARE @exclusionTable TABLE (Individual nvarchar(20) COLLATE Ukrainian_100_CI_AS);
insert into @exclusionTable values('1E1-00009173'),('95C-00150057'),('AA6-00159541'),
  ('AA6-00159247'),('1E1-00011803'),('1E1-00003519'),('1E1-00021147'),('1E1-00181827'),
  ('22D-00068067'),('1E1-00003488'),('95C-00189571'),('1E1-00009191'),('1E1-00011786'),
  ('1E1-00012194'),('1E1-00015154'),('1E1-00000193'),('1E1-00003676'),('1E1-00000194'),
  ('95C-00126261'),('AA6-00159024'),('1E1-00003695'),('1E1-00003544')

PRINT '1. Missing (Current) Address'
  SELECT [Individual ID] as 'Individuals with Missing Current Address'
    FROM [progresSSISdb].[dbo].[Ind]
    where [Created On] < @PeriodEnd
    AND
    [Individual ID] not in (
      SELECT * FROM @exclusionTable
    )
EXCEPT
  SELECT [Individual]
    FROM [progresSSISdb].[dbo].[Addr]
    JOIN [progresSSISdb].[dbo].[Ind] on [progresSSISdb].[dbo].[Ind].[Individual ID] = [progresSSISdb].[dbo].[Addr].Individual
    where (
      [Address Type] = 'Country of Residence - Current'
      OR
      [Address Type] = 'Current displacement address – IDP'
      )
      AND
      [progresSSISdb].[dbo].[Ind].[Created On] < @PeriodEnd

PRINT '2. Address recorded with Address type which differs from: Current displacement address – IDP, Previous displacement address – IDP, Original displacement address – IDP, Country of Residence – Current or Country of Residence – Earlier'
SELECT count(1),[Address Type]
    FROM [progresSSISdb].[dbo].[Addr]
    where [Individual] in (
        SELECT [Individual ID]
            FROM [progresSSISdb].[dbo].[Ind]
            where [Created on] < @PeriodEnd
    )
    group by [Address Type]

PRINT '3. Wrong Address type for IDP individuals'
  SELECT [Individual ID] as 'Wrong Address type for IDP individuals'
    FROM [progresSSISdb].[dbo].[Ind]
    where [progresSSISdb].[dbo].[Ind].[Created On] < @PeriodEnd
    AND
    [Legal Status] = 'Internally displaced person'
    AND
    [Individual ID] not in (
      SELECT * FROM @exclusionTable
    )
EXCEPT
  SELECT [Individual]
    FROM [progresSSISdb].[dbo].[Addr]
    JOIN [progresSSISdb].[dbo].[Ind] on [progresSSISdb].[dbo].[Ind].[Individual ID] = [progresSSISdb].[dbo].[Addr].Individual
    where [Address Type] in (
          'Current displacement address – IDP',
          'Previous displacement address – IDP',
          'Original displacement address – IDP'
      )
      AND
      [progresSSISdb].[dbo].[Ind].[Created On] < @PeriodEnd

PRINT '4. Wrong Address type for IDP-like, Returned IDP, Returnee, Other of concern individuals'
  SELECT [Individual ID] as 'Wrong Address type for IDP-like, Returned IDP, Returnee, Other of concern'
    FROM [progresSSISdb].[dbo].[Ind]
    where [progresSSISdb].[dbo].[Ind].[Created On] < @PeriodEnd
    AND
    [Legal Status] in (
      'Returnee',
      'IDP-like',
      'Returned IDP'
    )
    AND
    [Individual ID] not in (
      SELECT * FROM @exclusionTable
    )
EXCEPT
  SELECT [Individual]
    FROM [progresSSISdb].[dbo].[Addr]
    JOIN [progresSSISdb].[dbo].[Ind] on [progresSSISdb].[dbo].[Ind].[Individual ID] = [progresSSISdb].[dbo].[Addr].Individual
    where [Address Type] in (
          'Country of Residence - Current',
          'Country of Residence - Earlier'
      )
      AND
      [progresSSISdb].[dbo].[Ind].[Created On] < @PeriodEnd

PRINT '5. Missing Current displacement address – IDP for IDP individuals'
  SELECT [Individual ID] as 'Missing Current displacement address – IDP for IDP individuals'
    FROM [progresSSISdb].[dbo].[Ind]
    where [progresSSISdb].[dbo].[Ind].[Created On] < @PeriodEnd
    AND
    [Legal Status] = 'Internally displaced person'
    AND
    [Individual ID] not in (
      SELECT * FROM @exclusionTable
    )
EXCEPT
  SELECT [Individual]
    FROM [progresSSISdb].[dbo].[Addr]
    JOIN [progresSSISdb].[dbo].[Ind] on [progresSSISdb].[dbo].[Ind].[Individual ID] = [progresSSISdb].[dbo].[Addr].Individual
    where [Address Type] = 'Current displacement address – IDP'
      AND
      [progresSSISdb].[dbo].[Ind].[Created On] < @PeriodEnd

PRINT '6. Missing Original displacement address – IDP for IDP individuals'
  SELECT [Individual ID] as 'Missing Original displacement address – IDP for IDP individuals'
    FROM [progresSSISdb].[dbo].[Ind]
    where [progresSSISdb].[dbo].[Ind].[Created On] < @PeriodEnd
    AND
    [Legal Status] = 'Internally displaced person'
    AND
    [Individual ID] not in (
      SELECT * FROM @exclusionTable
    )
EXCEPT
  SELECT [Individual]
    FROM [progresSSISdb].[dbo].[Addr]
    JOIN [progresSSISdb].[dbo].[Ind] on [progresSSISdb].[dbo].[Ind].[Individual ID] = [progresSSISdb].[dbo].[Addr].Individual
    where [Address Type] = 'Original displacement address – IDP'
      AND
      [progresSSISdb].[dbo].[Ind].[Created On] < @PeriodEnd
  
PRINT '7. Missing Country of residence – Current address for IDP-like, Returned IDP, Returnee, Other of concern individuals'
  SELECT [Individual ID] as 'Missing Country of residence – Current address for IDP-like, Returned IDP, Returnee, Other of concern individuals'
    FROM [progresSSISdb].[dbo].[Ind]
    where [progresSSISdb].[dbo].[Ind].[Created On] < @PeriodEnd
    AND
    [Legal Status] in (
      'Returnee',
      'IDP-like',
      'Returned IDP',
      'Other of concern'
    )
    AND
    [Individual ID] not in (
      SELECT * FROM @exclusionTable
    )
EXCEPT
  SELECT [Individual]
    FROM [progresSSISdb].[dbo].[Addr]
    JOIN [progresSSISdb].[dbo].[Ind] on [progresSSISdb].[dbo].[Ind].[Individual ID] = [progresSSISdb].[dbo].[Addr].Individual
    where [Address Type] = 'Country of Residence - Current'
      AND
      [progresSSISdb].[dbo].[Ind].[Created On] < @PeriodEnd

PRINT '8. Missing Country of residence – Earlier address for IDP-like, Returned IDP, Returnee individuals'
  SELECT [Individual ID] as 'Missing Country of residence – Earlier address for IDP-like, Returned IDP, Returnee individuals'
    FROM [progresSSISdb].[dbo].[Ind]
    where [progresSSISdb].[dbo].[Ind].[Created On] < @PeriodEnd
    AND
    [Legal Status] in (
      'Returnee',
      'IDP-like',
      'Returned IDP'
    )
    AND
    [Individual ID] not in (
      SELECT * FROM @exclusionTable
    )
EXCEPT
  SELECT [Individual]
    FROM [progresSSISdb].[dbo].[Addr]
    JOIN [progresSSISdb].[dbo].[Ind] on [progresSSISdb].[dbo].[Ind].[Individual ID] = [progresSSISdb].[dbo].[Addr].Individual
    where [Address Type] = 'Country of Residence - Earlier'
      AND
      [progresSSISdb].[dbo].[Ind].[Created On] < @PeriodEnd

PRINT '9. Current address not in Ukraine or Luhansk region or Crimea'
SELECT [Individual] as 'Current address not in Ukraine or Luhanska or Crimea'
  FROM [progresSSISdb].[dbo].[Addr]
  where [Address type] like '%current%'
  AND (
    Country <> 'Ukraine'
    OR
    [Location level 1] in ('Avtonomna Respublika Krym','Luhanska')
  )
  AND
  [Individual] in (
        SELECT [Individual ID]
            FROM [progresSSISdb].[dbo].[Ind]
            where [Created on] < @PeriodEnd
    ) 
  AND
    [Individual] not in (
      SELECT * FROM @exclusionTable
    )

PRINT '10. Returnees with previous address in Ukraine'
SELECT [Individual ID] as 'Returnees with previous address in Ukraine'
  FROM [progresSSISdb].[dbo].[Ind]
  where [Legal Status] = 'Returnee'
  AND [Individual ID] in (
        SELECT [Individual]
            FROM [progresSSISdb].[dbo].[Addr]
            where [Address type] = 'Country of Residence - Earlier'
            and Country = 'Ukraine'
  )
  AND
    [Individual ID] not in (
      SELECT * FROM @exclusionTable
    )
  AND
  [progresSSISdb].[dbo].[Ind].[Created On] < @PeriodEnd

PRINT '11. IDPs with addresses outside Ukraine'
SELECT [Individual ID] as 'IDPs with addresses outside Ukraine'
  FROM [progresSSISdb].[dbo].[Ind]
  where [Legal Status] in ('Internally displaced person','Returned IDP','Other of concern')
  and [Individual ID] in (
        SELECT [Individual]
            FROM [progresSSISdb].[dbo].[Addr]
            where Country <> 'Ukraine'
  )
  AND
    [Individual ID] not in (
      SELECT * FROM @exclusionTable
    )
  AND
  [progresSSISdb].[dbo].[Ind].[Created On] < @PeriodEnd