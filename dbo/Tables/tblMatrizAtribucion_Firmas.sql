--============================================================================
-- Nombre del Objeto: tblMatrizAtribucion_Firmas.
-- Descripcion:
--		Esta tabla almacena información sobre la matriz de atribucion y su relacion con firmas.
-- Objetivo: 
--		Administrar y almacenar información detallada sobre la matriz de atribucion y su relacion con firmas.
-- Tipo de Objeto: 
--     Tabla.
-- Motor:
--		MSSQL Server.
-- Origen de los Datos:
--		Los datos provienen de la aplicación web.
-- Permanencia de Datos:
--		Los datos se almacenan de forma permanente para el seguimiento histórico y la gestión de matriz de atribucion.
-- Uso de los datos:
--		Los datos se utilizan para tenerl el control de la relacion matriz de atribucion y firmas.
-- Restricciones o consideraciones:
--      No aplican restricciones
--	Parametros de Entrada y de Salida:
--     No aplicable (ya que es una tabla y no un procedimiento almacenado).
--============================================================================

CREATE TABLE [dbo].[tblMatrizAtribucion_Firmas] (
    [Id]                     INT           IDENTITY (1, 1) NOT NULL,
    [Fk_Id_MatrizAtribucion] INT           NOT NULL,
    [Fk_Id_Firmas]           INT           NOT NULL,
    [Activo]                 BIT           CONSTRAINT [DF_tblMatrizAtribucion_Firmas_Activo] DEFAULT (1) NOT NULL,
    [FechaCreacion]          SMALLDATETIME CONSTRAINT [DF_tblMatrizAtribucion_Firmas_FechaCreacion] DEFAULT (CONVERT([smalldatetime],getdate())) NOT NULL,
    [FechaModificacion]      SMALLDATETIME NULL,
    CONSTRAINT [PK_tblMatrizAtribucion_Firmas] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_tblMatrizAtribucion_Firmas_tblFirmas] FOREIGN KEY ([Fk_Id_Firmas]) REFERENCES [dbo].[tblFirmas] ([Id]),
    CONSTRAINT [FK_tblMatrizAtribucion_Firmas_tblMatrizAtribucion] FOREIGN KEY ([Fk_Id_MatrizAtribucion]) REFERENCES [dbo].[tblMatrizAtribucion] ([Id])
);