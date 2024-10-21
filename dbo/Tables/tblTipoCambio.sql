--============================================================================
-- Nombre del Objeto: tblTipoCambio.
-- Descripcion:
--		Tabla que almacena información sobre los tipos de cambio entre divisas,
--		incluyendo la divisa cotizada, tasas de compra y venta, estado activo, etc.
-- Objetivo: 
--		Gestionar los tipos de cambio entre distintas divisas.
-- Tipo de Objeto: 
--     Tabla.
-- Motor:
--		MSSQL Server.
-- Origen de los Datos:
--		Datos ingresados por un grupo del BAC.
-- Permanencia de Datos:
--		Permanente.
-- Uso de los datos:
--		Utilizado para la gestión de tipos de cambio en transacciones financieras.
-- Restricciones o consideraciones:
--     No se especifican restricciones adicionales en la descripción.
--	Parametros de Entrada y de Salida:
--     No aplica (la tabla almacena datos).
--============================================================================

CREATE TABLE [dbo].[tblTipoCambio] (
    [Id]                   INT          IDENTITY (1, 1) NOT NULL,
    [fk_Id_DivisaCotizada] INT          NOT NULL,
    [CompraColones]        DECIMAL (18) NOT NULL,
    [VentaColones]         DECIMAL (18) NOT NULL,
    [Activo]               BIT          CONSTRAINT [CT_tblTipoCambio_Activo] DEFAULT (1) NOT NULL,
    [FechaCreacion]        DATETIME     CONSTRAINT [CT_tblTipoCambio_FechaCreacion] DEFAULT (getdate()) NOT NULL,
    [FechaModificacion]    DATETIME     NULL,
    CONSTRAINT [PK_tblTipoCambio] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_tblTipoCambio_tblDivisa] FOREIGN KEY ([fk_Id_DivisaCotizada]) REFERENCES [dbo].[tblDivisa] ([Id])
);