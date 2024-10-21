---
CREATE   PROCEDURE SP_SelectCuentasInternas_x_GrupoAgencias(    
																		  @ID						NVARCHAR(MAX)  =	NULL
																		, @FK_ID_GRUPO				NVARCHAR(MAX)  =	NULL
																		, @FK_ID_CUENTA				NVARCHAR(MAX)  =	NULL
																		, @CODIGO_GRUPO_CUENTA		NVARCHAR(MAX)  =	NULL
																		, @CODIGO_GRUPO				NVARCHAR(MAX)  =	NULL
																		, @CODIGO_CUENTA			NVARCHAR(MAX)  =	NULL
																		, @ACTIVO					NVARCHAR(MAX)  =	NULL
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
	;WITH DATA_INDEXED AS (				SELECT   CGA.Id							 AS [Id]
												--, CGA.FkIdCuentaInterna			 AS [FkIdCuentaInterna]
												--, CGA.FkIdGrupoAgencias			 AS [FkIdGrupoAgencias]
												, CGA.Codigo					 AS [Codigo]
												, CGA.Activo					 AS [Activo]
												, dbo.FN_CastTimeZoneFormat(@IS_UTC, @CURRENT_TIME_ZONE, @TIME_ZONE_FORMAT, CGA.FechaCreacion)			AS [FechaCreacion]
												, dbo.FN_CastTimeZoneFormat(@IS_UTC, @CURRENT_TIME_ZONE, @TIME_ZONE_FORMAT, CGA.FechaModificacion)		AS [FechaModificacion]

												, C.Id							 AS [CuentaInterna.Id]
												, C.NumeroCuenta				 AS [CuentaInterna.NumeroCuenta]
												, C.Codigo						 AS [CuentaInterna.Codigo]
												--, C.FkIdDivisa					 AS [CuentaInterna.FkIdDivisa]
												, C.Activo						 AS [CuentaInterna.Activo]
												, dbo.FN_CastTimeZoneFormat(@IS_UTC, @CURRENT_TIME_ZONE, @TIME_ZONE_FORMAT, C.FechaCreacion)			AS [CuentaInterna.FechaCreacion]
												, dbo.FN_CastTimeZoneFormat(@IS_UTC, @CURRENT_TIME_ZONE, @TIME_ZONE_FORMAT, C.FechaModificacion)		AS [CuentaInterna.FechaModificacion]

												, D.Id							 AS [CuentaInterna.Divisa.Id]
												, D.Nombre						 AS [CuentaInterna.Divisa.Nombre]
												, D.Nomenclatura				 AS [CuentaInterna.Divisa.Nomenclatura]
												, D.Simbolo						 AS [CuentaInterna.Divisa.Simbolo]
												, D.Descripcion					 AS [CuentaInterna.Divisa.Descripcion]
												, D.Activo						 AS [CuentaInterna.Divisa.Activo]
												, dbo.FN_CastTimeZoneFormat(@IS_UTC, @CURRENT_TIME_ZONE, @TIME_ZONE_FORMAT, D.FechaCreacion)			AS [CuentaInterna.Divisa.FechaCreacion]
												, dbo.FN_CastTimeZoneFormat(@IS_UTC, @CURRENT_TIME_ZONE, @TIME_ZONE_FORMAT, D.FechaModificacion)		AS [CuentaInterna.Divisa.FechaModificacion]

												, G.Id							 AS [GrupoAgencia.Id]
												, G.Nombre						 AS [GrupoAgencia.Nombre]
												, G.Codigo						 AS [GrupoAgencia.Codigo]
												, G.EnviaRemesas				 AS [GrupoAgencia.EnviaRemesas]
												, G.SolicitaRemesas				 AS [GrupoAgencia.SolicitaRemesas]
												, G.Activo						 AS [GrupoAgencia.Activo]
												, dbo.FN_CastTimeZoneFormat(@IS_UTC, @CURRENT_TIME_ZONE, @TIME_ZONE_FORMAT, G.FechaCreacion)			AS [GrupoAgencia.FechaCreacion]
												, dbo.FN_CastTimeZoneFormat(@IS_UTC, @CURRENT_TIME_ZONE, @TIME_ZONE_FORMAT, G.FechaModificacion)		AS [GrupoAgencia.FechaModificacion]

												, ROW_NUMBER() OVER(ORDER BY G.Id) AS [INDEX]

										FROM tblCuentaInterna_x_GrupoAgencias CGA
										INNER JOIN tblGrupoAgencia G
										ON CGA.FkIdGrupoAgencias = G.Id
										INNER JOIN tblCuentaInterna C
										ON CGA.FkIdCuentaInterna = C.Id
										INNER JOIN tblDivisa D
										ON C.FkIdDivisa = D.Id
										WHERE CGA.Id = ISNULL(@ID, CGA.Id) 
										AND CGA.FkIdGrupoAgencias = ISNULL(@FK_ID_GRUPO, CGA.FkIdGrupoAgencias)
										AND CGA.FkIdCuentaInterna = ISNULL(@FK_ID_CUENTA, CGA.FkIdCuentaInterna)
										AND CGA.Codigo = ISNULL(@CODIGO_GRUPO_CUENTA, CGA.Codigo)
										AND C.Codigo = ISNULL(@CODIGO_CUENTA, C.Codigo)
										AND G.Codigo = ISNULL(@CODIGO_GRUPO, G.Codigo)
										AND CGA.Activo = ISNULL(@ACTIVO, CGA.Activo))
	SELECT * INTO #tmpTblDataResult FROM DATA_INDEXED;
	---
	DECLARE @JSON_RESULT NVARCHAR(MAX) = (SELECT * FROM #tmpTblDataResult FOR JSON PATH)
	---
	DROP TABLE #tmpTblDataResult
	---
	SELECT @JSON_RESULT AS JSON_GRUPO_AGENCIAS
	---
END