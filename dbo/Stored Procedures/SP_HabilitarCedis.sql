
CREATE PROCEDURE [dbo].[SP_HabilitarCedis](@JSON_IN VARCHAR(MAX) = NULL,
	                                             @JSON_OUT  VARCHAR(MAX) OUTPUT )
AS
BEGIN

	  ---Declaracion Variables Mensajes
      DECLARE @MetodoTemporal VARCHAR(MAX) = 'SP_HabilitarCedis';
	  DECLARE @ErrorMensaje VARCHAR(MAX);
	  DECLARE @ERROR_NUMBER VARCHAR(MAX);

      -- Variables para iterar en las tablas temporales
	  DECLARE @Resp_1 VARCHAR(MAX); 
	  DECLARE @Resp_2 VARCHAR(MAX); 
	  DECLARE @ROW VARCHAR(MAX);

	  --DECLARACION DE VARIABLES PARA RECORRER LA TABLA
	  DECLARE @p_Id_Cedis_Cursor INT	
	  DECLARE @p_Activo_Cursor BIT 

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

	IF (@JSON_IN IS NULL OR @JSON_IN = '' OR ISJSON(@JSON_IN) = 0)
	BEGIN
		-- Error por JSON inválido
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

		SELECT @Resp_1 = (SELECT * FROM #Mensajes FOR JSON PATH, INCLUDE_NULL_VALUES);
		SELECT @Resp_2 = (SELECT CAST(@Resp_1 AS VARCHAR(MAX)));
		SET @JSON_OUT = (SELECT @Resp_2);
		TRUNCATE TABLE #Mensajes;

		RETURN;  -- Finaliza aquí si hay error en el JSON
	END;

	SET @JSON_IN = REPLACE( @JSON_IN,'\','')

	--DECLARACION DE TABLA PARA INSERTAR LOS REGISTROS
	DECLARE @p_Tbl_Temp_Cedis TABLE   
     (  
	  ID INT IDENTITY(1,1)
	 ,Id_Cedis INT
	 ,Activo BIT
    )  

	--INSERTA CADA UNO DE LOS ITEMS EN LA TABLA (SETEANDO LOS VALORES DEL JSON)
	INSERT INTO @p_Tbl_Temp_Cedis	 
	SELECT DISTINCT -- SE EMPLEA UN DISTINCT PARA EVITAR DUPLICADOS...
		  Id_Cedis	
		 ,Activo
	FROM OPENJSON (@JSON_IN)
	WITH (cedis_DTO NVARCHAR(MAX) AS JSON)
	CROSS APPLY OPENJSON (cedis_DTO) 
	WITH 
	(
	  Id_Cedis INT	 
	 ,Activo BIT
	) 
 
	 BEGIN TRY		
		 BEGIN TRANSACTION ACTUALIZAR
				
				------------------------------ RECORRIDO Y SETEO DE DATA DE LA TABLA  ------------------------------------
				
					DECLARE @i INT = 1
					DECLARE @Contador INT = (SELECT COUNT(1) FROM @p_Tbl_Temp_Cedis)

					IF @Contador > 0
					BEGIN
					WHILE (@i <= (SELECT MAX(ID) FROM @p_Tbl_Temp_Cedis))
					BEGIN

						--OBTIENE UN ITEM
						SELECT 								
						 @p_Id_Cedis_Cursor = Id_Cedis 
						,@p_Activo_Cursor = Activo								
						FROM @p_Tbl_Temp_Cedis 
						WHERE ID = @i
								
						UPDATE tblCedis SET Activo = IIF(@p_Activo_Cursor = 1, 0, 1), FechaModificacion = CURRENT_TIMESTAMP 
						WHERE Id_Cedis = @p_Id_Cedis_Cursor

						SET @ROW = (SELECT * FROM tblCedis WHERE Id_Cedis = @p_Id_Cedis_Cursor FOR JSON PATH);
								
			    															
						 SET @i = @i + 1

					END; --FIN DEL CICLO
					END;
					------------------------------ RESPUESTA A LA APP  ------------------------------------
						INSERT INTO #Mensajes 
						EXEC SP_Select_Mensajes_Emergentes_Para_SP 
						@ROWS_AFFECTED = @@ROWCOUNT,
						@SUCCESS = 1,
						@ERROR_NUMBER_SP = NULL,
						@CONSTRAINT_TRIGGER_NAME = NULL,
						@ID = @p_Id_Cedis_Cursor,
						@ROW = @ROW,
						@Metodo = @MetodoTemporal, 
						@TipoMensaje = 'Exitoso', 
						@ErrorMensaje = NULL,
						@ModeJson = 0;

					---------------------------------------------------------------------------------------

				  --FINAL
				 IF @@TRANCOUNT > 0
				 BEGIN
				   COMMIT TRANSACTION ACTUALIZAR
				 END		

	  END TRY    
	  BEGIN CATCH
					            -- Manejar errores
            IF @@TRANCOUNT > 0 BEGIN
                ROLLBACK TRANSACTION ACTUALIZAR;
			END
				   ------------------------------ RESPUESTA A LA APP  ------------------------------------
						
						DECLARE @ERROR VARCHAR(MAX) = ERROR_MESSAGE();
						SET @ERROR_NUMBER = ERROR_NUMBER();

						INSERT INTO #Mensajes 
						EXEC SP_Select_Mensajes_Emergentes_Para_SP 
						@ROWS_AFFECTED = 0,
						@SUCCESS = 0,
						@ERROR_NUMBER_SP = @ERROR_NUMBER,
						@CONSTRAINT_TRIGGER_NAME = @ERROR,
						@ID = @p_Id_Cedis_Cursor,
						@ROW = NULL,
						@Metodo = @MetodoTemporal, 
						@TipoMensaje = 'Error', 
						@ErrorMensaje = @ERROR,
						@ModeJson = 0;		

				   -----------------------------------------------------------------------------------------

	  END CATCH;

    -- Preparar respuesta JSON
    SELECT @Resp_1 = (SELECT * FROM #Mensajes FOR JSON PATH, INCLUDE_NULL_VALUES);
    SELECT @Resp_2 = (SELECT CAST(@Resp_1 AS VARCHAR(MAX)));
    SET @JSON_OUT = @Resp_2;

    -- Limpiar tabla temporal
    TRUNCATE TABLE #Mensajes;
    DROP TABLE #Mensajes;
	---
END