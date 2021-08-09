--SELECT count(p.Id) as 'Кількість дозволів'
SELECT count(p.Id) as 'Кількість дозволів', ca.Name as 'Перевізник'

FROM [DSBT_Permits].[dbo].[Permits] p   

left join [DSBT_Permits].dbo.Carrier ca on ca.Id = p.Carrier_Id 

where year(p.application_date) > 2020
   group by p.Carrier_Id, ca.Name  order by 'Кількість дозволів' desc