﻿CREATE FUNCTION [dbo].[FN_VALIDACION_CONTRAINT_REACTIVAR_tblDivisa](@REACTIVAR BIT, @Fk_Id_Divisa INT)
RETURNS BIT
AS
BEGIN
	--
	-- VALIDA SI EXISTEN RELACIONES ACTIVAS PARA REACTIVAR UNA DIVISA
	DECLARE @RESULT BIT = 1
    DECLARE @CANT INT 
	DECLARE @RELACION_TE INT
	--
	IF @REACTIVAR = 1 
	BEGIN

	    SET @RELACION_TE =(Select count(*) from tblTipoEfectivo TE
				INNER JOIN tblDivisa_x_TipoEfectivo UMTE ON UMTE.FkIdTipoEfectivo = TE.Id AND UMTE.FkIdDivisa = @Fk_Id_Divisa
				WHERE TE.Activo = 0)

		SET @CANT = @RELACION_TE

		SET @RESULT = IIF(@CANT > 0, 0, 1) 
		
	END	
	--
    RETURN(@RESULT)
	--
END