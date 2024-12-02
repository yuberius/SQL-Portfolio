SELECT [Process status]
      ,[Individual ID]
      ,[Full name]
      ,[Registration Group ID]
  FROM [progresSSISdb].[dbo].[Ind]
  where [Full name] like '%[^йцукенгґшщзхїфівапролджєячсмитьбю'', ]%'

SELECT [Reception ID]
      ,[Full name]
      ,[Created on]
      ,[Reception location]
  FROM [progresSSISdb].[dbo].[RCP]
  where [Full name]  like '%[^йцукенгґшщзхїфівапролджєячсмитьбю'', ]%'