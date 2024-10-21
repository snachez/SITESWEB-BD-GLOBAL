CREATE PROCEDURE [dbo].[usp_UpdateModulo] 
(
@ID INT, 
@NOMBRE VARCHAR(MAX), 
@ACTIVO BIT

)
AS
BEGIN
	---
	BEGIN TRY
		---
		UPDATE tblModulo SET 
		Nombre = @NOMBRE,	
		Activo = @ACTIVO, 
		FechaModificacion = CURRENT_TIMESTAMP 
		WHERE Id = @ID
		---
		DECLARE @ROW VARCHAR(MAX) = (SELECT * FROM tblModulo WHERE Id = @ID FOR JSON PATH)
		---
		SELECT	  @@ROWCOUNT												AS ROWS_AFFECTED
				, CAST(1 AS BIT)											AS SUCCESS
				, 'Se modifico satisfactoriamente la area!'    			AS ERROR_MESSAGE_SP
				, NULL														AS ERROR_NUMBER_SP
				, CONVERT(INT, ISNULL(SCOPE_IDENTITY(), -1))				AS ID
				, @ROW														AS ROW
		---
	END TRY    
	BEGIN CATCH
		--
		DECLARE @ERROR_MESSAGE VARCHAR(MAX) = ERROR_MESSAGE()
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