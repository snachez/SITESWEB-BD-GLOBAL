---
CREATE   PROCEDURE [dbo].[SP_Select_Msj_OnSPSuccess](@SP_NAME VARCHAR(MAX), @ROWS_AFFECTED__ INT = 0, @ID__ INT = -1, @ROW__ VARCHAR(MAX) = NULL, @JSON_MODE BIT = 0 )
AS
BEGIN
	---
	SELECT	  TOP 1
			  @ROWS_AFFECTED__	AS ROWS_AFFECTED
			, 1					AS SUCCESS
			, T.Titulo			AS SUCCESS_TITLE_SP
			, ME.Mensaje		AS SUCCESS_MESSAGE_SP
			, NULL				AS ERROR_TITLE_SP
			, NULL				AS ERROR_MESSAGE_SP
			, NULL				AS ERROR_NUMBER_SP
			, NULL				AS CONSTRAINT_TRIGGER_NAME
			, @ID__				AS ID
			, @ROW__			AS ROW
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
	WHERE MET.Metodo = @SP_NAME
		AND TM.TipoMensaje = 'Exitoso'
	---
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