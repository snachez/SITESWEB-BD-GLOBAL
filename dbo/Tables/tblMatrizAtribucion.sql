--============================================================================
-- Nombre del Objeto: tblMatrizAtribucion.
-- Descripcion:
--		Esta tabla almacena información sobre la matriz de atribucion.
-- Objetivo: 
--		Administrar y almacenar información detallada sobre los departamentos.
-- Tipo de Objeto: 
--     Tabla.
-- Motor:
--		MSSQL Server.
-- Origen de los Datos:
--		Los datos provienen de la aplicación web.
-- Permanencia de Datos:
--		Los datos se almacenan de forma permanente para el seguimiento histórico y la gestión de matriz de atribucion.
-- Uso de los datos:
--		Los datos se utilizan para tenerl el control de la matriz de atribucion.
-- Restricciones o consideraciones:
--     - La longitud máxima del nombre de la matriz (Nombre) es de 50 caracteres.
--     - Se garantiza que el nombre de la matriz sea única.
--     - [tblMatrizAtribucion_C3_Cambiar_Estados] se valida que la divisa que esta asociada a la matriz se encuentre activa para poder reactivar la matriz
--     - [tblMatrizAtribucion_X_USUARIO_DESACTIVAR] se valida que la matriz no este asociada a un usuario activo para poderla desactivar
--	Parametros de Entrada y de Salida:
--     No aplicable (ya que es una tabla y no un procedimiento almacenado).
--============================================================================

CREATE TABLE [dbo].[tblMatrizAtribucion] (
    [Id]                INT           IDENTITY (1, 1) NOT NULL,
    [Nombre]            VARCHAR (50)  NULL,
    [Fk_Id_Divisa]      INT           NULL,
    [Activo]            BIT           CONSTRAINT [DF_tblMatrizAtribucion_Activo] DEFAULT (1) NULL,
    [FechaCreacion]     SMALLDATETIME CONSTRAINT [DF_tblMatrizAtribucion_FechaCreacion] DEFAULT (CONVERT([smalldatetime],getdate())) NULL,
    [FechaModificacion] SMALLDATETIME NULL,
    CONSTRAINT [PK_tblMatrizAtribucion] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [tblMatrizAtribucion_C3_Cambiar_Estados] CHECK ([dbo].[FN_VALIDACION_CONTRAINT_REACTIVAR_tblMatrizAtribucion]([Activo],[Fk_Id_Divisa])=(1)),
    CONSTRAINT [tblMatrizAtribucion_X_USUARIO_DESACTIVAR] CHECK ([dbo].[FN_VALIDACION_CONTRAINT_DESACTIVAR_tblMatrizAtribucion_Usuario]([Activo],[Id])=(1)),
    CONSTRAINT [FK_tblMatrizAtribucion_tblDivisa] FOREIGN KEY ([Fk_Id_Divisa]) REFERENCES [dbo].[tblDivisa] ([Id]),
    CONSTRAINT [Unique_Nombre_tblMatrizAtribucion] UNIQUE NONCLUSTERED ([Nombre] ASC)
);