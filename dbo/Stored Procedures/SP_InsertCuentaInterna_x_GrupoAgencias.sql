--
CREATE   PROCEDURE [dbo].[SP_InsertCuentaInterna_x_GrupoAgencias](	  @FK_ID_CUENTA_INTERNA		INT
																	, @FK_ID_GRUPO_AGENCIA		INT
																	, @USUARIO_ID				INT = NULL
															    )
AS
BEGIN
	---
	BEGIN TRY
		---
		INSERT INTO tblCuentaInterna_x_GrupoAgencias(FkIdCuentaInterna, FkIdGrupoAgencias) VALUES (@FK_ID_CUENTA_INTERNA, @FK_ID_GRUPO_AGENCIA)
		---
		----------------------------------------------------------------------------------------
		--- V A R I A B L E S		F O R M A T E O		F E C H A . . .
		----------------------------------------------------------------------------------------
		DECLARE @TIME_ZONE_FORMAT VARCHAR(90) = dbo.FN_GET_USER_ZONE_REGION_FORMAT(@USUARIO_ID)
		DECLARE @IS_UTC BIT = dbo.FN_IS_DB_UTC_ZONE_FORMAT()
		DECLARE @CURRENT_TIME_ZONE VARCHAR(100) = dbo.FN_DB_UTC_ZONE_FORMAT_NAME()
		----------------------------------------------------------------------------------------
		DECLARE @ROW NVARCHAR(MAX) = (SELECT   CGA.Id						 AS [Id]
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
												, G.EnviaRemesas				 AS	[GrupoAgencia.EnviaRemesas]
												, G.SolicitaRemesas				 AS	[GrupoAgencia.SolicitaRemesas]
												, G.Activo						 AS [GrupoAgencia.Activo]
												, dbo.FN_CastTimeZoneFormat(@IS_UTC, @CURRENT_TIME_ZONE, @TIME_ZONE_FORMAT, G.FechaCreacion)			AS [GrupoAgencia.FechaCreacion]
												, dbo.FN_CastTimeZoneFormat(@IS_UTC, @CURRENT_TIME_ZONE, @TIME_ZONE_FORMAT, G.FechaModificacion)		AS [GrupoAgencia.FechaModificacion]

										FROM tblCuentaInterna_x_GrupoAgencias CGA
										INNER JOIN tblGrupoAgencia G
										ON CGA.FkIdGrupoAgencias = G.Id
										INNER JOIN tblCuentaInterna C
										ON CGA.FkIdCuentaInterna = C.Id
										INNER JOIN tblDivisa D
										ON C.FkIdDivisa = D.Id
										WHERE CGA.Id = ISNULL(SCOPE_IDENTITY(), -1)
										FOR JSON PATH)
		---
		SELECT	  @@ROWCOUNT												AS ROWS_AFFECTED
				, CAST(1 AS BIT)											AS SUCCESS
				, ''														AS ERROR_MESSAGE_SP
				, NULL														AS ERROR_NUMBER_SP
				, CONVERT(INT, ISNULL(SCOPE_IDENTITY(), -1))				AS ID
				, @ROW														AS ROW
		---
	END TRY    
	BEGIN CATCH
		--
		DECLARE @ERROR_MESSAGE NVARCHAR(MAX) = ERROR_MESSAGE()
		--
		IF @ERROR_MESSAGE LIKE '%Unique_cuenta_x_grupo%' BEGIN 
			---
			SET @ERROR_MESSAGE = 'El numero de cuenta y el grupo ya se encuentran asociados'
			---
		END
		--
		SELECT	  0															AS ROWS_AFFECTED 
		        ,  CAST(0 AS BIT)											AS SUCCESS
				, @ERROR_MESSAGE											AS ERROR_MESSAGE_SP
				, ERROR_NUMBER()											AS ERROR_NUMBER_SP
				, -1														AS ID
				, NULL														AS ROW

		--   
	END CATCH
	---
END
---
GO

