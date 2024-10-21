
CREATE PROCEDURE [dbo].[usp_SelectCombobox_Cedis_X_Pais](@IdPais INT = NULL, @Nombre varchar(50) = NULL, @Activo BIT = NULL)
AS
BEGIN
	---
	;WITH DATA_INDEXED AS (SELECT [Id_Cedis]
	                             ,[Activo]
								 ,[Nombre]
						   FROM [tblCedis] 
						   WHERE [Fk_Id_Pais] = ISNULL(@IdPais, [Fk_Id_Pais]) AND
						   [Nombre] = ISNULL(@Nombre, [Nombre]) AND
						   [Activo] = ISNULL(@Activo, [Activo]))
	SELECT * INTO #tmpTblDataResult FROM DATA_INDEXED
	---
	DECLARE @JSON_RESULT VARCHAR(MAX) = (SELECT * FROM #tmpTblDataResult FOR JSON PATH)
	---
	DROP TABLE #tmpTblDataResult
	---
	SELECT @JSON_RESULT AS JSON_RESULT_SELECT
	---
END