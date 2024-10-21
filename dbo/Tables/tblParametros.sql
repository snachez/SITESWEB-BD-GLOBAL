--============================================================================
-- Nombre del Objeto: tblParametros.
-- Descripcion:
--		Esta tabla almacena información sobre los parametros de configuracion para ciertas restricciones.
-- Objetivo: 
--		Gestionar y almacenar datos parametrizables del sistema.
-- Tipo de Objeto: 
--     Tabla.
-- Motor:
--		MSSQL Server.
-- Origen de los Datos:
--		Datos ingresados por script.
-- Permanencia de Datos:
--		Los datos de esta tabla se mantienen en la base de datos miesntras sean parametros que se necesiten.
-- Uso de los datos:
--		Los datos se utilizan para parametrizar.
-- Restricciones o consideraciones:
--     No se especifican restricciones adicionales en la descripción.
--	Parametros de Entrada y de Salida:
--     No aplica (ya que es una tabla y no un procedimiento almacenado).
--============================================================================


CREATE TABLE [dbo].[tblParametros] (
    [Id]                INT             IDENTITY (1, 1) NOT NULL,
    [Codigo]            INT             NOT NULL,
    [Nombre]            VARCHAR (200)  NOT NULL,
    [Descripcion]       VARCHAR (2000) NOT NULL,
    [Valor]             VARCHAR (MAX)  NOT NULL,
    [Activo]            BIT             CONSTRAINT [DF_tblParametros_Activo] DEFAULT ((1)) NOT NULL,
    [FechaCreacion]     SMALLDATETIME   CONSTRAINT [DF_tblParametros_FechaCreacion] DEFAULT (CONVERT([smalldatetime],getdate())) NOT NULL,
    [FechaModificacion] SMALLDATETIME   NULL,
    CONSTRAINT [PK_tblParametros] PRIMARY KEY CLUSTERED ([Id] ASC)
);