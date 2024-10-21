

CREATE   FUNCTION [dbo].[FN_CONTRAINT_VALIDACION_EXISTENCIA_VALORES_ACTIVOS_INACTIVOS_CONTRA_TRANSPORTADORAS_CUANDO_HABILITA](@p_Activo INT, @p_Id_Transportadora INT)
	RETURNS VARCHAR(MAX)
AS
BEGIN

	DECLARE @Result INT = 0
	DECLARE @Cant_Relacion_Pais_Activas INT

	---------------- PAIS ----------------------
	DECLARE @p_Tbl_Temp_Transportadoras_x_Pais TABLE   
	(  
		 ID INT IDENTITY(1,1) 
		,Fk_Id_Pais INT NULL
		,Nombre VARCHAR(MAX) NULL	 
	)  

	INSERT INTO @p_Tbl_Temp_Transportadoras_x_Pais (Fk_Id_Pais)
	SELECT Fk_Id_Pais FROM tblTransportadoras_x_Pais WHERE Fk_Id_Transportadora =  @p_Id_Transportadora
	---------------- FIN PAIS ----------------------


	IF @p_Activo = 0  --SI ESTA INTENTANDO INACTIVAR
	BEGIN

		SET @Cant_Relacion_Pais_Activas = (SELECT COUNT(*) FROM tblPais WHERE Id IN (SELECT Fk_Id_Pais FROM @p_Tbl_Temp_Transportadoras_x_Pais) AND Activo = 1) 

		IF(@Cant_Relacion_Pais_Activas > 0 )
		BEGIN
			SET @Result = 0
		END

	END
	ELSE
	BEGIN

		SET @Cant_Relacion_Pais_Activas = (SELECT COUNT(*) FROM tblPais WHERE Id IN (SELECT Fk_Id_Pais FROM @p_Tbl_Temp_Transportadoras_x_Pais) AND Activo = 0) 

		IF(@Cant_Relacion_Pais_Activas > 0  )
		BEGIN
			SET @Result = 1
		END

	END


    RETURN(@Result)

	--DATOS DE ENVIO DE EJEMPLO PARA DEBUGGEAR
	--DECLARE @Resultado AS VARCHAR(MAX)
	--SELECT @Resultado = dbo.FN_CONTRAINT_VALIDACION_VALORES_INACTIVOS_CONTRA_TRANSPORTADORAS(0, 3);
	--SELECT @Resultado;

END