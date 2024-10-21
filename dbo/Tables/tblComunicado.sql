--============================================================================
-- Nombre del Objeto: tblComunicado.
-- Descripcion:
--		Tabla que almacena información sobre comunicados enviados a colaboradores,
--		incluyendo el tipo de comunicado, el colaborador destinatario, el mensaje, etc.
-- Objetivo: 
--		Gestionar los comunicados dirigidos a los colaboradores de la organización.
-- Tipo de Objeto: 
--     Tabla.
-- Motor:
--		MSSQL Server.
-- Origen de los Datos:
--		Datos ingresados por script y/o provenientes de la aplicación web.
-- Permanencia de Datos:
--		Permanente.
-- Uso de los datos:
--		Utilizado para la gestión de comunicados y su relación con los colaboradores.
-- Restricciones o consideraciones:
--     La columna 'FkHabilitarBanner' debe tener una referencia válida en la tabla 'tblHabilitarBanner'.
--	Parametros de Entrada y de Salida:
--     No aplica (la tabla almacena datos).
--============================================================================

CREATE TABLE [dbo].[tblComunicado] (
    [Id]                INT           IDENTITY (1, 1) NOT NULL,
    [FkTipoComunicado]  INT           NOT NULL,
    [FKColaborador]     INT           NOT NULL,
    [Mensaje]           VARCHAR (500) NOT NULL,
    [FkHabilitarBanner] INT           NOT NULL,
    [Activo]            BIT           CONSTRAINT [CT_tblComunicado_Activo] DEFAULT ((1)) NOT NULL,
    [FechaCreacion]     SMALLDATETIME CONSTRAINT [CT_tblComunicado_FechaCreacion] DEFAULT (CONVERT([smalldatetime],getdate())) NOT NULL,
    [FechaModificacion] SMALLDATETIME NULL,
    CONSTRAINT [PK_tblComunicado] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [tblComunicado_C4_EXISTE_COMUNICADO] CHECK ([dbo].[FN_VALIDACION_CONTRAINT_EXISTE_COMUNICADO_tblComunicado]([Mensaje])=(1)),
    CONSTRAINT [tblComunicado_C6_MAXIMO_COMUNICADOS] CHECK ([dbo].[FN_VALIDACION_CONTRAINT_MAXIMO_COMUNICADOS_tblComunicado]([Activo])=(1)),
    CONSTRAINT [FK_tblComunicado_tblColaborador] FOREIGN KEY ([FKColaborador]) REFERENCES [dbo].[tblColaborador] ([Id]),
    CONSTRAINT [FK_tblComunicado_tblHabilitarBanner] FOREIGN KEY ([FkHabilitarBanner]) REFERENCES [dbo].[tblHabilitarBanner] ([Id]),
    CONSTRAINT [FK_tblComunicado_tblTipoComunicado] FOREIGN KEY ([FkTipoComunicado]) REFERENCES [dbo].[tblTipoComunicado] ([Id])
);