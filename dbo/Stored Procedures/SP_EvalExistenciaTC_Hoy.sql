
---
CREATE   PROCEDURE [usp_EvalExistenciaTC_Hoy](@USUARIO_ID INT = -1)
AS
BEGIN
	---
	DECLARE @USD_ID INT = (SELECT Id FROM tblDivisa WHERE Nomenclatura = 'USD')
	DECLARE @EUR_ID INT = (SELECT Id FROM tblDivisa WHERE Nomenclatura = 'EUR')
	---
	DECLARE @EXISTE_TC_USD BIT = IIF((SELECT COUNT(*) FROM tblTipoCambio WHERE CAST(FechaCreacion AS DATE) = CAST(CURRENT_TIMESTAMP AS DATE) AND fk_Id_DivisaCotizada = @USD_ID) >= 1, 1, 0)
	DECLARE @EXISTE_TC_EUR BIT = IIF((SELECT COUNT(*) FROM tblTipoCambio WHERE CAST(FechaCreacion AS DATE) = CAST(CURRENT_TIMESTAMP AS DATE) AND fk_Id_DivisaCotizada = @EUR_ID) >= 1, 1, 0)
	---
	SELECT	  @USUARIO_ID															AS UsuarioID
			, CURRENT_TIMESTAMP														AS FechaEjecucionEval 
			, CAST(IIF(@EXISTE_TC_EUR = 1 AND @EXISTE_TC_USD = 1, 1, 0) AS BIT)		AS ExisteTC_Hoy
	---
END