--
CREATE PROCEDURE [dbo].[usp_ResetSecuenciasTransacciones]
AS
BEGIN
  	BEGIN TRY
	---

	--EXEC [Sites.Pedidos].dbo.usp_ResetSecuenciaPEXT
    --EXEC usp_ResetSecuenciaGestionesUsuario

	---
		SELECT	  @@ROWCOUNT												AS ROWS_AFFECTED
				, CAST(1 AS BIT)											AS SUCCESS
				, 'Se reseteo exitosamente la secuencia de las transacciones' AS ERROR_MESSAGE_SP
				, NULL														AS ERROR_NUMBER_SP
				, -1				                                        AS ID
				, NULL														AS ROW
	---
	END TRY    
	BEGIN CATCH
		--
		DECLARE @ERROR_MESSAGE VARCHAR(MAX) = ERROR_MESSAGE();
		DECLARE @ERROR_NUMBER VARCHAR(MAX) = ERROR_NUMBER();

        SELECT	  CAST(0 AS BIT)											AS SUCCESS
				, @ERROR_MESSAGE											AS ERROR_MESSAGE_SP
				, @ERROR_NUMBER 											AS ERROR_NUMBER_SP
				, 0															AS ROWS_AFFECTED
				, -1														AS ID
				, NULL														AS ROW

		--    
	END CATCH
END