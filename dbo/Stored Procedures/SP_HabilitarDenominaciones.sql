﻿


CREATE   PROCEDURE [dbo].[SP_HabilitarDenominaciones](
	@JSON_IN VARCHAR(MAX),
	@JSON_OUT  VARCHAR(MAX) OUTPUT 
)
AS
BEGIN

	  ---Declaracion Variables Mensajes
      DECLARE @MetodoTemporal VARCHAR(MAX) = 'SP_HabilitarDenominaciones';
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

	  --AUN NO ESTAN EN USO
	   
	  

	  --------------------------- DECLARACION DE TABLA PARA INSERTAR LOS REGISTROS DE HABILITAR DENOMINACIONES (TABLA PADRE) ----------------------------------------
	  DECLARE @p_Tbl_Temp_Habilitar_Denominaciones_Insert TABLE   
	  (  
		  IDTEMPORAL INT IDENTITY(1,1)
		 ,ID                   INT
		 ,ACTIVO               BIT
	  );  

		--INSERTA CADA UNO DE LOS ITEMS DE LAS DENOMINACIONES A HABILITAR O DESABILITAR
		INSERT INTO @p_Tbl_Temp_Habilitar_Denominaciones_Insert	 
		SELECT 
			   ID
			  ,ACTIVO
		FROM OPENJSON (@JSON_IN)
		WITH 
		(
		  ID                   INT
		 ,ACTIVO               BIT
		); 


	  --VARIABLES PARA DAR RESPUESTA
	  DECLARE @Id_Denominaciones_Habilitar INT
	  DECLARE @Activo_Denominaciones_Habilitar INT

	  DECLARE @Resp_1 VARCHAR(MAX)
	  DECLARE @Resp_2 VARCHAR(MAX)
	  DECLARE @ROW VARCHAR(MAX)

	  BEGIN TRY	
	 
		 BEGIN TRANSACTION INSERTAR
								   
						------------------------------ INICIO DEL RECORRIDO Y SETEO DE DATA DE LA TABLA TEMPORAL MODULO  ------------------------------------

						DECLARE @i INT = 1
						DECLARE @Contador INT = (SELECT COUNT(1) FROM  @p_Tbl_Temp_Habilitar_Denominaciones_Insert)

						IF @Contador > 0 BEGIN WHILE (@i <= (SELECT MAX(IDTEMPORAL) FROM @p_Tbl_Temp_Habilitar_Denominaciones_Insert))
							BEGIN

								--OBTIENE UN ITEM
								SELECT 								
								 @Id_Denominaciones_Habilitar = ID,
								 @Activo_Denominaciones_Habilitar = ACTIVO
								FROM @p_Tbl_Temp_Habilitar_Denominaciones_Insert 
								WHERE IDTEMPORAL = @i

								UPDATE dbo.[tblDenominaciones] SET Activo = IIF(@Activo_Denominaciones_Habilitar = 1, 0, 1) 
								WHERE Id = @Id_Denominaciones_Habilitar;

								SET @i = @i + 1
							END --FIN DEL CICLO
						END	

					SELECT @ROW = (SELECT * FROM tblDenominaciones WHERE Id = @Id_Denominaciones_Habilitar FOR JSON PATH, INCLUDE_NULL_VALUES)
					------------------------------ FIN DEL RECORRIDO Y SETEO DE DATA DE LA TABLA TEMPORAL MODULO  ------------------------------------
															
					------------------------------ RESPUESTA A LA APP  ------------------------------------
						INSERT INTO #Mensajes 
						EXEC SP_Select_Mensajes_Emergentes_Para_SP 
						@ROWS_AFFECTED = @@ROWCOUNT,
						@SUCCESS = 1,
						@ERROR_NUMBER_SP = NULL,
						@CONSTRAINT_TRIGGER_NAME = NULL,
						@ID = @Id_Denominaciones_Habilitar,
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
						EXEC SP_Select_Mensajes_Emergentes_Para_SP 
						@ROWS_AFFECTED = 0,
						@SUCCESS = 0,
						@ERROR_NUMBER_SP = @ERROR_NUMBER,
						@CONSTRAINT_TRIGGER_NAME = @ERROR,
						@ID = @Id_Denominaciones_Habilitar,
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
	  
	  GOTO FINALIZAR 	 				
  END

  FINALIZAR:RETURN
END
---