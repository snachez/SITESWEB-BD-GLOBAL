CREATE     PROCEDURE [dbo].[SP_UpdateDivisa](
	@JSON_IN VARCHAR(MAX),
	@JSON_OUT  VARCHAR(MAX) OUTPUT 
)
AS
BEGIN

  IF(@JSON_IN IS NOT NULL AND @JSON_IN <> '' AND ISJSON(@JSON_IN) = 1)
  BEGIN

	  SET @JSON_IN = REPLACE( @JSON_IN,'\','')

	  ---Declaracion Variables Mensajes
      DECLARE @MetodoTemporal VARCHAR(MAX) = 'SP_UpdateDivisa';
	  DECLARE @ErrorMensaje VARCHAR(MAX);
	  DECLARE @ERROR_NUMBER VARCHAR(MAX);
	
	  --DECLARACION DE VARIABLES PARA ACCEER A LAS PROPIEDADES Y VALORES QUE VIENEN DENTRO DEL JSON
	  DECLARE @p_Id_Divisa INT
	  DECLARE @p_Nombre_Divisa VARCHAR(MAX) 
	  DECLARE @p_Nomenclatura_Divisa VARCHAR(MAX)
	  DECLARE @p_Descripcion_Divisa VARCHAR(MAX)
	  DECLARE @p_Activo_Divisa BIT

	  --AUN NO ESTAN EN USO
	   
	  

	  --SETEANDO LOS VALORES DEL JSON (TABLA PADRE DIVISA)
	  SELECT @p_Id_Divisa = Id FROM OPENJSON( @JSON_IN) WITH ( Id INT )
	  SELECT @p_Nombre_Divisa = Nombre FROM OPENJSON( @JSON_IN) WITH ( Nombre VARCHAR(MAX) )
	  SELECT @p_Nomenclatura_Divisa = Nomenclatura FROM OPENJSON( @JSON_IN) WITH ( Nomenclatura VARCHAR(MAX) )
	  SELECT @p_Descripcion_Divisa = Descripcion FROM OPENJSON( @JSON_IN) WITH ( Descripcion VARCHAR(MAX) )
	  SELECT @p_Activo_Divisa = Activo FROM OPENJSON( @JSON_IN) WITH ( Activo BIT )

	  --------------------------- DECLARACION DE TABLA PARA EDITAR LOS REGISTROS DE PRESENTACIONES HABILITADAS (TABLA HIJO) ----------------------------------------
	  DECLARE @p_Tbl_Temp_Presentaciones_Habilitadas_Nuevas TABLE   
	  (  
		  ID INT IDENTITY(1,1)
		 ,Id_Efectivo INT
		 ,Nombre VARCHAR(MAX) NULL
	  )  

	  --INSERTA CADA UNO DE LOS ITEMS DEL TIPO EFECTIVO
		INSERT INTO @p_Tbl_Temp_Presentaciones_Habilitadas_Nuevas	 
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

	  --DECLARACION DE VARIABLES PARA RECORRER LA TABLA TEMPORAL PRESENTACIONES HABILITADAS
	  DECLARE @p_Id_Efectivo_Iterador INT
	  DECLARE @p_Nombre_Efectivo_Iterador VARCHAR(MAX)

	  DECLARE @Resp_1 VARCHAR(MAX)
	  DECLARE @Resp_2 VARCHAR(MAX)
	  DECLARE @ROW VARCHAR(MAX)

	   --PARA VALIDACIONES UNIDADES DE MEDIDAS
	  CREATE TABLE #Tbl_Temp_Presentaciones_Habilitadas_Viejas_Unidad_Medida (
	  	 ID INT IDENTITY(1,1)
	  	,Id_Efectivo INT	
	  )
	 
	  CREATE TABLE #Tbl_Temp_Resp_Hay_Items_Diferentes_Unidad_Medida (
	  	 ID INT IDENTITY(1,1)
	  	,Id_Efectivo INT	
	  )
	 
	  CREATE TABLE #Tbl_Temp_Resp_Hay_Items_Iguales_Unidad_Medida (
	  	 ID INT IDENTITY(1,1)
	  	,Id_Efectivo INT	
	  )

	 --PARA VALIDACIONES DENOMINACIONES
	  CREATE TABLE #Tbl_Temp_Presentaciones_Habilitadas_Viejas_Denominacion (
	  	 ID INT IDENTITY(1,1)
	  	,Id_Efectivo INT	
	  )
	 
	  CREATE TABLE #Tbl_Temp_Resp_Hay_Items_Diferentes_Denominacion (
	  	 ID INT IDENTITY(1,1)
	  	,Id_Efectivo INT	
	  )
	 
	  CREATE TABLE #Tbl_Temp_Resp_Hay_Items_Iguales_Denominacion (
	  	 ID INT IDENTITY(1,1)
	  	,Id_Efectivo INT	
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

	  DECLARE @Validar_Estado_Unidad_Medida_Este_Activa VARCHAR(MAX)		
	  DECLARE @Canti_Items_Nuevos INT
	  DECLARE @Canti_Items_Viejos INT
	  DECLARE @Canti_Items_Diferentes INT
	  DECLARE @Canti_Items_Iguales INT
	  DECLARE @Validar_Estado_Denominacion_Este_Activa VARCHAR(MAX)		

	  DECLARE @CONTINUAR_TRANSACCION INT
	 
	  BEGIN TRY	
	  

	    --- ACA SE PONEN LAS VALIDACIONES ANTES DE ITERAR ( UTLIZAR LAS VARIABLE @CONTINUAR_TRANSACCION PARA ELLO ) ----- 

		---------------------------------- INICIO VALIDACION 1 CONTRA UNIDADES DE MEDIDAS --------------------------------------- 

			-- Verifica si una unidad de medida tiene relacion con la divisa	
			SELECT @Validar_Estado_Unidad_Medida_Este_Activa = tbl_UM.Activo  --priorizar tabla  tblUnidadMedida_x_Divisa
			FROM tblUnidadMedida tbl_UM 
			INNER JOIN tblUnidadMedida_x_Divisa Tbl_UM_X_Tbl_Div  
			ON Tbl_UM_X_Tbl_Div.Fk_Id_Unidad_Medida = tbl_UM.Id 
			AND Tbl_UM_X_Tbl_Div.Fk_Id_Divisa = @p_Id_Divisa								
			
			--ITEMS VIEJOS
			INSERT INTO #Tbl_Temp_Presentaciones_Habilitadas_Viejas_Unidad_Medida (Id_Efectivo)
			SELECT DISTINCT Tbl_UM_X_Tbl_TEfec.Fk_Id_Tipo_Efectivo AS Id_Efectivo				
			FROM tblUnidadMedida_x_TipoEfectivo Tbl_UM_X_Tbl_TEfec 
			INNER JOIN tblUnidadMedida tbl_UM
			ON tbl_UM.Id = Tbl_UM_X_Tbl_TEfec.Fk_Id_Unidad_Medida
			AND Tbl_UM_X_Tbl_TEfec.Fk_Id_Divisa = @p_Id_Divisa	
		
			-- Obtiene la cantidad de ítems nuevos, viejos

			SET @Canti_Items_Nuevos = (SELECT COUNT(*) FROM @p_Tbl_Temp_Presentaciones_Habilitadas_Nuevas)
            SET @Canti_Items_Viejos = (SELECT COUNT(*) FROM #Tbl_Temp_Presentaciones_Habilitadas_Viejas_Unidad_Medida)


			-- Obtiene la cantidad de ítems diferentes
			INSERT INTO #Tbl_Temp_Resp_Hay_Items_Diferentes_Unidad_Medida (Id_Efectivo)
			SELECT t.Id_Efectivo
			FROM @p_Tbl_Temp_Presentaciones_Habilitadas_Nuevas t
			WHERE NOT EXISTS (
				SELECT 1
				FROM #Tbl_Temp_Presentaciones_Habilitadas_Viejas_Unidad_Medida v
				WHERE v.Id_Efectivo = t.Id_Efectivo
			);
					  
			SET @Canti_Items_Diferentes = (SELECT COUNT(*) FROM #Tbl_Temp_Resp_Hay_Items_Diferentes_Unidad_Medida)


			-- Obtiene la cantidad de ítems iguales
			INSERT INTO #Tbl_Temp_Resp_Hay_Items_Iguales_Unidad_Medida (Id_Efectivo)
			SELECT Id_Efectivo				 
			FROM @p_Tbl_Temp_Presentaciones_Habilitadas_Nuevas
			WHERE Id_Efectivo IN (					
				SELECT Id_Efectivo FROM #Tbl_Temp_Presentaciones_Habilitadas_Viejas_Unidad_Medida					
			)							

			SET @Canti_Items_Iguales = (SELECT COUNT(*) FROM #Tbl_Temp_Resp_Hay_Items_Iguales_Unidad_Medida) 
			
			DROP TABLE #Tbl_Temp_Presentaciones_Habilitadas_Viejas_Unidad_Medida 
			DROP TABLE #Tbl_Temp_Resp_Hay_Items_Diferentes_Unidad_Medida
			DROP TABLE #Tbl_Temp_Resp_Hay_Items_Iguales_Unidad_Medida

	        ------------------------------ RESPUESTA A LA APP  ------------------------------------
			
			SET @ErrorMensaje = 'Instrucción UPDATE en conflicto con la restricción ''Validar_Relaciones_Tipo_Efectivo_Unidades_Medida''. El conflicto ha aparecido en la base de datos ''Sites.Global'', tabla ''tblDivisa''.'; 
			SET @ERROR_NUMBER = ERROR_NUMBER();

			INSERT INTO #Mensajes 
			EXEC SP_Select_Mensajes_Emergentes_Para_SP 
			@ROWS_AFFECTED = 0,
			@SUCCESS = 0,
			@ERROR_NUMBER_SP = @ERROR_NUMBER,
			@CONSTRAINT_TRIGGER_NAME = @ErrorMensaje,
			@ID = @p_Id_Divisa,
			@ROW = NULL,
			@Metodo = @MetodoTemporal, 
			@TipoMensaje = 'Error', 
			@ErrorMensaje = @ErrorMensaje,
			@ModeJson = 0;						

			SELECT @Resp_1 = 
				(
				  SELECT * FROM #Mensajes FOR JSON PATH, INCLUDE_NULL_VALUES
				)

			SELECT @Resp_2 = 
				( 
					SELECT CAST(@Resp_1 AS VARCHAR(MAX)) 
				)
            
			TRUNCATE TABLE #Mensajes;
			------------------------------ FIN RESPUESTA A LA APP  ------------------------------------
						
			-- Continuar la transacción según las condiciones
			BEGIN
				IF (@Validar_Estado_Unidad_Medida_Este_Activa IS NOT NULL AND @Validar_Estado_Unidad_Medida_Este_Activa <> '')
				BEGIN
					-- Si la cantidad de ítems viejos es igual a la cantidad de ítems iguales, continuar
					IF (@Canti_Items_Viejos = @Canti_Items_Iguales)
					BEGIN
						SET @CONTINUAR_TRANSACCION = 1;
					END
					ELSE
					BEGIN
					    SET @JSON_OUT = ( SELECT @Resp_2  );
						GOTO FINALIZAR;
					END
				END
				ELSE
				BEGIN
					-- Si la cantidad de ítems nuevos es mayor a 0, continuar
					IF (@Canti_Items_Nuevos > 0)
					BEGIN
						SET @CONTINUAR_TRANSACCION = 1;
					END
					ELSE
					BEGIN
					    SET @JSON_OUT = ( SELECT @Resp_2  );
						GOTO FINALIZAR;
					END
				END
			END			

	    --------------------------------- FIN DE LAS VALIDACION 1 CONTRA UNIDADES DE MEDIDAS ----------------------------------

		------------------------------------- INICIO VALIDACION 2 CONTRA DENOMINACIONES --------------------------------------- 

			-- Verifica si una denominación tiene relacion con la divisa
			SELECT @Validar_Estado_Denominacion_Este_Activa = Denomi.Activo
			FROM tblDenominaciones Denomi 
			WHERE Denomi.IdDivisa = @p_Id_Divisa

			--ITEMS VIEJOS
			INSERT INTO #Tbl_Temp_Presentaciones_Habilitadas_Viejas_Denominacion (Id_Efectivo)				 
			SELECT DISTINCT BMO FROM tblDenominaciones tbl_Deno
			WHERE tbl_Deno.IdDivisa = @p_Id_Divisa;	

			-- Obtiene la cantidad de ítems nuevos
			SELECT @Canti_Items_Nuevos = COUNT(*) FROM @p_Tbl_Temp_Presentaciones_Habilitadas_Nuevas;
			SELECT @Canti_Items_Viejos = COUNT(*) FROM #Tbl_Temp_Presentaciones_Habilitadas_Viejas_Denominacion;

			-- Obtiene la cantidad de ítems diferentes
			INSERT INTO #Tbl_Temp_Resp_Hay_Items_Diferentes_Denominacion (Id_Efectivo)
			SELECT Id_Efectivo
			FROM @p_Tbl_Temp_Presentaciones_Habilitadas_Nuevas AS N
			WHERE NOT EXISTS (
				SELECT 1
				FROM #Tbl_Temp_Presentaciones_Habilitadas_Viejas_Denominacion AS V
				WHERE V.Id_Efectivo = N.Id_Efectivo
			);

			SET @Canti_Items_Diferentes = (SELECT COUNT(*) FROM #Tbl_Temp_Resp_Hay_Items_Diferentes_Denominacion);

			-- Obtiene la cantidad de ítems iguales
			INSERT INTO #Tbl_Temp_Resp_Hay_Items_Iguales_Denominacion (Id_Efectivo)
			SELECT Id_Efectivo
			FROM @p_Tbl_Temp_Presentaciones_Habilitadas_Nuevas
			WHERE Id_Efectivo IN (SELECT Id_Efectivo FROM #Tbl_Temp_Presentaciones_Habilitadas_Viejas_Denominacion);

			SET @Canti_Items_Iguales = (SELECT COUNT(*) FROM #Tbl_Temp_Resp_Hay_Items_Iguales_Denominacion);

			DROP TABLE #Tbl_Temp_Presentaciones_Habilitadas_Viejas_Denominacion 
			DROP TABLE #Tbl_Temp_Resp_Hay_Items_Diferentes_Denominacion
			DROP TABLE #Tbl_Temp_Resp_Hay_Items_Iguales_Denominacion

	        ------------------------------ RESPUESTA A LA APP  ------------------------------------

			SET @ErrorMensaje = 'Instrucción UPDATE en conflicto con la restricción ''Validar_Relaciones_Tipo_Efectivo_Denominaciones''. El conflicto ha aparecido en la base de datos ''Sites.Global'', tabla ''tblDivisa''.';
			SET @ERROR_NUMBER = ERROR_NUMBER();

			INSERT INTO #Mensajes 
			EXEC SP_Select_Mensajes_Emergentes_Para_SP 
			@ROWS_AFFECTED = 0,
			@SUCCESS = 0,
			@ERROR_NUMBER_SP = @ERROR_NUMBER,
			@CONSTRAINT_TRIGGER_NAME = @ErrorMensaje,
			@ID = @p_Id_Divisa,
			@ROW = NULL,
			@Metodo = @MetodoTemporal, 
			@TipoMensaje = 'Error', 
			@ErrorMensaje = @ErrorMensaje,
			@ModeJson = 0;						

			SELECT @Resp_1 = 
				(
				   SELECT * FROM #Mensajes FOR JSON PATH, INCLUDE_NULL_VALUES
				)

			SELECT @Resp_2 = 
				( 
					SELECT CAST(@Resp_1 AS VARCHAR(MAX)) 
				)

			TRUNCATE TABLE #Mensajes;	
			-- Continuar la transacción según las condiciones
			BEGIN
				IF (@Validar_Estado_Denominacion_Este_Activa IS NOT NULL AND @Validar_Estado_Denominacion_Este_Activa <> '')
				BEGIN
					-- Si la cantidad de ítems viejos es igual a la cantidad de ítems iguales, continuar
					IF (@Canti_Items_Viejos = @Canti_Items_Iguales)
					BEGIN
						SET @CONTINUAR_TRANSACCION = 1;
					END
					ELSE
					BEGIN
					    SET @JSON_OUT = ( SELECT @Resp_2  );
						GOTO FINALIZAR;
					END
				END
				ELSE
				BEGIN
					-- Si la cantidad de ítems nuevos es mayor a 0, continuar
					IF (@Canti_Items_Nuevos > 0)
					BEGIN
						SET @CONTINUAR_TRANSACCION = 1;
					END
					ELSE
					BEGIN
					    SET @JSON_OUT = ( SELECT @Resp_2  );
						GOTO FINALIZAR;
					END
				END
			END

	   --------------------------------------- FIN DE LAS VALIDACION 2 CONTRA DENOMINACIONES ----------------------------------


	  BEGIN TRANSACTION EDITAR
						
				IF(@CONTINUAR_TRANSACCION = 1)
				BEGIN 

					-----EDITA EN LA DIVISAS------
				
					UPDATE tblDivisa SET Nombre = @p_Nombre_Divisa, Nomenclatura = @p_Nomenclatura_Divisa, Descripcion = @p_Descripcion_Divisa, Activo = @p_Activo_Divisa, FechaModificacion = GETDATE()
					WHERE tblDivisa.Id = @p_Id_Divisa

					IF(@p_Id_Divisa IS NOT NULL)
					BEGIN   
				   	
						------------------------------ INICIO DEL RECORRIDO Y SETEO DE DATA DE LA TABLA TEMPORAL PRESENTACIONES DEL EFECTIVO  ------------------------------------
						--ELIMINE LOS QUE YA ESTABAN POR EL ID DE LA TABLA PAPA OSEA TABLA DIVISA

						DELETE FROM tblDivisa_x_TipoEfectivo WHERE FkIdDivisa = @p_Id_Divisa						

						DECLARE @iter INT = 1
						DECLARE @Conta INT = (SELECT COUNT(1) FROM  @p_Tbl_Temp_Presentaciones_Habilitadas_Nuevas	 )

						IF @Conta > 0 WHILE (@iter <= (SELECT MAX(ID) FROM @p_Tbl_Temp_Presentaciones_Habilitadas_Nuevas	 ))
						BEGIN

								--OBTIENE UN ITEM
								SELECT 								
								 @p_Id_Efectivo_Iterador = Id_Efectivo
								,@p_Nombre_Efectivo_Iterador = Nombre									
								FROM @p_Tbl_Temp_Presentaciones_Habilitadas_Nuevas 
								WHERE ID = @iter
													
								--INSERTA EN LA TABLA tblDivisa_x_TipoEfectivo
							    INSERT INTO dbo.[tblDivisa_x_TipoEfectivo] (    [FkIdTipoEfectivo],          [FkIdDivisa],     [FechaCreacion],  [Activo], [NombreTipoEfectivo],    [NombreDivisa]   )
															 VALUES (	 @p_Id_Efectivo_Iterador,				@p_Id_Divisa,    GETDATE(),         1,    @p_Nombre_Efectivo_Iterador,   @p_Nombre_Divisa    )			    												

								SET @iter = @iter + 1
							END --FIN DEL CICLO
										
					------------------------------ FIN DEL RECORRIDO Y SETEO DE DATA DE LA TABLA TEMPORAL PRESENTACIONES DEL EFECTIVO  ------------------------------------

					END

										
					SELECT @ROW = (SELECT * FROM tblDivisa WHERE Id = @p_Id_Divisa FOR JSON PATH, INCLUDE_NULL_VALUES)
				
					------------------------------ RESPUESTA A LA APP  ------------------------------------
						INSERT INTO #Mensajes 
						EXEC SP_Select_Mensajes_Emergentes_Para_SP 
						@ROWS_AFFECTED = @@ROWCOUNT,
						@SUCCESS = 1,
						@ERROR_NUMBER_SP = NULL,
						@CONSTRAINT_TRIGGER_NAME = NULL,
						@ID = @p_Id_Divisa,
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
					  COMMIT TRANSACTION EDITAR
					END		

				END					

	  END TRY    
	  BEGIN CATCH
					
				   ------------------------------ RESPUESTA A LA APP  ------------------------------------

					--
				    DECLARE @ERROR VARCHAR(MAX) = ERROR_MESSAGE();
			        SET @ERROR_NUMBER = ERROR_NUMBER();

					INSERT INTO #Mensajes 
					EXEC SP_Select_Mensajes_Emergentes_Para_SP 
					@ROWS_AFFECTED = 0,
					@SUCCESS = 0,
					@ERROR_NUMBER_SP = @ERROR_NUMBER,
					@CONSTRAINT_TRIGGER_NAME = @ERROR,
					@ID = @p_Id_Divisa,
					@ROW = NULL,
					@Metodo = @MetodoTemporal, 
					@TipoMensaje = 'Error', 
					@ErrorMensaje = @ERROR,
					@ModeJson = 0;		

					--

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
				  ROLLBACK TRANSACTION EDITAR								
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