CREATE   PROCEDURE [dbo].[SP_UpdateAgenciaBancaria](
	@JSON_IN VARCHAR(MAX) = NULL,
	@JSON_OUT  VARCHAR(MAX) OUTPUT 
)
AS
BEGIN

	  ---Declaracion Variables Mensajes
      DECLARE @MetodoTemporal VARCHAR(MAX) = 'SP_UpdateAgenciaBancaria';
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
	  DECLARE @p_Id_Insert_Agencia_Bancaria INT ;
	  DECLARE @p_Id_Insert_Grupo_Agencia INT;
	  DECLARE @p_Activo_Insert_Cuentas_Agencia BIT;
	  DECLARE @p_Iterador_Insert_Grupo_Agencia INT;
	  DECLARE @p_UsaCuentasGrupo_Insert_Agencia_Bancaria BIT;
	  DECLARE @p_Id_Insert_Cuenta INT;
	  DECLARE @p_Id_Insert_CuentaxAgencia INT;
	  DECLARE @Id INT;
      DECLARE @Codigo_Agencia VARCHAR(25);

	  --------------------------- DECLARACION DE TABLA PARA INSERTAR LOS REGISTROS DE AGENCIAS BANCARIAS (TABLA PADRE) ----------------------------------------
	  DECLARE @p_Tbl_Temp_Agencia_Bancaria_Insert TABLE   
	  (  
		  ID INT IDENTITY(1,1)
		 ,IDAGENCIA            INT
		 ,NOMBRE               VARCHAR(MAX)
		 ,USA_CUENTAS_GRUPO    BIT
		 ,ENVIA_REMESAS        BIT
		 ,SOLICITA_REMESAS     BIT
		 ,CODIGO_BRANCH        VARCHAR(MAX)
		 ,CODIGO_PROVINCIA     INT
		 ,CODIGO_CANTON        INT
		 ,CODIGO_DISTRITO      INT
		 ,DIRECCION            VARCHAR(MAX)
		 ,ACTIVO               BIT
		 ,Codigo_Pais          INT
		 ,Codigo_CEDI          INT
		 ,Codigo_GrupoAgencias INT
		 ,Codigo_Transportadora_Envio     INT
		 ,Codigo_Transportadora_Solicitud INT
	  );  

		--INSERTA CADA UNO DE LOS ITEMS DE LAS AGENCIAS BANCARIAS
		INSERT INTO @p_Tbl_Temp_Agencia_Bancaria_Insert	 
		SELECT 
		       IDAGENCIA
			  ,NOMBRE
		      ,USA_CUENTAS_GRUPO
		      ,ENVIA_REMESAS
		      ,SOLICITA_REMESAS
		      ,CODIGO_BRANCH
		      ,CODIGO_PROVINCIA
			  ,CODIGO_CANTON
			  ,CODIGO_DISTRITO
			  ,DIRECCION
			  ,ACTIVO
			  ,Codigo_Pais
			  ,Codigo_CEDI
			  ,Codigo_GrupoAgencias
			  ,Codigo_Transportadora_Envio
			  ,Codigo_Transportadora_Solicitud
		FROM OPENJSON (@JSON_IN)
		WITH 
		(
		  IDAGENCIA            INT
		 ,NOMBRE               VARCHAR(MAX)
		 ,USA_CUENTAS_GRUPO    BIT
		 ,ENVIA_REMESAS        BIT
		 ,SOLICITA_REMESAS     BIT
		 ,CODIGO_BRANCH        VARCHAR(MAX)
		 ,CODIGO_PROVINCIA     INT
		 ,CODIGO_CANTON        INT
		 ,CODIGO_DISTRITO      INT
		 ,DIRECCION            VARCHAR(MAX)
		 ,ACTIVO               BIT
		 ,Codigo_Pais          INT
		 ,Codigo_CEDI          INT
		 ,Codigo_GrupoAgencias INT
		 ,Codigo_Transportadora_Envio     INT
		 ,Codigo_Transportadora_Solicitud INT
		); 

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
		WITH (Agencia NVARCHAR(MAX) AS JSON)
		CROSS APPLY OPENJSON (@JSON_IN, '$.Cuentas_Internas') 
		WITH 
		(
		   NumeroCuenta VARCHAR(MAX)
          ,IdDivisa INT
		)

	  --------------------------- DECLARACION DE TABLA PARA ELIMINAR LOS REGISTROS DE CUENTAS INTERNAS (TABLA HIJO) ----------------------------------------
	  DECLARE @p_Tbl_Temp_Cuentas_Internas_Eliminar_Insert TABLE   
	  (  
		  ID INT IDENTITY(1,1)
		 ,NumeroCuenta VARCHAR(MAX)
		 ,IdDivisa INT	 
	  );  

	  --INSERTA CADA UNO DE LOS ITEMS DE LAS CUENTAS INTERNAS
		INSERT INTO @p_Tbl_Temp_Cuentas_Internas_Eliminar_Insert	 
		SELECT 
			   NumeroCuenta
			  ,IdDivisa		  
		FROM OPENJSON (@JSON_IN)
		WITH (Agencia NVARCHAR(MAX) AS JSON)
		CROSS APPLY OPENJSON (@JSON_IN, '$.EliminarCuenta') 
		WITH 
		(
		   NumeroCuenta VARCHAR(MAX)
          ,IdDivisa INT
		)

	  --DECLARACION DE VARIABLES PARA RECORRER LA TABLA TEMPORAL CUENTAS INTERNAS
	  DECLARE @p_Id_Divisa_Iterador INT
	  DECLARE @p_Numero_Cuenta_Iterador VARCHAR(MAX)

	  --VARIABLES PARA DAR RESPUESTA
	  DECLARE @Resp_1 VARCHAR(MAX)
	  DECLARE @Resp_2 VARCHAR(MAX)
	  DECLARE @ROW VARCHAR(MAX)

	  BEGIN TRY	
	 
		 BEGIN TRANSACTION INSERTAR
								   
					--ACTUALIZA EN LA TABLA AGENCIAS BANCARIAS

					UPDATE tblAgenciaBancaria 
                    SET Nombre = Tbl_Temp.NOMBRE, UsaCuentasGrupo = Tbl_Temp.USA_CUENTAS_GRUPO, EnviaRemesas = Tbl_Temp.ENVIA_REMESAS, 
					SolicitaRemesas = Tbl_Temp.SOLICITA_REMESAS, CodigoBranch = Tbl_Temp.CODIGO_BRANCH, CodigoProvincia = Tbl_Temp.CODIGO_PROVINCIA, 
					CodigoCanton = Tbl_Temp.CODIGO_CANTON, CodigoDistrito = Tbl_Temp.CODIGO_DISTRITO, Direccion = Tbl_Temp.DIRECCION,
					Activo = Tbl_Temp.ACTIVO, FkIdPais = Tbl_Temp.Codigo_Pais, FkIdCedi = Tbl_Temp.Codigo_CEDI, FkIdGrupoAgencia = Tbl_Temp.Codigo_GrupoAgencias, 
					Fk_Transportadora_Envio = Tbl_Temp.Codigo_Transportadora_Envio, Fk_Transportadora_Solicitud = Tbl_Temp.Codigo_Transportadora_Solicitud, 
					FechaModificacion = CURRENT_TIMESTAMP 
                    FROM (
							SELECT IDAGENCIA, NOMBRE, USA_CUENTAS_GRUPO, ENVIA_REMESAS, SOLICITA_REMESAS, CODIGO_BRANCH, CODIGO_PROVINCIA, CODIGO_CANTON, CODIGO_DISTRITO, DIRECCION,
							ACTIVO, Codigo_Pais, Codigo_CEDI, Codigo_GrupoAgencias, Codigo_Transportadora_Envio, Codigo_Transportadora_Solicitud
							from @p_Tbl_Temp_Agencia_Bancaria_Insert) AS Tbl_Temp
					WHERE 
						Tbl_Temp.IDAGENCIA = tblAgenciaBancaria.Id


					SELECT @p_Id_Insert_Agencia_Bancaria = IDAGENCIA from @p_Tbl_Temp_Agencia_Bancaria_Insert
					SELECT @p_UsaCuentasGrupo_Insert_Agencia_Bancaria = USA_CUENTAS_GRUPO, @p_Id_Insert_Grupo_Agencia = Codigo_GrupoAgencias from @p_Tbl_Temp_Agencia_Bancaria_Insert;

					IF(@p_Id_Insert_Agencia_Bancaria IS NOT NULL)
					BEGIN   
					    
						--------------------------------------------------- ELIMINAR CUENTAS INTERNAS  ----------------------------------------------------------------
						DECLARE @iteradorEliminar INT = 1
						DECLARE @ContadorEliminar INT = (SELECT COUNT(1) FROM  @p_Tbl_Temp_Cuentas_Internas_Eliminar_Insert)

						IF @ContadorEliminar > 0 WHILE (@iteradorEliminar <= (SELECT MAX(ID) FROM @p_Tbl_Temp_Cuentas_Internas_Eliminar_Insert))
						BEGIN
						       --OBTIENE UN ITEM
							   SELECT @p_Id_Divisa_Iterador = IdDivisa, @p_Numero_Cuenta_Iterador = NumeroCuenta FROM @p_Tbl_Temp_Cuentas_Internas_Eliminar_Insert WHERE ID = @iteradorEliminar
							
							   --OBTIENE LA CUENTA SI EXISTE
							   SELECT @p_Id_Insert_Cuenta = Id  FROM tblCuentaInterna WHERE NumeroCuenta = @p_Numero_Cuenta_Iterador;

							   --UPDATE EN LA TABLA tblCuentaInterna_x_Agencia PARA INACTIVARLA
							   UPDATE [tblCuentaInterna_x_Agencia] SET Activo =  0 WHERE FkIdCuentaInterna = @p_Id_Insert_Cuenta AND FkIdAgencia = @p_Id_Insert_Agencia_Bancaria;

				   		   SET @iteradorEliminar = @iteradorEliminar + 1
					    END
						
						--------------------------------------------------- VALIDACION DE CUENTAS INTERNAS VACIAS -----------------------------------------------------
						DECLARE @iTERADOR INT = 1
						DECLARE @ContadorGrupo INT = (SELECT COUNT(1) FROM tblCuentaInterna_x_GrupoAgencias WHERE FkIdGrupoAgencias = @p_Id_Insert_Grupo_Agencia AND Activo = 1)

						IF @ContadorGrupo > 0 WHILE (@iTERADOR <= (SELECT MAX(FkIdCuentaInterna) FROM tblCuentaInterna_x_GrupoAgencias WHERE FkIdGrupoAgencias = @p_Id_Insert_Grupo_Agencia AND Activo = 1))
						BEGIN

                             --OBTIENE UN ITEM
						     SELECT @p_Activo_Insert_Cuentas_Agencia = Activo FROM tblCuentaInterna_x_Agencia WHERE FkIdCuentaInterna  = @iTERADOR  AND FkIdAgencia = @p_Id_Insert_Agencia_Bancaria;

							--VALIDACION 1(SI USA CUENTAS DE GRUPO Y SI LA CUENTA DE LA AGENCIA ESTA INACTIVA)
							--VALIDACION 2(SI USA CUENTAS DE GRUPO Y SI NO EXISTE LA CUENTA DE LA AGENCIA)
							--VALIDACION 3(SI NO USA CUENTAS DE GRUPO Y SI LA CUENTA DE LA AGENCIA ESTA ACTIVA)
						     IF(@p_UsaCuentasGrupo_Insert_Agencia_Bancaria = 1 AND @p_Activo_Insert_Cuentas_Agencia = 0)
					         BEGIN

							 --ACTUALIZA EN LA TABLA tblCuentaInterna_x_Agencia
							   UPDATE [tblCuentaInterna_x_Agencia] SET Activo =  1 WHERE FkIdCuentaInterna = @iTERADOR AND FkIdAgencia = @p_Id_Insert_Agencia_Bancaria;
                                       
			    	         END
							 ELSE IF(@p_UsaCuentasGrupo_Insert_Agencia_Bancaria = 1 AND @p_Activo_Insert_Cuentas_Agencia IS NULL)
							 BEGIN

							   --INSERTA EN LA TABLA tblCuentaInterna_x_Agencia
							   INSERT INTO dbo.[tblCuentaInterna_x_Agencia] ( FkIdCuentaInterna, FkIdAgencia )
							   SELECT FkIdCuentaInterna,@p_Id_Insert_Agencia_Bancaria  FROM  tblCuentaInterna_x_GrupoAgencias WHERE FkIdGrupoAgencias = @p_Id_Insert_Grupo_Agencia AND FkIdCuentaInterna = @iTERADOR AND Activo = 1

							 END
							 ELSE IF(@p_UsaCuentasGrupo_Insert_Agencia_Bancaria = 0 AND @p_Activo_Insert_Cuentas_Agencia = 1)
							 BEGIN

							   --ACTUALIZA EN LA TABLA tblCuentaInterna_x_Agencia
							   UPDATE [tblCuentaInterna_x_Agencia] SET Activo =  0 WHERE FkIdCuentaInterna = @iTERADOR AND FkIdAgencia = @p_Id_Insert_Agencia_Bancaria;

							 END

							  SET @iTERADOR = @iTERADOR + 1
					     END

						------------------------------ INICIO DEL RECORRIDO Y SETEO DE DATA DE LA TABLA TEMPORAL CUENTAS INTERNAS  ------------------------------------

						DECLARE @i INT = 1
						DECLARE @Contador INT = (SELECT COUNT(1) FROM  @p_Tbl_Temp_Cuentas_Internas_Insert)

						IF @Contador > 0 WHILE (@i <= (SELECT MAX(ID) FROM @p_Tbl_Temp_Cuentas_Internas_Insert))
						BEGIN

							--OBTIENE UN ITEM
							SELECT @p_Id_Divisa_Iterador = IdDivisa, @p_Numero_Cuenta_Iterador = NumeroCuenta FROM @p_Tbl_Temp_Cuentas_Internas_Insert WHERE ID = @i
							
							--OBTIENE LA CUENTA SI EXISTE Y SI EXISTE RELACION CON LA AGENCIA Y SI EXISTE RELACION CON EL GRUPO AGENCIA
							SELECT @p_Id_Insert_Cuenta = Id  FROM tblCuentaInterna WHERE NumeroCuenta = @p_Numero_Cuenta_Iterador;
							SELECT @p_Activo_Insert_Cuentas_Agencia = Activo  FROM tblCuentaInterna_x_Agencia WHERE FkIdCuentaInterna = @p_Id_Insert_Cuenta AND FkIdAgencia = @p_Id_Insert_Agencia_Bancaria;
							SELECT @p_Iterador_Insert_Grupo_Agencia = Id  FROM tblCuentaInterna_x_GrupoAgencias WHERE FkIdGrupoAgencias = @p_Id_Insert_Grupo_Agencia AND FkIdCuentaInterna = @p_Id_Insert_Cuenta AND Activo = 1;

							--VALIDACION 1(SI LA CUENTA EXISTE Y SI EXISTE RELACION CON LAS CUENTAS DE GRUPO AGENCIA)
							--VALIDACION 2(SI LA CUENTA EXISTE Y SI EXISTE RELACION CON LAS CUENTAS DE LA AGENCIA BANCARIA)
							--VALIDACION 3(SI LA CUENTA EXISTE)
							--VALIDACION 4(SI LA CUENTA NO EXISTE)
							IF(@p_Id_Insert_Cuenta IS NOT NULL AND @p_Iterador_Insert_Grupo_Agencia IS NOT NULL)
							BEGIN

							    --INSERTA EN LA TABLA tblCuentaInterna_x_Agencia
							      INSERT INTO dbo.[tblCuentaInterna_x_Agencia] ( FkIdCuentaInterna, FkIdAgencia )
																        VALUES ( @p_Id_Insert_Cuenta, @p_Id_Insert_Agencia_Bancaria )

							END
							ELSE IF(@p_Id_Insert_Cuenta IS NOT NULL AND @p_Activo_Insert_Cuentas_Agencia IS NOT NULL)
							BEGIN

							    ----UPDATE EN LA TABLA tblCuentaInterna_x_Agencia
								UPDATE [tblCuentaInterna_x_Agencia] SET Activo =  1 WHERE FkIdCuentaInterna = @p_Id_Insert_Cuenta AND FkIdAgencia = @p_Id_Insert_Agencia_Bancaria;

							END
							ELSE IF(@p_Id_Insert_Cuenta IS NOT NULL)
							BEGIN

								   --INSERTA EN LA TABLA tblCuentaInterna_x_Agencia
							      INSERT INTO dbo.[tblCuentaInterna_x_Agencia] ( FkIdCuentaInterna, FkIdAgencia )
																        VALUES ( @p_Id_Insert_Cuenta, @p_Id_Insert_Agencia_Bancaria )

							END
							ELSE
							BEGIN
							      
								  --INSERTA EN LA TABLA tblCuentaInterna
							      INSERT INTO dbo.[tblCuentaInterna] ( NumeroCuenta, FkIdDivisa )
														      VALUES ( @p_Numero_Cuenta_Iterador, @p_Id_Divisa_Iterador )

                                  SELECT @p_Id_Insert_Cuenta = CONVERT(INT, ISNULL(SCOPE_IDENTITY(), -1))

							      --INSERTA EN LA TABLA tblCuentaInterna_x_Agencia
							      INSERT INTO dbo.[tblCuentaInterna_x_Agencia] ( FkIdCuentaInterna, FkIdAgencia )
																        VALUES ( @p_Id_Insert_Cuenta, @p_Id_Insert_Agencia_Bancaria )

							END

							SET @i = @i + 1
						END --FIN DEL CICLO
														
					END
					
					SELECT @ROW = (SELECT * FROM tblAgenciaBancaria WHERE Id = @p_Id_Insert_Agencia_Bancaria FOR JSON PATH, INCLUDE_NULL_VALUES)
					
					------------------------------ RESPUESTA A LA APP  ------------------------------------
						INSERT INTO #Mensajes 
						EXEC SP_Select_Mensajes_Emergentes_Para_SP 
						@ROWS_AFFECTED = @@ROWCOUNT,
						@SUCCESS = 1,
						@ERROR_NUMBER_SP = NULL,
						@CONSTRAINT_TRIGGER_NAME = NULL,
						@ID = @p_Id_Insert_Agencia_Bancaria,
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
						@ID = @p_Id_Insert_Agencia_Bancaria,
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