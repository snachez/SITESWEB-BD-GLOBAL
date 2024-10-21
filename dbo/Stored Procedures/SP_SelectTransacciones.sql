---
CREATE   PROCEDURE SP_SelectTransacciones (			 
                                                      @SEARCH					NVARCHAR(MAX)	=	NULL
													, @USUARIO_ID				INT				=	NULL
										         )
AS
BEGIN
	----------------------------------------------------------------------------------------
	--- V A R I A B L E S		F O R M A T E O		F E C H A . . .
	----------------------------------------------------------------------------------------
	DECLARE @TIME_ZONE_FORMAT VARCHAR(90) = dbo.FN_GET_USER_ZONE_REGION_FORMAT(@USUARIO_ID)
	DECLARE @IS_UTC BIT = dbo.FN_IS_DB_UTC_ZONE_FORMAT()
	DECLARE @CURRENT_TIME_ZONE VARCHAR(100) = dbo.FN_DB_UTC_ZONE_FORMAT_NAME()
	----------------------------------------------------------------------------------------
    ---
	SELECT @SEARCH = (CASE WHEN @SEARCH is null THEN '' ELSE @SEARCH END);
	---
	;WITH DATA_INDEXED AS (SELECT  T.[Id]
								 , T.[Nombre]
								 , T.[Fk_Id_Modulo]
								 , CONVERT(VARCHAR(36),NEWID()) AS [Codigo]
								 , T.[Activo]
								 , dbo.FN_CastTimeZoneFormat(@IS_UTC, @CURRENT_TIME_ZONE, @TIME_ZONE_FORMAT, T.FechaCreacion)			AS FechaCreacion
								 , dbo.FN_CastTimeZoneFormat(@IS_UTC, @CURRENT_TIME_ZONE, @TIME_ZONE_FORMAT, T.FechaModificacion)		AS FechaModificacion
							FROM [tblTransacciones] T
							LEFT JOIN (
								SELECT MT.Fk_Id_Transaccion
								FROM tblMatrizAtribucion_Transaccion MT
								GROUP BY MT.Fk_Id_Transaccion
								HAVING MAX(CAST(MT.Activo AS INT)) = 0 -- Todos deben ser 0
							) MT
							ON T.Id = MT.Fk_Id_Transaccion
							WHERE MT.Fk_Id_Transaccion IS NOT NULL
							   OR NOT EXISTS (
									SELECT 1
									FROM tblMatrizAtribucion_Transaccion MT2
									WHERE MT2.Fk_Id_Transaccion = T.Id
								)
							AND (
								T.Activo = (CASE 
											   WHEN @SEARCH = 'Activo' THEN 1
											   WHEN @SEARCH = 'Inactivo' THEN 0 
											 END)
								OR T.Id LIKE CONCAT('%', ISNULL(@SEARCH, T.Id), '%')
								OR T.Nombre LIKE CONCAT('%', ISNULL(@SEARCH, T.Nombre), '%')
							))
	SELECT * INTO #tmpTblDataResult FROM DATA_INDEXED
	---
	DECLARE @JSON_RESULT NVARCHAR(MAX) = (SELECT * FROM #tmpTblDataResult ORDER BY Nombre asc FOR JSON PATH)
	---
	DROP TABLE #tmpTblDataResult
	---
	SELECT @JSON_RESULT AS JSON_RESULT_SELECT
	---
END