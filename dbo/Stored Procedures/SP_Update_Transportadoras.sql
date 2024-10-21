CREATE    PROCEDURE [dbo].[SP_Update_Transportadoras](
    @JSON_IN VARCHAR(MAX) = NULL,
	@JSON_OUT  VARCHAR(MAX) OUTPUT 
)
AS
BEGIN
DECLARE @Resp_1 VARCHAR(MAX)

    -- Validar JSON de entrada
    IF @JSON_IN IS NULL OR @JSON_IN = '' OR ISJSON(@JSON_IN) <> 1
    BEGIN
						SELECT @Resp_1 = 
						(
							  SELECT	  @@ROWCOUNT												    AS ROWS_AFFECTED
							, CAST(0 AS BIT)														    AS SUCCESS
							, 'No registrado!'														    AS ERROR_TITLE_SP
							, CONCAT(ERROR_MESSAGE() ,'Error, se resivio el JSON Vacio')                AS ERROR_MESSAGE_SP
							, ERROR_NUMBER()													        AS ERROR_NUMBER_SP
							, NULL																	    AS ID
							, NULL																	    AS ROW 
							FOR JSON PATH, INCLUDE_NULL_VALUES
						)				
						
						SET @JSON_OUT = ( SELECT @Resp_1  )	
        RETURN;
    END

    -- Procesar el JSON válido
    SET @JSON_IN = REPLACE(@JSON_IN, '\', '');

	  ---Declaracion Variables Mensajes
      DECLARE @MetodoTemporal VARCHAR(MAX) = 'SP_Update_Transportadora';
	  DECLARE @ERROR_MESSAGE VARCHAR(MAX);
	  DECLARE @ERROR_NUMBER INT;

	  -- Declarar una tabla temporal para almacenar los resultados del procedimiento almacenado de mensajes
	  CREATE TABLE #Mensajes (
	  	ROWS_AFFECTED INT,
	  	SUCCESS BIT,
	  	ERROR_TITLE_SP VARCHAR(MAX),
	  	ERROR_MESSAGE_SP VARCHAR(MAX),
	  	ERROR_NUMBER_SP INT,
	  	CONSTRAINT_TRIGGER_NAME VARCHAR(MAX),
	  	ID INT,
	  	ROW VARCHAR(MAX)
	  );

	  --DECLARACION DE VARIABLES PARA ACCEER A LAS PROPIEDADES Y VALORES QUE VIENEN DENTRO DEL JSON
	  DECLARE @p_Id_Transportadora INT
	  DECLARE @p_Nombre_Transportadora VARCHAR(MAX) 
	  DECLARE @p_Codigo_Transportadora VARCHAR(MAX)
	  DECLARE @p_Activo_Transportadora BIT

	  --AUN NO ESTAN EN USO
	   
	  

	  --SETEANDO LOS VALORES DEL JSON (TABLA PADRE TRANSPORTADORA)
	  SELECT @p_Id_Transportadora = Id FROM OPENJSON( @JSON_IN) WITH ( Id INT )
	  SELECT @p_Nombre_Transportadora = Nombre FROM OPENJSON( @JSON_IN) WITH ( Nombre VARCHAR(MAX) )
	  SELECT @p_Codigo_Transportadora = Codigo FROM OPENJSON( @JSON_IN) WITH ( Codigo VARCHAR(MAX) )	 
	  SELECT @p_Activo_Transportadora = Activo FROM OPENJSON( @JSON_IN) WITH ( Activo BIT )

	  --------------------------- DECLARACION DE TABLA PARA EDITAR LOS REGISTROS DE PAISES (TABLA HIJO) ----------------------------------------
	  DECLARE @p_Tbl_Temp_Pais_Nuevas TABLE   
	  (  
		  ID INT IDENTITY(1,1) 
		 ,Id_Pais INT NULL
		 ,Nombre VARCHAR(MAX) NULL	 
	  )  

	  --INSERTA CADA UNO DE LOS ITEMS DE LOS PAISES
	  INSERT INTO @p_Tbl_Temp_Pais_Nuevas	 
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

	    --DECLARACION DE VARIABLES PARA RECORRER LA TABLA TEMPORAL PAISES (TABLA HIJO) 
	  DECLARE @p_Id_Pais_Iterador INT
	  DECLARE @p_Nombre_Pais_Iterador VARCHAR(MAX)

	  --------------------------- DECLARACION DE TABLA PARA EDITAR LOS REGISTROS DE MODULOS (TABLA HIJO) ----------------------------------------
	 
	  DECLARE @p_Tbl_Temp_Modulo_Nuevas TABLE   
	  (  
		  ID INT IDENTITY(1,1) 
		 ,Id_Modulo INT NULL
		 ,Nombre VARCHAR(MAX) NULL	 
	  )  

	  --INSERTA CADA UNO DE LOS ITEMS DE LOS PAISES
	  INSERT INTO @p_Tbl_Temp_Modulo_Nuevas
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

	    --DECLARACION DE VARIABLES PARA RECORRER LA TABLA TEMPORAL PAISES (TABLA HIJO) 
	  DECLARE @p_Id_Modulo_Iterador INT
	  DECLARE @p_Nombre_Modulo_Iterador VARCHAR(MAX)

	 ----------------------------------------------------------------------------------------------------------------------------------------------
	  
	  --VARIABLES PARA DAR RESPUESTA AL APP
	  DECLARE @CONTINUAR_TRANSACCION INT
	  DECLARE @ROW VARCHAR(MAX)
	  DECLARE @Resultado INT


	  --VALIDAR EXISTENCIA TRANSPORTADORA POR PAIS Y MODULO
	  IF EXISTS(SELECT 1 FROM tblTransportadoras WHERE Nombre = @p_Nombre_Transportadora)        
	  BEGIN   	   
																															
			SELECT @Resultado = dbo.FN_CONTRAINT_VALIDACION_EXISTENCIA_TRASPORTADORA(@JSON_IN);
			
			IF(@Resultado = 1) --ES POR QUE EXISTE
			BEGIN 
					------------------------------ RESPUESTA A LA APP  ------------------------------------
						SET @ERROR_MESSAGE = ERROR_MESSAGE() 
						SET @ERROR_NUMBER = ERROR_NUMBER()

						INSERT INTO #Mensajes 
						EXEC SP_Select_Mensajes_Emergentes_Para_SP 
						@ROWS_AFFECTED = 0,
						@SUCCESS = 0,
						@ERROR_NUMBER_SP = @ERROR_NUMBER ,
						@CONSTRAINT_TRIGGER_NAME = @ERROR_MESSAGE,
						@ID = 0,
						@ROW = NULL,
						@Metodo = @MetodoTemporal, 
						@TipoMensaje = 'Error', 
						@ErrorMensaje  = 'Unique_Nombre_Transportadora_By_Pais_And_Modulo',
						@ModeJson = 0;

						SELECT @Resp_1 = 
						(
							SELECT * FROM #Mensajes FOR JSON PATH, INCLUDE_NULL_VALUES
						)
						
						SET @JSON_OUT = ( SELECT @Resp_1  )
						
						TRUNCATE TABLE #Mensajes;				  
								
					----------------------------------------------------------------------------------------
			
					  

			END
	       
	  END  


	  --VALIDAR EXISTENCIA DE VALORES ACTIVOS E INACTIVOS CONTRA PAIS 	 
	 IF EXISTS(SELECT 1 FROM tblTransportadoras WHERE Nombre = @p_Nombre_Transportadora)        
	 BEGIN   	   
																																
			SELECT @Resultado = dbo.FN_CONTRAINT_VALIDACION_EXISTENCIA_VALORES_ACTIVOS_INACTIVOS_CONTRA_TRASPORTADORA_CUANDO_MODIFICA(@JSON_IN);
			
			IF(@Resultado = 1) --ES POR QUE TIENE VALORES ACTIVOS EXISTE
			BEGIN 
					------------------------------ RESPUESTA A LA APP MSJ: 3226 ------------------------------------
								
									INSERT INTO #Mensajes 
									EXEC SP_Select_Mensajes_Emergentes_Para_SP 
									@ROWS_AFFECTED = 0,
									@SUCCESS = 0,
									@ERROR_NUMBER_SP = @ERROR_NUMBER,
									@CONSTRAINT_TRIGGER_NAME = 'Constrains_Validate_Relaciones_Activas_Inactivas_Contra_Transportadoras_2',
									@ID = 0,
									@ROW = NULL,
									@Metodo = @MetodoTemporal, 
									@TipoMensaje = 'Error', 
									@ErrorMensaje  = 'Constrains_Validate_Relaciones_Activas_Inactivas_Contra_Transportadoras_2',
									@ModeJson = 0;

									SELECT @Resp_1 = 
									(
										SELECT * FROM #Mensajes FOR JSON PATH, INCLUDE_NULL_VALUES
									)
					
									SET @JSON_OUT = ( SELECT @Resp_1  )
					
									TRUNCATE TABLE #Mensajes;

					----------------------------------------------------------------------------------------
			
					  

			END	       
	 END  

	 --VALIDAR EXISTENCIA DE VALORES ACTIVOS E INACTIVOS CONTRA AGENCIA

	 IF EXISTS(SELECT 1 FROM tblTransportadoras WHERE Nombre = @p_Nombre_Transportadora)        
	 BEGIN   	   
																																
			SELECT @Resultado = dbo.FN_CONTRAINT_VALIDACION_EXISTENCIA_VALORES_ACTIVOS_INACTIVOS_CONTRA_TRASPORTADORA_CUANDO_MODIFICA_AGENCIA(@JSON_IN);
			
			IF(@Resultado = 1) --ES POR QUE TIENE VALORES ACTIVOS EXISTE
			BEGIN 
					------------------------------ RESPUESTA A LA APP MSJ: 3226 ------------------------------------
									
									INSERT INTO #Mensajes 
									EXEC SP_Select_Mensajes_Emergentes_Para_SP 
									@ROWS_AFFECTED = 0,
									@SUCCESS = 0,
									@ERROR_NUMBER_SP = @ERROR_NUMBER,
									@CONSTRAINT_TRIGGER_NAME = 'Constrains_Validate_Valores_Activos_Inactivos_Contra_Transportadoras',
									@ID = 0,
									@ROW = NULL,
									@Metodo = @MetodoTemporal, 
									@TipoMensaje = 'Error', 
									@ErrorMensaje  = 'Constrains_Validate_Valores_Activos_Inactivos_Contra_Transportadoras',
									@ModeJson = 0;

									SELECT @Resp_1 = 
									(
										SELECT * FROM #Mensajes FOR JSON PATH, INCLUDE_NULL_VALUES
									)
					
									SET @JSON_OUT = ( SELECT @Resp_1  )
					
									TRUNCATE TABLE #Mensajes;

					----------------------------------------------------------------------------------------
			
					  

			END	       
	 END  


	 BEGIN TRY	
	 
		 BEGIN TRANSACTION EDITAR
															
					--EDITA EN LA TABLA TRANSPORTADORA
					
					UPDATE tblTransportadoras SET Nombre = @p_Nombre_Transportadora, Codigo = @p_Codigo_Transportadora, Activo = @p_Activo_Transportadora, Fecha_Modificacion = GETDATE()
					WHERE tblTransportadoras.Id = @p_Id_Transportadora
					
				    IF(@p_Id_Transportadora IS NOT NULL OR @p_Id_Transportadora <> '' OR @p_Id_Transportadora <> 0)
					BEGIN   
				   		
					    ------------------------------ INICIO DEL RECORRIDO Y SETEO DE DATA DE LA TABLA TEMPORAL PAISES (TABLA HIJO) ------------------------------------

					    --ELIMINE LOS QUE YA ESTABAN POR EL ID DE LA TABLA PAPA OSEA TABLA TRANSPORTADORA
						DELETE FROM tblTransportadoras_x_Pais WHERE Fk_Id_Transportadora = @p_Id_Transportadora	

						DECLARE @i INT = 1
						DECLARE @Contador INT = (SELECT COUNT(1) FROM  @p_Tbl_Temp_Pais_Nuevas	 )

						IF @Contador > 0 BEGIN WHILE (@i <= (SELECT MAX(ID) FROM @p_Tbl_Temp_Pais_Nuevas	 ))
							BEGIN

								--OBTIENE UN ITEM
								SELECT 								
								 @p_Id_Pais_Iterador = Id_Pais
								,@p_Nombre_Pais_Iterador = Nombre									
								FROM @p_Tbl_Temp_Pais_Nuevas 
								WHERE ID = @i
												
								--INSERTA EN LA TABLA tblTransportadoras_x_Pais
								INSERT INTO dbo.[tblTransportadoras_x_Pais] (    [Fk_Id_Transportadora],          [Fk_Id_Pais],     [Fecha_Creacion],  [Activo]  )
																 VALUES (   @p_Id_Transportadora,    @p_Id_Pais_Iterador,    GETDATE(),          1  )			    												

								SET @i = @i + 1
							END --FIN DEL CICLO
						END
						------------------------------ FIN DEL RECORRIDO Y SETEO DE DATA DE LA TABLA TEMPORAL PAISES (TABLA HIJO) ------------------------------------			
						------------------------------ INICIO DEL RECORRIDO Y SETEO DE DATA DE LA TABLA TEMPORAL MODULOS  ------------------------------------

						DELETE FROM tblTransportadoras_x_Modulo WHERE Fk_Id_Transportadora = @p_Id_Transportadora	

						DECLARE @iter INT = 1
						DECLARE @Conta INT = (SELECT COUNT(1) FROM  @p_Tbl_Temp_Modulo_Nuevas	 )

						IF @Conta > 0 WHILE (@iter <= (SELECT MAX(ID) FROM @p_Tbl_Temp_Modulo_Nuevas	 ))
						BEGIN

							--OBTIENE UN ITEM
							SELECT 								
							 @p_Id_Modulo_Iterador = Id_Modulo
							,@p_Nombre_Modulo_Iterador = Nombre									
							FROM @p_Tbl_Temp_Modulo_Nuevas 
							WHERE ID = @iter
						
							--INSERTA EN LA TABLA tblTransportadoras_x_Modulo
							INSERT INTO dbo.[tblTransportadoras_x_Modulo] (      [Fk_Id_Transportadora],      	        [Fk_Id_Modulo],      [Activo],    [Fecha_Creacion]   )
																   VALUES (   @p_Id_Transportadora,    @p_Id_Modulo_Iterador,       1,            GETDATE()     )
			    											
							SET @iter = @iter + 1
						END --FIN DEL CICLO

						------------------------------ FIN DEL RECORRIDO Y SETEO DE DATA DE LA TABLA TEMPORAL MODULO (TABLA HIJO) ------------------------------------
						SET @CONTINUAR_TRANSACCION = 1
					END
					ELSE
					BEGIN
					    SET @CONTINUAR_TRANSACCION = 0
					END

					IF(@CONTINUAR_TRANSACCION = 1)
					BEGIN 
						
								SELECT @ROW = (SELECT * FROM tblTransportadoras WHERE Id = @p_Id_Transportadora FOR JSON PATH, INCLUDE_NULL_VALUES)
										
								------------------------------ RESPUESTA A LA APP MSJ: 3205 Transportadora insertada con exito!  ------------------------------------							

								INSERT INTO #Mensajes 
								EXEC SP_Select_Mensajes_Emergentes_Para_SP 
								@ROWS_AFFECTED = @@ROWCOUNT,
								@SUCCESS = 1,
								@ERROR_NUMBER_SP = NULL,
								@CONSTRAINT_TRIGGER_NAME = NULL,
								@ID = @p_Id_Transportadora,
								@ROW = @ROW,
								@Metodo = @MetodoTemporal, 
								@TipoMensaje = 'Exitoso', 
								@ErrorMensaje  = NULL,
								@ModeJson = 0;

								SELECT @Resp_1 = 
								(
									SELECT * FROM #Mensajes FOR JSON PATH, INCLUDE_NULL_VALUES
								)
						
								SET @JSON_OUT = ( SELECT @Resp_1  )
						
								TRUNCATE TABLE #Mensajes;				  
								---------------------------------------------------------------------------------------
									
							--FINAL
							IF @@TRANCOUNT > 0
							BEGIN
							  COMMIT TRANSACTION EDITAR
							END		

					END
					ELSE
					BEGIN

								------------------------------ RESPUESTA A LA APP MSJ: 3208 Los campos: Nombre, Codigo, Pais, Modulo son obligatorios ------------------------------------
								
								SET @ERROR_MESSAGE = ERROR_MESSAGE() 
								SET @ERROR_NUMBER = ERROR_NUMBER()

								INSERT INTO #Mensajes 
								EXEC SP_Select_Mensajes_Emergentes_Para_SP 
								@ROWS_AFFECTED = 0,
								@SUCCESS = 0,
								@ERROR_NUMBER_SP = @ERROR_NUMBER ,
								@CONSTRAINT_TRIGGER_NAME = @ERROR_MESSAGE,
								@ID = 0,
								@ROW = NULL,
								@Metodo = @MetodoTemporal, 
								@TipoMensaje = 'Error', 
								@ErrorMensaje  = 'SP_Update_Transportadora_VALORES_NULL',
								@ModeJson = 0;

								SELECT @Resp_1 = 
								(
									SELECT * FROM #Mensajes FOR JSON PATH, INCLUDE_NULL_VALUES
								)
						
								SET @JSON_OUT = ( SELECT @Resp_1  )
						
								TRUNCATE TABLE #Mensajes;				  
								---------------------------------------------------------------------------------------

							--FINAL
							IF @@TRANCOUNT > 0
							BEGIN
							  COMMIT TRANSACTION EDITAR
							END		

					END

	  END TRY    
	  BEGIN CATCH				
				
						------------------------------ RESPUESTA A LA APP MSJ: 3200 3201 ------------------------------------
					
						SET @ERROR_NUMBER = ERROR_NUMBER()				

						IF  @ERROR_NUMBER LIKE '%515%' 
						BEGIN 
						
							SET @ERROR_MESSAGE = 'SP_Update_Transportadora_VALORES_NULL'
						
						END	

						IF  @ERROR_NUMBER LIKE '%2627%'
						BEGIN 
						
							SET @ERROR_MESSAGE = ERROR_MESSAGE() 
						
						END	
								
						INSERT INTO #Mensajes 
						EXEC SP_Select_Mensajes_Emergentes_Para_SP 
						@ROWS_AFFECTED = 0,
						@SUCCESS = 0,
						@ERROR_NUMBER_SP = @ERROR_NUMBER,
						@CONSTRAINT_TRIGGER_NAME = @ERROR_MESSAGE,
						@ID = 0,
						@ROW = NULL,
						@Metodo = @MetodoTemporal, 
						@TipoMensaje = 'Error', 
						@ErrorMensaje = @ERROR_MESSAGE,
						@ModeJson = 0;

						SELECT @Resp_1 = 
						(
							SELECT * FROM #Mensajes FOR JSON PATH, INCLUDE_NULL_VALUES
						)
					
						SET @JSON_OUT = ( SELECT @Resp_1  )
						
						TRUNCATE TABLE #Mensajes;	
						-------------------------------------------------------------------------------------	   

			   IF @@TRANCOUNT > 0
			   BEGIN
			   
					ROLLBACK TRANSACTION EDITAR		

			   END	

	  END CATCH
	   
	---
END