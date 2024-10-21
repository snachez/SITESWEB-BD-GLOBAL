--============================================================================
-- Nombre del Objeto: tblTipoEfectivo.
-- Descripcion:
--		Esta tabla almacena información sobre los tipos de efectivo utilizados en el sistema.
--		Contiene registros que representan diferentes tipos de efectivo, como efectivo en moneda local, dólares, euros, etc.
--		Cada tipo de efectivo tiene un identificador único y un nombre descriptivo.
-- Objetivo: 
--		Registrar y gestionar los diferentes tipos de efectivo utilizados en el sistema.
-- Tipo de Objeto: 
--     Tabla.
-- Motor:
--		MSSQL Server.
-- Origen de los Datos:
--		Los datos provienen de la aplicación web.
-- Permanencia de Datos:
--		Los datos de esta tabla se mantienen en la base de datos mientras los tipos de efectivo sean relevantes para el sistema.
-- Uso de los datos:
--		Los datos se utilizan para identificar y gestionar los diferentes tipos de efectivo utilizados en el sistema.
--		Son parte fundamental en procesos relacionados con transacciones financieras y gestión de fondos.
-- Restricciones o consideraciones:
--     No se especifican restricciones adicionales en la descripción.
--	Parametros de Entrada y de Salida:
--     No aplica (ya que es una tabla y no un procedimiento almacenado).
--============================================================================

CREATE TABLE [dbo].[tblTipoEfectivo] (
    [Id]                INT           IDENTITY (1, 1) NOT NULL,
    [Nombre]            VARCHAR (100) NOT NULL,
    [Activo]            BIT           CONSTRAINT [CT_tblTipoEfectivo_Activo] DEFAULT ((1)) NOT NULL,
    [FechaCreacion]     SMALLDATETIME CONSTRAINT [CT_tblTipoEfectivo_FechaCreacion] DEFAULT (CONVERT([smalldatetime],getdate())) NULL,
    [FechaModificacion] SMALLDATETIME NULL,
    CONSTRAINT [PK_tblTipoEfectivo] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [Constrains_Validate_Relaciones_TipoEfectivo] CHECK ([dbo].[FN_VALIDACION_CONTRAINT_DESACTIVAR_tblTipoEfectivo]([Activo],[Id])=(0)),
    CONSTRAINT [Unique_Nombre_TipoEfectivo] UNIQUE NONCLUSTERED ([Nombre] ASC)
);