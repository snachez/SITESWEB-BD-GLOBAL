--============================================================================
-- Nombre del Objeto: tblDenominaciones.
-- Descripcion:
--		Esta tabla almacena información sobre las denominaciones de efectivo, 
--      incluyendo su valor nominal, relación con una divisa específica y otros detalles.
-- Objetivo: 
--		Administrar y almacenar información detallada sobre las denominaciones de efectivo.
-- Tipo de Objeto: 
--     Tabla.
-- Motor:
--		MSSQL Server.
-- Origen de los Datos:
--		Los datos provienen de la aplicación web.
-- Permanencia de Datos:
--		Los datos se almacenan de forma permanente para el seguimiento histórico y la gestión de denominaciones de efectivo.
-- Uso de los datos:
--		Los datos se utilizan para realizar transacciones financieras, calcular valores y gestionar inventarios de efectivo.
-- Restricciones o consideraciones:
--     - La longitud máxima del nombre de la denominación (Nombre) es de 100 caracteres.
--     - Se garantiza que cada combinación de valor nominal, divisa y BMO sea única.
--	Parametros de Entrada y de Salida:
--     No aplicable (ya que es una tabla y no un procedimiento almacenado).
--============================================================================

CREATE TABLE [dbo].[tblDenominaciones] (
    [Id]                INT           IDENTITY (1, 1) NOT NULL,
    [ValorNominal]      DECIMAL (18)  NOT NULL,
    [Nombre]            VARCHAR (100) NULL,
    [IdDivisa]          INT           NOT NULL,
    [BMO]               INT           NOT NULL,
    [Imagen]            VARCHAR (MAX) NULL,
    [Activo]            BIT           CONSTRAINT [CT_tblDenominaciones_Activo] DEFAULT (1) NOT NULL,
    [FechaCreacion]     SMALLDATETIME CONSTRAINT [CT_tblDenominaciones_FechaCreacion] DEFAULT (CONVERT([smalldatetime],getdate())) NULL,
    [FechaModificacion] SMALLDATETIME NULL,
    CONSTRAINT [PK_tblDenominaciones] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [Contrains_Validate_Relaciones_Denominaciones] CHECK ([dbo].[FN_VALIDACION_CONTRAINT_REACTIVAR_tblDenominaciones]([Activo],[Id])=(1)),
    CONSTRAINT [FK_tblDenominaciones_tblDivisa] FOREIGN KEY ([IdDivisa]) REFERENCES [dbo].[tblDivisa] ([Id]),
    CONSTRAINT [FK_tblDenominaciones_tblTipoEfectivo] FOREIGN KEY ([BMO]) REFERENCES [dbo].[tblTipoEfectivo] ([Id]),
    CONSTRAINT [UNIQUE_NOMINAL_DIVISA_BMO] UNIQUE NONCLUSTERED ([ValorNominal] ASC, [IdDivisa] ASC, [BMO] ASC)
);