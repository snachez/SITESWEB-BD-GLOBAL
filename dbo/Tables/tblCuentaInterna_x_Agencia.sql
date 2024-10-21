--============================================================================
-- Nombre del Objeto: tblCuentaInterna_x_Agencia.
-- Descripcion:
--		Esta tabla representa la relación entre cuentas internas y agencias bancarias,
--		indicando qué cuentas internas están asociadas a qué agencias bancarias.
-- Objetivo: 
--		Administrar y almacenar información sobre la relación entre cuentas internas y agencias bancarias.
-- Tipo de Objeto: 
--     Tabla.
-- Motor:
--		MSSQL Server.
-- Origen de los Datos:
--		Los datos se generan internamente en el sistema al asociar cuentas internas con agencias bancarias.
-- Permanencia de Datos:
--		Los datos se almacenan de forma permanente para mantener un registro de las asociaciones.
-- Uso de los datos:
--		Los datos se utilizan para consultar y gestionar las asociaciones entre cuentas internas y agencias bancarias.
-- Restricciones o consideraciones:
--     - El código (Codigo) se genera automáticamente utilizando la función newid().
--     - Se garantiza que cada combinación de cuenta interna y agencia sea única.
--	Parametros de Entrada y de Salida:
--     No aplicable (ya que es una tabla y no un procedimiento almacenado).
--============================================================================

CREATE TABLE [dbo].[tblCuentaInterna_x_Agencia] (
    [Id]                INT           IDENTITY (1, 1) NOT NULL,
    [FkIdCuentaInterna] BIGINT        NOT NULL,
    [FkIdAgencia]       INT           NOT NULL,
    [Codigo]            VARCHAR (90)  CONSTRAINT [CT_tblCuentaInterna_x_Agencia_Codigo] DEFAULT (newid()) NOT NULL,
    [Activo]            BIT           CONSTRAINT [CT_tblCuentaInterna_x_Agencia_Activo] DEFAULT ((1)) NOT NULL,
    [FechaCreacion]     SMALLDATETIME CONSTRAINT [CT_tblCuentaInterna_x_Agencia_FechaCreacion] DEFAULT (CONVERT([smalldatetime],getdate())) NOT NULL,
    [FechaModificacion] SMALLDATETIME NULL,
    CONSTRAINT [PK_tblCuentaInterna_x_Agencia] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [Unique_cuenta_x_agencia] UNIQUE NONCLUSTERED ([FkIdCuentaInterna] ASC, [FkIdAgencia] ASC)
);