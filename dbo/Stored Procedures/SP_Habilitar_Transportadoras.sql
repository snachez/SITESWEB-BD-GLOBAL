



CREATE   PROCEDURE [dbo].[usp_Habilitar_Transportadoras](
	@JSON_IN VARCHAR(MAX),
	@JSON_OUT  VARCHAR(MAX) OUTPUT 
)
AS
BEGIN

  DECLARE @Resp_1 VARCHAR(MAX)

  IF(@JSON_IN IS NOT NULL OR @JSON_IN != '')
  BEGIN

	SET @JSON_IN = REPLACE( @JSON_IN,'\','')

	---Declaracion Variables Mensajes
    DECLARE @MetodoTemporal VARCHAR(MAX) = 'usp_Habilitar_Transportadoras';
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

	--DECLARACION DE TABLA PARA INSERTAR LOS REGISTROS
	DECLARE @p_Tbl_Temp_Transportadoras TABLE   
     (  
	  ID INT IDENTITY(1,1)
	 ,Id_Transportadora INT
	 ,Activo BIT
    )  

	--INSERTA CADA UNO DE LOS ITEMS EN LA TABLA (SETEANDO LOS VALORES DEL JSON)
	INSERT INTO @p_Tbl_Temp_Transportadoras	 
	SELECT 
		  Id	
		 ,Activo
	FROM OPENJSON (@JSON_IN)
	WITH (transportadoras_DTO NVARCHAR(MAX) AS JSON)
	CROSS APPLY OPENJSON (transportadoras_DTO) 
	WITH 
	(
	  Id INT	 
	 ,Activo BIT
	) 

	--DECLARACION DE VARIABLES PARA RECORRER LA TABLA
	DECLARE @p_Id_Transportadora_Cursor INT	
	DECLARE @p_Activo_Cursor BIT 
	DECLARE @p_Aux_Activo BIT	
 
	DECLARE @Resultado INT
 	DECLARE @CONTINUAR_TRANSACCION INT
	DECLARE @ROW VARCHAR(MAX)


	BEGIN TRY		
		 BEGIN TRANSACTION ACTUALIZAR
				
				------------------------------ RECORRIDO Y SETEO DE DATA DE LA TABLA  ------------------------------------
				
					DECLARE @i INT = 1
					DECLARE @Contador INT = (SELECT COUNT(1) FROM @p_Tbl_Temp_Transportadoras)

					IF @Contador > 0 WHILE (@i <= (SELECT MAX(ID) FROM @p_Tbl_Temp_Transportadoras))
					BEGIN

							--OBTIENE UN ITEM
							SELECT 								
							 @p_Id_Transportadora_Cursor = Id_Transportadora 
							,@p_Activo_Cursor = Activo								
							FROM @p_Tbl_Temp_Transportadoras 
							WHERE ID = @i
							
							IF(@p_Activo_Cursor = 1)
							BEGIN   				   				
								SET @p_Activo_Cursor = 0							
							END
							ELSE 
							BEGIN					      																										
								SET @p_Activo_Cursor = 1	
							END

							SET @Resultado = NULL	
							SELECT @Resultado = dbo.FN_CONTRAINT_VALIDACION_EXISTENCIA_VALORES_ACTIVOS_INACTIVOS_CONTRA_TRANSPORTADORAS_CUANDO_HABILITA(@p_Activo_Cursor, @p_Id_Transportadora_Cursor);			
							IF(@Resultado = 1) --ES POR QUE TIENE RELACIONES ACTIVAS O INACTIVAS
							BEGIN 

								------------------------------ RESPUESTA A LA APP MSJ 3224 ------------------------------------
									SET @ERROR_MESSAGE = ERROR_MESSAGE() 
									SET @ERROR_NUMBER = ERROR_NUMBER()

									INSERT INTO #Mensajes 
									EXEC usp_Select_Mensajes_Emergentes_Para_SP 
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

								ROLLBACK TRANSACTION ACTUALIZAR
								GOTO FINALIZAR 	

							END
							
							SET @Resultado = NULL	
							SELECT @Resultado = dbo.FN_CONTRAINT_VALIDACION_EXISTENCIA_VALORES_ACTIVOS_INACTIVOS_CONTRA_TRASPORTADORA_CUANDO_HABILITA_AGENCIA(@p_Activo_Cursor, @p_Id_Transportadora_Cursor);			
							IF(@Resultado = 1) --ES POR QUE TIENE RELACIONES ACTIVAS O INACTIVAS
							BEGIN 

								------------------------------ RESPUESTA A LA APP MSJ 3224 ------------------------------------
									SET @ERROR_MESSAGE = ERROR_MESSAGE() 
									SET @ERROR_NUMBER = ERROR_NUMBER()

									INSERT INTO #Mensajes 
									EXEC usp_Select_Mensajes_Emergentes_Para_SP 
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

								ROLLBACK TRANSACTION ACTUALIZAR
								GOTO FINALIZAR 	

							END


							UPDATE tblTransportadoras SET Activo =  @p_Activo_Cursor, Fecha_Modificacion = CURRENT_TIMESTAMP WHERE Id = @p_Id_Transportadora_Cursor
							SET @ROW = (SELECT * FROM tblTransportadoras WHERE Id = @p_Id_Transportadora_Cursor FOR JSON PATH)		

							
			    															
						SET @i = @i + 1
					END --FIN DEL CICLO

					------------------------------ RESPUESTA A LA APP MSJ: 3223  ------------------------------------							
							
							INSERT INTO #Mensajes 
							EXEC usp_Select_Mensajes_Emergentes_Para_SP 
							@ROWS_AFFECTED = @@ROWCOUNT,
							@SUCCESS = 1,
							@ERROR_NUMBER_SP = NULL,
							@CONSTRAINT_TRIGGER_NAME = NULL,
							@ID = 0,
							@ROW = @Resultado,
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
				   COMMIT TRANSACTION ACTUALIZAR
				 END		

	  END TRY    
	  BEGIN CATCH

				   ------------------------------ RESPUESTA A LA APP  ------------------------------------
						SELECT @Resp_1 = 
						(
							  SELECT	  @@ROWCOUNT														AS ROWS_AFFECTED
							, CAST(0 AS BIT)																AS SUCCESS
							, 'No Modificado!'																AS ERROR_TITLE_SP
							, 'Error, al intentar actualizar los estados de transportadoras seleccionados'	AS ERROR_MESSAGE_SP
							, NULL																			AS ERROR_NUMBER_SP
							, CONVERT(INT, ISNULL(SCOPE_IDENTITY(), -1))									AS ID
							, NULL																			AS ROW 
							FOR JSON PATH, INCLUDE_NULL_VALUES
						)
										
						SET @JSON_OUT = ( SELECT @Resp_1  )	
				   --------------------------------------------------------------------------------------------


			   IF @@TRANCOUNT > 0
			   BEGIN
				  ROLLBACK TRANSACTION ACTUALIZAR								
			   END	

	  END CATCH
	  GOTO FINALIZAR 
	---
  END
  ELSE
  BEGIN 
	 
						SELECT @Resp_1 = 
						(
							  SELECT	  @@ROWCOUNT												AS ROWS_AFFECTED
							, CAST(0 AS BIT)														AS SUCCESS
							, 'No Modificado!'														AS ERROR_TITLE_SP
							, 'Error, se resivieron datos null'										AS ERROR_MESSAGE_SP
							, NULL																	AS ERROR_NUMBER_SP
							, CONVERT(INT, ISNULL(SCOPE_IDENTITY(), -1))							AS ID
							, NULL																	AS ROW 
							FOR JSON PATH, INCLUDE_NULL_VALUES
						)
					
						SET @JSON_OUT = ( SELECT @Resp_1  )	
	  GOTO FINALIZAR 	 				
  END

  FINALIZAR:RETURN
END
---