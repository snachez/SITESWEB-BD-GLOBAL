CREATE PROCEDURE [dbo].[SP_ValidateTipoEfectivo_UnidadMedida](    
                                                                          @FK_ID_TIPOEFECTIVO	VARCHAR(MAX)  =	NULL
																		, @ACTIVO               VARCHAR(MAX)  =	NULL
																	)
AS
BEGIN
	---
	DECLARE @NEW_ROW VARCHAR(MAX) = ( SELECT      TE.Id						 AS [Id]
												, TE.Activo					 AS [Activo]
												, UM.Fk_Id_Unidad_Medida	 AS [FkIdUnidadMedida]
												, D.Id						 AS [Denominacion]


										FROM tblTipoEfectivo TE
										INNER JOIN tblUnidadMedida_x_TipoEfectivo UM
										ON UM.Fk_Id_Tipo_Efectivo = TE.Id	
										LEFT JOIN tblDivisa_x_TipoEfectivo DxT
										ON DxT.FkIdTipoEfectivo = TE.Id	
										LEFT JOIN tblDenominaciones D
										ON D.BMO = TE.Id
										WHERE (UM.Fk_Id_Tipo_Efectivo = ISNULL(@FK_ID_TIPOEFECTIVO, UM.Fk_Id_Tipo_Efectivo)
										AND UM.Activo = ISNULL(@ACTIVO, UM.Activo))
										OR (D.BMO = ISNULL(@FK_ID_TIPOEFECTIVO, D.BMO)
										AND D.Activo = ISNULL(@ACTIVO,D.Activo))
										OR (DxT.FkIdTipoEfectivo = ISNULL(@FK_ID_TIPOEFECTIVO, DxT.FkIdTipoEfectivo)
										AND DxT.Activo = ISNULL(@ACTIVO,DxT.Activo))
										FOR JSON PATH)
	---
	if(ISNULL(@NEW_ROW, 'NULL') != 'NULL')
	BEGIN
		SELECT	  @@ROWCOUNT												AS ROWS_AFFECTED
				, CAST(1 AS BIT)											AS SUCCESS
				, 'El tipo de efectivo tiene asocion activa con Denominaciones o Unidad Medida'	AS ERROR_MESSAGE_SP
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