--============================================================================
-- Nombre del Objeto: tblDivisa_x_TipoEfectivo.
-- Descripcion:
--		Esta tabla representa la relación entre las divisas y los tipos de efectivo, indicando
--      qué tipo de efectivo está asociado a qué divisa.
-- Objetivo: 
--		Gestionar las relaciones entre las divisas y los tipos de efectivo.
-- Tipo de Objeto: 
--     Tabla.
-- Motor:
--		MSSQL Server.
-- Origen de los Datos:
--		Los datos pueden provenir de registros de tipos de efectivo y divisas en la base de datos.
-- Permanencia de Datos:
--		Los datos de esta tabla se mantienen mientras existan relaciones entre divisas y tipos de efectivo.
-- Uso de los datos:
--		Los datos se utilizan para determinar qué tipo de efectivo se puede usar con una divisa específica.
--		Los nombres de tipo de efectivo y divisas pueden ser útiles para identificación y presentación de información.
-- Restricciones o consideraciones:
--     - Se garantiza que cada combinación de divisa y tipo de efectivo sea única.
--	Parametros de Entrada y de Salida:
--     No aplicable (ya que es una tabla y no un procedimiento almacenado).
--============================================================================

CREATE TABLE [dbo].[tblDivisa_x_TipoEfectivo] (
    [Id]                 INT           IDENTITY (1, 1) NOT NULL,
    [FkIdTipoEfectivo]   INT           NULL,
    [FkIdDivisa]         INT           NULL,
    [FechaCreacion]      SMALLDATETIME CONSTRAINT [CT_tblDivisa_x_TipoEfectivo_FechaCreacion] DEFAULT (CONVERT([smalldatetime],getdate())) NULL,
    [FechaModificacion]  SMALLDATETIME NULL,
    [Activo]             BIT           CONSTRAINT [CT_tblDivisa_x_TipoEfectivo_Activo] DEFAULT (1) NULL,
    [NombreTipoEfectivo] VARCHAR (150) NULL,
    [NombreDivisa]       VARCHAR (150) NULL,
    CONSTRAINT [PK_tblDivisa_x_TipoEfectivo] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_tblDivisa_x_TipoEfectivo_tblDivisa] FOREIGN KEY ([FkIdDivisa]) REFERENCES [dbo].[tblDivisa] ([Id]),
    CONSTRAINT [FK_TipoEfectivo_X_tblDivisa_x_TipoEfectivo] FOREIGN KEY ([FkIdTipoEfectivo]) REFERENCES [dbo].[tblTipoEfectivo] ([Id]),
    CONSTRAINT [UNIQUE_tblDivisa_x_TipoEfectivo] UNIQUE NONCLUSTERED ([FkIdDivisa] ASC, [FkIdTipoEfectivo] ASC)
);