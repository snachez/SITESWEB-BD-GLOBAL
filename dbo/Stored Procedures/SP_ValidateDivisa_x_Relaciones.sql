CREATE PROCEDURE [dbo].[SP_ValidateDivisa_x_Relaciones](    
                                                                          @FK_ID_DIVISA			VARCHAR(MAX)  =	NULL
																		, @ACTIVO          VARCHAR(MAX)  =	NULL
																	)
AS
BEGIN
	---
										
	---

	DECLARE @NEW_ROW VARCHAR(MAX) = ( SELECT      TE.Id						 AS [Id]
												, TE.Activo					 AS [Activo]
										FROM tblDivisa TE
										LEFT JOIN tblUnidadMedida_x_Divisa UM
										ON UM.Fk_Id_Divisa = TE.Id	
										LEFT JOIN tblDenominaciones D
										ON D.IdDivisa = TE.Id
										WHERE UM.Fk_Id_Divisa = ISNULL(@FK_ID_DIVISA, UM.Fk_Id_Divisa)
										AND UM.Activo = ISNULL(@ACTIVO, UM.Activo)
										OR D.IdDivisa = ISNULL(@FK_ID_DIVISA, D.IdDivisa)
										AND D.Activo = ISNULL(@ACTIVO,D.Activo)
										FOR JSON PATH)
	---
	if(ISNULL(@NEW_ROW, 'NULL') != 'NULL')
	BEGIN
		SELECT	  @@ROWCOUNT												AS ROWS_AFFECTED
				, CAST(0 AS BIT)											AS SUCCESS
				, 'Esta divisa tiene denominaciones y unidades de medida activas relacionadas, debe desactivar  todos los valores relacionados antes de  desactivar esta divisa'	AS ERROR_MESSAGE_SP
				, NULL														AS ERROR_NUMBER_SP
				, CONVERT(INT, ISNULL(SCOPE_IDENTITY(), -1))				AS ID
				, @NEW_ROW													AS ROW
		---
		END
	else
	BEGIN
	     SELECT	  @@ROWCOUNT												AS ROWS_AFFECTED
				, CAST(1 AS BIT)											AS SUCCESS
				, ''										                AS ERROR_MESSAGE_SP
				, NULL														AS ERROR_NUMBER_SP
				, CONVERT(INT, ISNULL(SCOPE_IDENTITY(), -1))				AS ID
				, @NEW_ROW													AS ROW
				END
	---
END