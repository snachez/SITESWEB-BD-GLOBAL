
CREATE   PROCEDURE [dbo].[SP_Insert_Unidad_Medida](
	@JSON_IN VARCHAR(MAX) = NULL,
	@JSON_OUT  VARCHAR(MAX) OUTPUT 
)
AS
BEGIN

	  ---Declaracion Variables Mensajes
      DECLARE @MetodoTemporal VARCHAR(MAX) = 'SP_Insert_Unidad_Medida';
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
	  DECLARE @p_Nombre_Unidad_Medida VARCHAR(MAX) 
	  DECLARE @p_Simbolo_Unidad_Medida VARCHAR(MAX)
	  DECLARE @p_Cantidad_Unidades INT
	  DECLARE @p_Activo_Unidad_Medida BIT

	  --SETEANDO LOS VALORES DEL JSON (TABLA PADRE UNIDADES DE MEDIDAS)
	  SELECT @p_Nombre_Unidad_Medida = Nombre FROM OPENJSON( @JSON_IN) WITH ( Nombre VARCHAR(MAX) )
	  SELECT @p_Simbolo_Unidad_Medida = Simbolo FROM OPENJSON( @JSON_IN) WITH ( Simbolo VARCHAR(MAX) )
	  SELECT @p_Cantidad_Unidades = Cantidad_Unidades FROM OPENJSON( @JSON_IN) WITH ( Cantidad_Unidades INT )
	  SELECT @p_Activo_Unidad_Medida = Activo FROM OPENJSON( @JSON_IN) WITH ( Activo BIT )

	  --------------------------- DECLARACION DE TABLA PARA INSERTAR LOS REGISTROS DE DIVISAS (TABLA HIJO) ----------------------------------------
	  DECLARE @p_Tbl_Temp_Divisa TABLE   
	  (  
		  ID INT IDENTITY(1,1)
		 ,Id_Divisa INT
		 ,Nombre VARCHAR(MAX)	 
	  )  

		--INSERTA CADA UNO DE LOS ITEMS DE LA DIVISA
		INSERT INTO @p_Tbl_Temp_Divisa	 
		SELECT 
			   Id
			  ,Nombre		  
		FROM OPENJSON (@JSON_IN)
		WITH (Divisa NVARCHAR(MAX) AS JSON)
		CROSS APPLY OPENJSON (Divisa) 
		WITH 
		(
		   Id INT
		  ,Nombre VARCHAR(MAX)
		) 

	  --------------------------- DECLARACION DE TABLA PARA INSERTAR LOS REGISTROS DE PRESENTACIONES HABILITADAS (TABLA HIJO) ----------------------------------------
	  DECLARE @p_Tbl_Temp_Presentaciones_Habilitadas TABLE   
	  (  
		  ID INT IDENTITY(1,1)
		 ,Id_Efectivo INT
		 ,Nombre VARCHAR(MAX)	 
	  )  

	  --INSERTA CADA UNO DE LOS ITEMS DE LA DIVISA
		INSERT INTO @p_Tbl_Temp_Presentaciones_Habilitadas	 
		SELECT 
			   Id
			  ,Nombre		  
		FROM OPENJSON (@JSON_IN)
		WITH (Presentaciones_Habilitadas NVARCHAR(MAX) AS JSON)
		CROSS APPLY OPENJSON (Presentaciones_Habilitadas) 
		WITH 
		(
		   Id INT
		  ,Nombre VARCHAR(MAX)
		) 

	  --DECLARACION DE VARIABLES PARA RECORRER LA TABLA TEMPORAL DIVISAS
	  DECLARE @p_Id_Divisa_Iterador INT
	  DECLARE @p_Nombre_Divisa_Iterador VARCHAR(MAX)

	  --DECLARACION DE VARIABLES PARA RECORRER LA TABLA TEMPORAL PRESENTACIONES HABILITADAS
	  DECLARE @p_Id_Efectivo_Iterador INT
	  DECLARE @p_Nombre_Efectivo_Iterador VARCHAR(MAX)


	  --VARIABLES PARA DAR RESPUESTA
	  DECLARE @Id_Unidad_Medida_Insertada INT
	  DECLARE @Id_Unidad_Medida_Por_Divisa_Insertada INT
	  DECLARE @p_Id_Divisa_Insertada VARCHAR(MAX)

	  DECLARE @Resp_1 VARCHAR(MAX)
	  DECLARE @Resp_2 VARCHAR(MAX)
	  DECLARE @ROW VARCHAR(MAX)

	  BEGIN TRY	
	 
		 BEGIN TRANSACTION INSERTAR
								   
					--INSERTA EN LA TABLA UNIDADES DE MEDIDAS
					INSERT INTO dbo.[tblUnidadMedida] (			[Nombre],					[Simbolo],			[Cantidad_Unidades],			[Activo],				[Fecha_Creacion] )
											    VALUES(	@p_Nombre_Unidad_Medida,	@p_Simbolo_Unidad_Medida,	@p_Cantidad_Unidades,		@p_Activo_Unidad_Medida,		GETDATE()    )

					SELECT @Id_Unidad_Medida_Insertada = CONVERT(INT, ISNULL(SCOPE_IDENTITY(), -1))

					IF(@Id_Unidad_Medida_Insertada IS NOT NULL)
					BEGIN   
				   		
						------------------------------ INICIO DEL RECORRIDO Y SETEO DE DATA DE LA TABLA TEMPORAL DIVISA  ------------------------------------

						DECLARE @i INT = 1
						DECLARE @Contador INT = (SELECT COUNT(1) FROM  @p_Tbl_Temp_Divisa)

						IF @Contador > 0 BEGIN WHILE (@i <= (SELECT MAX(ID) FROM @p_Tbl_Temp_Divisa))
							BEGIN

								--OBTIENE UN ITEM
								SELECT 								
								 @p_Id_Divisa_Iterador = Id_Divisa
								,@p_Nombre_Divisa_Iterador = Nombre									
								FROM @p_Tbl_Temp_Divisa 
								WHERE ID = @i
								
								--INSERTA EN LA TABLA tblUnidadMedida_x_Divisa
								INSERT INTO dbo.[tblUnidadMedida_x_Divisa] (    [Fk_Id_Unidad_Medida],          [Fk_Id_Divisa],     [Activo],    [Fecha_Creacion]   )
																	VALUES (  @Id_Unidad_Medida_Insertada,    @p_Id_Divisa_Iterador,    1,          GETDATE()       )
			    			
								SELECT @Id_Unidad_Medida_Por_Divisa_Insertada = CONVERT(INT, ISNULL(SCOPE_IDENTITY(), -1)) 
								SELECT @p_Id_Divisa_Insertada = (SELECT Fk_Id_Divisa FROM tblUnidadMedida_x_Divisa WHERE Id = @Id_Unidad_Medida_Por_Divisa_Insertada)


								SET @i = @i + 1
							END --FIN DEL CICLO
						END								
					END

					------------------------------ FIN DEL RECORRIDO Y SETEO DE DATA DE LA TABLA TEMPORAL DIVISA  ------------------------------------

					IF(@Id_Unidad_Medida_Por_Divisa_Insertada IS NOT NULL)
					BEGIN   

						------------------------------ INICIO DEL RECORRIDO Y SETEO DE DATA DE LA TABLA TEMPORAL PRESENTACIONES DEL EFECTIVO  ------------------------------------

						DECLARE @iter INT = 1
						DECLARE @Conta INT = (SELECT COUNT(1) FROM  @p_Tbl_Temp_Presentaciones_Habilitadas	 )

						IF @Conta > 0 WHILE (@iter <= (SELECT MAX(ID) FROM @p_Tbl_Temp_Presentaciones_Habilitadas	 ))
						BEGIN

							--OBTIENE UN ITEM
							SELECT 								
							 @p_Id_Efectivo_Iterador = Id_Efectivo
							,@p_Nombre_Efectivo_Iterador = Nombre									
							FROM @p_Tbl_Temp_Presentaciones_Habilitadas 
							WHERE ID = @iter
						
							--INSERTA EN LA TABLA tblUnidadMedida_x_Divisa
							INSERT INTO dbo.[tblUnidadMedida_x_TipoEfectivo] (    [Fk_Id_Unidad_Medida],	[Fk_Id_Divisa]       , [Fk_Id_Tipo_Efectivo],     [Activo],    [Fecha_Creacion]   )
																      VALUES (  @Id_Unidad_Medida_Insertada,  @p_Id_Divisa_Insertada,    @p_Id_Efectivo_Iterador,       1,          GETDATE()       )
			    											
							SET @iter = @iter + 1
						END --FIN DEL CICLO

					END

											
					SELECT @ROW = (SELECT * FROM tblUnidadMedida WHERE Id = @Id_Unidad_Medida_Insertada FOR JSON PATH, INCLUDE_NULL_VALUES)
					
					------------------------------ RESPUESTA A LA APP  ------------------------------------
						INSERT INTO #Mensajes 
						EXEC SP_Select_Mensajes_Emergentes_Para_SP 
						@ROWS_AFFECTED = @@ROWCOUNT,
						@SUCCESS = 1,
						@ERROR_NUMBER_SP = NULL,
						@CONSTRAINT_TRIGGER_NAME = NULL,
						@ID = @Id_Unidad_Medida_Insertada,
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
						@ID = @Id_Unidad_Medida_Insertada,
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
---