CREATE PROCEDURE [dbo].[usp_SelectMatricesAtribucion](	  @SEARCH		NVARCHAR(MAX)		=		NULL
														, @PAGE			INT					=		1
														, @SIZE			INT					=		10
														, @ORDEN        INT					=		1
														, @USUARIO_ID INT = NULL
													)
AS
BEGIN
	---
	SET @PAGE = ISNULL(@PAGE, 1)
	SET @SIZE = ISNULL(@SIZE, 10)

	DECLARE @TOTAL_RECORDS INT = 0;

	DECLARE @JSON_RESULT_2 NVARCHAR(MAX)
	DECLARE @resp_JSON_Consolidada NVARCHAR(MAX)
	----------------------------------------------------------------------------------------
	--- V A R I A B L E S		F O R M A T E O		F E C H A . . .
	----------------------------------------------------------------------------------------
	DECLARE @TIME_ZONE_FORMAT VARCHAR(90) = dbo.FN_GET_USER_ZONE_REGION_FORMAT(@USUARIO_ID)
	DECLARE @IS_UTC BIT = dbo.FN_IS_DB_UTC_ZONE_FORMAT()
	DECLARE @CURRENT_TIME_ZONE VARCHAR(100) = dbo.FN_DB_UTC_ZONE_FORMAT_NAME()
	----------------------------------------------------------------------------------------
	------------------------------------------
				--FULL DATA--
	------------------------------------------
				SELECT DISTINCT 
					M.Id AS [Id],
					M.Activo AS [Activo],
					M.Nombre AS [Nombre],
					D.Id AS [Divisa.Id],
					D.Activo AS [Divisa.Activo],
					D.Nombre AS [Divisa.Nombre],
					D.Nomenclatura AS [Divisa.Nomenclatura],
					D.Descripcion AS [Divisa.Descripcion],
					(
						SELECT DISTINCT
							F.[Id],
							F.[Firma],
							F.[MontoDesde],
							F.[MontoHasta],
							F.[Activo],
							dbo.FN_CastTimeZoneFormat(@IS_UTC, @CURRENT_TIME_ZONE, @TIME_ZONE_FORMAT, F.[FechaCreacion]) AS [FechaCreacion],
							dbo.FN_CastTimeZoneFormat(@IS_UTC, @CURRENT_TIME_ZONE, @TIME_ZONE_FORMAT, F.[FechaModificacion]) AS [FechaModificacion]
						FROM tblMatrizAtribucion_Firmas MF
						INNER JOIN tblFirmas F ON F.Id = MF.Fk_Id_Firmas
						WHERE MF.Fk_Id_MatrizAtribucion = M.Id
						AND MF.Activo = 1
						FOR JSON PATH
					) AS Firmas,
					(
						SELECT DISTINCT
							T.[Id],
							T.[Nombre],
							T.[Fk_Id_Modulo],
							T.[Codigo],
							T.[Activo],
							dbo.FN_CastTimeZoneFormat(@IS_UTC, @CURRENT_TIME_ZONE, @TIME_ZONE_FORMAT, T.[FechaCreacion]) AS [FechaCreacion],
							dbo.FN_CastTimeZoneFormat(@IS_UTC, @CURRENT_TIME_ZONE, @TIME_ZONE_FORMAT, T.[FechaModificacion]) AS [FechaModificacion]
						FROM tblMatrizAtribucion_Transaccion MT
						INNER JOIN tblTransacciones T ON T.Id = MT.Fk_Id_Transaccion
						WHERE MT.Fk_Id_MatrizAtribucion = M.Id
						AND MT.Activo = 1
						FOR JSON PATH
					) AS Transacciones
				INTO #tblFullData
				FROM tblMatrizAtribucion M
				INNER JOIN tblDivisa D 
				ON M.Fk_Id_Divisa = D.Id
				
	------------------------------------------
		-- DATA INDEXADA & FILTRADA --
	------------------------------------------
	
	;WITH DATA_INDEXED AS (				
								SELECT	  *
										, CASE 
													WHEN @ORDEN = -1 THEN ROW_NUMBER() OVER(ORDER BY Id DESC)
													WHEN @ORDEN =  1 THEN ROW_NUMBER() OVER(ORDER BY Id ASC)

													WHEN @ORDEN = -2 THEN ROW_NUMBER() OVER(ORDER BY Activo DESC)
													WHEN @ORDEN =  2 THEN ROW_NUMBER() OVER(ORDER BY Activo ASC)

													WHEN @ORDEN = -3 THEN ROW_NUMBER() OVER(ORDER BY Nombre DESC)
													WHEN @ORDEN =  3 THEN ROW_NUMBER() OVER(ORDER BY Nombre ASC)														

													WHEN @ORDEN = -4 THEN ROW_NUMBER() OVER(ORDER BY [Divisa.Nomenclatura] DESC)
													WHEN @ORDEN =  4 THEN ROW_NUMBER() OVER(ORDER BY [Divisa.Nomenclatura] ASC)

													ELSE ROW_NUMBER() OVER(ORDER BY Id ASC)

												END
											AS [INDEX]
										FROM #tblFullData AS D	
										WHERE 	
										    D.Activo = (
											  CASE 
											  WHEN @SEARCH  = 'Activo' THEN 1
											  WHEN @SEARCH = 'Inactivo' THEN 0 END
											  )
										  OR D.Nombre LIKE CONCAT('%', ISNULL(@SEARCH, Nombre), '%') 
										  OR D.Id LIKE CONCAT('%', ISNULL(@SEARCH, Id), '%') 
										  OR D.[Divisa.Nomenclatura] LIKE CONCAT('%', ISNULL(@SEARCH, [Divisa.Nomenclatura]), '%') 

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