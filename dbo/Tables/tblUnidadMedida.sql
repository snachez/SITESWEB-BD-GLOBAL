--============================================================================
-- Nombre del Objeto: tblUnidadMedida.
-- Descripcion:
--		Esta tabla almacena información sobre las unidades de medida utilizadas en el sistema.
--		Contiene registros que representan diferentes unidades de medida, como fajo, muerto, bolsa, etc.
--		Cada unidad de medida tiene un identificador único y puede tener asociados un nombre, un símbolo, una cantidad de unidades, una divisa y presentaciones habilitadas.
-- Objetivo: 
--		Registrar y gestionar las diferentes unidades de medida utilizadas en el sistema.
-- Tipo de Objeto: 
--     Tabla.
-- Motor:
--		MSSQL Server.
-- Origen de los Datos:
--		Los datos provienen de la aplicación web.
-- Permanencia de Datos:
--		Los datos de esta tabla se mantienen en la base de datos mientras las unidades de medida sean relevantes para el sistema.
-- Uso de los datos:
--		Los datos se utilizan para identificar y gestionar las diferentes unidades de medida utilizadas en el sistema.
--		Son parte fundamental en procesos relacionados con la medición de cantidades y la gestión de inventario.
-- Restricciones o consideraciones:
--     No se especifican restricciones adicionales en la descripción.
--	Parametros de Entrada y de Salida:
--     No aplica (ya que es una tabla y no un procedimiento almacenado).
--============================================================================

CREATE TABLE [dbo].[tblUnidadMedida] (
    [Id]                 INT           IDENTITY (1, 1) NOT NULL,
    [Nombre]             VARCHAR (250) NOT NULL,
    [Simbolo]            VARCHAR (250) NOT NULL,
    [Cantidad_Unidades]  INT           NOT NULL,
    [Activo]             BIT           CONSTRAINT [CT_tblUnidadMedida_Activo] DEFAULT (1) NOT NULL,
    [Fecha_Creacion]     SMALLDATETIME CONSTRAINT [CT_tblUnidadMedida_FechaCreacion] DEFAULT (CONVERT([smalldatetime],getdate())) NOT NULL,
    [Fecha_Modificacion] SMALLDATETIME NULL,
    CONSTRAINT [PK_tblUnidadMedida] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [Unique_Nombre_UnidadMedida] UNIQUE NONCLUSTERED ([Nombre] ASC),
    CONSTRAINT [Unique_Simbolo_UnidadMedida] UNIQUE NONCLUSTERED ([Simbolo] ASC)
);