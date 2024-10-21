--============================================================================
-- Nombre del Objeto: tblDivisa.
-- Descripcion:
--		Tabla que almacena información sobre las divisas utilizadas en la organización,
--		incluyendo nombre, nomenclatura, símbolo, descripción, etc.
-- Objetivo: 
--		Gestionar las distintas divisas utilizadas en las transacciones de la organización.
-- Tipo de Objeto: 
--     Tabla.
-- Motor:
--		MSSQL Server.
-- Origen de los Datos:
--		Datos ingresados por script y/o provenientes de la aplicación web.
-- Permanencia de Datos:
--		Permanente.
-- Uso de los datos:
--		Utilizado para la gestión de las divisas y su información asociada.
-- Restricciones o consideraciones:
--     Las columnas 'Nomenclatura' y 'Nombre' deben ser únicas.
--      Se valida que la divisa no este ligada a otro elemnto para poder desactivarla
--	Parametros de Entrada y de Salida:
--     No aplica (la tabla almacena datos).
--============================================================================

CREATE TABLE [dbo].[tblDivisa] (
    [Id]                INT           IDENTITY (1, 1) NOT NULL,
    [Nombre]            VARCHAR (150) NULL,
    [Nomenclatura]      VARCHAR (4)   NOT NULL,
    [Simbolo]           VARCHAR (3)   NULL,
    [Descripcion]       VARCHAR (300) NULL,
    [Activo]            BIT           CONSTRAINT [CT_tblDivisa_Activo] DEFAULT (1) NOT NULL,
    [FechaCreacion]     SMALLDATETIME CONSTRAINT [CT_tblDivisa_FechaCreacion] DEFAULT (CONVERT([smalldatetime],getdate())) NOT NULL,
    [FechaModificacion] SMALLDATETIME NULL,
    CONSTRAINT [PK_tblDivisa] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [Constrains_Validate_Relaciones_Divisas] CHECK ([dbo].[FN_VALIDACION_CONTRAINT_DESACTIVAR_tblDivisas]([Activo],[Id])=(1)),
    CONSTRAINT [Constrains_Validate_Valores_Inactivos] CHECK ([dbo].[FN_VALIDACION_CONTRAINT_REACTIVAR_tblDivisa]([Activo],[Id])=(1)),
    CONSTRAINT [Unique_Nombre_Divisa] UNIQUE NONCLUSTERED ([Nombre] ASC),
    CONSTRAINT [Unique_Nomenclatura_Divisa] UNIQUE NONCLUSTERED ([Nomenclatura] ASC)
);