CREATE   PROCEDURE [dbo].[SP_UpdateDiasHabilesEntregaPedidosInternos](
  @DIA											INT
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
, @HORA_DESDE									TIME
, @HORA_HASTA									TIME
, @HORA_LIMITE_MISMO_DIA						TIME
, @HORA_LIMITE_APROBACION						TIME
, @HORA_CORTE_DIA								TIME
, @HORA_LIMITE_APROBACION_MISMO_DIA				TIME
)
AS
BEGIN
	---
	BEGIN TRY
		---
			IF(@HORA_LIMITE_APROBACION IS NULL)
		BEGIN
			SET @HORA_LIMITE_APROBACION = '23:59'
		END


		
			DECLARE @ROW VARCHAR(MAX)

			SET @ROW  = (SELECT * FROM tblDiasHabilesEntregaPedidosInternos WHERE Dia = @DIA AND Id = @ID FOR JSON PATH)
			---

			  IF EXISTS(SELECT 1 FROM tblParametros WHERE Codigo = 1 AND ACTIVO = 1)
			  BEGIN

				  EXEC SP_VALIDACION_CONTRAINT_MODIFICACION_MISMO_DIA_VALIDACIONES_tblDiasHabilesEntregaPedidosInternos
				  @DIA = @DIA, @ID = @ID, @PERMITE_REMESAS = @PERMITE_REMESAS, @ENTREGAS_MISMO_DIA = @ENTREGAS_MISMO_DIA, 
				  @ENTREGAS_LUNES = @ENTREGAS_LUNES, @ENTREGAS_MARTES = @ENTREGAS_MARTES, @ENTREGAS_MIERCOLES = @ENTREGAS_MIERCOLES, @ENTREGAS_JUEVES = @ENTREGAS_JUEVES	, @ENTREGAS_VIERNES = @ENTREGAS_VIERNES, @ENTREGAS_SABADO = @ENTREGAS_SABADO								
				 ,@ENTREGAS_DOMINGO = @ENTREGAS_DOMINGO, @HORA_DESDE = @HORA_DESDE, @HORA_HASTA = @HORA_HASTA, @HORA_LIMITE_MISMO_DIA = @HORA_LIMITE_MISMO_DIA, @HORA_LIMITE_APROBACION = @HORA_LIMITE_APROBACION, 
				  @HORA_CORTE_DIA = @HORA_CORTE_DIA, @HORA_LIMITE_APROBACION_MISMO_DIA = @HORA_LIMITE_APROBACION_MISMO_DIA

		      END

			  UPDATE tblDiasHabilesEntregaPedidosInternos SET
			  PermiteRemesas					=		@PERMITE_REMESAS
			, PermiteEntregasMismoDia			=		IIF(@PERMITE_REMESAS = 1, @ENTREGAS_MISMO_DIA, 0)
			, EntregarLunes						=		IIF(@PERMITE_REMESAS = 1 AND @ENTREGAS_LUNES = 1, @ENTREGAS_LUNES, 0)
			, EntregarMartes					=		IIF(@PERMITE_REMESAS = 1 AND @ENTREGAS_MARTES = 1, @ENTREGAS_MARTES, 0)
			, EntregarMiercoles					=		IIF(@PERMITE_REMESAS = 1 AND @ENTREGAS_MIERCOLES = 1, @ENTREGAS_MIERCOLES, 0)
			, EntregarJueves					=		IIF(@PERMITE_REMESAS = 1 AND @ENTREGAS_JUEVES = 1, @ENTREGAS_JUEVES, 0)
			, EntregarViernes					=		IIF(@PERMITE_REMESAS = 1 AND @ENTREGAS_VIERNES = 1, @ENTREGAS_VIERNES, 0)
			, EntregarSabado					=		IIF(@PERMITE_REMESAS = 1 AND @ENTREGAS_SABADO = 1, @ENTREGAS_SABADO, 0)
			, EntregarDomingo					=		IIF(@PERMITE_REMESAS = 1 AND @ENTREGAS_DOMINGO = 1, @ENTREGAS_DOMINGO, 0)
			, HoraDesde							=		IIF(@PERMITE_REMESAS = 1, @HORA_DESDE, '00:00')
			, HoraHasta							=		IIF(@PERMITE_REMESAS = 1, @HORA_HASTA, NULL)
			, HoraLimiteMismoDia				=		IIF(@PERMITE_REMESAS = 1 AND @ENTREGAS_MISMO_DIA = 1, @HORA_LIMITE_MISMO_DIA, NULL)
			, FechaModificacion					=		CURRENT_TIMESTAMP
			, HoraLimiteAprobacion				=		@HORA_LIMITE_APROBACION
			, HoraCorteDia						=		IIF(@PERMITE_REMESAS = 1, @HORA_CORTE_DIA, '23:59')
			, HoraLimiteAprobacionMismoDia		=		IIF(@PERMITE_REMESAS = 1 AND @ENTREGAS_MISMO_DIA = 1, @HORA_LIMITE_APROBACION_MISMO_DIA, NULL)
			WHERE Dia = @DIA AND Id = @ID

		
		---
		SELECT	  @@ROWCOUNT												AS ROWS_AFFECTED
				, CAST(1 AS BIT)											AS SUCCESS
				, ''														AS ERROR_MESSAGE_SP
				, ''														AS CONSTRAINT_TRIGGER_NAME
				, NULL														AS ERROR_NUMBER_SP
				, CONVERT(INT, ISNULL(SCOPE_IDENTITY(), -1))				AS ID
				, @ROW														AS ROW

		---
	END TRY    
	BEGIN CATCH	
		SET @ROW  = (SELECT * FROM tblDiasHabilesEntregaPedidosInternos WHERE Dia = @DIA AND Id = @ID FOR JSON PATH)

		---
		DECLARE @ERROR_MESSAGE VARCHAR(MAX);
		DECLARE @ERROR_MESSAGE1 VARCHAR(MAX) = '%tbl001_C3_Check_Hora_Desde_Hasta_Not_Null%';
		DECLARE @ERROR_MESSAGE2 VARCHAR(MAX) = '%tbl001_C4_Check_Rango_Hora_Desde_Hasta_Valido%';
		DECLARE @ERROR_MESSAGE3 VARCHAR(MAX) = '%tbl001_C5_Check_Al_Menos_Un_DiaEntrega_Requerido_Distinto_Al_De_Entregas_Mismo_Dia%';
		DECLARE @ERROR_MESSAGE4 VARCHAR(MAX) = '%tbl001_C7_Check_Hora_Limite_Mismo_Dia_Requerido%';
		DECLARE @ERROR_MESSAGE5 VARCHAR(MAX) = '%tbl001_C8_Check_Hora_Limite_Mismo_Dia_Valida%';
		DECLARE @ERROR_MESSAGE6 VARCHAR(MAX) = '%tbl001_C6_Check_Regla_De_Los_Dos_Dias%';
		DECLARE @ERROR_MESSAGE7 VARCHAR(MAX) = '%tbl001_C9_Check_Hora_Limite_Aprobacion_Null%';
		DECLARE @ERROR_MESSAGE8 VARCHAR(MAX) = '%tbl002_C1_Check_Hora_Limite_Aprobacion_Hora_Hasta%';
		DECLARE @ERROR_MESSAGE9 VARCHAR(MAX) = '%tbl002_C2_Check_Hora_Limite_Aprobacion_Hora_Desde%';
		DECLARE @ERROR_MESSAGE10 VARCHAR(MAX) = '%tbl002_C3_Check_Hora_Limite_Aprobacion_Mismo_Dia_Requerido%';
		DECLARE @ERROR_MESSAGE11 VARCHAR(MAX) = '%tbl002_C4_Check_Hora_Corte_Dia_Permite_Remesas%';
		DECLARE @ERROR_MESSAGE12 VARCHAR(MAX) = '%tbl002_C5_Check_Hora_Corte_Dia_No_Permite_Remesas%';
		DECLARE @ERROR_MESSAGE13 VARCHAR(MAX) = '%tbl002_C6_Check_Hora_Aprobacion_Mismo_Dia_Valida%';
		DECLARE @ERROR_MESSAGE14 VARCHAR(MAX) = '%tbl002_Check_CorteDia_PermiteEntregaMismoDia%';
		DECLARE @ERROR_MESSAGE15 VARCHAR(MAX) =  '%tbl002_C9_Check_HoraLimiteAprobacionMismoDia_Menor_HoraHasta%';
		DECLARE @ERROR_MESSAGE16 VARCHAR(MAX) = '%tblDiasHabilesEntregaPedidosInternos_Modificacion_Dia_Actual_Diferente_Dia_Desde_Corte%';
		DECLARE @MESSAGEDIA VARCHAR(MAX) = 'Para el día ';


		SET @ERROR_MESSAGE = ERROR_MESSAGE() 
		---
		DECLARE @CONSTRAINT_NAME VARCHAR(MAX) = ''
		---
		DECLARE @NOMBRE_DIA VARCHAR(MAX) = (SELECT top 1 NombreDia FROM tblDiasHabilesEntregaPedidosInternos WHERE Dia = @DIA)
		--
		IF @ERROR_MESSAGE LIKE @ERROR_MESSAGE1 
		BEGIN 
			---
			SET @CONSTRAINT_NAME = 'Check_Hora_Desde_Hasta_Not_Null'
			SET @ERROR_MESSAGE = 'Al seleccionar el día ' + @NOMBRE_DIA + ' como dia hábil para tramitar pedidos internos, debe seleccionar la hora Hasta'
			---
		END
		--
		ELSE IF @ERROR_MESSAGE LIKE @ERROR_MESSAGE2 
		BEGIN 
			---
			SET @CONSTRAINT_NAME = 'Check_Rango_Hora_Desde_Hasta_Valido'
			SET @ERROR_MESSAGE = CONCAT('Para el dia ', @NOMBRE_DIA,', la hora desde(', CONVERT(char(5), @HORA_DESDE, 108), ') debe ser menor o igual que la hora hasta(', CONVERT(char(5), @HORA_HASTA, 108), ')')
			---
		END
		--
		ELSE IF @ERROR_MESSAGE LIKE @ERROR_MESSAGE3
		BEGIN 
			---
			SET @CONSTRAINT_NAME = 'Check_Al_Menos_Un_DiaEntrega_Requerido'
			DECLARE @ERROR_MESSAGEFIRST VARCHAR(MAX) = 'Al pemitir remesas para el día ';
			DECLARE @ERROR_MESSAGESECOND VARCHAR(MAX) = ' y ser el único día de entrega. Debe seleccionar al menos un día extra';
			SET @ERROR_MESSAGE = (SELECT CASE 
												WHEN @DIA = 1 AND @ENTREGAS_LUNES = 1		THEN @ERROR_MESSAGEFIRST + @NOMBRE_DIA + @ERROR_MESSAGESECOND
												WHEN @DIA = 2 AND @ENTREGAS_MARTES = 1		THEN @ERROR_MESSAGEFIRST + @NOMBRE_DIA + @ERROR_MESSAGESECOND
												WHEN @DIA = 3 AND @ENTREGAS_MIERCOLES = 1	THEN @ERROR_MESSAGEFIRST + @NOMBRE_DIA + @ERROR_MESSAGESECOND
												WHEN @DIA = 4 AND @ENTREGAS_JUEVES = 1		THEN @ERROR_MESSAGEFIRST + @NOMBRE_DIA + @ERROR_MESSAGESECOND
												WHEN @DIA = 5 AND @ENTREGAS_VIERNES = 1		THEN @ERROR_MESSAGEFIRST + @NOMBRE_DIA + @ERROR_MESSAGESECOND
												WHEN @DIA = 6 AND @ENTREGAS_SABADO = 1		THEN @ERROR_MESSAGEFIRST + @NOMBRE_DIA + @ERROR_MESSAGESECOND
												WHEN @DIA = 7 AND @ENTREGAS_DOMINGO = 1		THEN @ERROR_MESSAGEFIRST + @NOMBRE_DIA + @ERROR_MESSAGESECOND
												ELSE 'Al habilitar el día ' + @NOMBRE_DIA + ' para tramitar pedidos, debe seleccionar al menos un día de entrega'
										 END)
			---
		END
		--
		ELSE IF @ERROR_MESSAGE LIKE @ERROR_MESSAGE4 
		BEGIN 
			---
			SET @CONSTRAINT_NAME = 'Check_Hora_Limite_Mismo_Dia_Requerido'
			SET @ERROR_MESSAGE = 'La hora limite mismo día es requerida cuando se habilita las entregas para el mismo día(' + @NOMBRE_DIA + ')'
			---
		END
		--
		ELSE IF @ERROR_MESSAGE LIKE @ERROR_MESSAGE5 
		BEGIN 
			---
			SET @CONSTRAINT_NAME = 'Check_Hora_Limite_Mismo_Dia_Valida'
			SET @ERROR_MESSAGE = CONCAT('La hora limite mismo día(', CONVERT(char(5), @HORA_LIMITE_MISMO_DIA, 108), ') debe estár entre el rango seleccionado. Hora desde(', CONVERT(char(5), @HORA_DESDE, 108), ') y hora hasta(', CONVERT(char(5), @HORA_HASTA, 108), ') para el día ', @NOMBRE_DIA)
			---
		END 
		ELSE IF @ERROR_MESSAGE LIKE @ERROR_MESSAGE6 
		BEGIN
			---
			SET @CONSTRAINT_NAME = 'Check_Regla_De_Los_Dos_Dias'
			SET @ERROR_MESSAGE = 'Obligatorio seleccionar un día de entrega más como respaldo. Note que esto ocurre al marcar unicamente el día imediato al ' + @NOMBRE_DIA + ' para entregas. Tome en concideración que ' + @NOMBRE_DIA + ' no cuenta como día de respaldo'
			---
		END 
		ELSE IF  @ERROR_MESSAGE LIKE @ERROR_MESSAGE7 
		BEGIN
			---
			SET @CONSTRAINT_NAME = 'Check_Regla_De_La_Hora_Limite_Aprobacion_Null'
			SET @ERROR_MESSAGE = 'La hora  límite de aprobación es requerida para todos los días previos a los días de entrega habilitados.'
			---
		END 
		ELSE IF @ERROR_MESSAGE LIKE @ERROR_MESSAGE8 
		BEGIN
			---
			SET @CONSTRAINT_NAME = 'Check_Regla_De_La_Hora_Limite_Aprobacion_Superior_Hora_Hasta'
			SET @ERROR_MESSAGE = @MESSAGEDIA + @NOMBRE_DIA + ' la hora limite de aprobación debe ser posterior a la hora hasta. '
			---
		END 
		ELSE IF @ERROR_MESSAGE LIKE @ERROR_MESSAGE9 
		BEGIN
			---
			SET @CONSTRAINT_NAME = 'Check_Regla_De_La_Hora_Limite_Aprobacion_Superior_Hora_Desde'
			SET @ERROR_MESSAGE = @MESSAGEDIA + @NOMBRE_DIA + ' la hora limite de aprobación debe ser posterior a la hora desde.'
			---
		END 
		ELSE IF @ERROR_MESSAGE LIKE @ERROR_MESSAGE10 
		BEGIN
			---
			SET @CONSTRAINT_NAME = 'Check_Regla_De_La_Hora_Limite_Aprobacion_Mismo_Dia_Requerido'
			SET @ERROR_MESSAGE = 'La hora  límite de aprobación mismo día es requerida cuando se ha habilitado la entrega para el mismo día'
			---
		END 
		ELSE IF @ERROR_MESSAGE LIKE @ERROR_MESSAGE11 
		BEGIN
			---
			SET @CONSTRAINT_NAME = 'Check_Regla_De_La_Hora_Corte_Dia_Permite_Remesas'
			SET @ERROR_MESSAGE = @MESSAGEDIA + @NOMBRE_DIA + ' la Hora Corte del día debe ser posterior o igual a la Hora Limite de Aprobacion.'
			---
		END 
		ELSE IF ERROR_MESSAGE() LIKE @ERROR_MESSAGE12 
		BEGIN
			---
			SET @CONSTRAINT_NAME = 'Check_Regla_De_La_Hora_Corte_Dia_No_Permite_Remesas'
			SET @ERROR_MESSAGE = @MESSAGEDIA + @NOMBRE_DIA + ' la Hora Corte del día debe ser previa a la Hora Desde.'
			---
		END
				ELSE IF ERROR_MESSAGE() LIKE @ERROR_MESSAGE13 
		BEGIN
			---
			SET @CONSTRAINT_NAME = 'Check_Hora_Aprobacion_Mismo_Dia_Valida'
			SET @ERROR_MESSAGE = @MESSAGEDIA + @NOMBRE_DIA + ' la hora limite de aprobación mismo día  debe ser posterior a la hora límite mismo día.'
			---
		END
				ELSE IF ERROR_MESSAGE() LIKE @ERROR_MESSAGE14 
		BEGIN
			---
			SET @CONSTRAINT_NAME = 'Check_CorteDia_PermiteEntregaMismoDia'
			SET @ERROR_MESSAGE = @MESSAGEDIA + @NOMBRE_DIA + ' la hora corte del dia debe der posterior a la hora limite de aprobacion mismo dia y a la hora limite mismo dia.'
			---
		END
		ELSE IF ERROR_MESSAGE() LIKE @ERROR_MESSAGE15 
		BEGIN
			---
			SET @CONSTRAINT_NAME = 'Check_HoraLimiteAprobacionMismoDia_Menor_HoraHasta'
			SET @ERROR_MESSAGE = @MESSAGEDIA + @NOMBRE_DIA + ' la hora limite de aprobacion mismo dia debe ser previo o igual a la hora hasta.'
			---
		END
		ELSE IF ERROR_MESSAGE() LIKE @ERROR_MESSAGE16 
		BEGIN
			---
			SET @CONSTRAINT_NAME = 'Check_Modificacion_Dia_Actual_Diferente_Dia_Desde_Corte'
			SET @ERROR_MESSAGE = 'No puede modificar el rango horario del día en curso durante horario hábil definido para este día, debe esperar a una fecha distinta o en el horario después de la hora de corte del día en curso.'
			---
		END

		--
		SELECT  CAST(0 AS BIT)												AS SUCCESS
				, @ERROR_MESSAGE											AS ERROR_MESSAGE_SP
				, @CONSTRAINT_NAME											AS CONSTRAINT_TRIGGER_NAME
				, ERROR_NUMBER()											AS ERROR_NUMBER_SP
				, 0															AS ROWS_AFFECTED
				, -1														AS ID
				, @ROW														AS ROW
		

		--
	END CATCH
	---
END