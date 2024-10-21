--============================================================================
-- Nombre del Objeto: tblModulo.
-- Descripcion:
--		Esta tabla almacena información sobre los módulos del sistema web.
-- Objetivo: 
--		Gestionar y almacenar datos relacionados con los módulos del sistema.
-- Tipo de Objeto: 
--     Tabla.
-- Motor:
--		MSSQL Server.
-- Origen de los Datos:
--		Datos ingresados por script.
-- Permanencia de Datos:
--		Los datos de esta tabla se mantienen en la base de datos mientras los módulos existan en el sistema.
-- Uso de los datos:
--		Los datos se utilizan para identificar y gestionar los módulos del sistema.
-- Restricciones o consideraciones:
--     No se especifican restricciones adicionales en la descripción.
--	Parametros de Entrada y de Salida:
--     No aplica (ya que es una tabla y no un procedimiento almacenado).
--============================================================================

CREATE TABLE [dbo].[tblModulo] (
    [Id]                INT           IDENTITY (1, 1) NOT NULL,
    [Nombre]            VARCHAR (100) NULL,
    [FechaCreacion]     SMALLDATETIME CONSTRAINT [CT_tblModulo_FechaCreacion] DEFAULT (CONVERT([smalldatetime],getdate())) NULL,
    [FechaModificacion] SMALLDATETIME NULL,
    [Activo]            BIT           CONSTRAINT [CT_tblModulo_Activo] DEFAULT (1) NOT NULL,
    CONSTRAINT [PK_tblModulo] PRIMARY KEY CLUSTERED ([Id] ASC)
);