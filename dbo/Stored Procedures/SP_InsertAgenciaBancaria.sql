

CREATE   PROCEDURE [dbo].[SP_InsertAgenciaBancaria](
	@JSON_IN VARCHAR(MAX) = NULL,
	@JSON_OUT  VARCHAR(MAX) OUTPUT 
)
AS
BEGIN

	  ---Declaracion Variables Mensajes
      DECLARE @MetodoTemporal VARCHAR(MAX) = 'SP_InsertAgenciaBancaria';
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
	  DECLARE @p_Id_Insert_Agencia_Bancaria INT ;
	  DECLARE @p_Id_Insert_Grupo_Agencia INT;
	  DECLARE @p_Iterador_Insert_Grupo_Agencia INT;
	  DECLARE @p_UsaCuentasGrupo_Insert_Agencia_Bancaria BIT;
	  DECLARE @p_Id_Insert_Cuenta INT;
	  DECLARE @p_Id_Insert_CuentaxAgencia INT;
	  DECLARE @Id INT;
      DECLARE @Codigo_Agencia VARCHAR(25);

	  --------------------------- DECLARACION DE TABLA PARA INSERTAR LOS REGISTROS DE AGENCIAS BANCARIAS (TABLA PADRE) ----------------------------------------
	  DECLARE @p_Tbl_Temp_Agencia_Bancaria_Insert TABLE   
	  (  
		  ID							  INT IDENTITY(1,1)
		 ,NOMBRE						  VARCHAR(MAX)
		 ,USA_CUENTAS_GRUPO				  BIT
		 ,ENVIA_REMESAS					  BIT
		 ,SOLICITA_REMESAS				  BIT
		 ,CODIGO_BRANCH					  VARCHAR(MAX)
		 ,CODIGO_PROVINCIA				  INT
		 ,CODIGO_CANTON					  INT
		 ,CODIGO_DISTRITO				  INT
		 ,DIRECCION						  VARCHAR(MAX)
		 ,Codigo_Pais                     INT
		 ,Codigo_CEDI					  INT
		 ,Codigo_GrupoAgencias            INT
		 ,Codigo_Transportadora_Envio     INT
		 ,Codigo_Transportadora_Solicitud INT
		 ,Activo                          BIT
	  );  

		--INSERTA CADA UNO DE LOS ITEMS DE LAS AGENCIAS BANCARIAS
		INSERT INTO @p_Tbl_Temp_Agencia_Bancaria_Insert	 
		SELECT 
			   NOMBRE
		      ,USA_CUENTAS_GRUPO
		      ,ENVIA_REMESAS
		      ,SOLICITA_REMESAS
		      ,CODIGO_BRANCH
		      ,CODIGO_PROVINCIA
			  ,CODIGO_CANTON
			  ,CODIGO_DISTRITO
			  ,DIRECCION
			  ,Codigo_Pais
			  ,Codigo_CEDI
			  ,Codigo_GrupoAgencias
			  ,Codigo_Transportadora_Envio
			  ,Codigo_Transportadora_Solicitud
			  ,Activo
		FROM OPENJSON (@JSON_IN)
		WITH 
		(
		  NOMBRE						  VARCHAR(MAX)
		 ,USA_CUENTAS_GRUPO				  BIT
		 ,ENVIA_REMESAS					  BIT
		 ,SOLICITA_REMESAS				  BIT
		 ,CODIGO_BRANCH					  VARCHAR(MAX)
		 ,CODIGO_PROVINCIA				  INT
		 ,CODIGO_CANTON					  INT
		 ,CODIGO_DISTRITO				  INT
		 ,DIRECCION						  VARCHAR(MAX)
		 ,Codigo_Pais					  INT
		 ,Codigo_CEDI					  INT
		 ,Codigo_GrupoAgencias			  INT
		 ,Codigo_Transportadora_Envio     INT
		 ,Codigo_Transportadora_Solicitud INT
		 ,Activo                          BIT
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

	  --DECLARACION DE VARIABLES PARA RECORRER LA TABLA TEMPORAL CUENTAS INTERNAS
	  DECLARE @p_Id_Divisa_Iterador INT
	  DECLARE @p_Numero_Cuenta_Iterador VARCHAR(MAX)

	  --VARIABLES PARA DAR RESPUESTA
	  DECLARE @Resp_1 VARCHAR(MAX)
	  DECLARE @Resp_2 VARCHAR(MAX)
	  DECLARE @ROW VARCHAR(MAX)

	  BEGIN TRY	
	 
		 BEGIN TRANSACTION INSERTAR
								   
					--INSERTA EN LA TABLA AGENCIAS BANCARIAS

					SELECT @Id = ISNULL(MAX(Id),0) + 1 FROM tblAgenciaBancaria;
					SELECT @Codigo_Agencia = RIGHT('00000' + CAST(@Id AS VARCHAR(5)), 5);

					INSERT INTO tblAgenciaBancaria ( Nombre, Codigo_Agencia, UsaCuentasGrupo, EnviaRemesas, SolicitaRemesas, CodigoBranch, CodigoProvincia, 
					                                  CodigoCanton, CodigoDistrito, Direccion, FkIdPais
												    , FkIdCedi, FkIdGrupoAgencia, Fk_Transportadora_Envio, Fk_Transportadora_Solicitud, Activo)
					SELECT  NOMBRE, @Codigo_Agencia, USA_CUENTAS_GRUPO, ENVIA_REMESAS, SOLICITA_REMESAS, CODIGO_BRANCH, CODIGO_PROVINCIA, 
					        CODIGO_CANTON, CODIGO_DISTRITO, DIRECCION, Codigo_Pais, Codigo_CEDI ,Codigo_GrupoAgencias,
							Codigo_Transportadora_Envio, Codigo_Transportadora_Solicitud , Activo
							from @p_Tbl_Temp_Agencia_Bancaria_Insert;

					SELECT @p_Id_Insert_Agencia_Bancaria = CONVERT(INT, ISNULL(SCOPE_IDENTITY(), -1))
					SELECT @p_UsaCuentasGrupo_Insert_Agencia_Bancaria = USA_CUENTAS_GRUPO, @p_Id_Insert_Grupo_Agencia = Codigo_GrupoAgencias from @p_Tbl_Temp_Agencia_Bancaria_Insert;

						--------------------------------------------------- VALIDACION DE CUENTAS INTERNAS VACIAS -----------------------------------------------------
						IF(@p_UsaCuentasGrupo_Insert_Agencia_Bancaria = 1)
					    BEGIN

							 --INSERTA EN LA TABLA tblCuentaInterna_x_Agencia
							   INSERT INTO dbo.[tblCuentaInterna_x_Agencia] ( FkIdCuentaInterna, FkIdAgencia )
							   SELECT FkIdCuentaInterna,@p_Id_Insert_Agencia_Bancaria  FROM  tblCuentaInterna_x_GrupoAgencias WHERE FkIdGrupoAgencias = @p_Id_Insert_Grupo_Agencia AND Activo = 1
                                       
			    	    END

						------------------------------ INICIO DEL RECORRIDO Y SETEO DE DATA DE LA TABLA TEMPORAL CUENTAS INTERNAS  ------------------------------------

						DECLARE @i INT = 1
						DECLARE @Contador INT = (SELECT COUNT(1) FROM  @p_Tbl_Temp_Cuentas_Internas_Insert)

						IF @Contador > 0 BEGIN WHILE (@i <= (SELECT MAX(ID) FROM @p_Tbl_Temp_Cuentas_Internas_Insert))
							BEGIN

								--OBTIENE UN ITEM
								SELECT @p_Id_Divisa_Iterador = IdDivisa, @p_Numero_Cuenta_Iterador = NumeroCuenta FROM @p_Tbl_Temp_Cuentas_Internas_Insert WHERE ID = @i
							
								--OBTIENE LA CUENTA SI EXISTE Y SI EXISTE RELACION CON LA AGENCIA
								SELECT @p_Id_Insert_Cuenta = Id  FROM tblCuentaInterna WHERE NumeroCuenta = @p_Numero_Cuenta_Iterador;
								SELECT @p_Id_Insert_CuentaxAgencia = Id  FROM tblCuentaInterna_x_Agencia WHERE FkIdCuentaInterna = @p_Id_Insert_Cuenta AND FkIdAgencia = @p_Id_Insert_Agencia_Bancaria;
								SELECT @p_Iterador_Insert_Grupo_Agencia = Id  FROM tblCuentaInterna_x_GrupoAgencias WHERE FkIdGrupoAgencias = @p_Id_Insert_Grupo_Agencia AND FkIdCuentaInterna = @p_Id_Insert_Cuenta AND Activo = 1;

								--VALIDACION 1(SI LA CUENTA EXISTE Y NO ESTA EN GRUPO AGENCIA Y USA CUENTAS DE GRUPO)
								--VALIDACION 1(SI LA CUENTA EXISTE Y NO USA CUENTAS DE GRUPO)
								--VALIDACION 3(SI LA CUENTA NO EXISTE Y  EL NUMERO DE CUENTA NO ESTA VACIO)
								IF((@p_Id_Insert_Cuenta IS NOT NULL AND @p_Iterador_Insert_Grupo_Agencia IS NULL AND @p_UsaCuentasGrupo_Insert_Agencia_Bancaria = 1) OR (@p_Id_Insert_Cuenta IS NOT NULL AND @p_UsaCuentasGrupo_Insert_Agencia_Bancaria = 0))
								BEGIN

									--INSERTA EN LA TABLA tblCuentaInterna_x_Agencia
									  INSERT INTO dbo.[tblCuentaInterna_x_Agencia] ( FkIdCuentaInterna, FkIdAgencia )
																			VALUES ( @p_Id_Insert_Cuenta, @p_Id_Insert_Agencia_Bancaria )

								END
								ELSE IF(@p_Id_Insert_Cuenta IS NULL AND @p_Numero_Cuenta_Iterador IS NOT NULL)
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
	   
	--- 
END
---