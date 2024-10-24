﻿CREATE   PROCEDURE [dbo].[SP_Select_Codigo_Consecutivo_Transportadora](
	@JSON_OUT  VARCHAR(MAX) OUTPUT 
)
AS
BEGIN
	  
	DECLARE @codigo_Transportadora_Consolidado VARCHAR(MAX) 
	DECLARE @total_Items_Tbl_Transportadora INT 
 
	SET @total_Items_Tbl_Transportadora = (SELECT COUNT(*) FROM tblTransportadoras) -- 2: OBTENER LA CANTIDAD TOTAL DE REGISTROS QUE HAY EN ESA TABLA

	--ES POR SER LA PRIMERA VEZ
	IF(@total_Items_Tbl_Transportadora = 0)
	BEGIN
	
		SET @codigo_Transportadora_Consolidado  = RIGHT(CONCAT('0000', 1  ),4)

		SET @JSON_OUT = ( SELECT @codigo_Transportadora_Consolidado AS Codigo ) 

	END
	ELSE
	BEGIN

		
		DECLARE @ultimo_Id_Transportadora_Insertado INT 
		DECLARE @siguiente_Codigo_Transportadora_A_Utilizar INT

		SET @ultimo_Id_Transportadora_Insertado =(SELECT MAX(Id) FROM tblTransportadoras)
		SET @siguiente_Codigo_Transportadora_A_Utilizar  = @ultimo_Id_Transportadora_Insertado + 1
		
		SET @codigo_Transportadora_Consolidado  = (SELECT Codigo = RIGHT(CONCAT('0000', @siguiente_Codigo_Transportadora_A_Utilizar ),4) )

		SET @JSON_OUT = ( SELECT @codigo_Transportadora_Consolidado AS Codigo ) 

	END
END