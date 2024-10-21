CREATE   PROCEDURE [dbo].[usp_HabilitarCuentaInterna](@ID INT, @ACTIVO BIT)
AS
BEGIN
	---
	BEGIN TRY
		---
		UPDATE tblCuentaInterna SET Activo = @ACTIVO, FechaModificacion = CURRENT_TIMESTAMP WHERE Id = @ID
		---
		DECLARE @ROW VARCHAR(MAX) = (	SELECT   C.Id						AS [Id]
												   , C.NumeroCuenta				AS [NumeroCuenta]
												   , C.Codigo					AS [Codigo]
												   , C.FkIdDivisa				AS [FkIdDivisa]
												   , C.Activo					AS [Activo]
												   , C.FechaCreacion			AS [FechaCreacion]
												   , C.FechaModificacion		AS [FechaModificacion]
												   
												   , D.Id						AS [Divisa.Id]
												   , D.Nombre					AS [Divisa.Nombre]
												   , D.Nomenclatura				AS [Divisa.Nomenclatura]
												   , D.Simbolo					AS [Divisa.Simbolo]
												   , D.Descripcion				AS [Divisa.Descripcion]
												   , D.Activo					AS [Divisa.Activo]
												   , D.FechaCreacion			AS [Divisa.FechaCreacion]
												   , D.FechaModificacion		AS [Divisa.FechaModificacion]

											FROM tblCuentaInterna C
											INNER JOIN tblDivisa D
											ON C.FkIdDivisa = D.Id
											WHERE C.Id = @ID FOR JSON PATH)
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
		SELECT	  CAST(0 AS BIT)											AS SUCCESS
				, ERROR_MESSAGE()											AS ERROR_MESSAGE_SP
				, ERROR_NUMBER()											AS ERROR_NUMBER_SP
				, 0															AS ROWS_AFFECTED
				, -1														AS ID
				, NULL														AS ROW

		--   
	END CATCH
	---
END
---
---