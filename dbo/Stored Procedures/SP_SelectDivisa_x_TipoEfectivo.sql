---
CREATE   PROCEDURE usp_SelectDivisa_x_TipoEfectivo(    
															  @ID							INT  =	NULL
															, @FK_ID_DIVISA			        INT  =	NULL
															, @FK_ID_TIPOEFECTIVO			INT  =	NULL
															, @ACTIVO						BIT  =	NULL
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
	DECLARE @JSONRESULT NVARCHAR(MAX) = (SELECT     DxT.Id						AS [Id]											
												  , DxT.Activo					AS [Activo]
												  , dbo.FN_CastTimeZoneFormat(@IS_UTC, @CURRENT_TIME_ZONE, @TIME_ZONE_FORMAT, DxT.FechaCreacion)			AS [FechaCreacion]
												  , dbo.FN_CastTimeZoneFormat(@IS_UTC, @CURRENT_TIME_ZONE, @TIME_ZONE_FORMAT, DxT.FechaModificacion)		AS [FechaModificacion]

												  , DI.Id						AS [Divisa.Id]
												  , DI.Nombre					AS [Divisa.Nombre]
												  , DI.Nomenclatura			    AS [Divisa.Nomenclatura]
												  , DI.Simbolo					AS [Divisa.Simbolo]
												  , DI.Descripcion				AS [Divisa.Descripcion]
												  , DI.Activo					AS [Divisa.Activo]
												  , dbo.FN_CastTimeZoneFormat(@IS_UTC, @CURRENT_TIME_ZONE, @TIME_ZONE_FORMAT, DI.FechaCreacion)				AS [Divisa.FechaCreacion]
												  , dbo.FN_CastTimeZoneFormat(@IS_UTC, @CURRENT_TIME_ZONE, @TIME_ZONE_FORMAT, DI.FechaModificacion)			AS [Divisa.FechaModificacion]

												  ,TE.[Id]					       AS [TipoEfectivo.Id]
												  ,TE.[Nombre]                     AS [TipoEfectivo.Nombre]
												  ,TE.[Activo]                     AS [TipoEfectivo.Activo]
												  , dbo.FN_CastTimeZoneFormat(@IS_UTC, @CURRENT_TIME_ZONE, @TIME_ZONE_FORMAT, TE.FechaCreacion)				AS [TipoEfectivo.FechaCreacion]
												  , dbo.FN_CastTimeZoneFormat(@IS_UTC, @CURRENT_TIME_ZONE, @TIME_ZONE_FORMAT, TE.FechaModificacion)			AS [TipoEfectivo.FechaModificacion]
								
										FROM tblDivisa_x_TipoEfectivo DxT
										INNER JOIN tblDivisa DI
										ON DxT.FkIdDivisa = DI.Id
										INNER JOIN tblTipoEfectivo TE
										ON DxT.FkIdTipoEfectivo = TE.Id
										WHERE DxT.Id = ISNULL(@ID, DxT.Id)		
										AND DxT.Activo = ISNULL(@ACTIVO, DxT.Activo)
										AND DxT.FkIdDivisa = ISNULL(@FK_ID_DIVISA, DxT.FkIdDivisa)
										AND DxT.FkIdTipoEfectivo = ISNULL(@FK_ID_TIPOEFECTIVO, DxT.FkIdTipoEfectivo)
										FOR JSON PATH)
	---
	SELECT @JSONRESULT AS DENOMINACIONES_X_AREAS_JSONRESULT
	---
END