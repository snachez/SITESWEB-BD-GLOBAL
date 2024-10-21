--
CREATE   PROCEDURE SP_SelectModulo (		  @ID						NVARCHAR(MAX)  =	NULL
												, @NOMBRE					NVARCHAR(MAX)  =	NULL
												, @ACTIVO					NVARCHAR(MAX)  =	NULL
												, @USUARIO_ID INT = NULL
										  )
AS
BEGIN
	----------------------------------------------------------------------------------------
	--- V A R I A B L E S		F O R M A T E O		F E C H A . . .
	----------------------------------------------------------------------------------------
	DECLARE @TIME_ZONE_FORMAT VARCHAR(90) = dbo.FN_GET_USER_ZONE_REGION_FORMAT(@USUARIO_ID)
	DECLARE @IS_UTC BIT = dbo.FN_IS_DB_UTC_ZONE_FORMAT()
	DECLARE @CURRENT_TIME_ZONE VARCHAR(100) = dbo.FN_DB_UTC_ZONE_FORMAT_NAME()
	----------------------------------------------------------------------------------------
	DECLARE @JSONRESULT NVARCHAR(MAX) = (SELECT    A.Id		     				 AS [Id]
												 , A.Nombre					     AS [Nombre]
												 , A.Activo				    	 AS [Activo]
												 , dbo.FN_CastTimeZoneFormat(@IS_UTC, @CURRENT_TIME_ZONE, @TIME_ZONE_FORMAT, A.FechaCreacion)			AS [FechaCreacion]
												 , dbo.FN_CastTimeZoneFormat(@IS_UTC, @CURRENT_TIME_ZONE, @TIME_ZONE_FORMAT, A.FechaModificacion)		AS [FechaModificacion]
										FROM tblModulo A
										WHERE A.Id = ISNULL(@ID, A.Id)
										AND A.Nombre = ISNULL(@NOMBRE, A.Nombre)
										AND A.Activo = ISNULL(@ACTIVO, A.Activo)
										FOR JSON PATH)
	---
	SELECT @JSONRESULT AS Modulo_JSONRESULT
	---
END