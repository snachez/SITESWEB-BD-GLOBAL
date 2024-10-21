CREATE PROCEDURE [dbo].[usp_ValidateCuentaInterna_x_AgenciaBancaria](    
                                                                          @FK_ID_AGENCIA			VARCHAR(MAX)  =	NULL
																		, @NUMERO_CUENTA            VARCHAR(MAX)  =	NULL
																	)
AS
BEGIN
	---
										
	---

	DECLARE @NEW_ROW VARCHAR(MAX) = ( SELECT     CA.Id						 AS [Id]
												, CA.FkIdCuentaInterna		 AS [FkIdCuentaInterna]
												, CA.FkIdAgencia			 AS [FkIdGrupoAgencias]
												, CA.Activo					 AS [Activo]
												, C.NumeroCuenta			 AS [CuentaInterna.NumeroCuenta]


										FROM tblCuentaInterna_x_Agencia CA
										INNER JOIN tblAgenciaBancaria A
										ON CA.FkIdAgencia = A.Id
										INNER JOIN tblCuentaInterna C
										ON CA.FkIdCuentaInterna = C.Id
										INNER JOIN tblDivisa D
										ON C.FkIdDivisa = D.Id
										WHERE CA.FkIdAgencia = ISNULL(@FK_ID_AGENCIA, CA.FkIdAgencia)
										AND C.NumeroCuenta = ISNULL(@NUMERO_CUENTA, C.NumeroCuenta)
										FOR JSON PATH)
	---
	if(ISNULL(@NEW_ROW, 'NULL') != 'NULL')
	BEGIN
		SELECT	  @@ROWCOUNT												AS ROWS_AFFECTED
				, CAST(1 AS BIT)											AS SUCCESS
				, 'Existe la cuenta'										AS ERROR_MESSAGE_SP
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