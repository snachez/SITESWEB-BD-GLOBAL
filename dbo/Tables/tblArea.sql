--============================================================================
-- Nombre del Objeto: tblArea.
-- Descripcion:
--		Esta tabla almacena información sobre las areas, incluyendo la relacion con el Departamento,
--		códigos, y otras propiedades relacionadas.
-- Objetivo: 
--		Administrar y almacenar información detallada del area.
-- Tipo de Objeto: 
--     Tabla.
-- Motor:
--		MSSQL Server.
-- Origen de los Datos:
--		Información interna y externa relacionada con las areas.
-- Permanencia de Datos:
--		Los datos se almacenan de forma permanente para el seguimiento histórico.
-- Uso de los datos:
--		La tabla se utiliza para gestionar y consultar información sobre areas.
-- Restricciones o consideraciones:
--     - Se utiliza la función [FN_VALIDACION_CONTRAINT_ASIGNACION_DEPARTAMENTO_ACTIVO_tblArea_T2_C3] para validar si en la tabla tblArea
--       al agregar el Departamento este activo en su respectiva tabla.
--     - Se utiliza la función [FN_VALIDACION_CONTRAINT_REACTIVAR_tblArea_T2_C4] para validar si en la tabla tblArea
--       al activar una area sus valores de Departamento este activo en su respectiva tabla.
--     - Se utiliza la función [FN_VALIDACION_CONTRAINT_DESACTIVAR_tblArea_T2_C5] para validar si en la tabla tblArea
--       al desactivar una area esta se encuentra ligada a otra tabla.
--	Parametros de Entrada y de Salida:
--     No aplicable (ya que es una tabla y no un procedimiento almacenado).
--============================================================================
CREATE TABLE [dbo].[tblArea] (
    [Id]                 INT           IDENTITY (1, 1) NOT NULL,
    [Nombre]             VARCHAR (30)  NOT NULL,
    [Fk_Id_Departamento] INT           NOT NULL,
    [Activo]             BIT           CONSTRAINT [CT_tblArea_Activo] DEFAULT ((1)) NOT NULL,
    [FechaCreacion]      SMALLDATETIME CONSTRAINT [CT_tblArea_FechaCreacion] DEFAULT (CONVERT([smalldatetime],getdate())) NOT NULL,
    [FechaModificacion]  SMALLDATETIME NULL,
    CONSTRAINT [PK_tblArea] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [t2_C3_Asignacion_Departamento_Activo] CHECK ([dbo].[FN_VALIDACION_CONTRAINT_ASIGNACION_DEPARTAMENTO_ACTIVO_tblArea_T2_C3]([Fk_Id_Departamento])=(1)),
    CONSTRAINT [t2_C4_Reactivacion_Valida] CHECK ([dbo].[FN_VALIDACION_CONTRAINT_REACTIVAR_tblArea_T2_C4]([Activo],[Fk_Id_Departamento])=(1)),
    CONSTRAINT [t2_C5_Desactivacion_Valida] CHECK ([dbo].[FN_VALIDACION_CONTRAINT_DESACTIVAR_tblArea_T2_C5]([Activo],[Id])=(1)),
    CONSTRAINT [t2_C2_Foreign_Key_Departamento] FOREIGN KEY ([Fk_Id_Departamento]) REFERENCES [dbo].[tblDepartamento] ([Id]),
    CONSTRAINT [t2_C1_Unique_Nombre_Area] UNIQUE NONCLUSTERED ([Nombre] ASC, [Fk_Id_Departamento] ASC)
);