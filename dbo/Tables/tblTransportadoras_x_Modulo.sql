--============================================================================
-- Nombre del Objeto: tblTransportadoras_x_Modulo.
-- Descripcion:
--		Esta tabla almacena información sobre la relacion entre las transportadoras y los modulos.
-- Objetivo: 
--		Administrar y almacenar información detallada sobre la relacion entre transportadoras y los modulos.
-- Tipo de Objeto: 
--     Tabla.
-- Motor:
--		MSSQL Server.
-- Origen de los Datos:
--		Los datos provienen de la aplicación web.
-- Permanencia de Datos:
--		Los datos se almacenan de forma permanente para el seguimiento histórico y la gestión de transportadoras asosciadas al modulo.
-- Uso de los datos:
--		Los datos se utilizan para la gestion de la relacion entre transportadora y modulo.
-- Restricciones o consideraciones:
--     - No aplican restricciones

--	Parametros de Entrada y de Salida:
--     No aplicable (ya que es una tabla y no un procedimiento almacenado).
--============================================================================

CREATE TABLE [dbo].[tblTransportadoras_x_Modulo] (
    [Id]                   INT           IDENTITY (1, 1) NOT NULL,
    [Fk_Id_Transportadora] INT           NOT NULL,
    [Fk_Id_Modulo]         INT           NOT NULL,
    [Activo]               BIT           CONSTRAINT [CT_tblTransportadoras_x_Modulo_Activo] DEFAULT ((1)) NOT NULL,
    [Fecha_Creacion]       SMALLDATETIME CONSTRAINT [CT_tblTransportadoras_x_Modulo_FechaCreacion] DEFAULT (CONVERT([smalldatetime],getdate())) NULL,
    [Fecha_Modificacion]   SMALLDATETIME NULL,
    CONSTRAINT [PK_tblTransportadoras_x_Modulo] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_tblTransportadoras_x_Modulo_tblModulo] FOREIGN KEY ([Fk_Id_Modulo]) REFERENCES [dbo].[tblModulo] ([Id]),
    CONSTRAINT [FK_tblTransportadoras_x_Modulo_tblTransportadoras] FOREIGN KEY ([Fk_Id_Transportadora]) REFERENCES [dbo].[tblTransportadoras] ([Id])
);