CREATE   PROCEDURE SP_ValidateCuentasInternas_x_GrupoAgencias(    
																		  @FK_ID_GRUPO				NVARCHAR(MAX)  =	NULL
																		, @NUMERO_CUENTA			NVARCHAR(MAX)  =	NULL
																		, @USUARIO_ID				INT			   =	NULL
																  )
AS
BEGIN

	BEGIN TRY

	----------------------------------------------------------------------------------------
	--- V A R I A B L E S		F O R M A T E O		F E C H A . . .
	----------------------------------------------------------------------------------------
	DECLARE @TIME_ZONE_FORMAT VARCHAR(90) = dbo.FN_GET_USER_ZONE_REGION_FORMAT(@USUARIO_ID)
	DECLARE @IS_UTC BIT = dbo.FN_IS_DB_UTC_ZONE_FORMAT()
	DECLARE @CURRENT_TIME_ZONE VARCHAR(100) = dbo.FN_DB_UTC_ZONE_FORMAT_NAME()
	----------------------------------------------------------------------------------------
	
	---Declaracion Variables
    DECLARE @MetodoTemporal NVARCHAR(MAX) = 'SP_ValidateCuentasInternas_x_GrupoAgencias';
	DECLARE @IdDato INT = -1;

	DECLARE @NEW_ROW NVARCHAR(MAX) = (  SELECT   CGA.Id				         AS [Id]
												, CGA.FkIdCuentaInterna			 AS [FkIdCuentaInterna]
												, CGA.FkIdGrupoAgencias			 AS [FkIdGrupoAgencias]
												, CGA.Activo					 AS [Activo]
												, C.NumeroCuenta				 AS [CuentaInterna.NumeroCuenta]

										FROM tblCuentaInterna_x_GrupoAgencias CGA
										INNER JOIN tblGrupoAgencia G
										ON CGA.FkIdGrupoAgencias = G.Id
										INNER JOIN tblCuentaInterna C
										ON CGA.FkIdCuentaInterna = C.Id
										INNER JOIN tblDivisa D
										ON C.FkIdDivisa = D.Id
										WHERE CGA.FkIdGrupoAgencias = ISNULL(@FK_ID_GRUPO, CGA.FkIdGrupoAgencias)
										AND C.NumeroCuenta = ISNULL(@NUMERO_CUENTA, C.Codigo)FOR JSON PATH)

     DECLARE @NEW_ROW_Cuentas_x_grupos  NVARCHAR(MAX) = (SELECT				  CI.Id						AS [Id]
												, CI.NumeroCuenta			AS [NumeroCuenta]
												, CI.Codigo					AS [Codigo]
												, CI.FkIdDivisa				AS [FkIdDivisa]
												, CI.Activo					AS [Activo]
												, dbo.FN_CastTimeZoneFormat(@IS_UTC, @CURRENT_TIME_ZONE, @TIME_ZONE_FORMAT, CI.FechaCreacion)			AS [FechaCreacion]
												, dbo.FN_CastTimeZoneFormat(@IS_UTC, @CURRENT_TIME_ZONE, @TIME_ZONE_FORMAT, CI.FechaModificacion)		AS [FechaModificacion]

												, DV.Id						AS [Divisa.Id]
												, DV.Nombre					AS [Divisa.Nombre]
												, DV.Nomenclatura			AS [Divisa.Nomenclatura]
												, DV.Simbolo				AS [Divisa.Simbolo]
												, DV.Descripcion			AS [Divisa.Descripcion]
												, DV.Activo					AS [Divisa.Activo]
												, dbo.FN_CastTimeZoneFormat(@IS_UTC, @CURRENT_TIME_ZONE, @TIME_ZONE_FORMAT, DV.FechaCreacion)			AS [Divisa.FechaCreacion]
												, dbo.FN_CastTimeZoneFormat(@IS_UTC, @CURRENT_TIME_ZONE, @TIME_ZONE_FORMAT, DV.FechaModificacion)		AS [Divisa.FechaModificacion]

												FROM tblCuentaInterna CI
												INNER JOIN tblDivisa DV
												ON CI.FkIdDivisa = DV.Id
												WHERE CI.NumeroCuenta = ISNULL(@NUMERO_CUENTA, CI.NumeroCuenta)
												FOR JSON PATH)

	---
	IF (ISNULL(@NEW_ROW_Cuentas_x_grupos, 'NULL') <> 'NULL')
	BEGIN

	    DECLARE @ERROR_NUMBER NVARCHAR(MAX);
		SET @ERROR_NUMBER = ERROR_NUMBER();

		EXEC SP_Select_Mensajes_Emergentes_Para_SP 
		@ROWS_AFFECTED = 0,
		@SUCCESS = 1,
		@ERROR_NUMBER_SP = @ERROR_NUMBER,
		@CONSTRAINT_TRIGGER_NAME = 'Existe cuenta grupo',
		@ID = -1,
		@ROW = NULL,
		@Metodo = @MetodoTemporal, 
		@TipoMensaje = 'Error', 
		@ErrorMensaje = 'Existe cuenta grupo',
		@ModeJson = 0;		
		---
	END
	ELSE IF (ISNULL(@NEW_ROW, 'NULL') <> 'NULL')
	BEGIN
		---
		
		EXEC SP_Select_Mensajes_Emergentes_Para_SP 
		@ROWS_AFFECTED = @@ROWCOUNT,
		@SUCCESS = 1,
		@ERROR_NUMBER_SP = NULL,
		@CONSTRAINT_TRIGGER_NAME = NULL,
		@ID = @IdDato,
		@ROW = @NEW_ROW,
		@Metodo = @MetodoTemporal, 
		@TipoMensaje = 'Exitoso', 
		@ErrorMensaje = NULL,
		@ModeJson = 0;

		---
	END
	ELSE
	BEGIN
	     SELECT	  @@ROWCOUNT												AS ROWS_AFFECTED
				, CAST(0 AS BIT)											AS SUCCESS
				, ''                                                        AS ERROR_TITLE_SP
				, ''										                AS ERROR_MESSAGE_SP
				, NULL														AS ERROR_NUMBER_SP
				, CONVERT(INT, ISNULL(SCOPE_IDENTITY(), -1))				AS ID
				, @NEW_ROW													AS ROW
	END
		---
	END TRY    
	BEGIN CATCH
		--
	     SELECT	  @@ROWCOUNT												AS ROWS_AFFECTED
				, CAST(0 AS BIT)											AS SUCCESS
				, ''                                                        AS ERROR_TITLE_SP
				, ''										                AS ERROR_MESSAGE_SP
				, NULL														AS ERROR_NUMBER_SP
				, CONVERT(INT, ISNULL(SCOPE_IDENTITY(), -1))				AS ID
				, @NEW_ROW													AS ROW
		--   
	END CATCH
END