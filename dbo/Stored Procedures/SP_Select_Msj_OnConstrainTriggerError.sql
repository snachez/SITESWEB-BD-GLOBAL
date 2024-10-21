---
CREATE   PROCEDURE [dbo].[SP_Select_Msj_OnConstrainTriggerError] ( @ERROR_MESSAGE VARCHAR(MAX), @JSON_MODE BIT = 0 )
AS
BEGIN
	---
	DECLARE @CONSTRAINT VARCHAR(MAX) = dbo.FN_GetNameConstraintTriggerOnError(@ERROR_MESSAGE)
	---
	SELECT	  TOP 1
			  0 AS ROWS_AFFECTED
			, 0 AS SUCCESS
			, T.Titulo AS ERROR_TITLE_SP
			, ME.Mensaje AS ERROR_MESSAGE_SP
			, 50001 AS ERROR_NUMBER_SP
			, @CONSTRAINT AS CONSTRAINT_TRIGGER_NAME
			, -1 AS ID
			, NULL AS ROW
	INTO #tmpResult
	FROM tblMensajes_Emergentes ME
	LEFT JOIN tblMensajes_Emergentes_Metodo MET
		ON ME.Fk_Metodo = MET.Id
	LEFT JOIN tblMensajes_Emergentes_Modulo MO
		ON ME.Fk_Modulo = MO.Id
	LEFT JOIN tblMensajes_Emergentes_Tipo_Mensaje TM
		ON ME.Fk_TipoMensaje = TM.Id
	LEFT JOIN tblMensajes_Emergentes_Titulo T
		ON ME.Fk_Titulo = T.Id
	WHERE ME.ErrorMensaje = @CONSTRAINT

	IF @JSON_MODE = 1 BEGIN
		---
		DECLARE @JSON VARCHAR(MAX) = (SELECT * FROM #tmpResult FOR JSON PATH, INCLUDE_NULL_VALUES)
		SELECT @JSON AS RESULT
		---
	END ELSE BEGIN
		---
		SELECT * FROM #tmpResult
		---
	END
	---
END