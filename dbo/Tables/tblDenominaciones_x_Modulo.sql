--============================================================================
-- Nombre del Objeto: tblDenominaciones_x_Modulo.
-- Descripcion:
--		Esta tabla representa la relación entre las denominaciones de efectivo y los módulos de un sistema,
--		indicando qué denominaciones de efectivo están asociadas a qué módulos.
-- Objetivo: 
--		Administrar y almacenar información sobre la relación entre las denominaciones de efectivo y los módulos del sistema.
-- Tipo de Objeto: 
--     Tabla.
-- Motor:
--		MSSQL Server.
-- Origen de los Datos:
--		Los datos provienen de la aplicación web.
-- Permanencia de Datos:
--		Los datos se almacenan de forma permanente para mantener un registro de las asociaciones entre denominaciones de efectivo y módulos.
-- Uso de los datos:
--		Los datos se utilizan para controlar la disponibilidad de denominaciones de efectivo en los módulos del sistema y gestionar su uso.
-- Restricciones o consideraciones:
--     - Se garantiza que cada combinación de módulo y denominación de efectivo sea única.
--	Parametros de Entrada y de Salida:
--     No aplicable (ya que es una tabla y no un procedimiento almacenado).
--============================================================================

CREATE TABLE [dbo].[tblDenominaciones_x_Modulo] (
    [Id]                 INT           IDENTITY (1, 1) NOT NULL,
    [FkIdModulo]         INT           NULL,
    [FkIdDenominaciones] INT           NULL,
    [FechaCreacion]      SMALLDATETIME CONSTRAINT [CT_tblDenominaciones_x_Modulo_FechaCreacion] DEFAULT (CONVERT([smalldatetime],getdate())) NULL,
    [FechaModificacion]  SMALLDATETIME NULL,
    [Activo]             BIT           CONSTRAINT [CT_tblDenominaciones_x_Modulo_Activo] DEFAULT ((1)) NOT NULL,
    CONSTRAINT [PK_tblDenominaciones_x_Modulo] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_tblDenominaciones_x_Modulo_tblDenominaciones] FOREIGN KEY ([FkIdDenominaciones]) REFERENCES [dbo].[tblDenominaciones] ([Id]),
    CONSTRAINT [FK_tblDenominaciones_x_Modulo_tblModulo] FOREIGN KEY ([FkIdModulo]) REFERENCES [dbo].[tblModulo] ([Id]),
    CONSTRAINT [UNIQUE_tblDenominaciones_x_Modulo] UNIQUE NONCLUSTERED ([FkIdModulo] ASC, [FkIdDenominaciones] ASC)
);