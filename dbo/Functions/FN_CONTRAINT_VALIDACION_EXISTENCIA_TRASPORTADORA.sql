
CREATE   FUNCTION [dbo].[FN_CONTRAINT_VALIDACION_EXISTENCIA_TRASPORTADORA](@JSON_IN VARCHAR(MAX))
	RETURNS VARCHAR(MAX)
AS
BEGIN
	--	
	DECLARE @p_Id_Transportadora INT
	DECLARE @p_Nombre_Transportadora VARCHAR(MAX) 

	SELECT @p_Id_Transportadora = Id FROM OPENJSON( @JSON_IN) WITH ( Id INT )
	SELECT @p_Nombre_Transportadora = Nombre FROM OPENJSON( @JSON_IN) WITH ( Nombre VARCHAR(MAX) )

	--
	DECLARE @Result INT = 0
	DECLARE @Relacion_Pais INT
	
	DECLARE @p_Tabl_Temp_Pais TABLE   
	(  
		 ID INT IDENTITY(1,1) 
		,Id_Pais INT NULL
		,Nombre VARCHAR(MAX) NULL	 
	)  

	--INSERTA CADA UNO DE LOS ITEMS DE LOS PAISES
	INSERT INTO @p_Tabl_Temp_Pais	 
	SELECT 
		   Id
		  ,Nombre		  
	FROM OPENJSON (@JSON_IN)
	WITH (Pais NVARCHAR(MAX) AS JSON)
	CROSS APPLY OPENJSON (Pais) 
	WITH 
	(
	   Id INT
	  ,Nombre VARCHAR(MAX)
	) 

	DECLARE @p_Tbl_Temp_Modulo TABLE   
	(  
	 ID INT IDENTITY(1,1) 
	,Id_Modulo INT NULL
	,Nombre VARCHAR(MAX) NULL	 
	)  

	--INSERTA CADA UNO DE LOS ITEMS DE LOS MODULOS
	INSERT INTO @p_Tbl_Temp_Modulo
	SELECT 
		   Id
		  ,Nombre		  
	FROM OPENJSON (@JSON_IN)
	WITH (Modulo NVARCHAR(MAX) AS JSON)
	CROSS APPLY OPENJSON (Modulo) 
	WITH 
	(
	   Id INT
	  ,Nombre VARCHAR(MAX)
	) 

	DECLARE @p_Tabl_Temp_Ids_Transportadoras TABLE   
	(  
		 ID INT IDENTITY(1,1) 
		,Id_Transportadora INT 
		,Nombre VARCHAR(MAX) NULL	 
	)  

	 --ITEMS VIEJOS MODULO
	 IF(@p_Id_Transportadora IS NULL OR @p_Id_Transportadora = '') --ESTA INSERTADO
	 BEGIN

		INSERT INTO @p_Tabl_Temp_Ids_Transportadoras (Id_Transportadora)
		SELECT Id FROM tblTransportadoras WHERE Nombre LIKE '%' +(SELECT @p_Nombre_Transportadora) +'%'	

	 END
	 ELSE --ESTA MODIFICANDO
	 BEGIN 
		 INSERT INTO @p_Tabl_Temp_Ids_Transportadoras (Id_Transportadora)
		 SELECT Id FROM tblTransportadoras WHERE Nombre LIKE '%' +(SELECT @p_Nombre_Transportadora) +'%' AND Id <> @p_Id_Transportadora
	 END

	SET @Relacion_Pais = (SELECT COUNT(*) FROM tblTransportadoras_x_Pais WHERE Fk_Id_Transportadora IN (SELECT Id_Transportadora FROM @p_Tabl_Temp_Ids_Transportadoras) AND Fk_Id_Pais IN (SELECT Id_Pais FROM @p_Tabl_Temp_Pais))

	IF((SELECT @Relacion_Pais) > 0)
	BEGIN
		SET @Result = 1
	END

    RETURN(@Result)

END