--
CREATE   PROCEDURE [dbo].[SP_InsertCuentaInterna](@NUMERO_CUENTA NVARCHAR(MAX), @FK_ID_DIVISA INT, @USUARIO_ID INT = NULL)
AS
BEGIN
	---
	BEGIN TRY
		---
		INSERT INTO tblCuentaInterna(NumeroCuenta, FkIdDivisa) VALUES(@NUMERO_CUENTA, @FK_ID_DIVISA)
		---
		----------------------------------------------------------------------------------------
		--- V A R I A B L E S		F O R M A T E O		F E C H A . . .
		----------------------------------------------------------------------------------------
		DECLARE @TIME_ZONE_FORMAT VARCHAR(90) = dbo.FN_GET_USER_ZONE_REGION_FORMAT(@USUARIO_ID)
		DECLARE @IS_UTC BIT = dbo.FN_IS_DB_UTC_ZONE_FORMAT()
		DECLARE @CURRENT_TIME_ZONE VARCHAR(100) = dbo.FN_DB_UTC_ZONE_FORMAT_NAME()
		----------------------------------------------------------------------------------------
		DECLARE @NEW_ROW NVARCHAR(MAX) = (	SELECT   C.Id						AS [Id]
												   , C.NumeroCuenta				AS [NumeroCuenta]
												   , C.Codigo					AS [Codigo]
												   , C.FkIdDivisa				AS [FkIdDivisa]
												   , C.Activo					AS [Activo]
												   , dbo.FN_CastTimeZoneFormat(@IS_UTC, @CURRENT_TIME_ZONE, @TIME_ZONE_FORMAT, C.FechaCreacion)			AS [FechaCreacion]
												   , dbo.FN_CastTimeZoneFormat(@IS_UTC, @CURRENT_TIME_ZONE, @TIME_ZONE_FORMAT, C.FechaModificacion)		AS [FechaModificacion]
												   
												   , D.Id						AS [Divisa.Id]
												   , D.Nombre					AS [Divisa.Nombre]
												   , D.Nomenclatura				AS [Divisa.Nomenclatura]
												   , D.Simbolo					AS [Divisa.Simbolo]
												   , D.Descripcion				AS [Divisa.Descripcion]
												   , D.Activo					AS [Divisa.Activo]

												   , dbo.FN_CastTimeZoneFormat(@IS_UTC, @CURRENT_TIME_ZONE, @TIME_ZONE_FORMAT, D.FechaCreacion)			AS [Divisa.FechaCreacion]
												   , dbo.FN_CastTimeZoneFormat(@IS_UTC, @CURRENT_TIME_ZONE, @TIME_ZONE_FORMAT, D.FechaModificacion)		AS [Divisa.FechaModificacion]

											FROM tblCuentaInterna C
											INNER JOIN tblDivisa D
											ON C.FkIdDivisa = D.Id
											WHERE C.Id = ISNULL(SCOPE_IDENTITY(), -1) FOR JSON PATH)
		---
		SELECT	  @@ROWCOUNT												AS ROWS_AFFECTED
				, CAST(1 AS BIT)											AS SUCCESS
				, ''														AS ERROR_MESSAGE_SP
				, NULL														AS ERROR_NUMBER_SP
				, CONVERT(INT, ISNULL(SCOPE_IDENTITY(), -1))				AS ID
				, @NEW_ROW													AS ROW
		---
	END TRY    
	BEGIN CATCH
		--
		DECLARE @ERROR_MESSAGE NVARCHAR(MAX) = ERROR_MESSAGE();
		DECLARE @ERROR_MESSAGE1 NVARCHAR(MAX) = '%Unique_numero_cuenta%';
		DECLARE @ERROR_MESSAGE2 NVARCHAR(MAX) = '%the value NULL%';
		DECLARE @ERROR_MESSAGE3 NVARCHAR(MAX) = '%FkIdDivisa%';
		--
		IF @ERROR_MESSAGE LIKE @ERROR_MESSAGE1 BEGIN 
			---
			SET @ERROR_MESSAGE = 'El numero de cuenta que intenta ingresar ya existe'
			---
		END
		--
		IF @ERROR_MESSAGE LIKE @ERROR_MESSAGE2 BEGIN 
			---
			IF @ERROR_MESSAGE LIKE '%NumeroCuenta%' BEGIN 
				---
				SET @ERROR_MESSAGE = 'El numero de cuenta es requerido'
				---
			END
			---
			IF @ERROR_MESSAGE LIKE @ERROR_MESSAGE3 BEGIN 
				---
				SET @ERROR_MESSAGE = 'La divisa es requerida'
				---
			END
			---
		END
		--
		SELECT	  0															AS ROWS_AFFECTED
				, CAST(0 AS BIT)											AS SUCCESS
				, @ERROR_MESSAGE											AS ERROR_MESSAGE_SP
				, ERROR_NUMBER()											AS ERROR_NUMBER_SP
				, -1														AS ID
				, NULL														AS ROW

		--   
	END CATCH
	---
END
GO

