CREATE PROCEDURE [dbo].[SP_UpdateMatrizAtribucion](
	@JSON_IN VARCHAR(MAX) = NULL,
	@JSON_OUT  VARCHAR(MAX) OUTPUT 
)
AS
BEGIN

	  ---Declaracion Variables Mensajes
      DECLARE @MetodoTemporal VARCHAR(MAX) = 'SP_UpdateMatrizAtribucion';
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

    -- Validar JSON de entrada
    IF @JSON_IN IS NULL OR @JSON_IN = '' OR ISJSON(@JSON_IN) <> 1
    BEGIN
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

        SET @JSON_OUT = (SELECT CAST((SELECT * FROM #Mensajes FOR JSON PATH, INCLUDE_NULL_VALUES) AS VARCHAR(MAX)));
        TRUNCATE TABLE #Mensajes;
        RETURN;
    END

    -- Procesar el JSON válido
    SET @JSON_IN = REPLACE(@JSON_IN, '\', '');

	  --DECLARACION DE VARIABLES PARA ACCEER A LAS PROPIEDADES Y VALORES QUE VIENEN DENTRO DEL JSON
	  DECLARE @p_Id_Update_Matriz_Atribucion INT ;
	  DECLARE @p_Id_Update_Divisa INT;

	  --SETEANDO LOS VALORES DEL JSON (TABLA HIJO DIVISA)
	  SELECT @p_Id_Update_Divisa = Id FROM OPENJSON( @JSON_IN) WITH (MatrizAtribucion NVARCHAR(MAX) AS JSON) CROSS APPLY OPENJSON (@JSON_IN, '$.Divisa') WITH ( Id INT );

	  --------------------------- DECLARACION DE TABLA PARA INSERTAR LOS REGISTROS DE MATRIZ ATRIBUCION (TABLA PADRE) ----------------------------------------
	  DECLARE @p_Tbl_Temp_Matriz_Atribucion_Update TABLE   
	  (  
		  ID INT IDENTITY(1,1)
		 ,IdMatriz             INT
		 ,Activo               BIT
		 ,Nombre               VARCHAR(MAX)
	  );  

		--INSERTA CADA UNO DE LOS ITEMS DE LAS MATRIZ ATRIBUCION
		INSERT INTO @p_Tbl_Temp_Matriz_Atribucion_Update	 
		SELECT 
		       Id
			  ,Activo
			  ,Nombre
		FROM OPENJSON (@JSON_IN)
		WITH 
		(
		  Id                   INT
         ,Activo               BIT
		 ,Nombre               VARCHAR(MAX)
		); 

	  --------------------------- DECLARACION DE TABLA PARA INSERTAR LOS REGISTROS DE FIRMAS (TABLA HIJO) ----------------------------------------
	  DECLARE @p_Tbl_Temp_Firmas_Update TABLE   
	  (  
		  ID INT IDENTITY(1,1)
		 ,IdFirma             INT
		 ,Firma VARCHAR(MAX)
		 ,MontoDesde DECIMAL(38,2)	
		 ,MontoHasta DECIMAL(38,2)	
	  );  

	  --INSERTA CADA UNO DE LOS ITEMS DE LAS FIRMAS
		INSERT INTO @p_Tbl_Temp_Firmas_Update	 
		SELECT 
		       Id
		      ,Firma
		      ,MontoDesde
		      ,MontoHasta
		FROM OPENJSON (@JSON_IN)
		WITH (MatrizAtribucion NVARCHAR(MAX) AS JSON)
		CROSS APPLY OPENJSON (@JSON_IN, '$.Firmas') 
		WITH 
		(
		   Id         INT
		  ,Firma      VARCHAR(MAX)
          ,MontoDesde DECIMAL(38,2)
		  ,MontoHasta DECIMAL(38,2)
		)

	  --------------------------- DECLARACION DE TABLA PARA INSERTAR LOS REGISTROS DE TRANSACCIONES (TABLA HIJO) ----------------------------------------
	  DECLARE @p_Tbl_Temp_Transacciones_Update TABLE   
	  (  
		  ID              INT IDENTITY(1,1)
		 ,IdTransacciones INT
		 ,Nombre          VARCHAR(MAX)
         ,Activo          BIT
	  );  

	  --INSERTA CADA UNO DE LOS ITEMS DE LAS TRANSACCIONES
		INSERT INTO @p_Tbl_Temp_Transacciones_Update	 
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
	  DECLARE @p_Id_Firma_Iterador INT;
	  DECLARE @p_Firma_Firma_Iterador VARCHAR(MAX);
	  DECLARE @p_MontoDesde_Firma_Iterador DECIMAL(38,2);
	  DECLARE @p_MontoHasta_Firma_Iterador DECIMAL(38,2);
	  --DECLARACION DE VARIABLES PARA RECORRER LA TABLA TEMPORAL TRANSACCIONES
	  DECLARE @p_Id_Transaccion_Iterador INT;
	  DECLARE @p_Nombre_Transaccion_Iterador VARCHAR(MAX);

	  --VARIABLES PARA DAR RESPUESTA
	  DECLARE @Id_Matriz_Por_Transaccion_Actualizada INT;
	  DECLARE @Id_Matriz_Por_Firma_Actualizada INT;

	  DECLARE @Resp_1 VARCHAR(MAX);
	  DECLARE @Resp_2 VARCHAR(MAX);
	  DECLARE @ROW VARCHAR(MAX);

	  BEGIN TRY	


		 ---------------------------------------------------------------------------------------
	 
		 BEGIN TRANSACTION INSERTAR
								   
					--ACTUALIZA EN LA TABLA MATRIZ ATRIBUCION

					UPDATE tblMatrizAtribucion 
                    SET Nombre = Tbl_Temp.Nombre, Fk_Id_Divisa = @p_Id_Update_Divisa, Activo = Tbl_Temp.Activo,
					FechaModificacion = CURRENT_TIMESTAMP 
                    FROM (
							SELECT IdMatriz, Nombre, Activo from @p_Tbl_Temp_Matriz_Atribucion_Update) AS Tbl_Temp
					WHERE 
						Tbl_Temp.IdMatriz = tblMatrizAtribucion.Id


					SELECT @p_Id_Update_Matriz_Atribucion = IdMatriz from @p_Tbl_Temp_Matriz_Atribucion_Update
 
				   		
						------------------------------ INICIO DEL RECORRIDO Y SETEO DE DATA DE LA TABLA TEMPORAL TRANSACCIONES  ------------------------------------
						--DESACTIVA LOS QUE YA ESTABAN 
						UPDATE tblMatrizAtribucion_Transaccion SET Activo = 0 WHERE Fk_Id_MatrizAtribucion = @p_Id_Update_Matriz_Atribucion		

						DECLARE @i INT = 1;
						DECLARE @Existe INT = 0;
						DECLARE @Contador INT = (SELECT COUNT(1) FROM  @p_Tbl_Temp_Transacciones_Update)

						IF @Contador > 0 BEGIN WHILE (@i <= (SELECT MAX(ID) FROM @p_Tbl_Temp_Transacciones_Update))
						BEGIN

							--OBTIENE UN ITEM
							SELECT 								
							 @p_Id_Transaccion_Iterador = IdTransacciones
							,@p_Nombre_Transaccion_Iterador = Nombre									
							FROM @p_Tbl_Temp_Transacciones_Update 
							WHERE ID = @i

							SELECT @Existe = COUNT(*) FROM tblMatrizAtribucion_Transaccion 
							WHERE Fk_Id_Transaccion = @p_Id_Transaccion_Iterador AND Fk_Id_MatrizAtribucion = @p_Id_Update_Matriz_Atribucion;

							   IF @Existe > 0
							   BEGIN

								--ACTUALIZA EN LA TABLA tblMatrizAtribucion_Transaccion
								UPDATE tblMatrizAtribucion_Transaccion SET Fk_Id_MatrizAtribucion = @p_Id_Update_Matriz_Atribucion, Fk_Id_Transaccion = @p_Id_Transaccion_Iterador,
								Activo = 1, FechaModificacion = CURRENT_TIMESTAMP WHERE Fk_Id_Transaccion = @p_Id_Transaccion_Iterador AND Fk_Id_MatrizAtribucion = @p_Id_Update_Matriz_Atribucion

							   END
							  ELSE
							  BEGIN
								--INSERTA EN LA TABLA tblMatrizAtribucion_Transaccion
								INSERT INTO tblMatrizAtribucion_Transaccion ( [Fk_Id_MatrizAtribucion], [Fk_Id_Transaccion], [Activo], [FechaCreacion] )
																     VALUES ( @p_Id_Update_Matriz_Atribucion, @p_Id_Transaccion_Iterador, 1, CURRENT_TIMESTAMP )							    
			    			  END	

							SELECT @Id_Matriz_Por_Transaccion_Actualizada = CONVERT(INT, ISNULL(SCOPE_IDENTITY(), -1)) 
							
							SET @i = @i + 1

						END --FIN DEL CICLO		
						END
					------------------------------ FIN DEL RECORRIDO Y SETEO DE DATA DE LA TABLA TEMPORAL TRANSACCIONES  ------------------------------------

						------------------------------ INICIO DEL RECORRIDO Y SETEO DE DATA DE LA TABLA TEMPORAL FIRMAS  ------------------------------------
						--DESACTIVA LOS QUE YA ESTABAN 
						UPDATE tblMatrizAtribucion_Firmas SET Activo = 0 WHERE Fk_Id_MatrizAtribucion = @p_Id_Update_Matriz_Atribucion

						DECLARE @iter INT = 1;
						DECLARE @ExisteUnion INT = 0;
						DECLARE @ExisteFirma INT = 0;
						DECLARE @Conta INT = (SELECT COUNT(1) FROM  @p_Tbl_Temp_Firmas_Update	 )

						IF @Conta > 0 BEGIN WHILE (@iter <= (SELECT MAX(ID) FROM @p_Tbl_Temp_Firmas_Update	 ))
							BEGIN

								--OBTIENE UN ITEM
								SELECT 		
								 @p_Id_Firma_Iterador    = IdFirma
								,@p_Firma_Firma_Iterador = Firma
								,@p_MontoDesde_Firma_Iterador = MontoDesde
								,@p_MontoHasta_Firma_Iterador = MontoHasta
								FROM @p_Tbl_Temp_Firmas_Update 
								WHERE ID = @iter

								--VALIDA SI EXISTE LA DATA EN tblMatrizAtribucion_Firmas
								SELECT @ExisteUnion = COUNT(*) FROM tblMatrizAtribucion_Firmas MF
								WHERE MF.Fk_Id_Firmas = @p_Id_Firma_Iterador ;

								--VALIDA SI EXISTE LA DATA EN tblFirmas
								SELECT @ExisteFirma = COUNT(*) FROM tblFirmas F
								WHERE F.Id = @p_Id_Firma_Iterador;

								   IF @ExisteUnion > 0 AND @ExisteFirma > 0
								   BEGIN

									 --ACTUALIZA EN LA TABLA tblMatrizAtribucion_Transaccion
									 UPDATE tblMatrizAtribucion_Firmas SET Fk_Id_MatrizAtribucion = @p_Id_Update_Matriz_Atribucion, Fk_Id_Firmas = @p_Id_Firma_Iterador,
									 Activo = 1, FechaModificacion = CURRENT_TIMESTAMP WHERE Fk_Id_Firmas = @p_Id_Firma_Iterador AND Fk_Id_MatrizAtribucion = @p_Id_Update_Matriz_Atribucion;

								   END
								   ELSE IF @ExisteUnion < 0 AND @ExisteFirma > 0
								   BEGIN

									 --INSERTA EN LA TABLA tblMatrizAtribucion_Firmas
									 INSERT INTO tblMatrizAtribucion_Firmas ( [Fk_Id_MatrizAtribucion], [Fk_Id_Firmas], [Activo], [FechaCreacion] )
													VALUES ( @p_Id_Update_Matriz_Atribucion, @p_Id_Firma_Iterador, 1, CURRENT_TIMESTAMP );

								   END
								  ELSE
								  BEGIN

									 --INSERTA EN LA TABLA tblFirmas
									 INSERT INTO tblFirmas ( [Firma], [MontoDesde], [MontoHasta], [Activo], [FechaCreacion] )
													VALUES ( @p_Firma_Firma_Iterador, @p_MontoDesde_Firma_Iterador, @p_MontoHasta_Firma_Iterador, 1, CURRENT_TIMESTAMP );

									 SELECT @Id_Matriz_Por_Firma_Actualizada = CONVERT(INT, ISNULL(SCOPE_IDENTITY(), -1));

									 --INSERTA EN LA TABLA tblMatrizAtribucion_Firmas
									 INSERT INTO tblMatrizAtribucion_Firmas ( [Fk_Id_MatrizAtribucion], [Fk_Id_Firmas], [Activo], [FechaCreacion] )
																	  VALUES ( @p_Id_Update_Matriz_Atribucion, @Id_Matriz_Por_Firma_Actualizada, 1, CURRENT_TIMESTAMP );
												
			    				  END	
							  
								SET @iter = @iter + 1
							END --FIN DEL CICLO
						END

											
					SELECT @ROW = (SELECT * FROM tblMatrizAtribucion WHERE Id = @p_Id_Update_Matriz_Atribucion FOR JSON PATH, INCLUDE_NULL_VALUES)
					
					------------------------------ RESPUESTA A LA APP  ------------------------------------
						INSERT INTO #Mensajes 
						EXEC SP_Select_Mensajes_Emergentes_Para_SP 
						@ROWS_AFFECTED = @@ROWCOUNT,
						@SUCCESS = 1,
						@ERROR_NUMBER_SP = NULL,
						@CONSTRAINT_TRIGGER_NAME = NULL,
						@ID = @p_Id_Update_Matriz_Atribucion,
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
						EXEC SP_Select_Mensajes_Emergentes_Para_SP 
						@ROWS_AFFECTED = 0,
						@SUCCESS = 0,
						@ERROR_NUMBER_SP = @ERROR_NUMBER,
						@CONSTRAINT_TRIGGER_NAME = @ERROR,
						@ID = @p_Id_Update_Matriz_Atribucion,
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
	   
	---
END