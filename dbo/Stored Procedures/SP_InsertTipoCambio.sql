CREATE   PROCEDURE [dbo].[usp_InsertTipoCambio] (		  @NOMENCLATURADIVISA	 VARCHAR(3)
													, @COMPRA                DECIMAL
													, @VENTA                 DECIMAL
										      )
AS
BEGIN

	---
	BEGIN TRY
		/*
		----------
		 DIVISAS 
		----------
		 1 - CRC
		 2 - USD
		 3 - EUR
		----------
		*/
		---
		DECLARE @FK_DIVISA_COTIZADA INT = -1, @NEW_ID INT = -1
		SELECT @FK_DIVISA_COTIZADA = Id FROM tblDivisa WHERE Nomenclatura = @NOMENCLATURADIVISA
		---
		IF @FK_DIVISA_COTIZADA <> -1 BEGIN
			---
			INSERT INTO tblTipoCambio(fk_Id_DivisaCotizada, CompraColones, VentaColones)VALUES(@FK_DIVISA_COTIZADA, @COMPRA, @VENTA)
			---
			SET @NEW_ID =  CONVERT(INT, ISNULL(SCOPE_IDENTITY(), -1))
			---
		END
		---
		
		---
		SELECT	  @@ROWCOUNT												AS ROWS_AFFECTED
				, CAST(0 AS BIT)											AS SP_Error
				, ''														AS SP_ERROR_MESSAGE_DB 
				, @NEW_ID													AS pk_Id
		---
	END TRY    
	BEGIN CATCH
		--
		SELECT	  CAST(1 AS BIT)											AS SP_Error
				, 'Error: error en el insert usp_InsertTipoCambio'			AS SP_ERROR_MESSAGE_DB
				, 0															AS ROWS_AFFECTED
				, -1														AS pk_Id

		--   
	END CATCH
	---
END