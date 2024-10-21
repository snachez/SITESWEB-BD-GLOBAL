CREATE   PROCEDURE usp_SelectGrupoAgencia(        @SEARCH					NVARCHAR(MAX)  =	NULL
													  , @PAGE					INT			   =	1
												      , @SIZE					INT			   =	10
												      , @ORDEN                  INT            =    1
													  , @USUARIO_ID				INT			   =	NULL
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
		G.Activo,
		G.Id,
		G.Nombre,
		 STUFF((SELECT DISTINCT ', ' + A.Nombre
                  FROM tblAgenciaBancaria A
                  WHERE A.FkIdGrupoAgencia = G.Id AND A.Activo = 1
				  FOR XML PATH ('')
				), 1, 2, ''
			) AS AgenciasActivas,
        0 AS UsuariosVinculados,
		 STUFF((SELECT ', ' + CONVERT(varchar, D.Nomenclatura +' '+ CI.NumeroCuenta)
                  FROM tblCuentaInterna_x_GrupoAgencias CG
                  LEFT JOIN tblCuentaInterna CI
                    ON CI.Id = CG.FkIdCuentaInterna
			      INNER JOIN tblDivisa D
			        ON D.Id = CI.FkIdDivisa
                  WHERE CG.FkIdGrupoAgencias = G.Id
			        AND CG.Activo = 1
				  FOR XML PATH ('')
				), 1, 2, ''
			) AS Cuentas,
		G.EnviaRemesas,
		G.SolicitaRemesas,
		(
			SELECT DISTINCT
				CI.Id,
				CI.NumeroCuenta,
				CI.Codigo,
				CI.Activo
				, dbo.FN_CastTimeZoneFormat(@IS_UTC, @CURRENT_TIME_ZONE, @TIME_ZONE_FORMAT, CI.FechaCreacion)			AS FechaCreacion
				, dbo.FN_CastTimeZoneFormat(@IS_UTC, @CURRENT_TIME_ZONE, @TIME_ZONE_FORMAT, CI.FechaModificacion)		AS FechaModificacion,
				D.Id                    [Divisa.Id],
				D.Activo                [Divisa.Activo],
				D.Nombre                [Divisa.Nombre],
				D.Nomenclatura          [Divisa.Nomenclatura],
				D.Descripcion           [Divisa.Descripcion]
			FROM tblCuentaInterna_x_GrupoAgencias CG
			LEFT JOIN tblCuentaInterna CI
			ON CI.Id = CG.FkIdCuentaInterna
			INNER JOIN tblDivisa D
			ON D.Id = CI.FkIdDivisa
			WHERE CG.FkIdGrupoAgencias = G.Id
			AND CG.Activo = 1
			FOR JSON PATH
		) AS CuentaInterna
	INTO #tblFullData
	FROM tblGrupoAgencia G

	------------------------------------------
		-- DATA INDEXADA & FILTRADA --
	------------------------------------------
	
	;WITH DATA_INDEXED AS (				
								SELECT	  *
										, CASE 
													WHEN @ORDEN = -1 THEN ROW_NUMBER() OVER(ORDER BY Activo DESC)
													WHEN @ORDEN =  1 THEN ROW_NUMBER() OVER(ORDER BY Activo ASC)

													WHEN @ORDEN = -2 THEN ROW_NUMBER() OVER(ORDER BY Id DESC)
													WHEN @ORDEN =  2 THEN ROW_NUMBER() OVER(ORDER BY Id ASC)

													WHEN @ORDEN = -3 THEN ROW_NUMBER() OVER(ORDER BY Nombre DESC)
													WHEN @ORDEN =  3 THEN ROW_NUMBER() OVER(ORDER BY Nombre ASC)														

													WHEN @ORDEN = -4 THEN ROW_NUMBER() OVER(ORDER BY AgenciasActivas DESC)
													WHEN @ORDEN =  4 THEN ROW_NUMBER() OVER(ORDER BY AgenciasActivas ASC)

													WHEN @ORDEN = -5 THEN ROW_NUMBER() OVER(ORDER BY UsuariosVinculados DESC)
													WHEN @ORDEN =  5 THEN ROW_NUMBER() OVER(ORDER BY UsuariosVinculados ASC)

													WHEN @ORDEN = -6 THEN ROW_NUMBER() OVER(ORDER BY Cuentas DESC)
													WHEN @ORDEN =  6 THEN ROW_NUMBER() OVER(ORDER BY Cuentas ASC)

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
										  OR D.Id LIKE CONCAT('%', ISNULL(@SEARCH, Id), '%') 
										  OR D.Nombre LIKE CONCAT('%', ISNULL(@SEARCH, Nombre), '%') 
										  OR D.AgenciasActivas LIKE CONCAT('%', ISNULL(@SEARCH, AgenciasActivas), '%') 
										  OR D.Cuentas LIKE CONCAT('%', ISNULL(@SEARCH, Cuentas), '%') 
										  OR D.UsuariosVinculados LIKE CONCAT('%', ISNULL(@SEARCH, UsuariosVinculados), '%') 

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