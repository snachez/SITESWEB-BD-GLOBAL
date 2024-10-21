--============================================================================
-- Nombre del Objeto: tblDistrito.
-- Descripcion:
--		Esta tabla almacena información sobre los distritos, que son divisiones administrativas
--      dentro de un cantón en una región geográfica específica.
-- Objetivo: 
--		Gestionar y almacenar información sobre los distritos.
-- Tipo de Objeto: 
--     Tabla.
-- Motor:
--		MSSQL Server.
-- Origen de los Datos:
--		Los datos provienen de un microservicio de otro grupo de desarrolladores.
-- Permanencia de Datos:
--		Los datos se mantienen de forma permanente para definir los distritos y sus relaciones con los cantones.
-- Uso de los datos:
--		Los datos se utilizan para propósitos administrativos, geográficos y de planificación.
-- Restricciones o consideraciones:
--     - Se garantiza que cada distrito especificado sea único dentro de un cantón.
--	Parametros de Entrada y de Salida:
--     No aplicable (ya que es una tabla y no un procedimiento almacenado).
--============================================================================

CREATE TABLE [dbo].[tblDistrito] (
    [Id]                INT           NOT NULL,
    [Nombre]            VARCHAR (50)  NOT NULL,
    [fk_Id_Canton]      INT           NOT NULL,
    [Activo]            BIT           CONSTRAINT [CT_tblDistrito_Activo] DEFAULT (1) NOT NULL,
    [FechaCreacion]     SMALLDATETIME CONSTRAINT [CT_tblDistrito_FechaCreacion] DEFAULT (CONVERT([smalldatetime],getdate())) NOT NULL,
    [FechaModificacion] SMALLDATETIME NULL,
    CONSTRAINT [PK_tblDistrito] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_tblDistrito_tblCanton] FOREIGN KEY ([fk_Id_Canton]) REFERENCES [dbo].[tblCanton] ([Id])
);