--============================================================================
-- Nombre del Objeto: tblTipoComunicado.
-- Descripcion:
--		Tabla que almacena información sobre los tipos de comunicados,
--		incluyendo el nombre, una imagen asociada, estado activo, etc.
-- Objetivo: 
--		Gestionar los diferentes tipos de comunicados que pueden ser enviados.
-- Tipo de Objeto: 
--     Tabla.
-- Motor:
--		MSSQL Server.
-- Origen de los Datos:
--		Datos ingresados por script.
-- Permanencia de Datos:
--		Permanente.
-- Uso de los datos:
--		Utilizado para la clasificación de los comunicados según su tipo.
-- Restricciones o consideraciones:
--     No se especifican restricciones adicionales en la descripción.
--	Parametros de Entrada y de Salida:
--     No aplica (la tabla almacena datos).
--============================================================================

CREATE TABLE [dbo].[tblTipoComunicado] (
    [Id]                INT           IDENTITY (1, 1) NOT NULL,
    [Nombre]            VARCHAR (50)  NOT NULL,
    [Imagen]            VARCHAR (50)  NOT NULL,
    [Activo]            BIT           CONSTRAINT [CT_tblTipoComunicado_Activo] DEFAULT ((1)) NOT NULL,
    [FechaCreacion]     SMALLDATETIME CONSTRAINT [CT_tblTipoComunicado_FechaCreacion] DEFAULT (CONVERT([smalldatetime],getdate())) NOT NULL,
    [FechaModificacion] SMALLDATETIME NULL,
    CONSTRAINT [PK_tblTipoComunicado] PRIMARY KEY CLUSTERED ([Id] ASC)
);