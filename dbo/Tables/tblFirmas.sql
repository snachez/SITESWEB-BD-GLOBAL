--============================================================================
-- Nombre del Objeto: tblFirmas.
-- Descripcion:
--		Tabla que almacena información sobre las firmas autorizadas,
--		para aprobar los pedidos.
-- Objetivo: 
--		Gestionar las distintas firmas utilizadas en las transacciones de la organización.
-- Tipo de Objeto: 
--     Tabla.
-- Motor:
--		MSSQL Server.
-- Origen de los Datos:
--		Datos ingresados por script y/o provenientes de la aplicación web.
-- Permanencia de Datos:
--		Permanente.
-- Uso de los datos:
--		Utilizado para la aprobacion de pedidos.
-- Restricciones o consideraciones:
--     No aplican restricciones en esta tabla.
--	Parametros de Entrada y de Salida:
--     No aplica (la tabla almacena datos).
--============================================================================

CREATE TABLE [dbo].[tblFirmas] (
    [Id]                INT             IDENTITY (1, 1) NOT NULL,
    [Firma]             VARCHAR (50)    NOT NULL,
    [MontoDesde]        DECIMAL (38, 2) NOT NULL,
    [MontoHasta]        DECIMAL (38, 2) NOT NULL,
    [Activo]            BIT             CONSTRAINT [DF_tblFirmas_Activo] DEFAULT ((1)) NULL,
    [FechaCreacion]     SMALLDATETIME   CONSTRAINT [DF_tblFirmas_FechaCreacion] DEFAULT (CONVERT([smalldatetime],getdate())) NULL,
    [FechaModificacion] SMALLDATETIME   NULL,
    CONSTRAINT [PK_tblFirmas] PRIMARY KEY CLUSTERED ([Id] ASC)
);