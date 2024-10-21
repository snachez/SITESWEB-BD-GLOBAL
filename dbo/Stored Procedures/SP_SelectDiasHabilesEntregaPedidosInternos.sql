

CREATE   PROCEDURE [dbo].[usp_SelectDiasHabilesEntregaPedidosInternos](@FKIDCEDIS	INT)
AS
BEGIN
	---
	DECLARE @CEDIS INT = (SELECT COUNT(*) FROM tblDiasHabilesEntregaPedidosInternos WHERE FkIdCedis = @FKIDCEDIS)
	DECLARE @JSON_RESULT VARCHAR(MAX)
	IF (@CEDIS > 0)
	BEGIN 
		SET @JSON_RESULT  = (SELECT * FROM tblDiasHabilesEntregaPedidosInternos WHERE FkIdCedis = @FKIDCEDIS FOR JSON PATH)
	---

	END
	ELSE
	BEGIN

	INSERT INTO tblDiasHabilesEntregaPedidosInternos(FkIdCedis, Dia, NombreDia, HoraDesde, HoraCorteDia, HoraLimiteAprobacion)
	VALUES(	@FKIDCEDIS, '1', 'Lunes','00:00', '23:59', '23:59'),
	(@FKIDCEDIS, '2', 'Martes', '00:00', '23:59', '23:59'),
	(@FKIDCEDIS, '3', 'Miercoles', '00:00', '23:59', '23:59'),
	(@FKIDCEDIS, '4', 'Jueves', '00:00', '23:59', '23:59'),
	(@FKIDCEDIS, '5', 'Viernes', '00:00', '23:59', '23:59'),
	(@FKIDCEDIS, '6', 'Sábado', '00:00', '23:59', '23:59'),
	(@FKIDCEDIS, '7', 'Domingo', '00:00', '23:59', '23:59')

	SET @JSON_RESULT  = (SELECT * FROM tblDiasHabilesEntregaPedidosInternos WHERE FkIdCedis = @FKIDCEDIS FOR JSON PATH)
	
	END

		SELECT @JSON_RESULT AS JSON_RESULT_SELECT

	---
END