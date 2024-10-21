------------------------------------- INICIO DE ELIMINAR TABLAS EXTERNAS -------------------------------------

DECLARE @tableName NVARCHAR(128)
DECLARE @schemaName NVARCHAR(128)
DECLARE @QUERY NVARCHAR(MAX)

DECLARE cur CURSOR FOR 
SELECT schema_name(schema_id), name 
FROM sys.external_tables 

OPEN cur

FETCH NEXT FROM cur INTO @schemaName, @tableName

WHILE @@FETCH_STATUS = 0
BEGIN
    SET @QUERY = N'DROP EXTERNAL TABLE ' + QUOTENAME(@schemaName) + N'.' + QUOTENAME(@tableName)
    EXEC sp_executesql @QUERY
    FETCH NEXT FROM cur INTO @schemaName, @tableName 
END

CLOSE cur
DEALLOCATE cur

------------------------------------- FIN DE ELIMINAR TABLAS EXTERNAS -------------------------------------

------------------------------------- INICIO DE ELIMINAR EXTERNAL DATA SOURCE -------------------------------------
PRINT N'INICIO DE ELIMINAR EXTERNAL DATA SOURCE';

GO

DECLARE @dataSourceName NVARCHAR(128);
DECLARE @QUERYS NVARCHAR(MAX);

DECLARE dataSourceCursor CURSOR FOR
SELECT name
FROM sys.external_data_sources;

OPEN dataSourceCursor;

FETCH NEXT FROM dataSourceCursor INTO @dataSourceName;

WHILE @@FETCH_STATUS = 0
BEGIN
    SET @QUERYS = N'DROP EXTERNAL DATA SOURCE [' + @dataSourceName + N']';
    EXEC sp_executesql @QUERYS;
    FETCH NEXT FROM dataSourceCursor INTO @dataSourceName;
END

CLOSE dataSourceCursor;
DEALLOCATE dataSourceCursor;

PRINT N'FIN DE ELIMINAR EXTERNAL DATA SOURCE';

GO
------------------------------------- FIN DE ELIMINAR EXTERNAL DATA SOURCE -------------------------------------


------------------------------------- CREACION DE EXTERNAL DATA SOURCE -------------------------------------

DECLARE @NombreBaseDatos NVARCHAR(50);
DECLARE @SqlCommand NVARCHAR(MAX);
DECLARE @Servername NVARCHAR(MAX) = (SELECT @@SERVERNAME AS ServerName);

IF (DB_NAME() = 'sitesw-Global') 
BEGIN
    SET @NombreBaseDatos = N'sitesw-Identity';
END
ELSE 
BEGIN
    SET @NombreBaseDatos = N'sitesw-Identitystg';
END

-- Construye el comando SQL dinámico
SET @SqlCommand = N'
    CREATE EXTERNAL DATA SOURCE [sitesw-Identity]
    WITH (
        TYPE = RDBMS,
        LOCATION = N'''+@Servername+'.database.windows.net'',
        DATABASE_NAME = N''' + @NombreBaseDatos + ''',
        CREDENTIAL = [ElasticDBQueryCred]
    );';

-- Ejecuta el comando SQL dinámico
EXEC sp_executesql @SqlCommand;

------------------------------------- FIN DE CREACION DE EXTERNAL DATA SOURCE -------------------------------------



------------------------------------- CREACION DE TABLAS EXTERNAS -------------------------------------

CREATE EXTERNAL TABLE [dbo].[tblAccesoInformacionAgenciasUsuario] (
    [Id]                INT           NOT NULL,
    [Fk_Id_Usuario]     INT           NOT NULL,
    [Fk_Id_Agencia]     INT           NOT NULL,
    [Activo]            BIT           NOT NULL,
    [FechaCreacion]     SMALLDATETIME NOT NULL,
    [FechaModificacion] SMALLDATETIME NULL
)
    WITH (
    DATA_SOURCE = [sitesw-Identity]
    );

CREATE EXTERNAL TABLE [dbo].[tblFirmasUsuario] (
    [Id] INT NOT NULL,
    [FK_Id_Usuario] INT NOT NULL,
    [FK_Id_Matriz] INT NOT NULL,
    [FK_Id_Firma] INT NOT NULL,
    [Codigo] VARCHAR (90) NOT NULL,
    [Activo] BIT NOT NULL,
    [FechaCreacion] SMALLDATETIME NOT NULL,
    [FechaModificacion] SMALLDATETIME NULL
)
    WITH (
    DATA_SOURCE = [sitesw-Identity]
    );

CREATE EXTERNAL TABLE [dbo].[tblPaises] (
    [Id]          INT           NOT NULL,
    [Nombre]      VARCHAR (100) NULL,
    [Activo]      BIT           NULL,
    [IconBandera] VARCHAR (250) NULL,
    [TIME_ZONE]   VARCHAR (90)  NULL
)
    WITH (
    DATA_SOURCE = [sitesw-Identity]
    );

CREATE EXTERNAL TABLE [dbo].[tblRol] (
    [Id] INT NOT NULL,
    [Nombre] VARCHAR (150) NULL,
    [Fk_Id_Departamento] INT NOT NULL,
    [Fk_Id_Area] INT NOT NULL,
    [Originador] BIT NOT NULL,
    [Activo] BIT NOT NULL,
    [FechaCreacion] SMALLDATETIME NOT NULL,
    [FechaModificacion] SMALLDATETIME NULL
)
    WITH (
    DATA_SOURCE = [sitesw-Identity]
    );

CREATE EXTERNAL TABLE [dbo].[tblUsuario] (
    [Id]                 INT            NOT NULL,
    [Nombre]             VARCHAR (300) NULL,
    [Apellido1]          VARCHAR (300) NULL,
    [Apellido2]          VARCHAR (300) NULL,
    [Correo]             VARCHAR (300) NULL,
    [UsuarioRed]         VARCHAR (300) NOT NULL,
    [NumeroColaborador]  INT            NOT NULL,
    [Codigo]             VARCHAR (90)  NOT NULL,
    [Fk_Id_Rol]          INT            NOT NULL,
    [EsAprobador]        BIT            NOT NULL,
    [TieneFirmas]        BIT            NOT NULL,
    [FKGestionActual]    INT            NULL,
    [FKEstadoUsuario]    INT            NOT NULL,
    [UsuarioAprobado]    BIT            NOT NULL,
    [Activo]             BIT            NOT NULL,
    [FechaCreacion]      SMALLDATETIME  NOT NULL,
    [FechaModificacion]  SMALLDATETIME  NULL,
    [FechaUltimoIngreso] SMALLDATETIME  NULL,
    [FechaIngresoActual] SMALLDATETIME  NULL,
    [FkIdPais]           INT            NULL
    )
    WITH (
    DATA_SOURCE = [sitesw-Identity]
    );

------------------------------------- FIN DE CREACION DE TABLAS EXTERNAS -------------------------------------

-----------------------------------------
-- I N S E R T		D E		D A T O S
-----------------------------------------

---------------------------------------------------------------------
--- I N S E R T		C O L A B O R A D O R
---------------------------------------------------------------------
IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = 'dbo' AND TABLE_NAME = 'tblColaborador')
BEGIN
	SET IDENTITY_INSERT [dbo].[tblColaborador] ON 

	-- Verificar y hacer INSERT si no existe el registro con Id = 1
	IF NOT EXISTS (SELECT 1 FROM [dbo].[tblColaborador] WHERE [Id] = 1)
	BEGIN
		INSERT INTO [dbo].[tblColaborador] ([Id], [Nombre], [Apellido1], [Apellido2], [Cedula], [UserActiveDirectory], [Activo], [Correo], [FechaCreacion], [FechaModificacion])
		VALUES (1, N'Esteban', N'Cordoba', N'Calderon', N'60011013', N'ecordoba', 1, N'ecordobaca@baccredomatic.cr', CURRENT_TIMESTAMP, NULL);
	END

	-- Verificar y hacer INSERT si no existe el registro con Id = 2
	IF NOT EXISTS (SELECT 1 FROM [dbo].[tblColaborador] WHERE [Id] = 2)
	BEGIN
		INSERT INTO [dbo].[tblColaborador] ([Id], [Nombre], [Apellido1], [Apellido2], [Cedula], [UserActiveDirectory], [Activo], [Correo], [FechaCreacion], [FechaModificacion])
		VALUES (2, N'Jefry', N'Sanchez', N'Blandino', N'115580349', N'jefry.sanchez', 1, N'jefry.sanchez@cr.asesorexternoca.com', CURRENT_TIMESTAMP, NULL);
	END

	-- Verificar y hacer INSERT si no existe el registro con Id = 3
	IF NOT EXISTS (SELECT 1 FROM [dbo].[tblColaborador] WHERE [Id] = 3)
	BEGIN
		INSERT INTO [dbo].[tblColaborador] ([Id], [Nombre], [Apellido1], [Apellido2], [Cedula], [UserActiveDirectory], [Activo], [Correo], [FechaCreacion], [FechaModificacion])
		VALUES (3, N'Johan', N'Umaña', N'Villalobos', N'115576578', N'jumanavi', 1, N'jumanav@baccredomatic.cr', CURRENT_TIMESTAMP, NULL);
	END

	-- Verificar y hacer INSERT si no existe el registro con Id = 4
	IF NOT EXISTS (SELECT 1 FROM [dbo].[tblColaborador] WHERE [Id] = 4)
	BEGIN
		INSERT INTO [dbo].[tblColaborador] ([Id], [Nombre], [Apellido1], [Apellido2], [Cedula], [UserActiveDirectory], [Activo], [Correo], [FechaCreacion], [FechaModificacion])
		VALUES (4, N'Jose', N'Lenin', N'Ulloa', N'115562345', N'jose.ulloa', 1, N'jose.ulloa@cr.asesorexternoca.com', CURRENT_TIMESTAMP, NULL);
	END

	-- Verificar y hacer INSERT si no existe el registro con Id = 5
	IF NOT EXISTS (SELECT 1 FROM [dbo].[tblColaborador] WHERE [Id] = 5)
	BEGIN
		INSERT INTO [dbo].[tblColaborador] ([Id], [Nombre], [Apellido1], [Apellido2], [Cedula], [UserActiveDirectory], [Activo], [Correo], [FechaCreacion], [FechaModificacion])
		VALUES (5, N'Ulises', N'Valenciano', N'Alfaro', N'111111111', N'ulises.valenciano', 1, N'ulises.valenciano@baccredomatic.cr', CURRENT_TIMESTAMP, NULL);
	END

	SET IDENTITY_INSERT [dbo].[tblColaborador] OFF
END
GO
---------------------------------------------------------------
--- I N S E R T		H A B I L I T A R   B A N N E R
---------------------------------------------------------------
IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = 'dbo' AND TABLE_NAME = 'tblHabilitarBanner')
BEGIN
    -- Verificar y hacer INSERT si no existe el registro con Id = 1
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblHabilitarBanner] WHERE [Id] = 1)
    BEGIN
        SET IDENTITY_INSERT [dbo].[tblHabilitarBanner] ON 

        INSERT INTO [dbo].[tblHabilitarBanner] ([Id], [Activo], [FechaCreacion], [FechaModificacion])
        VALUES (1, 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

        SET IDENTITY_INSERT [dbo].[tblHabilitarBanner] OFF
    END
END
GO
---------------------------------------------------------------
--- I N S E R T		M O D U L O
---------------------------------------------------------------
IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = 'dbo' AND TABLE_NAME = 'tblModulo')
BEGIN
    SET IDENTITY_INSERT [dbo].[tblModulo] ON 

    -- Verificar y hacer INSERT si no existe el registro con Id = 1 y Nombre = 'Recepcion'
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblModulo] WHERE [Id] = 1 AND [Nombre] = 'Recepcion')
    BEGIN
        INSERT INTO [dbo].[tblModulo] ([Id], [Nombre], [FechaCreacion], [FechaModificacion], [Activo]) 
        VALUES (1, N'Recepcion', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 1);
    END

    -- Verificar y hacer INSERT si no existe el registro con Id = 2 y Nombre = 'Centro de Efectivo'
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblModulo] WHERE [Id] = 2 AND [Nombre] = 'Centro de Efectivo')
    BEGIN
        INSERT INTO [dbo].[tblModulo] ([Id], [Nombre], [FechaCreacion], [FechaModificacion], [Activo]) 
        VALUES (2, N'Centro de Efectivo', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 1);
    END

    -- Verificar y hacer INSERT si no existe el registro con Id = 3 y Nombre = 'Boveda General'
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblModulo] WHERE [Id] = 3 AND [Nombre] = 'Boveda General')
    BEGIN
        INSERT INTO [dbo].[tblModulo] ([Id], [Nombre], [FechaCreacion], [FechaModificacion], [Activo]) 
        VALUES (3, N'Boveda General', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 1);
    END

    -- Verificar y hacer INSERT si no existe el registro con Id = 4 y Nombre = 'Facturacion'
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblModulo] WHERE [Id] = 4 AND [Nombre] = 'Facturacion')
    BEGIN
        INSERT INTO [dbo].[tblModulo] ([Id], [Nombre], [FechaCreacion], [FechaModificacion], [Activo]) 
        VALUES (4, N'Facturacion', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 1);
    END

    -- Verificar y hacer INSERT si no existe el registro con Id = 5 y Nombre = 'Cajeros Automaticos'
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblModulo] WHERE [Id] = 5 AND [Nombre] = 'Cajeros Automaticos')
    BEGIN
        INSERT INTO [dbo].[tblModulo] ([Id], [Nombre], [FechaCreacion], [FechaModificacion], [Activo]) 
        VALUES (5, N'Cajeros Automaticos', CURRENT_TIMESTAMP, NULL, 1);
    END

    -- Verificar y hacer INSERT si no existe el registro con Id = 6 y Nombre = 'Niquel'
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblModulo] WHERE [Id] = 6 AND [Nombre] = 'Niquel')
    BEGIN
        INSERT INTO [dbo].[tblModulo] ([Id], [Nombre], [FechaCreacion], [FechaModificacion], [Activo]) 
        VALUES (6, N'Niquel', CURRENT_TIMESTAMP, NULL, 1);
    END

    -- Verificar y hacer INSERT si no existe el registro con Id = 7 y Nombre = 'Transporte de valor'
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblModulo] WHERE [Id] = 7 AND [Nombre] = 'Transporte de valor')
    BEGIN
        INSERT INTO [dbo].[tblModulo] ([Id], [Nombre], [FechaCreacion], [FechaModificacion], [Activo]) 
        VALUES (7, N'Transporte de valor', CURRENT_TIMESTAMP, NULL, 1);
    END

    -- Verificar y hacer INSERT si no existe el registro con Id = 8 y Nombre = 'Optimizacion'
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblModulo] WHERE [Id] = 8 AND [Nombre] = 'Optimizacion')
    BEGIN
        INSERT INTO [dbo].[tblModulo] ([Id], [Nombre], [FechaCreacion], [FechaModificacion], [Activo]) 
        VALUES (8, N'Optimizacion', CURRENT_TIMESTAMP, NULL, 1);
    END

    -- Verificar y hacer INSERT si no existe el registro con Id = 9 y Nombre = 'Mantenimientos'
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblModulo] WHERE [Id] = 9 AND [Nombre] = 'Mantenimientos')
    BEGIN
        INSERT INTO [dbo].[tblModulo] ([Id], [Nombre], [FechaCreacion], [FechaModificacion], [Activo]) 
        VALUES (9, N'Mantenimientos', CURRENT_TIMESTAMP, NULL, 1);
    END

    SET IDENTITY_INSERT [dbo].[tblModulo] OFF
END
GO
---------------------------------------------------------------
--- I N S E R T		D I V I S A
---------------------------------------------------------------
IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = 'dbo' AND TABLE_NAME = 'tblDivisa')
BEGIN
    SET IDENTITY_INSERT [dbo].[tblDivisa] ON 

    -- Verificar y hacer INSERT si no existe el registro con Id = 1 y Nombre = 'Colón'
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDivisa] WHERE [Id] = 1 AND [Nombre] = 'Colón')
    BEGIN
        INSERT INTO [dbo].[tblDivisa] ([Id], [Nombre], [Nomenclatura], [Simbolo], [Descripcion], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES (1, N'Colón', N'CRC', N'¢', N'Moneda De Costa Rica', 1, CURRENT_TIMESTAMP, NULL);
    END

    -- Verificar y hacer INSERT si no existe el registro con Id = 2 y Nombre = 'Dólar'
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDivisa] WHERE [Id] = 2 AND [Nombre] = 'Dólar')
    BEGIN
        INSERT INTO [dbo].[tblDivisa] ([Id], [Nombre], [Nomenclatura], [Simbolo], [Descripcion], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES (2, N'Dólar', N'USD', N'$', N'Moneda De Estados Unidos', 1, CURRENT_TIMESTAMP, NULL);
    END

    -- Verificar y hacer INSERT si no existe el registro con Id = 3 y Nombre = 'Euro'
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDivisa] WHERE [Id] = 3 AND [Nombre] = 'Euro')
    BEGIN
        INSERT INTO [dbo].[tblDivisa] ([Id], [Nombre], [Nomenclatura], [Simbolo], [Descripcion], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES (3, N'Euro', N'EUR', N'€', N'Moneda De La Union Europea', 1, CURRENT_TIMESTAMP, NULL);
    END

    SET IDENTITY_INSERT [dbo].[tblDivisa] OFF
END
GO
---------------------------------------------------------------
--- I N S E R T		T I P O   E F E C T I V O
---------------------------------------------------------------
IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = 'dbo' AND TABLE_NAME = 'tblTipoEfectivo')
BEGIN 
    SET IDENTITY_INSERT [dbo].[tblTipoEfectivo] ON 

    -- Verificar y hacer INSERT si no existe el registro con Id = 1 y Nombre = 'Billete'
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblTipoEfectivo] WHERE [Id] = 1 AND [Nombre] = 'Billete')
    BEGIN
        INSERT INTO [dbo].[tblTipoEfectivo] ([Id], [Nombre], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES (1, N'Billete', 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);
    END

    SET IDENTITY_INSERT [dbo].[tblTipoEfectivo] OFF
END
GO
---------------------------------------------------------------
--- I N S E R T		D I V I S A   X  T I P O   E F E C T I V O
---------------------------------------------------------------
IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = 'dbo' AND TABLE_NAME = 'tblDivisa_x_TipoEfectivo')
BEGIN 
    -- Verificar y hacer INSERT si no existe el registro con FkIdTipoEfectivo = 1 y NombreDivisa = 'Colón'
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDivisa_x_TipoEfectivo] WHERE [FkIdTipoEfectivo] = 1 AND [NombreDivisa] = 'Colón')
    BEGIN
        INSERT INTO [dbo].[tblDivisa_x_TipoEfectivo] ([FkIdTipoEfectivo], [FkIdDivisa], [FechaCreacion], [FechaModificacion], [Activo], [NombreTipoEfectivo], [NombreDivisa]) 
        VALUES (1, 1, CURRENT_TIMESTAMP, NULL, 1, 'Billete', 'Colón');
    END

    -- Verificar y hacer INSERT si no existe el registro con FkIdTipoEfectivo = 1 y NombreDivisa = 'Dólar'
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDivisa_x_TipoEfectivo] WHERE [FkIdTipoEfectivo] = 1 AND [NombreDivisa] = 'Dólar')
    BEGIN
        INSERT INTO [dbo].[tblDivisa_x_TipoEfectivo] ([FkIdTipoEfectivo], [FkIdDivisa], [FechaCreacion], [FechaModificacion], [Activo], [NombreTipoEfectivo], [NombreDivisa]) 
        VALUES (1, 2, CURRENT_TIMESTAMP, NULL, 1, 'Billete', 'Dólar');
    END

    -- Verificar y hacer INSERT si no existe el registro con FkIdTipoEfectivo = 1 y NombreDivisa = 'Euro'
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDivisa_x_TipoEfectivo] WHERE [FkIdTipoEfectivo] = 1 AND [NombreDivisa] = 'Euro')
    BEGIN
        INSERT INTO [dbo].[tblDivisa_x_TipoEfectivo] ([FkIdTipoEfectivo], [FkIdDivisa], [FechaCreacion], [FechaModificacion], [Activo], [NombreTipoEfectivo], [NombreDivisa]) 
        VALUES (1, 3, CURRENT_TIMESTAMP, NULL, 1, 'Billete', 'Euro');
    END
END
GO
---------------------------------------------------------------
--- I N S E R T		T I P O   C A M B I O
---------------------------------------------------------------
IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = 'dbo' AND TABLE_NAME = 'tblTipoCambio')
BEGIN
    SET IDENTITY_INSERT [dbo].[tblTipoCambio] ON 

    -- Verificar y hacer INSERT si no existe el registro con Id = 1
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblTipoCambio] WHERE [Id] = 1)
    BEGIN
        INSERT INTO [dbo].[tblTipoCambio] ([Id], [fk_Id_DivisaCotizada], [CompraColones], [VentaColones], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES (1, 2, CAST(630 AS Decimal(18, 0)), CAST(645 AS Decimal(18, 0)), 1, CURRENT_TIMESTAMP, NULL);
    END

    -- Verificar y hacer INSERT si no existe el registro con Id = 2
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblTipoCambio] WHERE [Id] = 2)
    BEGIN
        INSERT INTO [dbo].[tblTipoCambio] ([Id], [fk_Id_DivisaCotizada], [CompraColones], [VentaColones], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES (2, 3, CAST(720 AS Decimal(18, 0)), CAST(810 AS Decimal(18, 0)), 1, CURRENT_TIMESTAMP, NULL);
    END

    SET IDENTITY_INSERT [dbo].[tblTipoCambio] OFF 
END
GO
---------------------------------------------------------------
--- I N S E R T		T I P O   C O M U N I C A D O
---------------------------------------------------------------
IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = 'dbo' AND TABLE_NAME = 'tblTipoComunicado')
BEGIN
    SET IDENTITY_INSERT [dbo].[tblTipoComunicado] ON 

    -- Verificar y hacer INSERT si no existen los registros con Id = 1, 2 o 3
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblTipoComunicado] WHERE [Id] = 1)
    BEGIN
        INSERT INTO [dbo].[tblTipoComunicado] ([Id], [Nombre], [Imagen], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES (1, N'Informativo', N'#1075BB', 1, CURRENT_TIMESTAMP, NULL);
    END

    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblTipoComunicado] WHERE [Id] = 2)
    BEGIN
        INSERT INTO [dbo].[tblTipoComunicado] ([Id], [Nombre], [Imagen], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES (2, N'Correctivo', N'#E4002B', 1, CURRENT_TIMESTAMP, NULL);
    END

    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblTipoComunicado] WHERE [Id] = 3)
    BEGIN
        INSERT INTO [dbo].[tblTipoComunicado] ([Id], [Nombre], [Imagen], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES (3, N'Advertencia', N'#F5881F', 1, CURRENT_TIMESTAMP, NULL);
    END

    SET IDENTITY_INSERT [dbo].[tblTipoComunicado] OFF
END
GO
---------------------------------------------------------------
--- I N S E R T		P R O V I N C I A
---------------------------------------------------------------
IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = 'dbo' AND TABLE_NAME = 'tblProvincia')
BEGIN
    -- Verificar y hacer INSERT si no existen los registros con los Id correspondientes
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblProvincia] WHERE [Id] = 1)
    BEGIN
        INSERT INTO [dbo].[tblProvincia] ([Id], [Nombre], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES (1, N'SAN JOSE', 1, CURRENT_TIMESTAMP, NULL);
    END

    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblProvincia] WHERE [Id] = 2)
    BEGIN
        INSERT INTO [dbo].[tblProvincia] ([Id], [Nombre], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES (2, N'ALAJUELA', 1, CURRENT_TIMESTAMP, NULL);
    END

    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblProvincia] WHERE [Id] = 3)
    BEGIN
        INSERT INTO [dbo].[tblProvincia] ([Id], [Nombre], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES (3, N'CARTAGO', 1, CURRENT_TIMESTAMP, NULL);
    END

    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblProvincia] WHERE [Id] = 4)
    BEGIN
        INSERT INTO [dbo].[tblProvincia] ([Id], [Nombre], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES (4, N'HEREDIA', 1, CURRENT_TIMESTAMP, NULL);
    END

    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblProvincia] WHERE [Id] = 5)
    BEGIN
        INSERT INTO [dbo].[tblProvincia] ([Id], [Nombre], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES (5, N'GUANACASTE', 1, CURRENT_TIMESTAMP, NULL);
    END

    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblProvincia] WHERE [Id] = 6)
    BEGIN
        INSERT INTO [dbo].[tblProvincia] ([Id], [Nombre], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES (6, N'PUNTARENAS', 1, CURRENT_TIMESTAMP, NULL);
    END

    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblProvincia] WHERE [Id] = 7)
    BEGIN
        INSERT INTO [dbo].[tblProvincia] ([Id], [Nombre], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES (7, N'LIMON', 1, CURRENT_TIMESTAMP, NULL);
    END
END
GO
---------------------------------------------------------------
--- I N S E R T		C A N T O N
---------------------------------------------------------------
IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = 'dbo' AND TABLE_NAME = 'tblCanton')
BEGIN
    -- Verificar y hacer INSERT si no existen los registros con los Id correspondientes

    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblCanton] WHERE [Id] = 101)
    BEGIN
        INSERT INTO [dbo].[tblCanton] ([Id], [Nombre], [fk_Id_Provincia], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES (101, N'SAN JOSE', 1, 1, CURRENT_TIMESTAMP, NULL);
    END

    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblCanton] WHERE [Id] = 102)
    BEGIN
        INSERT INTO [dbo].[tblCanton] ([Id], [Nombre], [fk_Id_Provincia], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES (102, N'ESCAZU', 1, 1, CURRENT_TIMESTAMP, NULL);
    END

    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblCanton] WHERE [Id] = 103)
    BEGIN
        INSERT INTO [dbo].[tblCanton] ([Id], [Nombre], [fk_Id_Provincia], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES (103, N'DESAMPARADOS', 1, 1, CURRENT_TIMESTAMP, NULL);
    END

    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblCanton] WHERE [Id] = 104)
    BEGIN
        INSERT INTO [dbo].[tblCanton] ([Id], [Nombre], [fk_Id_Provincia], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES (104, N'PURISCAL', 1, 1, CURRENT_TIMESTAMP, NULL);
    END

    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblCanton] WHERE [Id] = 105)
    BEGIN
        INSERT INTO [dbo].[tblCanton] ([Id], [Nombre], [fk_Id_Provincia], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES (105, N'TARRAZU', 1, 1, CURRENT_TIMESTAMP, NULL);
    END

    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblCanton] WHERE [Id] = 106)
    BEGIN
        INSERT INTO [dbo].[tblCanton] ([Id], [Nombre], [fk_Id_Provincia], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES (106, N'ASERRI', 1, 1, CURRENT_TIMESTAMP, NULL);
    END

    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblCanton] WHERE [Id] = 107)
    BEGIN
        INSERT INTO [dbo].[tblCanton] ([Id], [Nombre], [fk_Id_Provincia], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES (107, N'MORA', 1, 1, CURRENT_TIMESTAMP, NULL);
    END

    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblCanton] WHERE [Id] = 108)
    BEGIN
        INSERT INTO [dbo].[tblCanton] ([Id], [Nombre], [fk_Id_Provincia], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES (108, N'GOICOECHEA', 1, 1, CURRENT_TIMESTAMP, NULL);
    END

    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblCanton] WHERE [Id] = 109)
    BEGIN
        INSERT INTO [dbo].[tblCanton] ([Id], [Nombre], [fk_Id_Provincia], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES (109, N'SANTA ANA', 1, 1, CURRENT_TIMESTAMP, NULL);
    END

    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblCanton] WHERE [Id] = 110)
    BEGIN
        INSERT INTO [dbo].[tblCanton] ([Id], [Nombre], [fk_Id_Provincia], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES (110, N'ALAJUELITA', 1, 1, CURRENT_TIMESTAMP, NULL);
    END

    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblCanton] WHERE [Id] = 111)
    BEGIN
        INSERT INTO [dbo].[tblCanton] ([Id], [Nombre], [fk_Id_Provincia], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES (111, N'VAZQUEZ DE CORONADO', 1, 1, CURRENT_TIMESTAMP, NULL);
    END

    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblCanton] WHERE [Id] = 112)
    BEGIN
        INSERT INTO [dbo].[tblCanton] ([Id], [Nombre], [fk_Id_Provincia], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES (112, N'ACOSTA', 1, 1, CURRENT_TIMESTAMP, NULL);
    END

    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblCanton] WHERE [Id] = 113)
    BEGIN
        INSERT INTO [dbo].[tblCanton] ([Id], [Nombre], [fk_Id_Provincia], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES (113, N'TIBAS', 1, 1, CURRENT_TIMESTAMP, NULL);
    END

    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblCanton] WHERE [Id] = 114)
    BEGIN
        INSERT INTO [dbo].[tblCanton] ([Id], [Nombre], [fk_Id_Provincia], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES (114, N'MORAVIA', 1, 1, CURRENT_TIMESTAMP, NULL);
    END

    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblCanton] WHERE [Id] = 115)
    BEGIN
        INSERT INTO [dbo].[tblCanton] ([Id], [Nombre], [fk_Id_Provincia], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES (115, N'MONTES DE OCA', 1, 1, CURRENT_TIMESTAMP, NULL);
    END

    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblCanton] WHERE [Id] = 116)
    BEGIN
        INSERT INTO [dbo].[tblCanton] ([Id], [Nombre], [fk_Id_Provincia], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES (116, N'TURRUBARES', 1, 1, CURRENT_TIMESTAMP, NULL);
    END

    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblCanton] WHERE [Id] = 117)
    BEGIN
        INSERT INTO [dbo].[tblCanton] ([Id], [Nombre], [fk_Id_Provincia], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES (117, N'DOTA', 1, 1, CURRENT_TIMESTAMP, NULL);
    END

    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblCanton] WHERE [Id] = 118)
    BEGIN
        INSERT INTO [dbo].[tblCanton] ([Id], [Nombre], [fk_Id_Provincia], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES (118, N'CURRIDABAT', 1, 1, CURRENT_TIMESTAMP, NULL);
    END

    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblCanton] WHERE [Id] = 119)
    BEGIN
        INSERT INTO [dbo].[tblCanton] ([Id], [Nombre], [fk_Id_Provincia], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES (119, N'PEREZ ZELEDON', 1, 1, CURRENT_TIMESTAMP, NULL);
    END

    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblCanton] WHERE [Id] = 120)
    BEGIN
        INSERT INTO [dbo].[tblCanton] ([Id], [Nombre], [fk_Id_Provincia], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES (120, N'LEON CORTES', 1, 1, CURRENT_TIMESTAMP, NULL);
    END

    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblCanton] WHERE [Id] = 201)
    BEGIN
        INSERT INTO [dbo].[tblCanton] ([Id], [Nombre], [fk_Id_Provincia], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES (201, N'ALAJUELA', 2, 1, CURRENT_TIMESTAMP, NULL);
    END

    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblCanton] WHERE [Id] = 202)
    BEGIN
        INSERT INTO [dbo].[tblCanton] ([Id], [Nombre], [fk_Id_Provincia], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES (202, N'SAN RAMON', 2, 1, CURRENT_TIMESTAMP, NULL);
    END

    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblCanton] WHERE [Id] = 203)
    BEGIN
        INSERT INTO [dbo].[tblCanton] ([Id], [Nombre], [fk_Id_Provincia], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES (203, N'GRECIA', 2, 1, CURRENT_TIMESTAMP, NULL);
    END

    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblCanton] WHERE [Id] = 204)
    BEGIN
        INSERT INTO [dbo].[tblCanton] ([Id], [Nombre], [fk_Id_Provincia], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES (204, N'SAN MATEO', 2, 1, CURRENT_TIMESTAMP, NULL);
    END

    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblCanton] WHERE [Id] = 205)
    BEGIN
        INSERT INTO [dbo].[tblCanton] ([Id], [Nombre], [fk_Id_Provincia], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES (205, N'ATENAS', 2, 1, CURRENT_TIMESTAMP, NULL);
    END

    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblCanton] WHERE [Id] = 206)
    BEGIN
        INSERT INTO [dbo].[tblCanton] ([Id], [Nombre], [fk_Id_Provincia], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES (206, N'NARANJO', 2, 1, CURRENT_TIMESTAMP, NULL);
    END

    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblCanton] WHERE [Id] = 207)
    BEGIN
        INSERT INTO [dbo].[tblCanton] ([Id], [Nombre], [fk_Id_Provincia], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES (207, N'PALMARES', 2, 1, CURRENT_TIMESTAMP, NULL);
    END

    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblCanton] WHERE [Id] = 208)
    BEGIN
        INSERT INTO [dbo].[tblCanton] ([Id], [Nombre], [fk_Id_Provincia], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES (208, N'POAS', 2, 1, CURRENT_TIMESTAMP, NULL);
    END

    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblCanton] WHERE [Id] = 209)
    BEGIN
        INSERT INTO [dbo].[tblCanton] ([Id], [Nombre], [fk_Id_Provincia], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES (209, N'OROTINA', 2, 1, CURRENT_TIMESTAMP, NULL);
    END

    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblCanton] WHERE [Id] = 210)
    BEGIN
        INSERT INTO [dbo].[tblCanton] ([Id], [Nombre], [fk_Id_Provincia], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES (210, N'SAN CARLOS', 2, 1, CURRENT_TIMESTAMP, NULL);
    END

    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblCanton] WHERE [Id] = 211)
    BEGIN
        INSERT INTO [dbo].[tblCanton] ([Id], [Nombre], [fk_Id_Provincia], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES (211, N'ALFARO RUIZ', 2, 1, CURRENT_TIMESTAMP, NULL);
    END

    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblCanton] WHERE [Id] = 212)
    BEGIN
        INSERT INTO [dbo].[tblCanton] ([Id], [Nombre], [fk_Id_Provincia], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES (212, N'VALVERDE VEGA', 2, 1, CURRENT_TIMESTAMP, NULL);
    END

    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblCanton] WHERE [Id] = 213)
    BEGIN
        INSERT INTO [dbo].[tblCanton] ([Id], [Nombre], [fk_Id_Provincia], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES (213, N'UPALA', 2, 1, CURRENT_TIMESTAMP, NULL);
    END

    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblCanton] WHERE [Id] = 214)
    BEGIN
        INSERT INTO [dbo].[tblCanton] ([Id], [Nombre], [fk_Id_Provincia], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES (214, N'LOS CHILES', 2, 1, CURRENT_TIMESTAMP, NULL);
    END

    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblCanton] WHERE [Id] = 215)
    BEGIN
        INSERT INTO [dbo].[tblCanton] ([Id], [Nombre], [fk_Id_Provincia], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES (215, N'GUATUSO', 2, 1, CURRENT_TIMESTAMP, NULL);
    END

    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblCanton] WHERE [Id] = 301)
    BEGIN
        INSERT INTO [dbo].[tblCanton] ([Id], [Nombre], [fk_Id_Provincia], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES (301, N'CARTAGO', 3, 1, CURRENT_TIMESTAMP, NULL);
    END

    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblCanton] WHERE [Id] = 302)
    BEGIN
        INSERT INTO [dbo].[tblCanton] ([Id], [Nombre], [fk_Id_Provincia], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES (302, N'PARAISO', 3, 1, CURRENT_TIMESTAMP, NULL);
    END

    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblCanton] WHERE [Id] = 303)
    BEGIN
        INSERT INTO [dbo].[tblCanton] ([Id], [Nombre], [fk_Id_Provincia], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES (303, N'LA UNION', 3, 1, CURRENT_TIMESTAMP, NULL);
    END

    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblCanton] WHERE [Id] = 304)
    BEGIN
        INSERT INTO [dbo].[tblCanton] ([Id], [Nombre], [fk_Id_Provincia], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES (304, N'SANTA ROSA', 3, 1, CURRENT_TIMESTAMP, NULL);
    END

    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblCanton] WHERE [Id] = 305)
    BEGIN
        INSERT INTO [dbo].[tblCanton] ([Id], [Nombre], [fk_Id_Provincia], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES (305, N'TURRIALBA', 3, 1, CURRENT_TIMESTAMP, NULL);
    END

    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblCanton] WHERE [Id] = 306)
    BEGIN
        INSERT [dbo].[tblCanton] ([Id], [Nombre], [fk_Id_Provincia], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES (306, N'ALVARADO', 3, 1, CURRENT_TIMESTAMP, NULL);
    END

    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblCanton] WHERE [Id] = 307)
    BEGIN
        INSERT [dbo].[tblCanton] ([Id], [Nombre], [fk_Id_Provincia], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES (307, N'OREAMUNO', 3, 1, CURRENT_TIMESTAMP, NULL);
    END

    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblCanton] WHERE [Id] = 308)
    BEGIN
        INSERT [dbo].[tblCanton] ([Id], [Nombre], [fk_Id_Provincia], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES (308, N'EL GUARCO', 3, 1, CURRENT_TIMESTAMP, NULL);
    END

    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblCanton] WHERE [Id] = 401)
    BEGIN
        INSERT [dbo].[tblCanton] ([Id], [Nombre], [fk_Id_Provincia], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES (401, N'HEREDIA', 4, 1, CURRENT_TIMESTAMP, NULL);
    END

    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblCanton] WHERE [Id] = 402)
    BEGIN
        INSERT [dbo].[tblCanton] ([Id], [Nombre], [fk_Id_Provincia], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES (402, N'BARVA', 4, 1, CURRENT_TIMESTAMP, NULL);
    END

    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblCanton] WHERE [Id] = 403)
    BEGIN
        INSERT [dbo].[tblCanton] ([Id], [Nombre], [fk_Id_Provincia], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES (403, N'SANTO DOMINGO', 4, 1, CURRENT_TIMESTAMP, NULL);
    END

    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblCanton] WHERE [Id] = 404)
    BEGIN
        INSERT [dbo].[tblCanton] ([Id], [Nombre], [fk_Id_Provincia], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES (404, N'SANTA BARBARA', 4, 1, CURRENT_TIMESTAMP, NULL);
    END

    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblCanton] WHERE [Id] = 405)
    BEGIN
        INSERT [dbo].[tblCanton] ([Id], [Nombre], [fk_Id_Provincia], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES (405, N'SAN RAFAEL', 4, 1, CURRENT_TIMESTAMP, NULL);
    END

    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblCanton] WHERE [Id] = 406)
    BEGIN
        INSERT [dbo].[tblCanton] ([Id], [Nombre], [fk_Id_Provincia], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES (406, N'SAN ISIDRO', 4, 1, CURRENT_TIMESTAMP, NULL);
    END

    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblCanton] WHERE [Id] = 407)
    BEGIN
        INSERT [dbo].[tblCanton] ([Id], [Nombre], [fk_Id_Provincia], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES (407, N'BELEN', 4, 1, CURRENT_TIMESTAMP, NULL);
    END

    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblCanton] WHERE [Id] = 408)
    BEGIN
        INSERT [dbo].[tblCanton] ([Id], [Nombre], [fk_Id_Provincia], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES (408, N'FLORES', 4, 1, CURRENT_TIMESTAMP, NULL);
    END

    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblCanton] WHERE [Id] = 409)
    BEGIN
        INSERT [dbo].[tblCanton] ([Id], [Nombre], [fk_Id_Provincia], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES (409, N'SAN PABLO', 4, 1, CURRENT_TIMESTAMP, NULL);
    END

    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblCanton] WHERE [Id] = 410)
    BEGIN
        INSERT [dbo].[tblCanton] ([Id], [Nombre], [fk_Id_Provincia], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES (410, N'SARAPIQUI', 4, 1, CURRENT_TIMESTAMP, NULL);
    END

    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblCanton] WHERE [Id] = 501)
    BEGIN
        INSERT [dbo].[tblCanton] ([Id], [Nombre], [fk_Id_Provincia], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES (501, N'LIBERIA', 5, 1, CURRENT_TIMESTAMP, NULL);
    END

    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblCanton] WHERE [Id] = 502)
    BEGIN
        INSERT [dbo].[tblCanton] ([Id], [Nombre], [fk_Id_Provincia], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES (502, N'NICOYA', 5, 1, CURRENT_TIMESTAMP, NULL);
    END

    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblCanton] WHERE [Id] = 503)
    BEGIN
        INSERT [dbo].[tblCanton] ([Id], [Nombre], [fk_Id_Provincia], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES (503, N'SANTA CRUZ', 5, 1, CURRENT_TIMESTAMP, NULL);
    END

    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblCanton] WHERE [Id] = 504)
    BEGIN
        INSERT [dbo].[tblCanton] ([Id], [Nombre], [fk_Id_Provincia], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES (504, N'BAGACES', 5, 1, CURRENT_TIMESTAMP, NULL);
    END

    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblCanton] WHERE [Id] = 505)
    BEGIN
        INSERT [dbo].[tblCanton] ([Id], [Nombre], [fk_Id_Provincia], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES (505, N'CARRILLO', 5, 1, CURRENT_TIMESTAMP, NULL);
    END

    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblCanton] WHERE [Id] = 506)
    BEGIN
        INSERT [dbo].[tblCanton] ([Id], [Nombre], [fk_Id_Provincia], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES (506, N'CA#AS', 5, 1, CURRENT_TIMESTAMP, NULL);
    END

    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblCanton] WHERE [Id] = 507)
    BEGIN
        INSERT [dbo].[tblCanton] ([Id], [Nombre], [fk_Id_Provincia], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES (507, N'ABANGARES', 5, 1, CURRENT_TIMESTAMP, NULL);
    END

    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblCanton] WHERE [Id] = 508)
    BEGIN
        INSERT [dbo].[tblCanton] ([Id], [Nombre], [fk_Id_Provincia], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES (508, N'TILARAN', 5, 1, CURRENT_TIMESTAMP, NULL)
    END

    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblCanton] WHERE [Id] = 509)
    BEGIN
        INSERT [dbo].[tblCanton] ([Id], [Nombre], [fk_Id_Provincia], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES (509, N'NANDAYURE', 5, 1, CURRENT_TIMESTAMP, NULL)
    END

    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblCanton] WHERE [Id] = 510)
    BEGIN
        INSERT [dbo].[tblCanton] ([Id], [Nombre], [fk_Id_Provincia], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES (510, N'LA CRUZ', 5, 1, CURRENT_TIMESTAMP, NULL)
    END

    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblCanton] WHERE [Id] = 511)
    BEGIN
        INSERT [dbo].[tblCanton] ([Id], [Nombre], [fk_Id_Provincia], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES (511, N'HOJANCHA', 5, 1, CURRENT_TIMESTAMP, NULL)
    END

    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblCanton] WHERE [Id] = 601)
    BEGIN
        INSERT [dbo].[tblCanton] ([Id], [Nombre], [fk_Id_Provincia], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES (601, N'PUNTARENAS', 6, 1, CURRENT_TIMESTAMP, NULL)
    END

    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblCanton] WHERE [Id] = 602)
    BEGIN
        INSERT [dbo].[tblCanton] ([Id], [Nombre], [fk_Id_Provincia], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES (602, N'ESPARZA', 6, 1, CURRENT_TIMESTAMP, NULL)
    END

    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblCanton] WHERE [Id] = 603)
    BEGIN
        INSERT [dbo].[tblCanton] ([Id], [Nombre], [fk_Id_Provincia], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES (603, N'BUENOS AIRES', 6, 1, CURRENT_TIMESTAMP, NULL)
    END

    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblCanton] WHERE [Id] = 604)
    BEGIN
        INSERT [dbo].[tblCanton] ([Id], [Nombre], [fk_Id_Provincia], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES (604, N'MONTES DE ORO', 6, 1, CURRENT_TIMESTAMP, NULL)
    END

    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblCanton] WHERE [Id] = 605)
    BEGIN
        INSERT [dbo].[tblCanton] ([Id], [Nombre], [fk_Id_Provincia], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES (605, N'OSA', 6, 1, CURRENT_TIMESTAMP, NULL)
    END

    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblCanton] WHERE [Id] = 606)
    BEGIN
        INSERT [dbo].[tblCanton] ([Id], [Nombre], [fk_Id_Provincia], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES (606, N'AGUIRRE', 6, 1, CURRENT_TIMESTAMP, NULL)
    END

    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblCanton] WHERE [Id] = 607)
    BEGIN
        INSERT [dbo].[tblCanton] ([Id], [Nombre], [fk_Id_Provincia], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES (607, N'GOLFITO', 6, 1, CURRENT_TIMESTAMP, NULL)
    END

    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblCanton] WHERE [Id] = 608)
    BEGIN
        INSERT [dbo].[tblCanton] ([Id], [Nombre], [fk_Id_Provincia], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES (608, N'COTO BRUS', 6, 1, CURRENT_TIMESTAMP, NULL)
    END

    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblCanton] WHERE [Id] = 609)
    BEGIN
        INSERT [dbo].[tblCanton] ([Id], [Nombre], [fk_Id_Provincia], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES (609, N'PARRITA', 6, 1, CURRENT_TIMESTAMP, NULL)
    END

    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblCanton] WHERE [Id] = 610)
    BEGIN
        INSERT [dbo].[tblCanton] ([Id], [Nombre], [fk_Id_Provincia], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES (610, N'CORREDORES', 6, 1, CURRENT_TIMESTAMP, NULL)
    END

    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblCanton] WHERE [Id] = 611)
    BEGIN
        INSERT [dbo].[tblCanton] ([Id], [Nombre], [fk_Id_Provincia], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES (611, N'GARABITO', 6, 1, CURRENT_TIMESTAMP, NULL)
    END

    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblCanton] WHERE [Id] = 701)
    BEGIN
        INSERT [dbo].[tblCanton] ([Id], [Nombre], [fk_Id_Provincia], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES (701, N'LIMON', 7, 1, CURRENT_TIMESTAMP, NULL)
    END

    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblCanton] WHERE [Id] = 702)
    BEGIN
        INSERT [dbo].[tblCanton] ([Id], [Nombre], [fk_Id_Provincia], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES (702, N'POCOCI', 7, 1, CURRENT_TIMESTAMP, NULL)
    END

    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblCanton] WHERE [Id] = 703)
    BEGIN
        INSERT [dbo].[tblCanton] ([Id], [Nombre], [fk_Id_Provincia], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES (703, N'SIQUIRRES', 7, 1, CURRENT_TIMESTAMP, NULL)
    END

    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblCanton] WHERE [Id] = 704)
    BEGIN
        INSERT [dbo].[tblCanton] ([Id], [Nombre], [fk_Id_Provincia], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES (704, N'TALAMANCA', 7, 1, CURRENT_TIMESTAMP, NULL)
    END

    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblCanton] WHERE [Id] = 705)
    BEGIN
        INSERT [dbo].[tblCanton] ([Id], [Nombre], [fk_Id_Provincia], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES (705, N'MATINA', 7, 1, CURRENT_TIMESTAMP, NULL)
    END

    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblCanton] WHERE [Id] = 706)
    BEGIN
        INSERT [dbo].[tblCanton] ([Id], [Nombre], [fk_Id_Provincia], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES (706, N'GUACIMO', 7, 1, CURRENT_TIMESTAMP, NULL)
    END

END
GO
---------------------------------------------------------------
--- I N S E R T		D I S T R I T O
---------------------------------------------------------------
DECLARE @DISTRITO1 VARCHAR(20) = 'SAN ANTONIO';
DECLARE @DISTRITO2 VARCHAR(20) = 'SAN RAFAEL';
DECLARE @DISTRITO3 VARCHAR(20) = 'SAN MIGUEL';
DECLARE @DISTRITO4 VARCHAR(20) = 'SANTIAGO';
DECLARE @DISTRITO5 VARCHAR(20) = 'CONCEPCION';
DECLARE @DISTRITO6 VARCHAR(20) = 'SAN ISIDRO';
DECLARE @DISTRITO7 VARCHAR(20) = 'SAN JUAN';
DECLARE @DISTRITO8 VARCHAR(20) = 'SAN PEDRO';
DECLARE @DISTRITO9 VARCHAR(20) = 'MERCEDES';
DECLARE @DISTRITO10 VARCHAR(20) = 'SAN PABLO';
DECLARE @DISTRITO11 VARCHAR(20) = 'SAN JOSE';
DECLARE @DISTRITO12 VARCHAR(20) = 'SANTA ROSA';



--******************************************************************************************
--- T A B L A	>>	 [ D B O . T B L D I S T R I T O ]
--******************************************************************************************
IF EXISTS(SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA  = 'dbo' AND TABLE_NAME = 'tblDistrito') BEGIN
    
    
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 10101) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(10101, 'CARMEN', 101, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 10102) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(10102, 'MERCED', 101, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 10103) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(10103, 'HOSPITAL', 101, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 10104) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(10104, 'CATEDRAL', 101, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 10105) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(10105, 'ZAPOTE', 101, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 10106) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(10106, 'SAN FRANCISCO DE DOS RIOS', 101, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 10107) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(10107, 'URUCA', 101, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 10108) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(10108, 'MATA REDONDA', 101, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 10109) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(10109, 'PAVAS', 101, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 10110) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(10110, 'HATILLO', 101, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 10111) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(10111, 'SAN SEBASTIAN', 101, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 10201) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(10201, 'ESCAZU', 102, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 10202) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(10202, @DISTRITO1, 102, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 10203) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(10203, @DISTRITO2, 102, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 10301) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(10301, 'DESAMPARADOS', 103, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 10302) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(10302, @DISTRITO3, 103, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 10303) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(10303, 'SAN JUAN DE DIOS', 103, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 10304) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(10304, 'SAN RAFAEL ARRIBA', 103, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 10305) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(10305, @DISTRITO1, 103, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 10306) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(10306, 'FRAILES', 103, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 10307) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(10307, 'PATARRA', 103, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 10308) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(10308, 'SAN CRISTOBAL', 103, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 10309) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(10309, 'ROSARIO', 103, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 10310) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(10310, 'DAMAS', 103, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 10311) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(10311, 'SAN RAFAEL ABAJO', 103, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 10312) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(10312, 'GRAVILIAS', 103, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 10313) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(10313, 'LOS GUIDO', 103, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 10401) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(10401, @DISTRITO4, 104, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 10402) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(10402, 'MERCEDES SUR', 104, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 10403) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(10403, 'BARBACOAS', 104, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 10404) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(10404, 'GRIFO ALTO', 104, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 10405) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(10405, @DISTRITO2, 104, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 10406) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(10406, 'CANDELARITA', 104, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 10407) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(10407, 'DESAMPARADITOS', 104, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 10408) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(10408, @DISTRITO1, 104, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 10409) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(10409, 'CHIRES', 104, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 10501) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(10501, 'SAN MARCOS', 105, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 10502) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(10502, 'SAN LORENZO', 105, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 10503) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(10503, 'SAN CARLOS', 105, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 10601) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(10601, 'ASERRI', 106, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 10602) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(10602, 'TARBACA', 106, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 10603) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(10603, 'VUELTA DE JORCO', 106, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 10604) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(10604, 'SAN GABRIEL', 106, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 10605) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(10605, 'LEGUA', 106, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 10606) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(10606, 'MONTERREY', 106, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 10607) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(10607, 'SALITRILLOS', 106, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 10701) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(10701, 'CIUDAD COLON', 107, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 10702) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(10702, 'GUAYABO', 107, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 10703) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(10703, 'TABARCIA', 107, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 10704) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(10704, 'PIEDRAS NEGRAS', 107, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 10705) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(10705, 'PICAGRES', 107, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 10801) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(10801, 'GUADALUPE', 108, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 10802) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(10802, 'SAN FRANCISCO', 108, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 10803) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(10803, 'CALLE BLANCOS', 108, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 10804) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(10804, 'MATA DE PLATANO', 108, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 10805) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(10805, 'IPIS', 108, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 10806) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(10806, 'RANCHO REDONDO', 108, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 10807) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(10807, 'PURRAL', 108, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 10901) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(10901, 'SANTA ANA', 109, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 10902) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(10902, 'SALITRAL', 109, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 10903) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(10903, 'POZOS', 109, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 10904) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(10904, 'URUCA', 109, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 10905) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(10905, 'PIEDADES', 109, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 10906) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(10906, 'BRASIL', 109, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 11001) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(11001, 'ALAJUELITA', 110, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 11002) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(11002, 'SAN JOSECITO', 110, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 11003) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(11003, @DISTRITO1, 110, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 11004) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(11004, @DISTRITO5, 110, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 11005) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(11005, 'SAN FELIPE', 110, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 11006) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(11006, 'BRASIL', 110, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 11101) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(11101, @DISTRITO6, 111, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 11102) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(11102, @DISTRITO2, 111, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 11103) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(11103, 'DULCE NOMBRE', 111, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 11104) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(11104, 'PATALILLO', 111, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 11105) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(11105, 'CASCAJAL', 111, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 11201) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(11201, 'SAN IGNASIO', 112, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 11202) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(11202, 'GUAITIL', 112, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 11203) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(11203, 'PALMICHAL', 112, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 11204) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(11204, 'CANGREJAL', 112, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 11205) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(11205, 'SABANILLAS', 112, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 11301) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(11301, @DISTRITO7, 113, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 11302) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(11302, 'CINCO ESQUINAS', 113, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 11303) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(11303, 'ANSELMO LLORENTE', 113, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 11304) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(11304, 'LEON 13', 113, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 11305) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(11305, 'COLIMA', 113, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 11401) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(11401, 'SAN VICENTE', 114, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 11402) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(11402, 'SAN JERONIMO', 114, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 11403) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(11403, 'LA TRINIDAD', 114, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 11501) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(11501, @DISTRITO8, 115, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 11502) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(11502, 'SABANILLA', 115, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 11503) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(11503, @DISTRITO9, 115, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 11504) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(11504, @DISTRITO2, 115, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 11601) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(11601, @DISTRITO10, 116, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 11602) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(11602, @DISTRITO8, 116, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 11603) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(11603, 'SAN JUAN DE MATA', 116, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 11604) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(11604, 'SAN LUIS', 116, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 11605) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(11605, 'CARARA', 116, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 11701) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(11701, 'SANTA MARIA', 117, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 11702) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(11702, 'JARDIN', 117, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 11703) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(11703, 'COPEY', 117, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 11801) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(11801, 'CURRIDABAT', 118, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 11802) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(11802, 'GRANADILLA', 118, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 11803) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(11803, 'SANCHEZ', 118, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 11804) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(11804, 'TIRRASES', 118, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 11901) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(11901, 'SAN ISIDRO DEL GENERAL', 119, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 11902) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(11902, 'GENERAL', 119, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 11903) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(11903, 'DANIEL FLORES', 119, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 11904) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(11904, 'RIVAS', 119, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 11905) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(11905, @DISTRITO8, 119, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 11906) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(11906, 'PLATANARES', 119, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 11907) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(11907, 'PEJIBAYE', 119, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 11908) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(11908, 'CAJON', 119, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 11909) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(11909, 'BARU', 119, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 11910) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(11910, 'RIO NUEVO', 119, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 11911) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(11911, 'PARAMO', 119, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 12001) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(12001, @DISTRITO10, 120, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 12002) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(12002, 'SAN ANDRES', 120, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 12003) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(12003, 'LLANO BONITO', 120, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 12004) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(12004, @DISTRITO6, 120, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 12005) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(12005, 'SANTA CRUZ', 120, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 12006) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(12006, @DISTRITO1, 120, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 20101) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(20101, 'ALAJUELA', 201, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 20102) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(20102, 'BARRIO SAN JOSE', 201, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 20103) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(20103, 'CARRIZAL', 201, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 20104) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(20104, @DISTRITO1, 201, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 20105) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(20105, 'GUACIMA', 201, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 20106) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(20106, @DISTRITO6, 201, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 20107) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(20107, 'SABANILLA', 201, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 20108) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(20108, @DISTRITO2, 201, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 20109) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(20109, 'RIO SEGUNDO', 201, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 20110) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(20110, 'DESAMPARADOS', 201, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 20111) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(20111, 'TURRUCARES', 201, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 20112) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(20112, 'TAMBOR', 201, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 20113) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(20113, 'GARITA', 201, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 20114) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(20114, 'SARAPIQUI', 201, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 20201) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(20201, 'SAN RAMON', 202, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 20202) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(20202, @DISTRITO4, 202, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 20203) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(20203, @DISTRITO7, 202, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 20204) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(20204, 'PIEDADES NORTE', 202, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 20205) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(20205, 'PIEDADES SUR', 202, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 20206) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(20206, @DISTRITO2, 202, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 20207) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(20207, @DISTRITO6, 202, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 20208) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(20208, 'ANGELES', 202, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 20209) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(20209, 'ALFARO', 202, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 20210) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(20210, 'VOLIO', 202, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 20211) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(20211, @DISTRITO5, 202, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 20212) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(20212, 'ZAPOTAL', 202, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 20213) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(20213, 'PEÑAS BLANCAS', 202, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 20301) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(20301, 'GRECIA', 203, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 20302) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(20302, @DISTRITO6, 203, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 20303) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(20303, @DISTRITO11, 203, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 20304) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(20304, 'SAN ROQUE', 203, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 20305) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(20305, 'TACARES', 203, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 20306) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(20306, 'RIO CUARTO', 203, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 20307) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(20307, 'PUENTE DE PIEDRA', 203, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 20308) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(20308, 'BOLIVAR', 203, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 20401) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(20401, 'SAN MATEO', 204, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 20402) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(20402, 'DESMONTE', 204, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 20403) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(20403, 'JESUS MARIA', 204, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 20501) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(20501, 'ATENAS', 205, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 20502) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(20502, 'JESUS', 205, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 20503) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(20503, @DISTRITO9, 205, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 20504) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(20504, @DISTRITO6, 205, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 20505) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(20505, @DISTRITO5, 205, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 20506) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(20506, @DISTRITO11, 205, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 20507) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(20507, 'SANTA EULALIA', 205, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 20601) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(20601, 'NARANJO', 206, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 20602) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(20602, @DISTRITO3, 206, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 20603) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(20603, @DISTRITO11, 206, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 20604) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(20604, 'CIRRI SURR', 206, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 20605) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(20605, 'SAN JERONIMO', 206, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 20606) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(20606, @DISTRITO7, 206, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 20607) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(20607, 'ROSARIO', 206, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 20701) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(20701, 'PALMARES', 207, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 20702) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(20702, 'ZARAGOZA', 207, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 20703) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(20703, 'BUENOS AIRES', 207, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 20704) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(20704, @DISTRITO4, 207, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 20705) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(20705, 'CANDELARIA', 207, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 20706) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(20706, 'ESQUIPULAS', 207, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 20707) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(20707, 'GRANJA', 207, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 20801) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(20801, @DISTRITO8, 208, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 20802) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(20802, @DISTRITO7, 208, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 20803) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(20803, @DISTRITO2, 208, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 20804) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(20804, 'CARRILLOS', 208, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 20805) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(20805, 'SABANA REDONDA', 208, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 20901) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(20901, 'OROTINA', 209, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 20902) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(20902, 'MASTATE', 209, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 20903) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(20903, 'HACIENDA VIEJA', 209, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 20904) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(20904, 'COYOLAR', 209, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 20905) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(20905, 'CEIBA', 209, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 21001) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(21001, 'CIUDAD QUESADA', 210, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 21002) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(21002, 'FLORENCIA', 210, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 21003) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(21003, 'BUENA VISTA', 210, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 21004) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(21004, 'AGUAS ZARCAS', 210, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 21005) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(21005, 'VENECIA', 210, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 21006) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(21006, 'PITAL', 210, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 21007) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(21007, 'FORTUNA', 210, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 21008) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(21008, 'TIGRA', 210, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 21009) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(21009, 'PALMERA', 210, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 21010) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(21010, 'VENADO', 210, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 21011) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(21011, 'CUTRIS', 210, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 21012) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(21012, 'MONTERREY', 210, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 21013) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(21013, 'POCOSOL', 210, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 21101) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(21101, 'ZARCERO', 211, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 21102) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(21102, 'LAGUNA', 211, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 21103) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(21103, 'TAPEZCO', 211, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 21104) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(21104, 'GUADALUPE', 211, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 21105) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(21105, 'PALMIRA', 211, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 21106) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(21106, 'ZAPOTE', 211, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 21107) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(21107, 'BRISA', 211, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 21201) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(21201, 'SARCHI NORTE', 212, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 21202) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(21202, 'SARCHI SUR', 212, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 21203) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(21203, 'TORO AMARILLO', 212, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 21204) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(21204, @DISTRITO8, 212, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 21205) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(21205, 'RODRIGUEZ', 212, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 21301) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(21301, 'AGUAS CLARAS', 213, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 21302) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(21302, 'SAN JOSE O PIZOTE', 213, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 21303) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(21303, 'BIJAGUA', 213, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 21304) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(21304, 'DELICIAS', 213, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 21305) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(21305, 'DOS RIOS', 213, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 21306) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(21306, 'YOLILLAL', 213, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 21307) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(21307, 'UPALA', 213, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 21401) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(21401, 'LOS CHILES', 214, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 21402) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(21402, 'CAÐO NEGRO', 214, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 21403) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(21403, 'EL AMPARO', 214, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 21404) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(21404, 'SAN JORGE', 214, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 21501) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(21501, @DISTRITO2, 215, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 21502) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(21502, 'BUENA VISTA', 215, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 21503) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(21503, 'COTE', 215, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 21504) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(21504, 'KATIRA', 215, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 30101) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(30101, 'ORIENTAL', 301, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 30102) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(30102, 'OCCIDENTAL', 301, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 30103) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(30103, 'CARMEN', 301, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 30104) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(30104, 'SAN NICOLAS', 301, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 30105) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(30105, 'AGUACALIENTE ( SAN FRANCISCO)', 301, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 30106) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(30106, 'GUADALUPE O ARENILLA', 301, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 30107) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(30107, 'CORRALILLO', 301, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 30108) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(30108, 'TIERRA BLANCA', 301, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 30109) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(30109, 'DULCE NOMBRE', 301, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 30110) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(30110, 'LLANO GRANDE', 301, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 30111) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(30111, 'QUEBRADILLA', 301, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 30201) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(30201, 'PARAISO', 302, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 30202) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(30202, @DISTRITO4, 302, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 30203) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(30203, 'OROSI', 302, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 30204) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(30204, 'CACHI', 302, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 30301) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(30301, 'TRES RIOS', 303, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 30302) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(30302, 'SAN DIEGO', 303, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 30303) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(30303, @DISTRITO7, 303, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 30304) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(30304, @DISTRITO2, 303, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 30305) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(30305, @DISTRITO5, 303, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 30306) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(30306, 'DULCE NOMBRE', 303, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 30307) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(30307, 'SAN RAMON', 303, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 30308) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(30308, 'RIO AZUL', 303, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 30401) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(30401, 'JUAN VIÑAS', 304, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 30402) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(30402, 'TUCURRIQUE', 304, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 30403) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(30403, 'PEJIBAYE', 304, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 30501) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(30501, 'TURRIALBA', 305, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 30502) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(30502, 'LA SUIZA', 305, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 30503) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(30503, 'PERALTA', 305, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 30504) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(30504, 'SANTA CRUZ', 305, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 30505) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(30505, 'SANTA TERESITA', 305, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 30506) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(30506, 'PAVONES', 305, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 30507) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(30507, 'TUIS', 305, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 30508) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(30508, 'TAYUTIC', 305, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 30509) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(30509, @DISTRITO12, 305, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 30510) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(30510, 'TRES EQUIS', 305, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 30511) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(30511, 'LA ISABEL', 305, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 30512) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(30512, 'CHIRRIPO', 305, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 30601) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(30601, 'PACAYAS', 306, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 30602) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(30602, 'CERVANTES', 306, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 30603) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(30603, 'CAPELLADES', 306, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 30701) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(30701, @DISTRITO2, 307, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 30702) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(30702, 'COT', 307, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 30703) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(30703, 'POTRERO CERRADO', 307, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 30704) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(30704, 'CIPRESES', 307, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 30705) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(30705, @DISTRITO12, 307, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 30801) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(30801, 'TEJAR', 308, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 30802) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(30802, @DISTRITO6, 308, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 30803) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(30803, 'TOBOSI', 308, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 30804) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(30804, 'PATIO DE AGUA', 308, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 40101) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(40101, 'HEREDIA', 401, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 40102) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(40102, @DISTRITO9, 401, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 40103) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(40103, 'SAN FRANCISCO', 401, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 40104) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(40104, 'ULLOA', 401, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 40105) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(40105, 'VARABLANCA', 401, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 40201) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(40201, 'BARVA', 402, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 40202) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(40202, @DISTRITO8, 402, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 40203) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(40203, @DISTRITO10, 402, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 40204) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(40204, 'SAN ROQUE', 402, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 40205) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(40205, 'SANTA LUCIA', 402, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 40206) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(40206, 'SAN JOSE DE LA MONTAÑA', 402, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 40301) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(40301, 'SANTO DOMINGO', 403, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 40302) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(40302, 'SAN VICENTE', 403, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 40303) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(40303, @DISTRITO3, 403, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 40304) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(40304, 'PARACITO', 403, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 40305) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(40305, 'SANTO TOMAS', 403, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 40306) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(40306, @DISTRITO12, 403, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 40307) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(40307, 'TURES', 403, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 40308) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(40308, 'PARA', 403, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 40401) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(40401, 'SANTA BARBARA', 404, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 40402) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(40402, @DISTRITO8, 404, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 40403) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(40403, @DISTRITO7, 404, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 40404) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(40404, 'JESUS', 404, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 40405) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(40405, 'SANTO DOMINGO', 404, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 40406) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(40406, 'PURABA', 404, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 40501) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(40501, @DISTRITO2, 405, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 40502) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(40502, 'SAN JOSECITO', 405, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 40503) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(40503, @DISTRITO4, 405, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 40504) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(40504, 'ANGELES', 405, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 40505) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(40505, @DISTRITO5, 405, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 40601) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(40601, @DISTRITO6, 406, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 40602) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(40602, @DISTRITO11, 406, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 40603) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(40603, @DISTRITO5, 406, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 40701) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(40701, @DISTRITO1, 407, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 40702) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(40702, 'RIVERA', 407, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 40703) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(40703, 'ASUNCION', 407, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 40801) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(40801, 'SAN JOAQUIN', 408, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 40802) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(40802, 'BARRANTES', 408, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 40803) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(40803, 'LLORENTE', 408, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 40901) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(40901, @DISTRITO10, 409, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 41001) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(41001, 'PUERTO VIEJO', 410, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 41002) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(41002, 'LA VIRGEN', 410, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 41003) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(41003, 'HORQUETAS', 410, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 50101) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(50101, 'LIBERIA', 501, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 50102) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(50102, 'CAÑAS DULCES', 501, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 50103) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(50103, 'MAYORGA', 501, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 50104) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(50104, 'NACASCOLO', 501, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 50105) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(50105, 'CURUBANDE', 501, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 50201) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(50201, 'NICOYA', 502, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 50202) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(50202, 'MANSION', 502, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 50203) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(50203, @DISTRITO1, 502, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 50204) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(50204, 'QUEBRADA HONDA', 502, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 50205) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(50205, 'SAMARA', 502, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 50206) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(50206, 'NOSARA', 502, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 50207) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(50207, 'BELEN DE NOSARITA', 502, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 50301) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(50301, 'SANTA CRUZ', 503, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 50302) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(50302, 'BOLSON', 503, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 50303) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(50303, 'VEINTISIETE DE ABRIL', 503, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 50304) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(50304, 'TEMPATE', 503, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 50305) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(50305, 'CARTAGENA', 503, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 50306) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(50306, 'CUAJINIQUIL', 503, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 50307) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(50307, 'DIRIA', 503, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 50308) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(50308, 'CABO VELAS', 503, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 50309) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(50309, 'TAMARINDO', 503, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 50401) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(50401, 'BAGACES', 504, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 50402) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(50402, 'FORTUNA', 504, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 50403) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(50403, 'MOGOTE', 504, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 50404) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(50404, 'RIO NARANJO', 504, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 50501) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(50501, 'FILADELFIA', 505, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 50502) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(50502, 'PALMIRA', 505, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 50503) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(50503, 'SARDINAL', 505, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 50504) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(50504, 'BELEN', 505, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 50601) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(50601, 'CAÑAS', 506, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 50602) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(50602, 'PALMIRA', 506, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 50603) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(50603, @DISTRITO3, 506, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 50604) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(50604, 'BEBEDERO', 506, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 50605) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(50605, 'POROZAL', 506, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 50701) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(50701, 'JUNTAS', 507, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 50702) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(50702, 'SIERRA', 507, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 50703) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(50703, @DISTRITO7, 507, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 50704) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(50704, 'COLORADO', 507, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 50801) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(50801, 'TILARAN', 508, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 50802) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(50802, 'QUEBRADA GRANDE', 508, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 50803) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(50803, 'TRONADORA', 508, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 50804) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(50804, @DISTRITO12, 508, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 50805) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(50805, 'LIBANO', 508, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 50806) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(50806, 'TIERRAS MORENAS', 508, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 50807) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(50807, 'ARENAL', 508, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 50901) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(50901, 'CARMONA', 509, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 50902) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(50902, 'SANTA RITA', 509, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 50903) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(50903, 'ZAPOTAL', 509, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 50904) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(50904, @DISTRITO10, 509, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 50905) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(50905, 'PORVENIR', 509, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 50906) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(50906, 'BEJUCO', 509, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 51001) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(51001, 'LA CRUZ', 510, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 51002) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(51002, 'SANTA CECILIA', 510, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 51003) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(51003, 'GARITA', 510, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 51004) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(51004, 'SANTA ELENA', 510, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 51101) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(51101, 'HOJANCHA', 511, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 51102) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(51102, 'MONTE ROMO', 511, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 51103) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(51103, 'PUERTO CARRILLO', 511, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 51104) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(51104, 'HUACAS', 511, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 60101) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(60101, 'PUNTARENAS', 601, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 60102) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(60102, 'PITAHAYA', 601, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 60103) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(60103, 'CHOMES', 601, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 60104) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(60104, 'LEPANTO', 601, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 60105) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(60105, 'PAQUERA', 601, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 60106) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(60106, 'MANZANILLO', 601, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 60107) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(60107, 'GUACIMAL', 601, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 60108) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(60108, 'BARRANCA', 601, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 60109) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(60109, 'MONTE VERDE', 601, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 60111) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(60111, 'COBANO', 601, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 60112) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(60112, 'CHACARITA', 601, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 60113) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(60113, 'CHIRA', 601, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 60114) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(60114, 'ACAPULCO', 601, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 60115) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(60115, 'EL ROBLE', 601, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 60116) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(60116, 'ARANCIBIA', 601, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 60201) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(60201, 'ESPIRITU SANTO', 602, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 60202) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(60202, 'SAN JUAN GRANDE', 602, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 60203) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(60203, 'MACACONA', 602, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 60204) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(60204, @DISTRITO2, 602, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 60205) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(60205, 'SAN JERONIMO', 602, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 60301) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(60301, 'BUENOS AIRES', 603, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 60302) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(60302, 'VOLCAN', 603, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 60303) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(60303, 'POTRERO GRANDE', 603, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 60304) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(60304, 'BORUCA', 603, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 60305) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(60305, 'PILAS', 603, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 60306) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(60306, 'COLINAS', 603, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 60307) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(60307, 'CHANGUENA', 603, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 60308) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(60308, 'BIOLLEY', 603, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 60401) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(60401, 'MIRAMAR', 604, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 60402) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(60402, 'UNION', 604, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 60403) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(60403, @DISTRITO6, 604, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 60501) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(60501, 'PUERTO CORTES', 605, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 60502) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(60502, 'PALMAR', 605, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 60503) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(60503, 'SIERPE', 605, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 60504) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(60504, 'BAHIA BALLENA', 605, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 60505) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(60505, 'PIEDRAS BLANCAS', 605, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 60601) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(60601, 'QUEPOS', 606, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 60602) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(60602, 'SAVEGRE', 606, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 60603) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(60603, 'NARANJITO', 606, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 60701) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(60701, 'GOLFITO', 607, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 60702) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(60702, 'PUERTO JIMENEZ', 607, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 60703) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(60703, 'GUAYCARA', 607, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 60704) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(60704, 'PAVON', 607, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 60801) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(60801, 'SAN VITO', 608, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 60802) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(60802, 'SABALITO', 608, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 60803) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(60803, 'AGUABUENA', 608, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 60804) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(60804, 'LIMONCITO', 608, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 60805) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(60805, 'PITTIER', 608, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 60901) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(60901, 'PARRITA', 609, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 61001) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(61001, 'CORREDOR', 610, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 61002) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(61002, 'LA CUESTA', 610, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 61003) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(61003, 'CANOAS', 610, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 61004) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(61004, 'LAUREL', 610, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 61101) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(61101, 'JACO', 611, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 61102) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(61102, 'TARCOLES', 611, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 70101) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(70101, 'LIMON', 701, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 70102) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(70102, 'VALLE LA ESTRELLA', 701, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 70103) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(70103, 'RIO BLANCO', 701, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 70104) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(70104, 'MATAMA', 701, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 70201) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(70201, 'GUAPILES', 702, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 70202) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(70202, 'JIMENEZ', 702, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 70203) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(70203, 'RITA', 702, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 70204) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(70204, 'ROXANA', 702, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 70205) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(70205, 'CARIARI', 702, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 70206) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(70206, 'COLORADO', 702, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 70301) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(70301, 'SIQUIRRES', 703, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 70302) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(70302, 'PACUARITO', 703, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 70303) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(70303, 'FLORIDA', 703, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 70304) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(70304, 'GERMANIA', 703, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 70305) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(70305, 'CAIRO', 703, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 70306) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(70306, 'ALEGRIA', 703, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 70401) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(70401, 'BRATSI', 704, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 70402) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(70402, 'SIXAOLA', 704, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 70403) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(70403, 'CAHUITA', 704, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 70404) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(70404, 'TELIRE', 704, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 70501) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(70501, 'MATINA', 705, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 70502) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(70502, 'BATAN', 705, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 70503) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(70503, 'CARRANDI', 705, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 70601) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(70601, 'GUACIMO', 706, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 70602) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(70602, @DISTRITO9, 706, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 70603) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(70603, 'POCORA', 706, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 70604) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(70604, 'RIO JIMENEZ', 706, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblDistrito] WHERE Id = 70605) BEGIN
        INSERT INTO [dbo].[tblDistrito] ([Id], [Nombre], [fk_Id_Canton], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES(70605, 'DUACARI', 706, 1, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    
END
GO
------------------------------------------------------------------
--- I N S E R T		M E N S A J E  E M E R G E N T E  M E T O D O
------------------------------------------------------------------
IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblMensajes_Emergentes_Metodo')
BEGIN
    SET IDENTITY_INSERT [dbo].[tblMensajes_Emergentes_Metodo] ON 

    -- Registro 1
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes_Metodo] WHERE [Id] = 1)
    BEGIN
        INSERT [dbo].[tblMensajes_Emergentes_Metodo] ([Id], [Metodo], [FechaCreacion], [FechaModificacion]) 
        VALUES (1, N'usp_DeleteComunicado', CURRENT_TIMESTAMP, NULL)
    END

    -- Registro 2
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes_Metodo] WHERE [Id] = 2)
    BEGIN
        INSERT [dbo].[tblMensajes_Emergentes_Metodo] ([Id], [Metodo], [FechaCreacion], [FechaModificacion]) 
        VALUES (2, N'EliminarNotificacionBtn( )', CURRENT_TIMESTAMP, NULL)
    END

    -- Registro 3
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes_Metodo] WHERE [Id] = 3)
    BEGIN
        INSERT [dbo].[tblMensajes_Emergentes_Metodo] ([Id], [Metodo], [FechaCreacion], [FechaModificacion]) 
        VALUES (3, N'usp_UpdateHabilitarBanner', CURRENT_TIMESTAMP, NULL)
    END

    -- Registro 4
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes_Metodo] WHERE [Id] = 4)
    BEGIN
        INSERT [dbo].[tblMensajes_Emergentes_Metodo] ([Id], [Metodo], [FechaCreacion], [FechaModificacion]) 
        VALUES (4, N'usp_InsertComunicado', CURRENT_TIMESTAMP, NULL)
    END

    -- Registro 5
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes_Metodo] WHERE [Id] = 5)
    BEGIN
        INSERT [dbo].[tblMensajes_Emergentes_Metodo] ([Id], [Metodo], [FechaCreacion], [FechaModificacion]) 
        VALUES (5, N'showValidateSendNoticeFormSubmit()', CURRENT_TIMESTAMP, NULL)
    END

    -- Registro 6
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes_Metodo] WHERE [Id] = 6)
    BEGIN
        INSERT [dbo].[tblMensajes_Emergentes_Metodo] ([Id], [Metodo], [FechaCreacion], [FechaModificacion]) 
        VALUES (6, N'usp_InsertDenominaciones', CURRENT_TIMESTAMP, NULL)
    END

    -- Registro 7
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes_Metodo] WHERE [Id] = 7)
    BEGIN
        INSERT [dbo].[tblMensajes_Emergentes_Metodo] ([Id], [Metodo], [FechaCreacion], [FechaModificacion]) 
        VALUES (7, N'showValidateSendNuevoFormSubmit()', CURRENT_TIMESTAMP, NULL)
    END

    -- Registro 8
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes_Metodo] WHERE [Id] = 8)
    BEGIN
        INSERT [dbo].[tblMensajes_Emergentes_Metodo] ([Id], [Metodo], [FechaCreacion], [FechaModificacion]) 
        VALUES (8, N'MensajeEnviarNuevaDenominacion()', CURRENT_TIMESTAMP, NULL)
    END

    -- Registro 9
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes_Metodo] WHERE [Id] = 9)
    BEGIN
        INSERT [dbo].[tblMensajes_Emergentes_Metodo] ([Id], [Metodo], [FechaCreacion], [FechaModificacion]) 
        VALUES (9, N'usp_UpdateDenominaciones', CURRENT_TIMESTAMP, NULL)
    END

    -- Registro 10
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes_Metodo] WHERE [Id] = 10)
    BEGIN
        INSERT [dbo].[tblMensajes_Emergentes_Metodo] ([Id], [Metodo], [FechaCreacion], [FechaModificacion]) 
        VALUES (10, N'showValidateSendEditFormSubmit()', CURRENT_TIMESTAMP, NULL)
    END

    -- Registro 11
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes_Metodo] WHERE [Id] = 11)
    BEGIN
        INSERT [dbo].[tblMensajes_Emergentes_Metodo] ([Id], [Metodo], [FechaCreacion], [FechaModificacion]) 
        VALUES (11, N'MensajeEnviarEditarDenominacion()', CURRENT_TIMESTAMP, NULL)
    END

    -- Registro 12
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes_Metodo] WHERE [Id] = 12)
    BEGIN
        INSERT [dbo].[tblMensajes_Emergentes_Metodo] ([Id], [Metodo], [FechaCreacion], [FechaModificacion]) 
        VALUES (12, N'usp_HabilitarDenominaciones', CURRENT_TIMESTAMP, NULL)
    END

    -- Registro 13
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes_Metodo] WHERE [Id] = 13)
    BEGIN
        INSERT [dbo].[tblMensajes_Emergentes_Metodo] ([Id], [Metodo], [FechaCreacion], [FechaModificacion]) 
        VALUES (13, N'BtnHabilitarDenominacion()', CURRENT_TIMESTAMP, NULL)
    END

    -- Registro 14
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes_Metodo] WHERE [Id] = 14)
    BEGIN
        INSERT [dbo].[tblMensajes_Emergentes_Metodo] ([Id], [Metodo], [FechaCreacion], [FechaModificacion]) 
        VALUES (14, N'usp_InsertDivisa', CURRENT_TIMESTAMP, NULL)
    END

    -- Registro 15
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes_Metodo] WHERE [Id] = 15)
    BEGIN
        INSERT [dbo].[tblMensajes_Emergentes_Metodo] ([Id], [Metodo], [FechaCreacion], [FechaModificacion]) 
        VALUES (15, N'MensajeEnviarNuevaDivisa()', CURRENT_TIMESTAMP, NULL)
    END

    -- Registro 16
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes_Metodo] WHERE [Id] = 16)
    BEGIN
        INSERT [dbo].[tblMensajes_Emergentes_Metodo] ([Id], [Metodo], [FechaCreacion], [FechaModificacion]) 
        VALUES (16, N'usp_UpdateDivisa', CURRENT_TIMESTAMP, NULL)
    END

    -- Registro 17
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes_Metodo] WHERE [Id] = 17)
    BEGIN
        INSERT [dbo].[tblMensajes_Emergentes_Metodo] ([Id], [Metodo], [FechaCreacion], [FechaModificacion]) 
        VALUES (17, N'usp_HabilitarDivisa', CURRENT_TIMESTAMP, NULL)
    END

    -- Registro 18
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes_Metodo] WHERE [Id] = 18)
    BEGIN
        INSERT [dbo].[tblMensajes_Emergentes_Metodo] ([Id], [Metodo], [FechaCreacion], [FechaModificacion]) 
        VALUES (18, N'BtnHabilitarDivisas()', CURRENT_TIMESTAMP, NULL)
    END

    -- Registro 19
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes_Metodo] WHERE [Id] = 19)
    BEGIN
        INSERT [dbo].[tblMensajes_Emergentes_Metodo] ([Id], [Metodo], [FechaCreacion], [FechaModificacion]) 
        VALUES (19, N'MensajeEnviarEditarDivisa()', CURRENT_TIMESTAMP, NULL)
    END

    -- Registro 20
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes_Metodo] WHERE [Id] = 20)
    BEGIN
        INSERT [dbo].[tblMensajes_Emergentes_Metodo] ([Id], [Metodo], [FechaCreacion], [FechaModificacion]) 
        VALUES (20, N'usp_UpdateTipoEfectivo', CURRENT_TIMESTAMP, NULL)
    END

    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes_Metodo] WHERE [Id] = 21)
    BEGIN
        INSERT [dbo].[tblMensajes_Emergentes_Metodo] ([Id], [Metodo], [FechaCreacion], [FechaModificacion]) 
        VALUES (21, N'MensajeEnviarNuevoTipoEfectivo()', CURRENT_TIMESTAMP, NULL)
    END

    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes_Metodo] WHERE [Id] = 22)
    BEGIN
        INSERT [dbo].[tblMensajes_Emergentes_Metodo] ([Id], [Metodo], [FechaCreacion], [FechaModificacion]) 
        VALUES (22, N'MensajeEnviarEditarTipoEfectivo()', CURRENT_TIMESTAMP, NULL)
    END

    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes_Metodo] WHERE [Id] = 23)
    BEGIN
        INSERT [dbo].[tblMensajes_Emergentes_Metodo] ([Id], [Metodo], [FechaCreacion], [FechaModificacion]) 
        VALUES (23, N'usp_HabilitarTipoEfectivo', CURRENT_TIMESTAMP, NULL)
    END

    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes_Metodo] WHERE [Id] = 24)
    BEGIN
        INSERT [dbo].[tblMensajes_Emergentes_Metodo] ([Id], [Metodo], [FechaCreacion], [FechaModificacion]) 
        VALUES (24, N'BtnHabilitarTiposEfectivos()', CURRENT_TIMESTAMP, NULL)
    END

    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes_Metodo] WHERE [Id] = 25)
    BEGIN
        INSERT [dbo].[tblMensajes_Emergentes_Metodo] ([Id], [Metodo], [FechaCreacion], [FechaModificacion]) 
        VALUES (25, N'usp_InsertTipoEfectivo', CURRENT_TIMESTAMP, NULL)
    END

    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes_Metodo] WHERE [Id] = 26)
    BEGIN
        INSERT [dbo].[tblMensajes_Emergentes_Metodo] ([Id], [Metodo], [FechaCreacion], [FechaModificacion]) 
        VALUES (26, N'usp_Insert_Unidad_Medida', CURRENT_TIMESTAMP, NULL)
    END

    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes_Metodo] WHERE [Id] = 27)
    BEGIN
        INSERT [dbo].[tblMensajes_Emergentes_Metodo] ([Id], [Metodo], [FechaCreacion], [FechaModificacion]) 
        VALUES (27, N'usp_Edit_Unidad_Medida', CURRENT_TIMESTAMP, NULL)
    END

    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes_Metodo] WHERE [Id] = 28)
    BEGIN
        INSERT [dbo].[tblMensajes_Emergentes_Metodo] ([Id], [Metodo], [FechaCreacion], [FechaModificacion]) 
        VALUES (28, N'usp_Habilitar_Unidades_Medidas', CURRENT_TIMESTAMP, NULL)
    END

    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes_Metodo] WHERE [Id] = 29)
    BEGIN
        INSERT [dbo].[tblMensajes_Emergentes_Metodo] ([Id], [Metodo], [FechaCreacion], [FechaModificacion]) 
        VALUES (29, N'cambiar_Estados_Unidades_Medidas()', CURRENT_TIMESTAMP, NULL)
    END

    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes_Metodo] WHERE [Id] = 30)
    BEGIN
        INSERT [dbo].[tblMensajes_Emergentes_Metodo] ([Id], [Metodo], [FechaCreacion], [FechaModificacion]) 
        VALUES (30, N'validar_Datos_Antes_De_Enviar_Frm_Modal_Agregar_Unidad_Medida()', CURRENT_TIMESTAMP, NULL)
    END

    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes_Metodo] WHERE [Id] = 31)
    BEGIN
        INSERT [dbo].[tblMensajes_Emergentes_Metodo] ([Id], [Metodo], [FechaCreacion], [FechaModificacion]) 
        VALUES (31, N'Campos_Vacios_Formulario_Agregar_Unidad_Medida()', CURRENT_TIMESTAMP, NULL)
    END

    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes_Metodo] WHERE [Id] = 32)
    BEGIN
        INSERT [dbo].[tblMensajes_Emergentes_Metodo] ([Id], [Metodo], [FechaCreacion], [FechaModificacion]) 
        VALUES (32, N'validar_Datos_Antes_De_Enviar_Frm_Modal_Editar_Unidad_Medida()', CURRENT_TIMESTAMP, NULL)
    END

    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes_Metodo] WHERE [Id] = 33)
    BEGIN
        INSERT [dbo].[tblMensajes_Emergentes_Metodo] ([Id], [Metodo], [FechaCreacion], [FechaModificacion]) 
        VALUES (33, N'Campos_Vacios_Formulario_Editar_Unidad_Medida()', CURRENT_TIMESTAMP, NULL)
    END

    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes_Metodo] WHERE [Id] = 34)
    BEGIN
        INSERT [dbo].[tblMensajes_Emergentes_Metodo] ([Id], [Metodo], [FechaCreacion], [FechaModificacion]) 
        VALUES (34, N'usp_InsertAgenciaBancaria', CURRENT_TIMESTAMP, NULL)
    END

    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes_Metodo] WHERE [Id] = 35)
    BEGIN
        INSERT [dbo].[tblMensajes_Emergentes_Metodo] ([Id], [Metodo], [FechaCreacion], [FechaModificacion]) 
        VALUES (35, N'usp_UpdateAgenciaBancaria', CURRENT_TIMESTAMP, NULL)
    END

    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes_Metodo] WHERE [Id] = 36)
    BEGIN
        INSERT [dbo].[tblMensajes_Emergentes_Metodo] ([Id], [Metodo], [FechaCreacion], [FechaModificacion]) 
        VALUES (36, N'usp_HabilitarAgenciaBancaria', CURRENT_TIMESTAMP, NULL)
    END

    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes_Metodo] WHERE [Id] = 37)
    BEGIN
        INSERT [dbo].[tblMensajes_Emergentes_Metodo] ([Id], [Metodo], [FechaCreacion], [FechaModificacion]) 
        VALUES (37, N'BtnHabilitarAgencia()', CURRENT_TIMESTAMP, NULL)
    END

    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes_Metodo] WHERE [Id] = 38)
    BEGIN
        INSERT [dbo].[tblMensajes_Emergentes_Metodo] ([Id], [Metodo], [FechaCreacion], [FechaModificacion]) 
        VALUES (38, N'MostrarMensajeFormularioVacio()', CURRENT_TIMESTAMP, NULL)
    END

    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes_Metodo] WHERE [Id] = 39)
    BEGIN
        INSERT [dbo].[tblMensajes_Emergentes_Metodo] ([Id], [Metodo], [FechaCreacion], [FechaModificacion]) 
        VALUES (39, N'ValidarNumeroCuentaBD()', CURRENT_TIMESTAMP, NULL)
    END

    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes_Metodo] WHERE [Id] = 40)
    BEGIN
        INSERT [dbo].[tblMensajes_Emergentes_Metodo] ([Id], [Metodo], [FechaCreacion], [FechaModificacion]) 
        VALUES (40, N'BtnEnviarFormularioModalEditar()', CURRENT_TIMESTAMP, NULL)
    END

    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes_Metodo] WHERE [Id] = 41)
    BEGIN
        INSERT [dbo].[tblMensajes_Emergentes_Metodo] ([Id], [Metodo], [FechaCreacion], [FechaModificacion]) 
        VALUES (41, N'BtnEnviarFormularioModalNuevo()', CURRENT_TIMESTAMP, NULL)
    END

    -- Insert 1
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes_Metodo] WHERE [Id] = 42)
    BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes_Metodo] ([Id], [Metodo], [FechaCreacion], [FechaModificacion]) 
        VALUES (42, N'usp_SelectCuentaInterna', CURRENT_TIMESTAMP, NULL);
    END;

    -- Insert 2
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes_Metodo] WHERE [Id] = 43)
    BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes_Metodo] ([Id], [Metodo], [FechaCreacion], [FechaModificacion]) 
        VALUES (43, N'usp_ValidateCuentasInternas_x_GrupoAgencias', CURRENT_TIMESTAMP, NULL);
    END;

    -- Insert 3
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes_Metodo] WHERE [Id] = 44)
    BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes_Metodo] ([Id], [Metodo], [FechaCreacion], [FechaModificacion]) 
        VALUES (44, N'usp_InsertGrupoAgencia', CURRENT_TIMESTAMP, NULL);
    END;

    -- Insert 4
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes_Metodo] WHERE [Id] = 45)
    BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes_Metodo] ([Id], [Metodo], [FechaCreacion], [FechaModificacion]) 
        VALUES (45, N'usp_UpdateGrupoAgencia', CURRENT_TIMESTAMP, NULL);
    END;

    -- Insert 5
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes_Metodo] WHERE [Id] = 46)
    BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes_Metodo] ([Id], [Metodo], [FechaCreacion], [FechaModificacion]) 
        VALUES (46, N'usp_HabilitarGrupoAgencia', CURRENT_TIMESTAMP, NULL);
    END;

    -- Insert 6
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes_Metodo] WHERE [Id] = 47)
    BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes_Metodo] ([Id], [Metodo], [FechaCreacion], [FechaModificacion]) 
        VALUES (47, N'BtnHabilitarGrupoAgencia()', CURRENT_TIMESTAMP, NULL);
    END;

    -- Insert 7
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes_Metodo] WHERE [Id] = 48)
    BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes_Metodo] ([Id], [Metodo], [FechaCreacion], [FechaModificacion]) 
        VALUES (48, N'usp_InsertCedis', CURRENT_TIMESTAMP, NULL);
    END;

    -- Insert 8
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes_Metodo] WHERE [Id] = 49)
    BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes_Metodo] ([Id], [Metodo], [FechaCreacion], [FechaModificacion]) 
        VALUES (49, N'usp_UpdateCedis', CURRENT_TIMESTAMP, NULL);
    END;

    -- Insert 9
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes_Metodo] WHERE [Id] = 50)
    BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes_Metodo] ([Id], [Metodo], [FechaCreacion], [FechaModificacion]) 
        VALUES (50, N'usp_HabilitarCedis', CURRENT_TIMESTAMP, NULL);
    END;

    -- Insert 10
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes_Metodo] WHERE [Id] = 51)
    BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes_Metodo] ([Id], [Metodo], [FechaCreacion], [FechaModificacion]) 
        VALUES (51, N'BtnHabilitarCedis()', CURRENT_TIMESTAMP, NULL);
    END;

    -- Insert 11
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes_Metodo] WHERE [Id] = 52)
    BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes_Metodo] ([Id], [Metodo], [FechaCreacion], [FechaModificacion]) 
        VALUES (52, N'MensajeEnviarNuevaCedi()', CURRENT_TIMESTAMP, NULL);
    END;

    -- Insert 12
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes_Metodo] WHERE [Id] = 53)
    BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes_Metodo] ([Id], [Metodo], [FechaCreacion], [FechaModificacion]) 
        VALUES (53, N'MensajeEnviarEditarCedi()', CURRENT_TIMESTAMP, NULL);
    END;

    -- Insert 13
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes_Metodo] WHERE [Id] = 54)
    BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes_Metodo] ([Id], [Metodo], [FechaCreacion], [FechaModificacion]) 
        VALUES (54, N'usp_Habilitar_Paises', CURRENT_TIMESTAMP, NULL);
    END;

    -- Insert 14
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes_Metodo] WHERE [Id] = 55)
    BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes_Metodo] ([Id], [Metodo], [FechaCreacion], [FechaModificacion]) 
        VALUES (55, N'usp_InsertPais', CURRENT_TIMESTAMP, NULL);
    END;

    -- Insert 15
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes_Metodo] WHERE [Id] = 56)
    BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes_Metodo] ([Id], [Metodo], [FechaCreacion], [FechaModificacion]) 
        VALUES (56, N'usp_UpdatePais', CURRENT_TIMESTAMP, NULL);
    END;

    -- Insert 16
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes_Metodo] WHERE [Id] = 57)
    BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes_Metodo] ([Id], [Metodo], [FechaCreacion], [FechaModificacion]) 
        VALUES (57, N'cambiar_Estados_Paises()', CURRENT_TIMESTAMP, NULL);
    END;

    -- Insert 17
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes_Metodo] WHERE [Id] = 58)
    BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes_Metodo] ([Id], [Metodo], [FechaCreacion], [FechaModificacion]) 
        VALUES (58, N'MensajeEnviarNuevoPais()', CURRENT_TIMESTAMP, NULL);
    END;

    -- Insert 18
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes_Metodo] WHERE [Id] = 59)
    BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes_Metodo] ([Id], [Metodo], [FechaCreacion], [FechaModificacion]) 
        VALUES (59, N'MensajeEnviarEditarPais()', CURRENT_TIMESTAMP, NULL);
    END;

    -- Insert 19
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes_Metodo] WHERE [Id] = 60)
    BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes_Metodo] ([Id], [Metodo], [FechaCreacion], [FechaModificacion]) 
        VALUES (60, N'usp_HabilitarDepartamento', CURRENT_TIMESTAMP, NULL);
    END;

    -- Insert 20
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes_Metodo] WHERE [Id] = 61)
    BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes_Metodo] ([Id], [Metodo], [FechaCreacion], [FechaModificacion]) 
        VALUES (61, N'usp_InsertDepartamento', CURRENT_TIMESTAMP, NULL);
    END;

    -- Insert 21
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes_Metodo] WHERE [Id] = 62)
    BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes_Metodo] ([Id], [Metodo], [FechaCreacion], [FechaModificacion]) 
        VALUES (62, N'usp_UpdateDepartamento', CURRENT_TIMESTAMP, NULL);
    END;

    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes_Metodo] WHERE [Id] = 63)
    BEGIN
        INSERT [dbo].[tblMensajes_Emergentes_Metodo] ([Id], [Metodo], [FechaCreacion], [FechaModificacion]) 
        VALUES (63, N'BtnHabilitarDepartamentos()', CURRENT_TIMESTAMP, NULL);
    END

    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes_Metodo] WHERE [Id] = 64)
    BEGIN
        INSERT [dbo].[tblMensajes_Emergentes_Metodo] ([Id], [Metodo], [FechaCreacion], [FechaModificacion]) 
        VALUES (64, N'MensajeEnviarNuevaDepartamento()', CURRENT_TIMESTAMP, NULL);
    END

    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes_Metodo] WHERE [Id] = 65)
    BEGIN
        INSERT [dbo].[tblMensajes_Emergentes_Metodo] ([Id], [Metodo], [FechaCreacion], [FechaModificacion]) 
        VALUES (65, N'MensajeEnviarEditarDepartamento()', CURRENT_TIMESTAMP, NULL);
    END

    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes_Metodo] WHERE [Id] = 66)
    BEGIN
        INSERT [dbo].[tblMensajes_Emergentes_Metodo] ([Id], [Metodo], [FechaCreacion], [FechaModificacion]) 
        VALUES (66, N'usp_HabilitarMatrizAtribucion', CURRENT_TIMESTAMP, NULL);
    END

    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes_Metodo] WHERE [Id] = 67)
    BEGIN
        INSERT [dbo].[tblMensajes_Emergentes_Metodo] ([Id], [Metodo], [FechaCreacion], [FechaModificacion]) 
        VALUES (67, N'usp_InsertMatrizAtribucion', CURRENT_TIMESTAMP, NULL);
    END

    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes_Metodo] WHERE [Id] = 68)
    BEGIN
        INSERT [dbo].[tblMensajes_Emergentes_Metodo] ([Id], [Metodo], [FechaCreacion], [FechaModificacion]) 
        VALUES (68, N'usp_UpdateMatrizAtribucion', CURRENT_TIMESTAMP, NULL);
    END

    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes_Metodo] WHERE [Id] = 69)
    BEGIN
        INSERT [dbo].[tblMensajes_Emergentes_Metodo] ([Id], [Metodo], [FechaCreacion], [FechaModificacion]) 
        VALUES (69, N'Boton_Habilitar_Matriz_Atribucion()', CURRENT_TIMESTAMP, NULL);
    END

    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes_Metodo] WHERE [Id] = 1036)
    BEGIN
        INSERT [dbo].[tblMensajes_Emergentes_Metodo] ([Id], [Metodo], [FechaCreacion], [FechaModificacion]) 
        VALUES (1036, N'usp_UpdateRol', CURRENT_TIMESTAMP, NULL);
    END

    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes_Metodo] WHERE [Id] = 1037)
    BEGIN
        INSERT [dbo].[tblMensajes_Emergentes_Metodo] ([Id], [Metodo], [FechaCreacion], [FechaModificacion]) 
        VALUES (1037, N'usp_InsertRol', CURRENT_TIMESTAMP, NULL);
    END

    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes_Metodo] WHERE [Id] = 1038)
    BEGIN
        INSERT [dbo].[tblMensajes_Emergentes_Metodo] ([Id], [Metodo], [FechaCreacion], [FechaModificacion]) 
        VALUES (1038, N'usp_Habilitar_Roles', CURRENT_TIMESTAMP, NULL);
    END

    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes_Metodo] WHERE [Id] = 1039)
    BEGIN
        INSERT [dbo].[tblMensajes_Emergentes_Metodo] ([Id], [Metodo], [FechaCreacion], [FechaModificacion]) 
        VALUES (1039, N'OnClickEstado()', CURRENT_TIMESTAMP, NULL);
    END

    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes_Metodo] WHERE [Id] = 1040)
    BEGIN
        INSERT [dbo].[tblMensajes_Emergentes_Metodo] ([Id], [Metodo], [FechaCreacion], [FechaModificacion]) 
        VALUES (1040, N'Insertar()', CURRENT_TIMESTAMP, NULL);
    END

    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes_Metodo] WHERE [Id] = 1041)
    BEGIN
        INSERT [dbo].[tblMensajes_Emergentes_Metodo] ([Id], [Metodo], [FechaCreacion], [FechaModificacion]) 
        VALUES (1041, N'Insertar() ORIGINADOR', CURRENT_TIMESTAMP, NULL);
    END

    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes_Metodo] WHERE [Id] = 1042)
    BEGIN
        INSERT [dbo].[tblMensajes_Emergentes_Metodo] ([Id], [Metodo], [FechaCreacion], [FechaModificacion]) 
        VALUES (1042, N'RequestValido()', CURRENT_TIMESTAMP, NULL);
    END

    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes_Metodo] WHERE [Id] = 1043)
    BEGIN
        INSERT [dbo].[tblMensajes_Emergentes_Metodo] ([Id], [Metodo], [FechaCreacion], [FechaModificacion]) 
        VALUES (1043, N'Update()', CURRENT_TIMESTAMP, NULL);
    END

    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes_Metodo] WHERE [Id] = 1044)
    BEGIN
        INSERT [dbo].[tblMensajes_Emergentes_Metodo] ([Id], [Metodo], [FechaCreacion], [FechaModificacion]) 
        VALUES (1044, N'Update() ORIGINADOR', CURRENT_TIMESTAMP, NULL);
    END

    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes_Metodo] WHERE [Id] = 1045)
    BEGIN
        INSERT [dbo].[tblMensajes_Emergentes_Metodo] ([Id], [Metodo], [FechaCreacion], [FechaModificacion]) 
        VALUES (1045, N'usp_InsertArea', CURRENT_TIMESTAMP, NULL);
    END

    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes_Metodo] WHERE [Id] = 1046)
    BEGIN
        INSERT [dbo].[tblMensajes_Emergentes_Metodo] ([Id], [Metodo], [FechaCreacion], [FechaModificacion]) 
        VALUES (1046, N'usp_UpdateArea', CURRENT_TIMESTAMP, NULL);
    END

    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes_Metodo] WHERE [Id] = 1047)
    BEGIN
        INSERT [dbo].[tblMensajes_Emergentes_Metodo] ([Id], [Metodo], [FechaCreacion], [FechaModificacion]) 
        VALUES (1047, N'usp_HabilitarArea', CURRENT_TIMESTAMP, NULL);
    END

    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes_Metodo] WHERE [Id] = 1048)
    BEGIN
        INSERT [dbo].[tblMensajes_Emergentes_Metodo] ([Id], [Metodo], [FechaCreacion], [FechaModificacion]) 
        VALUES (1048, N'usp_InsertUsuario', CURRENT_TIMESTAMP, NULL);
    END

    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes_Metodo] WHERE [Id] = 1049)
    BEGIN
        INSERT [dbo].[tblMensajes_Emergentes_Metodo] ([Id], [Metodo], [FechaCreacion], [FechaModificacion]) 
        VALUES (1049, N'usp_UpdateUsuario', CURRENT_TIMESTAMP, NULL);
    END

    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes_Metodo] WHERE [Id] = 1050)
    BEGIN
        INSERT [dbo].[tblMensajes_Emergentes_Metodo] ([Id], [Metodo], [FechaCreacion], [FechaModificacion]) 
        VALUES (1050, N'usp_HabilitarUsuario', CURRENT_TIMESTAMP, NULL);
    END

    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes_Metodo] WHERE [Id] = 1051)
    BEGIN
        INSERT [dbo].[tblMensajes_Emergentes_Metodo] ([Id], [Metodo], [FechaCreacion], [FechaModificacion]) 
        VALUES (1051, N'validar_Datos_Antes_De_Enviar_Frm_Modal_Nueva_Transportadora()', CURRENT_TIMESTAMP, NULL);
    END

    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes_Metodo] WHERE [Id] = 1052)
    BEGIN
        INSERT [dbo].[tblMensajes_Emergentes_Metodo] ([Id], [Metodo], [FechaCreacion], [FechaModificacion]) 
        VALUES (1052, N'campos_Vacios_Formulario_Agregar_Transportadora()', CURRENT_TIMESTAMP, NULL);
    END

    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes_Metodo] WHERE [Id] = 1053)
    BEGIN
        INSERT [dbo].[tblMensajes_Emergentes_Metodo] ([Id], [Metodo], [FechaCreacion], [FechaModificacion]) 
        VALUES (1053, N'usp_Insert_Transportadora', CURRENT_TIMESTAMP, NULL);
    END

    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes_Metodo] WHERE [Id] = 1054)
    BEGIN
        INSERT [dbo].[tblMensajes_Emergentes_Metodo] ([Id], [Metodo], [FechaCreacion], [FechaModificacion]) 
        VALUES (1054, N'OnClickBtnRegresar()', CURRENT_TIMESTAMP, NULL);
    END

    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes_Metodo] WHERE [Id] = 1055)
    BEGIN
        INSERT [dbo].[tblMensajes_Emergentes_Metodo] ([Id], [Metodo], [FechaCreacion], [FechaModificacion]) 
        VALUES (1055, N'usp_UpdateDiasHabilesEntregaPedidosInternos', CURRENT_TIMESTAMP, NULL);
    END

    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes_Metodo] WHERE [Id] = 1056)
    BEGIN
        INSERT [dbo].[tblMensajes_Emergentes_Metodo] ([Id], [Metodo], [FechaCreacion], [FechaModificacion]) 
        VALUES (1056, N'MantenimientoGestionesUsuario', CURRENT_TIMESTAMP, NULL);
    END

    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes_Metodo] WHERE [Id] = 1060)
    BEGIN
        INSERT [dbo].[tblMensajes_Emergentes_Metodo] ([Id], [Metodo], [FechaCreacion], [FechaModificacion]) 
        VALUES (1060, N'EliminarFirma()', CURRENT_TIMESTAMP, NULL);
    END

    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes_Metodo] WHERE [Id] = 1061)
    BEGIN
        INSERT [dbo].[tblMensajes_Emergentes_Metodo] ([Id], [Metodo], [FechaCreacion], [FechaModificacion]) 
        VALUES (1061, N'MostrarMensajeFormularioVacio() solicitud', CURRENT_TIMESTAMP, NULL);
    END

    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes_Metodo] WHERE [Id] = 1062)
    BEGIN
        INSERT [dbo].[tblMensajes_Emergentes_Metodo] ([Id], [Metodo], [FechaCreacion], [FechaModificacion]) 
        VALUES (1062, N'MostrarMensajeFormularioVacio() envio', CURRENT_TIMESTAMP, NULL);
    END

    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes_Metodo] WHERE [Id] = 1063)
    BEGIN
        INSERT [dbo].[tblMensajes_Emergentes_Metodo] ([Id], [Metodo], [FechaCreacion], [FechaModificacion]) 
        VALUES (1063, N'MostrarMensajeFormularioVacio() envio y solicitud', CURRENT_TIMESTAMP, NULL);
    END

    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes_Metodo] WHERE [Id] = 1065)
    BEGIN
        INSERT [dbo].[tblMensajes_Emergentes_Metodo] ([Id], [Metodo], [FechaCreacion], [FechaModificacion]) 
        VALUES (1065, N'usp_Insert_Transportadora_VALORES_NULL', CURRENT_TIMESTAMP, NULL);
    END

    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes_Metodo] WHERE [Id] = 1066)
    BEGIN
        INSERT [dbo].[tblMensajes_Emergentes_Metodo] ([Id], [Metodo], [FechaCreacion], [FechaModificacion]) 
        VALUES (1066, N'usp_Insert_Transportadora_CONSTRAINT', CURRENT_TIMESTAMP, NULL);
    END

    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes_Metodo] WHERE [Id] = 1067)
    BEGIN
        INSERT [dbo].[tblMensajes_Emergentes_Metodo] ([Id], [Metodo], [FechaCreacion], [FechaModificacion]) 
        VALUES (1067, N'usp_FinalizarGestionUsuario', CURRENT_TIMESTAMP, NULL);
    END

    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes_Metodo] WHERE [Id] = 1070)
    BEGIN
        INSERT [dbo].[tblMensajes_Emergentes_Metodo] ([Id], [Metodo], [FechaCreacion], [FechaModificacion]) 
        VALUES (1070, N'usp_Insert_Transportadora_CAMPOS_YA_EXISTENTES', CURRENT_TIMESTAMP, NULL);
    END

    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes_Metodo] WHERE [Id] = 1071)
    BEGIN
        INSERT [dbo].[tblMensajes_Emergentes_Metodo] ([Id], [Metodo], [FechaCreacion], [FechaModificacion]) 
        VALUES (1071, N'validar_Datos_Antes_De_Enviar_Frm_Modal_Editar_Transportadora()', CURRENT_TIMESTAMP, NULL);
    END

    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes_Metodo] WHERE [Id] = 1072)
    BEGIN
        INSERT [dbo].[tblMensajes_Emergentes_Metodo] ([Id], [Metodo], [FechaCreacion], [FechaModificacion]) 
        VALUES (1072, N'usp_Update_Transportadora', CURRENT_TIMESTAMP, NULL);
    END

    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes_Metodo] WHERE [Id] = 1073)
    BEGIN
        INSERT [dbo].[tblMensajes_Emergentes_Metodo] ([Id], [Metodo], [FechaCreacion], [FechaModificacion]) 
        VALUES (1073, N'validar_Datos_Antes_De_Enviar_A_Cambiar_Estados_Transportadoras()', CURRENT_TIMESTAMP, NULL);
    END

    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes_Metodo] WHERE [Id] = 1074)
    BEGIN
        INSERT [dbo].[tblMensajes_Emergentes_Metodo] ([Id], [Metodo], [FechaCreacion], [FechaModificacion]) 
        VALUES (1074, N'usp_Habilitar_Transportadoras', CURRENT_TIMESTAMP, NULL);
    END;

    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes_Metodo] WHERE [Id] = 1075)
    BEGIN
        INSERT [dbo].[tblMensajes_Emergentes_Metodo] ([Id], [Metodo], [FechaCreacion], [FechaModificacion]) 
        VALUES (1075, N'MantenimientoPedidosExternosBoveda', CURRENT_TIMESTAMP, NULL);
    END;

    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes_Metodo] WHERE [Id] = 1076)
    BEGIN
        INSERT [dbo].[tblMensajes_Emergentes_Metodo] ([Id], [Metodo], [FechaCreacion], [FechaModificacion]) 
        VALUES (1076, N'SP_InsertPedidoExterno', CURRENT_TIMESTAMP, NULL);
    END;

    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes_Metodo] WHERE [Id] = 1080)
    BEGIN
        INSERT [dbo].[tblMensajes_Emergentes_Metodo] ([Id], [Metodo], [FechaCreacion], [FechaModificacion]) 
        VALUES (1080, N'ModuloPedidoExternoModificacionDenominaciones', CURRENT_TIMESTAMP, NULL);
    END;

    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes_Metodo] WHERE [Id] = 1081)
    BEGIN
        INSERT [dbo].[tblMensajes_Emergentes_Metodo] ([Id], [Metodo], [FechaCreacion], [FechaModificacion]) 
        VALUES (1081, N'SP_CancelarPEXT', CURRENT_TIMESTAMP, NULL);
    END;

    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes_Metodo] WHERE [Id] = 1082)
    BEGIN
        INSERT [dbo].[tblMensajes_Emergentes_Metodo] ([Id], [Metodo], [FechaCreacion], [FechaModificacion]) 
        VALUES (1082, N'SP_SetRestaurar', CURRENT_TIMESTAMP, NULL);
    END;

    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes_Metodo] WHERE [Id] = 1083)
    BEGIN
        INSERT [dbo].[tblMensajes_Emergentes_Metodo] ([Id], [Metodo], [FechaCreacion], [FechaModificacion]) 
        VALUES (1083, N'SP_PedidoExternoPendientesAprobaciones', CURRENT_TIMESTAMP, NULL);
    END;

    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes_Metodo] WHERE [Id] = 1084)
    BEGIN
        INSERT [dbo].[tblMensajes_Emergentes_Metodo] ([Id], [Metodo], [FechaCreacion], [FechaModificacion]) 
        VALUES (1084, N'SP_PedidoExternoPendientesRechazados', CURRENT_TIMESTAMP, NULL);
    END;

    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes_Metodo] WHERE [Id] = 1085)
    BEGIN
        INSERT [dbo].[tblMensajes_Emergentes_Metodo] ([Id], [Metodo], [FechaCreacion], [FechaModificacion]) 
        VALUES (1085, N'SP_RechazarFirmaPEXT', CURRENT_TIMESTAMP, NULL);
    END;

    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes_Metodo] WHERE [Id] = 1086)
    BEGIN
        INSERT [dbo].[tblMensajes_Emergentes_Metodo] ([Id], [Metodo], [FechaCreacion], [FechaModificacion]) 
        VALUES (1086, N'SP_AprobarFirmaPEXT', CURRENT_TIMESTAMP, NULL);
    END;

    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes_Metodo] WHERE [Id] = 1087)
    BEGIN
        INSERT [dbo].[tblMensajes_Emergentes_Metodo] ([Id], [Metodo], [FechaCreacion], [FechaModificacion]) 
        VALUES (1087, N'SP_PedidoExternoAprobadosAsignaciones', CURRENT_TIMESTAMP, NULL);
    END;

    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes_Metodo] WHERE [Id] = 1088)
    BEGIN
        INSERT [dbo].[tblMensajes_Emergentes_Metodo] ([Id], [Metodo], [FechaCreacion], [FechaModificacion]) 
        VALUES (1088, N'SP_PedidoExternoAprobadosDevolver', CURRENT_TIMESTAMP, NULL);
    END;

    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes_Metodo] WHERE [Id] = 1089)
    BEGIN
        INSERT [dbo].[tblMensajes_Emergentes_Metodo] ([Id], [Metodo], [FechaCreacion], [FechaModificacion]) 
        VALUES (1089, N'SP_CancelarArrayPEXT', CURRENT_TIMESTAMP, NULL);
    END;

    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes_Metodo] WHERE [Id] = 1090)
    BEGIN
        INSERT [dbo].[tblMensajes_Emergentes_Metodo] ([Id], [Metodo], [FechaCreacion], [FechaModificacion]) 
        VALUES (1090, N'SaldoCierreAgenciasMantenimiento', CURRENT_TIMESTAMP, NULL);
    END;

    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes_Metodo] WHERE [Id] = 1092)
    BEGIN
        INSERT [dbo].[tblMensajes_Emergentes_Metodo] ([Id], [Metodo], [FechaCreacion], [FechaModificacion]) 
        VALUES (1092, N'SP_PedidoExternoAsignadas_Devolver', CURRENT_TIMESTAMP, NULL);
    END;

    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes_Metodo] WHERE [Id] = 1093)
    BEGIN
        INSERT [dbo].[tblMensajes_Emergentes_Metodo] ([Id], [Metodo], [FechaCreacion], [FechaModificacion]) 
        VALUES (1093, N'SP_PedidoExternoAsignadas_Preparacion', CURRENT_TIMESTAMP, NULL);
    END;

    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes_Metodo] WHERE [Id] = 1094)
    BEGIN
        INSERT [dbo].[tblMensajes_Emergentes_Metodo] ([Id], [Metodo], [FechaCreacion], [FechaModificacion]) 
        VALUES (1094, N'HistorialPedidosExternosBoveda', CURRENT_TIMESTAMP, NULL);
    END;

    SET IDENTITY_INSERT [dbo].[tblMensajes_Emergentes_Metodo] OFF
END
GO
------------------------------------------------------------------
--- I N S E R T		M E N S A J E  E M E R G E N T E  M O D U L O
------------------------------------------------------------------
IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblMensajes_Emergentes_Modulo')
BEGIN
    SET IDENTITY_INSERT [dbo].[tblMensajes_Emergentes_Modulo] ON 

    -- Validación y luego inserción para cada fila
    IF NOT EXISTS (SELECT * FROM [dbo].[tblMensajes_Emergentes_Modulo] WHERE [Id] = 1)
    BEGIN
        INSERT [dbo].[tblMensajes_Emergentes_Modulo] ([Id], [Modulo], [FechaCreacion], [FechaModificacion]) 
        VALUES (1, N'Comunicados', CURRENT_TIMESTAMP, NULL)
    END

    IF NOT EXISTS (SELECT * FROM [dbo].[tblMensajes_Emergentes_Modulo] WHERE [Id] = 2)
    BEGIN
        INSERT [dbo].[tblMensajes_Emergentes_Modulo] ([Id], [Modulo], [FechaCreacion], [FechaModificacion]) 
        VALUES (2, N'Denominaciones', CURRENT_TIMESTAMP, NULL)
    END

    IF NOT EXISTS (SELECT * FROM [dbo].[tblMensajes_Emergentes_Modulo] WHERE [Id] = 3)
    BEGIN
        INSERT [dbo].[tblMensajes_Emergentes_Modulo] ([Id], [Modulo], [FechaCreacion], [FechaModificacion]) 
        VALUES (3, N'Divisa', CURRENT_TIMESTAMP, NULL)
    END

    IF NOT EXISTS (SELECT * FROM [dbo].[tblMensajes_Emergentes_Modulo] WHERE [Id] = 4)
    BEGIN
        INSERT [dbo].[tblMensajes_Emergentes_Modulo] ([Id], [Modulo], [FechaCreacion], [FechaModificacion]) 
        VALUES (4, N'TipoEfectivo', CURRENT_TIMESTAMP, NULL)
    END

    IF NOT EXISTS (SELECT * FROM [dbo].[tblMensajes_Emergentes_Modulo] WHERE [Id] = 5)
    BEGIN
        INSERT [dbo].[tblMensajes_Emergentes_Modulo] ([Id], [Modulo], [FechaCreacion], [FechaModificacion]) 
        VALUES (5, N'UnidadesMedidas', CURRENT_TIMESTAMP, NULL)
    END

    IF NOT EXISTS (SELECT * FROM [dbo].[tblMensajes_Emergentes_Modulo] WHERE [Id] = 6)
    BEGIN
        INSERT [dbo].[tblMensajes_Emergentes_Modulo] ([Id], [Modulo], [FechaCreacion], [FechaModificacion]) 
        VALUES (6, N'AgenciasBancarias', CURRENT_TIMESTAMP, NULL)
    END

    IF NOT EXISTS (SELECT * FROM [dbo].[tblMensajes_Emergentes_Modulo] WHERE [Id] = 7)
    BEGIN
        INSERT [dbo].[tblMensajes_Emergentes_Modulo] ([Id], [Modulo], [FechaCreacion], [FechaModificacion]) 
        VALUES (7, N'GrupoAgencias', CURRENT_TIMESTAMP, NULL)
    END

    IF NOT EXISTS (SELECT * FROM [dbo].[tblMensajes_Emergentes_Modulo] WHERE [Id] = 8)
    BEGIN
        INSERT [dbo].[tblMensajes_Emergentes_Modulo] ([Id], [Modulo], [FechaCreacion], [FechaModificacion]) 
        VALUES (8, N'Cedis', CURRENT_TIMESTAMP, NULL)
    END

    IF NOT EXISTS (SELECT * FROM [dbo].[tblMensajes_Emergentes_Modulo] WHERE [Id] = 9)
    BEGIN
        INSERT [dbo].[tblMensajes_Emergentes_Modulo] ([Id], [Modulo], [FechaCreacion], [FechaModificacion]) 
        VALUES (9, N'Paises', CURRENT_TIMESTAMP, NULL)
    END

    IF NOT EXISTS (SELECT * FROM [dbo].[tblMensajes_Emergentes_Modulo] WHERE [Id] = 10)
    BEGIN
        INSERT [dbo].[tblMensajes_Emergentes_Modulo] ([Id], [Modulo], [FechaCreacion], [FechaModificacion]) 
        VALUES (10, N'Departamentos', CURRENT_TIMESTAMP, NULL)
    END

    IF NOT EXISTS (SELECT * FROM [dbo].[tblMensajes_Emergentes_Modulo] WHERE [Id] = 11)
    BEGIN
        INSERT [dbo].[tblMensajes_Emergentes_Modulo] ([Id], [Modulo], [FechaCreacion], [FechaModificacion]) 
        VALUES (11, N'MatrizAtribucion', CURRENT_TIMESTAMP, NULL)
    END

    IF NOT EXISTS (SELECT * FROM [dbo].[tblMensajes_Emergentes_Modulo] WHERE [Id] = 12)
    BEGIN
        INSERT [dbo].[tblMensajes_Emergentes_Modulo] ([Id], [Modulo], [FechaCreacion], [FechaModificacion]) 
        VALUES (12, N'Areas', CURRENT_TIMESTAMP, NULL)
    END

    IF NOT EXISTS (SELECT * FROM [dbo].[tblMensajes_Emergentes_Modulo] WHERE [Id] = 13)
    BEGIN
        INSERT [dbo].[tblMensajes_Emergentes_Modulo] ([Id], [Modulo], [FechaCreacion], [FechaModificacion]) 
        VALUES (13, N'Roles', CURRENT_TIMESTAMP, NULL)
    END

    IF NOT EXISTS (SELECT * FROM [dbo].[tblMensajes_Emergentes_Modulo] WHERE [Id] = 14)
    BEGIN
        INSERT [dbo].[tblMensajes_Emergentes_Modulo] ([Id], [Modulo], [FechaCreacion], [FechaModificacion]) 
        VALUES (14, N'Usuarios', CURRENT_TIMESTAMP, NULL)
    END

    IF NOT EXISTS (SELECT * FROM [dbo].[tblMensajes_Emergentes_Modulo] WHERE [Id] = 15)
    BEGIN
        INSERT [dbo].[tblMensajes_Emergentes_Modulo] ([Id], [Modulo], [FechaCreacion], [FechaModificacion]) 
        VALUES (15, N'Empresas de logistica de efectivo', CURRENT_TIMESTAMP, NULL)
    END

    IF NOT EXISTS (SELECT * FROM [dbo].[tblMensajes_Emergentes_Modulo] WHERE [Id] = 16)
    BEGIN
        INSERT [dbo].[tblMensajes_Emergentes_Modulo] ([Id], [Modulo], [FechaCreacion], [FechaModificacion]) 
        VALUES (16, N'HorariosPedidos', CURRENT_TIMESTAMP, NULL)
    END

    IF NOT EXISTS (SELECT * FROM [dbo].[tblMensajes_Emergentes_Modulo] WHERE [Id] = 17)
    BEGIN
        INSERT [dbo].[tblMensajes_Emergentes_Modulo] ([Id], [Modulo], [FechaCreacion], [FechaModificacion]) 
        VALUES (17, N'AprobacionPedidos', CURRENT_TIMESTAMP, NULL)
    END

    IF NOT EXISTS (SELECT * FROM [dbo].[tblMensajes_Emergentes_Modulo] WHERE [Id] = 18)
    BEGIN
        INSERT [dbo].[tblMensajes_Emergentes_Modulo] ([Id], [Modulo], [FechaCreacion], [FechaModificacion]) 
        VALUES (18, N'Solicitud de Pedidos', CURRENT_TIMESTAMP, NULL)
    END

    IF NOT EXISTS (SELECT * FROM [dbo].[tblMensajes_Emergentes_Modulo] WHERE [Id] = 19)
    BEGIN
        INSERT [dbo].[tblMensajes_Emergentes_Modulo] ([Id], [Modulo], [FechaCreacion], [FechaModificacion]) 
        VALUES (19, N'Solicitud de Pedidos', CURRENT_TIMESTAMP, NULL)
    END

    IF NOT EXISTS (SELECT * FROM [dbo].[tblMensajes_Emergentes_Modulo] WHERE [Id] = 20)
    BEGIN
        INSERT [dbo].[tblMensajes_Emergentes_Modulo] ([Id], [Modulo], [FechaCreacion], [FechaModificacion]) 
        VALUES (20, N'Saldo Cierres Sucursal', CURRENT_TIMESTAMP, NULL)
    END

    SET IDENTITY_INSERT [dbo].[tblMensajes_Emergentes_Modulo] OFF
END
GO
----------------------------------------------------------------------------
--- I N S E R T		M E N S A J E  E M E R G E N T E  T I P O  M E N S A J E
----------------------------------------------------------------------------
IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblMensajes_Emergentes_Tipo_Mensaje')
BEGIN
    SET IDENTITY_INSERT [dbo].[tblMensajes_Emergentes_Tipo_Mensaje] ON 

    IF NOT EXISTS (SELECT * FROM [dbo].[tblMensajes_Emergentes_Tipo_Mensaje] WHERE [Id] = 1)
    BEGIN

        INSERT [dbo].[tblMensajes_Emergentes_Tipo_Mensaje] ([Id], [TipoMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES (1, N'Exitoso', CURRENT_TIMESTAMP, NULL)

    END

    IF NOT EXISTS (SELECT * FROM [dbo].[tblMensajes_Emergentes_Tipo_Mensaje] WHERE [Id] = 2)
    BEGIN

        INSERT [dbo].[tblMensajes_Emergentes_Tipo_Mensaje] ([Id], [TipoMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES (2, N'Error', CURRENT_TIMESTAMP, NULL)

    END

    IF NOT EXISTS (SELECT * FROM [dbo].[tblMensajes_Emergentes_Tipo_Mensaje] WHERE [Id] = 3)
    BEGIN

        INSERT [dbo].[tblMensajes_Emergentes_Tipo_Mensaje] ([Id], [TipoMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES (3, N'Confirmacion', CURRENT_TIMESTAMP, NULL)

    END

    SET IDENTITY_INSERT [dbo].[tblMensajes_Emergentes_Tipo_Mensaje] OFF
END
GO
----------------------------------------------------------------------------
--- I N S E R T		M E N S A J E  E M E R G E N T E  T I T U L O
----------------------------------------------------------------------------
IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblMensajes_Emergentes_Titulo')
BEGIN
    SET IDENTITY_INSERT [dbo].[tblMensajes_Emergentes_Titulo] ON 

    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes_Titulo] WHERE [Id] = 1)
    BEGIN
        INSERT [dbo].[tblMensajes_Emergentes_Titulo] ([Id], [Titulo], [FechaCreacion], [FechaModificacion]) 
        VALUES (1, N'Eliminado!', CURRENT_TIMESTAMP, NULL)
    END

    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes_Titulo] WHERE [Id] = 2)
    BEGIN
        INSERT [dbo].[tblMensajes_Emergentes_Titulo] ([Id], [Titulo], [FechaCreacion], [FechaModificacion]) 
        VALUES (2, N'No Eliminado!', CURRENT_TIMESTAMP, NULL)
    END

    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes_Titulo] WHERE [Id] = 3)
    BEGIN
        INSERT [dbo].[tblMensajes_Emergentes_Titulo] ([Id], [Titulo], [FechaCreacion], [FechaModificacion]) 
        VALUES (3, N'Estas seguro?', CURRENT_TIMESTAMP, NULL)
    END

    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes_Titulo] WHERE [Id] = 4)
    BEGIN
        INSERT [dbo].[tblMensajes_Emergentes_Titulo] ([Id], [Titulo], [FechaCreacion], [FechaModificacion]) 
        VALUES (4, N'Modificado!', CURRENT_TIMESTAMP, NULL)
    END

    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes_Titulo] WHERE [Id] = 5)
    BEGIN
        INSERT [dbo].[tblMensajes_Emergentes_Titulo] ([Id], [Titulo], [FechaCreacion], [FechaModificacion]) 
        VALUES (5, N'No Modificado!', CURRENT_TIMESTAMP, NULL)
    END

    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes_Titulo] WHERE [Id] = 6)
    BEGIN
        INSERT [dbo].[tblMensajes_Emergentes_Titulo] ([Id], [Titulo], [FechaCreacion], [FechaModificacion]) 
        VALUES (6, N'Registrado!', CURRENT_TIMESTAMP, NULL)
    END

    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes_Titulo] WHERE [Id] = 7)
    BEGIN
        INSERT [dbo].[tblMensajes_Emergentes_Titulo] ([Id], [Titulo], [FechaCreacion], [FechaModificacion]) 
        VALUES (7, N'No registrado!', CURRENT_TIMESTAMP, NULL)
    END

    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes_Titulo] WHERE [Id] = 8)
    BEGIN
        INSERT [dbo].[tblMensajes_Emergentes_Titulo] ([Id], [Titulo], [FechaCreacion], [FechaModificacion]) 
        VALUES (8, N'Ocurrió un problema!', CURRENT_TIMESTAMP, NULL)
    END

    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes_Titulo] WHERE [Id] = 9)
    BEGIN
        INSERT [dbo].[tblMensajes_Emergentes_Titulo] ([Id], [Titulo], [FechaCreacion], [FechaModificacion]) 
        VALUES (9, N'Creación', CURRENT_TIMESTAMP, NULL)
    END

    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes_Titulo] WHERE [Id] = 10)
    BEGIN
        INSERT [dbo].[tblMensajes_Emergentes_Titulo] ([Id], [Titulo], [FechaCreacion], [FechaModificacion]) 
        VALUES (10, N'Modificación', CURRENT_TIMESTAMP, NULL)
    END

    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes_Titulo] WHERE [Id] = 11)
    BEGIN
        INSERT [dbo].[tblMensajes_Emergentes_Titulo] ([Id], [Titulo], [FechaCreacion], [FechaModificacion]) 
        VALUES (11, N'Actualizado!', CURRENT_TIMESTAMP, NULL)
    END

    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes_Titulo] WHERE [Id] = 12)
    BEGIN
        INSERT [dbo].[tblMensajes_Emergentes_Titulo] ([Id], [Titulo], [FechaCreacion], [FechaModificacion]) 
        VALUES (12, N'No Actualizado!', CURRENT_TIMESTAMP, NULL)
    END

    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes_Titulo] WHERE [Id] = 13)
    BEGIN
        INSERT [dbo].[tblMensajes_Emergentes_Titulo] ([Id], [Titulo], [FechaCreacion], [FechaModificacion]) 
        VALUES (13, N'¿Está seguro que desea cambiar el estado de las denominaciones?', CURRENT_TIMESTAMP, NULL)
    END

    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes_Titulo] WHERE [Id] = 14)
    BEGIN
        INSERT [dbo].[tblMensajes_Emergentes_Titulo] ([Id], [Titulo], [FechaCreacion], [FechaModificacion]) 
        VALUES (14, N'¿Está seguro que desea cambiar el estado de las divisas?', CURRENT_TIMESTAMP, NULL)
    END

    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes_Titulo] WHERE [Id] = 15)
    BEGIN
        INSERT [dbo].[tblMensajes_Emergentes_Titulo] ([Id], [Titulo], [FechaCreacion], [FechaModificacion]) 
        VALUES (15, N'¿Está seguro que desea cambiar el estado de las presentaciones del efectivo?', CURRENT_TIMESTAMP, NULL)
    END

    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes_Titulo] WHERE [Id] = 16)
    BEGIN
        INSERT [dbo].[tblMensajes_Emergentes_Titulo] ([Id], [Titulo], [FechaCreacion], [FechaModificacion]) 
        VALUES (16, N'¿Está seguro que desea cambiar el estado de la unidad de medida?', CURRENT_TIMESTAMP, NULL)
    END

    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes_Titulo] WHERE [Id] = 17)
    BEGIN
        INSERT [dbo].[tblMensajes_Emergentes_Titulo] ([Id], [Titulo], [FechaCreacion], [FechaModificacion]) 
        VALUES (17, N'¿Está seguro que desea cambiar el estado de la agencia?', CURRENT_TIMESTAMP, NULL)
    END

    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes_Titulo] WHERE [Id] = 18)
    BEGIN
        INSERT [dbo].[tblMensajes_Emergentes_Titulo] ([Id], [Titulo], [FechaCreacion], [FechaModificacion]) 
        VALUES (18, N'¿Desea agregar la cuenta a la agencia?', CURRENT_TIMESTAMP, NULL)
    END

    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes_Titulo] WHERE [Id] = 19)
    BEGIN
        INSERT [dbo].[tblMensajes_Emergentes_Titulo] ([Id], [Titulo], [FechaCreacion], [FechaModificacion]) 
        VALUES (19, N'¿Esta seguro que desea cambiar el estado del grupo?', CURRENT_TIMESTAMP, NULL)
    END

    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes_Titulo] WHERE [Id] = 20)
    BEGIN
        INSERT [dbo].[tblMensajes_Emergentes_Titulo] ([Id], [Titulo], [FechaCreacion], [FechaModificacion]) 
        VALUES (20, N'¿Desea agregar la cuenta al grupo?', CURRENT_TIMESTAMP, NULL)
    END

    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes_Titulo] WHERE [Id] = 21)
    BEGIN
        INSERT [dbo].[tblMensajes_Emergentes_Titulo] ([Id], [Titulo], [FechaCreacion], [FechaModificacion]) 
        VALUES (21, N'¿Está seguro que desea activar/desactivar los CEDIS seleccionados?', CURRENT_TIMESTAMP, NULL);
    END

    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes_Titulo] WHERE [Id] = 22)
    BEGIN
        INSERT [dbo].[tblMensajes_Emergentes_Titulo] ([Id], [Titulo], [FechaCreacion], [FechaModificacion]) 
        VALUES (22, N'¿Está seguro que desea cambiar el estado del País?', CURRENT_TIMESTAMP, NULL);
    END

    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes_Titulo] WHERE [Id] = 23)
    BEGIN
        INSERT [dbo].[tblMensajes_Emergentes_Titulo] ([Id], [Titulo], [FechaCreacion], [FechaModificacion]) 
        VALUES (23, N'¿Está seguro que desea cambiar el estado del departamento?', CURRENT_TIMESTAMP, NULL);
    END

    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes_Titulo] WHERE [Id] = 24)
    BEGIN
        INSERT [dbo].[tblMensajes_Emergentes_Titulo] ([Id], [Titulo], [FechaCreacion], [FechaModificacion]) 
        VALUES (24, N'¿Está seguro que desea cambiar el estado de las matrices seleccionados?', CURRENT_TIMESTAMP, NULL);
    END

    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes_Titulo] WHERE [Id] = 1017)
    BEGIN
        INSERT [dbo].[tblMensajes_Emergentes_Titulo] ([Id], [Titulo], [FechaCreacion], [FechaModificacion]) 
        VALUES (1017, N'¿Está seguro que desea cambiar el estado de los roles seleccionados?', CURRENT_TIMESTAMP, NULL);
    END

    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes_Titulo] WHERE [Id] = 1018)
    BEGIN
        INSERT [dbo].[tblMensajes_Emergentes_Titulo] ([Id], [Titulo], [FechaCreacion], [FechaModificacion]) 
        VALUES (1018, N'¿Está seguro que desea cambiar el estado de las areas seleccionadas?', CURRENT_TIMESTAMP, NULL);
    END

    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes_Titulo] WHERE [Id] = 1019)
    BEGIN
        INSERT [dbo].[tblMensajes_Emergentes_Titulo] ([Id], [Titulo], [FechaCreacion], [FechaModificacion]) 
        VALUES (1019, N'¿Está seguro que desea cambiar el estado de los usuarios seleccionadas?', CURRENT_TIMESTAMP, NULL);
    END

    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes_Titulo] WHERE [Id] = 1020)
    BEGIN
        INSERT [dbo].[tblMensajes_Emergentes_Titulo] ([Id], [Titulo], [FechaCreacion], [FechaModificacion]) 
        VALUES (1020, N'Información', CURRENT_TIMESTAMP, NULL);
    END

    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes_Titulo] WHERE [Id] = 1021)
    BEGIN
        INSERT [dbo].[tblMensajes_Emergentes_Titulo] ([Id], [Titulo], [FechaCreacion], [FechaModificacion]) 
        VALUES (1021, N'Confirmación', CURRENT_TIMESTAMP, NULL);
    END

    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes_Titulo] WHERE [Id] = 1023)
    BEGIN
        INSERT [dbo].[tblMensajes_Emergentes_Titulo] ([Id], [Titulo], [FechaCreacion], [FechaModificacion]) 
        VALUES (1023, N'¿Está seguro que desea cambiar el estado de las transportadoras?', CURRENT_TIMESTAMP, NULL);
    END

    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes_Titulo] WHERE [Id] = 1024)
    BEGIN
        INSERT [dbo].[tblMensajes_Emergentes_Titulo] ([Id], [Titulo], [FechaCreacion], [FechaModificacion]) 
        VALUES (1024, N'Restaurado', CURRENT_TIMESTAMP, NULL);
    END

    SET IDENTITY_INSERT [dbo].[tblMensajes_Emergentes_Titulo] OFF
END
GO
--******************************************************************************************
--- T A B L A	>>	 [ D B O . T B L M E N S A J E S _ E M E R G E N T E S ]
--******************************************************************************************
DECLARE @MENSAJE1 VARCHAR(50) = 'Se cambio el estado';
DECLARE @MENSAJE2 VARCHAR(50) = 'El campo Nombre es obligatorio';
DECLARE @MENSAJE3 VARCHAR(50) = 'Se recibió el JSON vacío o un JSON inválido.';
DECLARE @MENSAJE4 VARCHAR(50) = 'Ya existe un cedis con los datos que indica';
DECLARE @MENSAJE5 VARCHAR(100) = 'Uno o más de los registros que intenta cambiar de estado poseen valores inactivos o erróneos';
DECLARE @ERRORMENSAJE VARCHAR(50) = 'Error JSON';
DECLARE @ERRORMENSAJE2 VARCHAR(60) = 'Constrains_Validate_Relaciones_Padre_AgenciaBancaria';
DECLARE @ERRORMENSAJE3 VARCHAR(50) = 't2_C5_Desactivacion_Valida';

IF EXISTS(SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA  = 'dbo' AND TABLE_NAME = 'tblMensajes_Emergentes') BEGIN
    ---
    SET IDENTITY_INSERT [dbo].[tblMensajes_Emergentes] ON
    ---
    
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 1) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(1, 1, 1, 1, 1, 'Se elimino el comunicado', NULL, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 2) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(2, 1, 1, 2, 2, 'Error en el delete SP_DeleteComunicado', NULL, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 3) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(3, 1, 2, 3, 3, 'No podras revertir esto!', NULL, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 4) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(4, 1, 3, 1, 11, 'Se cambio el estado del banner', NULL, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 5) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(5, 1, 3, 2, 12, 'No se pudo cambiar el estado del banner', NULL, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 6) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(6, 1, 4, 1, 6, 'Se creó la notificación', NULL, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 7) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(7, 1, 4, 2, 7, 'El comunicado que intenta ingresar existe actualmente', 'tblComunicado_C4_EXISTE_COMUNICADO', CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 8) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(8, 1, 4, 2, 7, 'Ya alcanzaste el máximo de comunicados', 'tblComunicado_C6_MAXIMO_COMUNICADOS', CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 9) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(9, 1, 5, 3, 8, 'Mensaje o el tipo de mensaje esta vacio', NULL, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 10) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(10, 2, 6, 1, 6, 'Se registro satisfactoriamente la denominacion!', NULL, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 11) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(11, 2, 6, 2, 7, 'La combinación de Valor Nominal, el tipo de Divisa y la presentación ya existen', 'UNIQUE_NOMINAL_DIVISA_BMO', CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 12) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(12, 2, 7, 2, 8, 'Los campos Valor nominal, Nombre, Presentación de la denominación y  Divisa son obligatorio', NULL, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 13) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(13, 2, 8, 3, 9, '¿Confirma la creación de la nueva denominación?', NULL, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 14) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(14, 2, 9, 1, 4, 'Se modifico satisfactoriamente la denominacion!', NULL, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 15) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(15, 2, 9, 2, 5, 'La combinación de Valor Nominal, el tipo de Divisa y la presentación ya existen', 'UNIQUE_NOMINAL_DIVISA_BMO', CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 16) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(16, 2, 9, 2, 5, 'Está tratando de activar la denominación con un valor inactivo ó inválido', 'Contrains_Validate_Relaciones_Denominaciones', CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 17) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(17, 2, 10, 2, 8, 'Los campos Valor nominal, Nombre, Presentación de la denominación y  Divisa son obligatorios', NULL, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 18) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(18, 2, 11, 3, 10, '¿Confirma la modificación de la denominación?', NULL, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 19) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(19, 2, 12, 1, 11, @MENSAJE1, NULL, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 20) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(20, 2, 12, 2, 12, 'Una o varias Denominaciones tienen valores relacionados en estado inactivo', 'Contrains_Validate_Relaciones_Denominaciones', CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 21) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(21, 2, 13, 3, 13, 'Al cambiar el estado de la denominacion puede inhabilitar las denominaciones que la componen!', NULL, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 22) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(22, 3, 14, 1, 6, 'Divisa insertada con exito!', NULL, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 23) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(23, 3, 14, 2, 7, 'Ya existe una divisa con los datos que indica.', 'Unique_Nombre_Divisa', CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 24) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(24, 3, 14, 2, 7, 'El símbolo de la divisa ya existe', 'Unique_Nomenclatura_Divisa', CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 25) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(25, 3, 7, 2, 8, 'Los campos Nombre, Símbolo, Descripción y Presentaciones habilitadas son obligatorias', NULL, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 26) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(26, 3, 15, 3, 9, '¿Confirma la creación de la nueva divisa?', NULL, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 27) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(27, 3, 19, 3, 10, '¿Confirma la modificación de la divisa?', NULL, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 28) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(28, 3, 10, 2, 8, 'Los campos Nombre, Símbolo, Descripción y Presentaciones habilitadas son obligatorias', NULL, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 29) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(29, 3, 16, 2, 5, 'El nombre de la divisa ya existe', 'Unique_Nombre_Divisa', CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 30) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(30, 3, 16, 2, 5, 'El símbolo de la divisa ya existe', 'Unique_Nomenclatura_Divisa', CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 31) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(31, 3, 16, 2, 8, 'La divisa posee valores inactivos relacionados, debe modificar esos valores para ejecutar esta acción ', 'Constrains_Validate_Valores_Inactivos', CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 32) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(32, 3, 16, 2, 8, 'Esta divisa tiene Denominaciones, Unidades de Medidas, Matrices de Atribución, Cuentas de Agencias, Grupos de Agencias o Tipos de Cambios activos relacionados, debe desactivar todos los valores relacionados antes de desactivar esta divisa', 'Constrains_Validate_Relaciones_Divisas', CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 33) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(33, 3, 16, 2, 5, 'Esta divisa tiene unidades de medidas relacionadas con algunas presentaciones, debe desvincular las presentaciones antes de quitarlas de esta divisa', 'Validar_Relaciones_Tipo_Efectivo_Unidades_Medida', CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 34) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(34, 3, 16, 2, 5, 'Esta divisa tiene denominaciones relacionadas con algunas presentaciones, debe desvincular las presentaciones antes de quitarlas de esta divisa', 'Validar_Relaciones_Tipo_Efectivo_Denominaciones', CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 35) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(35, 3, 16, 1, 4, 'Se modifico satisfactoriamente la divisa!', NULL, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 36) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(36, 3, 17, 1, 11, @MENSAJE1, NULL, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 37) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(37, 3, 17, 2, 12, 'Uno o varios de los registros seleccionados tienen valores relacionados en estado activo o inactivo', 'Constrains_Validate_Valores_Inactivos', CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 38) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(38, 3, 17, 2, 12, 'Uno o varios de los registros seleccionados tienen valores relacionados en estado activo o inactivo', 'Constrains_Validate_Relaciones_Divisas', CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 39) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(39, 3, 18, 3, 14, 'Al cambiar el estado de las divisas puedes inhabilitarlas!', NULL, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 40) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(40, 4, 25, 1, 6, 'Se registro satisfactoriamente la presentacion del efectivo', NULL, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 41) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(41, 4, 25, 2, 7, 'El nombre de la presentación del efectivo que intenta ingresar ya existe', 'Unique_Nombre_TipoEfectivo', CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 42) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(42, 4, 20, 2, 5, 'Una o varias Presentaciones tiene denominaciones, divisas o unidades de medida activas relacionadas, debe desactivar todas los valores relacionados para efectuar esta acción', 'Constrains_Validate_Relaciones_TipoEfectivo', CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 43) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(43, 4, 20, 2, 5, 'El nombre de la presentación del efectivo que intenta ingresar ya existe', 'Unique_Nombre_TipoEfectivo', CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 44) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(44, 4, 20, 1, 4, 'Se modifico satisfactoriamente la presentacion del efectivo!', NULL, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 45) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(45, 4, 21, 3, 9, '¿Confirma la creación de la nueva presentacion del efectivo?', NULL, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 46) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(46, 4, 7, 2, 8, 'El campo nombre es obligatorio', NULL, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 47) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(47, 4, 10, 2, 8, @MENSAJE2, NULL, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 48) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(48, 4, 22, 3, 10, '¿Confirma la modificación de la presentacion del efectivo?', NULL, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 49) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(49, 4, 23, 1, 11, @MENSAJE1, NULL, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 50) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(50, 4, 23, 2, 12, 'Una o varias Presentaciones tiene denominaciones, divisas o unidades de medida activas relacionadas, debe desactivar todas los valores relacionados para efectuar esta acción', 'Constrains_Validate_Relaciones_TipoEfectivo', CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 51) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(51, 4, 24, 3, 15, 'Al cambiar el estado de los efectivo puedes inhabilitarlos!', NULL, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 52) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(52, 5, 26, 1, 6, 'Unidad de medida insertada con exito!', NULL, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 53) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(53, 5, 26, 2, 7, 'El nombre de la unidad de medida ya existe', 'Unique_Nombre_UnidadMedida', CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 54) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(54, 5, 26, 2, 7, 'El símbolo de la unidad de medida ya existe', 'Unique_Simbolo_UnidadMedida', CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 55) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(55, 5, 26, 2, 7, @MENSAJE3, @ERRORMENSAJE, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 56) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(56, 5, 27, 2, 5, @MENSAJE3, @ERRORMENSAJE, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 57) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(57, 5, 27, 2, 5, 'El nombre de la unidad de medida ya existe', 'Unique_Nombre_UnidadMedida', CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 58) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(58, 5, 27, 2, 5, 'El símbolo de la unidad de medida ya existe', 'Unique_Simbolo_UnidadMedida', CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 59) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(59, 5, 27, 1, 4, 'Unidad de medida editada con exito!', NULL, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 60) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(60, 5, 28, 2, 12, @MENSAJE3, @ERRORMENSAJE, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 61) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(61, 5, 28, 2, 12, 'Error, al intentar actualizar los estados de medidas seleccionados', 'JSON Diferente', CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 62) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(62, 5, 28, 1, 11, @MENSAJE1, NULL, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 63) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(63, 5, 29, 3, 16, 'Al cambiar el estado de los registros seleccionados, puedes inhabilitarlos!', NULL, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 64) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(64, 5, 29, 2, 8, 'Por favor, asegúrese de seleccionar registros de la tabla.', NULL, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 65) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(65, 5, 30, 3, 9, '¿Confirma la creación de la nueva unidad de medida?', NULL, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 66) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(66, 5, 31, 2, 8, 'Los campos Nombre, Símbolo, Divisa, Cantidad de Unidades y Presentaciones habilitadas son obligatorios', NULL, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 67) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(67, 5, 32, 3, 10, '¿Confirma la Modificación de la nueva unidad de medida?', NULL, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 68) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(68, 5, 33, 2, 8, 'Los campos Nombre, Símbolo, Divisa, Cantidad de Unidades y Presentaciones habilitadas son obligatorios', NULL, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 69) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(69, 6, 34, 1, 6, 'Se registro con exito la agencia bancaria!', NULL, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 70) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(70, 6, 34, 2, 7, 'El branch de la agencia ya existe', 'Unique_Codigo_Branch', CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 71) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(71, 6, 34, 2, 7, 'El nombre de la agencia ya existe', 'Unique_Codigo_Agencia', CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 72) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(72, 6, 34, 2, 7, @MENSAJE3, @ERRORMENSAJE, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 73) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(73, 6, 35, 1, 4, 'Se modifico satisfactoriamente la agencia!', NULL, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 74) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(74, 6, 35, 2, 5, 'El branch de la agencia ya existe', 'Unique_Codigo_Branch', CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 75) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(75, 6, 35, 2, 5, 'El nombre de la agencia ya existe', 'Unique_Codigo_Agencia', CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 76) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(76, 6, 35, 2, 5, 'Está tratando de activar la Agencia con un valor inactivo o inválido', 'tblAgencias_C3_4_5_Reactivacion_Valida', CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 77) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(77, 6, 35, 2, 5, @MENSAJE3, @ERRORMENSAJE, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 78) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(78, 6, 36, 1, 11, 'Se cambio el estado exitosamente', NULL, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 79) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(79, 6, 36, 2, 12, 'Uno o más de los registros seleccionados posee valores activos o inactivos relacionados', 'tblAgencias_C3_4_5_Reactivacion_Valida', CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 80) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(80, 6, 37, 3, 17, 'Al cambiar el estado de la agencia puede inhabilitarla!', NULL, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 81) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(81, 6, 38, 2, 8, 'Los campos Nombre, Branch, Provincia, Cantón, Distrito y Dirección, País, CEDI y Grupo de Agencias son obligatorios', NULL, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 82) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(82, 6, 39, 3, 18, 'Ya existe la cuenta', NULL, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 83) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(83, 6, 40, 3, 10, '¿Confirma la modificación de la agencia?', NULL, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 84) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(84, 6, 41, 3, 9, '¿Confirma la creación de la agencia?', NULL, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 85) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(85, 6, 42, 1, 8, 'Ya existe la cuenta', NULL, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 86) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(86, 6, 43, 1, 8, 'Existe la cuenta en el grupo', NULL, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 87) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(87, 7, 44, 1, 6, 'Se registro satisfactoriamente el grupo!', NULL, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 88) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(88, 7, 44, 2, 7, 'El nombre del grupo que intenta ingresar ya existe', 'Unique_Nombre_Grupo_Agencia', CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 89) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(89, 7, 45, 1, 4, 'Se modifico satisfactoriamente el grupo!', NULL, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 90) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(90, 7, 45, 2, 5, 'El nombre del grupo que intenta ingresar ya existe', 'Unique_Nombre_Grupo_Agencia', CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 91) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(91, 7, 46, 1, 11, 'Se cambio el estado exitosamente', NULL, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 92) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(92, 7, 46, 2, 12, 'Este Grupo de Agencias tiene Agencias Bancarias activas relacionadas, debe desactivar todos los valores relacionados antes de desactivar este Grupo de agencias', 'Constrains_Validate_Relaciones_GrupoAgencia', CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 93) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(93, 7, 45, 2, 5, 'Este Grupo de Agencias tiene Agencias Bancarias activas relacionadas, debe desactivar todos los valores relacionados antes de desactivar este Grupo de agencias', 'Constrains_Validate_Relaciones_GrupoAgencia', CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 94) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(94, 7, 47, 3, 19, 'Al cambiar el estado del grupo puede inhabilitarla!', NULL, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 95) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(95, 7, 39, 3, 20, 'Ya existe la cuenta', NULL, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 96) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(96, 7, 40, 3, 10, '¿Confirma la modificación del grupo?', NULL, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 97) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(97, 7, 38, 2, 8, 'Debe ingresar un nombre para el grupo', NULL, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 98) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(98, 7, 41, 3, 9, '¿Confirma la creación del nuevo grupo de agencias?', NULL, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 99) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(99, 8, 49, 1, 4, 'Se modifico satisfactoriamente el Cedi!', NULL, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 100) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(100, 8, 49, 2, 5, @MENSAJE4, 'Unique_Nombre_Cedis', CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 101) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(101, 8, 49, 2, 5, 'No se puede deshabilitar un CEDI si existen agencias o usuarios activos ligados a este', 'Constrains_Validate_Relaciones_Padre_Cedis', CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 102) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(102, 8, 49, 2, 5, 'Está tratando de activar el CEDI con un valor inactivo o inválido', 'tblCedis_C4_Asignacion_Pais_Activo', CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 103) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(103, 8, 49, 2, 5, 'se recibió el JSON vacio o un JSON inválido.', @ERRORMENSAJE, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 104) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(104, 8, 48, 1, 6, 'Se registro con exito el Cedi', NULL, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 105) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(105, 8, 48, 2, 7, @MENSAJE4, 'Unique_Nombre_Cedis', CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 106) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(106, 8, 48, 2, 7, 'No puede ingresar datos inactivos al cedis', 'tblCedis_C4_Asignacion_Pais_Activo', CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 107) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(107, 8, 48, 2, 7, @MENSAJE4, 'Unique_Codigo_Cedis', CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 108) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(108, 8, 49, 2, 5, @MENSAJE4, 'Unique_Codigo_Cedis', CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 109) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(109, 8, 48, 2, 7, 'se recibió el JSON vacio o un JSON inválido.', @ERRORMENSAJE, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 110) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(110, 8, 50, 1, 11, 'Estados de Cedis actualizados con exito', NULL, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 111) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(111, 8, 50, 2, 12, 'Uno o varios de los registros seleccionados poseen valores relacionados en estado Activo o Inactivo', 'Constrains_Validate_Relaciones_Padre_Cedis', CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 112) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(112, 8, 50, 2, 12, 'Uno o varios de los registros seleccionados poseen valores relacionados en estado Activo o Inactivo', 'tblCedis_C4_Asignacion_Pais_Activo', CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 113) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(113, 8, 50, 2, 12, 'se recibió el JSON vacio o un JSON inválido.', @ERRORMENSAJE, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 114) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(114, 8, 51, 3, 21, 'Al cambiar el estado de los Cedis puedes inhabilitarlos!', NULL, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 115) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(115, 8, 52, 3, 9, '¿Confirma la creación del nuevo Cedi?', NULL, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 116) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(116, 8, 7, 2, 8, 'Los campos Nombre y País son obligatorios', NULL, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 117) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(117, 8, 53, 3, 10, '¿Confirma la modificación de la cedi?', NULL, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 118) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(118, 8, 10, 2, 8, 'Los campos Nombre y País son obligatorios', NULL, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 119) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(119, 9, 54, 1, 11, 'Estados de Paises actualizados con exito', NULL, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 120) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(120, 9, 54, 2, 12, 'se recibió el JSON vacio o un JSON inválido.', @ERRORMENSAJE, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 121) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(121, 9, 55, 1, 6, 'Se registro con exito el pais', NULL, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 122) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(122, 9, 55, 2, 7, 'Ya existe un pais con los datos que indica', 'Unique_Nombre_Pais', CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 123) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(123, 9, 55, 2, 7, 'se recibió el JSON vacio o un JSON inválido.', @ERRORMENSAJE, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 124) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(124, 9, 56, 1, 4, 'Se modifico con exito el pais', NULL, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 125) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(125, 9, 56, 2, 5, 'Este País posee CEDIS, Agencias, Transportadoras o Usuarios activos relacionados, debe desactivar todos los valores relacionados antes de efectuar esta acción', 'Constrains_Validate_Relaciones_Pais', CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 126) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(126, 9, 56, 2, 5, 'Ya existe un pais con los datos que indica', 'Unique_Nombre_Pais', CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 127) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(127, 9, 56, 2, 5, 'se recibió el JSON vacio o un JSON inválido.', @ERRORMENSAJE, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 128) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(128, 9, 54, 2, 12, 'Uno o varios Países tienen CEDIS, Agencias, Transportadoras o Usuarios activos relacionados, debe desactivar todos los valores relacionados para efectuar esta acción', 'Constrains_Validate_Relaciones_Pais', CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 129) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(129, 9, 57, 3, 22, 'Al cambiar el estado de los registros seleccionados, puedes inhabilitarlos!', NULL, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 130) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(130, 9, 58, 3, 9, '¿Confirma la creación del nuevo país?', NULL, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 131) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(131, 9, 7, 2, 8, @MENSAJE2, NULL, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 132) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(132, 9, 59, 3, 10, '¿Confirma la modificación del país?', NULL, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 133) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(133, 9, 10, 2, 8, @MENSAJE2, NULL, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 134) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(134, 10, 60, 1, 11, 'Estados de departamentos actualizados con exito', NULL, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 135) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(135, 10, 60, 2, 12, 'Uno o varios de los departamentos poseen Áreas, Roles o usuarios activos relacionados, debe desactivar todos los valores relacionados antes de efectuar esta acción', 'Constrains_Validate_Relaciones_Departamento', CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 136) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(136, 10, 60, 2, 12, 'se recibió el JSON vacio o un JSON inválido.', @ERRORMENSAJE, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 137) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(137, 10, 61, 1, 6, 'Se registro con exito el departamento', NULL, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 138) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(138, 10, 61, 2, 7, 'Ya existe un departamento con los datos que indica', 't2_C1_Unique_Nombre_Departamento', CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 139) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(139, 10, 61, 2, 7, 'se recibió el JSON vacio o un JSON inválido.', @ERRORMENSAJE, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 140) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(140, 10, 62, 1, 4, 'Se modifico con exito el departamento', NULL, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 141) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(141, 10, 62, 2, 5, 'Este Departamento posee Areas, Roles o Usuarios activos relacionados, debe desactivar todos los valores relacionados antes de efectuar esta acción', 'Constrains_Validate_Relaciones_Departamento', CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 142) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(142, 10, 62, 2, 5, 'Ya existe un departamento con los datos que indica', 't2_C1_Unique_Nombre_Departamento', CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 143) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(143, 10, 62, 2, 5, 'se recibió el JSON vacio o un JSON inválido.', @ERRORMENSAJE, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 144) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(144, 10, 63, 3, 23, 'Al cambiar el estado de los departamentos puedes inhabilitarlos!', NULL, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 145) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(145, 10, 64, 3, 9, '¿Confirma la creación del nuevo departamento?', NULL, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 146) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(146, 10, 7, 2, 8, @MENSAJE2, NULL, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 147) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(147, 10, 65, 3, 10, '¿Confirma la modificación del departamento?', NULL, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 148) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(148, 10, 10, 2, 8, @MENSAJE2, NULL, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 149) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(149, 11, 66, 1, 11, 'Estados de Matriz actualizados con exito', NULL, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 150) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(150, 11, 66, 2, 12, @MENSAJE5, 'tblMatrizAtribucion_C3_Cambiar_Estados', CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 151) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(151, 11, 66, 2, 12, 'La matriz que desea desactivar presenta usuarios activos o inactivos ligados, debe desligar esos usuarios para poder efectuar esta acción', 'tblMatrizAtribucion_X_USUARIO_DESACTIVAR', CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 152) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(152, 11, 66, 2, 12, 'se recibió el JSON vacio o un JSON inválido.', @ERRORMENSAJE, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 153) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(153, 11, 67, 1, 6, 'Se registro con exito la matriz de atribucion!', NULL, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 154) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(154, 11, 67, 2, 7, 'El nombre de la matriz ya existe', 'Unique_Nombre_tblMatrizAtribucion', CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 155) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(155, 11, 67, 2, 7, 'Está tratando de activar la matriz de atribucion con un valor inactivo o invalido', 'tblMatrizAtribucion_C3_Cambiar_Estados', CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 156) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(156, 11, 67, 2, 7, 'se recibió el JSON vacio o un JSON inválido.', @ERRORMENSAJE, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 157) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(157, 11, 67, 2, 7, 'La transaccion ya existe en otra matriz', 'Relacion_Unica_Transaccion_Matriz', CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 158) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(158, 11, 68, 1, 4, 'Se actualizo con exito la matriz de atribucion!', NULL, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 159) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(159, 11, 68, 2, 5, 'El nombre de la matriz ya existe', 'Unique_Nombre_tblMatrizAtribucion', CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 160) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(160, 11, 68, 2, 5, 'Está tratando de activar la matriz de atribucion con un valor inactivo o invalido', 'tblMatrizAtribucion_C3_Cambiar_Estados', CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 161) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(161, 11, 68, 2, 5, 'La matriz que desea desactivar presenta usuarios activos o inactivos ligados, debe desligar esos usuarios para poder efectuar esta acción', 'tblMatrizAtribucion_X_USUARIO_DESACTIVAR', CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 162) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(162, 11, 68, 2, 5, 'se recibió el JSON vacio o un JSON inválido.', @ERRORMENSAJE, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 163) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(163, 11, 69, 3, 24, 'Al cambiar el estado de la matriz puede inhabilitarla!', NULL, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 164) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(164, 11, 40, 3, 10, '¿Confirma la modificación de la matriz?', NULL, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 165) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(165, 11, 38, 2, 8, 'Los campos Nombre, Transacciones para las que aplica y Divisa son obligatorios, ademas debe definir al menos una firma cuyo valor Hasta sea mayor a cero', NULL, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 166) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(166, 11, 41, 3, 9, '¿Confirma la creación de la matriz?', NULL, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 167) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(167, 13, 1036, 1, 4, 'Se actualizó correctamente el rol', NULL, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 168) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(168, 13, 1036, 2, 8, 'se recibió el JSON vacio o un JSON inválido.', @ERRORMENSAJE, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 169) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(169, 13, 1036, 2, 8, @MENSAJE5, 'Validation_Status_Roles', CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 170) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(170, 13, 1036, 2, 8, 'Este rol tiene usuarios activos relacionados, debe desactivar todos los usuarios antes de desactivar este rol', 'Validation_Relation_Roles', CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 171) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(171, 13, 1036, 2, 8, 'Ya existe un rol con los datos que indica.', 'Unique_Nombre_Rol', CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 172) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(172, 13, 1037, 1, 6, 'Se agregó correctamente el rol', NULL, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 173) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(173, 13, 1037, 2, 8, 'se recibió el JSON vacio o un JSON inválido.', @ERRORMENSAJE, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 174) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(174, 13, 1037, 2, 8, @MENSAJE5, 'Validation_Status_Roles', CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 175) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(175, 13, 1037, 2, 8, 'Ya existe un rol con los datos que indica.', 'Unique_Nombre_Rol', CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 176) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(176, 13, 1038, 1, 11, 'Los estados de los roles fueron actualizadas correctamente', NULL, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 177) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(177, 13, 1038, 2, 8, 'se recibió el JSON vacio o un JSON inválido.', @ERRORMENSAJE, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 178) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(178, 13, 1038, 2, 8, @MENSAJE5, 'Validation_Status_Roles', CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 179) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(179, 13, 1038, 2, 8, 'Este rol tiene usuarios activos relacionados, debe desactivar todos los usuarios antes de desactivar este rol', 'Validation_Relation_Roles', CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 180) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(180, 13, 1039, 3, 1017, 'Al cambiar el estado de los roles puedes inhabilitarlas!', NULL, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 181) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(181, 13, 1040, 3, 9, '¿Confirma la creación del nuevo rol?', NULL, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 182) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(182, 13, 1041, 3, 3, '¿Confirma que el rol es NO originador?', NULL, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 183) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(183, 13, 1042, 2, 8, 'Los campos Nombre, departamento y área son obligatorios y debe asignar al menos 1 funcionalidad', NULL, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 184) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(184, 13, 1043, 3, 10, '¿Confirma la modificación del rol?', NULL, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 185) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(185, 13, 1044, 3, 3, '¿Confirma que el rol es NO originador?', NULL, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 186) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(186, 12, 1045, 1, 6, 'Se agregó correctamente el área', NULL, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 187) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(187, 12, 1045, 2, 8, 'El nombre de área ya existe asociada al departamento. Favor seleccionar otro nombre o cambiar el departamento.', 't2_C1_Unique_Nombre_Area', CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 188) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(188, 12, 1045, 2, 8, 'El departamento seleccionado no existe actualmente en base de datos', 't2_C2_Foreign_Key_Departamento', CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 189) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(189, 12, 1045, 2, 8, 'El departamento se encuentra inactivo en base de datos. Favor seleccionar otro departamento que sea valido', 't2_C3_Asignacion_Departamento_Activo', CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 190) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(190, 12, 1046, 1, 4, 'Se actualizó correctamente el área', NULL, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 191) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(191, 12, 1046, 2, 8, 'El nombre de área ya existe asociada al departamento. Favor seleccionar otro nombre o cambiar el departamento.', 't2_C1_Unique_Nombre_Area', CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 192) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(192, 12, 1046, 2, 8, 'El departamento seleccionado no existe actualmente en base de datos', 't2_C2_Foreign_Key_Departamento', CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 193) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(193, 12, 1046, 2, 8, 'El departamento se encuentra inactivo en base de datos. Favor seleccionar otro departamento que sea valido', 't2_C3_Asignacion_Departamento_Activo', CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 194) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(194, 12, 1047, 1, 11, 'Los estados de las areas fueron actualizadas correctamente', NULL, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 195) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(195, 12, 1047, 2, 8, 'Uno o más de los registros seleccionados posee valores activos o inactivos relacionados', 't2_C4_Reactivacion_Valida', CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 196) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(196, 12, 1039, 3, 1018, 'Al cambiar el estado de las áreas puedes inhabilitarlas!', NULL, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 197) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(197, 12, 1040, 3, 9, '¿Confirma la creación de la nueva área?', NULL, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 198) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(198, 12, 1042, 2, 8, 'Los campos Nombre y Departamento son obligatorios', NULL, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 199) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(199, 12, 1043, 3, 10, '¿Confirma la modificación del area?', NULL, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 200) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(200, 14, 1039, 3, 1019, 'Al cambiar el estado de los usuarios puedes inhabilitarlas!', NULL, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 201) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(201, 14, 1040, 3, 9, '¿Confirma la creación de un nuevo usuario?', NULL, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 202) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(202, 14, 1043, 3, 10, '¿Confirma la modificación del usuario?', NULL, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 203) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(203, 14, 1042, 2, 8, 'Todos los campos son obligatorios', NULL, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 204) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(204, 14, 1048, 1, 6, 'Se agregó correctamente el usuario', NULL, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 205) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(205, 14, 1048, 2, 8, 'Formato JSON invalido o mal formado para la lista de agencias asociadas al usuario', 'Eval_JSON_Agencias_Invalido', CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 206) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(206, 14, 1048, 2, 8, 'El usuario que intenta ingresar requiere al menos una agencia valida', 'Eval_Usuario_Requiere_Agencia', CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 207) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(207, 14, 1048, 2, 8, 'Formato JSON invalido o mal formado para la lista de firmas asociadas al usuario', 'Eval_JSON_Matriz_Firmas_Invalido', CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 208) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(208, 14, 1048, 2, 8, 'El usuario requiere al menos una firma valida', 'Eval_Usuario_Requiere_Firmas', CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 209) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(209, 14, 1048, 2, 8, 'El Rol que seleccionó deben existir en el catálogo de roles del sistema', 'Eval_Rol_Debe_Existir', CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 210) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(210, 14, 1048, 2, 8, 'El usuario de red que intenta registrar ya existe en el sistema', 'Unique_Usuario_Red', CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 211) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(211, 14, 1048, 2, 8, 'El correo electronico que intenta registrar ya existe en el sistema', 'Unique_Correo_Electronico', CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 212) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(212, 14, 1048, 2, 8, 'El número de colaborador que intenta registrar ya existe en el sistema', 'Unique_Numero_Colaborador', CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 213) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(213, 14, 1048, 2, 8, 'El nombre del colaborador que intenta registrar solo puede contener: (Letras(Mayusculas/minusculas/Tildes/Espacios)', 'Eval_Regex_Nombre', CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 214) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(214, 14, 1048, 2, 8, 'El Primer apellido del colaborador que intenta registrar solo puede contener: (Letras(Mayusculas/minusculas/Tildes/Espacios)', 'Eval_Regex_Apellido1', CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 215) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(215, 14, 1048, 2, 8, 'El Segundo apellido del colaborador que intenta registrar solo puede contener: (Letras(Mayusculas/minusculas/Tildes/Espacios)', 'Eval_Regex_Apellido2', CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 216) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(216, 14, 1048, 2, 8, 'El dominio de correo que intenta registrar no es valido', 'Eval_Dominio_Email', CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 217) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(217, 14, 1048, 2, 8, 'Es requerido que usuario sea aprobador para tener firmas', 'Eval_Requerido_Ser_Aprobador', CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 218) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(218, 14, 1048, 2, 8, 'El usuario tiene un rol originador. Por tanto no está permitido asociar más de una agencia al mismo.', 'Eval_Ligar_Usuario_Agencia_Invalido', CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 219) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(219, 14, 1048, 2, 8, 'Está intentando asociar una o varias agencia(s) al usuario que no existe.', 'Eval_Agencia_Debe_Existir', CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 220) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(220, 14, 1048, 2, 8, 'El usuario y la agencia ya se encuentran ligas. No se pueden duplicar registros.', 'Unique_Usuario_Agencia', CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 221) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(221, 14, 1048, 2, 8, 'El usuario que intenta ligar a la agencia no existe en el catálogo de usuarios.', 'Eval_Violacion_Usuario_Inexistente', CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 222) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(222, 14, 1048, 2, 8, 'Una o varias de las firmas que intenta ligar al usuario no existen en el catalogo de firmas del sistema.', 'EVAL_Matriz_Firma_debe_existir', CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 223) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(223, 14, 1048, 2, 8, 'El usuario que intenta ligar con la(s) fimra(s) debe existir.', 'EVAL_Usuario_debe_existir_Asociar_Firma', CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 224) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(224, 14, 1048, 2, 8, 'Una de las firmas y el usuario ya se encuentran asociadas.', 'Unique_Usuario_Matriz_Firma', CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 225) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(225, 14, 1048, 2, 8, 'La matrices contienen varias firmas. Pero solo se puede asociar una firma por matriz al usuario.', 'EVAL_Solo_Una_Firma_Por_Matriz', CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 226) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(226, 14, 1049, 1, 4, 'Se actualizó correctamente el usuario', NULL, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 227) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(227, 14, 1049, 2, 8, 'Formato JSON invalido o mal formado para la lista de agencias asociadas al usuario', 'Eval_JSON_Agencias_Invalido', CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 228) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(228, 14, 1049, 2, 8, 'El usuario que intenta ingresar requiere al menos una agencia valida', 'Eval_Usuario_Requiere_Agencia', CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 229) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(229, 14, 1049, 2, 8, 'Formato JSON invalido o mal formado para la lista de firmas asociadas al usuario', 'Eval_JSON_Matriz_Firmas_Invalido', CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 230) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(230, 14, 1049, 2, 8, 'El usuario requiere al menos una firma valida', 'Eval_Usuario_Requiere_Firmas', CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 231) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(231, 14, 1049, 2, 8, 'El Rol que seleccionó deben existir en el catálogo de roles del sistema', 'Eval_Rol_Debe_Existir', CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 232) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(232, 14, 1049, 2, 8, 'El usuario de red que intenta registrar ya existe en el sistema', 'Unique_Usuario_Red', CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 233) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(233, 14, 1049, 2, 8, 'El correo electronico que intenta registrar ya existe en el sistema', 'Unique_Correo_Electronico', CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 234) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(234, 14, 1049, 2, 8, 'El número de colaborador que intenta registrar ya existe en el sistema', 'Unique_Numero_Colaborador', CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 235) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(235, 14, 1049, 2, 8, 'El nombre del colaborador que intenta registrar solo puede contener: (Letras(Mayusculas/minusculas/Tildes/Espacios)', 'Eval_Regex_Nombre', CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 236) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(236, 14, 1049, 2, 8, 'El Primer apellido del colaborador que intenta registrar solo puede contener: (Letras(Mayusculas/minusculas/Tildes/Espacios)', 'Eval_Regex_Apellido1', CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 237) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(237, 14, 1049, 2, 8, 'El Segundo apellido del colaborador que intenta registrar solo puede contener: (Letras(Mayusculas/minusculas/Tildes/Espacios)', 'Eval_Regex_Apellido2', CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 238) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(238, 14, 1049, 2, 8, 'El dominio de correo que intenta registrar no es valido', 'Eval_Dominio_Email', CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 239) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(239, 14, 1049, 2, 8, 'Es requerido que usuario sea aprobador para tener firmas', 'Eval_Requerido_Ser_Aprobador', CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 240) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(240, 14, 1049, 2, 8, 'El usuario tiene un rol originador. Por tanto no está permitido asociar más de una agencia al mimo.', 'Eval_Ligar_Usuario_Agencia_Invalido', CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 241) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(241, 14, 1049, 2, 8, 'Está intentando asociar una o varias agencia(s) al usuario que no existe.', 'Eval_Agencia_Debe_Existir', CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 242) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(242, 14, 1049, 2, 8, 'El usuario y la agencia ya se encuentran ligas. No se pueden duplicar registros.', 'Unique_Usuario_Agencia', CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 243) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(243, 14, 1049, 2, 8, 'El usuario que intenta ligar a la agencia no existe en el catálogo de usuarios.', 'Eval_Violacion_Usuario_Inexistente', CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 244) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(244, 14, 1049, 2, 8, 'Una o varias de las firmas que intenta ligar al usuario no existen en el catalogo de firmas del sistema.', 'EVAL_Matriz_Firma_debe_existir', CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 245) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(245, 14, 1049, 2, 8, 'El usuario que intenta ligar con la(s) fimra(s) debe existir.', 'EVAL_Usuario_debe_existir_Asociar_Firma', CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 246) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(246, 14, 1049, 2, 8, 'Una de las firmas y el usuario ya se encuentran asociadas.', 'Unique_Usuario_Matriz_Firma', CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 247) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(247, 14, 1049, 2, 8, 'La matrices contienen varias firmas. Pero solo se puede asociar una firma por matriz al usuario.', 'EVAL_Solo_Una_Firma_Por_Matriz', CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 248) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(248, 14, 1050, 1, 11, 'Los estados de los usuarios fueron actualizados correctamente', NULL, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 249) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(249, 14, 1050, 2, 8, 'Uno o más de los registros que intenta cambiar de estado poseen valores inactivos o erróneos.', 'Validar_Change_Estado', CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 250) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(250, 14, 1048, 2, 8, 'Es requerido indicar un usuario gestor durante la creación de un usuario nuevo', 'Eval_Usuario_Gestor_Requerido_Mantenimiento_Usuarios', CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 251) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(251, 14, 1048, 2, 8, 'El usuario en gestion ingresado es inexistente', 'Eval_Usuario_En_Gestion_No_Existe', CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 252) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(252, 14, 1048, 2, 8, 'El usuario originador ingresado es inexistente', 'Eval_Usuario_Originador_No_Existe', CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 253) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(253, 14, 1048, 2, 8, 'El tipo de gestion ingresado es inexistente', 'Eval_FK_Tipo_Gestion_No_Existe', CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 254) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(254, 14, 1048, 2, 8, 'El número de gestión generado por el sistema ya existe. No se puede duplicar numeros de gestión', 'Unique_G_Numero_Gestion_Usuario', CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 255) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(255, 14, 1048, 2, 8, 'Es requierido que se indique el usuario anterior y el modificado en formato JSON', 'REQUIRED_G_Usuario_Prev_Post_JSON', CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 256) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(256, 14, 1048, 2, 8, 'Un usuario no puede crear gestiones de modificación a si mismo', 'EVAL_G_Usuario_Originador_Y_En_Gestion_Iguales', CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 257) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(257, 14, 1048, 2, 8, 'No se puede modificar algunos de los usuarios seleccionados, dado tienen gestiones pendientes', 'EVAL_G_Usuario_Tiene_Gestiones_Pendientes', CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 258) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(258, 1, 1054, 3, 1020, 'Posee mensajes en edición, si abandona esta ventana el mensaje no se publicará', NULL, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 259) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(259, 14, 1056, 2, 8, 'No se puedo finalizar algunas gestiones. Uno o más de los IDs no existen', 'Eval_ID_Gestion_No_Existe', CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 260) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(260, 14, 1056, 2, 8, 'No se puedo finalizar algunas gestiones. Es requerido indicar un estado valido para finalizar la gestión', 'Eval_FK_Estado_Gestion_No_Existe', CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 261) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(261, 14, 1056, 2, 8, 'Una o más gestiones ya se ecuentran finalizadas', 'Eval_Gestion_Ya_Fue_Finalizada', CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 262) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(262, 14, 1056, 2, 8, 'Debe anotar en comentarios el motivo de rechazo para cada gestión', 'REQUIRED_G_Comentario_Requerido', CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 263) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(263, 14, 1056, 2, 8, 'No se puedo finalizar algunas gestiones. El usuario que aprueba/rechazar la gestión, no puede finalizarse gestiones a si mismo', 'EVAL_G_Usuario_Aprobador_Y_En_Gestion_Iguales', CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 264) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(264, 14, 1056, 2, 8, 'No se puedo finalizar algunas gestiones. Es requerido un usuario aprobador para finalizar la gestión', 'EVAL_G_Requerido_Finalizar_Gestion_Por_Usuario_Aprobador', CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 265) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(265, 11, 1060, 3, 1021, '¿Confirma que desea eliminar la firma seleccionada? Revise que no esté dejando un intervalo de montos sin firma de aprobación', NULL, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 266) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(266, 6, 1063, 2, 8, 'Los campos Nombre, Branch, Provincia, Cantón, Distrito y Dirección, País, CEDI y Grupo de Agencias son obligatorios. Debe seleccionar ambas transportadoras de solicitud y envío de remesas.', NULL, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 267) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(267, 6, 1061, 2, 8, 'Los campos Nombre, Branch, Provincia, Cantón, Distrito y Dirección, País, CEDI y Grupo de Agencias son obligatorios. Debe seleccionar la transportadora de solicitud de remesas.', NULL, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 268) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(268, 6, 1062, 2, 8, 'Los campos Nombre, Branch, Provincia, Cantón, Distrito y Dirección, País, CEDI y Grupo de Agencias son obligatorios. Debe seleccionar la transportadora de envío de remesas.', NULL, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 269) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(269, 14, 1067, 1, 11, 'Todas las gestiones seleccionadas fueron finalizadas correctamente', NULL, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 270) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(270, 14, 1056, 2, 8, 'No se pudo optener la información de los usuario en gestion. La gestón no existe.', 'EVAL_Gestion_Usuario_Inexistente', CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 271) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(271, 15, 1051, 3, 9, '¿Confirma la creación de la nueva empresa de logística de efectivo?', NULL, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 272) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(272, 15, 1053, 1, 6, 'Empresa de logística de efectivo insertada con exito!.', NULL, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 273) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(273, 15, 1053, 2, 7, 'Ya existe una empresa de logística de efectivo con los datos que indica.', 'Unique_Nombre_Transportadora_By_Pais_And_Modulo', CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 274) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(274, 15, 1053, 2, 7, 'El Código de la empresa de logística de efectivo ya existe.', 'Unique_Codigo_Transportadora', CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 275) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(275, 15, 1053, 2, 8, 'Los campos nombre, país y módulo son obligatorios', 'SP_Insert_Transportadora_VALORES_NULL', CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 276) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(276, 15, 1071, 3, 10, '¿Confirma los cambios?', NULL, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 277) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(277, 15, 1072, 1, 4, 'Empresa de logística de efectivo modificada con exito!.', NULL, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 278) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(278, 15, 1072, 2, 7, 'Ya existe una empresa de logística de efectivo con los datos que indica.', 'Unique_Nombre_Transportadora_By_Pais_And_Modulo', CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 279) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(279, 15, 1072, 2, 7, 'El Código de la empresa de logística de efectivo ya existe.', 'Unique_Codigo_Transportadora', CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 280) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(280, 15, 1072, 2, 8, 'Los campos nombre, país y módulo son obligatorios', 'SP_Update_Transportadora_VALORES_NULL', CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 281) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(281, 16, 1055, 3, 8, 'La hora limite mismo día es requerida cuando se habilita las entregas para el mismo día('' + @NOMBRE_DIA + '')', 'Check_Hora_Limite_Mismo_Dia_Requerido', CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 282) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(282, 16, 1055, 3, 8, 'CONCAT(''La hora limite mismo día('', CONVERT(char(5), @HORA_LIMITE_MISMO_DIA, 108), '') debe estár entre el rango seleccionado. Hora desde('', CONVERT(char(5), @HORA_DESDE, 108), '') y hora hasta('', CONVERT(char(5), @HORA_HASTA, 108), '') para el día '', @NOMBRE_DIA)', 'Check_Hora_Limite_Mismo_Dia_Valida', CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 283) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(283, 16, 1055, 3, 8, 'Obligatorio seleccionar un día de entrega más como respaldo. Note que esto ocurre al marcar unicamente el día imediato al '' + @NOMBRE_DIA + '' para entregas. Tome en concideración que '' + @NOMBRE_DIA + '' no cuenta como día de respaldo', 'Check_Regla_De_Los_Dos_Dias', CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 284) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(284, 16, 1055, 3, 8, 'La hora  límite de aprobación es requerida para todos los días previos a los días de entrega habilitados.', 'Check_Regla_De_La_Hora_Limite_Aprobacion_Null', CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 285) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(285, 16, 1055, 3, 8, 'Para el día '' + @NOMBRE_DIA + '' la hora hasta debe ser previa a la  hora limite de aprobación.', 'Check_Regla_De_La_Hora_Limite_Aprobacion_Superior_Hora_Desde', CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 286) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(286, 15, 1073, 3, 1023, 'Al cambiar el estado de las empresas de logística de efectivo puedes inhabilitarlas!', NULL, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 287) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(287, 15, 1074, 1, 11, 'Se cambió el estado', NULL, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 288) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(288, 15, 1074, 2, 12, 'Uno o varios de los registros seleccionados tienen valores relacionados en estado activo o inactivo', 'Constrains_Validate_Valores_Activos_Inactivos_Contra_Transportadoras', CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 289) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(289, 15, 1072, 2, 8, 'Esta empresa de logística de efectivo tiene agencias activas relacionadas, debe desactivar todos los valores relacionados antes de ejecutar esta acción.', 'Constrains_Validate_Valores_Activos_Inactivos_Contra_Transportadoras', CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 290) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(290, 6, 35, 2, 8, 'Esta Agencia posee Usuarios activos relacionados, debe desactivar todos los valores relacionados antes de efectuar esta acción', @ERRORMENSAJE2, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 291) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(291, 6, 36, 2, 8, 'Una o varias de las Agencias poseen Usuarios activos relacionados, debe desactivar todos los valores relacionados antes de efectuar esta acción', @ERRORMENSAJE2, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 292) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(292, 12, 1046, 2, 8, 'Esta Area posee Usuarios o Roles activos relacionados, debe desactivar todos los valores relacionados antes de efectuar esta acción', @ERRORMENSAJE3, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 293) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(293, 12, 1047, 2, 8, 'Uno o más de los registros seleccionados posee valores activos o inactivos relacionados', @ERRORMENSAJE3, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 294) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(294, 15, 1072, 2, 8, 'Está tratando de activar la empresa de logística de efectivo con un valor inactivo o inválido', 'Constrains_Validate_Relaciones_Activas_Inactivas_Contra_Transportadoras_2', CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 295) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(295, 6, 35, 2, 8, 'Esta Agencia posee Usuarios activos relacionados, debe desactivar todos los valores relacionados antes de efectuar esta acción', @ERRORMENSAJE2, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 296) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(296, 6, 36, 2, 8, 'Una o varias de las Agencias poseen Usuarios activos relacionados, debe desactivar todos los valores relacionados antes de efectuar esta acción', @ERRORMENSAJE2, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 297) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(297, 12, 1046, 2, 8, 'Esta Area posee Usuarios o Roles activos relacionados, debe desactivar todos los valores relacionados antes de efectuar esta acción', @ERRORMENSAJE3, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 298) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(298, 12, 1047, 2, 8, 'Una o varias de las Áreas poseen Roles o Usuarios activos relacionados, debe desactivar todos los valores relacionados antes de efectuar esta acción', @ERRORMENSAJE3, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 299) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(299, 3, 1075, 1, 6, 'Se registro con exito el pedido externo a boveda!', NULL, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 300) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(300, 3, 1075, 2, 8, 'El estado que intenta asociar al pedido no existe en el catalogo de estados', 'Fk_PEXT_EstadoPedido', CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 301) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(301, 3, 1075, 2, 8, 'La agencia que intenta asociar al pedido no es valida', 'FK_PEXT_Agencia_Valdio', CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 302) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(302, 3, 1075, 2, 8, 'El grupo de la agencia que intenta asociar al pedido no es valida', 'FK_PEXT_Grupo_Valdio', CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 303) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(303, 3, 1075, 2, 8, 'El CEDI que intenta asociar al pedido no es valido', 'FK_PEXT_CEDI_Valdio', CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 304) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(304, 3, 1075, 2, 8, 'El País que intenta asociar al pedido no es valido', 'FK_PEXT_Pais_Valdio', CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 305) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(305, 3, 1075, 2, 8, 'La transportadora que intenta asociar al pedido no es valida', 'FK_PEXT_Transportadora_Valdia', CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 306) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(306, 3, 1075, 2, 8, 'El usuario que intenta crear el pedido no es valido', 'FK_PEXT_UsuarioOriginador_Valdio', CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 307) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(307, 3, 1075, 2, 8, 'Es requerido el tipo de cambio en dolares para poder realizar un pedido', 'FK_PEXT_TipoCmabioUSD_Valdio', CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 308) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(308, 3, 1075, 2, 8, 'Es requerido el tipo de cambio en euros para poder realizar un pedido', 'FK_PEXT_TipoCmabioEUR_Valdio', CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 309) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(309, 3, 1075, 2, 8, 'El número de pedido auto-generado debe ser unico', 'Unique_PEXT_NumPedido', CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 310) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(310, 3, 1075, 2, 8, 'El usuario que intenta realizar el pedido no es valido', 'EVAL_PEXT_Usuario_Originador_Valdio', CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 311) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(311, 3, 1075, 2, 8, 'La agencia y el usuario con los cuales se intenta realizar el pedido no son vailidos', 'EVAL_PEXT_Ligue_Agencia_X_Usuario_Valido', CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 312) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(312, 3, 1075, 2, 8, 'El pais, CEDI, Agencia que con los que se intenta realizar el pedido no son validos', 'EVAL_PEXT_Ligue_Agencia_X_Grupo_X_CEDI_X_Pais_Valido', CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 313) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(313, 3, 1075, 2, 8, 'El detalle del pedido requiere un ID de pedido valido', 'Fk_PEXT_FkPedido', CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 314) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(314, 3, 1075, 2, 8, 'Una linea del detalle del pedido contiene una divisa invalida', 'FK_PEXT_Divisa_Valida', CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 315) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(315, 3, 1075, 2, 8, 'Una linea del detalle del pedido contiene una presentación del efectivo invalida', 'FK_PEXT_TipoEfectivo_Valido', CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 316) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(316, 3, 1075, 2, 8, 'Una linea del detalle del pedido contiene una unidad de medida invalida', 'FK_PEXT_UnidadMedida_Valida', CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 317) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(317, 3, 1075, 2, 8, 'Una linea del detalle del pedido contiene una denominación invalida', 'FK_PEXT_Denominacion_Valida', CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 318) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(318, 3, 1075, 2, 8, 'Una linea del detalle del pedido contiene una asosiación divisa Divisa/Presentación/Unidad Medida invalida', 'FK_PEXT_LigueDivisaTipoEfectivoUnidadMedia_Valdio', CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 319) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(319, 3, 1075, 2, 8, 'El pedido que intenta asociar a la firma es invalido', 'Fk_PEXT_DetalleFkPedido', CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 320) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(320, 3, 1075, 2, 8, 'La Matriz y Firma que intenta asociar al pedido ya existe', 'Unique_PEXT_FirmaMatrizUsuarioPeedido', CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 321) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(321, 3, 1075, 2, 8, 'La firma que intenta asociar al pedido es invalida', 'EVAL_PEXT_FK_Firma_Valdia', CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 322) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(322, 3, 1075, 2, 8, 'El usuario asociado a una de las firmas es invalido', 'EVAL_PEXT_FK_UsuarioFirma_Valdio', CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 323) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(323, 3, 1075, 2, 8, 'La firma y el usuario no se encuentran relacionadas', 'EVAL_PEXT_FK_Ligue_FirmaMatrizUsuario_Valdio', CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 324) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(324, 3, 1075, 2, 8, 'La transacción ligada al pedido no es valida', 'EVAL_PEXT_Fk_Transaccion_Valdia', CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 325) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(325, 3, 1075, 2, 8, 'No se ha ingresado el tipo de cambio para el día de hoy', 'PEXT_Eval_Tipo_Cambio_USD_No_Existe', CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 326) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(326, 3, 1075, 2, 8, 'No se ha ingresado el tipo de cambio para el día de hoy', 'PEXT_Eval_Tipo_Cambio_EUR_No_Existe', CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 327) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(327, 3, 1075, 2, 8, 'La agencia no está habilitada para solicitar remesas o no tiene una transportadora asociada', 'PEXT_Eval_Fk_Transportadora_Requerida', CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 328) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(328, 3, 1075, 2, 8, 'No se puede ingresar más de dos pedidos por día para una agencia', 'EVAL_PEXT_Max_Pedidos_Agencia_X_Dia_Valido', CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 329) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(329, 3, 1075, 2, 8, 'El rango de fechas seleccionado no es valido', 'EVAL_PEXT_Rango_Busqueda_Invalido', CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 330) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(330, 3, 1075, 2, 8, 'El rango de búsqueda no puede ser superior a 31 días', 'EVAL_PEXT_Max_Dias_Permitidos_Busqueda', CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 331) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(331, 2, 6, 2, 7, 'La combinacion de denominacion y area ya esta registrada', 'Unique_denominacion_x_area', CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 332) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(332, 2, 6, 2, 8, 'se recibió el JSON vacio o un JSON inválido.', @ERRORMENSAJE, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 333) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(333, 2, 9, 2, 5, 'La combinacion de denominacion y area ya esta registrada', 'Unique_denominacion_x_area', CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 334) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(334, 2, 9, 2, 8, 'se recibió el JSON vacio o un JSON inválido.', @ERRORMENSAJE, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 335) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(335, 2, 12, 2, 8, 'se recibió el JSON vacio o un JSON inválido.', @ERRORMENSAJE, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 336) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(336, 7, 46, 2, 8, 'se recibió el JSON vacio o un JSON inválido.', @ERRORMENSAJE, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 337) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(337, 7, 44, 2, 7, 'El numero de cuenta y el grupo ya se encuentran asociados', 'Unique_cuenta_x_grupo', CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 338) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(338, 7, 44, 2, 8, 'se recibió el JSON vacio o un JSON inválido.', @ERRORMENSAJE, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 339) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(339, 7, 45, 2, 5, 'El numero de cuenta y el grupo ya se encuentran asociados', 'Unique_cuenta_x_grupo', CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 340) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(340, 7, 45, 2, 8, 'se recibió el JSON vacio o un JSON inválido.', @ERRORMENSAJE, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 341) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(341, 6, 43, 2, 8, 'Existe la cuenta en el grupo', 'Existe cuenta grupo', CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 342) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(342, 3, 1080, 1, 11, 'Se registro exitozamente la modificacion!', '', CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 343) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(343, 3, 1080, 2, 8, 'El Id de pedido no existe', 'PEXT_Eval_Id_Pedido_No_Existe', CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 344) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(344, 3, 1075, 2, 8, 'La hora hasta la cual podía solicitar pedidos para entrega al día siguiente ha sido superada, debe regresar al paso 1 y seleccionar otra fecha de entrega.', 'PEXT_Eval_Hora_Hasta_Superada_Fecha_Entrega_Siguiente', CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 345) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(345, 3, 1075, 2, 8, 'La hora hasta la cual podía solicitar pedidos ha sido superada, debe esperar al día siguiente para registrar su solicitud.', 'PEXT_Eval_Hora_Corte_Hoy_Superada', CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 346) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(346, 3, 1075, 2, 8, 'La hora hasta la cual podía solicitar pedidos para ser entregados hoy mismo, ha sido superada, debe regresar al paso 1 y seleccionar otra fecha de entrega.', 'PEXT_Eval_Hora_Hora_Limite_Mismo_Dia_Superada', CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 347) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(347, 3, 1080, 2, 8, 'El registro ya está siendo modificado', 'PK_FK_Pedido__ID', CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 348) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(348, 3, 1080, 2, 8, 'El monto total actualizado debe ser igual o menor al monto original aprobado', 'PEXT_Eval_GranTotalCRC_ExecedeFirmaActual', CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 351) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(351, 3, 1075, 2, 8, 'El identificador(Id) del pedido no existe', 'EVAL_PEXT_Id_PEXT_No_Existe', CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 352) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(352, 3, 1075, 2, 8, 'El Pedido tiene un estado que impide su cancelación', 'EVAL_PEXT_CancelarPEXT_Invalido', CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 353) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(353, 3, 1081, 1, 11, 'Se registro exitozamente la modificacion!', '', CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 354) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(354, 3, 1075, 2, 8, 'El pedido no puede ser cancelado. No se especifico el Usuario que cancela', 'EVAL_PEXT_CancelarPEXT_Fk_Usuario_Cancela_Invalido', CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 365) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(365, 17, 1082, 1, 1024, 'Se restauró exitosamente el pedido', NULL, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 366) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(366, 3, 1080, 2, 8, 'El pedido ya se encuentra en estado cancelado', 'EVAL_PEXT_CancelarPEXT_Ya_Cancelado', CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 367) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(367, 17, 1083, 2, 8, 'Hay registros cuyo estatus cambió y no se pudieron aprobar', 'PEXT_Eval_Aprobacion_Pedido_Pendiente_Igual_Aprobada_Segun_Matriz', CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 368) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(368, 17, 1083, 1, 11, 'Se aprobo exitosamente los pedidos!', NULL, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 369) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(369, 17, 1084, 2, 8, 'Hay registros cuyo estatus cambió y no se pudieron rechazar', 'PEXT_Eval_Rechazar_Pedido_Pendiente_Igual_Aprobada_Segun_Matriz', CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 370) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(370, 17, 1084, 2, 8, 'Algunos registros no tienen el comentario de motivo de rechazo, por lo que no fueron rechazados', 'PEXT_Eval_Rechazar_Pedido_Pendiente_Comentario_Rechazado_Vacio', CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 371) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(371, 17, 1084, 1, 11, 'Se rechazo exitosamente los pedidos!', NULL, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 372) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(372, 3, 1085, 1, 11, 'Se registro exitozamente el rechazo de la(s) firma(s)!', '', CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 373) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(373, 3, 1085, 2, 8, 'No se especifió el Id(Identificador) de la firma', 'EVAL_While_RechazoFirma_PEXT_FirmaId_Requerido', CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 374) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(374, 3, 1085, 2, 8, 'No se especifió el Id(Identificador) del usuario que rechaza la firma', 'EVAL_While_RechazoFirma_PEXT_UsuarioId_Requerido', CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 375) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(375, 3, 1085, 2, 8, 'Algunos registros no tienen el comentario de motivo de rechazo, por lo que no fueron rechazados', 'EVAL_While_RechazoFirma_PEXT_Comentario_Requerido', CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 376) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(376, 3, 1085, 2, 8, 'El Id(Identificador) para una de las firmas a rechazar no existe', 'EVAL_While_RechazoFirma_PEXT_FirmaID_No_Existe', CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 377) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(377, 3, 1085, 2, 8, 'El Id(Identificador) del usuario que rechaza no está asociado a la firma que desea rechazar', 'EVAL_While_RechazoFirma_PEXT_UsuarioID_No_CorrespondeConFirma', CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 378) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(378, 3, 1085, 2, 8, 'El Pedido se encuentra en un estado que imposibilita el rechazo de la firma', 'EVAL_While_RechazoFirma_PEXT_CurrentEstadoPEXT_Invalido', CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 379) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(379, 3, 1085, 2, 8, 'No se puedo rechazar una de las firma. El pedido ya se encuentra en estado "Rechazada según matriz"', 'EVAL_While_RechazoFirma_PEXT_YaRechazado', CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 380) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(380, 3, 1085, 2, 8, 'La firma que intenta rechazar no es la firma actualmente requiere ser atendida. Favor respertar la jerarquia de aprovaciones/rechazos para firmas', 'EVAL_While_RechazoFirma_PEXT_NEXT_FirmaRequeridaInvalida', CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 381) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(381, 3, 1086, 1, 11, 'Se registro exitozamente la aprobación de la(s) firma(s)!', '', CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 382) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(382, 3, 1086, 2, 8, 'La firma que intenta aprobar no es la firma actualmente requiere ser atendida. Favor respertar la jerarquia de aprovaciones/rechazos para firmas', 'EVAL_While_AprobacionFirma_PEXT_NEXT_FirmaRequeridaInvalida', CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 383) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(383, 3, 1086, 2, 8, 'No se especifió el Id(Identificador) de la firma', 'EVAL_While_AprobacionFirma_PEXT_FirmaId_Requerido', CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 384) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(384, 3, 1086, 2, 8, 'No se especifió el Id(Identificador) del usuario que aprueba la firma', 'EVAL_While_AprobacionFirma_PEXT_UsuarioId_Requerido', CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 385) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(385, 3, 1086, 2, 8, 'El Id(Identificador) para una de las firmas a aprobar no existe', 'EVAL_While_AprobacionFirma_PEXT_FirmaID_No_Existe', CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 386) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(386, 3, 1086, 2, 8, 'El Id(Identificador) del usuario que aprueba no está asociado a la firma que desea aprobar', 'EVAL_While_AprobacionFirma_PEXT_UsuarioID_No_CorrespondeConFirma', CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 387) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(387, 3, 1086, 2, 8, 'El Pedido se encuentra en un estado que imposibilita la aprobación de la firma', 'EVAL_While_AprobacionFirma_PEXT_CurrentEstadoPEXT_Invalido', CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 388) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(388, 3, 1075, 2, 8, 'No existen usuarios asociados con la firma requerída para el monto total', 'PEXT_Eval_No_Existe_Usuarios_Firma_Requerida', CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 389) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(389, 17, 1083, 2, 8, 'La acción no se puede efectuar en estos momentos pues el sistema se encuentra en proceso de cierre para el CEDI del registro seleccionado', 'PEXT_Eval_Aprobacion_Pedido_Pendiente_Proceso_Cierre_CEDI', CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 390) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(390, 17, 1087, 1, 11, 'El pedido fue asignado correctamente', NULL, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 392) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(392, 17, 1087, 1, 11, 'Los pedidos fueron asignados correctamente', NULL, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 393) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(393, 17, 1087, 1, 11, 'El pedido se asigno correctamente', NULL, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 394) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(394, 17, 1088, 1, 11, 'El pedido se devolvio correctamente', NULL, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 396) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(396, 3, 1086, 2, 8, 'La firma que intenta aprobar ya fue aprobada o rechazada por otro usuario', 'EVAL_While_AprobacionFirma_PEXT_FirmaID_Ya_Fue_Aprobada', CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 397) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(397, 3, 1086, 2, 8, 'La firma que intenta rechazar ya fue aprobada o rechazada por otro usuario', 'EVAL_While_RechazoFirma_PEXT_FirmaID_Ya_Fue_Rechazada', CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 398) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(398, 3, 1089, 2, 8, 'El registro seleccionado está en un estado que imposibilita su cancelación en este instante. Regrese más tarde e inténtelo nuevamente o póngase en contacto con los administradores del CEDI de su agencia', 'EVAL_While_Estado_PEXT_Invalido', CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 399) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(399, 3, 1090, 1, 6, 'Se registro exitozamente el saldo cierre de la Agencia', '', CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 400) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(400, 3, 1090, 2, 8, 'No se puede ingresar más de un saldo cierre por dia por Agencia', 'FK_SCA_SaldoCierreAgenciaDiarioUnico', CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 401) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(401, 3, 1090, 2, 8, 'La Agencia que se ingreso no es valido o no existe en el sistema', 'FK_SCA_Agencia_Valdio', CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 402) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(402, 3, 1090, 2, 8, 'El Grupo Agencia que se ingreso no es valido o no existe en el sistema', 'FK_SCA_Grupo_Valdio', CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 403) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(403, 3, 1090, 2, 8, 'El CEDI que se ingreso no es valido o no existe en el sistema', 'FK_SCA_CEDI_Valdio', CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 404) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(404, 3, 1090, 2, 8, 'El Pais que se ingreso no es valido o no existe en el sistema', 'FK_SCA_Pais_Valdio', CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 405) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(405, 3, 1090, 2, 8, 'El Usuario Originador que se ingreso no es valido o no existe en el sistema', 'FK_SCA_UsuarioOriginador_Valdio', CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 406) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(406, 3, 1090, 2, 8, 'El Número de saldo de cierre auto-generado debe ser unico', 'Unique_SCA_NumSaldoCierreAgencia', CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 407) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(407, 3, 1090, 2, 8, 'La Agencia/Pais/CEDI/Usuario no se encuentran asociados entre si. No se puede crear el registro', 'EVAL_SCA_Ligue_Agencia_X_Usuario_Valido', CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 408) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(408, 3, 1090, 2, 8, 'La referencia(Id) al registro "Saldo Cierre Agencia" especificado no existe', 'Fk_SCA_FkSaldoCierreAgencia', CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 409) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(409, 3, 1090, 2, 8, 'La referencia(Id) al registro "Divisa" especificado no existe', 'FK_SCA_Divisa_Valida', CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 410) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(410, 3, 1090, 2, 8, 'La referencia(Id) al registro "Tipo Efectivo" especificado no existe', 'FK_SCA_TipoEfectivo_Valido', CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 411) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(411, 3, 1090, 2, 8, 'La referencia(Id) al registro "Denominacion" especificado no existe', 'FK_SCA_Denominacion_Valida', CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 412) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(412, 3, 1075, 2, 8, 'Una de las divisas de su solicitud no posee tipo de cambio registrado', 'Eval_TC_X_Divisa_Requerido', CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 413) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(413, 3, 1086, 2, 8, 'La acción no se puede efectuar en estos momentos pues el sistema se encuentra en proceso de cierre para el CEDI del registro seleccionado', 'EVAL_BloqueoPorRangoCierreAgencia', CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 414) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(414, 17, 1092, 2, 8, 'Hay registros cuyo estatus cambió y no se pudieron devolver', 'PEXT_Eval_Devolver_Pedido_Asignado_Igual_Asignado', CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 415) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(415, 17, 1092, 2, 8, 'La acción no se puede efectuar en estos momentos pues el sistema se encuentra en proceso de cierre para el CEDI del registro seleccionado', 'PEXT_Eval_Preparacion_Pedido_Asignados_Proceso_Cierre_CEDI', CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 416) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(416, 17, 1092, 1, 11, 'El pedido se devolvio correctamente', NULL, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 417) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(417, 17, 1093, 2, 8, 'Hay registros cuyo estatus cambió y no se pudieron mandar a preparacion', 'PEXT_Eval_Preparar_Pedido_Asignado_Igual_Asignado', CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 418) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(418, 17, 1093, 1, 11, 'El pedido se mando a preparar correctamente', NULL, CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 419) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(419, 3, 1080, 2, 8, 'El pedido fue Cancelado', 'PEXT_Eval_Id_Pedido_Cancelado', CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 420) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(420, 18, 1075, 2, 8, 'Algunos registros se encuentran en un estado que impide su cancelación. Regrese más tarde e inténtelo nuevamente o póngase en contacto con los administradores del CEDI de su agencia', 'EVAL_PEXT_ESTADO_INVALIDO_01', CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 421) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(421, 18, 1075, 2, 8, 'Algunos registros se encuentran en un estado que impide su cancelación', 'EVAL_PEXT_ESTADO_INVALIDO_02', CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 422) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(422, 20, 1090, 2, 8, 'El cierre del día anterior no se puede modificar cuando ya se ingresó el cierre del día en curso', 'EVAL_SCA_No_Modificable_Penultimo', CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 423) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(423, 20, 1090, 2, 8, 'Este cierre ya no se puede modificar ', 'EVAL_SCA_No_Modificable_X_Antiguedad', CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 425) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(425, 3, 1094, 2, 8, 'El rango de búsqueda no puede ser superior a 6 meses', 'EVAL_PEXT_Max_Dias_Permitidos_Busqueda', CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
    IF NOT EXISTS (SELECT 1 FROM [dbo].[tblMensajes_Emergentes] WHERE Id = 426) BEGIN
        INSERT INTO [dbo].[tblMensajes_Emergentes] ([Id], [Fk_Modulo], [Fk_Metodo], [Fk_TipoMensaje], [Fk_Titulo], [Mensaje], [ErrorMensaje], [FechaCreacion], [FechaModificacion]) 
        VALUES(426, 3, 1094, 2, 8, 'El rango de fechas seleccionado no es valido', 'EVAL_PEXT_Rango_Busqueda_Invalido', CAST(CURRENT_TIMESTAMP AS SMALLDATETIME), NULL);
    END
    ---
     SET IDENTITY_INSERT [dbo].[tblMensajes_Emergentes] OFF
    ---
END
GO
----------------------------------------------------------------------------
--- I N S E R T		T R A N S A C C I O N E S
----------------------------------------------------------------------------
IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblTransacciones')
BEGIN
    SET IDENTITY_INSERT [dbo].[tblTransacciones] ON 

    IF NOT EXISTS ( SELECT * FROM [dbo].[tblTransacciones] where [Id] = 1)
    BEGIN

        INSERT [dbo].[tblTransacciones] ([Id], [Nombre], [Fk_Id_Modulo], [Codigo], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES (1, N'Pedidos externos', 3, N'PEXT(30/08/2023)00001', 1,CURRENT_TIMESTAMP, NULL)

    END

    IF NOT EXISTS ( SELECT * FROM [dbo].[tblTransacciones] where [Id] = 2)
    BEGIN

        INSERT [dbo].[tblTransacciones] ([Id], [Nombre], [Fk_Id_Modulo], [Codigo], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES (2, N'Entregas Externas', 3, N'EEXT(30/08/2023)00002', 1, CURRENT_TIMESTAMP, NULL)

    END

    IF NOT EXISTS ( SELECT * FROM [dbo].[tblTransacciones] where [Id] = 3)
    BEGIN

        INSERT [dbo].[tblTransacciones] ([Id], [Nombre], [Fk_Id_Modulo], [Codigo], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES (3, N'Exportaciones', 3, N'EXP(30/08/2023)00003', 1, CURRENT_TIMESTAMP, NULL)

    END

    IF NOT EXISTS ( SELECT * FROM [dbo].[tblTransacciones] where [Id] = 4)
    BEGIN

        INSERT [dbo].[tblTransacciones] ([Id], [Nombre], [Fk_Id_Modulo], [Codigo], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES (4, N'Saldo de Cierre de Agencias', 3, N'SCA(19/04/2024)00004', 1, CURRENT_TIMESTAMP, NULL)

    END

    SET IDENTITY_INSERT [dbo].[tblTransacciones] OFF
END
GO
----------------------------------------------------------------------------
--- I N S E R T		P A I S
----------------------------------------------------------------------------
IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblPais')
BEGIN
    SET IDENTITY_INSERT [dbo].[tblPais] ON 

    IF NOT EXISTS ( SELECT * FROM [dbo].[tblPais] where [Id] = 1)
    BEGIN

        INSERT [dbo].[tblPais] ([Id], [Nombre], [Codigo], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES (1, N'Costa Rica', N'0001', 1, CURRENT_TIMESTAMP, NULL)

    END

    SET IDENTITY_INSERT [dbo].[tblPais] OFF
END
GO
----------------------------------------------------------------------------
--- I N S E R T		C E D I S
----------------------------------------------------------------------------
IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblCedis')
BEGIN
    SET IDENTITY_INSERT [dbo].[tblCedis] ON 

    IF NOT EXISTS ( SELECT * FROM [dbo].[tblCedis] where [Id_Cedis] = 1)
    BEGIN

        INSERT [dbo].[tblCedis] ([Id_Cedis], [Nombre], [Codigo_Cedis], [Fk_Id_Pais], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES (1, N'CEDI Curridabat', N'0001', 1, 1, CURRENT_TIMESTAMP, NULL)

    END

    SET IDENTITY_INSERT [dbo].[tblCedis] OFF
END
GO
-----------------------------------------------------------------------------------------
--- I N S E R T		D I A S  H A B I L E S  E N T R E G A  P E D I D O S  I N T E R N O S
-----------------------------------------------------------------------------------------
DECLARE @HoraLimiteMismoDia VARCHAR(20) = '11:01:00';
DECLARE @HoraHasta VARCHAR(20) = '18:00:00';
DECLARE @HoraDesde VARCHAR(20) = '08:00:00';
DECLARE @HoraLimiteAprobacionMismoDia VARCHAR(20) = '11:02:00';
DECLARE @HoraCorteDia VARCHAR(20) = '23:59:00';
DECLARE @HoraLimiteAprobacion VARCHAR(20) = '23:59:00';

IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblDiasHabilesEntregaPedidosInternos')
BEGIN

    SET IDENTITY_INSERT [dbo].[tblDiasHabilesEntregaPedidosInternos] ON 

    IF NOT EXISTS ( SELECT * FROM [dbo].[tblDiasHabilesEntregaPedidosInternos] where [Id] = 1)
    BEGIN
        INSERT [dbo].[tblDiasHabilesEntregaPedidosInternos] 
        ([Id], [Dia], [FkIdCedis], [NombreDia], [PermiteRemesas], [PermiteEntregasMismoDia], 
         [EntregarLunes], [EntregarMartes], [EntregarMiercoles], [EntregarJueves], 
         [EntregarViernes], [EntregarSabado], [EntregarDomingo], [HoraDesde], 
         [HoraHasta], [HoraLimiteMismoDia], [Codigo], [FechaCreacion], 
         [FechaModificacion], [HoraLimiteAprobacion], [HoraCorteDia], 
         [HoraLimiteAprobacionMismoDia]) 
        VALUES (1, 1, 1, N'Lunes', 1, 1, 0, 1, 1, 1, 0, 0, 0, 
                CAST(@HoraDesde AS Time), CAST(@HoraHasta AS Time), 
                CAST(N@HoraLimiteMismoDia AS Time), N'F78F76ED-C14F-46A2-9BD3-C0DC093C3715', 
                CAST(CURRENT_TIMESTAMP AS SmallDateTime), 
                CAST(CURRENT_TIMESTAMP AS SmallDateTime), 
                CAST(N@HoraLimiteAprobacion AS Time), CAST(N@HoraCorteDia AS Time), 
                CAST(N@HoraLimiteAprobacionMismoDia AS Time))
    END

    IF NOT EXISTS ( SELECT * FROM [dbo].[tblDiasHabilesEntregaPedidosInternos] where [Id] = 2)
    BEGIN
        INSERT [dbo].[tblDiasHabilesEntregaPedidosInternos] 
        ([Id], [Dia], [FkIdCedis], [NombreDia], [PermiteRemesas], [PermiteEntregasMismoDia], 
         [EntregarLunes], [EntregarMartes], [EntregarMiercoles], [EntregarJueves], 
         [EntregarViernes], [EntregarSabado], [EntregarDomingo], [HoraDesde], 
         [HoraHasta], [HoraLimiteMismoDia], [Codigo], [FechaCreacion], 
         [FechaModificacion], [HoraLimiteAprobacion], [HoraCorteDia], 
         [HoraLimiteAprobacionMismoDia]) 
        VALUES (2, 2, 1, N'Martes', 1, 0, 0, 0, 1, 1, 1, 0, 0, 
                CAST(@HoraDesde AS Time), CAST(@HoraHasta AS Time), 
                NULL, N'7026B3B3-3ECE-4CA1-A892-950E7363DFBA', 
                CAST(CURRENT_TIMESTAMP AS SmallDateTime), 
                CAST(CURRENT_TIMESTAMP AS SmallDateTime), 
                CAST(N@HoraLimiteAprobacion AS Time), CAST(N@HoraCorteDia AS Time), NULL)
    END

    IF NOT EXISTS ( SELECT * FROM [dbo].[tblDiasHabilesEntregaPedidosInternos] where [Id] = 3)
    BEGIN
        INSERT [dbo].[tblDiasHabilesEntregaPedidosInternos] 
        ([Id], [Dia], [FkIdCedis], [NombreDia], [PermiteRemesas], [PermiteEntregasMismoDia], 
         [EntregarLunes], [EntregarMartes], [EntregarMiercoles], [EntregarJueves], 
         [EntregarViernes], [EntregarSabado], [EntregarDomingo], [HoraDesde], 
         [HoraHasta], [HoraLimiteMismoDia], [Codigo], [FechaCreacion], 
         [FechaModificacion], [HoraLimiteAprobacion], [HoraCorteDia], 
         [HoraLimiteAprobacionMismoDia]) 
        VALUES (3, 3, 1, N'Miercoles', 1, 0, 0, 0, 0, 1, 1, 0, 0, 
                CAST(@HoraDesde AS Time), CAST(@HoraHasta AS Time), 
                NULL, N'70BD4C48-CFE1-47FA-BA86-85A3F50BC22B', 
                CAST(CURRENT_TIMESTAMP AS SmallDateTime), 
                CAST(CURRENT_TIMESTAMP AS SmallDateTime), 
                CAST(N@HoraLimiteAprobacion AS Time), CAST(N@HoraCorteDia AS Time), NULL)
    END

    IF NOT EXISTS ( SELECT * FROM [dbo].[tblDiasHabilesEntregaPedidosInternos] where [Id] = 4)
    BEGIN
        INSERT [dbo].[tblDiasHabilesEntregaPedidosInternos] 
        ([Id], [Dia], [FkIdCedis], [NombreDia], [PermiteRemesas], [PermiteEntregasMismoDia], 
         [EntregarLunes], [EntregarMartes], [EntregarMiercoles], [EntregarJueves], 
         [EntregarViernes], [EntregarSabado], [EntregarDomingo], [HoraDesde], 
         [HoraHasta], [HoraLimiteMismoDia], [Codigo], [FechaCreacion], 
         [FechaModificacion], [HoraLimiteAprobacion], [HoraCorteDia], 
         [HoraLimiteAprobacionMismoDia]) 
        VALUES (4, 4, 1, N'Jueves', 1, 0, 1, 1, 0, 0, 1, 0, 0, 
                CAST(@HoraDesde AS Time), CAST(@HoraHasta AS Time), 
                NULL, N'4844D405-F412-4842-838D-20B16D039B88', 
                CAST(CURRENT_TIMESTAMP AS SmallDateTime), 
                CAST(CURRENT_TIMESTAMP AS SmallDateTime), 
                CAST(N@HoraLimiteAprobacion AS Time), CAST(N@HoraCorteDia AS Time), NULL)
    END

    IF NOT EXISTS ( SELECT * FROM [dbo].[tblDiasHabilesEntregaPedidosInternos] where [Id] = 5)
    BEGIN
        INSERT [dbo].[tblDiasHabilesEntregaPedidosInternos] 
        ([Id], [Dia], [FkIdCedis], [NombreDia], [PermiteRemesas], [PermiteEntregasMismoDia], 
         [EntregarLunes], [EntregarMartes], [EntregarMiercoles], [EntregarJueves], 
         [EntregarViernes], [EntregarSabado], [EntregarDomingo], [HoraDesde], 
         [HoraHasta], [HoraLimiteMismoDia], [Codigo], [FechaCreacion], 
         [FechaModificacion], [HoraLimiteAprobacion], [HoraCorteDia], 
         [HoraLimiteAprobacionMismoDia]) 
        VALUES (5, 5, 1, N'Viernes', 1, 0, 1, 1, 0, 0, 0, 0, 0, 
                CAST(@HoraDesde AS Time), CAST(@HoraHasta AS Time), 
                NULL, N'B2EF2137-597F-4E31-81EE-A43AC78F1BB6', 
                CAST(CURRENT_TIMESTAMP AS SmallDateTime), 
                CAST(CURRENT_TIMESTAMP AS SmallDateTime), 
                CAST(N@HoraLimiteAprobacion AS Time), CAST(N@HoraCorteDia AS Time), NULL)
    END

    IF NOT EXISTS ( SELECT * FROM [dbo].[tblDiasHabilesEntregaPedidosInternos] where [Id] = 6)
    BEGIN
        INSERT [dbo].[tblDiasHabilesEntregaPedidosInternos] 
        ([Id], [Dia], [FkIdCedis], [NombreDia], [PermiteRemesas], [PermiteEntregasMismoDia], 
         [EntregarLunes], [EntregarMartes], [EntregarMiercoles], [EntregarJueves], 
         [EntregarViernes], [EntregarSabado], [EntregarDomingo], [HoraDesde], 
         [HoraHasta], [HoraLimiteMismoDia], [Codigo], [FechaCreacion], 
         [FechaModificacion], [HoraLimiteAprobacion], [HoraCorteDia], 
         [HoraLimiteAprobacionMismoDia]) 
        VALUES (6, 6, 1, N'Sábado', 0, 0, 0, 0, 0, 0, 0, 0, 1, 
                CAST(@HoraDesde AS Time), CAST(@HoraHasta AS Time), 
                NULL, N'B726D4A1-F9F9-42CA-82CA-DFB484C629DA', 
                CAST(CURRENT_TIMESTAMP AS SmallDateTime), 
                CAST(CURRENT_TIMESTAMP AS SmallDateTime), 
                CAST(N@HoraLimiteAprobacion AS Time), CAST(N@HoraCorteDia AS Time), NULL)
    END

    IF NOT EXISTS ( SELECT * FROM [dbo].[tblDiasHabilesEntregaPedidosInternos] where [Id] = 7)
    BEGIN
        INSERT [dbo].[tblDiasHabilesEntregaPedidosInternos] 
        ([Id], [Dia], [FkIdCedis], [NombreDia], [PermiteRemesas], [PermiteEntregasMismoDia], 
         [EntregarLunes], [EntregarMartes], [EntregarMiercoles], [EntregarJueves], 
         [EntregarViernes], [EntregarSabado], [EntregarDomingo], [HoraDesde], 
         [HoraHasta], [HoraLimiteMismoDia], [Codigo], [FechaCreacion], 
         [FechaModificacion], [HoraLimiteAprobacion], [HoraCorteDia], 
         [HoraLimiteAprobacionMismoDia]) 
        VALUES (7, 7, 1, N'Domingo', 0, 0, 0, 0, 0, 0, 0, 0, 0, 
                CAST(@HoraDesde AS Time), CAST(@HoraHasta AS Time), 
                NULL, N'F70FFAF5-206E-49EB-A8E3-6A8913F33E02', 
                CAST(CURRENT_TIMESTAMP AS SmallDateTime), 
                CAST(CURRENT_TIMESTAMP AS SmallDateTime), 
                NULL, NULL, NULL)
    END

    SET IDENTITY_INSERT [dbo].[tblDiasHabilesEntregaPedidosInternos] OFF

END
GO
----------------------------------------------------------------------------
--- I N S E R T		G R U P O   A G E N C I A 
----------------------------------------------------------------------------
IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblGrupoAgencia')
BEGIN
    SET IDENTITY_INSERT [dbo].[tblGrupoAgencia] ON 

    IF NOT EXISTS ( SELECT * FROM [dbo].[tblGrupoAgencia] where [Id] = 1)
    BEGIN

        INSERT [dbo].[tblGrupoAgencia] ([Id], [Nombre], [Codigo], [EnviaRemesas], [SolicitaRemesas], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES (1, N'Grupo Sucursales', N'8560E123-121A-45FE-AF69-2B13B2315B55', 1, 1, 1, CURRENT_TIMESTAMP, NULL)

    END

    SET IDENTITY_INSERT [dbo].[tblGrupoAgencia] OFF
END
GO
----------------------------------------------------------------------------
--- I N S E R T		D E P A R T A M E N T O 
----------------------------------------------------------------------------
IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblDepartamento')
BEGIN
    SET IDENTITY_INSERT [dbo].[tblDepartamento] ON 

    IF NOT EXISTS ( SELECT * FROM [dbo].[tblDepartamento] where [Id] = 1)
    BEGIN

        INSERT [dbo].[tblDepartamento] ([Id], [Nombre], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES (1, N'TI', 1, CURRENT_TIMESTAMP, NULL)

    END

    SET IDENTITY_INSERT [dbo].[tblDepartamento] OFF
END
GO
----------------------------------------------------------------------------
--- I N S E R T		A R E A 
----------------------------------------------------------------------------
IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblArea')
BEGIN
    SET IDENTITY_INSERT [dbo].[tblArea] ON 

    IF NOT EXISTS ( SELECT * FROM [dbo].[tblArea] where [Id] = 1)
    BEGIN

        INSERT [dbo].[tblArea] ([Id], [Nombre], [Fk_Id_Departamento], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES (1, N'Sucursales', 1, 1, CURRENT_TIMESTAMP, NULL)

    END

    SET IDENTITY_INSERT [dbo].[tblArea] OFF
END
GO
----------------------------------------------------------------------------
--- I N S E R T		A G E N C I A   B A N C A R I A
----------------------------------------------------------------------------
IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblAgenciaBancaria')
BEGIN
    SET IDENTITY_INSERT [dbo].[tblAgenciaBancaria] ON;

    IF NOT EXISTS (SELECT * FROM [dbo].[tblAgenciaBancaria] WHERE [Id] = 1)
    BEGIN

        INSERT [dbo].[tblAgenciaBancaria] ([Id], [Nombre], [Codigo_Agencia], [FkIdGrupoAgencia], [FkIdPais], [FkIdCedi], [UsaCuentasGrupo], [EnviaRemesas], [SolicitaRemesas], [CodigoBranch], [CodigoProvincia], [CodigoCanton], [CodigoDistrito], [Direccion], [Activo], [FechaCreacion], [FechaModificacion], [Fk_Transportadora_Envio], [Fk_Transportadora_Solicitud])
        VALUES (1, N'Sucursal Curridabat', N'00001', 1, 1, 1, 1, 0, 0, N'0001', 1, 118, 11801, N'del pali 50m norte', 1, CURRENT_TIMESTAMP, NULL, NULL, NULL);

    END

    SET IDENTITY_INSERT [dbo].[tblAgenciaBancaria] OFF;
END
GO
----------------------------------------------------------------------------
--- I N S E R T		P A R A M E T R O S
----------------------------------------------------------------------------
IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblParametros')
BEGIN
     SET IDENTITY_INSERT [dbo].[tblParametros] ON;

    IF NOT EXISTS (SELECT * FROM [dbo].[tblParametros] WHERE [Id] = 1)
    BEGIN

        INSERT [dbo].[tblParametros] ([Id], [Codigo], [Nombre], [Descripcion], [Valor], [Activo], [FechaCreacion], [FechaModificacion]) 
        VALUES (1, 1, N'tblDiasHabilesEntregaPedidosInternos_Modificacion_Dia_Actual_Diferente_Dia_Desde_Corte', N'Activa o Desactiva el sp usp_VALIDACION_CONTRAINT_MODIFICACION_MISMO_DIA_VALIDACIONES_tblDiasHabilesEntregaPedidosInternos', N'1', 0, CURRENT_TIMESTAMP, NULL);

    END

    SET IDENTITY_INSERT [dbo].[tblParametros] OFF;
END
GO
----------------------------------------------------------------------------
--- I N S E R T		R E P O R T E S
----------------------------------------------------------------------------
IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblReportes')
BEGIN
        SET IDENTITY_INSERT [dbo].[tblReportes] ON;

        -- Validación e inserción del registro 1
        IF NOT EXISTS (SELECT * FROM [dbo].[tblReportes] WHERE [Id] = 1)
        BEGIN
            INSERT [dbo].[tblReportes] ([Id], [Nombre], [Procedimiento], [Descripcion], [Tiene_Filtro_Fechas], [Es_Reporte_VD], [Fecha_Creacion], [Fecha_Modificacion], [Estado]) 
            VALUES (1, N'Tipo_Efectivo.pdf', N'usp_Select_Data_By_Pdf_Tipo_Efectivo', N'prueba masiva', 0, 0, CURRENT_TIMESTAMP, NULL, 1);
        END
        
        -- Validación e inserción del registro 2
        IF NOT EXISTS (SELECT * FROM [dbo].[tblReportes] WHERE [Id] = 2)
        BEGIN
            INSERT [dbo].[tblReportes] ([Id], [Nombre], [Procedimiento], [Descripcion], [Tiene_Filtro_Fechas], [Es_Reporte_VD], [Fecha_Creacion], [Fecha_Modificacion], [Estado]) 
            VALUES (2, N'Tipo_Efectivo.xlsx', N'usp_Select_Data_By_Excel_Tipo_Efectivo', N'prueba masiva', 0, 0, CURRENT_TIMESTAMP, NULL, 1);
        END
        
        -- Validación e inserción del registro 3
        IF NOT EXISTS (SELECT * FROM [dbo].[tblReportes] WHERE [Id] = 3)
        BEGIN
            INSERT [dbo].[tblReportes] ([Id], [Nombre], [Procedimiento], [Descripcion], [Tiene_Filtro_Fechas], [Es_Reporte_VD], [Fecha_Creacion], [Fecha_Modificacion], [Estado]) 
            VALUES (3, N'Pedidos_Externos.pdf', N'SP_Select_Data_By_Pdf_Pedidos_Externos', N'reporte pdf para pedidos externo en el modulo de boveda', 1, 0, CURRENT_TIMESTAMP, NULL, 1);
        END
        
        -- Validación e inserción del registro 4
        IF NOT EXISTS (SELECT * FROM [dbo].[tblReportes] WHERE [Id] = 4)
        BEGIN
            INSERT [dbo].[tblReportes] ([Id], [Nombre], [Procedimiento], [Descripcion], [Tiene_Filtro_Fechas], [Es_Reporte_VD], [Fecha_Creacion], [Fecha_Modificacion], [Estado]) 
            VALUES (4, N'Pedidos_Externos.xlsx', N'SP_Select_Data_By_Excel_Pedidos_Externos', N'reporte excel para pedidos externo en el modulo de boveda', 1, 0, CURRENT_TIMESTAMP, NULL, 1);
        END
        
        -- Validación e inserción del registro 5
        IF NOT EXISTS (SELECT * FROM [dbo].[tblReportes] WHERE [Id] = 5)
        BEGIN
            INSERT [dbo].[tblReportes] ([Id], [Nombre], [Procedimiento], [Descripcion], [Tiene_Filtro_Fechas], [Es_Reporte_VD], [Fecha_Creacion], [Fecha_Modificacion], [Estado]) 
            VALUES (5, N'Pedidos_Externos_Historico.xlsx', N'SP_Select_Data_By_Excel_Pedidos_Externos_Historico', N'reporte excel para el historico de pedidos', 1, 0, NULL, NULL, 1);
        END
        
        -- Validación e inserción del registro 6
        IF NOT EXISTS (SELECT * FROM [dbo].[tblReportes] WHERE [Id] = 6)
        BEGIN
            INSERT [dbo].[tblReportes] ([Id], [Nombre], [Procedimiento], [Descripcion], [Tiene_Filtro_Fechas], [Es_Reporte_VD], [Fecha_Creacion], [Fecha_Modificacion], [Estado]) 
            VALUES (6, N'Pedidos_Externos_Historico.pdf', N'SP_Select_Data_By_Pdf_Pedidos_Externos_Historico', N'reporte en pdf para el historico de pedidos', 1, 0, NULL, NULL, 1);
        END

        SET IDENTITY_INSERT [dbo].[tblReportes] OFF;
END
GO

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- D O C U M E N T A C I O N  E X T E N S A   D E  C O L U M N A S
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
BEGIN
	---
	DECLARE @_NAME VARCHAR(30) = 'MS_Description';
	DECLARE @_LELEL0TYPE VARCHAR(30) = 'SCHEMA';
	DECLARE @_LELEL0NAME VARCHAR(30) = '';
	DECLARE @_LELEL1TYPE VARCHAR(30) = 'TABLE';
	DECLARE @_LELEL1NAME VARCHAR(30) = '';
	DECLARE @_LELEL2TYPE VARCHAR(30) = 'COLUMN';
	DECLARE @_Id VARCHAR(30) = 'Id';
	DECLARE @_FechaCreacion VARCHAR(30) = 'FechaCreacion';
	DECLARE @_FechaModificacion VARCHAR(30) = 'FechaModificacion';


-------------------------------------- Descripciones para las columnas de tblAgenciaBancaria
    SET @_LELEL0NAME = 'dbo'
	SET @_LELEL1NAME = 'tblAgenciaBancaria'

EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'(dbo.tblAgenciaBancaria) - Indica si la agencia bancaria está activa o no.', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = @_LELEL1NAME, @level2type = @_LELEL2TYPE, @level2name = N'Activo';
EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'(dbo.tblAgenciaBancaria) - Código de la sucursal de la agencia bancaria.', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = @_LELEL1NAME, @level2type = @_LELEL2TYPE, @level2name = N'CodigoBranch';
EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'(dbo.tblAgenciaBancaria) - Código del cantón de la agencia bancaria.', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = @_LELEL1NAME, @level2type = @_LELEL2TYPE, @level2name = N'CodigoCanton';
EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'(dbo.tblAgenciaBancaria) - Código del distrito de la agencia bancaria.', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = @_LELEL1NAME, @level2type = @_LELEL2TYPE, @level2name = N'CodigoDistrito';
EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'(dbo.tblAgenciaBancaria) - Código de la provincia de la agencia bancaria.', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = @_LELEL1NAME, @level2type = @_LELEL2TYPE, @level2name = N'CodigoProvincia';
EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'(dbo.tblAgenciaBancaria) - Dirección de la agencia bancaria.', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = @_LELEL1NAME, @level2type = @_LELEL2TYPE, @level2name = N'Direccion';
EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'(dbo.tblAgenciaBancaria) - Indica si la agencia bancaria envía remesas.', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = @_LELEL1NAME, @level2type = @_LELEL2TYPE, @level2name = N'EnviaRemesas';
EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'(dbo.tblAgenciaBancaria) - Fecha en que se creó el registro de la agencia bancaria.', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = @_LELEL1NAME, @level2type = @_LELEL2TYPE, @level2name = @_FechaCreacion;
EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'(dbo.tblAgenciaBancaria) - Fecha en que se modificó por última vez el registro de la agencia bancaria.', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = @_LELEL1NAME, @level2type = @_LELEL2TYPE, @level2name = @_FechaModificacion;
EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'(dbo.tblAgenciaBancaria) - Identificador del grupo de agencia al que pertenece la agencia bancaria.', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = @_LELEL1NAME, @level2type = @_LELEL2TYPE, @level2name = N'FkIdGrupoAgencia';
EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'(dbo.tblAgenciaBancaria) - Identificador único de tipo entero para la agencia bancaria.', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = @_LELEL1NAME, @level2type = @_LELEL2TYPE, @level2name = @_Id;
EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'(dbo.tblAgenciaBancaria) - Nombre de la agencia bancaria.', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = @_LELEL1NAME, @level2type = @_LELEL2TYPE, @level2name = N'Nombre';
EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'(dbo.tblAgenciaBancaria) - Indica si la agencia bancaria solicita remesas.', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = @_LELEL1NAME, @level2type = @_LELEL2TYPE, @level2name = N'SolicitaRemesas';
EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'(dbo.tblAgenciaBancaria) - Indica si la agencia bancaria utiliza cuentas del grupo de agencia.', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = @_LELEL1NAME, @level2type = @_LELEL2TYPE, @level2name = N'UsaCuentasGrupo';

-------------------------------------- Descripciones para las columnas de tblArea
	SET @_LELEL1NAME = 'tblArea'

EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'(dbo.tblArea) - Indica si el area está activa o no.', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = @_LELEL1NAME, @level2type = @_LELEL2TYPE, @level2name = N'Activo';
EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'(dbo.tblArea) - Identificador del Departamento al que pertenece el area.', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = @_LELEL1NAME, @level2type = @_LELEL2TYPE, @level2name = N'Fk_Id_Departamento';
EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'(dbo.tblArea) - Fecha en que se creó el registro del area.', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = @_LELEL1NAME, @level2type = @_LELEL2TYPE, @level2name = @_FechaCreacion;
EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'(dbo.tblArea) - Fecha en que se modificó por última vez el registro del area.', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = @_LELEL1NAME, @level2type = @_LELEL2TYPE, @level2name = @_FechaModificacion;
EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'(dbo.tblArea) - Nombre del area.', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = @_LELEL1NAME, @level2type = @_LELEL2TYPE, @level2name = N'Nombre';
EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'(dbo.tblArea) - Identificador único de tipo entero para el area.', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = @_LELEL1NAME, @level2type = @_LELEL2TYPE, @level2name = @_Id;

-------------------------------------- Descripciones para las columnas de tblCanton
	SET @_LELEL1NAME = 'tblCanton'

EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'(dbo.tblCanton) - Identificador único de tipo entero para el canton.', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = @_LELEL1NAME, @level2type = @_LELEL2TYPE, @level2name = @_Id;
EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'(dbo.tblCanton) - Nombre del canton.', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = @_LELEL1NAME, @level2type = @_LELEL2TYPE, @level2name = N'Nombre';
EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'(dbo.tblCanton) - Identificador de la provincia a la que pertenece el cantón.', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = @_LELEL1NAME, @level2type = @_LELEL2TYPE, @level2name = N'fk_Id_Provincia';
EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'(dbo.tblCanton) - Indica si el canton está activo o no.', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = @_LELEL1NAME, @level2type = @_LELEL2TYPE, @level2name = N'Activo';
EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'(dbo.tblCanton) - Fecha en que se creó el registro del canton.', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = @_LELEL1NAME, @level2type = @_LELEL2TYPE, @level2name = @_FechaCreacion;
EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'(dbo.tblCanton) - Fecha en que se modificó por última vez el registro del canton.', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = @_LELEL1NAME, @level2type = @_LELEL2TYPE, @level2name = @_FechaModificacion;

-------------------------------------- Descripciones para las columnas de tblCedis


EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Identificador único de tipo entero para el cedis.', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblCedis', @level2type = @_LELEL2TYPE, @level2name = N'Id_Cedis';
EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Nombre del cedis.', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblCedis', @level2type = @_LELEL2TYPE, @level2name = N'Nombre';
EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Codigo del cedis.', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblCedis', @level2type = @_LELEL2TYPE, @level2name = N'Codigo_Cedis';
EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Identificador del Pais al que pertenece el Cedis.', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblCedis', @level2type = @_LELEL2TYPE, @level2name = N'Fk_Id_Pais';
EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Indica si el cedis está activo o no.', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblCedis', @level2type = @_LELEL2TYPE, @level2name = N'Activo';
EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Fecha en que se creó el registro del cedis.', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblCedis', @level2type = @_LELEL2TYPE, @level2name = @_FechaCreacion;
EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Fecha en que se modificó por última vez el registro del cedis.', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblCedis', @level2type = @_LELEL2TYPE, @level2name = @_FechaModificacion;


-------------------------------------- Descripciones para las columnas de tblColaborador

EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Identificador único de tipo entero para el cedis.', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblColaborador', @level2type = @_LELEL2TYPE, @level2name = @_Id;
EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Nombre del colaborador.', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblColaborador', @level2type = @_LELEL2TYPE, @level2name = N'Nombre';
EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Primer Apellido del colaborador.', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblColaborador', @level2type = @_LELEL2TYPE, @level2name = N'Apellido1';
EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Segundo Apellido del colaborador.', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblColaborador', @level2type = @_LELEL2TYPE, @level2name = N'Apellido2';
EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Usuario del Directorio Activo del colaborador.', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblColaborador', @level2type = @_LELEL2TYPE, @level2name = N'UserActiveDirectory';
EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Indica si el colaborador está activo o no.', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblColaborador', @level2type = @_LELEL2TYPE, @level2name = N'Activo';
EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Correo electronico del colaborador', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblColaborador', @level2type = @_LELEL2TYPE, @level2name = N'Correo';
EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Fecha en que se creó el registro del colaborador.', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblColaborador', @level2type = @_LELEL2TYPE, @level2name = @_FechaCreacion;
EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Fecha en que se modificó por última vez el registro del colaborador.', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblColaborador', @level2type = @_LELEL2TYPE, @level2name = @_FechaModificacion;


-------------------------------------- Descripciones para las columnas de tblComunicado


EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Identificador único de tipo entero para el comunicado.', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblComunicado', @level2type = @_LELEL2TYPE, @level2name = @_Id;
EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Identificador del tipo de comunicado que se esta registrando.', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblComunicado', @level2type = @_LELEL2TYPE, @level2name = N'FkTipoComunicado';
EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Identificador del colaborador que esta haciendo el registro del comunicado', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblComunicado', @level2type = @_LELEL2TYPE, @level2name = N'FKColaborador';
EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'El mensaje que va a brindar el comunicado.', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblComunicado', @level2type = @_LELEL2TYPE, @level2name = N'Mensaje';
EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Identificador para saber si se debe visualizar el comunicado en el banner.', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblComunicado', @level2type = @_LELEL2TYPE, @level2name = N'FkHabilitarBanner';
EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Indica si el comunicado está activo o no.', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblComunicado', @level2type = @_LELEL2TYPE, @level2name = N'Activo';
EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Fecha en que se creó el registro del comunicado.', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblComunicado', @level2type = @_LELEL2TYPE, @level2name = @_FechaCreacion;
EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Fecha en que se modificó por última vez el registro del comunicado.', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblComunicado', @level2type = @_LELEL2TYPE, @level2name = @_FechaModificacion;


-------------------------------------- Descripciones para las columnas de tblCuentaInterna

EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Identificador único de tipo entero para la cuenta bancaria interna.', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblCuentaInterna', @level2type = @_LELEL2TYPE, @level2name = @_Id;
EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Numero de cuenta bancaria interna.', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblCuentaInterna', @level2type = @_LELEL2TYPE, @level2name = N'NumeroCuenta';
EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Identificador de la divisa asociada a la cuenta banacaria interna que se esta haciendo el registro', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblCuentaInterna', @level2type = @_LELEL2TYPE, @level2name = N'Codigo';
EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Identificador de la divisa asociada a la cuenta interna.', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblCuentaInterna', @level2type = @_LELEL2TYPE, @level2name = N'FkIdDivisa';
EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Indica si la cuenta bancaria interna está activo o no.', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblCuentaInterna', @level2type = @_LELEL2TYPE, @level2name = N'Activo';
EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Fecha en que se creó el registro de la cuenta bancaria interna.', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblCuentaInterna', @level2type = @_LELEL2TYPE, @level2name = @_FechaCreacion;
EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Fecha en que se modificó por última vez el registro de la cuenta bancaria interna.', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblCuentaInterna', @level2type = @_LELEL2TYPE, @level2name = @_FechaModificacion;


-------------------------------------- Descripciones para las columnas de tblCuentaInterna_x_Agencia

EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Identificador único de tipo entero para la cuenta bancaria interna asociada a la agencia.', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblCuentaInterna_x_Agencia', @level2type = @_LELEL2TYPE, @level2name = @_Id;
EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Identificador de la cuenta bancaria interna asociada a la agencia.', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblCuentaInterna_x_Agencia', @level2type = @_LELEL2TYPE, @level2name = N'FkIdCuentaInterna';
EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Identificador de la agencia bancaria asociada a la cuenta bancaria interna.', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblCuentaInterna_x_Agencia', @level2type = @_LELEL2TYPE, @level2name = N'FkIdAgencia';
EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Codigo que asocia la relacion de cuanta bancaria interna con la agencia bancaria', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblCuentaInterna_x_Agencia', @level2type = @_LELEL2TYPE, @level2name = N'Codigo';
EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Indica si la relacion cuenta bancaria interna con la agencia está activa o no.', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblCuentaInterna_x_Agencia', @level2type = @_LELEL2TYPE, @level2name = N'Activo';
EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Fecha en que se creó el registro de la relacion cuenta bancaria interna con agencia bancaria.', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblCuentaInterna_x_Agencia', @level2type = @_LELEL2TYPE, @level2name = @_FechaCreacion;
EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Fecha en que se modificó por última vez el registro de la relacion cuenta bancaria interna con agencia bancaria.', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblCuentaInterna_x_Agencia', @level2type = @_LELEL2TYPE, @level2name = @_FechaModificacion;



-------------------------------------- Descripciones para las columnas de tblCuentaInterna_x_GrupoAgencias


EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Identificador único de tipo entero para la cuenta bancaria interna asociada al grupo de agencias.', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblCuentaInterna_x_GrupoAgencias', @level2type = @_LELEL2TYPE, @level2name = @_Id;
EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Identificador de la cuenta interna asociada a la relación.', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblCuentaInterna_x_GrupoAgencias', @level2type = @_LELEL2TYPE, @level2name = N'FkIdCuentaInterna';
EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Identificador de la cuenta bancaria interna asociada al grupo de agencias.', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblCuentaInterna_x_GrupoAgencias', @level2type = @_LELEL2TYPE, @level2name = N'FkIdGrupoAgencias';
EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Codigo que asocia la relacion de cuanta bancaria interna con la agencia bancaria', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblCuentaInterna_x_GrupoAgencias', @level2type = @_LELEL2TYPE, @level2name = N'Codigo';
EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Indica si la relacion cuenta bancaria interna con el grupo de agencia está activa o no.', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblCuentaInterna_x_GrupoAgencias', @level2type = @_LELEL2TYPE, @level2name = N'Activo';
EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Fecha en que se creó el registro de la relacion cuenta bancaria interna con agencia bancaria.', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblCuentaInterna_x_GrupoAgencias', @level2type = @_LELEL2TYPE, @level2name = @_FechaCreacion;
EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Fecha en que se modificó por última vez el registro de la relacion cuenta bancaria interna con agencia bancaria.', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblCuentaInterna_x_GrupoAgencias', @level2type = @_LELEL2TYPE, @level2name = @_FechaModificacion;



-------------------------------------- Descripciones para las columnas de tblDenominaciones


EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Identificador único de tipo entero para la denominacion', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblDenominaciones', @level2type = @_LELEL2TYPE, @level2name = @_Id;
EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Identificador de la divisa a la que esta asociada la denominacion.', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblDenominaciones', @level2type = @_LELEL2TYPE, @level2name = N'IdDivisa';
EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Valor nominal en expresion numerica de la denominacion que se esta creando', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblDenominaciones', @level2type = @_LELEL2TYPE, @level2name = N'ValorNominal';
EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Nombre de la denominacion, escrita en forma de texto', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblDenominaciones', @level2type = @_LELEL2TYPE, @level2name = N'Nombre';
EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Indica si la denominacion está activa o no.', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblDenominaciones', @level2type = @_LELEL2TYPE, @level2name = N'Activo';
EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Identificador del tipo de esta denominacion (Billete, Moneda o Otro).', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblDenominaciones', @level2type = @_LELEL2TYPE, @level2name = N'BMO';
EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Archivo guardado en bit que representa la imagen de la denominacion.', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblDenominaciones', @level2type = @_LELEL2TYPE, @level2name = N'Imagen';
EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Fecha en que se creó el registro de la denominacion.', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblDenominaciones', @level2type = @_LELEL2TYPE, @level2name = @_FechaCreacion;
EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Fecha en que se modificó por última vez el registro de la denominacion.', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblDenominaciones', @level2type = @_LELEL2TYPE, @level2name = @_FechaModificacion;




-------------------------------------- Descripciones para las columnas de tblDenominaciones_x_Modulo


EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Identificador único de tipo entero para la relacion entre denominacion y modulo', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblDenominaciones_x_Modulo', @level2type = @_LELEL2TYPE, @level2name = @_Id;
EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Identificador del modulo al que esta relacionada la denominacion.', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblDenominaciones_x_Modulo', @level2type = @_LELEL2TYPE, @level2name = N'FkIdModulo';
EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Identificador de la denominacion.', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblDenominaciones_x_Modulo', @level2type = @_LELEL2TYPE, @level2name = N'FkIdDenominaciones';
EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Indica si la relacion entre denominacion y modulo está activa o no.', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblDenominaciones_x_Modulo', @level2type = @_LELEL2TYPE, @level2name = N'Activo';
EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Fecha en que se creó el registro de la relacion entre denominacion y modul.', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblDenominaciones_x_Modulo', @level2type = @_LELEL2TYPE, @level2name = @_FechaCreacion;
EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Fecha en que se modificó por última vez el registro de la relacion entre denominacion y modul.', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblDenominaciones_x_Modulo', @level2type = @_LELEL2TYPE, @level2name = @_FechaModificacion;



-------------------------------------- Descripciones para las columnas de tblDepartamento


EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Identificador único de tipo entero para el departamento', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblDepartamento', @level2type = @_LELEL2TYPE, @level2name = @_Id;
EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Nombre que describe la funcion del departamento.', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblDepartamento', @level2type = @_LELEL2TYPE, @level2name = N'Nombre';
EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Indica si el departamento está activa o no.', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblDepartamento', @level2type = @_LELEL2TYPE, @level2name = N'Activo';
EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Fecha en que se creó el registro del departamento.', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblDepartamento', @level2type = @_LELEL2TYPE, @level2name = @_FechaCreacion;
EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Fecha en que se modificó por última vez el registro del departamento.', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblDepartamento', @level2type = @_LELEL2TYPE, @level2name = @_FechaModificacion;



-------------------------------------- Descripciones para las columnas de tblDiasHabilesEntregaPedidosInternos

EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Identificador único de tipo entero para el horario', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblDiasHabilesEntregaPedidosInternos', @level2type = @_LELEL2TYPE, @level2name = @_Id;
EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Numero que indica el dia de la semana para el cual se esta configuranfo el horario de entrega.', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblDiasHabilesEntregaPedidosInternos', @level2type = @_LELEL2TYPE, @level2name = N'Dia';
EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Identificador del cedis para el cual se etsa configurando el horario disponible de entrega de pedidos.', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblDiasHabilesEntregaPedidosInternos', @level2type = @_LELEL2TYPE, @level2name = N'FkIdCedis';
EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Nombre del dia para el cual se esta configurando el horario', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblDiasHabilesEntregaPedidosInternos', @level2type = @_LELEL2TYPE, @level2name = N'NombreDia';
EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Indica si para este dia esta permitido la entrega de remesas', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblDiasHabilesEntregaPedidosInternos', @level2type = @_LELEL2TYPE, @level2name = N'PermiteRemesas';
EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Indica si para este dia esta permitido la entrega de remesas par el mismo dia', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblDiasHabilesEntregaPedidosInternos', @level2type = @_LELEL2TYPE, @level2name = N'PermiteEntregasMismoDia';
EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Indica si para este cedis las entregas estan permitida para el dia Lunes', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblDiasHabilesEntregaPedidosInternos', @level2type = @_LELEL2TYPE, @level2name = N'EntregarLunes';
EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Indica si para este cedis las entregas estan permitida para el dia Martes', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblDiasHabilesEntregaPedidosInternos', @level2type = @_LELEL2TYPE, @level2name = N'EntregarMartes';
EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Indica si para este cedis las entregas estan permitida para el dia Miercoles', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblDiasHabilesEntregaPedidosInternos', @level2type = @_LELEL2TYPE, @level2name = N'EntregarMiercoles';
EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Indica si para este cedis las entregas estan permitida para el dia Jueves', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblDiasHabilesEntregaPedidosInternos', @level2type = @_LELEL2TYPE, @level2name = N'EntregarJueves';
EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Indica si para este cedis las entregas estan permitida para el dia Viernes', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblDiasHabilesEntregaPedidosInternos', @level2type = @_LELEL2TYPE, @level2name = N'EntregarViernes';
EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Indica si para este cedis las entregas estan permitida para el dia Sabado', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblDiasHabilesEntregaPedidosInternos', @level2type = @_LELEL2TYPE, @level2name = N'EntregarSabado';
EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Indica si para este cedis las entregas estan permitida para el dia Domingo', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblDiasHabilesEntregaPedidosInternos', @level2type = @_LELEL2TYPE, @level2name = N'EntregarDomingo';
EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Hora límite para las entregas de pedidos internos el mismo día en los días hábiles de entrega.', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblDiasHabilesEntregaPedidosInternos', @level2type = @_LELEL2TYPE, @level2name = N'HoraLimiteMismoDia';
EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Codigo unico para la configuracion del horario para ese dia para el dia especifico', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblDiasHabilesEntregaPedidosInternos', @level2type = @_LELEL2TYPE, @level2name = N'Codigo';
EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Se define la hora limite para aprobar la solicitud del pedido', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblDiasHabilesEntregaPedidosInternos', @level2type = @_LELEL2TYPE, @level2name = N'HoraLimiteAprobacion';
EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Se define la hora limite para aprobar la solicitud del pedido para el mismo dia', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblDiasHabilesEntregaPedidosInternos', @level2type = @_LELEL2TYPE, @level2name = N'HoraLimiteAprobacionMismoDia';
EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Hora inicial para la solicitud de remesas', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblDiasHabilesEntregaPedidosInternos', @level2type = @_LELEL2TYPE, @level2name = N'HoraDesde';
EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Hora limite para la solicitud de remesas', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblDiasHabilesEntregaPedidosInternos', @level2type = @_LELEL2TYPE, @level2name = N'HoraHasta';
EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Hora corte del dia para las solicitudes de remesas', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblDiasHabilesEntregaPedidosInternos', @level2type = @_LELEL2TYPE, @level2name = N'HoraCorteDia';
EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Fecha en que se creó el registro del horario para el cedis.', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblDiasHabilesEntregaPedidosInternos', @level2type = @_LELEL2TYPE, @level2name = @_FechaCreacion;
EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Fecha en que se modificó por última vez el registro del horario para el cedis.', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblDiasHabilesEntregaPedidosInternos', @level2type = @_LELEL2TYPE, @level2name = @_FechaModificacion;


-------------------------------------- Descripciones para las columnas de tblDistrito


EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Identificador único de tipo entero para el distrito', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblDistrito', @level2type = @_LELEL2TYPE, @level2name = @_Id;
EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Nombre que describe el distrito.', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblDistrito', @level2type = @_LELEL2TYPE, @level2name = N'Nombre';
EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Identificador único del cantón al que pertenece el distrito.', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblDistrito', @level2type = @_LELEL2TYPE, @level2name = N'fk_Id_Canton';
EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Indica si el distrito está activa o no.', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblDistrito', @level2type = @_LELEL2TYPE, @level2name = N'Activo';
EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Fecha en que se creó el registro del distrito.', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblDistrito', @level2type = @_LELEL2TYPE, @level2name = @_FechaCreacion;
EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Fecha en que se modificó por última vez el registro del distrito.', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblDistrito', @level2type = @_LELEL2TYPE, @level2name = @_FechaModificacion;



-------------------------------------- Descripciones para las columnas de tblDivisa


EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Identificador único de tipo entero para la divisa', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblDivisa', @level2type = @_LELEL2TYPE, @level2name = @_Id;
EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Nombre que describe la divisa.', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblDivisa', @level2type = @_LELEL2TYPE, @level2name = N'Nombre';
EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Nomenclatura que describe la divisa.', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblDivisa', @level2type = @_LELEL2TYPE, @level2name = N'Nomenclatura';
EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Simbolo que describe la divisa.', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblDivisa', @level2type = @_LELEL2TYPE, @level2name = N'Simbolo';
EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Descripcion literal sobre la divisa la divisa.', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblDivisa', @level2type = @_LELEL2TYPE, @level2name = N'Descripcion';
EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Indica si la divisa está activa o no.', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblDivisa', @level2type = @_LELEL2TYPE, @level2name = N'Activo';
EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Fecha en que se creó el registro de la divisa.', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblDivisa', @level2type = @_LELEL2TYPE, @level2name = @_FechaCreacion;
EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Fecha en que se modificó por última vez el registro de la divisa.', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblDivisa', @level2type = @_LELEL2TYPE, @level2name = @_FechaModificacion;



-------------------------------------- Descripciones para las columnas de tblDivisa_x_TipoEfectivo

EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Identificador único de tipo entero para la divisa', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblDivisa_x_TipoEfectivo', @level2type = @_LELEL2TYPE, @level2name = @_Id;
EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Identificador del tipo de efectivo.', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblDivisa_x_TipoEfectivo', @level2type = @_LELEL2TYPE, @level2name = N'FkIdTipoEfectivo';
EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Identificador del tipo de divisa.', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblDivisa_x_TipoEfectivo', @level2type = @_LELEL2TYPE, @level2name = N'FkIdDivisa';
EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Nombre del tipo de efectivo.', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblDivisa_x_TipoEfectivo', @level2type = @_LELEL2TYPE, @level2name = N'NombreTipoEfectivo';
EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Nombre de la divisa.', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblDivisa_x_TipoEfectivo', @level2type = @_LELEL2TYPE, @level2name = N'NombreDivisa';
EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Indica si la relacion divisa con tipo de efectivo está activa o no.', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblDivisa_x_TipoEfectivo', @level2type = @_LELEL2TYPE, @level2name = N'Activo';
EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Fecha en que se creó el registro de la relacion divisa con tipo de efectivo.', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblDivisa_x_TipoEfectivo', @level2type = @_LELEL2TYPE, @level2name = @_FechaCreacion;
EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Fecha en que se modificó por última vez el registro de la relacion divisa con tipo de efectivo.', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblDivisa_x_TipoEfectivo', @level2type = @_LELEL2TYPE, @level2name = @_FechaModificacion;



-------------------------------------- Descripciones para las columnas de tblFirmas


EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Identificador único de tipo entero para la firma', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblFirmas', @level2type = @_LELEL2TYPE, @level2name = @_Id;
EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Nombre de la firma.', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblFirmas', @level2type = @_LELEL2TYPE, @level2name = N'Firma';
EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Monto Inicial para el cual la firma aprueba .', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblFirmas', @level2type = @_LELEL2TYPE, @level2name = N'MontoDesde';
EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Monto limite para el cual la firma aprueba .', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblFirmas', @level2type = @_LELEL2TYPE, @level2name = N'MontoHasta';
EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Indica si la firma está activa o no.', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblFirmas', @level2type = @_LELEL2TYPE, @level2name = N'Activo';
EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Fecha en que se creó el registro de la firma.', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblFirmas', @level2type = @_LELEL2TYPE, @level2name = @_FechaCreacion;
EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Fecha en que se modificó por última vez el registro de la firma.', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblFirmas', @level2type = @_LELEL2TYPE, @level2name = @_FechaModificacion;


-------------------------------------- Descripciones para las columnas de tblGrupoAgencia


EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Identificador único de tipo entero para el grupo de agencias', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblGrupoAgencia', @level2type = @_LELEL2TYPE, @level2name = @_Id;
EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Nombre que describe el grupo de agencias.', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblGrupoAgencia', @level2type = @_LELEL2TYPE, @level2name = N'Nombre';
EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Codigo que identifica el grupo de agencias.', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblGrupoAgencia', @level2type = @_LELEL2TYPE, @level2name = N'Codigo';
EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Indica si el grupo de agencias esta autorizado a enviar remesas.', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblGrupoAgencia', @level2type = @_LELEL2TYPE, @level2name = N'EnviaRemesas';
EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Indica si el grupo de agencias est autorizado a solicitar remesas.', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblGrupoAgencia', @level2type = @_LELEL2TYPE, @level2name = N'SolicitaRemesas';
EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Indica si el gripo de agencias está activa o no.', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblGrupoAgencia', @level2type = @_LELEL2TYPE, @level2name = N'Activo';
EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Fecha en que se creó el registro del grupo de agencia.', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblGrupoAgencia', @level2type = @_LELEL2TYPE, @level2name = @_FechaCreacion;
EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Fecha en que se modificó por última vez el registro del grupo de agencia.', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblGrupoAgencia', @level2type = @_LELEL2TYPE, @level2name = @_FechaModificacion;


-------------------------------------- Descripciones para las columnas de tblHabilitarBanner


EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Identificador único de tipo entero para habilitar el banner', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblHabilitarBanner', @level2type = @_LELEL2TYPE, @level2name = @_Id;
EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Indica si el baner está activa o no.', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblHabilitarBanner', @level2type = @_LELEL2TYPE, @level2name = N'Activo';
EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Fecha en que se creó el registro para habilitar banner.', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblHabilitarBanner', @level2type = @_LELEL2TYPE, @level2name = @_FechaCreacion;
EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Fecha en que se modificó por última vez el registro para habilitar banner.', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblHabilitarBanner', @level2type = @_LELEL2TYPE, @level2name = @_FechaModificacion;


-------------------------------------- Descripciones para las columnas de tblMatrizAtribucion


EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Identificador único de tipo entero para la matriz de atribucion', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblMatrizAtribucion', @level2type = @_LELEL2TYPE, @level2name = @_Id;
EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Nombre que describe la matriz de atribucion.', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblMatrizAtribucion', @level2type = @_LELEL2TYPE, @level2name = N'Nombre';
EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Identificador de la divisa con la que esta asociada la matriz.', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblMatrizAtribucion', @level2type = @_LELEL2TYPE, @level2name = N'Fk_Id_Divisa';
EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Indica si la matriz de atribucion está activa o no.', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblMatrizAtribucion', @level2type = @_LELEL2TYPE, @level2name = N'Activo';
EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Fecha en que se creó el registro de la matriz de atribucion.', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblMatrizAtribucion', @level2type = @_LELEL2TYPE, @level2name = @_FechaCreacion;
EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Fecha en que se modificó por última vez el registro de la matriz de atribucion.', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblMatrizAtribucion', @level2type = @_LELEL2TYPE, @level2name = @_FechaModificacion;


-------------------------------------- Descripciones para las columnas de tblMatrizAtribucion_Firmas

EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Identificador único de tipo entero para la relacion matriz atribucion y firmas', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblMatrizAtribucion_Firmas', @level2type = @_LELEL2TYPE, @level2name = @_Id;
EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Identificador de matriz de atribucion.', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblMatrizAtribucion_Firmas', @level2type = @_LELEL2TYPE, @level2name = N'Fk_Id_MatrizAtribucion';
EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Identificador de firma.', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblMatrizAtribucion_Firmas', @level2type = @_LELEL2TYPE, @level2name = N'Fk_Id_Firmas';
EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Indica si la relacion matriz de atriucion y firma está activa o no.', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblMatrizAtribucion_Firmas', @level2type = @_LELEL2TYPE, @level2name = N'Activo';
EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Fecha en que se creó el registro de la relacion matriz de atribucion y firmas.', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblMatrizAtribucion_Firmas', @level2type = @_LELEL2TYPE, @level2name = @_FechaCreacion;
EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Fecha en que se modificó por última vez el registro de la relacion matriz de atribucion y firmas.', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblMatrizAtribucion_Firmas', @level2type = @_LELEL2TYPE, @level2name = @_FechaModificacion;



-------------------------------------- Descripciones para las columnas de tblMatrizAtribucion_Transaccion


EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Identificador único de tipo entero para la relacion matriz de atribucion con transacciones', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblMatrizAtribucion_Transaccion', @level2type = @_LELEL2TYPE, @level2name = @_Id;
EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Identificador de la matriz de atribucion.', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblMatrizAtribucion_Transaccion', @level2type = @_LELEL2TYPE, @level2name = N'Fk_Id_MatrizAtribucion';
EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Identificador de la transaccion.', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblMatrizAtribucion_Transaccion', @level2type = @_LELEL2TYPE, @level2name = N'Fk_Id_Transaccion';
EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Indica si la relacion de la transaccion con la matriz de atribucion está activa o no.', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblMatrizAtribucion_Transaccion', @level2type = @_LELEL2TYPE, @level2name = N'Activo';
EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Fecha en que se creó el registro de las transacciones asociadas a la matriz de atribucion.', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblMatrizAtribucion_Transaccion', @level2type = @_LELEL2TYPE, @level2name = @_FechaCreacion;
EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Fecha en que se modificó por última vez el registro de las transacciones asociadas a la matriz de atribucion.', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblMatrizAtribucion_Transaccion', @level2type = @_LELEL2TYPE, @level2name = @_FechaModificacion;


-------------------------------------- Descripciones para las columnas de tblMensajes_Emergentes


EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Identificador único de tipo entero para el departamento', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblMensajes_Emergentes', @level2type = @_LELEL2TYPE, @level2name = @_Id;
EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Indicador del modulo con el que esta relacionado el mensaje emergente.', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblMensajes_Emergentes', @level2type = @_LELEL2TYPE, @level2name = N'Fk_Modulo';
EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Indicador del modulo con el que esta relacionado el mensaje emergente.', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblMensajes_Emergentes', @level2type = @_LELEL2TYPE, @level2name = N'Fk_Metodo';
EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Indicador del tipo de mensaje.', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblMensajes_Emergentes', @level2type = @_LELEL2TYPE, @level2name = N'Fk_TipoMensaje';
EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Indicador del titulo con el que se relacione el mensaje emergente.', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblMensajes_Emergentes', @level2type = @_LELEL2TYPE, @level2name = N'Fk_Titulo';
EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Mensaje que se muestra en las mensaje emergentes.', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblMensajes_Emergentes', @level2type = @_LELEL2TYPE, @level2name = N'Mensaje';
EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Error que proporciona en la ventana emergente cado este mensaje no se puede mostrar.', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblMensajes_Emergentes', @level2type = @_LELEL2TYPE, @level2name = N'ErrorMensaje';
EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Fecha en que se creó el registro del mensaje emergente.', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblMensajes_Emergentes', @level2type = @_LELEL2TYPE, @level2name = @_FechaCreacion;
EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Fecha en que se modificó por última vez el registro del mensaje emergente.', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblMensajes_Emergentes', @level2type = @_LELEL2TYPE, @level2name = @_FechaModificacion;


-------------------------------------- Descripciones para las columnas de tblMensajes_Emergentes_Metodo


EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Identificador único de tipo entero para el metodo', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblMensajes_Emergentes_Metodo', @level2type = @_LELEL2TYPE, @level2name = @_Id;
EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Nombre que describe la funcion del metodo.', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblMensajes_Emergentes_Metodo', @level2type = @_LELEL2TYPE, @level2name = N'Metodo';
EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Fecha en que se creó el registro del metodo.', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblMensajes_Emergentes_Metodo', @level2type = @_LELEL2TYPE, @level2name = @_FechaCreacion;
EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Fecha en que se modificó por última vez el registro del metodo.', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblMensajes_Emergentes_Metodo', @level2type = @_LELEL2TYPE, @level2name = @_FechaModificacion;


-------------------------------------- Descripciones para las columnas de tblMensajes_Emergentes_Modulo


EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Identificador único de tipo entero para el modulo', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblMensajes_Emergentes_Modulo', @level2type = @_LELEL2TYPE, @level2name = @_Id;
EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Nombre que describe la funcion del modulo.', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblMensajes_Emergentes_Modulo', @level2type = @_LELEL2TYPE, @level2name = N'Modulo';
EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Fecha en que se creó el registro del modulo.', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblMensajes_Emergentes_Modulo', @level2type = @_LELEL2TYPE, @level2name = @_FechaCreacion;
EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Fecha en que se modificó por última vez el registro del modulo.', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblMensajes_Emergentes_Modulo', @level2type = @_LELEL2TYPE, @level2name = @_FechaModificacion;


-------------------------------------- Descripciones para las columnas de tblMensajes_Emergentes_Tipo_Mensaje


EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Identificador único de tipo entero para el tipo de mensaje', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblMensajes_Emergentes_Tipo_Mensaje', @level2type = @_LELEL2TYPE, @level2name = @_Id;
EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Nombre que describe el tipo de mensaje.', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblMensajes_Emergentes_Tipo_Mensaje', @level2type = @_LELEL2TYPE, @level2name = N'TipoMensaje';
EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Fecha en que se creó el registro del tipo de mensaje.', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblMensajes_Emergentes_Tipo_Mensaje', @level2type = @_LELEL2TYPE, @level2name = @_FechaCreacion;
EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Fecha en que se modificó por última vez el registro del tipo de mensaje.', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblMensajes_Emergentes_Tipo_Mensaje', @level2type = @_LELEL2TYPE, @level2name = @_FechaModificacion;



-------------------------------------- Descripciones para las columnas de tblMensajes_Emergentes_Titulo



EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Identificador único de tipo entero para el titulo del mensaje', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblMensajes_Emergentes_Titulo', @level2type = @_LELEL2TYPE, @level2name = @_Id;
EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Titulo del mensaje emergente.', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblMensajes_Emergentes_Titulo', @level2type = @_LELEL2TYPE, @level2name = N'Titulo';
EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Fecha en que se creó el registro el titulo del mensaje.', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblMensajes_Emergentes_Titulo', @level2type = @_LELEL2TYPE, @level2name = @_FechaCreacion;
EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Fecha en que se modificó por última vez el registro del titulo del mensaje.', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblMensajes_Emergentes_Titulo', @level2type = @_LELEL2TYPE, @level2name = @_FechaModificacion;


-------------------------------------- Descripciones para las columnas de tblModulo

EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Identificador único de tipo entero para el modulo', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblModulo', @level2type = @_LELEL2TYPE, @level2name = @_Id;
EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Nombre que describe la funcion del modulo.', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblModulo', @level2type = @_LELEL2TYPE, @level2name = N'Nombre';
EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Indica si el modulo está activa o no.', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblModulo', @level2type = @_LELEL2TYPE, @level2name = N'Activo';
EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Fecha en que se creó el registro del modulo.', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblModulo', @level2type = @_LELEL2TYPE, @level2name = @_FechaCreacion;
EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Fecha en que se modificó por última vez el registro del modulo.', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblModulo', @level2type = @_LELEL2TYPE, @level2name = @_FechaModificacion;



-------------------------------------- Descripciones para las columnas de tblPais


EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Identificador único de tipo entero para el pais', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblPais', @level2type = @_LELEL2TYPE, @level2name = @_Id;
EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Nombre del pais.', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblPais', @level2type = @_LELEL2TYPE, @level2name = N'Nombre';
EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Codigo identificativo para el pais.', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblPais', @level2type = @_LELEL2TYPE, @level2name = N'Codigo';
EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Indica si el pais está activa o no.', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblPais', @level2type = @_LELEL2TYPE, @level2name = N'Activo';
EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Fecha en que se creó el registro del pais.', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblPais', @level2type = @_LELEL2TYPE, @level2name = @_FechaCreacion;
EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Fecha en que se modificó por última vez el registro del pais.', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblPais', @level2type = @_LELEL2TYPE, @level2name = @_FechaModificacion;



-------------------------------------- Descripciones para las columnas de tblParametros

EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Identificador único de tipo entero para el parametro', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblParametros', @level2type = @_LELEL2TYPE, @level2name = @_Id;
EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Codigo que identifica al parametro.', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblParametros', @level2type = @_LELEL2TYPE, @level2name = N'Codigo';
EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Nombre que describe la funcion del parametro.', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblParametros', @level2type = @_LELEL2TYPE, @level2name = N'Nombre';
EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Descripcion literal del parametro.', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblParametros', @level2type = @_LELEL2TYPE, @level2name = N'Descripcion';
EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Valor que se la pasa al parametro.', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblParametros', @level2type = @_LELEL2TYPE, @level2name = N'Valor';
EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Indica si el parametro está activa o no.', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblParametros', @level2type = @_LELEL2TYPE, @level2name = N'Activo';
EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Fecha en que se creó el registro del parametro.', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblParametros', @level2type = @_LELEL2TYPE, @level2name = @_FechaCreacion;
EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Fecha en que se modificó por última vez el registro del parametro.', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblParametros', @level2type = @_LELEL2TYPE, @level2name = @_FechaModificacion;



-------------------------------------- Descripciones para las columnas de tblProvincia


EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Identificador único de tipo entero para la provincia', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblProvincia', @level2type = @_LELEL2TYPE, @level2name = @_Id;
EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Nombre que describe la funcion de la provincia.', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblProvincia', @level2type = @_LELEL2TYPE, @level2name = N'Nombre';
EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Indica si la provincia está activa o no.', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblProvincia', @level2type = @_LELEL2TYPE, @level2name = N'Activo';
EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Fecha en que se creó el registro de la provincia.', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblProvincia', @level2type = @_LELEL2TYPE, @level2name = @_FechaCreacion;
EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Fecha en que se modificó por última vez el registro de la provincia.', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblProvincia', @level2type = @_LELEL2TYPE, @level2name = @_FechaModificacion;



-------------------------------------- Descripciones para las columnas de tblReportes


EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Identificador único de tipo entero para el reporte', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblReportes', @level2type = @_LELEL2TYPE, @level2name = @_Id;
EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Nombre que describe la funcion del reporte.', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblReportes', @level2type = @_LELEL2TYPE, @level2name = N'Nombre';
EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Procedimiento con el cual se ejecuta el reporte.', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblReportes', @level2type = @_LELEL2TYPE, @level2name = N'Procedimiento';
EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Descripcion para que funciona el reporte.', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblReportes', @level2type = @_LELEL2TYPE, @level2name = N'Descripcion';
EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Indica si el reporte tiene filtros.', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblReportes', @level2type = @_LELEL2TYPE, @level2name = N'Tiene_Filtro_Fechas';
EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Indica si el reporte es VD.', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblReportes', @level2type = @_LELEL2TYPE, @level2name = N'Es_Reporte_VD';
EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Indica si el reporte está activa o no.', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblReportes', @level2type = @_LELEL2TYPE, @level2name = N'Estado';
EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Fecha en que se creó el registro del reporte.', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblReportes', @level2type = @_LELEL2TYPE, @level2name = N'Fecha_Creacion';
EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Fecha en que se modificó por última vez el registro del reporte.', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblReportes', @level2type = @_LELEL2TYPE, @level2name = N'Fecha_Modificacion';



-------------------------------------- Descripciones para las columnas de tblTipoCambio


EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Identificador único de tipo entero para el departamento', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblTipoCambio', @level2type = @_LELEL2TYPE, @level2name = @_Id;
EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Identificador para la divisa que se cotiza', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblTipoCambio', @level2type = @_LELEL2TYPE, @level2name = N'fk_Id_DivisaCotizada';
EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'El monto en colones de la compra de la divisa.', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblTipoCambio', @level2type = @_LELEL2TYPE, @level2name = N'CompraColones';
EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'El monto en colones de la venta de la divisa.', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblTipoCambio', @level2type = @_LELEL2TYPE, @level2name = N'VentaColones';
EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Indica si el tipo de cambio está activa o no.', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblTipoCambio', @level2type = @_LELEL2TYPE, @level2name = N'Activo';
EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Fecha en que se creó el registro del tipo de cambio.', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblTipoCambio', @level2type = @_LELEL2TYPE, @level2name = @_FechaCreacion;
EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Fecha en que se modificó por última vez el registro del tipo de cambio.', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblTipoCambio', @level2type = @_LELEL2TYPE, @level2name = @_FechaModificacion;


-------------------------------------- Descripciones para las columnas de tblTipoComunicado


EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Identificador único de tipo entero para el tipo de comunicado', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblTipoComunicado', @level2type = @_LELEL2TYPE, @level2name = @_Id;
EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Nombre del tipo de comunicado.', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblTipoComunicado', @level2type = @_LELEL2TYPE, @level2name = N'Nombre';
EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Fichero en bit para guardar la imagen asociada al comunicado.', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblTipoComunicado', @level2type = @_LELEL2TYPE, @level2name = N'Imagen';
EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Indica si el tipo de comunicado está activa o no.', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblTipoComunicado', @level2type = @_LELEL2TYPE, @level2name = N'Activo';
EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Fecha en que se creó el registro del tipo de comunicado.', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblTipoComunicado', @level2type = @_LELEL2TYPE, @level2name = @_FechaCreacion;
EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Fecha en que se modificó por última vez el registro del tipo de comunicado.', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblTipoComunicado', @level2type = @_LELEL2TYPE, @level2name = @_FechaModificacion;


-------------------------------------- Descripciones para las columnas de tblTipoEfectivo

EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Identificador único de tipo entero para el tipo de efectivo', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblTipoEfectivo', @level2type = @_LELEL2TYPE, @level2name = @_Id;
EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Nombre que describe el tipo de efectivo.', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblTipoEfectivo', @level2type = @_LELEL2TYPE, @level2name = N'Nombre';
EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Indica si el tipo de efectivo está activa o no.', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblTipoEfectivo', @level2type = @_LELEL2TYPE, @level2name = N'Activo';
EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Fecha en que se creó el registro del tipo de efectivo.', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblTipoEfectivo', @level2type = @_LELEL2TYPE, @level2name = @_FechaCreacion;
EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Fecha en que se modificó por última vez el registro del tipo de efectivo.', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblTipoEfectivo', @level2type = @_LELEL2TYPE, @level2name = @_FechaModificacion;


-------------------------------------- Descripciones para las columnas de tblTransacciones

EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Identificador único de tipo entero para el tipo de efectivo', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblTransacciones', @level2type = @_LELEL2TYPE, @level2name = @_Id;
EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Nombre que describe las transacciones.', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblTransacciones', @level2type = @_LELEL2TYPE, @level2name = N'Nombre';
EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Identificador del modulo al que esta ligada la transaccion.', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblTransacciones', @level2type = @_LELEL2TYPE, @level2name = N'Fk_Id_Modulo';
EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Codigo unico de la transaccion.', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblTransacciones', @level2type = @_LELEL2TYPE, @level2name = N'Codigo';
EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Indica si la transaccion está activa o no.', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblTransacciones', @level2type = @_LELEL2TYPE, @level2name = N'Activo';
EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Fecha en que se creó el registro de la transaccion.', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblTransacciones', @level2type = @_LELEL2TYPE, @level2name = @_FechaCreacion;
EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Fecha en que se modificó por última vez el registro de la transaccion.', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblTransacciones', @level2type = @_LELEL2TYPE, @level2name = @_FechaModificacion;


-------------------------------------- Descripciones para las columnas de tblTransportadoras

EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Identificador único de tipo entero para la transportadora', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblTransportadoras', @level2type = @_LELEL2TYPE, @level2name = @_Id;
EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Nombre que describe la transportadora.', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblTransportadoras', @level2type = @_LELEL2TYPE, @level2name = N'Nombre';
EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Codigo unico para la transportadora.', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblTransportadoras', @level2type = @_LELEL2TYPE, @level2name = N'Codigo';
EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Indica si la transportadora está activa o no.', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblTransportadoras', @level2type = @_LELEL2TYPE, @level2name = N'Activo';
EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Fecha en que se creó el registro de la trasnportadora.', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblTransportadoras', @level2type = @_LELEL2TYPE, @level2name = N'Fecha_Creacion';
EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Fecha en que se modificó por última vez el registro de la transportadora.', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblTransportadoras', @level2type = @_LELEL2TYPE, @level2name = N'Fecha_Modificacion';


-------------------------------------- Descripciones para las columnas de tblTransportadoras_x_Modulo

EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Identificador único de tipo entero para la relacion trasnportadora con modulo', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblTransportadoras_x_Modulo', @level2type = @_LELEL2TYPE, @level2name = @_Id;
EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Identificador de la transportadora', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblTransportadoras_x_Modulo', @level2type = @_LELEL2TYPE, @level2name = N'Fk_Id_Transportadora';
EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Identificador del modulo', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblTransportadoras_x_Modulo', @level2type = @_LELEL2TYPE, @level2name = N'Fk_Id_Modulo';
EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Indica si la relacion transportadora con modulo está activa o no.', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblTransportadoras_x_Modulo', @level2type = @_LELEL2TYPE, @level2name = N'Activo';
EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Fecha en que se creó el registro de la la relacion transportadora con modulo.', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblTransportadoras_x_Modulo', @level2type = @_LELEL2TYPE, @level2name = N'Fecha_Creacion';
EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Fecha en que se modificó por última vez el registro de la relacion transportadora con modulo.', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblTransportadoras_x_Modulo', @level2type = @_LELEL2TYPE, @level2name = N'Fecha_Modificacion';


-------------------------------------- Descripciones para las columnas de tblTransportadoras_x_Pais

EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Identificador único de tipo entero para la relacion trasnportadora con modulo', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblTransportadoras_x_Pais', @level2type = @_LELEL2TYPE, @level2name = @_Id;
EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Identificador de la transportadora', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblTransportadoras_x_Pais', @level2type = @_LELEL2TYPE, @level2name = N'Fk_Id_Transportadora';
EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Identificador del pais', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblTransportadoras_x_Pais', @level2type = @_LELEL2TYPE, @level2name = N'Fk_Id_Pais';
EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Indica si la relacion transportadora con pais está activa o no.', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblTransportadoras_x_Pais', @level2type = @_LELEL2TYPE, @level2name = N'Activo';
EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Fecha en que se creó el registro de la relacion transportadora con pais.', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblTransportadoras_x_Pais', @level2type = @_LELEL2TYPE, @level2name = N'Fecha_Creacion';
EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Fecha en que se modificó por última vez el registro de la relacion transportadora con pais.', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblTransportadoras_x_Pais', @level2type = @_LELEL2TYPE, @level2name = N'Fecha_Modificacion';


-------------------------------------- Descripciones para las columnas de tblUnidadMedida

EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Identificador único de tipo entero para la unidad de medida', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblUnidadMedida', @level2type = @_LELEL2TYPE, @level2name = @_Id;
EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Nombre que describe la unidad de medida.', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblUnidadMedida', @level2type = @_LELEL2TYPE, @level2name = N'Nombre';
EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Simbolo que identifica la unidad de medida.', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblUnidadMedida', @level2type = @_LELEL2TYPE, @level2name = N'Simbolo';
EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Cantidad que contiene la unidad de medida .', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblUnidadMedida', @level2type = @_LELEL2TYPE, @level2name = N'Cantidad_Unidades';
EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Indica si la unidad de medida está activa o no.', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblUnidadMedida', @level2type = @_LELEL2TYPE, @level2name = N'Activo';
EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Fecha en que se creó el registro de la unidad de medida.', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblUnidadMedida', @level2type = @_LELEL2TYPE, @level2name = N'Fecha_Creacion';
EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Fecha en que se modificó por última vez el registro de la unidad de medida.', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblUnidadMedida', @level2type = @_LELEL2TYPE, @level2name = N'Fecha_Modificacion';


-------------------------------------- Descripciones para las columnas de tblUnidadMedida_x_Divisa

EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Identificador único de tipo entero para la relacion unidad de medida con la divisa', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblUnidadMedida_x_Divisa', @level2type = @_LELEL2TYPE, @level2name = @_Id;
EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Identificador de la unidad de medida.', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblUnidadMedida_x_Divisa', @level2type = @_LELEL2TYPE, @level2name = N'Fk_Id_Unidad_Medida';
EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Identificador de la divisa.', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblUnidadMedida_x_Divisa', @level2type = @_LELEL2TYPE, @level2name = N'Fk_Id_Divisa';
EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Indica si la relacion entre la unidad de medida y la divisa está activa o no.', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblUnidadMedida_x_Divisa', @level2type = @_LELEL2TYPE, @level2name = N'Activo';
EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Fecha en que se creó el registro de la relacion entre la unidad de medida y la divisa.', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblUnidadMedida_x_Divisa', @level2type = @_LELEL2TYPE, @level2name = N'Fecha_Creacion';
EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Fecha en que se modificó por última vez el registro de la relacion entre la unidad de medida y la divisa.', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblUnidadMedida_x_Divisa', @level2type = @_LELEL2TYPE, @level2name = N'Fecha_Modificacion';


-------------------------------------- Descripciones para las columnas de tblUnidadMedida_x_TipoEfectivo

EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Identificador único de tipo entero para la relacion unidad de medida, divisa y tipo de efectivo', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblUnidadMedida_x_TipoEfectivo', @level2type = @_LELEL2TYPE, @level2name = @_Id;
EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Identificador de la unidad de medida.', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblUnidadMedida_x_TipoEfectivo', @level2type = @_LELEL2TYPE, @level2name = N'Fk_Id_Unidad_Medida';
EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Identificador de la divisa.', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblUnidadMedida_x_TipoEfectivo', @level2type = @_LELEL2TYPE, @level2name = N'Fk_Id_Divisa';
EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Identificador del tipo de efectivo.', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblUnidadMedida_x_TipoEfectivo', @level2type = @_LELEL2TYPE, @level2name = N'Fk_Id_Tipo_Efectivo';
EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Indica si la relacion entre la unidad de medida, divisa y tipo de efectivo está activa o no.', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblUnidadMedida_x_TipoEfectivo', @level2type = @_LELEL2TYPE, @level2name = N'Activo';
EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Fecha en que se creó el registro de la relacion entre la unidad de medida divisa y tipo de efectivo.', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblUnidadMedida_x_TipoEfectivo', @level2type = @_LELEL2TYPE, @level2name = N'Fecha_Creacion';
EXECUTE sp_addextendedproperty @name = @_NAME, @value = N'Fecha en que se modificó por última vez el registro de la relacion entre la unidad de medida divisa y tipo de efectivo.', @level0type = @_LELEL0TYPE, @level0name = @_LELEL0NAME, @level1type = @_LELEL1TYPE, @level1name = N'tblUnidadMedida_x_TipoEfectivo', @level2type = @_LELEL2TYPE, @level2name = N'Fecha_Modificacion';

END
GO