CREATE PROCEDURE [dbo].[SP_Divisa_ValidateRelationTipoEfectivo](    
                                                                          @FK_ID_TIPOEFECTIVO			VARCHAR(MAX)  =	NULL
																		, @FK_ID_DIVISA			VARCHAR(MAX)  =	NULL
																		, @ACTIVO          VARCHAR(MAX)  =	NULL
																	)
AS
BEGIN
	---
										
	---

	DECLARE @NEW_ROW VARCHAR(MAX) = ( SELECT     TE.Id						 AS [Id]
												, TE.Activo					 AS [Activo]


										FROM tblTipoEfectivo TE
										INNER JOIN tblDivisa_x_TipoEfectivo DT
										ON DT.FkIdDivisa = @FK_ID_DIVISA AND
										DT.FkIdTipoEfectivo = TE.Id
										LEFT JOIN tblUnidadMedida_x_Divisa UD
										ON UD.Fk_Id_Divisa = DT.Id
										LEFT JOIN tblUnidadMedida_x_TipoEfectivo UM
										ON UM.Fk_Id_Tipo_Efectivo = TE.Id	
										LEFT JOIN tblDenominaciones D
										ON D.BMO = TE.Id AND
										D.IdDivisa = @FK_ID_DIVISA
										WHERE (UM.Fk_Id_Tipo_Efectivo = ISNULL(@FK_ID_TIPOEFECTIVO, UM.Fk_Id_Tipo_Efectivo)
										AND UM.Activo = ISNULL(@ACTIVO, UM.Activo)
										AND UD.Fk_Id_Divisa = ISNULL(@FK_ID_DIVISA, UD.Fk_Id_Divisa)
										AND UD.Activo = ISNULL(@ACTIVO, UM.Activo))
										OR (D.BMO = ISNULL(@FK_ID_TIPOEFECTIVO, D.BMO)
										AND D.IdDivisa = ISNULL(@FK_ID_DIVISA, D.IdDivisa)
										AND D.Activo = ISNULL(@ACTIVO,D.Activo))
										FOR JSON PATH)
	---
	if(ISNULL(@NEW_ROW, 'NULL') <> 'NULL')
	BEGIN
		SELECT	  @@ROWCOUNT												AS ROWS_AFFECTED
				, CAST(1 AS BIT)											AS SUCCESS
				, 'La presentacion tiene Denominaciones o Unidades Medidas activas, debe desactivar todas las relaciones antes de desactivar esta presentacion'	AS ERROR_MESSAGE_SP
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