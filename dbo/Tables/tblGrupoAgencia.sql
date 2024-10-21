--============================================================================
-- Nombre del Objeto: tblGrupoAgencia.
-- Descripcion:
--		Esta tabla almacena información sobre grupos de agencias, incluyendo su nombre, código,
--		y si envían o solicitan remesas.
-- Objetivo: 
--		Gestionar y almacenar datos relacionados con los grupos de agencias.
-- Tipo de Objeto: 
--     Tabla.
-- Motor:
--		MSSQL Server.
-- Origen de los Datos:
--		Los datos provienen de la aplicación web.
-- Permanencia de Datos:
--		Los datos de esta tabla se mantienen en la base de datos mientras los grupos de agencias existan.
-- Uso de los datos:
--		Los datos se utilizan para identificar y gestionar los grupos de agencias en el sistema.
--		Las banderas EnvíaRemesas y SolicitaRemesas indican si un grupo de agencias realiza esas acciones.
-- Restricciones o consideraciones:
--     - Se garantiza que cada nombre de grupo de agencias sea único.
--     - Se aplican restricciones para validar la desactivación del grupo de agencias.
--	Parametros de Entrada y de Salida:
--     No aplica (ya que es una tabla y no un procedimiento almacenado).
--============================================================================

CREATE TABLE [dbo].[tblGrupoAgencia] (
    [Id]                INT           IDENTITY (1, 1) NOT NULL,
    [Nombre]            VARCHAR (100) NULL,
    [Codigo]            VARCHAR (90)  CONSTRAINT [CT_tblGrupoAgencia_Codigo] DEFAULT (newid()) NOT NULL,
    [EnviaRemesas]      BIT           CONSTRAINT [CT_tblGrupoAgencia_EnviaRemesas] DEFAULT (0) NOT NULL,
    [SolicitaRemesas]   BIT           CONSTRAINT [CT_tblGrupoAgencia_SolicitaRemesas] DEFAULT (0) NOT NULL,
    [Activo]            BIT           CONSTRAINT [CT_tblGrupoAgencia_Activo] DEFAULT (1) NOT NULL,
    [FechaCreacion]     SMALLDATETIME CONSTRAINT [CT_tblGrupoAgencia_FechaCreacion] DEFAULT (CONVERT([smalldatetime],getdate())) NOT NULL,
    [FechaModificacion] SMALLDATETIME NULL,
    CONSTRAINT [PK_tblGrupoAgencia] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [Constrains_Validate_Relaciones_GrupoAgencia] CHECK ([dbo].[FN_VALIDACION_CONTRAINT_DESACTIVAR_tblGrupoAgencia]([Activo],[Id])=(1)),
    CONSTRAINT [Unique_Nombre_Grupo_Agencia] UNIQUE NONCLUSTERED ([Nombre] ASC)
);