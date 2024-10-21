--============================================================================
-- Nombre del Objeto: tblDepartamrnto.
-- Descripcion:
--		Esta tabla almacena información sobre los departamentos.
-- Objetivo: 
--		Administrar y almacenar información detallada sobre los departamentos.
-- Tipo de Objeto: 
--     Tabla.
-- Motor:
--		MSSQL Server.
-- Origen de los Datos:
--		Los datos provienen de la aplicación web.
-- Permanencia de Datos:
--		Los datos se almacenan de forma permanente para el seguimiento histórico y la gestión de departamento.
-- Uso de los datos:
--		Los datos se utilizan para tenerl el control del acceso de la informacion por usuario y acceso por depatamentos y roles.
-- Restricciones o consideraciones:
--     - La longitud máxima del nombre de la denominación (Nombre) es de 50 caracteres.
--     - Se garantiza que el nombre de la denominacion sea única.
--     - [Constrains_Validate_Relaciones_Departamento] se valida que el departamento no este asociado con otro elemnto para poder desactivarlo
--	Parametros de Entrada y de Salida:
--     No aplicable (ya que es una tabla y no un procedimiento almacenado).
--============================================================================

CREATE TABLE [dbo].[tblDepartamento] (
    [Id]                INT           IDENTITY (1, 1) NOT NULL,
    [Nombre]            VARCHAR (50) NOT NULL,
    [Activo]            BIT           CONSTRAINT [DF_tblDepartamento_Activo] DEFAULT ((1)) NOT NULL,
    [FechaCreacion]     SMALLDATETIME CONSTRAINT [DF_tblDepartamento_FechaCreacion] DEFAULT (CONVERT([smalldatetime],getdate())) NOT NULL,
    [FechaModificacion] SMALLDATETIME NULL,
    CONSTRAINT [PK_tblDepartamento] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [Constrains_Validate_Relaciones_Departamento] CHECK ([dbo].[FN_VALIDACION_CONTRAINT_DESACTIVAR_tblDepartamento]([Activo],[Id])=(1)),
    CONSTRAINT [t2_C1_Unique_Nombre_Departamento] UNIQUE NONCLUSTERED ([Nombre] ASC)
);