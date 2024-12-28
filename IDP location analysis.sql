SELECT [Individual ID]
      ,[Full name]
      ,[Registration Group ID]
      ,[Age]
      ,[Sex]
      ,[Legal Status]
      ,[Arrival date]
      ,[Legacy ID]
      ,[Date of birth]
      ,[Nationality]
      ,[Phone number]
      ,CurrentAddr.[Location level 1] as 'Region current'
      ,OriginAddr.[Location level 1] as 'Region origin'
  FROM [progresSSISdb].[dbo].[Ind]
  left join [progresSSISdb].[dbo].[Addr] AS CurrentAddr
        on [progresSSISdb].[dbo].[Ind].[Individual ID] = CurrentAddr.[Individual]
        and CurrentAddr.[Address type] like '%current%'
  left join [progresSSISdb].[dbo].[Addr] AS OriginAddr
        on [progresSSISdb].[dbo].[Ind].[Individual ID] = CurrentAddr.[Individual]
        and OriginAddr.[Address type] like '%origin%'        
  where [Relationship to Focal Point] = 'Focal Point'
  and [Legal Status] = 'Internally displaced person'