--============================================================================
-- Nombre del Objeto: tblMatrizAtribucion_Transaccion.
-- Descripcion:
--		Esta tabla almacena información sobre la relacion de las transacciones asociadas a la matriz de atribucion.
-- Objetivo: 
--		Administrar y almacenar información detallada sobre las transacciones asociadas a la matriz de atribucion.
-- Tipo de Objeto: 
--     Tabla.
-- Motor:
--		MSSQL Server.
-- Origen de los Datos:
--		Los datos provienen de la aplicación web.
-- Permanencia de Datos:
--		Los datos se almacenan de forma permanente para el seguimiento histórico y la gestión de las transacciones asociadas a la matriz de atribucion.
-- Uso de los datos:
--		Los datos se utilizan para tenerl el control de las transacciones asociadas a la matriz de atribucion.
-- Restricciones o consideraciones:
--      No existen restricciones
--	Parametros de Entrada y de Salida:
--     No aplicable (ya que es una tabla y no un procedimiento almacenado).
--============================================================================

CREATE TABLE [dbo].[tblMatrizAtribucion_Transaccion] (
    [Id]                     INT           IDENTITY (1, 1) NOT NULL,
    [Fk_Id_MatrizAtribucion] INT           NOT NULL,
    [Fk_Id_Transaccion]      INT           NOT NULL,
    [Activo]                 BIT           CONSTRAINT [DF_tblMatrizAtribucion_x_Transaccion_Activo] DEFAULT ((1)) NOT NULL,
    [FechaCreacion]          SMALLDATETIME CONSTRAINT [DF_tblMatrizAtribucion_x_Transaccion_FechaCreacion] DEFAULT (CONVERT([smalldatetime],getdate())) NOT NULL,
    [FechaModificacion]      SMALLDATETIME NULL,
    CONSTRAINT [PK_tblMatrizAtribucion_x_Transaccion] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_tblMatrizAtribucion_x_Transaccion_tblMatrizAtribucion] FOREIGN KEY ([Fk_Id_MatrizAtribucion]) REFERENCES [dbo].[tblMatrizAtribucion] ([Id]),
    CONSTRAINT [FK_tblMatrizAtribucion_x_Transaccion_tblTransaccion] FOREIGN KEY ([Fk_Id_Transaccion]) REFERENCES [dbo].[tblTransacciones] ([Id])
);