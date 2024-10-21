CREATE   FUNCTION [dbo].[FN_VALIDACION_CONTRAINT_tbl001_C6](	  @DIA											INT
															, @PERMITE_REMESAS								BIT
															, @ENTREGAS_LUNES								BIT
															, @ENTREGAS_MARTES								BIT
															, @ENTREGAS_MIERCOLES							BIT
															, @ENTREGAS_JUEVES								BIT
															, @ENTREGAS_VIERNES								BIT
															, @ENTREGAS_SABADO								BIT
															, @ENTREGAS_DOMINGO								BIT)
RETURNS INT
--WITH EXECUTE AS CALLER
AS
BEGIN
	--
    DECLARE @RESULT BIT = 0;
	--
	IF @PERMITE_REMESAS = 1 BEGIN
		---
		SET @RESULT = (SELECT CASE 
									WHEN @DIA = 1 THEN	IIF(	    @ENTREGAS_MARTES		= 1 
																AND @ENTREGAS_MIERCOLES		= 0 
																AND @ENTREGAS_JUEVES		= 0 
																AND @ENTREGAS_VIERNES		= 0 
																AND @ENTREGAS_SABADO		= 0 
																AND @ENTREGAS_DOMINGO		= 0, 0, 1)

									WHEN @DIA = 2 THEN	IIF(	    @ENTREGAS_LUNES			= 0 
																AND @ENTREGAS_MIERCOLES		= 1 
																AND @ENTREGAS_JUEVES		= 0 
																AND @ENTREGAS_VIERNES		= 0 
																AND @ENTREGAS_SABADO		= 0 
																AND @ENTREGAS_DOMINGO		= 0, 0, 1)

									WHEN @DIA = 3 THEN	IIF(	    @ENTREGAS_LUNES			= 0 
																AND @ENTREGAS_MARTES		= 0 
																AND @ENTREGAS_JUEVES		= 1 
																AND @ENTREGAS_VIERNES		= 0 
																AND @ENTREGAS_SABADO		= 0 
																AND @ENTREGAS_DOMINGO		= 0, 0, 1)

									WHEN @DIA = 4 THEN	IIF(	    @ENTREGAS_LUNES			= 0 
																AND @ENTREGAS_MARTES		= 0 
																AND @ENTREGAS_MIERCOLES		= 0 
																AND @ENTREGAS_VIERNES		= 1 
																AND @ENTREGAS_SABADO		= 0 
																AND @ENTREGAS_DOMINGO		= 0, 0, 1)

									WHEN @DIA = 5 THEN	IIF(	    @ENTREGAS_LUNES			= 0 
																AND @ENTREGAS_MARTES		= 0 
																AND @ENTREGAS_MIERCOLES		= 0 
																AND @ENTREGAS_JUEVES		= 0 
																AND @ENTREGAS_SABADO		= 1 
																AND @ENTREGAS_DOMINGO		= 0, 0, 1)

									WHEN @DIA = 6 THEN	IIF(	    @ENTREGAS_LUNES			= 0 
																AND @ENTREGAS_MARTES		= 0 
																AND @ENTREGAS_MIERCOLES		= 0 
																AND @ENTREGAS_JUEVES		= 0 
																AND @ENTREGAS_VIERNES		= 0 
																AND @ENTREGAS_DOMINGO		= 1, 0, 1)

									WHEN @DIA = 7 THEN	IIF(	    @ENTREGAS_LUNES			= 1 
																AND @ENTREGAS_MARTES		= 0 
																AND @ENTREGAS_MIERCOLES		= 0 
																AND @ENTREGAS_JUEVES		= 0 
																AND @ENTREGAS_VIERNES		= 0 
																AND @ENTREGAS_SABADO		= 0, 0, 1)
						END)
		---
	END ELSE BEGIN
		---
		SET @RESULT = 1
		---
	END
	--
    RETURN(@RESULT)
	--
END