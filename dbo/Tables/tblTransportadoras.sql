--============================================================================
-- Nombre del Objeto: tblTransportadoras.
-- Descripcion:
--		Esta tabla almacena información sobre las transportadoras.
-- Objetivo: 
--		Administrar y almacenar información detallada sobre los transportadoras.
-- Tipo de Objeto: 
--     Tabla.
-- Motor:
--		MSSQL Server.
-- Origen de los Datos:
--		Los datos provienen de la aplicación web.
-- Permanencia de Datos:
--		Los datos se almacenan de forma permanente para el seguimiento histórico y la gestión de transportadoras.
-- Uso de los datos:
--		Los datos se utilizan para la gestion e identificacion de las transportadoras que se utilizan en la aplicacion web.
-- Restricciones o consideraciones:
--     - La longitud máxima del nombre de la denominación (Nombre) es de 250 caracteres.
--     - Se garantiza que el nombre y el codigo de la transportadora sea única.

--	Parametros de Entrada y de Salida:
--     No aplicable (ya que es una tabla y no un procedimiento almacenado).
--============================================================================

CREATE TABLE [dbo].[tblTransportadoras] (
    [Id]                 INT           IDENTITY (1, 1) NOT NULL,
    [Nombre]             VARCHAR (50)  NOT NULL,
    [Codigo]             VARCHAR (100) NOT NULL,
    [Activo]             BIT           CONSTRAINT [CT_tblTransportadoras_Activo] DEFAULT (1) NOT NULL,
    [Fecha_Creacion]     SMALLDATETIME CONSTRAINT [CT_tblTransportadoras_FechaCreacion] DEFAULT (CONVERT([smalldatetime],getdate())) NULL,
    [Fecha_Modificacion] SMALLDATETIME NULL,
    CONSTRAINT [PK_tblTransportadoras] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [Unique_Codigo_Transportadora] UNIQUE NONCLUSTERED ([Codigo] ASC)
);