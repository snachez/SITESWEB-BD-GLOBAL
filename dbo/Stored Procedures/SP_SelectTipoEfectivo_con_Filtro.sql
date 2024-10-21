
CREATE PROCEDURE [dbo].[usp_SelectTipoEfectivo_con_Filtro](       @ID				NVARCHAR(MAX)  =	NULL 
													, @NOMBRE			NVARCHAR(MAX)  =	NULL											
													, @ACTIVO			NVARCHAR(MAX)  =	NULL 
													, @PAGE				INT			   =	1
													, @SIZE				INT			   =	10
													, @FILTROS_SITES_JSON		NVARCHAR(MAX)  =	NULL
													, @ORDEN            INT   =    NULL)
AS
BEGIN

   ------ VALIDACION DE DATA
	SET @PAGE = ISNULL(@PAGE, 1)
	SET @SIZE = ISNULL(@SIZE, 10)

	DECLARE @TOTAL_RECORDS INT = 0;

	DECLARE @JSON_RESULT_2 NVARCHAR(MAX)
	DECLARE @resp_JSON_Consolidada NVARCHAR(MAX)

	------------------------------------------
				--FULL DATA--
	------------------------------------------
	SELECT
             [Id]
			,[Nombre]
			,[Activo]
	INTO #tblFullData
	FROM tblTipoEfectivo 

	-------------------------------------------------------------------------------------
	--- S E		C R E A		U N A		C O P I A		D E		L A		T A B L A...
	-------------------------------------------------------------------------------------
	CREATE TABLE #tblDataFiltrada (
		Id INT,  -- Ajusta los tipos de datos según la estructura real de tu tabla
		Nombre NVARCHAR(MAX),
		Activo NVARCHAR(MAX),  -- Ajusta los tipos de datos según la estructura real de tu tabla
	);

	-- Limpiar la tabla
	DELETE FROM #tblDataFiltrada;

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
		INSERT INTO #tblDataFiltrada (Id, Nombre, Activo)
		SELECT D.Id, D.Nombre, D.Activo
		FROM #tblFullData D

		LEFT JOIN #tblFiltrosSites F0
		ON D.[Activo] = F0.Valor
		AND F0.columnana = 0

		LEFT JOIN #tblFiltrosSites F1
		ON D.[Id] = F1.Valor
		AND F1.columnana = 1

		LEFT JOIN #tblFiltrosSites F2
		ON D.Nombre = F2.Valor
		AND F2.columnana = 2

		WHERE F0.columnana IS NOT NULL
		OR F1.columnana IS NOT NULL
		OR F2.columnana IS NOT NULL

		OR (	(@NOMBRE IS NOT NULL AND @NOMBRE <> '') -- Verifica si @SEARCHING no está vacía
				AND (
						   D.Activo = (CASE WHEN @NOMBRE = 'Activo' THEN 1 WHEN @NOMBRE = 'Inactivo' THEN 0 END)
						OR D.Id LIKE CONCAT('%', ISNULL(@NOMBRE, D.Id), '%')
						OR D.Nombre LIKE CONCAT('%', ISNULL(@NOMBRE, D.Nombre), '%')
					)
			)
		
		---
		DROP TABLE #tblFiltrosSites
		---
	END ELSE BEGIN
		---
		DROP TABLE #tblFiltrosSites
		---
		INSERT INTO #tblDataFiltrada (Id, Nombre, Activo)
		SELECT D.Id, D.Nombre, D.Activo
		FROM #tblFullData D
		WHERE
		D.Activo = (CASE WHEN @NOMBRE = 'Activo' THEN 1 WHEN @NOMBRE = 'Inactivo' THEN 0 END)
		OR D.Id LIKE CONCAT('%', ISNULL(@NOMBRE, D.Id), '%')
		OR D.Nombre LIKE CONCAT('%', ISNULL(@NOMBRE, D.Nombre), '%');
	END

	------------------------------------------
		-- DATA INDEXADA & FILTRADA --
	------------------------------------------
	
	;WITH DATA_INDEXED AS (				
								SELECT	  *
										, CASE 
													WHEN @ORDEN = -1 THEN ROW_NUMBER() OVER(ORDER BY Activo DESC)
													WHEN @ORDEN =  1 THEN ROW_NUMBER() OVER(ORDER BY Activo)

													WHEN @ORDEN = -2 THEN ROW_NUMBER() OVER(ORDER BY Id DESC)
													WHEN @ORDEN =  2 THEN ROW_NUMBER() OVER(ORDER BY Id)

													WHEN @ORDEN = -3 THEN ROW_NUMBER() OVER(ORDER BY Nombre DESC)
													WHEN @ORDEN =  3 THEN ROW_NUMBER() OVER(ORDER BY Nombre)		

													ELSE ROW_NUMBER() OVER(ORDER BY Id ASC)

												END
											AS [INDEX]
										FROM #tblDataFiltrada AS D	
										WHERE 	
										    D.Activo = (
											  CASE 
											  WHEN @NOMBRE  = 'Activo' THEN 1
											  WHEN @NOMBRE = 'Inactivo' THEN 0 END
											  )
										  OR D.Id LIKE CONCAT('%', ISNULL(@NOMBRE, Id), '%') 
										  OR D.Nombre LIKE CONCAT('%', ISNULL(@NOMBRE, Nombre), '%') 
						)

	SELECT * INTO #tmpTblDataIndexed FROM DATA_INDEXED ORDER BY [INDEX]
	--
	--SELECT * FROM #tmpTblDataIndexed ORDER BY [INDEX]
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
	SET @JSON_RESULT = (SELECT Id, Nombre, Convert(Bit,Activo) AS Activo  FROM #tmpTblDataIndexed WHERE [INDEX] BETWEEN ((@PAGE * @SIZE)-(@SIZE-1)) AND (@PAGE * @SIZE) ORDER BY [INDEX] FOR JSON PATH) -- PAGINAR... ORDER BY [INDEX] FOR JSON PATH)
	SELECT @JSON_RESULT AS JSON_RESULT_SELECT
	--


	--SELECT * FROM #tmpTblDataIndexed WHERE [INDEX] BETWEEN ((@PAGE * @SIZE)-(@SIZE-1)) AND (@PAGE * @SIZE)
	DROP TABLE #tmpTblDataIndexed
	

	---	 LIMPIAR SEARCHING ...
	SET @NOMBRE = IIF(@NOMBRE IS NOT NULL, REPLACE(REPLACE(REPLACE(REPLACE(LTRIM(@NOMBRE), CHAR(13), ''), CHAR(10), ''), CHAR(9), ''), CHAR(11), ''), NULL)
	SET @NOMBRE = IIF(@NOMBRE IS NOT NULL AND @NOMBRE <> '', CONCAT('%', @NOMBRE, '%'), NULL)
	---
	--- SELECT #1
	---
	SELECT DISTINCT
			CASE 
				WHEN T.Activo IS NULL THEN  0
				WHEN T.Activo IS NOT NULL THEN 1
				ELSE -1 END AS Matching
			,	D.Activo AS Valor
	FROM #tblFullData	D
	LEFT JOIN (
					SELECT DISTINCT Activo 
					FROM #tblFullData
					WHERE Activo  = (
											  CASE 
											  WHEN @NOMBRE  = 'Activo' THEN 1
											  WHEN @NOMBRE = 'Inactivo' THEN 0 END
											  )
					OR [Id] LIKE @NOMBRE
					OR Nombre LIKE @NOMBRE
			  ) T
	ON D.Activo = T.Activo
	ORDER BY Valor

    ---
	--- SELECT #2
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
					WHERE Activo  = (
											  CASE 
											  WHEN @NOMBRE  = 'Activo' THEN 1
											  WHEN @NOMBRE = 'Inactivo' THEN 0 END
											  )
					OR [Id] LIKE @NOMBRE
					OR Nombre LIKE @NOMBRE
			  ) T
	ON D.Id = T.Id
	ORDER BY Valor

	---
	--- SELECT #3
	---
	SELECT DISTINCT
			CASE 
				WHEN T.Nombre IS NULL THEN  0
				WHEN T.Nombre IS NOT NULL THEN 1
				ELSE -1 END AS Matching
			,	D.[Nombre] AS Valor
	FROM #tblFullData	D
	LEFT JOIN (
					SELECT DISTINCT [Nombre] AS Nombre FROM #tblFullData 
					WHERE Activo  = (
											  CASE 
											  WHEN @NOMBRE  = 'Activo' THEN 1
											  WHEN @NOMBRE = 'Inactivo' THEN 0 END
											  )
					OR [Id] LIKE @NOMBRE
					OR Nombre LIKE @NOMBRE
			  ) T
	ON D.[Nombre] = T.Nombre
	ORDER BY Valor

	DROP TABLE #tblFullData
	---


END