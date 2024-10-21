--============================================================================
-- Nombre del Objeto: tblTransacciones.
-- Descripcion:
--		Esta tabla almacena información sobre las transacciones del sistema web.
-- Objetivo: 
--		Gestionar y almacenar datos relacionados con las transacciones del sistema.
-- Tipo de Objeto: 
--     Tabla.
-- Motor:
--		MSSQL Server.
-- Origen de los Datos:
--		Datos ingresados por script.
-- Permanencia de Datos:
--		Los datos de esta tabla se mantienen en la base de datos mientras las transacciones existan en el sistema.
-- Uso de los datos:
--		Los datos se utilizan para identificar y gestionar las transacciones del sistema.
-- Restricciones o consideraciones:
--     No se especifican restricciones adicionales en la descripción.
--	Parametros de Entrada y de Salida:
--     No aplica (ya que es una tabla y no un procedimiento almacenado).
--============================================================================


CREATE TABLE [dbo].[tblTransacciones] (
    [Id]                INT           IDENTITY (1, 1) NOT NULL,
    [Nombre]            VARCHAR (50)  NOT NULL,
    [Fk_Id_Modulo]      INT           NULL,
    [Codigo]            VARCHAR (50)  NULL,
    [Activo]            BIT           CONSTRAINT [DF_tblTransacciones_Activo] DEFAULT (1) NOT NULL,
    [FechaCreacion]     SMALLDATETIME CONSTRAINT [DF_tblTransacciones_FechaCreacion] DEFAULT (CONVERT([smalldatetime],getdate())) NOT NULL,
    [FechaModificacion] SMALLDATETIME NULL,
    CONSTRAINT [PK_tblTransacciones] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_tblTransacciones_tblModulo] FOREIGN KEY ([Fk_Id_Modulo]) REFERENCES [dbo].[tblModulo] ([Id])
);