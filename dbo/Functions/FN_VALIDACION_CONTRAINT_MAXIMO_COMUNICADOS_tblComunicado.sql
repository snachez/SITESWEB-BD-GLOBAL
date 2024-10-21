﻿CREATE FUNCTION [dbo].[FN_VALIDACION_CONTRAINT_MAXIMO_COMUNICADOS_tblComunicado](@ACTIVO BIT)
RETURNS BIT
AS
BEGIN
	--
	-- VALIDA SI LOS MENSAJES ESTAN ACTIVOS Y SOLO PUEDE HABER MAXIMO 7 MENSAJES.
	DECLARE @RESULT BIT = 1
	DECLARE @MENSAJE_MAXIMO INT
	--
		BEGIN
	 
		   SET @MENSAJE_MAXIMO = (SELECT COUNT(*) FROM [tblComunicado] WHERE Activo = @ACTIVO) 

		   IF(@MENSAJE_MAXIMO = 8)
			  BEGIN
				 SET @RESULT	 = 0
			  END
	
		END
	--
    RETURN(@RESULT)
	--
END