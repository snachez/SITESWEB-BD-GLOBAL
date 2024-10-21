CREATE PROCEDURE [dbo].[SP_SelectDepartamento](	
												  @SEARCH					VARCHAR(MAX)   =	NULL
												, @PAGE						INT			   =	NULL
												, @SIZE						INT			   =	NULL
												, @ORDEN                    INT			   =    1	
											  )
AS
BEGIN
	---
	SET @PAGE = ISNULL(@PAGE, 1)
	SET @SIZE = ISNULL(@SIZE, 10)

	DECLARE @TOTAL_RECORDS INT = 0;

	DECLARE @JSON_RESULT_2 NVARCHAR(MAX)
	DECLARE @resp_JSON_Consolidada NVARCHAR(MAX)

	------------------------------------------
				--FULL DATA--
	------------------------------------------
            SELECT  [Id]
                   ,[Nombre]
                   ,[Activo]
			INTO #tblFullData
			FROM [tblDepartamento]
				
	------------------------------------------
		-- DATA INDEXADA & FILTRADA --
	------------------------------------------
	
	;WITH DATA_INDEXED AS (				
								SELECT	  *
										, CASE 
													WHEN @ORDEN = -1 THEN ROW_NUMBER() OVER(ORDER BY [Id] DESC)
													WHEN @ORDEN =  1 THEN ROW_NUMBER() OVER(ORDER BY [Id] ASC)

													WHEN @ORDEN = -2 THEN ROW_NUMBER() OVER(ORDER BY [Activo] DESC)
													WHEN @ORDEN =  2 THEN ROW_NUMBER() OVER(ORDER BY [Activo] ASC)

													WHEN @ORDEN = -3 THEN ROW_NUMBER() OVER(ORDER BY [Nombre] DESC)
													WHEN @ORDEN =  3 THEN ROW_NUMBER() OVER(ORDER BY [Nombre] ASC)	

													ELSE ROW_NUMBER() OVER(ORDER BY [Id] ASC)

												END
											AS [INDEX]
										FROM #tblFullData AS D	
										WHERE 

										D.Activo = (
													  CASE 
													  WHEN @SEARCH  = 'Activo' THEN 1
													  WHEN @SEARCH = 'Inactivo' THEN 0 END
													  )
												  OR D.Id LIKE CONCAT('%', ISNULL(@SEARCH, Id), '%') 
												  OR D.Nombre LIKE CONCAT('%', ISNULL(@SEARCH, Nombre), '%') 

						)

	--SE PASA LA DATA INDEXADA A UNA TABLA TEMPORAL
	SELECT * INTO #tmpTblData FROM DATA_INDEXED ORDER BY [INDEX];

	--- OBTIENE EL TOTAL DE FILAS PAGINADAS
	SET @TOTAL_RECORDS = (SELECT COUNT(*) FROM #tmpTblData)
										---
	SET @JSON_RESULT_2 = (SELECT * FROM #tmpTblData WHERE [INDEX] BETWEEN  (@PAGE)  AND   ((@PAGE)+(@SIZE-1)) ORDER BY [INDEX] FOR JSON PATH)
	---
	SET @resp_JSON_Consolidada = REPLACE( @JSON_RESULT_2,'\','') --COMO EL JSON SE SERIALIZA EN 3 OCACIONES A CAUSA DE LA CLAUSULA: FOR JSON PATH, HAY QUE ELIMINARLES LOS \\\ A LAS TABLAS HIJOS
	SET @resp_JSON_Consolidada = REPLACE( @resp_JSON_Consolidada,':"[{',':[{') --HAY QUE ELIMINAR LOS CARACTERES  \" CUANDO SE HABRE LAS LLAVES EN EL INICIO DE LAS CADENAS DE ARRAYS DE LAS TABLAS HIJOS
	SET @resp_JSON_Consolidada = REPLACE( @resp_JSON_Consolidada,'}]"','}]') --Y TAMBIEN HAY QUE ELIMINAR LOS CARACTERES  \"  CUANDO SE CIERRA LAS LLAVES EN LAS CADENAS DE ARRAYS DE LAS TABLAS HIJOS

	------------- BORRAR DATA  ---------------

	DROP TABLE #tblFullData;
	DROP TABLE #tmpTblData;

	------------------------------------------
		-- RESPUESTA ENVIADA A LA APP --
	------------------------------------------

	SELECT @TOTAL_RECORDS AS TotalRecords, @PAGE AS Page, @SIZE AS SizePage 

	SELECT @resp_JSON_Consolidada AS JSON_RESULT_2;

END