--============================================================================
-- Nombre del Objeto: tblCuentaInterna.
-- Descripcion:
--		Esta tabla almacena información sobre cuentas internas, utilizadas internamente
--		en un sistema para representar cuentas asociadas a una divisa específica.
-- Objetivo: 
--		Administrar y almacenar información detallada de las cuentas internas.
-- Tipo de Objeto: 
--     Tabla.
-- Motor:
--		MSSQL Server.
-- Origen de los Datos:
--		Los datos se generan dentro del sistema.
-- Permanencia de Datos:
--		Los datos se almacenan de forma permanente para el seguimiento y gestión de cuentas internas.
-- Uso de los datos:
--		Los datos se utilizan para gestionar transacciones internas y cuentas asociadas a una divisa.
-- Restricciones o consideraciones:
--     - El número de cuenta (NumeroCuenta) debe tener una longitud máxima de 30 caracteres y debe ser unico.
--     - El código (Codigo) se genera automáticamente utilizando la función newid().
--	Parametros de Entrada y de Salida:
--     No aplicable (ya que es una tabla y no un procedimiento almacenado).
--============================================================================

CREATE TABLE [dbo].[tblCuentaInterna] (
    [Id]                BIGINT        IDENTITY (1, 1) NOT NULL,
    [NumeroCuenta]      VARCHAR (30)  NOT NULL,
    [Codigo]            VARCHAR (90)  CONSTRAINT [CT_tblCuentaInterna_Codigo] DEFAULT (newid()) NOT NULL,
    [FkIdDivisa]        INT           NOT NULL,
    [Activo]            BIT           CONSTRAINT [CT_tblCuentaInterna_Activo] DEFAULT (1) NOT NULL,
    [FechaCreacion]     SMALLDATETIME CONSTRAINT [CT_tblCuentaInterna_FechaCreacion] DEFAULT (CONVERT([smalldatetime],getdate())) NOT NULL,
    [FechaModificacion] SMALLDATETIME NULL,
    CONSTRAINT [PK_tblCuentaInterna] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [Unique_numero_cuenta] UNIQUE NONCLUSTERED ([NumeroCuenta] ASC)
);