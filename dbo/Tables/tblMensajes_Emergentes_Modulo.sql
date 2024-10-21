--============================================================================
-- Nombre del Objeto: tblMensajes_Emergentes_Modulo.
-- Descripcion:
--		Esta tabla almacena información sobre los metodos de la aplicacion web.
-- Objetivo: 
--		Administrar y almacenar información detallada sobre los modulos de la aplicacion web.
-- Tipo de Objeto: 
--     Tabla.
-- Motor:
--		MSSQL Server.
-- Origen de los Datos:
--		Datos ingresados por script.
-- Permanencia de Datos:
--		Los datos se almacenan de forma permanente para poder mostrar los mensajes emergentes por cada modulo de la aplicacion web.
-- Uso de los datos:
--		Los datos se utilizan para visualizar los mensajes emergentes por modulo.
-- Restricciones o consideraciones:
--     - No aplican restricciones.
--	Parametros de Entrada y de Salida:
--     No aplicable (ya que es una tabla y no un procedimiento almacenado).
--============================================================================

CREATE TABLE [dbo].[tblMensajes_Emergentes_Modulo] (
    [Id]                INT            IDENTITY (1, 1) NOT NULL,
    [Modulo]            VARCHAR (MAX) NOT NULL,
    [FechaCreacion]     SMALLDATETIME  CONSTRAINT [DF_tblMensajes_Emergentes_Modulo_FechaCreacion] DEFAULT (CONVERT([smalldatetime],getdate())) NOT NULL,
    [FechaModificacion] SMALLDATETIME  NULL,
    CONSTRAINT [PK_tblMensajes_Emergentes_Modulo] PRIMARY KEY CLUSTERED ([Id] ASC)
);