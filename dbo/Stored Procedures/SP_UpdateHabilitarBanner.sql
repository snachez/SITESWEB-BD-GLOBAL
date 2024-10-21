CREATE PROCEDURE [dbo].[SP_UpdateHabilitarBanner] (
                                                @Activo bit
											  , @FechaModificacion VARCHAR(36)
										     )
AS
BEGIN
    ---Declaracion Variables
    DECLARE @MetodoTemporal VARCHAR(MAX) = 'SP_UpdateHabilitarBanner';
    DECLARE @IdDato INT = -1;

	---
	BEGIN TRY
		---
		SET DATEFORMAT 'YMD'
		---
		---
	    BEGIN
			---
			UPDATE tblHabilitarBanner SET Activo = @Activo, FechaModificacion = @FechaModificacion;
			
			---
			SET @IdDato = CONVERT(INT, ISNULL(SCOPE_IDENTITY(), -1));
			---
		END
		---

		EXEC SP_Select_Mensajes_Emergentes_Para_SP 
		@ROWS_AFFECTED = @@ROWCOUNT,
		@SUCCESS = 1,
		@ERROR_NUMBER_SP = NULL,
		@CONSTRAINT_TRIGGER_NAME = NULL,
		@ID = @IdDato,
		@ROW = @IdDato,
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