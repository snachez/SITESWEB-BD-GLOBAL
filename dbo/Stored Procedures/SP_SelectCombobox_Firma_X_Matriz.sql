--
CREATE   PROCEDURE SP_SelectCombobox_Firma_X_Matriz(@IdMatriz INT = NULL, @Nombre varchar(50) = NULL, @Activo BIT = NULL, @USUARIO_ID INT = NULL)
AS
BEGIN
	----------------------------------------------------------------------------------------
	--- V A R I A B L E S		F O R M A T E O		F E C H A . . .
	----------------------------------------------------------------------------------------
	DECLARE @TIME_ZONE_FORMAT VARCHAR(90) = dbo.FN_GET_USER_ZONE_REGION_FORMAT(@USUARIO_ID)
	DECLARE @IS_UTC BIT = dbo.FN_IS_DB_UTC_ZONE_FORMAT()
	DECLARE @CURRENT_TIME_ZONE VARCHAR(100) = dbo.FN_DB_UTC_ZONE_FORMAT_NAME()
	----------------------------------------------------------------------------------------
	;WITH DATA_INDEXED AS (SELECT F.[Id]
								 ,F.[Firma]
								 ,F.[MontoDesde]
								 ,F.[MontoHasta]
								 ,F.[Activo]
								 , dbo.FN_CastTimeZoneFormat(@IS_UTC, @CURRENT_TIME_ZONE, @TIME_ZONE_FORMAT, F.[FechaCreacion])		AS [FechaCreacion]
						   FROM [tblFirmas] F
						   LEFT JOIN tblMatrizAtribucion_Firmas  MF
						   ON F.Id = MF.Fk_Id_Firmas 
						   WHERE MF.Fk_Id_MatrizAtribucion = ISNULL(@IdMatriz, MF.Fk_Id_MatrizAtribucion) AND
						   F.Firma = ISNULL(@Nombre, F.Firma) AND
						   MF.Activo = ISNULL(@Activo, MF.Activo))
	SELECT * INTO #tmpTblDataResult FROM DATA_INDEXED
	---
	DECLARE @JSON_RESULT NVARCHAR(MAX) = (SELECT * FROM #tmpTblDataResult FOR JSON PATH)
	---
	DROP TABLE #tmpTblDataResult
	---
	SELECT @JSON_RESULT AS JSON_RESULT_SELECT
	---
END