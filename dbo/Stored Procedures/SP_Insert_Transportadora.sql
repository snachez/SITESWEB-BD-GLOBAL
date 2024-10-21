

CREATE   PROCEDURE [dbo].[SP_Insert_Transportadora] (

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
      DECLARE @MetodoTemporal VARCHAR(MAX) = 'SP_Insert_Transportadora';
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
	  DECLARE @p_Nombre_Transportadora VARCHAR(MAX) 
	  DECLARE @p_Codigo_Transportadora VARCHAR(MAX)
	  DECLARE @p_Activo_Transportadora BIT

	  --AUN NO ESTAN EN USO
	   
	  

	  --SETEANDO LOS VALORES DEL JSON (TABLA PADRE TRANSPORTADORA)
	  SELECT @p_Nombre_Transportadora = Nombre FROM OPENJSON( @JSON_IN) WITH ( Nombre VARCHAR(MAX) )
	  --apesar de que viene el codigo de transportadora en la variable @JSON_IN se setea nuevamente dicho codigo aqui, por que puede darse el caso que desde en el front end lo cambien
	  EXECUTE SP_Select_Codigo_Consecutivo_Transportadora @p_Codigo_Transportadora OUTPUT 	 
	  SELECT @p_Activo_Transportadora = Activo FROM OPENJSON( @JSON_IN) WITH ( Activo BIT )

	  --------------------------- DECLARACION DE TABLA PARA INSERTAR LOS REGISTROS DE PAISES (TABLA HIJO) ----------------------------------------
	  DECLARE @p_Tabl_Temp_Pais_Nuevos TABLE   
	  (  
		  ID INT IDENTITY(1,1) 
		 ,Id_Pais INT NULL
		 ,Nombre VARCHAR(MAX) NULL	 
	  )  

	  --INSERTA CADA UNO DE LOS ITEMS DE LOS PAISES
	  INSERT INTO @p_Tabl_Temp_Pais_Nuevos	 
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

	  --------------------------- DECLARACION DE TABLA PARA INSERTAR LOS REGISTROS DE MODULOS (TABLA HIJO) ----------------------------------------
	 
	  DECLARE @p_Tbl_Temp_Modulo_Nuevos TABLE   
	  (  
		  ID INT IDENTITY(1,1) 
		 ,Id_Modulo INT NULL
		 ,Nombre VARCHAR(MAX) NULL	 
	  )  

	  --INSERTA CADA UNO DE LOS ITEMS DE LOS PAISES
	  INSERT INTO @p_Tbl_Temp_Modulo_Nuevos
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
	  DECLARE @p_Id_Transportadora_Insertada INT
	  DECLARE @CONTINUAR_TRANSACCION INT

	  DECLARE @ROW VARCHAR(MAX)
	  DECLARE @total_Items_Tbl_Transportadora_Antes INT
	  DECLARE @total_Items_Tbl_Transportadora_Despues INT

      --VALIDAR EXISTENCIA TRANSPORTADORA POR PAIS Y MODULO

	  IF EXISTS(SELECT 1 FROM tblTransportadoras WHERE Nombre = @p_Nombre_Transportadora)        
	  BEGIN   	   
																													
			DECLARE @Resultado INT
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

	  BEGIN TRY	
	 
		 BEGIN TRANSACTION INSERTAR
															
					--INSERTA EN LA TABLA TRANSPORTADORA
					
					SET @total_Items_Tbl_Transportadora_Antes = (SELECT COUNT(*) FROM tblTransportadoras)
					INSERT INTO tblTransportadoras(Nombre, Codigo, Activo, Fecha_Creacion ) VALUES( @p_Nombre_Transportadora, @p_Codigo_Transportadora, @p_Activo_Transportadora, GETDATE())
					SET @total_Items_Tbl_Transportadora_Despues = (SELECT COUNT(*) FROM tblTransportadoras)
					
					IF(@total_Items_Tbl_Transportadora_Despues > @total_Items_Tbl_Transportadora_Antes) -- SI ES MAYOR ES POR QUE INSERTO
					BEGIN   

				   		SELECT @p_Id_Transportadora_Insertada = (SELECT MAX([Id]) FROM tblTransportadoras) -- NO CAMBIAR POR: SELECT SCOPE_IDENTITY()

					    ------------------------------ INICIO DEL RECORRIDO Y SETEO DE DATA DE LA TABLA TEMPORAL PAISES (TABLA HIJO) ------------------------------------

						DECLARE @i INT = 1
						DECLARE @Contador INT = (SELECT COUNT(1) FROM  @p_Tabl_Temp_Pais_Nuevos	 )

						IF @Contador > 0 BEGIN WHILE (@i <= (SELECT MAX(ID) FROM @p_Tabl_Temp_Pais_Nuevos	 ))
							BEGIN

								--OBTIENE UN ITEM
								SELECT 								
								 @p_Id_Pais_Iterador = Id_Pais
								,@p_Nombre_Pais_Iterador = Nombre									
								FROM @p_Tabl_Temp_Pais_Nuevos 
								WHERE ID = @i
												
								--INSERTA EN LA TABLA tblTransportadoras_x_Pais
								INSERT INTO dbo.[tblTransportadoras_x_Pais] (    [Fk_Id_Transportadora],          [Fk_Id_Pais],     [Fecha_Creacion],  [Activo]  )
																 VALUES (   @p_Id_Transportadora_Insertada,    @p_Id_Pais_Iterador,    GETDATE(),          1  )			    												

								SET @i = @i + 1
							END --FIN DEL CICLO
						END
						------------------------------ FIN DEL RECORRIDO Y SETEO DE DATA DE LA TABLA TEMPORAL PAISES (TABLA HIJO) ------------------------------------			
						------------------------------ INICIO DEL RECORRIDO Y SETEO DE DATA DE LA TABLA TEMPORAL MODULOS  ------------------------------------

						DECLARE @iter INT = 1
						DECLARE @Conta INT = (SELECT COUNT(1) FROM  @p_Tbl_Temp_Modulo_Nuevos	 )

						IF @Conta > 0 WHILE (@iter <= (SELECT MAX(ID) FROM @p_Tbl_Temp_Modulo_Nuevos	 ))
						BEGIN

							--OBTIENE UN ITEM
							SELECT 								
							 @p_Id_Modulo_Iterador = Id_Modulo
							,@p_Nombre_Modulo_Iterador = Nombre									
							FROM @p_Tbl_Temp_Modulo_Nuevos 
							WHERE ID = @iter
						
							--INSERTA EN LA TABLA tblTransportadoras_x_Modulo
							INSERT INTO dbo.[tblTransportadoras_x_Modulo] (      [Fk_Id_Transportadora],      	        [Fk_Id_Modulo],      [Activo],    [Fecha_Creacion]   )
																   VALUES (   @p_Id_Transportadora_Insertada,    @p_Id_Modulo_Iterador,       1,            GETDATE()     )
			    											
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
						
								SELECT @ROW = (SELECT * FROM tblTransportadoras WHERE Id = @p_Id_Transportadora_Insertada FOR JSON PATH, INCLUDE_NULL_VALUES)
										
								------------------------------ RESPUESTA A LA APP MSJ: 3198 Transportadora insertada con exito!  ------------------------------------							

								INSERT INTO #Mensajes 
								EXEC SP_Select_Mensajes_Emergentes_Para_SP 
								@ROWS_AFFECTED = @@ROWCOUNT,
								@SUCCESS = 1,
								@ERROR_NUMBER_SP = NULL,
								@CONSTRAINT_TRIGGER_NAME = NULL,
								@ID = @p_Id_Transportadora_Insertada,
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
							  COMMIT TRANSACTION INSERTAR
							END		

					END
					ELSE
					BEGIN

								------------------------------ RESPUESTA A LA APP MSJ: 3202 Los campos: Nombre, Codigo, Pais, Modulo son obligatorios ------------------------------------
								
								SET @ERROR_MESSAGE = ERROR_MESSAGE() --no devuelve nada por que se esta validando arriba con el count antes y el despues si se realizo la insercion
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
								@ErrorMensaje  = 'SP_Insert_Transportadora_VALORES_NULL',
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
							  COMMIT TRANSACTION INSERTAR
							END		

					END

	  END TRY    
	  BEGIN CATCH				
				
						------------------------------ RESPUESTA A LA APP MSJ: 3200 3201 ------------------------------------
					
						SET @ERROR_NUMBER = ERROR_NUMBER()				

						IF  @ERROR_NUMBER LIKE '%515%' -- SP_Insert_Transportadora_VALORES_NULL
						BEGIN 
						
							SET @ERROR_MESSAGE = 'SP_Insert_Transportadora_VALORES_NULL' 
						
						END	

						IF  @ERROR_NUMBER LIKE '%2627%' -- Unique_Codigo_Transportadora
						BEGIN 
						
							SET @ERROR_MESSAGE = ERROR_MESSAGE() 
						
						END	

						IF  @ERROR_NUMBER LIKE '%547%' -- Unique_Nombre_Transportadora_By_Pais_And_Modulo
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
			   
					ROLLBACK TRANSACTION INSERTAR		
					 																
						DECLARE @ultimo_Id_Tbl_Transportadora_Insertado_Para_ROLLBACK INT 	
						SELECT @ultimo_Id_Tbl_Transportadora_Insertado_Para_ROLLBACK = MAX([Id]) FROM [tblTransportadoras]	
						IF (@ultimo_Id_Tbl_Transportadora_Insertado_Para_ROLLBACK IS NULL) -- validacion requerida ya que cuando sea la primera vez que inserte un registro puede ocurrir algo y se setea a 0 la tabla para que esta no camine nuevamente
						BEGIN
							SET @ultimo_Id_Tbl_Transportadora_Insertado_Para_ROLLBACK = 0
						END
						DBCC CHECKIDENT ('[tblTransportadoras]', RESEED, @ultimo_Id_Tbl_Transportadora_Insertado_Para_ROLLBACK )

						DECLARE @ultimo_Id_TblTransportadoras_x_Pais_Insertado_Para_ROLLBACK INT
						SELECT @ultimo_Id_TblTransportadoras_x_Pais_Insertado_Para_ROLLBACK = MAX([Id]) FROM [tblTransportadoras_x_Pais]	
						IF (@ultimo_Id_TblTransportadoras_x_Pais_Insertado_Para_ROLLBACK  IS NULL) 
						BEGIN
							SET @ultimo_Id_TblTransportadoras_x_Pais_Insertado_Para_ROLLBACK = 1
						END
						DBCC CHECKIDENT ('[tblTransportadoras_x_Pais]', RESEED, @ultimo_Id_TblTransportadoras_x_Pais_Insertado_Para_ROLLBACK )

						DECLARE @ultimo_Id_TblTransportadoras_x_Modulo_Insertado_Para_ROLLBACK INT
						SELECT @ultimo_Id_TblTransportadoras_x_Modulo_Insertado_Para_ROLLBACK = MAX([Id]) FROM [tblTransportadoras_x_Modulo]		
						IF (@ultimo_Id_TblTransportadoras_x_Modulo_Insertado_Para_ROLLBACK IS NULL)
						BEGIN
							SET @ultimo_Id_TblTransportadoras_x_Modulo_Insertado_Para_ROLLBACK = 1
						END									
						DBCC CHECKIDENT ('[tblTransportadoras_x_Modulo]', RESEED, @ultimo_Id_TblTransportadoras_x_Modulo_Insertado_Para_ROLLBACK  )

			   END	

	  END CATCH
	   
	---
END