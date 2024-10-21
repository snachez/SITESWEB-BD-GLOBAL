
CREATE   PROCEDURE [dbo].[SP_InsertGrupoAgencia](
	@JSON_IN VARCHAR(MAX) = NULL,
	@JSON_OUT  VARCHAR(MAX) OUTPUT 
)
AS
BEGIN

	  ---Declaracion Variables Mensajes
      DECLARE @MetodoTemporal VARCHAR(MAX) = 'SP_InsertGrupoAgencia';
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

	  SET @JSON_IN = REPLACE( @JSON_IN,'\','');

	  --DECLARACION DE VARIABLES PARA ACCEER A LAS PROPIEDADES Y VALORES QUE VIENEN DENTRO DEL JSON
	  DECLARE @p_Nombre_Grupo_Agencia VARCHAR(MAX) ;
	  DECLARE @p_ENVIAR_REMESAS_Grupo_Agencia BIT;
	  DECLARE @p_SOLICITAR_REMESAS_Grupo_Agencia BIT;
	  DECLARE @p_ACTIVO_Grupo_Agencia BIT;
	  DECLARE @p_Id_Cuenta INT;
	  DECLARE @p_Id_Insert_Cuenta INT;

	  --AUN NO ESTAN EN USO
	   
	  

	  --SETEANDO LOS VALORES DEL JSON (TABLA PADRE UNIDADES DE MEDIDAS)
	  SELECT @p_Nombre_Grupo_Agencia = NOMBRE FROM OPENJSON( @JSON_IN) WITH ( NOMBRE VARCHAR(MAX) )
	  SELECT @p_ENVIAR_REMESAS_Grupo_Agencia = ENVIAR_REMESAS FROM OPENJSON( @JSON_IN) WITH ( ENVIAR_REMESAS BIT )
	  SELECT @p_SOLICITAR_REMESAS_Grupo_Agencia = SOLICITAR_REMESAS FROM OPENJSON( @JSON_IN) WITH ( SOLICITAR_REMESAS BIT )
	  SELECT @p_ACTIVO_Grupo_Agencia = ACTIVO FROM OPENJSON( @JSON_IN) WITH ( ACTIVO BIT )

	  --------------------------- DECLARACION DE TABLA PARA INSERTAR LOS REGISTROS DE CUENTAS INTERNAS (TABLA HIJO) ----------------------------------------
	  DECLARE @p_Tbl_Temp_Cuentas_Internas_Insert TABLE   
	  (  
		  ID INT IDENTITY(1,1)
		 ,NumeroCuenta VARCHAR(MAX)
		 ,IdDivisa INT	 
	  );  

	  --INSERTA CADA UNO DE LOS ITEMS DE LAS CUENTAS INTERNAS
		INSERT INTO @p_Tbl_Temp_Cuentas_Internas_Insert	 
		SELECT 
			   NumeroCuenta
			  ,IdDivisa		  
		FROM OPENJSON (@JSON_IN)
		WITH (CuentaEdit NVARCHAR(MAX) AS JSON)
		CROSS APPLY OPENJSON (CuentaEdit) 
		WITH 
		(
		   NumeroCuenta VARCHAR(MAX)
          ,IdDivisa INT
		)

	  --DECLARACION DE VARIABLES PARA RECORRER LA TABLA TEMPORAL CUENTAS INTERNAS
	  DECLARE @p_Id_Divisa_Iterador INT
	  DECLARE @p_Numero_Cuenta_Iterador VARCHAR(MAX)
	  DECLARE @p_Id_Insert_Grupo_Agencia INT;

	  --VARIABLES PARA DAR RESPUESTA
	  DECLARE @Resp_1 VARCHAR(MAX)
	  DECLARE @Resp_2 VARCHAR(MAX)
	  DECLARE @ROW VARCHAR(MAX)

	  BEGIN TRY	
	 
		 BEGIN TRANSACTION INSERTAR
								   
					--INSERTA EN LA TABLA AGENCIAS BANCARIAS

					INSERT INTO tblGrupoAgencia( Nombre, EnviaRemesas, SolicitaRemesas, Activo)
					                     VALUES( @p_Nombre_Grupo_Agencia, @p_ENVIAR_REMESAS_Grupo_Agencia, @p_SOLICITAR_REMESAS_Grupo_Agencia, @p_ACTIVO_Grupo_Agencia);

					SELECT @p_Id_Insert_Grupo_Agencia = CONVERT(INT, ISNULL(SCOPE_IDENTITY(), -1))

					IF(@p_Id_Insert_Grupo_Agencia IS NOT NULL)
					BEGIN   
				   		
						------------------------------ INICIO DEL RECORRIDO Y SETEO DE DATA DE LA TABLA TEMPORAL CUENTAS INTERNAS  ------------------------------------

						DECLARE @i INT = 1
						DECLARE @Contador INT = (SELECT COUNT(1) FROM  @p_Tbl_Temp_Cuentas_Internas_Insert)

						IF @Contador > 0 BEGIN WHILE (@i <= (SELECT MAX(ID) FROM @p_Tbl_Temp_Cuentas_Internas_Insert))
						BEGIN

							--OBTIENE UN ITEM
							SELECT @p_Id_Divisa_Iterador = IdDivisa, @p_Numero_Cuenta_Iterador = NumeroCuenta FROM @p_Tbl_Temp_Cuentas_Internas_Insert WHERE ID = @i
							
							--OBTIENE LA CUENTA SI EXISTE Y SI EXISTE RELACION CON EL GRUPO
							SET @p_Id_Insert_Cuenta = (SELECT Id  FROM tblCuentaInterna WHERE NumeroCuenta = @p_Numero_Cuenta_Iterador);

							--VALIDACION 1(SI LA CUENTA EXISTE)
							--VALIDACION 2(SI LA CUENTA NO EXISTE)
							IF(@p_Id_Insert_Cuenta IS NOT NULL)
							BEGIN

							    --INSERTA EN LA TABLA tblCuentaInterna_x_Agencia
							      INSERT INTO dbo.[tblCuentaInterna_x_GrupoAgencias] ( FkIdCuentaInterna, FkIdGrupoAgencias )
																        VALUES ( @p_Id_Insert_Cuenta, @p_Id_Insert_Grupo_Agencia )
								
							END
							ELSE IF(@p_Id_Insert_Cuenta IS NULL AND @p_Numero_Cuenta_Iterador IS NOT NULL)
							BEGIN
							      
								  --INSERTA EN LA TABLA tblCuentaInterna
							      INSERT INTO dbo.[tblCuentaInterna] ( NumeroCuenta, FkIdDivisa )
														      VALUES ( @p_Numero_Cuenta_Iterador, @p_Id_Divisa_Iterador )

                                  SELECT @p_Id_Cuenta = CONVERT(INT, ISNULL(SCOPE_IDENTITY(), -1))

							      --INSERTA EN LA TABLA tblCuentaInterna_x_Agencia
							      INSERT INTO dbo.[tblCuentaInterna_x_GrupoAgencias] ( FkIdCuentaInterna, FkIdGrupoAgencias )
																        VALUES ( @p_Id_Cuenta, @p_Id_Insert_Grupo_Agencia )

								  
							END

							SET @i = @i + 1
						END --FIN DEL CICLO
						END								
					END
					
					SELECT @ROW = (SELECT * FROM tblGrupoAgencia WHERE Id = @p_Id_Insert_Grupo_Agencia FOR JSON PATH, INCLUDE_NULL_VALUES)
					
					------------------------------ RESPUESTA A LA APP  ------------------------------------
						INSERT INTO #Mensajes 
						EXEC SP_Select_Mensajes_Emergentes_Para_SP 
						@ROWS_AFFECTED = @@ROWCOUNT,
						@SUCCESS = 1,
						@ERROR_NUMBER_SP = NULL,
						@CONSTRAINT_TRIGGER_NAME = NULL,
						@ID = @p_Id_Insert_Grupo_Agencia,
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
						@ID = @p_Id_Insert_Grupo_Agencia,
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