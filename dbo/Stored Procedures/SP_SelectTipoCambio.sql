--
CREATE   PROCEDURE SP_SelectTipoCambio (		  @ID		INT = NULL
													, @FECHA	NVARCHAR(10) = NULL
													, @ACTIVO	BIT = NULL
													, @NOMENCLATURA NVARCHAR(5) = NULL
													, @USUARIO_ID INT = NULL
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
	DECLARE @JSON_RESULT NVARCHAR(MAX)
	---
	SET @JSON_RESULT = (
	SELECT 
			  TC.Id								AS [Id]

			, D.Id								AS [DivisaCotizada.Id]
			, D.Nombre							AS [DivisaCotizada.Nombre]
			, D.Nomenclatura					AS [DivisaCotizada.Nomenclatura]
			, D.Simbolo							AS [DivisaCotizada.Simbolo]
			, D.Descripcion						AS [DivisaCotizada.Descripcion]
			, D.Activo							AS [DivisaCotizada.Activo]
			, dbo.FN_CastTimeZoneFormat(@IS_UTC, @CURRENT_TIME_ZONE, @TIME_ZONE_FORMAT, D.FechaCreacion)			AS [DivisaCotizada.FechaCreacion]
			, dbo.FN_CastTimeZoneFormat(@IS_UTC, @CURRENT_TIME_ZONE, @TIME_ZONE_FORMAT, D.FechaModificacion)		AS [DivisaCotizada.FechaModificacion]

			, TC.CompraColones					AS [CompraColones]
			, TC.VentaColones					AS [VentaColones]
			, TC.Activo							AS [Activo]
			, dbo.FN_CastTimeZoneFormat(@IS_UTC, @CURRENT_TIME_ZONE, @TIME_ZONE_FORMAT, TC.FechaCreacion)				AS [FechaCreacion]
			, dbo.FN_CastTimeZoneFormat(@IS_UTC, @CURRENT_TIME_ZONE, @TIME_ZONE_FORMAT, TC.FechaModificacion)			AS [FechaModificacion]

	FROM tblTipoCambio TC
	INNER JOIN tblDivisa D
	ON TC.fk_Id_DivisaCotizada									= D.Id
	WHERE 	ISNULL(@ID, TC.Id)									= TC.Id
	AND		ISNULL(CAST(@FECHA AS DATE), CAST(TC.FechaCreacion AS DATE))		= CAST(TC.FechaCreacion AS DATE)
	AND		ISNULL(@ACTIVO, TC.Activo)							= TC.Activo
	AND		ISNULL(@NOMENCLATURA, D.Nomenclatura)				= D.Nomenclatura
	FOR JSON PATH )
	---
	SELECT @JSON_RESULT AS TIPO_CAMBIO
	---
END