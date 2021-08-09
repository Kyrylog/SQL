--По дефолту запрос отображает, если не указывать переменные @PermitCountry_Id или @IssuePoint_Id, по 10 с самым большим количеством Permits.Id

declare @Carrier_Id int --= 59;						   -- Для выбора Carrier. принимает один параметр
,@PermitCountry_Id nvarchar(40)-- = '24'			   -- Для выбора страны. принимает несколько параметров(через запятую без пробелов)
,@IssuePoint_Id nvarchar(500)-- = '14,15'			   -- Для выбора ПВД. принимает несколько параметров(через запятую без пробелов)
,@Date_Year nvarchar(40)-- = '2020,2021' 			   -- Для выбора года (по дефолту все года). принимает несколько параметров(через запятую без пробелов)
,@Date_Month nvarchar(40)--							   -- Для выбора месяца (по дефолту все месяца). принимает несколько параметров(через запятую без пробелов)
;

declare @Par int = 0 -- Параметр для определения показывать по странам(1) или по ПВД(любой не единица и не нулл)
;
if @Par is null
begin
	Set @Par = 1
end

DECLARE @SQL NVARCHAR(MAX) = concat('
	WITH C 
	AS
	(
		Select 
			',iif(@Par = 1, N'PermitCountry_Id', N'IssuePoint_Id'),'
		   ,Carrier_Id
		   ,ROW_NUMBER() OVER(partition by ',iif(@Par = 1, N'PermitCountry_Id', N'IssuePoint_Id'),' order by count([Id]) desc) AS [rownum]
		   ,count([Id])	  as[Count_Id]
		from [DSBT_Permits].[dbo].[Permits]
		where (YEAR([Application_date]) in (Select ParsedString From EAR.dbo.ParseStringList(@Date_Year)) or @Date_Year is null)
		and (MONTH([Application_date]) in (Select ParsedString From EAR.dbo.ParseStringList(@Date_Month)) or @Date_Month is null)
		GROUP BY ',iif(@Par = 1, N'PermitCountry_Id', N'IssuePoint_Id'),' ,Carrier_Id
	)
	Select 
		 pc.[Name]	  as[Name]
		,C.',iif(@Par = 1, N'PermitCountry_Id', N'IssuePoint_Id'),'
		,car.[Id]	  as[Carrier_Id]
		,car.[Name]	  as[Carrier_Name]
		,[Count_Id]	  as[Count_Id]
	from C
	left join ',iif(@Par = 1,N'[DSBT_Permits].[DIM].[PermitCountry]', N'[DSBT_Permits].[DIM].[IssuePoint]'),' pc on pc.Id = ',iif(@Par = 1, N'C.PermitCountry_Id', N'C.IssuePoint_Id'),'
	left join [DSBT_Permits].[dbo].[Carrier] car on car.Id = C.Carrier_Id
	where ',iif(@Carrier_Id is not null, N'',N'[rownum] <= 10 and '),'
	',iif(@Par = 1,N'(PermitCountry_Id in (Select ParsedString From EAR.dbo.ParseStringList(@PermitCountry_Id)) or @PermitCountry_Id is null)',
	N'(IssuePoint_Id in (Select ParsedString From EAR.dbo.ParseStringList(@IssuePoint_Id)) or @IssuePoint_Id is null)'),'
	and (Carrier_Id = @Carrier_Id or @Carrier_Id is null)
	order by ',iif(@Par = 1, N'PermitCountry_Id', N'IssuePoint_Id'),', rownum ;'
	);
	EXECUTE sp_executesql @SQL, N'@PermitCountry_Id nvarchar(200), @IssuePoint_Id nvarchar(200), @Carrier_Id int, @Date_Month nvarchar(200), @Date_Year nvarchar(200)',
								@PermitCountry_Id = @PermitCountry_Id,
								@IssuePoint_Id = @IssuePoint_Id,
								@Carrier_Id = @Carrier_Id,
								@Date_Month = @Date_Month,
								@Date_Year = @Date_Year;
