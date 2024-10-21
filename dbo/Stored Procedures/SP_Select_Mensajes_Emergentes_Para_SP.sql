CREATE PROCEDURE [dbo].[SP_Select_Mensajes_Emergentes_Para_SP]
(
    @ROWS_AFFECTED INT = 0,
	@SUCCESS BIT = 0,
	@ERROR_NUMBER_SP INT = 0,
	@CONSTRAINT_TRIGGER_NAME VARCHAR(MAX) = NULL, 
	@ID INT = 0,
	@ROW VARCHAR(MAX) = NULL,
    @Modulo VARCHAR(MAX) = NULL,
    @Metodo VARCHAR(MAX) = NULL,
	@TipoMensaje VARCHAR(MAX) = NULL,
	@ErrorMensaje VARCHAR(MAX) = NULL,
	@ModeJson BIT = 0
)
AS
BEGIN

--------------------------------@CONSTRAINT_TRIGGER_NAME------------------------------------------------------------------------------
	-- Extraer el primer texto entre comillas simples o dobles
	DECLARE @SingleQuoteIndex INT = CHARINDEX('''', @CONSTRAINT_TRIGGER_NAME);
	DECLARE @DoubleQuoteIndex INT = CHARINDEX('"', @CONSTRAINT_TRIGGER_NAME);

	-- Utilizar IIF para verificar si se encontraron comillas simples o dobles
	DECLARE @StartIndex INT;
	DECLARE @MinIndex INT;

	-- Step 1: Determine the smaller index if both are positive
	IF @SingleQuoteIndex > 0 AND @DoubleQuoteIndex > 0
	BEGIN
		SET @MinIndex = CASE 
			WHEN @SingleQuoteIndex < @DoubleQuoteIndex THEN @SingleQuoteIndex 
			ELSE @DoubleQuoteIndex 
		END;
	END

	-- Step 2: If only one is positive, use that one, otherwise use the other
	ELSE
	BEGIN
		SET @MinIndex = IIF(@SingleQuoteIndex > 0, @SingleQuoteIndex, @DoubleQuoteIndex);
	END

	-- Step 3: Assign the final result to @StartIndex
	SET @StartIndex = @MinIndex;


	DECLARE @EndIndex INT = CHARINDEX(IIF(@StartIndex = @SingleQuoteIndex, '''', '"'), @CONSTRAINT_TRIGGER_NAME, @StartIndex + 1);

	DECLARE @CONSTRAINT VARCHAR(MAX) = IIF(@StartIndex > 0 AND @EndIndex > 0, 
		SUBSTRING(@CONSTRAINT_TRIGGER_NAME, @StartIndex + 1, @EndIndex - @StartIndex - 1),
		@CONSTRAINT_TRIGGER_NAME);

--------------------------------FIN @CONSTRAINT_TRIGGER_NAME------------------------------------------------------------------------------

-----------------------------------------------@ErrorMensaje------------------------------------------------------------------------------
	--  Extrae el primer texto entre las comillas
	DECLARE @SoloQuoteIndex INT = CHARINDEX('''', @ErrorMensaje);
	DECLARE @DobleQuoteIndex INT = CHARINDEX('"', @ErrorMensaje);

	-- Utilizar IIF para verificar si se encontraron comillas simples o dobles
	DECLARE @InicioIndex INT;
	DECLARE @MinIndex2 INT;

	-- Step 1: Check if both indices are greater than zero and find the smaller one
	IF @SoloQuoteIndex > 0 AND @DobleQuoteIndex > 0
	BEGIN
		SET @MinIndex2 = CASE 
			WHEN @SoloQuoteIndex < @DobleQuoteIndex THEN @SoloQuoteIndex 
			ELSE @DobleQuoteIndex 
		END;
	END
	-- Step 2: If only one index is greater than zero, use that one
	ELSE
	BEGIN
		SET @MinIndex2 = IIF(@SoloQuoteIndex > 0, @SoloQuoteIndex, @DobleQuoteIndex);
	END

	-- Step 3: Assign the final result to @InicioIndex
	SET @InicioIndex = @MinIndex2;


	DECLARE @FinalIndex INT = CHARINDEX(IIF(@InicioIndex = @SoloQuoteIndex, '''', '"'), @ErrorMensaje, @InicioIndex + 1);

	DECLARE @ErrorSinClave VARCHAR(MAX) = IIF(@InicioIndex > 0 AND @FinalIndex > 0, 
		SUBSTRING(@ErrorMensaje, @InicioIndex + 1, @FinalIndex - @InicioIndex - 1),
		@ErrorMensaje);
-----------------------------------------------FIN @ErrorMensaje--------------------------------------------------------------------------

	IF @ModeJson = 1
	BEGIN
	    
			SELECT TOP 1 @ROWS_AFFECTED AS ROWS_AFFECTED, @SUCCESS AS SUCCESS, T.Titulo AS ERROR_TITLE_SP, ME.Mensaje AS ERROR_MESSAGE_SP, @ERROR_NUMBER_SP AS ERROR_NUMBER_SP,
			@CONSTRAINT AS CONSTRAINT_TRIGGER_NAME, @ID AS ID, @ROW AS ROW
			FROM tblMensajes_Emergentes ME
			INNER JOIN tblMensajes_Emergentes_Metodo MET
				ON ME.Fk_Metodo = MET.Id
			INNER JOIN tblMensajes_Emergentes_Modulo MO
				ON ME.Fk_Modulo = MO.Id
			INNER JOIN tblMensajes_Emergentes_Tipo_Mensaje TM
				ON ME.Fk_TipoMensaje = TM.Id
			INNER JOIN tblMensajes_Emergentes_Titulo T
				ON ME.Fk_Titulo = T.Id
			WHERE 
			(
				MET.Metodo = ISNULL(@Metodo, MET.Metodo)
				AND TM.TipoMensaje = ISNULL(@TipoMensaje, TM.TipoMensaje)
				AND MO.Modulo = ISNULL(@Modulo, MO.Modulo)
			)
			AND 
			(
				ME.ErrorMensaje = ISNULL(@ErrorSinClave, ME.ErrorMensaje)
				OR ME.ErrorMensaje IS NULL
			)
			FOR JSON PATH, INCLUDE_NULL_VALUES -- Esta línea genera la salida en formato JSON
	END
	ELSE
	BEGIN
		SELECT TOP 1 @ROWS_AFFECTED AS ROWS_AFFECTED, @SUCCESS AS SUCCESS, T.Titulo AS ERROR_TITLE_SP, ME.Mensaje AS ERROR_MESSAGE_SP, @ERROR_NUMBER_SP AS ERROR_NUMBER_SP,
		@CONSTRAINT AS CONSTRAINT_TRIGGER_NAME, @ID AS ID, @ROW AS ROW
		FROM tblMensajes_Emergentes ME
		INNER JOIN tblMensajes_Emergentes_Metodo MET
			ON ME.Fk_Metodo = MET.Id
		INNER JOIN tblMensajes_Emergentes_Modulo MO
			ON ME.Fk_Modulo = MO.Id
		INNER JOIN tblMensajes_Emergentes_Tipo_Mensaje TM
			ON ME.Fk_TipoMensaje = TM.Id
		INNER JOIN tblMensajes_Emergentes_Titulo T
			ON ME.Fk_Titulo = T.Id
		WHERE 
		(
			MET.Metodo = ISNULL(@Metodo, MET.Metodo)
			AND TM.TipoMensaje = ISNULL(@TipoMensaje, TM.TipoMensaje)
			AND MO.Modulo = ISNULL(@Modulo, MO.Modulo)
		)
		AND 
		(
			ME.ErrorMensaje = ISNULL(@ErrorSinClave, ME.ErrorMensaje)
			OR ME.ErrorMensaje IS NULL
		);
	END

END;