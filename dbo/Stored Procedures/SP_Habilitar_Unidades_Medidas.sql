


CREATE   PROCEDURE [dbo].[SP_Habilitar_Unidades_Medidas](
	@JSON_IN VARCHAR(MAX) = NULL,
	@JSON_OUT  VARCHAR(MAX) OUTPUT 
)
AS
BEGIN

	---Declaracion Variables Mensajes
    DECLARE @MetodoTemporal VARCHAR(MAX) = 'SP_Habilitar_Unidades_Medidas';
	DECLARE @ErrorMensaje VARCHAR(MAX);
	DECLARE @ERROR_NUMBER VARCHAR(MAX);

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

  IF(@JSON_IN IS NOT NULL AND @JSON_IN <> '' AND ISJSON(@JSON_IN) = 1)
  BEGIN

	SET @JSON_IN = REPLACE( @JSON_IN,'\','')

	--DECLARACION DE TABLA PARA INSERTAR LOS REGISTROS
	DECLARE @p_Tbl_Temp_Unidad_Medidas TABLE   
     (  
	  ID INT IDENTITY(1,1)
	 ,Id_Unidad_Medida INT
	 ,Activo BIT
    )  

	--INSERTA CADA UNO DE LOS ITEMS EN LA TABLA (SETEANDO LOS VALORES DEL JSON)
	INSERT INTO @p_Tbl_Temp_Unidad_Medidas	 
	SELECT 
		  Id	
		 ,Activo
	FROM OPENJSON (@JSON_IN)
	WITH (unidades_Medidas_DTO NVARCHAR(MAX) AS JSON)
	CROSS APPLY OPENJSON (unidades_Medidas_DTO) 
	WITH 
	(
	  Id INT	 
	 ,Activo BIT
	) 

  --DECLARACION DE VARIABLES PARA RECORRER LA TABLA
  DECLARE @p_Id_Unidad_Medida_Cursor INT	
  DECLARE @p_Activo_Cursor BIT 
  DECLARE @p_Aux_Activo BIT	
 
  DECLARE @Resp_1 VARCHAR(MAX)
  DECLARE @Resp_2 VARCHAR(MAX)
  DECLARE @ROW VARCHAR(MAX)

	 BEGIN TRY		
		 BEGIN TRANSACTION ACTUALIZAR
				
				------------------------------ RECORRIDO Y SETEO DE DATA DE LA TABLA  ------------------------------------
				
					DECLARE @i INT = 1
					DECLARE @Contador INT = (SELECT COUNT(1) FROM @p_Tbl_Temp_Unidad_Medidas)

					IF @Contador > 0 BEGIN WHILE (@i <= (SELECT MAX(ID) FROM @p_Tbl_Temp_Unidad_Medidas))
						BEGIN

							--OBTIENE UN ITEM
							SELECT 								
							 @p_Id_Unidad_Medida_Cursor = Id_Unidad_Medida 
							,@p_Activo_Cursor = Activo								
							FROM @p_Tbl_Temp_Unidad_Medidas 
							WHERE ID = @i
								
							SET @p_Aux_Activo = NULL	
							SELECT @p_Aux_Activo = (SELECT Activo FROM tblUnidadMedida WHERE Id = @p_Id_Unidad_Medida_Cursor)	
							--SELECT @Aux_1_Existe 
						
							   IF(@p_Aux_Activo = 1)
							   BEGIN   
				   				
									UPDATE tblUnidadMedida SET Activo = 0, Fecha_Modificacion = CURRENT_TIMESTAMP WHERE Id = @p_Id_Unidad_Medida_Cursor
									SET @ROW = (SELECT * FROM tblUnidadMedida WHERE Id = @p_Id_Unidad_Medida_Cursor FOR JSON PATH)												  
								
							   END
							   ELSE 
							   BEGIN					      									
																		
									UPDATE tblUnidadMedida SET Activo = 1, Fecha_Modificacion = CURRENT_TIMESTAMP WHERE Id = @p_Id_Unidad_Medida_Cursor
									SET @ROW = (SELECT * FROM tblUnidadMedida WHERE Id = @p_Id_Unidad_Medida_Cursor FOR JSON PATH)		

							   END
			    															
							 SET @i = @i + 1
						END --FIN DEL CICLO
					END
					------------------------------ RESPUESTA A LA APP  ------------------------------------
						INSERT INTO #Mensajes 
						EXEC SP_Select_Mensajes_Emergentes_Para_SP 
						@ROWS_AFFECTED = @@ROWCOUNT,
						@SUCCESS = 1,
						@ERROR_NUMBER_SP = NULL,
						@CONSTRAINT_TRIGGER_NAME = NULL,
						@ID = @p_Id_Unidad_Medida_Cursor,
						@ROW = @ROW,
						@Metodo = @MetodoTemporal, 
						@TipoMensaje = 'Exitoso', 
						@ErrorMensaje = NULL,
						@ModeJson = 0;
						
						SELECT @Resp_1 = 
						(
							SELECT * FROM #Mensajes FOR JSON PATH, INCLUDE_NULL_VALUES
						)

						SELECT @Resp_2 = 
						( 
							SELECT CAST(@Resp_1 AS VARCHAR(MAX)) 
						)
						
						SET @JSON_OUT = ( SELECT @Resp_2  )	
						
						TRUNCATE TABLE #Mensajes;
				   --------------------------------------------------------------------------------------------

				  --FINAL
				 IF @@TRANCOUNT > 0
				 BEGIN
				   COMMIT TRANSACTION ACTUALIZAR
				 END		

	  END TRY    
	  BEGIN CATCH

				   ------------------------------ RESPUESTA A LA APP  ------------------------------------

						SET @ERROR_NUMBER = ERROR_NUMBER();

						INSERT INTO #Mensajes 
						EXEC SP_Select_Mensajes_Emergentes_Para_SP 
						@ROWS_AFFECTED = 0,
						@SUCCESS = 0,
						@ERROR_NUMBER_SP = @ERROR_NUMBER,
						@CONSTRAINT_TRIGGER_NAME = 'JSON Diferente',
						@ID = @p_Id_Unidad_Medida_Cursor,
						@ROW = NULL,
						@Metodo = @MetodoTemporal, 
						@TipoMensaje = 'Error', 
						@ErrorMensaje = 'JSON Diferente',
						@ModeJson = 0;		

						SELECT @Resp_1 = 
						(
							  SELECT * FROM #Mensajes FOR JSON PATH, INCLUDE_NULL_VALUES
						)

						SELECT @Resp_2 = 
						( 
							SELECT CAST(@Resp_1 AS VARCHAR(MAX)) 
						)
						
						SET @JSON_OUT = ( SELECT @Resp_2  )	
						
						TRUNCATE TABLE #Mensajes;
				   --------------------------------------------------------------------------------------------


			   IF @@TRANCOUNT > 0
			   BEGIN
				  ROLLBACK TRANSACTION ACTUALIZAR								
			   END	

	  END CATCH
	   
	---
  END
  ELSE
  BEGIN 
				 ------------------------------ RESPUESTA A LA APP  ------------------------------------

						SET @ERROR_NUMBER = ERROR_NUMBER();

						INSERT INTO #Mensajes 
						EXEC SP_Select_Mensajes_Emergentes_Para_SP 
						@ROWS_AFFECTED = 0,
						@SUCCESS = 0,
						@ERROR_NUMBER_SP = @ERROR_NUMBER,
						@CONSTRAINT_TRIGGER_NAME = 'Error JSON',
						@ID = -1,
						@ROW = NULL,
						@Metodo = @MetodoTemporal, 
						@TipoMensaje = 'Error', 
						@ErrorMensaje = 'Error JSON',
						@ModeJson = 0;		

						SELECT @Resp_1 = 
						(
							  SELECT * FROM #Mensajes FOR JSON PATH, INCLUDE_NULL_VALUES
						)

						SELECT @Resp_2 = 
						( 
							SELECT CAST(@Resp_1 AS VARCHAR(MAX)) 
						)
						
						SET @JSON_OUT = ( SELECT @Resp_2  )	

						TRUNCATE TABLE #Mensajes;
				----------------------------------------------------------------------------------------
	  
	   	 				
  END

  
END
---