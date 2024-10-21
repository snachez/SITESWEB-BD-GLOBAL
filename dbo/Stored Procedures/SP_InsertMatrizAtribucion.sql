
CREATE PROCEDURE [dbo].[usp_InsertMatrizAtribucion](
	@JSON_IN VARCHAR(MAX) = NULL,
	@JSON_OUT  VARCHAR(MAX) OUTPUT 
)
AS
BEGIN

	  ---Declaracion Variables Mensajes
      DECLARE @MetodoTemporal VARCHAR(MAX) = 'usp_InsertMatrizAtribucion';
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

	  SET @JSON_IN = REPLACE( @JSON_IN,'\','');

	  --DECLARACION DE VARIABLES PARA ACCEER A LAS PROPIEDADES Y VALORES QUE VIENEN DENTRO DEL JSON
	  DECLARE @p_Id_Insert_Matriz_Atribucion INT ;
	  DECLARE @p_Id_Insert_Divisa INT;

	  --SETEANDO LOS VALORES DEL JSON (TABLA PADRE DIVISA)
	  SELECT @p_Id_Insert_Divisa = Id FROM OPENJSON( @JSON_IN) WITH (MatrizAtribucion NVARCHAR(MAX) AS JSON) CROSS APPLY OPENJSON (@JSON_IN, '$.Divisa') WITH ( Id INT );

	  --------------------------- DECLARACION DE TABLA PARA INSERTAR LOS REGISTROS DE MATRIZ ATRIBUCION (TABLA PADRE) ----------------------------------------
	  DECLARE @p_Tbl_Temp_Matriz_Atribucion_Insert TABLE   
	  (  
		  ID INT IDENTITY(1,1)
		 ,Activo               BIT
		 ,Nombre               VARCHAR(MAX)
	  );  

		--INSERTA CADA UNO DE LOS ITEMS DE LAS MATRIZ ATRIBUCION
		INSERT INTO @p_Tbl_Temp_Matriz_Atribucion_Insert	 
		SELECT 
			   Activo
			  ,Nombre
		FROM OPENJSON (@JSON_IN)
		WITH 
		(
          Activo               BIT
		 ,Nombre               VARCHAR(MAX)
		); 

	  --------------------------- DECLARACION DE TABLA PARA INSERTAR LOS REGISTROS DE FIRMAS (TABLA HIJO) ----------------------------------------
	  DECLARE @p_Tbl_Temp_Firmas_Insert TABLE   
	  (  
		  ID INT IDENTITY(1,1)
		 ,Firma VARCHAR(MAX)
		 ,MontoDesde DECIMAL(38,2)	
		 ,MontoHasta DECIMAL(38,2)	
	  );  

	  --INSERTA CADA UNO DE LOS ITEMS DE LAS FIRMAS
		INSERT INTO @p_Tbl_Temp_Firmas_Insert	 
		SELECT 
		       Firma
		      ,MontoDesde
		      ,MontoHasta
		FROM OPENJSON (@JSON_IN)
		WITH (MatrizAtribucion NVARCHAR(MAX) AS JSON)
		CROSS APPLY OPENJSON (@JSON_IN, '$.Firmas') 
		WITH 
		(
		   Firma      VARCHAR(MAX)
          ,MontoDesde DECIMAL(38,2)
		  ,MontoHasta DECIMAL(38,2)
		)

	  --------------------------- DECLARACION DE TABLA PARA INSERTAR LOS REGISTROS DE TRANSACCIONES (TABLA HIJO) ----------------------------------------
	  DECLARE @p_Tbl_Temp_Transacciones_Insert TABLE   
	  (  
		  ID              INT IDENTITY(1,1)
		 ,IdTransacciones INT
		 ,Nombre          VARCHAR(MAX)
         ,Activo          BIT
	  );  

	  --INSERTA CADA UNO DE LOS ITEMS DE LAS TRANSACCIONES
		INSERT INTO @p_Tbl_Temp_Transacciones_Insert	 
		SELECT 
		       Id
		      ,Nombre
		      ,Activo
		FROM OPENJSON (@JSON_IN)
		WITH (MatrizAtribucion NVARCHAR(MAX) AS JSON)
		CROSS APPLY OPENJSON (@JSON_IN, '$.Transacciones') 
		WITH 
		(
		   Id    INT
		  ,Nombre             VARCHAR(MAX)
          ,Activo             BIT
		)

	  --DECLARACION DE VARIABLES PARA RECORRER LA TABLA TEMPORAL FIRMAS
	  DECLARE @p_Firma_Firma_Iterador VARCHAR(MAX);
	  DECLARE @p_MontoDesde_Firma_Iterador DECIMAL(38,2);
	  DECLARE @p_MontoHasta_Firma_Iterador DECIMAL(38,2);
	  --DECLARACION DE VARIABLES PARA RECORRER LA TABLA TEMPORAL TRANSACCIONES
	  DECLARE @p_Id_Transaccion_Iterador INT;
	  DECLARE @p_Nombre_Transaccion_Iterador VARCHAR(MAX);

	  --VARIABLES PARA DAR RESPUESTA
	  DECLARE @Id_Matriz_Por_Transaccion_Insertada INT;
	  DECLARE @Id_Matriz_Por_Firma_Insertada INT;

	  DECLARE @Resp_1 VARCHAR(MAX);
	  DECLARE @Resp_2 VARCHAR(MAX);
	  DECLARE @ROW VARCHAR(MAX);

	  BEGIN TRY	

		--ACA SE PONEN LAS VALIDACIONES 
		 IF EXISTS(SELECT 1 FROM [tblMatrizAtribucion_Transaccion] MT 
		           INNER JOIN @p_Tbl_Temp_Transacciones_Insert T ON MT.Fk_Id_Transaccion = T.IdTransacciones  WHERE MT.Activo = 1)        
		 BEGIN   
				 ------------------------------ RESPUESTA A LA APP  ------------------------------------

						SET @ERROR_NUMBER = ERROR_NUMBER();

						INSERT INTO #Mensajes 
						EXEC usp_Select_Mensajes_Emergentes_Para_SP 
						@ROWS_AFFECTED = 0,
						@SUCCESS = 0,
						@ERROR_NUMBER_SP = @ERROR_NUMBER,
						@CONSTRAINT_TRIGGER_NAME = 'Relacion_Unica_Transaccion_Matriz',
						@ID = -1,
						@ROW = NULL,
						@Metodo = @MetodoTemporal, 
						@TipoMensaje = 'Error', 
						@ErrorMensaje = 'Relacion_Unica_Transaccion_Matriz',
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

		 ---------------------------------------------------------------------------------------

		 BEGIN TRANSACTION INSERTAR
								   
					--INSERTA EN LA TABLA MATRIZ ATRIBUCION

					INSERT INTO tblMatrizAtribucion ( Nombre, Fk_Id_Divisa, Activo, FechaCreacion )
					SELECT  Nombre, @p_Id_Insert_Divisa, Activo, CURRENT_TIMESTAMP from @p_Tbl_Temp_Matriz_Atribucion_Insert;

					SELECT @p_Id_Insert_Matriz_Atribucion = CONVERT(INT, ISNULL(SCOPE_IDENTITY(), -1));

					IF(@p_Id_Insert_Matriz_Atribucion IS NOT NULL)
					BEGIN   
				   		
						------------------------------ INICIO DEL RECORRIDO Y SETEO DE DATA DE LA TABLA TEMPORAL TRANSACCIONES  ------------------------------------

						DECLARE @i INT = 1
						DECLARE @Contador INT = (SELECT COUNT(1) FROM  @p_Tbl_Temp_Transacciones_Insert)

						IF @Contador > 0 WHILE (@i <= (SELECT MAX(ID) FROM @p_Tbl_Temp_Transacciones_Insert))
						BEGIN

							--OBTIENE UN ITEM
							SELECT 								
							 @p_Id_Transaccion_Iterador = IdTransacciones
							,@p_Nombre_Transaccion_Iterador = Nombre									
							FROM @p_Tbl_Temp_Transacciones_Insert 
							WHERE ID = @i
								
							--INSERTA EN LA TABLA tblMatrizAtribucion_Transaccion
							INSERT INTO tblMatrizAtribucion_Transaccion ( [Fk_Id_MatrizAtribucion], [Fk_Id_Transaccion], [Activo], [FechaCreacion] )
																       VALUES ( @p_Id_Insert_Matriz_Atribucion, @p_Id_Transaccion_Iterador, 1, CURRENT_TIMESTAMP )
			    				
							SELECT @Id_Matriz_Por_Transaccion_Insertada = CONVERT(INT, ISNULL(SCOPE_IDENTITY(), -1)) 
							
							SET @i = @i + 1

						END --FIN DEL CICLO								
					END
					------------------------------ FIN DEL RECORRIDO Y SETEO DE DATA DE LA TABLA TEMPORAL TRANSACCIONES  ------------------------------------

					IF(@Id_Matriz_Por_Transaccion_Insertada IS NOT NULL)
					BEGIN   

						------------------------------ INICIO DEL RECORRIDO Y SETEO DE DATA DE LA TABLA TEMPORAL FIRMAS  ------------------------------------

						DECLARE @iter INT = 1
						DECLARE @ExisteFirma INT = 0;
						DECLARE @Conta INT = (SELECT COUNT(1) FROM  @p_Tbl_Temp_Firmas_Insert	 )

						IF @Conta > 0 WHILE (@iter <= (SELECT MAX(ID) FROM @p_Tbl_Temp_Firmas_Insert	 ))
						BEGIN

							--OBTIENE UN ITEM
							SELECT 								
							 @p_Firma_Firma_Iterador = Firma
							,@p_MontoDesde_Firma_Iterador = MontoDesde
							,@p_MontoHasta_Firma_Iterador = MontoHasta
							FROM @p_Tbl_Temp_Firmas_Insert 
							WHERE ID = @iter

							--VALIDA SI EXISTE LA DATA EN tblFirmas
							SELECT @ExisteFirma = COUNT(*) FROM tblFirmas F
							WHERE F.Firma = @p_Firma_Firma_Iterador 
							AND   F.MontoDesde = @p_MontoDesde_Firma_Iterador
							AND   F.MontoHasta = @p_MontoHasta_Firma_Iterador;

							  IF @ExisteFirma > 0
							  BEGIN

							     SELECT @ExisteFirma = Id FROM tblFirmas F WHERE F.Firma = @p_Firma_Firma_Iterador 
							                                    AND   F.MontoDesde = @p_MontoDesde_Firma_Iterador
							                                    AND   F.MontoHasta = @p_MontoHasta_Firma_Iterador;

								 --INSERTA EN LA TABLA tblMatrizAtribucion_Firmas
								 INSERT INTO tblMatrizAtribucion_Firmas ( [Fk_Id_MatrizAtribucion], [Fk_Id_Firmas], [Activo], [FechaCreacion] )
												VALUES ( @p_Id_Insert_Matriz_Atribucion, @ExisteFirma, 1, CURRENT_TIMESTAMP );

							  END
							  ELSE
							  BEGIN

						    --INSERTA EN LA TABLA tblFirmas
							INSERT INTO tblFirmas ( [Firma], [MontoDesde], [MontoHasta], [Activo], [FechaCreacion] )
												VALUES ( @p_Firma_Firma_Iterador, @p_MontoDesde_Firma_Iterador, @p_MontoHasta_Firma_Iterador, 1, CURRENT_TIMESTAMP )

							SELECT @Id_Matriz_Por_Firma_Insertada = CONVERT(INT, ISNULL(SCOPE_IDENTITY(), -1));

							--INSERTA EN LA TABLA tblMatrizAtribucion_Firmas
							INSERT INTO tblMatrizAtribucion_Firmas ( [Fk_Id_MatrizAtribucion], [Fk_Id_Firmas], [Activo], [FechaCreacion] )
																  VALUES ( @p_Id_Insert_Matriz_Atribucion, @Id_Matriz_Por_Firma_Insertada, 1, CURRENT_TIMESTAMP )
												
			    			  END	
			    											
							SET @iter = @iter + 1
						END --FIN DEL CICLO

					END

											
					SELECT @ROW = (SELECT * FROM tblMatrizAtribucion WHERE Id = @p_Id_Insert_Matriz_Atribucion FOR JSON PATH, INCLUDE_NULL_VALUES)
					
					------------------------------ RESPUESTA A LA APP  ------------------------------------
						INSERT INTO #Mensajes 
						EXEC usp_Select_Mensajes_Emergentes_Para_SP 
						@ROWS_AFFECTED = @@ROWCOUNT,
						@SUCCESS = 1,
						@ERROR_NUMBER_SP = NULL,
						@CONSTRAINT_TRIGGER_NAME = NULL,
						@ID = @Id_Matriz_Por_Transaccion_Insertada,
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
					
				   ------------------------------ RESPUESTA A LA APP  ------------------------------------
						
						DECLARE @ERROR VARCHAR(MAX) = ERROR_MESSAGE();
						SET @ERROR_NUMBER = ERROR_NUMBER();

						INSERT INTO #Mensajes 
						EXEC usp_Select_Mensajes_Emergentes_Para_SP 
						@ROWS_AFFECTED = 0,
						@SUCCESS = 0,
						@ERROR_NUMBER_SP = @ERROR_NUMBER,
						@CONSTRAINT_TRIGGER_NAME = @ERROR,
						@ID = @Id_Matriz_Por_Transaccion_Insertada,
						@ROW = NULL,
						@Metodo = @MetodoTemporal, 
						@TipoMensaje = 'Error', 
						@ErrorMensaje = @ERROR,
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