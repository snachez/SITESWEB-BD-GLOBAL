--============================================================================
-- Nombre del Objeto: tblTransportadoras_x_Pais.
-- Descripcion:
--		Esta tabla almacena información sobre la relacion entre las transportadoras y los paises.
-- Objetivo: 
--		Administrar y almacenar información detallada sobre la relacion entre transportadoras y los paises.
-- Tipo de Objeto: 
--     Tabla.
-- Motor:
--		MSSQL Server.
-- Origen de los Datos:
--		Los datos provienen de la aplicación web.
-- Permanencia de Datos:
--		Los datos se almacenan de forma permanente para el seguimiento histórico y la gestión de transportadoras asosciadas al pais.
-- Uso de los datos:
--		Los datos se utilizan para la gestion de la relacion entre transportadora y pais.
-- Restricciones o consideraciones:
--     - No aplican restricciones

--	Parametros de Entrada y de Salida:
--     No aplicable (ya que es una tabla y no un procedimiento almacenado).
--============================================================================

CREATE TABLE [dbo].[tblTransportadoras_x_Pais] (
    [Id]                   INT           IDENTITY (1, 1) NOT NULL,
    [Fk_Id_Transportadora] INT           NOT NULL,
    [Fk_Id_Pais]           INT           NOT NULL,
    [Activo]               BIT           CONSTRAINT [CT_tblTransportadoras_x_Pais_Activo] DEFAULT (1) NOT NULL,
    [Fecha_Creacion]       SMALLDATETIME CONSTRAINT [CT_tblTransportadoras_x_Pais_FechaCreacion] DEFAULT (CONVERT([smalldatetime],getdate())) NULL,
    [Fecha_Modificacion]   SMALLDATETIME NULL,
    CONSTRAINT [PK_tblTransportadoras_x_Pais] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_tblTransportadoras_x_Pais_tblPais] FOREIGN KEY ([Fk_Id_Pais]) REFERENCES [dbo].[tblPais] ([Id]),
    CONSTRAINT [FK_tblTransportadoras_x_Pais_tblTransportadoras] FOREIGN KEY ([Fk_Id_Transportadora]) REFERENCES [dbo].[tblTransportadoras] ([Id])
);