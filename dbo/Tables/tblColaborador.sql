--============================================================================
-- Nombre del Objeto: tblColaborador.
-- Descripcion:
--		Tabla que almacena información sobre los colaboradores de la organización,
--		incluyendo nombre, apellidos, información de inicio de sesión, estado de activo, correo, etc.
-- Objetivo: 
--		Gestionar la información de los colaboradores de la organización.
-- Tipo de Objeto: 
--     Tabla.
-- Motor:
--		MSSQL Server.
-- Origen de los Datos:
--		Los datos provienen de un microservicio de otro grupo de desarrolladores.
-- Permanencia de Datos:
--		Los datos se almacenan de forma permanente para el seguimiento histórico de los colobaradores.
-- Uso de los datos:
--		Utilizado para la gestión de colaboradores y sus datos asociados.
-- Restricciones o consideraciones:
--     La columna 'UserActiveDirectory' debe ser única para cada colaborador.
--	Parametros de Entrada y de Salida:
--     No aplica (la tabla almacena datos).
--============================================================================

CREATE TABLE [dbo].[tblColaborador] (
    [Id]                  INT           IDENTITY (1, 1) NOT NULL,
    [Nombre]              VARCHAR (50)  NULL,
    [Apellido1]           VARCHAR (50)  NULL,
    [Apellido2]           VARCHAR (50)  NULL,
    [Cedula]              VARCHAR (50)  NULL,
    [UserActiveDirectory] VARCHAR (100) NOT NULL,
    [Activo]              BIT           CONSTRAINT [CT_tblColaborador_Activo] DEFAULT ((1)) NOT NULL,
    [Correo]              VARCHAR (50)  NULL,
    [FechaCreacion]       DATETIME      CONSTRAINT [CT_tblColaborador_FechaCreacion] DEFAULT (getdate()) NOT NULL,
    [FechaModificacion]   DATETIME      NULL,
    CONSTRAINT [PK_tblColaborador] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [Unique_tblColaborador_UserActiveDirectory] UNIQUE NONCLUSTERED ([UserActiveDirectory] ASC)
);