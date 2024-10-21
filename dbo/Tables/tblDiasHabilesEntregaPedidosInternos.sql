--============================================================================
-- Nombre del Objeto: tblDiasHabilesEntregaPedidosInternos.
-- Descripcion:
--		Esta tabla define los días hábiles para la entrega de pedidos internos, 
--      especificando las características de entrega para cada día de la semana.
-- Objetivo: 
--		Gestionar y almacenar información sobre los días hábiles para la entrega de pedidos internos.
-- Tipo de Objeto: 
--     Tabla.
-- Motor:
--		MSSQL Server.
-- Origen de los Datos:
--		Los datos provienen de la aplicación web.
-- Permanencia de Datos:
--		Los datos se mantienen de forma permanente para definir los días disponibles y las reglas de entrega.
-- Uso de los datos:
--		Los datos se utilizan para planificar y gestionar las entregas de pedidos internos de manera efectiva.
-- Restricciones o consideraciones:
--     - Se garantiza que cada día especificado sea único.
--     - Se aplican varias restricciones para garantizar la coherencia de los datos de configuración.
--	Parametros de Entrada y de Salida:
--     No aplicable (ya que es una tabla y no un procedimiento almacenado).
--============================================================================

CREATE TABLE [dbo].[tblDiasHabilesEntregaPedidosInternos] (
    [Id]                           INT           IDENTITY (1, 1) NOT NULL,
    [Dia]                          INT           NOT NULL,
    [FkIdCedis]                    INT           NULL,
    [NombreDia]                    VARCHAR (30)  NOT NULL,
    [PermiteRemesas]               BIT           CONSTRAINT [CT_tblDiasHabilesEntregaPedidosInternos_PermiteRemesas] DEFAULT (0) NOT NULL,
    [PermiteEntregasMismoDia]      BIT           CONSTRAINT [CT_tblDiasHabilesEntregaPedidosInternos_PermiteEntregasMismoDia] DEFAULT (0) NOT NULL,
    [EntregarLunes]                BIT           CONSTRAINT [CT_tblDiasHabilesEntregaPedidosInternos_EntregarLunes] DEFAULT (0) NOT NULL,
    [EntregarMartes]               BIT           CONSTRAINT [CT_tblDiasHabilesEntregaPedidosInternos_EntregarMartes] DEFAULT (0) NOT NULL,
    [EntregarMiercoles]            BIT           CONSTRAINT [CT_tblDiasHabilesEntregaPedidosInternos_EntregarMiercoles] DEFAULT (0) NOT NULL,
    [EntregarJueves]               BIT           CONSTRAINT [CT_tblDiasHabilesEntregaPedidosInternos_EntregarJueves] DEFAULT (0) NOT NULL,
    [EntregarViernes]              BIT           CONSTRAINT [CT_tblDiasHabilesEntregaPedidosInternos_EntregarViernes] DEFAULT (0) NOT NULL,
    [EntregarSabado]               BIT           CONSTRAINT [CT_tblDiasHabilesEntregaPedidosInternos_EntregarSabado] DEFAULT (0) NOT NULL,
    [EntregarDomingo]              BIT           CONSTRAINT [CT_tblDiasHabilesEntregaPedidosInternos_EntregarDomingo] DEFAULT (0) NOT NULL,
    [HoraDesde]                    TIME (7)      NULL,
    [HoraHasta]                    TIME (7)      NULL,
    [HoraLimiteMismoDia]           TIME (7)      NULL,
    [Codigo]                       VARCHAR (90)  CONSTRAINT [CT_tblDiasHabilesEntregaPedidosInternos_Codigo] DEFAULT (newid()) NOT NULL,
    [FechaCreacion]                SMALLDATETIME CONSTRAINT [CT_tblDiasHabilesEntregaPedidosInternos_FechaCreacion] DEFAULT (CONVERT([smalldatetime],getdate())) NOT NULL,
    [FechaModificacion]            SMALLDATETIME NULL,
    [HoraLimiteAprobacion]         TIME (7)      NULL,
    [HoraCorteDia]                 TIME (7)      NULL,
    [HoraLimiteAprobacionMismoDia] TIME (7)      NULL,
    CONSTRAINT [PK_tblDiasHabilesEntregaPedidosInternos] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [tbl001_C2_Check_Dia_Between_1_and_7] CHECK ([Dia]>=(1) AND [Dia]<=(7)),
    CONSTRAINT [tbl001_C3_Check_Hora_Desde_Hasta_Not_Null] CHECK (case when [PermiteRemesas]=(1) then case when [HoraDesde] IS NOT NULL AND [HoraHasta] IS NOT NULL AND [HoraCorteDia] IS NOT NULL then (1) else (0) end else (1) end=(1)),
    CONSTRAINT [tbl001_C4_Check_Rango_Hora_Desde_Hasta_Valido] CHECK ([HoraDesde]<=[HoraHasta]),
    CONSTRAINT [tbl001_C5_Check_Al_Menos_Un_DiaEntrega_Requerido_Distinto_Al_De_Entregas_Mismo_Dia] CHECK ([dbo].[FN_VALIDACION_CONTRAINT_tbl001_C5]([Dia],[PermiteRemesas],[PermiteEntregasMismoDia],[EntregarLunes],[EntregarMartes],[EntregarMiercoles],[EntregarJueves],[EntregarViernes],[EntregarSabado],[EntregarDomingo])=(1)),
    CONSTRAINT [tbl001_C6_Check_Regla_De_Los_Dos_Dias] CHECK ([dbo].[FN_VALIDACION_CONTRAINT_tbl001_C6]([Dia],[PermiteRemesas],[EntregarLunes],[EntregarMartes],[EntregarMiercoles],[EntregarJueves],[EntregarViernes],[EntregarSabado],[EntregarDomingo])=(1)),
    CONSTRAINT [tbl001_C7_Check_Hora_Limite_Mismo_Dia_Requerido] CHECK (case when [PermiteEntregasMismoDia]=(1) then case when [HoraLimiteMismoDia] IS NOT NULL then (1) else (0) end else (1) end=(1)),
    CONSTRAINT [tbl001_C8_Check_Hora_Limite_Mismo_Dia_Valida] CHECK ([HoraLimiteMismoDia]>[HoraDesde] AND [HoraLimiteMismoDia]<[HoraHasta]),
    CONSTRAINT [tbl001_C9_Check_Hora_Limite_Aprobacion_Null] CHECK ([dbo].[FN_VALIDACION_CONTRAINT_tbl001_C7]([Dia],[FkIdCedis],[HoraLimiteAprobacion])=(0)),
    CONSTRAINT [tbl002_C1_Check_Hora_Limite_Aprobacion_Hora_Hasta] CHECK (case when [PermiteRemesas]=(1) then case when [HoraLimiteAprobacion]>[HoraHasta] then (1) else (0) end else (1) end=(1)),
    CONSTRAINT [tbl002_C2_Check_Hora_Limite_Aprobacion_Hora_Desde] CHECK (case when [PermiteRemesas]=(0) then case when [HoraLimiteAprobacion]>[HoraDesde] then (1) else (0) end else (1) end=(1)),
    CONSTRAINT [tbl002_C3_Check_Hora_Limite_Aprobacion_Mismo_Dia_Requerido] CHECK (case when [PermiteEntregasMismoDia]=(1) then case when [HoraLimiteAprobacionMismoDia] IS NOT NULL then (1) else (0) end else (1) end=(1)),
    CONSTRAINT [tbl002_C4_Check_Hora_Corte_Dia_Permite_Remesas] CHECK (case when [PermiteRemesas]=(1) then case when [HoraCorteDia]>=[HoraLimiteAprobacion] then (1) else (0) end else (1) end=(1)),
    CONSTRAINT [tbl002_C5_Check_Hora_Corte_Dia_No_Permite_Remesas] CHECK (case when [PermiteRemesas]=(0) then case when [HoraCorteDia]>=[HoraDesde] then (1) else (0) end else (1) end=(1)),
    CONSTRAINT [tbl002_C6_Check_Hora_Aprobacion_Mismo_Dia_Valida] CHECK ([HoraLimiteAprobacionMismoDia]>[HoraLimiteMismoDia]),
    CONSTRAINT [tbl002_C9_Check_HoraLimiteAprobacionMismoDia_Menor_HoraHasta] CHECK (case when [PermiteEntregasMismoDia]=(1) then case when [HoraLimiteAprobacionMismoDia]<=[HoraHasta] then (1) else (0) end else (1) end=(1)),
    CONSTRAINT [tbl001_C1_Unique_Dia] UNIQUE NONCLUSTERED ([Dia] ASC, [FkIdCedis] ASC)
);