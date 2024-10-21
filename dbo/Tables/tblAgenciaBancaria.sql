--============================================================================
-- Nombre del Objeto: tblAgenciaBancaria.
-- Descripcion:
--		Esta tabla almacena información sobre las agencias bancarias, incluyendo su ubicación,
--		códigos, configuraciones de remesas y otras propiedades relacionadas.
-- Objetivo: 
--		Administrar y almacenar información detallada de agencias bancarias.
-- Tipo de Objeto: 
--     Tabla.
-- Motor:
--		MSSQL Server.
-- Origen de los Datos:
--		Información interna y externa relacionada con las agencias bancarias.
-- Permanencia de Datos:
--		Los datos se almacenan de forma permanente para el seguimiento histórico.
-- Uso de los datos:
--		La tabla se utiliza para gestionar y consultar información sobre agencias bancarias.
-- Restricciones o consideraciones:
--     - Se utiliza la función FN_VALIDACION_CONTRAINT_tblAgenciaBancaria_C3_4_5 para validar si en la tabla tblAgencias 
--       al agregar el Pais, Cedis, Grupo esten activos en sus respectivas tablas.
--     - Se utiliza la función FN_VALIDACION_CONTRAINT_REACTIVAR_tblAgenciaBancaria_C3_4_5 para validar si en la tabla tblAgencias 
--       al activar una agencia sus valores de el Pais, Cedis, Grupo esten activos en sus respectivas tablas.
--	Parametros de Entrada y de Salida:
--     No aplicable (ya que es una tabla y no un procedimiento almacenado).
--============================================================================

CREATE TABLE [dbo].[tblAgenciaBancaria] (
    [Id]                          INT            IDENTITY (1, 1) NOT NULL,
    [Nombre]                      VARCHAR (50) NOT NULL,
    [Codigo_Agencia]              VARCHAR (100) NOT NULL,
    [FkIdGrupoAgencia]            INT            NOT NULL,
    [FkIdPais]                    INT            NOT NULL,
    [FkIdCedi]                    INT            NOT NULL,
    [UsaCuentasGrupo]             BIT            CONSTRAINT [CT_tblAgenciaBancaria_UsaCuentasGrupo] DEFAULT (0) NOT NULL,
    [EnviaRemesas]                BIT            CONSTRAINT [CT_tblAgenciaBancaria_EnviaRemesas] DEFAULT (0) NOT NULL,
    [SolicitaRemesas]             BIT            CONSTRAINT [CT_tblAgenciaBancaria_SolicitaRemesas] DEFAULT (0) NOT NULL,
    [CodigoBranch]                VARCHAR (30)  NOT NULL,
    [CodigoProvincia]             INT            NOT NULL,
    [CodigoCanton]                INT            NOT NULL,
    [CodigoDistrito]              INT            NOT NULL,
    [Direccion]                   VARCHAR (200) NOT NULL,
    [Activo]                      BIT            CONSTRAINT [CT_tblAgenciaBancaria_Activo] DEFAULT (1) NOT NULL,
    [FechaCreacion]               SMALLDATETIME  CONSTRAINT [CT_tblAgenciaBancaria_FechaCreacion] DEFAULT (CONVERT([smalldatetime],getdate())) NOT NULL,
    [FechaModificacion]           SMALLDATETIME  NULL,
    [Fk_Transportadora_Envio]     INT            NULL,
    [Fk_Transportadora_Solicitud] INT            NULL,
    CONSTRAINT [PK_tblAgenciaBancaria] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [Constrains_Validate_Relaciones_Padre_AgenciaBancaria] CHECK ([dbo].[FN_VALIDACION_CONTRAINT_DESACTIVAR_tblAgenciaBancaria]([Activo],[Id])=(1)),
    CONSTRAINT [tblAgencias_C3_4_5_Reactivacion_Valida] CHECK ([dbo].[FN_VALIDACION_CONTRAINT_REACTIVAR_tblAgenciaBancaria_C3_4_5]([Activo],[FkIdPais],[FkIdCedi],[FkIdGrupoAgencia],[Fk_Transportadora_Envio],[Fk_Transportadora_Solicitud])=(1)),
    CONSTRAINT [FK_tblAgenciaBancaria_tblCanton] FOREIGN KEY ([CodigoCanton]) REFERENCES [dbo].[tblCanton] ([Id]),
    CONSTRAINT [FK_tblAgenciaBancaria_tblCedi] FOREIGN KEY ([FkIdCedi]) REFERENCES [dbo].[tblCedis] ([Id_Cedis]),
    CONSTRAINT [FK_tblAgenciaBancaria_tblDistrito] FOREIGN KEY ([CodigoDistrito]) REFERENCES [dbo].[tblDistrito] ([Id]),
    CONSTRAINT [FK_tblAgenciaBancaria_tblGrupoAgencia] FOREIGN KEY ([FkIdGrupoAgencia]) REFERENCES [dbo].[tblGrupoAgencia] ([Id]),
    CONSTRAINT [FK_tblAgenciaBancaria_tblPais] FOREIGN KEY ([FkIdPais]) REFERENCES [dbo].[tblPais] ([Id]),
    CONSTRAINT [FK_tblAgenciaBancaria_tblProvincia] FOREIGN KEY ([CodigoProvincia]) REFERENCES [dbo].[tblProvincia] ([Id]),
    CONSTRAINT [Unique_Codigo_Agencia] UNIQUE NONCLUSTERED ([Nombre] ASC, [FkIdGrupoAgencia] ASC, [FkIdPais] ASC),
    CONSTRAINT [Unique_Codigo_Branch] UNIQUE NONCLUSTERED ([CodigoBranch] ASC, [FkIdPais] ASC)
);