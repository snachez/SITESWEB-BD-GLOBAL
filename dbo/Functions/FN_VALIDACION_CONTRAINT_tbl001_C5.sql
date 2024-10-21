
CREATE   FUNCTION [dbo].[FN_VALIDACION_CONTRAINT_tbl001_C5](	  @DIA											INT
															, @PERMITE_REMESAS								BIT
															, @ENTREGAS_MISMO_DIA							BIT
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
		IF @ENTREGAS_MISMO_DIA = 1 BEGIN 
			---
			SET @RESULT = (SELECT CASE 
										WHEN @DIA = 1 THEN	IIF(	   @ENTREGAS_MARTES			= 1 
																	OR @ENTREGAS_MIERCOLES		= 1 
																	OR @ENTREGAS_JUEVES			= 1 
																	OR @ENTREGAS_VIERNES		= 1 
																	OR @ENTREGAS_SABADO			= 1 
																	OR @ENTREGAS_DOMINGO		= 1, 1, 0)
										WHEN @DIA = 2 THEN	IIF(	   @ENTREGAS_LUNES			= 1 
																	OR @ENTREGAS_MIERCOLES		= 1 
																	OR @ENTREGAS_JUEVES			= 1 
																	OR @ENTREGAS_VIERNES		= 1 
																	OR @ENTREGAS_SABADO			= 1 
																	OR @ENTREGAS_DOMINGO		= 1, 1, 0)
										WHEN @DIA = 3 THEN	IIF(	   @ENTREGAS_LUNES			= 1 
																	OR @ENTREGAS_MARTES			= 1 
																	OR @ENTREGAS_JUEVES			= 1 
																	OR @ENTREGAS_VIERNES		= 1 
																	OR @ENTREGAS_SABADO			= 1 
																	OR @ENTREGAS_DOMINGO		= 1, 1, 0)
										WHEN @DIA = 4 THEN	IIF(	   @ENTREGAS_LUNES			= 1 
																	OR @ENTREGAS_MARTES			= 1 
																	OR @ENTREGAS_MIERCOLES		= 1 
																	OR @ENTREGAS_VIERNES		= 1 
																	OR @ENTREGAS_SABADO			= 1 
																	OR @ENTREGAS_DOMINGO		= 1, 1, 0)
										WHEN @DIA = 5 THEN	IIF(	   @ENTREGAS_LUNES			= 1 
																	OR @ENTREGAS_MARTES			= 1 
																	OR @ENTREGAS_MIERCOLES		= 1 
																	OR @ENTREGAS_JUEVES			= 1 
																	OR @ENTREGAS_SABADO			= 1 
																	OR @ENTREGAS_DOMINGO		= 1, 1, 0)
										WHEN @DIA = 6 THEN	IIF(	   @ENTREGAS_LUNES			= 1 
																	OR @ENTREGAS_MARTES			= 1 
																	OR @ENTREGAS_MIERCOLES		= 1 
																	OR @ENTREGAS_JUEVES			= 1 
																	OR @ENTREGAS_VIERNES		= 1 
																	OR @ENTREGAS_DOMINGO		= 1, 1, 0)
										WHEN @DIA = 7 THEN	IIF(	   @ENTREGAS_LUNES			= 1 
																	OR @ENTREGAS_MARTES			= 1 
																	OR @ENTREGAS_MIERCOLES		= 1 
																	OR @ENTREGAS_JUEVES			= 1 
																	OR @ENTREGAS_VIERNES		= 1 
																	OR @ENTREGAS_SABADO			= 1, 1, 0)
						   END)
			---
		END ELSE BEGIN
			---
			SET @RESULT = IIF(	   @ENTREGAS_LUNES			= 1 
								OR @ENTREGAS_MARTES			= 1 
								OR @ENTREGAS_MIERCOLES		= 1 
								OR @ENTREGAS_JUEVES			= 1 
								OR @ENTREGAS_VIERNES		= 1 
								OR @ENTREGAS_SABADO			= 1 
								OR @ENTREGAS_DOMINGO		= 1, 1, 0)
			---
		END
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