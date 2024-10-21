--============================================================================
-- Nombre del Objeto: tblUnidadMedida_x_Divisa.
-- Descripcion:
--		Esta tabla establece una relación entre unidades de medida y divisas.
--		Asocia una unidad de medida específica con una divisa particular.
-- Objetivo: 
--		Permitir la asociación de unidades de medida con divisas para su uso en el sistema.
-- Tipo de Objeto: 
--     Tabla.
-- Motor:
--		MSSQL Server.
-- Origen de los Datos:
--		Los datos provienen de la aplicación web.
-- Permanencia de Datos:
--		Los datos de esta tabla se mantienen en la base de datos mientras la asociación entre unidades de medida y divisas sea relevante para el sistema.
-- Uso de los datos:
--		Los datos se utilizan para determinar la relación entre una unidad de medida y una divisa, lo que puede ser necesario en diversos procesos dentro del sistema, como cálculos de conversión de unidades.
-- Restricciones o consideraciones:
--     No se especifican restricciones adicionales en la descripción.
--	Parametros de Entrada y de Salida:
--     No aplica (ya que es una tabla y no un procedimiento almacenado).
--============================================================================

CREATE TABLE [dbo].[tblUnidadMedida_x_Divisa] (
    [Id]                  INT           IDENTITY (1, 1) NOT NULL,
    [Fk_Id_Unidad_Medida] INT           NULL,
    [Fk_Id_Divisa]        INT           NULL,
    [Activo]              BIT           CONSTRAINT [CT_tblUnidadMedida_x_Divisa_Activo] DEFAULT ((1)) NOT NULL,
    [Fecha_Creacion]      SMALLDATETIME CONSTRAINT [CT_tblUnidadMedida_x_Divisa_FechaCreacion] DEFAULT (CONVERT([smalldatetime],getdate())) NULL,
    [Fecha_Modificacion]  SMALLDATETIME NULL,
    CONSTRAINT [PK_tblUnidadMedida_x_Divisa] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_tblUnidadMedida_x_Divisa_tblDivisa] FOREIGN KEY ([Fk_Id_Divisa]) REFERENCES [dbo].[tblDivisa] ([Id]),
    CONSTRAINT [FK_tblUnidadMedida_x_Divisa_tblUnidadMedida] FOREIGN KEY ([Fk_Id_Unidad_Medida]) REFERENCES [dbo].[tblUnidadMedida] ([Id]),
    CONSTRAINT [Unique_UnidadMedida_Divisa] UNIQUE NONCLUSTERED ([Fk_Id_Divisa] ASC, [Fk_Id_Unidad_Medida] ASC)
);