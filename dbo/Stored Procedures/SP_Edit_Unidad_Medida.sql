CREATE PROCEDURE [dbo].[SP_Edit_Unidad_Medida] (
    @JSON_IN VARCHAR(MAX) = NULL,
    @JSON_OUT VARCHAR(MAX) OUTPUT
)
AS
BEGIN
    -- Declaración de Variables de Mensajes
    DECLARE @MetodoTemporal VARCHAR(MAX) = 'SP_Edit_Unidad_Medida';
    DECLARE @ErrorMensaje VARCHAR(MAX);
    DECLARE @ERROR_NUMBER VARCHAR(MAX);

    -- Declaración de Variables para las propiedades del JSON
    DECLARE @p_Id_Unidad_Medida INT;
    DECLARE @p_Nombre_Unidad_Medida VARCHAR(MAX);
    DECLARE @p_Simbolo_Unidad_Medida VARCHAR(MAX);
    DECLARE @p_Cantidad_Unidades INT;
    DECLARE @p_Activo_Unidad_Medida BIT;
    DECLARE @p_Id_Divisa BIT;

    -- Variables para iterar sobre las tablas temporales
    DECLARE @Id_Unidad_Medida_Modificada INT;

    -- Variables para iterar en las tablas temporales
	DECLARE @Resp_1 VARCHAR(MAX); 
	DECLARE @Resp_2 VARCHAR(MAX); 
	DECLARE @ROW VARCHAR(MAX);

    -- Crear tabla temporal para almacenar los resultados del procedimiento almacenado de mensajes
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

        SET @JSON_IN = REPLACE(@JSON_IN, '\', '')

        -- Extraer valores del JSON
        SELECT @p_Id_Unidad_Medida = Id FROM OPENJSON(@JSON_IN) WITH (Id INT);
        SELECT @p_Nombre_Unidad_Medida = Nombre FROM OPENJSON(@JSON_IN) WITH (Nombre VARCHAR(MAX));
        SELECT @p_Simbolo_Unidad_Medida = Simbolo FROM OPENJSON(@JSON_IN) WITH (Simbolo VARCHAR(MAX));
        SELECT @p_Cantidad_Unidades = Cantidad_Unidades FROM OPENJSON(@JSON_IN) WITH (Cantidad_Unidades INT);
        SELECT @p_Activo_Unidad_Medida = Activo FROM OPENJSON(@JSON_IN) WITH (Activo BIT);

        -- Extraer Divisa (Tabla Hijo)
        SELECT @p_Id_Divisa = Id 
		FROM OPENJSON(@JSON_IN) 
		WITH (Divisa NVARCHAR(MAX) AS JSON)
        CROSS APPLY OPENJSON (Divisa) 
		WITH (Id INT);

        -- Declarar tabla temporal para Divisas
        DECLARE @p_Tbl_Temp_Divisa TABLE (
            ID INT IDENTITY(1,1),
            Id_Divisa INT,
            Nombre VARCHAR(MAX)
        );

        -- Insertar en tabla temporal Divisa
        INSERT INTO @p_Tbl_Temp_Divisa
        SELECT Id, Nombre
        FROM OPENJSON(@JSON_IN)
        WITH (Divisa NVARCHAR(MAX) AS JSON)
        CROSS APPLY OPENJSON(Divisa) 
		WITH (Id INT, Nombre VARCHAR(MAX));

        -- Declarar tabla temporal para Presentaciones Habilitadas
        DECLARE @p_Tbl_Temp_Presentaciones_Habilitadas TABLE (
            ID INT IDENTITY(1,1),
            Id_Efectivo INT,
            Nombre VARCHAR(MAX)
        );

        -- Insertar en tabla temporal Presentaciones Habilitadas
        INSERT INTO @p_Tbl_Temp_Presentaciones_Habilitadas
        SELECT Id, Nombre
        FROM OPENJSON(@JSON_IN)
        WITH (Presentaciones_Habilitadas NVARCHAR(MAX) AS JSON)
        CROSS APPLY OPENJSON(Presentaciones_Habilitadas) 
		WITH (Id INT, Nombre VARCHAR(MAX));

        BEGIN TRY
            BEGIN TRANSACTION EDITAR;

            -- Editar la tabla tblUnidadMedida
            UPDATE tblUnidadMedida
            SET Nombre = @p_Nombre_Unidad_Medida, Simbolo = @p_Simbolo_Unidad_Medida, Cantidad_Unidades = @p_Cantidad_Unidades, 
			Activo = @p_Activo_Unidad_Medida, Fecha_Modificacion = GETDATE()
            WHERE tblUnidadMedida.Id = @p_Id_Unidad_Medida;

            SET @Id_Unidad_Medida_Modificada = @p_Id_Unidad_Medida;

            -- Procesar Divisas
            IF EXISTS(SELECT 1 FROM @p_Tbl_Temp_Divisa)
            BEGIN
                DELETE FROM tblUnidadMedida_x_Divisa WHERE Fk_Id_Unidad_Medida = @p_Id_Unidad_Medida;
                
                INSERT INTO tblUnidadMedida_x_Divisa (Fk_Id_Unidad_Medida, Fk_Id_Divisa, Activo, Fecha_Creacion)
                SELECT @p_Id_Unidad_Medida, Id_Divisa, 1, GETDATE()
                FROM @p_Tbl_Temp_Divisa;
            END;

            -- Procesar Presentaciones Habilitadas
            IF EXISTS(SELECT 1 FROM @p_Tbl_Temp_Presentaciones_Habilitadas)
            BEGIN
                DELETE FROM tblUnidadMedida_x_TipoEfectivo WHERE Fk_Id_Unidad_Medida = @p_Id_Unidad_Medida;

                INSERT INTO tblUnidadMedida_x_TipoEfectivo (Fk_Id_Unidad_Medida, Fk_Id_Tipo_Efectivo, Activo, Fecha_Creacion)
                SELECT @p_Id_Unidad_Medida, Id_Efectivo, 1, GETDATE()
                FROM @p_Tbl_Temp_Presentaciones_Habilitadas;
            END;

            -- Generar respuesta exitosa
						INSERT INTO #Mensajes 
						EXEC SP_Select_Mensajes_Emergentes_Para_SP 
						@ROWS_AFFECTED = @@ROWCOUNT,
						@SUCCESS = 1,
						@ERROR_NUMBER_SP = NULL,
						@CONSTRAINT_TRIGGER_NAME = NULL,
						@ID = @Id_Unidad_Medida_Modificada,
						@ROW = @ROW,
						@Metodo = @MetodoTemporal, 
						@TipoMensaje = 'Exitoso', 
						@ErrorMensaje = NULL,
						@ModeJson = 0;

            -- Confirmar la transacción
            COMMIT TRANSACTION EDITAR;
        END TRY
        BEGIN CATCH
            -- Manejar errores
            IF @@TRANCOUNT > 0 BEGIN
                ROLLBACK TRANSACTION EDITAR;
            END

            DECLARE @ERROR VARCHAR(MAX) = ERROR_MESSAGE();
            SET @ERROR_NUMBER = ERROR_NUMBER();

						INSERT INTO #Mensajes 
						EXEC SP_Select_Mensajes_Emergentes_Para_SP 
						@ROWS_AFFECTED = 0,
						@SUCCESS = 0,
						@ERROR_NUMBER_SP = @ERROR_NUMBER,
						@CONSTRAINT_TRIGGER_NAME = @ERROR,
						@ID = @Id_Unidad_Medida_Modificada,
						@ROW = NULL,
						@Metodo = @MetodoTemporal, 
						@TipoMensaje = 'Error', 
						@ErrorMensaje = @ERROR,
						@ModeJson = 0;

        END CATCH;

    -- Preparar respuesta JSON
    SELECT @Resp_1 = (SELECT * FROM #Mensajes FOR JSON PATH, INCLUDE_NULL_VALUES);
    SELECT @Resp_2 = (SELECT CAST(@Resp_1 AS VARCHAR(MAX)));
    SET @JSON_OUT = @Resp_2;

    -- Limpiar tabla temporal
    TRUNCATE TABLE #Mensajes;
    DROP TABLE #Mensajes;
END;