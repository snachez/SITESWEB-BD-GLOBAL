--============================================================================
-- Nombre del Objeto: tblReportes.
-- Descripcion:
--		Esta tabla almacena información sobre los reportes que se generan en la aplicacion web.
-- Objetivo: 
--		Administrar y almacenar información detallada sobre los reportes que genera la aplicacion.
-- Tipo de Objeto: 
--     Tabla.
-- Motor:
--		MSSQL Server.
-- Origen de los Datos:
--		Datos ingresados por script.
-- Permanencia de Datos:
--		Los datos se almacenan de forma permanente miestras los reportes sean generados.
-- Uso de los datos:
--		Los datos se utilizan para la generacion de lso reportes del sistema.
-- Restricciones o consideraciones:
--     - La longitud máxima del nombre y procedimiento del reporte (Nombre, Procedimiento) es de 500 caracteres.
--     - La longitud máxima de la descripcion del reporte (Descripcion) es de 1000 caracteres.
--	Parametros de Entrada y de Salida:
--     No aplicable (ya que es una tabla y no un procedimiento almacenado).
--============================================================================

CREATE TABLE [dbo].[tblReportes] (
    [Id]                  INT            IDENTITY (1, 1) NOT NULL,
    [Nombre]              VARCHAR (500)  NULL,
    [Procedimiento]       VARCHAR (500)  NULL,
    [Descripcion]         VARCHAR (1000) NULL,
    [Tiene_Filtro_Fechas] INT            NULL,
    [Es_Reporte_VD]       INT            NULL,
    [Fecha_Creacion]      DATETIME       NULL,
    [Fecha_Modificacion]  DATETIME       NULL,
    [Estado]              INT            NULL,
    CONSTRAINT [PK_tblReportes] PRIMARY KEY CLUSTERED ([Id] ASC)
);