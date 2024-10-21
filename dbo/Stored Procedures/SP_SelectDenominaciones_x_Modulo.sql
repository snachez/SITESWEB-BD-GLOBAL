--
CREATE   PROCEDURE usp_SelectDenominaciones_x_Modulo(    
																  @ID							INT  =	NULL
																, @FK_ID_DENOMINACIONES			INT  =	NULL
																, @FK_ID_Modulo					INT  =	NULL
																, @ACTIVO						BIT  =	NULL
																, @USUARIO_ID					INT  =	NULL
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
	DECLARE @JSONRESULT NVARCHAR(MAX) = (SELECT     DxA.Id						AS [Id]											
												  , DxA.Activo					AS [Activo]
												  , dbo.FN_CastTimeZoneFormat(@IS_UTC, @CURRENT_TIME_ZONE, @TIME_ZONE_FORMAT, DxA.FechaCreacion)			AS [FechaCreacion]
												  , dbo.FN_CastTimeZoneFormat(@IS_UTC, @CURRENT_TIME_ZONE, @TIME_ZONE_FORMAT, DxA.FechaModificacion)		AS [FechaModificacion]

												  , D.Id						AS [Denominaciones.Id]
												  , D.Nombre					AS [Denominaciones.Nombre]
												  , D.ValorNominal				AS [Denominaciones.ValorNominal]
												  , D.BMO    				    AS [Denominaciones.BMO]
												  , D.IdDivisa					AS [Denominaciones.IdDivisa]
												  , D.Imagen					AS [Denominaciones.Imagen]																						
												  , D.Activo					AS [Denominaciones.Activo]
												  , dbo.FN_CastTimeZoneFormat(@IS_UTC, @CURRENT_TIME_ZONE, @TIME_ZONE_FORMAT, D.FechaCreacion)				AS [Denominaciones.FechaCreacion]
												  , dbo.FN_CastTimeZoneFormat(@IS_UTC, @CURRENT_TIME_ZONE, @TIME_ZONE_FORMAT, D.FechaModificacion)			AS [Denominaciones.FechaModificacion]

												  , DI.Id						AS [Divisa.Id]
												  , DI.Nombre					AS [Divisa.Nombre]
												  , DI.Nomenclatura			    AS [Divisa.Nomenclatura]
												  , DI.Simbolo					AS [Divisa.Simbolo]
												  , DI.Descripcion				AS [Divisa.Descripcion]
												  , DI.Activo					AS [Divisa.Activo]
												  , dbo.FN_CastTimeZoneFormat(@IS_UTC, @CURRENT_TIME_ZONE, @TIME_ZONE_FORMAT, DI.FechaCreacion)				AS [Divisa.FechaCreacion]
												  , dbo.FN_CastTimeZoneFormat(@IS_UTC, @CURRENT_TIME_ZONE, @TIME_ZONE_FORMAT, DI.FechaModificacion)			AS [Divisa.FechaModificacion]

												  , A.Id						AS [Modulo.Id]
												  , A.Nombre					AS [Modulo.Nombre]
												  , dbo.FN_CastTimeZoneFormat(@IS_UTC, @CURRENT_TIME_ZONE, @TIME_ZONE_FORMAT, A.FechaCreacion)				AS [Modulo.FechaCreacion]
												  , dbo.FN_CastTimeZoneFormat(@IS_UTC, @CURRENT_TIME_ZONE, @TIME_ZONE_FORMAT, A.FechaModificacion)			AS [Modulo.FechaModificacion]

								                  , TE.Id						AS [TipoEfectivo.Id]
												  , TE.Nombre					AS [TipoEfectivo.Nombre]	
												  , TE.Activo					AS [TipoEfectivo.Activo]
												  , dbo.FN_CastTimeZoneFormat(@IS_UTC, @CURRENT_TIME_ZONE, @TIME_ZONE_FORMAT, TE.FechaCreacion)				AS [TipoEfectivo.FechaCreacion]
												  , dbo.FN_CastTimeZoneFormat(@IS_UTC, @CURRENT_TIME_ZONE, @TIME_ZONE_FORMAT, TE.FechaModificacion)			AS [TipoEfectivo.FechaModificacion]

										FROM tblDenominaciones_x_Modulo DxA
										INNER JOIN tblDenominaciones D
										ON DxA.FkIdDenominaciones = D.Id
										INNER JOIN tblModulo A
										ON DxA.FkIdModulo = A.Id		
										INNER JOIN tblDivisa DI
										ON D.IdDivisa = DI.Id
										INNER JOIN tblTipoEfectivo TE
										ON D.BMO = TE.Id
										WHERE DxA.Id = ISNULL(@ID, DxA.Id)		
										AND DxA.Activo = ISNULL(@ACTIVO, DxA.Activo)
										AND DxA.FkIdModulo = ISNULL(@FK_ID_Modulo, DxA.FkIdModulo)
										AND DxA.FkIdDenominaciones = ISNULL(@FK_ID_DENOMINACIONES, DxA.FkIdDenominaciones)
										FOR JSON PATH)
	---
	SELECT @JSONRESULT AS DENOMINACIONES_X_Modulo_JSONRESULT
	---
END