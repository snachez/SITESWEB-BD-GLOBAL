CREATE   FUNCTION [dbo].[FN_VALIDACION_CONTRAINT_tbl001_C7](  @DIA											INT
															, @FK_ID_CEDIS									INT
															, @HORA_LIMITE_APROBACION						TIME
															
															)
RETURNS INT
--WITH EXECUTE AS CALLER
AS

BEGIN
	--
    DECLARE @RESULT BIT = 0;
	DECLARE @COUNT_DIA_ENTREGA INT = 0;
	--
			---
			IF @DIA = 1 
				BEGIN
					SET @COUNT_DIA_ENTREGA = (SELECT COUNT(*) from tblDiasHabilesEntregaPedidosInternos where EntregarMartes = 1 AND FkIdCedis = @FK_ID_CEDIS)
				END
			IF @DIA = 2
				BEGIN
					SET @COUNT_DIA_ENTREGA = (SELECT COUNT(*) from tblDiasHabilesEntregaPedidosInternos where EntregarMiercoles = 1 AND FkIdCedis = @FK_ID_CEDIS)
				END
			IF @DIA = 3
				BEGIN
					SET @COUNT_DIA_ENTREGA = (SELECT COUNT(*) from tblDiasHabilesEntregaPedidosInternos where EntregarJueves = 1 AND FkIdCedis = @FK_ID_CEDIS)
				END
			IF @DIA = 4
				BEGIN
					SET @COUNT_DIA_ENTREGA = (SELECT COUNT(*) from tblDiasHabilesEntregaPedidosInternos where EntregarViernes = 1 AND FkIdCedis = @FK_ID_CEDIS)
				END
			IF @DIA = 5
				BEGIN
					SET @COUNT_DIA_ENTREGA = (SELECT COUNT(*) from tblDiasHabilesEntregaPedidosInternos where EntregarSabado = 1 AND FkIdCedis = @FK_ID_CEDIS)
				END
			IF @DIA = 6
				BEGIN
					SET @COUNT_DIA_ENTREGA = (SELECT COUNT(*) from tblDiasHabilesEntregaPedidosInternos where EntregarDomingo = 1 AND FkIdCedis = @FK_ID_CEDIS)
				END
			IF @DIA = 7
				BEGIN
					SET @COUNT_DIA_ENTREGA = (SELECT COUNT(*) from tblDiasHabilesEntregaPedidosInternos where EntregarLunes = 1 AND FkIdCedis = @FK_ID_CEDIS)
				END

			IF(@COUNT_DIA_ENTREGA > 0 AND (SELECT @HORA_LIMITE_APROBACION) IS NULL)
			BEGIN
				SET @RESULT = 1;
			END

	--
    RETURN(@RESULT)
	--
END