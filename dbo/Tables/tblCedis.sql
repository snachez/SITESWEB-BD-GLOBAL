--============================================================================
-- Nombre del Objeto: tblCanton.
-- Descripcion:
--		Esta tabla almacena información sobre los cedis, que son subdivisiones administrativas
--		dentro de una provincia.
-- Objetivo: 
--		Administrar y almacenar información detallada de los cedis.
-- Tipo de Objeto: 
--     Tabla.
-- Motor:
--		MSSQL Server.
-- Origen de los Datos:
--		Los datos provienen de un microservicio de otro grupo de desarrolladores.
-- Permanencia de Datos:
--		Los datos se almacenan de forma permanente para el seguimiento histórico de los cedis.
-- Uso de los datos:
--		Los datos se utilizan para consultar y gestionar información sobre los cedis .
-- Restricciones o consideraciones:
--     - Se utiliza la función [Constrains_Validate_Relaciones_Padre_Cedis] para validar 
--       al activar un cedis que sus valores de Pais este activo en su respectiva tabla.
--     - Se utiliza la función [[tblCedis_C4_Asignacion_Pais_Activo]] para validar 
--       que el Cedis no este relacionado en alguna tabla y poder activatr o desactivar este.
--	Parametros de Entrada y de Salida:
--     No aplicable (ya que es una tabla y no un procedimiento almacenado).
--============================================================================

CREATE TABLE [dbo].[tblCedis] (
    [Id_Cedis]          INT            IDENTITY (1, 1) NOT NULL,
    [Nombre]            VARCHAR (50)  NOT NULL,
    [Codigo_Cedis]      VARCHAR (100) NOT NULL,
    [Fk_Id_Pais]        INT            NOT NULL,
    [Activo]            BIT            CONSTRAINT [DF_tblCedis_Activo] DEFAULT ((1)) NOT NULL,
    [FechaCreacion]     SMALLDATETIME  CONSTRAINT [DF_tblCedis_FechaCreacion] DEFAULT (CONVERT([smalldatetime],getdate())) NOT NULL,
    [FechaModificacion] SMALLDATETIME  NULL,
    CONSTRAINT [PK_tblCedis] PRIMARY KEY CLUSTERED ([Id_Cedis] ASC),
    CONSTRAINT [Constrains_Validate_Relaciones_Padre_Cedis] CHECK ([dbo].[FN_VALIDACION_CONTRAINT_DESACTIVAR_tblCedis]([Activo],[Id_Cedis])=(1)),
    CONSTRAINT [tblCedis_C4_Asignacion_Pais_Activo] CHECK ([dbo].[FN_VALIDACION_CONTRAINT_REACTIVAR_tblCedis_C4]([Activo],[Fk_Id_Pais])=(1)),
    CONSTRAINT [FK_tblCedis_tblPais] FOREIGN KEY ([Fk_Id_Pais]) REFERENCES [dbo].[tblPais] ([Id]),
    CONSTRAINT [Unique_Codigo_Cedis] UNIQUE NONCLUSTERED ([Codigo_Cedis] ASC),
    CONSTRAINT [Unique_Nombre_Cedis] UNIQUE NONCLUSTERED ([Nombre] ASC, [Fk_Id_Pais] ASC)
);