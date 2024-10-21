--============================================================================
-- Nombre del Objeto: tblMensajes_Emergentes.
-- Descripcion:
--		Esta tabla almacena información sobre los mensajes emergentes que brinda la aplicacion web.
-- Objetivo: 
--		Administrar y almacenar información detallada sobre los mensajes emergentes.
-- Tipo de Objeto: 
--     Tabla.
-- Motor:
--		MSSQL Server.
-- Origen de los Datos:
--		Datos ingresados por script.
-- Permanencia de Datos:
--		Los datos se almacenan de forma permanente para poder mostrar los mensajes emergentes que brinda la aplicacion web.
-- Uso de los datos:
--		Los datos se utilizan para tenerl el control de los mensajes emergentes que brinda la aplicacion web.
-- Restricciones o consideraciones:
--      No existen restricciones
--	Parametros de Entrada y de Salida:
--     No aplicable (ya que es una tabla y no un procedimiento almacenado).
--============================================================================


CREATE TABLE [dbo].[tblMensajes_Emergentes] (
    [Id]                INT           IDENTITY (1, 1) NOT NULL,
    [Fk_Modulo]         INT           NOT NULL,
    [Fk_Metodo]         INT           NOT NULL,
    [Fk_TipoMensaje]    INT           NOT NULL,
    [Fk_Titulo]         INT           NOT NULL,
    [Mensaje]           VARCHAR (500) NOT NULL,
    [ErrorMensaje]      VARCHAR (500) NULL,
    [FechaCreacion]     SMALLDATETIME CONSTRAINT [DF_tblMensajes_Emergentes_FechaCreacion] DEFAULT (CONVERT([smalldatetime],getdate())) NOT NULL,
    [FechaModificacion] SMALLDATETIME NULL,
    CONSTRAINT [PK_tblMensajes_Emergentes] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_tblMensajes_Emergentes_tblMensajes_Emergentes_Metodo] FOREIGN KEY ([Fk_Metodo]) REFERENCES [dbo].[tblMensajes_Emergentes_Metodo] ([Id]),
    CONSTRAINT [FK_tblMensajes_Emergentes_tblMensajes_Emergentes_Modulo] FOREIGN KEY ([Fk_Modulo]) REFERENCES [dbo].[tblMensajes_Emergentes_Modulo] ([Id]),
    CONSTRAINT [FK_tblMensajes_Emergentes_tblMensajes_Emergentes_TipoMensaje] FOREIGN KEY ([Fk_TipoMensaje]) REFERENCES [dbo].[tblMensajes_Emergentes_Tipo_Mensaje] ([Id]),
    CONSTRAINT [FK_tblMensajes_Emergentes_tblMensajes_Emergentes_Titulo] FOREIGN KEY ([Fk_Titulo]) REFERENCES [dbo].[tblMensajes_Emergentes_Titulo] ([Id])
);