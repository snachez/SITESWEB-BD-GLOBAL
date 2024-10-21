﻿
CREATE PROCEDURE [dbo].[usp_InsertCedis](
	@JSON_IN VARCHAR(MAX) = NULL,
	@JSON_OUT  VARCHAR(MAX) OUTPUT 
)
AS
BEGIN

	  ---Declaracion Variables Mensajes
      DECLARE @MetodoTemporal VARCHAR(MAX) = 'usp_InsertCedis';
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


	--DECLARACION DE TABLA PARA INSERTAR LOS REGISTROS
	DECLARE @p_Tbl_Temp_Cedis TABLE   
     (  
	  ID INT IDENTITY(1,1)
	 ,Nombre VARCHAR(50)	 
	 ,Fk_Id_Pais INT
	 ,Activo BIT
    )  

	--INSERTA CADA UNO DE LOS ITEMS EN LA TABLA (SETEANDO LOS VALORES DEL JSON)
	INSERT INTO @p_Tbl_Temp_Cedis 
	SELECT 
		  Nombre
		 ,Fk_Id_Pais
		 ,Activo
	FROM OPENJSON (@JSON_IN)
	WITH (cedis_DTO NVARCHAR(MAX) AS JSON)
	CROSS APPLY OPENJSON (cedis_DTO) 
	WITH 
	(
	  Nombre VARCHAR(50)
	  ,Fk_Id_Pais INT
	 ,Activo BIT
	) 

  --DECLARACION DE VARIABLES PARA RECORRER LA TABLA
  DECLARE @p_Nombre_Cedis_Cursor VARCHAR(50)
  DECLARE @p_Fk_Id_Pais_Cursor INT
  DECLARE @p_Activo_Cursor BIT 
  DECLARE @p_Aux_Activo BIT	

 
  DECLARE @Resp_1 VARCHAR(MAX)
  DECLARE @Resp_2 VARCHAR(MAX)
  DECLARE @ROW VARCHAR(MAX)

  DECLARE @NewCedisCodigo_Cedis VARCHAR(25);
  DECLARE @PreFix VARCHAR(10) = 'CEDI-';
  DECLARE @Id INT;

	 BEGIN TRY		
		 BEGIN TRANSACTION ACTUALIZAR
				
				------------------------------ RECORRIDO Y SETEO DE DATA DE LA TABLA  ------------------------------------
				
					DECLARE @i INT = 1
					DECLARE @Contador INT = (SELECT COUNT(1) FROM @p_Tbl_Temp_Cedis)

					IF @Contador > 0 WHILE (@i <= (SELECT MAX(ID) FROM @p_Tbl_Temp_Cedis))
					BEGIN			
 
					 SELECT @Id = ISNULL(MAX(Id_Cedis),0) + 1 FROM tblCedis
					 --SELECT @NewCedisCodigo_Cedis = @PreFix + RIGHT('0000' + CAST(@Id AS VARCHAR(4)), 4)
					 	 SELECT @NewCedisCodigo_Cedis = RIGHT('0000' + CAST(@Id AS VARCHAR(4)), 4)

						--OBTIENE UN ITEM
						SELECT 								
						 @p_Nombre_Cedis_Cursor = Nombre 	
						,@p_Fk_Id_Pais_Cursor = Fk_Id_Pais
						,@p_Activo_Cursor = Activo								
						FROM @p_Tbl_Temp_Cedis
						WHERE ID = @i
								
								INSERT INTO tblCedis(Nombre, Fk_Id_Pais, Activo, Codigo_Cedis) VALUES(RTRIM(@p_Nombre_Cedis_Cursor),@p_Fk_Id_Pais_Cursor, @p_Activo_Cursor, @NewCedisCodigo_Cedis)
								SET @ROW = (SELECT * FROM tblCedis WHERE Nombre = @p_Nombre_Cedis_Cursor FOR JSON PATH)												  
						
							DECLARE @FKIDCEDIS INT = CONVERT(INT, ISNULL(SCOPE_IDENTITY(), -1))
							INSERT INTO tblDiasHabilesEntregaPedidosInternos(FkIdCedis, Dia, NombreDia, HoraDesde, HoraCorteDia, HoraLimiteAprobacion)
							VALUES(	@FKIDCEDIS, '1', 'Lunes','00:00', '23:59', '23:59'),
							(@FKIDCEDIS, '2', 'Martes', '00:00', '23:59', '23:59'),
							(@FKIDCEDIS, '3', 'Miercoles', '00:00', '23:59', '23:59'),
							(@FKIDCEDIS, '4', 'Jueves', '00:00', '23:59', '23:59'),
							(@FKIDCEDIS, '5', 'Viernes', '00:00', '23:59', '23:59'),
							(@FKIDCEDIS, '6', 'Sábado', '00:00', '23:59', '23:59'),
							(@FKIDCEDIS, '7', 'Domingo', '00:00', '23:59', '23:59')
						 SET @i = @i + 1
					END --FIN DEL CICLO

					------------------------------ RESPUESTA A LA APP  ------------------------------------
						INSERT INTO #Mensajes 
						EXEC usp_Select_Mensajes_Emergentes_Para_SP 
						@ROWS_AFFECTED = @@ROWCOUNT,
						@SUCCESS = 1,
						@ERROR_NUMBER_SP = NULL,
						@CONSTRAINT_TRIGGER_NAME = NULL,
						@ID = @Id,
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
				   COMMIT TRANSACTION ACTUALIZAR
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
						@ID = @Id,
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
				  ROLLBACK TRANSACTION ACTUALIZAR								
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