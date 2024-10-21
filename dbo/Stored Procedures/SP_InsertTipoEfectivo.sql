﻿CREATE   PROCEDURE [dbo].[SP_InsertTipoEfectivo] (@NOMBRE VARCHAR(MAX), @ACTIVO BIT)
AS
BEGIN
	---Declaracion Variables
    DECLARE @MetodoTemporal VARCHAR(MAX) = 'SP_InsertTipoEfectivo';
	DECLARE @IdDato INT = -1;
	
	BEGIN TRY
		---
		INSERT INTO tblTipoEfectivo(Nombre, Activo) VALUES(@NOMBRE, @ACTIVO)
		---
		DECLARE @ROW VARCHAR(MAX) = (SELECT * FROM tblTipoEfectivo WHERE Id = ISNULL(SCOPE_IDENTITY(), -1) FOR JSON PATH)
		SET @IdDato = CONVERT(INT, ISNULL(SCOPE_IDENTITY(), -1));
		---

		EXEC SP_Select_Mensajes_Emergentes_Para_SP 
		@ROWS_AFFECTED = @@ROWCOUNT,
		@SUCCESS = 1,
		@ERROR_NUMBER_SP = NULL,
		@CONSTRAINT_TRIGGER_NAME = NULL,
		@ID = @IdDato,
		@ROW = @ROW,
		@Metodo = @MetodoTemporal, 
		@TipoMensaje = 'Exitoso', 
		@ErrorMensaje = NULL,
		@ModeJson = 0;

		---
	END TRY    
	BEGIN CATCH
		--
		DECLARE @ERROR VARCHAR(MAX) = ERROR_MESSAGE();
		DECLARE @ERROR_NUMBER VARCHAR(MAX) = ERROR_NUMBER();

		EXEC SP_Select_Mensajes_Emergentes_Para_SP 
		@ROWS_AFFECTED = 0,
		@SUCCESS = 0,
		@ERROR_NUMBER_SP = @ERROR_NUMBER,
		@CONSTRAINT_TRIGGER_NAME = @ERROR,
		@ID = @IdDato,
		@ROW = NULL,
		@Metodo = @MetodoTemporal, 
		@TipoMensaje = 'Error', 
		@ErrorMensaje = @ERROR,
		@ModeJson = 0;

		--   
	END CATCH
	---
END