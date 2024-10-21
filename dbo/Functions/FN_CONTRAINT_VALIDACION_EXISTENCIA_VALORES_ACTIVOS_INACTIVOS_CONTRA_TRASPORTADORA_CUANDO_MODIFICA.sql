
CREATE   FUNCTION [dbo].[FN_CONTRAINT_VALIDACION_EXISTENCIA_VALORES_ACTIVOS_INACTIVOS_CONTRA_TRASPORTADORA_CUANDO_MODIFICA](@JSON_IN VARCHAR(MAX))
	RETURNS VARCHAR(MAX)
AS
BEGIN
	--	
	DECLARE @Result INT = 0
	DECLARE @p_Id_Transportadora INT
	DECLARE @p_Activo_Transportadora BIT
	DECLARE @Cant_Relacion_Pais_Activas INT

	SELECT @p_Id_Transportadora = Id FROM OPENJSON( @JSON_IN) WITH ( Id INT )
	SELECT @p_Activo_Transportadora = Activo FROM OPENJSON( @JSON_IN) WITH ( Activo BIT )

	 ---------------- PAIS ----------------------
	  DECLARE @Tbl_Temp_Pais_Viejas TABLE ( 
	  	 ID INT IDENTITY(1,1)
	  	,Id_Pais INT 
		,Nombre VARCHAR(MAX) NULL	 
	  )

	  INSERT INTO @Tbl_Temp_Pais_Viejas (Id_Pais)
	  SELECT Fk_Id_Pais FROM tblTransportadoras_x_Pais WHERE Fk_Id_Transportadora =  @p_Id_Transportadora
	  ---------------- FIN PAIS ----------------------

	  IF(@p_Activo_Transportadora = 0 ) --SI ESTA INTENTANDO ACTIVAR
	  BEGIN

		--asegure de validar que la transportadora no tenga paises vinculados activos para poder continuar 
	    SET @Cant_Relacion_Pais_Activas = (SELECT COUNT(*) FROM tblPais WHERE Id IN (SELECT Id_Pais FROM @Tbl_Temp_Pais_Viejas) AND Activo = 1) 
		
	    IF(@Cant_Relacion_Pais_Activas > 0 )
		BEGIN
			SET @Result = 0
		END	
		
	  END
	  ELSE --SI ESTA INTENTANDO INACTIVAR
	  BEGIN
		
		--asegure de validar que la transportadora no tenga paises vinculados inactivos para poder continuar 
		SET @Cant_Relacion_Pais_Activas = (SELECT COUNT(*) FROM tblPais WHERE Id IN (SELECT Id_Pais FROM @Tbl_Temp_Pais_Viejas) AND Activo = 0) 
		
		IF(@Cant_Relacion_Pais_Activas > 0 )
		BEGIN
			SET @Result = 1
		END

	  END

    RETURN(@Result)

	
--DATOS DE ENVIO DE EJEMPLO PARA DEBUGGEAR
--DECLARE @Resultado AS VARCHAR(MAX)
--SELECT  @Resultado = dbo.FN_CONTRAINT_VALIDACION_EXISTENCIA_VALORES_ACTIVOS_INACTIVOS_CONTRA_TRASPORTADORA_CUANDO_MODIFICA('prueba1','{"Id":null,"Nombre":"prueba1","Codigo":"0004","Activo":true,"Fecha_Creacion":null,"Fecha_Modificacion":null,"Pais":[{"Id":36,"Nombre":"Estados Unidos","Codigo":"0036","Activo":true,"FechaCreacion":"0001-01-01T00:00:00","FechaModificacion":null},{"Id":37,"Nombre":"Costa Rica","Codigo":"0037","Activo":true,"FechaCreacion":"0001-01-01T00:00:00","FechaModificacion":null}],"Nombres_Paises_Concatenados":null,"Modulo":[{"Id":1,"Nombre":"Recepcion","Activo":true,"FechaCreacion":"2023-05-05T12:51:00","FechaModificacion":"2023-05-05T15:47:00"},{"Id":2,"Nombre":"Centro de Efectivo","Activo":true,"FechaCreacion":"2023-05-05T12:51:00","FechaModificacion":"2023-05-05T12:51:00"}],"Nombres_Modulos_Concatenados":null}');
--SELECT  @Resultado;


END