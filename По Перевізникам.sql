--SELECT count(p.Id) as 'ʳ������ �������'
SELECT count(p.Id) as 'ʳ������ �������', ca.Name as '���������'

FROM�[DSBT_Permits].[dbo].[Permits]�p� �

left join�[DSBT_Permits].dbo.Carrier ca on ca.Id = p.Carrier_Id�

where year(p.application_date) > 2020
� �group by p.Carrier_Id, ca.Name� order by 'ʳ������ �������' desc