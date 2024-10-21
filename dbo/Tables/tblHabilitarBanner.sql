--============================================================================
-- Nombre del Objeto: tblHabilitarBanner.
-- Descripcion:
--		Tabla que almacena información sobre la habilitación o deshabilitación de banners,
--		incluyendo el estado activo, fechas de creación y modificación, etc.
-- Objetivo: 
--		Gestionar la configuración de habilitación de banners en la aplicación.
-- Tipo de Objeto: 
--     Tabla.
-- Motor:
--		MSSQL Server.
-- Origen de los Datos:
--		Datos ingresados por script.
-- Permanencia de Datos:
--		Permanente.
-- Uso de los datos:
--		Utilizado para la gestión de la habilitación/deshabilitación de banners.
-- Restricciones o consideraciones:
--     No se especifican restricciones adicionales en la descripción.
--	Parametros de Entrada y de Salida:
--     No aplica (la tabla almacena datos).
--============================================================================

CREATE TABLE [dbo].[tblHabilitarBanner] (
    [Id]                INT           IDENTITY (1, 1) NOT NULL,
    [Activo]            BIT           CONSTRAINT [CT_tblHabilitarBanner_Activo] DEFAULT ((1)) NOT NULL,
    [FechaCreacion]     SMALLDATETIME CONSTRAINT [CT_tblHabilitarBanner_FechaCreacion] DEFAULT (CONVERT([smalldatetime],getdate())) NOT NULL,
    [FechaModificacion] SMALLDATETIME NULL,
    CONSTRAINT [PK_tblHabilitarBanner] PRIMARY KEY CLUSTERED ([Id] ASC)
);