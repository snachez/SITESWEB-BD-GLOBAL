CREATE PROCEDURE [dbo].[SP_ValidateDenominaciones_x_TipoPresentacion_x_Divisas](   
                                                                          @ID_DENOMINACION			VARCHAR(MAX)  =	NULL,
																		  @ACTIVO					VARCHAR(MAX)  =	NULL
																	)
AS
BEGIN
	---
										
	---

	DECLARE @NEW_ROW VARCHAR(MAX) = ( SELECT      D.Id						 AS [Id]
												, Dv.Id		                 AS [FkIdDivisa]
												, TE.Id			             AS [FkIdTipoEfectivo]
												, D.Activo					 AS [Activo]



										FROM tblDenominaciones D
										INNER JOIN tblDivisa Dv
										ON D.IdDivisa = Dv.Id 
										INNER JOIN tblTipoEfectivo TE
										ON TE.Id = D.BMO				
										WHERE D.Id = ISNULL(@ID_DENOMINACION, D.Id)	and
										Dv.Activo = @ACTIVO or TE.Activo = @ACTIVO
										FOR JSON PATH)
	---
	if(ISNULL(@NEW_ROW, 'NULL') != 'NULL')
	BEGIN
		SELECT	  @@ROWCOUNT												AS ROWS_AFFECTED
				, CAST(1 AS BIT)											AS SUCCESS
				, 'La denominacion esta asociada a Divisas o Tipo de Efcetivos desactivados'			AS ERROR_MESSAGE_SP
				, NULL														AS ERROR_NUMBER_SP
				, CONVERT(INT, ISNULL(SCOPE_IDENTITY(), -1))				AS ID
				, @NEW_ROW													AS ROW
		---
		END
	else
	BEGIN
	     SELECT	  @@ROWCOUNT												AS ROWS_AFFECTED
				, CAST(0 AS BIT)											AS SUCCESS
				, ''										                AS ERROR_MESSAGE_SP
				, NULL														AS ERROR_NUMBER_SP
				, CONVERT(INT, ISNULL(SCOPE_IDENTITY(), -1))				AS ID
				, @NEW_ROW													AS ROW
				END
	---
END