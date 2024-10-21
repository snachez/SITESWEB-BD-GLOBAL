--
CREATE   PROCEDURE SP_SelectCanton(@IdProvincia INT = NULL, @Nombre varchar(50) = NULL, @USUARIO_ID INT = NULL)
AS
BEGIN
	----------------------------------------------------------------------------------------
	--- V A R I A B L E S		F O R M A T E O		F E C H A . . .
	----------------------------------------------------------------------------------------
	DECLARE @TIME_ZONE_FORMAT VARCHAR(90) = dbo.FN_GET_USER_ZONE_REGION_FORMAT(@USUARIO_ID)
	DECLARE @IS_UTC BIT = dbo.FN_IS_DB_UTC_ZONE_FORMAT()
	DECLARE @CURRENT_TIME_ZONE VARCHAR(100) = dbo.FN_DB_UTC_ZONE_FORMAT_NAME()
	---
	;WITH DATA_INDEXED AS (SELECT [Id]
								 ,[Nombre]
								 ,[fk_Id_Provincia]
								 ,[Activo]
								 , dbo.FN_CastTimeZoneFormat(@IS_UTC, @CURRENT_TIME_ZONE, @TIME_ZONE_FORMAT, [FechaCreacion])		AS 	[FechaCreacion]
								 , dbo.FN_CastTimeZoneFormat(@IS_UTC, @CURRENT_TIME_ZONE, @TIME_ZONE_FORMAT, [FechaModificacion])	AS 	[FechaModificacion]
						   FROM [tblCanton] 
						   WHERE [fk_Id_Provincia] = ISNULL(@IdProvincia, [fk_Id_Provincia]) AND
						   [Nombre] = ISNULL(@Nombre, [Nombre]))
	SELECT * INTO #tmpTblDataResult FROM DATA_INDEXED
	---
	DECLARE @JSON_RESULT NVARCHAR(MAX) = (SELECT * FROM #tmpTblDataResult FOR JSON PATH)
	---
	DROP TABLE #tmpTblDataResult
	---
	SELECT @JSON_RESULT AS JSON_RESULT_SELECT
	---
END