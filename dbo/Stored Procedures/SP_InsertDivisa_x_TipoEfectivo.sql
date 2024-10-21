CREATE PROCEDURE [dbo].[SP_InsertDivisa_x_TipoEfectivo] (@FkIdDivisa INT, @FkIdTipoEfectivo INT)
AS
BEGIN
	---
	BEGIN TRY
		---

		DECLARE @p_Nombre_Divisa VARCHAR(150) 
		DECLARE @p_Nombre_Tipo_Efectivo VARCHAR(150) 

	
		SET @p_Nombre_Divisa = (SELECT Nombre FROM tblDivisa WHERE Id = @FkIdDivisa )
		SET @p_Nombre_Tipo_Efectivo = (SELECT Nombre FROM tblTipoEfectivo WHERE Id = @FkIdTipoEfectivo )

		INSERT INTO tblDivisa_x_TipoEfectivo(FkIdTipoEfectivo, FkIdDivisa, NombreTipoEfectivo, NombreDivisa ) VALUES(@FkIdTipoEfectivo, @FkIdDivisa, @p_Nombre_Tipo_Efectivo ,@p_Nombre_Divisa)


		---
		DECLARE @ROW VARCHAR(MAX) = (SELECT * FROM tblDivisa_x_TipoEfectivo WHERE Id = ISNULL(SCOPE_IDENTITY(), -1) FOR JSON PATH)
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
		DECLARE @ERROR_MESSAGE VARCHAR(MAX) = ERROR_MESSAGE();
		DECLARE @ERROR_MESSAGE1 VARCHAR(MAX) = '%Unique_Divisa_x_TipoEfectivo%';
		--
		IF @ERROR_MESSAGE LIKE @ERROR_MESSAGE1 BEGIN 
			---
			SET @ERROR_MESSAGE = 'El tipo de efectivo y la divisa ya se encuentran asociados'
			---
		END
		--
		SELECT	  CAST(0 AS BIT)											AS SUCCESS
				, @ERROR_MESSAGE											AS ERROR_MESSAGE_SP
				, ERROR_NUMBER()											AS ERROR_NUMBER_SP
				, 0															AS ROWS_AFFECTED
				, -1														AS ID
				, NULL														AS ROW

		--   
	END CATCH
	---
END