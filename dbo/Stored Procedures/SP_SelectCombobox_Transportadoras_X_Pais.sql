CREATE PROCEDURE [dbo].[SP_SelectCombobox_Transportadoras_X_Pais](@IdPais INT = NULL, @Activo bit = NULL, @IdTransportadora INT = NULL)
AS
BEGIN
	---
	;WITH DATA_INDEXED AS (SELECT T.Id, T.Nombre, T.Codigo
						   FROM [tblTransportadoras] T
						   INNER JOIN tblTransportadoras_x_Pais TxP on TxP.Fk_Id_Transportadora = T.Id
						   WHERE TxP.Fk_Id_Pais = ISNULL(@IdPais, [Fk_Id_Pais]) AND TxP.Activo = 1 AND T.Activo = ISNULL(@Activo, T.Activo) AND T.Id = ISNULL(@IdTransportadora, T.Id)
						   )
	
	SELECT * INTO #tmpTblDataResult FROM DATA_INDEXED
	---
	DECLARE @JSON_RESULT VARCHAR(MAX) = (SELECT * FROM #tmpTblDataResult order by Nombre ASC FOR JSON PATH)
	---
	DROP TABLE #tmpTblDataResult
	---
	SELECT @JSON_RESULT AS JSON_RESULT_SELECT
	---
END