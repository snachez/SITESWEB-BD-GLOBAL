--
CREATE   PROCEDURE usp_SelectCuentaInterna(    
													  @ID				INT			   =	NULL
													, @NUMERO_CUENTA	NVARCHAR(MAX)  =	NULL
													, @CODIGO			NVARCHAR(MAX)  =	NULL
													, @ACTIVO			BIT			   =	NULL
													, @USUARIO_ID		INT			   =	NULL
												)
AS
BEGIN
	---Declaracion Variables
    DECLARE @MetodoTemporal NVARCHAR(MAX) = 'usp_SelectCuentaInterna';
	DECLARE @IdDato INT = -1;
	----------------------------------------------------------------------------------------
	--- V A R I A B L E S		F O R M A T E O		F E C H A . . .
	----------------------------------------------------------------------------------------
	DECLARE @TIME_ZONE_FORMAT VARCHAR(90) = dbo.FN_GET_USER_ZONE_REGION_FORMAT(@USUARIO_ID)
	DECLARE @IS_UTC BIT = dbo.FN_IS_DB_UTC_ZONE_FORMAT()
	DECLARE @CURRENT_TIME_ZONE VARCHAR(100) = dbo.FN_DB_UTC_ZONE_FORMAT_NAME()
	----------------------------------------------------------------------------------------
	DECLARE @NEW_ROW NVARCHAR(MAX) = (SELECT	  CI.Id						AS [Id]
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
												, dbo.FN_CastTimeZoneFormat(@IS_UTC, @CURRENT_TIME_ZONE, @TIME_ZONE_FORMAT, DV.FechaCreacion)			AS 	[Divisa.FechaCreacion]
												, dbo.FN_CastTimeZoneFormat(@IS_UTC, @CURRENT_TIME_ZONE, @TIME_ZONE_FORMAT, DV.FechaModificacion)		AS 	[Divisa.FechaModificacion]

												FROM tblCuentaInterna CI
												INNER JOIN tblDivisa DV
												ON CI.FkIdDivisa = DV.Id
												WHERE CI.Id = ISNULL(@ID, CI.Id)
												AND Codigo = ISNULL(@CODIGO, Codigo)
												AND CI.NumeroCuenta = ISNULL(@NUMERO_CUENTA, CI.NumeroCuenta)
												AND CI.Activo = ISNULL(@ACTIVO, CI.Activo)FOR JSON PATH)

	---
	if(ISNULL(@NEW_ROW, 'NULL') != 'NULL')
	BEGIN
		---
		
		EXEC usp_Select_Mensajes_Emergentes_Para_SP 
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
	else
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
END