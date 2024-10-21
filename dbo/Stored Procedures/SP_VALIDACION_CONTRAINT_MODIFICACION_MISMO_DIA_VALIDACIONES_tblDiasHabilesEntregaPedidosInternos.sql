﻿CREATE PROCEDURE [dbo].[SP_VALIDACION_CONTRAINT_MODIFICACION_MISMO_DIA_VALIDACIONES_tblDiasHabilesEntregaPedidosInternos](
	  @DIA                            		        INT
	, @ID											INT
	, @PERMITE_REMESAS								BIT
	, @ENTREGAS_MISMO_DIA							BIT
	, @ENTREGAS_LUNES								BIT
	, @ENTREGAS_MARTES								BIT
	, @ENTREGAS_MIERCOLES							BIT
	, @ENTREGAS_JUEVES								BIT
	, @ENTREGAS_VIERNES								BIT
	, @ENTREGAS_SABADO								BIT
	, @ENTREGAS_DOMINGO								BIT
	, @HORA_DESDE									TIME(7)
	, @HORA_HASTA									TIME(7)
	, @HORA_LIMITE_MISMO_DIA						TIME(7)
	, @HORA_LIMITE_APROBACION						TIME(7)
	, @HORA_CORTE_DIA								TIME(7)
	, @HORA_LIMITE_APROBACION_MISMO_DIA				TIME(7)
   )
AS
BEGIN
	--
	SET DATEFIRST 1; -- 1 representa el lunes
    DECLARE @MODIFICADO BIT = 0;
    DECLARE @HoraActual TIME = GETDATE();
	DECLARE @FechaActual DATETIME = GETDATE();
	DECLARE @DIA_ACTUAL INT = DATEPART(WEEKDAY,@FechaActual);

	--- Variables que las obtengo del registro actual
	DECLARE @HoraDesde                                          TIME(7);
	DECLARE @HoraCorte                                          TIME(7);
	DECLARE @PERMITE_REMESAS_ACTUALMENTE                        BIT;
	DECLARE @ENTREGAS_MISMO_DIA_ACTUALMENTE					    BIT;
	DECLARE @ENTREGAS_LUNES_ACTUALMENTE						    BIT;
	DECLARE @ENTREGAS_MARTES_ACTUALMENTE					    BIT;
	DECLARE @ENTREGAS_MIERCOLES_ACTUALMENTE						BIT;
	DECLARE @ENTREGAS_JUEVES_ACTUALMENTE						BIT;
	DECLARE @ENTREGAS_VIERNES_ACTUALMENTE						BIT;
	DECLARE @ENTREGAS_SABADO_ACTUALMENTE						BIT;
	DECLARE @ENTREGAS_DOMINGO_ACTUALMENTE						BIT;
	DECLARE @HORA_HASTA_ACTUALMENTE								TIME(7);
	DECLARE @HORA_LIMITE_MISMO_DIA_ACTUALMENTE					TIME(7);
	DECLARE @HORA_LIMITE_APROBACION_ACTUALMENTE					TIME(7);
	DECLARE @HORA_LIMITE_APROBACION_MISMO_DIA_ACTUALMENTE		TIME(7);


    -- Obtener la hora hasta del dia desde tblDiasHabilesEntregaPedidosInternos
    SELECT @HoraDesde = HoraDesde, @HoraCorte = HoraCorteDia, @PERMITE_REMESAS_ACTUALMENTE = PermiteRemesas,
	@ENTREGAS_MISMO_DIA_ACTUALMENTE = PermiteEntregasMismoDia, @ENTREGAS_LUNES_ACTUALMENTE = EntregarLunes,
	@ENTREGAS_MARTES_ACTUALMENTE = EntregarMartes, @ENTREGAS_MIERCOLES_ACTUALMENTE = EntregarMiercoles,
	@ENTREGAS_JUEVES_ACTUALMENTE = EntregarJueves, @ENTREGAS_VIERNES_ACTUALMENTE =EntregarViernes,
	@ENTREGAS_SABADO_ACTUALMENTE = EntregarSabado, @ENTREGAS_DOMINGO_ACTUALMENTE = EntregarDomingo,
	@HORA_HASTA_ACTUALMENTE = HoraHasta, @HORA_LIMITE_MISMO_DIA_ACTUALMENTE = HoraLimiteMismoDia,
	@HORA_LIMITE_APROBACION_ACTUALMENTE = HoraLimiteAprobacion, @HORA_LIMITE_APROBACION_MISMO_DIA_ACTUALMENTE = HoraLimiteAprobacionMismoDia
    FROM tblDiasHabilesEntregaPedidosInternos
    WHERE Dia = DATEPART(WEEKDAY, @FechaActual)
	AND Id = @ID;

	IF @HoraDesde <> @HORA_DESDE OR @HoraCorte <> @HORA_CORTE_DIA OR @PERMITE_REMESAS_ACTUALMENTE <> @PERMITE_REMESAS OR 
	   @ENTREGAS_MISMO_DIA_ACTUALMENTE <> @ENTREGAS_MISMO_DIA OR @ENTREGAS_LUNES_ACTUALMENTE <> @ENTREGAS_LUNES OR
	   @ENTREGAS_MARTES_ACTUALMENTE <> @ENTREGAS_MARTES OR @ENTREGAS_MIERCOLES_ACTUALMENTE <> @ENTREGAS_MIERCOLES OR
	   @ENTREGAS_JUEVES_ACTUALMENTE <> @ENTREGAS_JUEVES 

    BEGIN
	    
		   SET @MODIFICADO = 1

	END

	IF @ENTREGAS_VIERNES_ACTUALMENTE <> @ENTREGAS_VIERNES OR
	   @ENTREGAS_SABADO_ACTUALMENTE <> @ENTREGAS_SABADO OR @ENTREGAS_DOMINGO_ACTUALMENTE <> @ENTREGAS_DOMINGO OR
	   @HORA_HASTA_ACTUALMENTE <> @HORA_HASTA OR @HORA_LIMITE_MISMO_DIA_ACTUALMENTE <> @HORA_LIMITE_MISMO_DIA  OR
	   @HORA_LIMITE_APROBACION_ACTUALMENTE <> @HORA_LIMITE_APROBACION OR @HORA_LIMITE_APROBACION_MISMO_DIA_ACTUALMENTE <> @HORA_LIMITE_APROBACION_MISMO_DIA

	BEGIN
	    
		   SET @MODIFICADO = 1

	END

    -- Validar si la hora actual es igual o mayor a la hora desde y que la hora de corte es mayor o igual
    IF (@MODIFICADO = 1) AND (@HoraActual >= @HoraDesde) AND (@HoraActual <= @HoraCorte) AND (@DIA = @DIA_ACTUAL) AND (@PERMITE_REMESAS_ACTUALMENTE = 1)
    BEGIN

	SET @MODIFICADO = 0

	;THROW 50000, 'Error al modificar el horario. "tblDiasHabilesEntregaPedidosInternos_Modificacion_Dia_Actual_Diferente_Dia_Desde_Corte". El horario actual no se puede modificar porque esta entre la hora desde y corte', 1
  
    END

END