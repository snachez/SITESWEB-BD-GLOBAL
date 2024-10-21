--============================================================================
-- Nombre del Objeto: tblMensajes_Emergentes_Titulo.
-- Descripcion:
--		Esta tabla almacena información sobre titulos de los mensajes emergentes.
-- Objetivo: 
--		Administrar y almacenar información detallada sobre los titulos de los mensajes de la aplicacion web.
-- Tipo de Objeto: 
--     Tabla.
-- Motor:
--		MSSQL Server.
-- Origen de los Datos:
--		Datos ingresados por script.
-- Permanencia de Datos:
--		Los datos se almacenan de forma permanente para poder visualizar los titulos mensajes emergentes de la aplicacion web.
-- Uso de los datos:
--		Los datos se utilizan para visualizar los titulos de mensajes emergentes.
-- Restricciones o consideraciones:
--     - No aplican restricciones.
--	Parametros de Entrada y de Salida:
--     No aplicable (ya que es una tabla y no un procedimiento almacenado).
--============================================================================

CREATE TABLE [dbo].[tblMensajes_Emergentes_Titulo] (
    [Id]                INT            IDENTITY (1, 1) NOT NULL,
    [Titulo]            VARCHAR (MAX) NOT NULL,
    [FechaCreacion]     SMALLDATETIME  CONSTRAINT [DF_tblMensajes_Emergentes_Titulo_FechaCreacion] DEFAULT (CONVERT([smalldatetime],getdate())) NOT NULL,
    [FechaModificacion] SMALLDATETIME  NULL,
    CONSTRAINT [PK_tblMensajes_Emergentes_Titulo] PRIMARY KEY CLUSTERED ([Id] ASC)
);