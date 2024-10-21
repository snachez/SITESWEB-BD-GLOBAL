CREATE PROCEDURE [dbo].[SP_ValidateGrupoAgencias_x_AgenciasBancarias](    
                                                                          @FK_ID_GRUPO			VARCHAR(MAX)  =	NULL
																		, @ACTIVO				VARCHAR(MAX)  =	NULL
																	)
AS
BEGIN
	---
										
	---

	DECLARE @NEW_ROW VARCHAR(MAX) = ( SELECT      GA.Id						 AS [Id]
												, GA.Activo					 AS [Activo]
												, AB.Id					     AS [IDAgenciaBancaria]

										FROM tblGrupoAgencia GA
										INNER JOIN tblAgenciaBancaria AB
										ON AB.FkIdGrupoAgencia = GA.Id									
										WHERE AB.FkIdGrupoAgencia = ISNULL(@FK_ID_GRUPO, AB.FkIdGrupoAgencia)
										AND AB.Activo = ISNULL(@ACTIVO, AB.Activo)									
										FOR JSON PATH)
	---
	if(ISNULL(@NEW_ROW, 'NULL') != 'NULL')
	BEGIN
		SELECT	  @@ROWCOUNT												AS ROWS_AFFECTED
				, CAST(1 AS BIT)											AS SUCCESS
				, 'El Grupo de Agencia esta asociado con Agencias Bancarias Activas'	AS ERROR_MESSAGE_SP
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