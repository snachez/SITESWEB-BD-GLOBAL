
CREATE   FUNCTION [dbo].[FN_CONTRAINT_VALIDACION_EXISTENCIA_VALORES_ACTIVOS_INACTIVOS_CONTRA_TRASPORTADORA_CUANDO_MODIFICA_AGENCIA](@JSON_IN VARCHAR(MAX))
	RETURNS VARCHAR(MAX)
AS
BEGIN
	--	
	DECLARE @Result INT = 0
	DECLARE @p_Id_Transportadora INT
	DECLARE @p_Activo_Transportadora BIT
    DECLARE @Cant_Relacion_Agencias_Activas INT

	SELECT @p_Id_Transportadora = Id FROM OPENJSON( @JSON_IN) WITH ( Id INT )
	SELECT @p_Activo_Transportadora = Activo FROM OPENJSON( @JSON_IN) WITH ( Activo BIT )

	
	  ---------------- AGENCIAS ----------------------
	DECLARE @p_Tbl_Temp_Transportadoras_x_Agencias TABLE   
	(  
		 ID INT IDENTITY(1,1) 
		,Fk_Id_Transportadora INT NULL
	)  

	INSERT INTO @p_Tbl_Temp_Transportadoras_x_Agencias (Fk_Id_Transportadora)
	SELECT Fk_Transportadora_Envio FROM tblAgenciaBancaria WHERE Fk_Transportadora_Envio =  @p_Id_Transportadora AND Activo = 1
	INSERT INTO @p_Tbl_Temp_Transportadoras_x_Agencias (Fk_Id_Transportadora)
	SELECT Fk_Transportadora_Solicitud FROM tblAgenciaBancaria WHERE Fk_Transportadora_Solicitud = @p_Id_Transportadora  AND Activo = 1
	---------------- FIN AGENCIAS ----------------------


	  IF(@p_Activo_Transportadora = 0 ) --SI ESTA INTENTANDO ACTIVAR
	  BEGIN

		SET @Cant_Relacion_Agencias_Activas = (
			SELECT COUNT(*) 
			FROM tblAgenciaBancaria 
			WHERE Fk_Transportadora_Envio IN (SELECT Fk_Id_Transportadora FROM @p_Tbl_Temp_Transportadoras_x_Agencias)            
			OR Fk_Transportadora_Solicitud IN (SELECT Fk_Id_Transportadora FROM @p_Tbl_Temp_Transportadoras_x_Agencias) AND            
			Activo = 1) 

	    IF( @Cant_Relacion_Agencias_Activas > 0 )
		BEGIN
			SET @Result = 1
		END	
		
	  END
	  ELSE --SI ESTA INTENTANDO INACTIVAR
	  BEGIN
		
		SET @Cant_Relacion_Agencias_Activas = (
			SELECT COUNT(*) 
			FROM tblAgenciaBancaria 
			WHERE Fk_Transportadora_Envio IN (SELECT Fk_Id_Transportadora FROM @p_Tbl_Temp_Transportadoras_x_Agencias)            
			OR Fk_Transportadora_Solicitud IN (SELECT Fk_Id_Transportadora FROM @p_Tbl_Temp_Transportadoras_x_Agencias) AND            
			Activo = 0) 

		IF(@Cant_Relacion_Agencias_Activas  > 0 )
		BEGIN
			SET @Result = 0
		END

	  END

    RETURN(@Result)


END