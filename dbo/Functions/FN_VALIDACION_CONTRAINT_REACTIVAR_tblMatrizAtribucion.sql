﻿CREATE FUNCTION [dbo].[FN_VALIDACION_CONTRAINT_REACTIVAR_tblMatrizAtribucion](@REACTIVAR BIT, @Fk_Id_Divisa INT )
RETURNS BIT
AS
BEGIN
	--
	-- VALIDA SI EL DIVISA ESTA ACTIVO PARA REACTIVAR UNA MatrizAtribucion
	DECLARE @RESULT BIT = 1
    DECLARE @CANT INT 
	DECLARE @RELACION_D INT
	--
	IF @REACTIVAR = 1 BEGIN
		--
		SET @RELACION_D = (SELECT count(*) FROM tblDivisa WHERE Id = @Fk_Id_Divisa AND Activo = 0)
		--

		SET @CANT = @RELACION_D

		SET @RESULT = IIF(@CANT > 0, 0, 1) 

	END
	--
    RETURN(@RESULT)
	--
END