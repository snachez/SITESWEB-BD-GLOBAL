--
CREATE   PROCEDURE SP_SelectArea  (	  @ID						INT				=	NULL
											, @NOMBRE					VARCHAR(MAX)	=	NULL
                                            , @Fk_Id_Departamento       INT				=	NULL
											, @SEARCHING				VARCHAR(MAX)	=	NULL
											, @CODIGO					VARCHAR(MAX)	=	NULL
											, @ACTIVO					BIT				=	NULL
											, @PAGE						INT				=	1
											, @SIZE						INT				=	10
											, @FILTROS_SITES_JSON		VARCHAR(MAX)	=	NULL
											, @ORDER_BY					INT				=	1
											, @USUARIO_ID				INT				=	NULL
										)
AS
BEGIN
	---
	SET @PAGE = ISNULL(@PAGE, 1)
	SET @SIZE = ISNULL(@SIZE, 10)
	SET @NOMBRE = ISNULL(@NOMBRE, '')
	----------------------------------------------------------------------------------------
	--- V A R I A B L E S		F O R M A T E O		F E C H A . . .
	----------------------------------------------------------------------------------------
	DECLARE @TIME_ZONE_FORMAT VARCHAR(90) = dbo.FN_GET_USER_ZONE_REGION_FORMAT(@USUARIO_ID)
	DECLARE @IS_UTC BIT = dbo.FN_IS_DB_UTC_ZONE_FORMAT()
	DECLARE @CURRENT_TIME_ZONE VARCHAR(100) = dbo.FN_DB_UTC_ZONE_FORMAT_NAME()
	----------------------------------------------------------------------------------------
	DECLARE @TOTAL_RECORDS INT = 0


	---	FULL DATA ...
	SELECT     A.Id							AS [Id]
			, A.Nombre						AS [Nombre]
			, CONVERT(VARCHAR(36),NEWID())	AS [Codigo]
			, A.Activo						AS [Activo]
			, A.FechaCreacion				AS [FechaCreacion]
			, A.FechaModificacion			AS [FechaModificacion]

			, D.Id							AS [Departamento.Id]
			, D.Nombre						AS [Departamento.Nombre]
			, D.Activo						AS [Departamento.Activo]
			, dbo.FN_CastTimeZoneFormat(@IS_UTC, @CURRENT_TIME_ZONE, @TIME_ZONE_FORMAT, D.FechaCreacion)			AS [Departamento.FechaCreacion]
			, dbo.FN_CastTimeZoneFormat(@IS_UTC, @CURRENT_TIME_ZONE, @TIME_ZONE_FORMAT, D.FechaModificacion)		AS [Departamento.FechaModificacion]
		INTO #tblFullData
		FROM tblArea A
		INNER JOIN tblDepartamento D
		ON A.Fk_Id_Departamento = D.Id

	---
	SELECT * INTO #tblDataFiltrada FROM #tblFullData
	DELETE FROM #tblDataFiltrada
	---


	-------------------------------------------------------
	--- F I L T R O S		S I T E S	. . . 
	-------------------------------------------------------
	CREATE TABLE #tblFiltrosSites(columnana INT, Valor NVARCHAR(MAX))
	BEGIN TRY
		---
		INSERT INTO #tblFiltrosSites SELECT * FROM dbo.FN_ParseJsonTableParametrosSites(@FILTROS_SITES_JSON)
		---
	END TRY BEGIN CATCH END CATCH
	---
	DECLARE @JSON_RESULT NVARCHAR(MAX)
	---


	--------------------------------------------------------------
	--- A P L I C A R		F I L T R O S		S I T E S	. . . 
	--------------------------------------------------------------
	DECLARE @APLICAR_FILTRADO_SITES_ BIT = (SELECT CASE WHEN COUNT(*) > 0 THEN CAST(1 AS BIT) ELSE CAST(0 AS BIT) END FROM #tblFiltrosSites)
	---
	IF @APLICAR_FILTRADO_SITES_ = 1 BEGIN
		--
		INSERT INTO #tblDataFiltrada 
		SELECT D.* 
		FROM #tblFullData D

		LEFT JOIN #tblFiltrosSites F4
		ON D.[Departamento.Id] = F4.Valor
		AND F4.columnana = 4

		LEFT JOIN #tblFiltrosSites F3
		ON D.[Departamento.Nombre] = F3.Valor
		AND F3.columnana = 3

		LEFT JOIN #tblFiltrosSites F2
		ON D.Nombre = F2.Valor
		AND F2.columnana = 2

		LEFT JOIN #tblFiltrosSites F0
		ON D.Id = F0.Valor
		AND F0.columnana = 0


		WHERE F0.columnana IS NOT NULL
		OR F2.columnana IS NOT NULL
		OR F3.columnana IS NOT NULL
		OR F4.columnana IS NOT NULL

		OR (	(@SEARCHING IS NOT NULL AND @SEARCHING <> '') -- Verifica si @SEARCHING no está vacía
				AND (
						Nombre LIKE CONCAT('%', ISNULL(@SEARCHING, Nombre), '%')
						OR [Departamento.Nombre] LIKE CONCAT('%', ISNULL(@SEARCHING, [Departamento.Nombre]), '%')
						OR Id LIKE CONCAT('%', ISNULL(@SEARCHING, Id), '%')
					)
			)
		
		---
		DROP TABLE #tblFiltrosSites
		---
	END ELSE BEGIN
		---
		DROP TABLE #tblFiltrosSites
		---
		INSERT INTO #tblDataFiltrada 
		SELECT * FROM #tblFullData D WHERE
		Nombre LIKE CONCAT('%', ISNULL(@SEARCHING, Nombre), '%')
		OR [Departamento.Nombre] LIKE CONCAT('%', ISNULL(@SEARCHING, [Departamento.Nombre]), '%')
		OR Id LIKE CONCAT('%', ISNULL(@SEARCHING, Id), '%')
	END



	------------------------------------------
	--		DATA INDEXADA & FILTRADA . . .
	------------------------------------------
	;WITH DATA_INDEXED AS (				SELECT	  *
												, CASE 
														WHEN @ORDER_BY = -1 THEN ROW_NUMBER() OVER(ORDER BY Id DESC)
														WHEN @ORDER_BY =  1 THEN ROW_NUMBER() OVER(ORDER BY Id)

														WHEN @ORDER_BY = -2 THEN ROW_NUMBER() OVER(ORDER BY Activo DESC)
														WHEN @ORDER_BY =  2 THEN ROW_NUMBER() OVER(ORDER BY Activo)

														WHEN @ORDER_BY = -3 THEN ROW_NUMBER() OVER(ORDER BY Nombre DESC)
														WHEN @ORDER_BY =  3 THEN ROW_NUMBER() OVER(ORDER BY Nombre)														

														WHEN @ORDER_BY = -4 THEN ROW_NUMBER() OVER(ORDER BY [Departamento.Nombre] DESC)
														WHEN @ORDER_BY =  4 THEN ROW_NUMBER() OVER(ORDER BY [Departamento.Nombre])

														ELSE ROW_NUMBER() OVER(ORDER BY Id)
														END
												AS [INDEX]
										FROM #tblDataFiltrada
										WHERE Id = ISNULL(@ID, Id)
										AND [Departamento.Id] = ISNULL(@Fk_Id_Departamento, [Departamento.Id])
										AND Codigo = ISNULL(@CODIGO, Codigo)
										AND Activo = ISNULL(@ACTIVO, Activo)
									)
	SELECT * INTO #tmpTblDataIndexed FROM DATA_INDEXED ORDER BY [INDEX]
	--

	--- TOTAL DE FILAS SIN PAGINAR
	SET @TOTAL_RECORDS = (SELECT COUNT(*) FROM #tmpTblDataIndexed)


	---
	--- SELECT #1
	---
	SELECT @TOTAL_RECORDS AS TotalRecords, @PAGE AS Page, @SIZE AS SizePage, @APLICAR_FILTRADO_SITES_ AS FiltradoSites --FROM tblArea WHERE Activo = ISNULL(@ACTIVO, Activo)
	---


	---
	--- SELECT #2
	---
	SET @JSON_RESULT = (SELECT * FROM #tmpTblDataIndexed WHERE [INDEX] BETWEEN ((@PAGE * @SIZE)-(@SIZE-1)) AND (@PAGE * @SIZE) ORDER BY [INDEX] FOR JSON PATH) -- PAGINAR... ORDER BY [INDEX] FOR JSON PATH)
	SELECT @JSON_RESULT AS JSON_RESULT_SELECT
	--


	DROP TABLE #tmpTblDataIndexed
	

	---	 LIMPIAR SEARCHING ...
	SET @SEARCHING = IIF(@SEARCHING IS NOT NULL, REPLACE(REPLACE(REPLACE(REPLACE(LTRIM(@SEARCHING), CHAR(13), ''), CHAR(10), ''), CHAR(9), ''), CHAR(11), ''), NULL)
	SET @SEARCHING = IIF(@SEARCHING IS NOT NULL AND @SEARCHING <> '', CONCAT('%', @SEARCHING, '%'), NULL)
	---
	--- SELECT #3
	---
	SELECT DISTINCT
			CASE 
				WHEN T.Nombre IS NULL THEN  0
				WHEN T.Nombre IS NOT NULL THEN 1
				ELSE -1 END AS Matching
			,	D.Nombre AS Valor
	FROM #tblFullData	D
	LEFT JOIN (
					SELECT DISTINCT Nombre 
					FROM #tblFullData
					WHERE Nombre LIKE @SEARCHING
					OR [Departamento.Nombre] LIKE @SEARCHING
					OR Id LIKE @SEARCHING
			  ) T
	ON D.Nombre = T.Nombre
	ORDER BY Valor
	---
	SELECT DISTINCT
			CASE 
				WHEN T.NombreDepartamento IS NULL THEN  0
				WHEN T.NombreDepartamento IS NOT NULL THEN 1
				ELSE -1 END AS Matching
			,	D.[Departamento.Nombre] AS Valor
	FROM #tblFullData	D
	LEFT JOIN (
					SELECT DISTINCT [Departamento.Nombre] AS NombreDepartamento FROM #tblFullData 
					WHERE Nombre LIKE @SEARCHING
					OR [Departamento.Nombre] LIKE @SEARCHING
					OR Id LIKE @SEARCHING
			  ) T
	ON D.[Departamento.Nombre] = T.NombreDepartamento
	ORDER BY Valor
	---
	SELECT DISTINCT
			CASE 
				WHEN T.Id IS NULL THEN  0
				WHEN T.Id IS NOT NULL THEN 1
				ELSE -1 END AS Matching
			,	D.Id AS Valor
	FROM #tblFullData	D
	LEFT JOIN (
					SELECT DISTINCT Id FROM #tblFullData 
					WHERE Nombre LIKE @SEARCHING
					OR [Departamento.Nombre] LIKE @SEARCHING
					OR Id LIKE @SEARCHING
			  ) T
	ON D.Id = T.Id
	ORDER BY Valor
	---
	DROP TABLE #tblFullData
	---
END