

CREATE PROCEDURE [dbo].[SP_InsertDivisa] (

	@JSON_IN VARCHAR(MAX) = NULL,
	@JSON_OUT  VARCHAR(MAX) OUTPUT 

)
AS
BEGIN
	
  IF(@JSON_IN IS NOT NULL AND @JSON_IN != '' AND ISJSON(@JSON_IN) = 1)
  BEGIN

	  SET @JSON_IN = REPLACE( @JSON_IN,'\','')

	  ---Declaracion Variables Mensajes
      DECLARE @MetodoTemporal VARCHAR(MAX) = 'SP_InsertDivisa';
	  DECLARE @ErrorMensaje VARCHAR(MAX);
	  DECLARE @ERROR_NUMBER VARCHAR(MAX);

	  --DECLARACION DE VARIABLES PARA ACCEER A LAS PROPIEDADES Y VALORES QUE VIENEN DENTRO DEL JSON
	  DECLARE @p_Nombre_Divisa VARCHAR(MAX) 
	  DECLARE @p_Nomenclatura_Divisa VARCHAR(MAX)
	  DECLARE @p_Descripcion_Divisa VARCHAR(MAX)
	  DECLARE @p_Activo_Divisa BIT

	  --AUN NO ESTAN EN USO
	  DECLARE @p_user_id INT 
	  DECLARE @Action VARCHAR(1)

	  --SETEANDO LOS VALORES DEL JSON (TABLA PADRE DIVISAS)
	  SELECT @p_Nombre_Divisa = Nombre FROM OPENJSON( @JSON_IN) WITH ( Nombre VARCHAR(MAX) )
	  SELECT @p_Nomenclatura_Divisa = Nomenclatura FROM OPENJSON( @JSON_IN) WITH ( Nomenclatura VARCHAR(MAX) )
	  SELECT @p_Descripcion_Divisa = Descripcion FROM OPENJSON( @JSON_IN) WITH ( Descripcion VARCHAR(MAX) )
	  SELECT @p_Activo_Divisa = Activo FROM OPENJSON( @JSON_IN) WITH ( Activo BIT )


	  --------------------------- DECLARACION DE TABLA PARA INSERTAR LOS REGISTROS DE PRESENTACIONES HABILITADAS (TABLA HIJO) ----------------------------------------
	  DECLARE @p_Tbl_Temp_Presentaciones_Habilitadas TABLE   
	  (  
		  ID INT IDENTITY(1,1)
		 ,Id_Efectivo INT
		 ,Nombre VARCHAR(MAX)	 
	  )  

	  --INSERTA CADA UNO DE LOS ITEMS DE LAS PRESENTACIONES DEL EFECTIVO
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

	  --DECLARACION DE VARIABLES PARA RECORRER LA TABLA TEMPORAL PRESENTACIONES HABILITADAS DE TIPO DE EFECTIVO
	  DECLARE @p_Id_Efectivo_Iterador INT
	  DECLARE @p_Nombre_Efectivo_Iterador VARCHAR(MAX)


	  --VARIABLES PARA DAR RESPUESTA
	  DECLARE @p_Id_Divisa_Insertada INT

	  DECLARE @Resp_1 VARCHAR(MAX)
	  DECLARE @Resp_2 VARCHAR(MAX)
	  DECLARE @ROW VARCHAR(MAX)

	  BEGIN TRY	
	 
		 BEGIN TRANSACTION INSERTAR
								   
					--INSERTA EN LA TABLA DIVISAS
					
					INSERT INTO tblDivisa(Nombre, Nomenclatura, Descripcion, Activo, FechaCreacion ) VALUES(@p_Nombre_Divisa, @p_Nomenclatura_Divisa, @p_Descripcion_Divisa, @p_Activo_Divisa, GETDATE())

					SELECT @p_Id_Divisa_Insertada = CONVERT(INT, ISNULL(SCOPE_IDENTITY(), -1))

					IF(@p_Id_Divisa_Insertada IS NOT NULL)
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
												
							--INSERTA EN LA TABLA tblDivisa_x_TipoEfectivo
							INSERT INTO dbo.[tblDivisa_x_TipoEfectivo] (    [FkIdTipoEfectivo],          [FkIdDivisa],     [FechaCreacion],  [Activo], [NombreTipoEfectivo],    [NombreDivisa]   )
															 VALUES (  @p_Id_Efectivo_Iterador, @p_Id_Divisa_Insertada,    GETDATE(),         1,    @p_Nombre_Efectivo_Iterador,   @p_Nombre_Divisa    )			    												

							SET @iter = @iter + 1
						END --FIN DEL CICLO
					
						------------------------------ FIN DEL RECORRIDO Y SETEO DE DATA DE LA TABLA TEMPORAL PRESENTACIONES DEL EFECTIVO  ------------------------------------
														
					END

													
					SELECT @ROW = (SELECT * FROM tblDivisa WHERE Id = @p_Id_Divisa_Insertada FOR JSON PATH, INCLUDE_NULL_VALUES)
					
					------------------------------ RESPUESTA A LA APP  ------------------------------------
						INSERT INTO #Mensajes 
						EXEC SP_Select_Mensajes_Emergentes_Para_SP 
						@ROWS_AFFECTED = @@ROWCOUNT,
						@SUCCESS = 1,
						@ERROR_NUMBER_SP = NULL,
						@CONSTRAINT_TRIGGER_NAME = NULL,
						@ID = @p_Id_Divisa_Insertada,
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
						@ID = @p_Id_Divisa_Insertada,
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

						SELECT @Resp_2 = 
						( 
							SELECT CAST(@Resp_1 AS VARCHAR(MAX)) 
						)
						
						SET @JSON_OUT = ( SELECT @Resp_2  )	
				----------------------------------------------------------------------------------------
	  
	  GOTO FINALIZAR 	 				
  END

  FINALIZAR:RETURN
END