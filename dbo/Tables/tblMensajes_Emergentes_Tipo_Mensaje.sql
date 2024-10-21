--============================================================================
-- Nombre del Objeto: tblMensajes_Emergentes_Tipo_Mensaje.
-- Descripcion:
--		Esta tabla almacena información sobre los tipos de mensajes de la aplicacion web.
-- Objetivo: 
--		Administrar y almacenar información detallada sobre los tipos de mensajes de la aplicacion web.
-- Tipo de Objeto: 
--     Tabla.
-- Motor:
--		MSSQL Server.
-- Origen de los Datos:
--		Datos ingresados por script.
-- Permanencia de Datos:
--		Los datos se almacenan de forma permanente para poder clasificar los tipos mensajes emergentes de la aplicacion web.
-- Uso de los datos:
--		Los datos se utilizan para clasificar los tipos de mensajes emergentes.
-- Restricciones o consideraciones:
--     - No aplican restricciones.
--	Parametros de Entrada y de Salida:
--     No aplicable (ya que es una tabla y no un procedimiento almacenado).
--============================================================================


CREATE TABLE [dbo].[tblMensajes_Emergentes_Tipo_Mensaje] (
    [Id]                INT            IDENTITY (1, 1) NOT NULL,
    [TipoMensaje]       VARCHAR (MAX) NOT NULL,
    [FechaCreacion]     SMALLDATETIME  CONSTRAINT [DF_tblMensajes_Emergentes_Tipo_Mensaje_FechaCreacion] DEFAULT (CONVERT([smalldatetime],getdate())) NOT NULL,
    [FechaModificacion] SMALLDATETIME  NULL,
    CONSTRAINT [PK_tblMensajes_Emergentes_Tipo_Mensaje] PRIMARY KEY CLUSTERED ([Id] ASC)
);