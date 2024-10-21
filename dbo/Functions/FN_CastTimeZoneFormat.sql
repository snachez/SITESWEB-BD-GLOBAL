﻿CREATE   FUNCTION FN_CastTimeZoneFormat(	
													  @IS_UTC_CURRENTLY BIT --INDICA SI EL FORMATO DE LA BASE DE DATOS ES UTC ACTUALMENTE
													, @CURRENT_TIME_ZONE VARCHAR(100) -- INDICA LA ZONA HORARIA ACTUAL DE LA BASE DATOS
													, @TO_TIME_ZONE_FORMAT VARCHAR(100) = 'Central America Standard Time' -- INDICA EL FORMATO AL QUE SE DESEA CONVERTIR EL DATO
													, @FECHA DATETIME -- FECHA QUE SE DESEA FORMATEAR...
												 )
RETURNS DATETIME
AS
BEGIN
	--
	RETURN		CASE 
				WHEN @IS_UTC_CURRENTLY = 1 
				THEN CAST(@FECHA AT TIME ZONE @CURRENT_TIME_ZONE AT TIME ZONE @TO_TIME_ZONE_FORMAT AS DATETIME)
				ELSE @FECHA END
	--
END