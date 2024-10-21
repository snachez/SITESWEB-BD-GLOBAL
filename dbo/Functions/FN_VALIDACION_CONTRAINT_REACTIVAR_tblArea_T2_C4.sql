﻿CREATE   FUNCTION [dbo].[FN_VALIDACION_CONTRAINT_REACTIVAR_tblArea_T2_C4](@REACTIVAR BIT, @FK_ID_DEPARTAMENTO INT)
RETURNS BIT
AS
BEGIN
	--
	DECLARE @RESULT BIT = 1
    DECLARE @CANT INT 
	DECLARE @RELACION_D INT
	--
	IF @REACTIVAR = 1 BEGIN
		--
		SET @RELACION_D = (SELECT count(*) FROM tblDepartamento WHERE Id = @FK_ID_DEPARTAMENTO AND Activo = 0)
		--

		SET @CANT = @RELACION_D

		SET @RESULT = IIF(@CANT > 0, 0, 1) 

	END
	--
    RETURN(@RESULT)
	--
END