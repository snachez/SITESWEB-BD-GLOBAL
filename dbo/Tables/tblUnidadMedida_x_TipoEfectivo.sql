
--============================================================================
-- Nombre del Objeto: tblUnidadMedida_x_TipoEfectivo.
-- Descripcion:
--		Esta tabla establece una relación entre las unidades de medida y los tipos de efectivo.
--		Asocia una unidad de medida con un tipo de efectivo específico.
-- Objetivo: 
--		Permitir la asociación entre unidades de medida y tipos de efectivo para su uso en el sistema.
-- Tipo de Objeto: 
--     Tabla.
-- Motor:
--		MSSQL Server.
-- Origen de los Datos:
--		Los datos provienen de la aplicación web.
-- Permanencia de Datos:
--		Los datos de esta tabla se mantienen en la base de datos mientras la asociación entre unidades de medida y tipos de efectivo sea relevante para el sistema.
-- Uso de los datos:
--		Los datos se utilizan para determinar la relación entre una unidad de medida y un tipo de efectivo, lo que puede ser necesario en diversos procesos dentro del sistema.
-- Restricciones o consideraciones:
--     No se especifican restricciones adicionales en la descripción.
--	Parametros de Entrada y de Salida:
--     No aplica (ya que es una tabla y no un procedimiento almacenado).
--============================================================================

CREATE TABLE [dbo].[tblUnidadMedida_x_TipoEfectivo] (
    [Id]                  INT      IDENTITY (1, 1) NOT NULL,
    [Fk_Id_Unidad_Medida] INT      NULL,
    [Fk_Id_Divisa]        INT      NULL,
    [Fk_Id_Tipo_Efectivo] INT      NULL,
    [Activo]              BIT      CONSTRAINT [CT_tblUnidadMedida_x_TipoEfectivo_Activo] DEFAULT (1) NOT NULL,
    [Fecha_Creacion]      DATETIME CONSTRAINT [CT_tblUnidadMedida_x_TipoEfectivo_FechaCreacion] DEFAULT (CONVERT([smalldatetime],getdate())) NOT NULL,
    [Fecha_Modificacion]  DATETIME NULL,
    CONSTRAINT [PK_tblUnidadMedida_x_TipoEfectivo] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_tblUnidadMedida_x_TipoEfectivo_tblDivisa] FOREIGN KEY ([Fk_Id_Divisa]) REFERENCES [dbo].[tblDivisa] ([Id]),
    CONSTRAINT [FK_tblUnidadMedida_x_TipoEfectivo_tblTipoEfectivo] FOREIGN KEY ([Fk_Id_Tipo_Efectivo]) REFERENCES [dbo].[tblTipoEfectivo] ([Id]),
    CONSTRAINT [FK_tblUnidadMedida_x_TipoEfectivo_tblUnidadMedida] FOREIGN KEY ([Fk_Id_Unidad_Medida]) REFERENCES [dbo].[tblUnidadMedida] ([Id])
);