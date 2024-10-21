--============================================================================
-- Nombre del Objeto: tblPais.
-- Descripcion:
--		Esta tabla almacena información sobre los paises.
-- Objetivo: 
--		Administrar y almacenar información detallada sobre los paises.
-- Tipo de Objeto: 
--     Tabla.
-- Motor:
--		MSSQL Server.
-- Origen de los Datos:
--		Los datos provienen de la aplicación web.
-- Permanencia de Datos:
--		Los datos se almacenan de forma permanente para el seguimiento histórico y la gestión de los paises.
-- Uso de los datos:
--		Los datos se utilizan para gestionar e identificar los paises con los que puede rabajar el sistema.
-- Restricciones o consideraciones:
--     - La longitud máxima del nombre del pais (Nombre) es de 250 caracteres.
--     - Se garantiza que el nombre y el codigo del pais sea único.
--     - [Constrains_Validate_Relaciones_Pais] se valida que el pais no este asociado con otro elemento para poder desactivarlo
--	Parametros de Entrada y de Salida:
--     No aplicable (ya que es una tabla y no un procedimiento almacenado).
--============================================================================

CREATE TABLE [dbo].[tblPais] (
    [Id]                INT           IDENTITY (1, 1) NOT NULL,
    [Nombre]            VARCHAR (30)  NOT NULL,
    [Codigo]            VARCHAR (100) NULL,
    [Activo]            BIT           NOT NULL,
    [FechaCreacion]     SMALLDATETIME CONSTRAINT [DF_tblPais_FechaCreacion] DEFAULT (CONVERT([smalldatetime],getdate())) NOT NULL,
    [FechaModificacion] SMALLDATETIME NULL,
    CONSTRAINT [PK_tblPais] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [Constrains_Validate_Relaciones_Pais] CHECK ([dbo].[FN_VALIDACION_CONTRAINT_DESACTIVAR_tblPais]([Activo],[Id])=(1)),
    CONSTRAINT [Unique_Codigo_Pais] UNIQUE NONCLUSTERED ([Codigo] ASC),
    CONSTRAINT [Unique_Nombre_Pais] UNIQUE NONCLUSTERED ([Nombre] ASC)
);