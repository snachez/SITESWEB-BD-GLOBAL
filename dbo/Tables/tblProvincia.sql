--============================================================================
-- Nombre del Objeto: tblProvincia.
-- Descripcion:
--		Esta tabla almacena información sobre las provincias.
--		Es parte de la estructura básica de la geografía del sistema.
--		Se registran las provincias disponibles en el sistema.
-- Objetivo: 
--		Gestionar y almacenar datos relacionados con las provincias.
-- Tipo de Objeto: 
--     Tabla.
-- Motor:
--		MSSQL Server.
-- Origen de los Datos:
--		Datos ingresados por script.
-- Permanencia de Datos:
--		Los datos de esta tabla se mantienen en la base de datos mientras las provincias existan en el sistema.
-- Uso de los datos:
--		Los datos se utilizan para identificar y gestionar las provincias dentro del sistema.
--		Son parte de la estructura básica de la geografía y pueden ser utilizados en varios procesos del sistema.
-- Restricciones o consideraciones:
--     No se especifican restricciones adicionales en la descripción.
--	Parametros de Entrada y de Salida:
--     No aplica (ya que es una tabla y no un procedimiento almacenado).
--============================================================================

CREATE TABLE [dbo].[tblProvincia] (
    [Id]                INT           NOT NULL,
    [Nombre]            VARCHAR (50)  NOT NULL,
    [Activo]            BIT           CONSTRAINT [CT_tblProvincia_Activo] DEFAULT ((1)) NOT NULL,
    [FechaCreacion]     SMALLDATETIME CONSTRAINT [CT_tblProvincia_FechaCreacion] DEFAULT (CONVERT([smalldatetime],getdate())) NOT NULL,
    [FechaModificacion] SMALLDATETIME NULL,
    CONSTRAINT [PK_tblProvincia] PRIMARY KEY CLUSTERED ([Id] ASC)
);