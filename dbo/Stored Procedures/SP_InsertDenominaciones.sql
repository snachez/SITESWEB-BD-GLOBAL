


CREATE   PROCEDURE [dbo].[usp_InsertDenominaciones](
	@JSON_IN VARCHAR(MAX),
	@JSON_OUT  VARCHAR(MAX) OUTPUT 
)
AS
BEGIN

	  ---Declaracion Variables Mensajes
      DECLARE @MetodoTemporal VARCHAR(MAX) = 'usp_InsertDenominaciones';
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

  IF(@JSON_IN IS NOT NULL AND @JSON_IN != '' AND ISJSON(@JSON_IN) = 1)
  BEGIN

	  SET @JSON_IN = REPLACE( @JSON_IN,'\','')

	  --DECLARACION DE VARIABLES PARA ACCEER A LAS PROPIEDADES Y VALORES QUE VIENEN DENTRO DEL JSON
	  DECLARE @p_Nombre_Denominaciones VARCHAR(MAX) 
	  DECLARE @p_ValorNominal_Denominaciones DECIMAL(18,0)
	  DECLARE @p_Id_Divisa_Denominaciones INT
	  DECLARE @p_Presentacion_Denominaciones INT
	  DECLARE @p_Imagen_Denominaciones VARCHAR(MAX)
	  DECLARE @p_Activo_Denominaciones BIT

	  --AUN NO ESTAN EN USO
	  DECLARE @p_user_id INT 
	  DECLARE @Action VARCHAR(1)

	  --SETEANDO LOS VALORES DEL JSON (TABLA PADRE UNIDADES DE MEDIDAS)
	  SELECT @p_Nombre_Denominaciones = Nombre FROM OPENJSON( @JSON_IN) WITH ( NOMBRE VARCHAR(MAX) )
	  SELECT @p_ValorNominal_Denominaciones = VALORNOMINAL FROM OPENJSON( @JSON_IN) WITH ( VALORNOMINAL DECIMAL(18,0) )
	  SELECT @p_Id_Divisa_Denominaciones = DIVISA FROM OPENJSON( @JSON_IN) WITH ( DIVISA INT )
	  SELECT @p_Presentacion_Denominaciones = BMO FROM OPENJSON( @JSON_IN) WITH ( BMO INT )
	  SELECT @p_Imagen_Denominaciones = IMAGEN FROM OPENJSON( @JSON_IN) WITH ( IMAGEN VARCHAR(MAX) )
	  SELECT @p_Activo_Denominaciones = ACTIVO FROM OPENJSON( @JSON_IN) WITH ( ACTIVO BIT )

	  --------------------------- DECLARACION DE TABLA PARA INSERTAR LOS REGISTROS DE MODULO (TABLA HIJO) ----------------------------------------
	  DECLARE @p_Tbl_Temp_Modulo TABLE   
	  (  
		  ID INT IDENTITY(1,1)
		 ,FK_ID_Modulo INT	 
	  )  

		--INSERTA CADA UNO DE LOS ITEMS DE LA DIVISA
		INSERT INTO @p_Tbl_Temp_Modulo	 
		SELECT 
			   FK_ID_Modulo  
		FROM OPENJSON (@JSON_IN)
		WITH (Modulo NVARCHAR(MAX) AS JSON)
		CROSS APPLY OPENJSON (Modulo) 
		WITH 
		(
		   FK_ID_Modulo INT
		) 

	  --DECLARACION DE VARIABLES PARA RECORRER LA TABLA TEMPORAL DIVISAS
	  DECLARE @p_Id_Modulo_Denominaciones_Iterador INT

	  --VARIABLES PARA DAR RESPUESTA
	  DECLARE @Id_Denominaciones_Insertada INT

	  DECLARE @Resp_1 VARCHAR(MAX)
	  DECLARE @Resp_2 VARCHAR(MAX)
	  DECLARE @ROW VARCHAR(MAX)

	  BEGIN TRY	
	 
		 BEGIN TRANSACTION INSERTAR
								   
					--INSERTA EN LA TABLA UNIDADES DE MEDIDAS
					INSERT INTO dbo.[tblDenominaciones] (Nombre, ValorNominal, IdDivisa, BMO, Imagen, Activo , FechaCreacion)
											    VALUES(	@p_Nombre_Denominaciones,	@p_ValorNominal_Denominaciones,	@p_Id_Divisa_Denominaciones, @p_Presentacion_Denominaciones, 
												@p_Imagen_Denominaciones, @p_Activo_Denominaciones, (CONVERT([smalldatetime],getdate())) )

					SELECT @Id_Denominaciones_Insertada = CONVERT(INT, ISNULL(SCOPE_IDENTITY(), -1))

					IF(@Id_Denominaciones_Insertada IS NOT NULL)
					BEGIN   
				   		
						------------------------------ INICIO DEL RECORRIDO Y SETEO DE DATA DE LA TABLA TEMPORAL DIVISA  ------------------------------------

						DECLARE @i INT = 1
						DECLARE @Contador INT = (SELECT COUNT(1) FROM  @p_Tbl_Temp_Modulo)

						IF @Contador > 0 WHILE (@i <= (SELECT MAX(ID) FROM @p_Tbl_Temp_Modulo))
						BEGIN

							--OBTIENE UN ITEM
							SELECT 								
							 @p_Id_Modulo_Denominaciones_Iterador = FK_ID_Modulo								
							FROM @p_Tbl_Temp_Modulo 
							WHERE ID = @i


								--INSERTA EN LA TABLA tblDenominaciones_x_Modulo
								INSERT INTO dbo.[tblDenominaciones_x_Modulo] (FkIdDenominaciones, FkIdModulo, Activo, FechaCreacion)
																	VALUES (  @Id_Denominaciones_Insertada,    @p_Id_Modulo_Denominaciones_Iterador, 1, (CONVERT([smalldatetime],getdate())) )
			    				

							SET @i = @i + 1
						END --FIN DEL CICLO
														
					END

					SELECT @ROW = (SELECT * FROM tblDenominaciones WHERE Id = @Id_Denominaciones_Insertada FOR JSON PATH, INCLUDE_NULL_VALUES)
					------------------------------ FIN DEL RECORRIDO Y SETEO DE DATA DE LA TABLA TEMPORAL DIVISA  ------------------------------------
															
					------------------------------ RESPUESTA A LA APP  ------------------------------------
						INSERT INTO #Mensajes 
						EXEC usp_Select_Mensajes_Emergentes_Para_SP 
						@ROWS_AFFECTED = @@ROWCOUNT,
						@SUCCESS = 1,
						@ERROR_NUMBER_SP = NULL,
						@CONSTRAINT_TRIGGER_NAME = NULL,
						@ID = @Id_Denominaciones_Insertada,
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
				    ---------------------------------------------------------------------------------------

				  --FINAL
				 IF @@TRANCOUNT > 0
				 BEGIN
				   COMMIT TRANSACTION INSERTAR
				 END		

	  END TRY    
	  BEGIN CATCH

						DECLARE @ERROR VARCHAR(MAX) = ERROR_MESSAGE();
						SET @ERROR_NUMBER = ERROR_NUMBER();

						INSERT INTO #Mensajes 
						EXEC usp_Select_Mensajes_Emergentes_Para_SP 
						@ROWS_AFFECTED = 0,
						@SUCCESS = 0,
						@ERROR_NUMBER_SP = @ERROR_NUMBER,
						@CONSTRAINT_TRIGGER_NAME = @ERROR,
						@ID = @Id_Denominaciones_Insertada,
						@ROW = NULL,
						@Metodo = @MetodoTemporal, 
						@TipoMensaje = 'Error', 
						@ErrorMensaje = @ERROR,
						@ModeJson = 0;		

				   ------------------------------ RESPUESTA A LA APP  ------------------------------------
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
				   -----------------------------------------------------------------------------------------


			   IF @@TRANCOUNT > 0
			   BEGIN
				  ROLLBACK TRANSACTION INSERTAR								
			   END	

	  END CATCH
	  GOTO FINALIZAR 
	---
  END
  ELSE
  BEGIN 
				 ------------------------------ RESPUESTA A LA APP  ------------------------------------
						SET @ERROR_NUMBER = ERROR_NUMBER();

						INSERT INTO #Mensajes 
						EXEC usp_Select_Mensajes_Emergentes_Para_SP 
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
	  
	  GOTO FINALIZAR 	 				
  END

  FINALIZAR:RETURN
END
---