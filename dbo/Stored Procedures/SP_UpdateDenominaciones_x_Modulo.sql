CREATE PROCEDURE [dbo].[SP_UpdateDenominaciones_x_Modulo] 
(
@ID INT, 
@FK_ID_DENOMINACIONES	INT,
@FK_ID_Modulo			INT,
@ACTIVO					BIT
)
AS
BEGIN
	---
	BEGIN TRY
		---
			SET @ID = ISNULL(@ID, 1)

		UPDATE tblDenominaciones_x_Modulo SET 
		FkIdModulo = @FK_ID_Modulo,
		FkIdDenominaciones = @FK_ID_DENOMINACIONES,
		Activo = @ACTIVO, 
		FechaModificacion = CURRENT_TIMESTAMP 
		WHERE FkIdModulo = @FK_ID_Modulo AND
		FkIdDenominaciones = @FK_ID_DENOMINACIONES
		---
		DECLARE @ROW VARCHAR(MAX) = (SELECT * FROM tblDenominaciones_x_Modulo WHERE FkIdModulo = @FK_ID_Modulo AND
		FkIdDenominaciones = @FK_ID_DENOMINACIONES FOR JSON PATH)
		---
		SELECT	  @@ROWCOUNT												AS ROWS_AFFECTED
				, CAST(1 AS BIT)											AS SUCCESS
				, 'Se modifico satisfactoriamente la relacion denominaciones con Modulo!'    			AS ERROR_MESSAGE_SP
				, NULL														AS ERROR_NUMBER_SP
				, CONVERT(INT, ISNULL(SCOPE_IDENTITY(), -1))				AS ID
				, @ROW														AS ROW
		---
	END TRY    
	BEGIN CATCH
		--
		DECLARE @ERROR_MESSAGE VARCHAR(MAX) = ERROR_MESSAGE();
		DECLARE @ERROR_MESSAGE1 VARCHAR(MAX) = '%Unique_denominacion_x_area%';
		--
		IF @ERROR_MESSAGE LIKE @ERROR_MESSAGE1 BEGIN 
			---
			SET @ERROR_MESSAGE = 'La combinacion de denominacion y area ya esta registrada'
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
---