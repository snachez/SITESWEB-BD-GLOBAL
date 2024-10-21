CREATE   PROCEDURE [dbo].[usp_DeleteDenominaciones] (@ID VARCHAR(MAX))
AS
BEGIN
	---
	BEGIN TRY
		---
		UPDATE tblDenominaciones SET Activo = 0 WHERE Id = @ID
		---
		SELECT	  @@ROWCOUNT												AS ROWS_AFFECTED
				, ''														AS SP_Error
				, ''														AS SP_ERROR_MESSAGE_DB 
				, @ID														AS pk_Id
		---
	END TRY    
	BEGIN CATCH
		--
		SELECT	  CAST(1 AS BIT)											AS SP_Error
				, 'Error: error en el insert usp_DeleteDenominaciones'			AS SP_ERROR_MESSAGE_DB
				, 0															AS ROWS_AFFECTED
				, -1														AS pk_Id

		--   
	END CATCH
	---
END