

CREATE   PROCEDURE [dbo].[SP_SelectDiasHabilesEntregaPedidosInternos](@FKIDCEDIS	INT)
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
	DECLARE @HoraDesde VARCHAR(MAX) = '00:00';
	DECLARE @HoraCorteDia VARCHAR(MAX) = '23:59';
	DECLARE @HoraLimiteAprobacion VARCHAR(MAX) = '23:59';

	INSERT INTO tblDiasHabilesEntregaPedidosInternos(FkIdCedis, Dia, NombreDia, HoraDesde, HoraCorteDia, HoraLimiteAprobacion)
	VALUES(	@FKIDCEDIS, '1', 'Lunes',@HoraDesde, @HoraCorteDia, @HoraLimiteAprobacion),
	(@FKIDCEDIS, '2', 'Martes', @HoraDesde, @HoraCorteDia, @HoraLimiteAprobacion),
	(@FKIDCEDIS, '3', 'Miercoles', @HoraDesde, @HoraCorteDia, @HoraLimiteAprobacion),
	(@FKIDCEDIS, '4', 'Jueves', @HoraDesde, @HoraCorteDia, @HoraLimiteAprobacion),
	(@FKIDCEDIS, '5', 'Viernes', @HoraDesde, @HoraCorteDia, @HoraLimiteAprobacion),
	(@FKIDCEDIS, '6', 'Sábado', @HoraDesde, @HoraCorteDia, @HoraLimiteAprobacion),
	(@FKIDCEDIS, '7', 'Domingo', @HoraDesde, @HoraCorteDia, @HoraLimiteAprobacion)

	SET @JSON_RESULT  = (SELECT * FROM tblDiasHabilesEntregaPedidosInternos WHERE FkIdCedis = @FKIDCEDIS FOR JSON PATH)
	
	END

		SELECT @JSON_RESULT AS JSON_RESULT_SELECT

	---
END