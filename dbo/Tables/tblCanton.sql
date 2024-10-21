--============================================================================
-- Nombre del Objeto: tblCanton.
-- Descripcion:
--		Esta tabla almacena información sobre los cantones, que son subdivisiones administrativas
--		dentro de una provincia.
-- Objetivo: 
--		Administrar y almacenar información detallada de los cantones.
-- Tipo de Objeto: 
--     Tabla.
-- Motor:
--		MSSQL Server.
-- Origen de los Datos:
--		Los datos provienen de un microservicio de otro grupo de desarrolladores.
-- Permanencia de Datos:
--		Los datos se almacenan de forma permanente para el seguimiento histórico de los cantones.
-- Uso de los datos:
--		Los datos se utilizan para consultar y gestionar información sobre los cantones en una provincia.
-- Restricciones o consideraciones:
--     No se especifican restricciones adicionales en la descripción.
--	Parametros de Entrada y de Salida:
--     No aplicable (ya que es una tabla y no un procedimiento almacenado).
--============================================================================

CREATE TABLE [dbo].[tblCanton] (
    [Id]                INT           NOT NULL,
    [Nombre]            VARCHAR (50)  NOT NULL,
    [fk_Id_Provincia]   INT           NOT NULL,
    [Activo]            BIT           CONSTRAINT [CT_tblCanton_Activo] DEFAULT (1) NOT NULL,
    [FechaCreacion]     SMALLDATETIME CONSTRAINT [CT_tblCanton_FechaCreacion] DEFAULT (CONVERT([smalldatetime],getdate())) NOT NULL,
    [FechaModificacion] SMALLDATETIME NULL,
    CONSTRAINT [PK_tblCanton] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_tblCanton_tblProvincia] FOREIGN KEY ([fk_Id_Provincia]) REFERENCES [dbo].[tblProvincia] ([Id])
);