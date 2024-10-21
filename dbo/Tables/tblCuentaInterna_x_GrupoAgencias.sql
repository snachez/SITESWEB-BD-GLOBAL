--============================================================================
-- Nombre del Objeto: tblCuentaInterna_x_GrupoAgencias.
-- Descripcion:
--		Esta tabla representa la relación entre cuentas internas y grupos de agencias,
--		indicando qué cuentas internas están asociadas a qué grupos de agencias.
-- Objetivo: 
--		Administrar y almacenar información sobre la relación entre cuentas internas y grupos de agencias.
-- Tipo de Objeto: 
--     Tabla.
-- Motor:
--		MSSQL Server.
-- Origen de los Datos:
--		Los datos se generan internamente en el sistema al asociar cuentas internas con grupos de agencias.
-- Permanencia de Datos:
--		Los datos se almacenan de forma permanente para mantener un registro de las asociaciones.
-- Uso de los datos:
--		Los datos se utilizan para consultar y gestionar las asociaciones entre cuentas internas y grupos de agencias.
-- Restricciones o consideraciones:
--     - El código (Codigo) se genera automáticamente utilizando la función newid().
--     - Se garantiza que cada combinación de cuenta interna y grupo de agencias sea única.
--	Parametros de Entrada y de Salida:
--     No aplicable (ya que es una tabla y no un procedimiento almacenado).
--============================================================================

CREATE TABLE [dbo].[tblCuentaInterna_x_GrupoAgencias] (
    [Id]                INT           IDENTITY (1, 1) NOT NULL,
    [FkIdCuentaInterna] BIGINT        NOT NULL,
    [FkIdGrupoAgencias] INT           NOT NULL,
    [Codigo]            VARCHAR (90)  CONSTRAINT [CT_tblCuentaInterna_x_GrupoAgencias_Codigo] DEFAULT (newid()) NOT NULL,
    [Activo]            BIT           CONSTRAINT [CT_tblCuentaInterna_x_GrupoAgencias_Activo] DEFAULT ((1)) NOT NULL,
    [FechaCreacion]     SMALLDATETIME CONSTRAINT [CT_tblCuentaInterna_x_GrupoAgencias_FechaCreacion] DEFAULT (CONVERT([smalldatetime],getdate())) NOT NULL,
    [FechaModificacion] SMALLDATETIME NULL,
    CONSTRAINT [PK_tblCuentaInterna_x_GrupoAgencias] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [Unique_cuenta_x_grupo] UNIQUE NONCLUSTERED ([FkIdCuentaInterna] ASC, [FkIdGrupoAgencias] ASC)
);