select [Registration Group ID]
    ,sum([Girls]) 'Girls'
    ,sum ([Boys]) 'Boys'
    ,sum([Women]) 'Women'
    ,sum([Men]) 'Men'
    ,sum([Elderly Women]) 'Elderly Women'
    ,sum([Elderly Men]) 'Elderly Men'
from(
    SELECT [Registration Group ID],
        CASE
            WHEN ([Age] < 18) and (Sex = 'Female') THEN 1
            ELSE 0
        END 'Girls',
        CASE
            WHEN ([Age] < 18) and (Sex = 'Male') THEN 1
            ELSE 0
        END 'Boys',
        CASE
            WHEN ([Age] > 17) and ([Age] < 60) and (Sex = 'Female') THEN 1
            ELSE 0
        END 'Women',
        CASE
            WHEN ([Age] > 17) and ([Age] < 60) and (Sex = 'Male') THEN 1
            ELSE 0
        END 'Men',
        CASE
            WHEN ([Age] > 59) and (Sex = 'Female') THEN 1
            ELSE 0
        END 'Elderly Women',
        CASE
            WHEN ([Age] > 59) and (Sex = 'Male') THEN 1
            ELSE 0
        END 'Elderly Men'
      FROM [progresSSISdb].[dbo].[Ind]
    where [Registration Group ID] in (
            'Reg group IDs' --insert the list of registration group IDs
      )
) as Temp
group by [Registration Group ID]
