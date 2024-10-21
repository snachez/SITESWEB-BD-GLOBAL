
CREATE   FUNCTION [dbo].[FN_ParseJsonTableParametrosSites]
(
    @PARAMETROS_SITES NVARCHAR(MAX) = NULL
)
RETURNS TABLE
AS
RETURN
(
    SELECT columna AS Columna, value AS Valor
    FROM OPENJSON(ISNULL(@PARAMETROS_SITES, '[]'))
    WITH (
        columna INT,
        values_ NVARCHAR(MAX) AS JSON
    ) AS Resultado
    CROSS APPLY OPENJSON(Resultado.values_) WITH (value NVARCHAR(MAX) '$') AS Valores
)