USE [DSBT_Permits]
GO
/****** Object:  UserDefinedFunction [dbo].[ParseStringList]    Script Date: 09.08.2021 14:48:14 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER Function [dbo].[ParseStringList]  (@StringArray nvarchar(max) )  
Returns @tbl_string Table  (ParsedString nvarchar(max))  As  

BEGIN 

DECLARE @end Int,
        @start Int

SET @stringArray =  @StringArray + ',' 
SET @start=1
SET @end=1

WHILE @end<Len(@StringArray)
    BEGIN
        SET @end = CharIndex(',', @StringArray, @end)
        INSERT INTO @tbl_string 
            SELECT
                Substring(@StringArray, @start, @end-@start)

        SET @start=@end+1
        SET @end = @end+1
    END

RETURN
END
