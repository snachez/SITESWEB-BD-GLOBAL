
CREATE   PROCEDURE [dbo].[SP_SelectColaborador] (	  @USER_ACTIVE_DIRECTORY VARCHAR(MAX) = NULL
													, @ACTIVO	BIT = NULL
											   )
AS
BEGIN
	---
	SELECT *
	FROM tblColaborador
	WHERE	ISNULL(@ACTIVO, Activo)		= Activo
	AND		ISNULL(@USER_ACTIVE_DIRECTORY, UserActiveDirectory)	= UserActiveDirectory
	AND     Correo is not null
	---
END