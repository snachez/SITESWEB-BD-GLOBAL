CREATE PROCEDURE [dbo].[usp_SelectCuentaInterna_x_AgenciaBancaria](	
																		  @ID						NVARCHAR(MAX)  =	NULL
																		, @FK_ID_AGENCIA			NVARCHAR(MAX)  =	NULL
																		, @FK_ID_CUENTA				NVARCHAR(MAX)  =	NULL
																		, @CODIGO_AGENCIA_CUENTA	NVARCHAR(MAX)  =	NULL
																		, @BRANCH_AGENCIA			NVARCHAR(MAX)  =	NULL
																		, @CODIGO_CUENTA			NVARCHAR(MAX)  =	NULL
																		, @ACTIVO					NVARCHAR(MAX)  =	NULL
																		, @PAGE				        INT			   =	NULL
													                    , @SIZE				        INT			   =	NULL
													                    , @ORDEN                    INT			   =    1
																		, @USUARIO_ID				INT			   =	NULL
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
              SELECT      C.Id							 AS [Id]
						, C.NumeroCuenta				 AS [NumeroCuenta]
						, C.Codigo						 AS [Codigo]
						, C.Activo						 AS [Activo]
						, dbo.FN_CastTimeZoneFormat(@IS_UTC, @CURRENT_TIME_ZONE, @TIME_ZONE_FORMAT, C.FechaCreacion)			 AS [FechaCreacion]
						, dbo.FN_CastTimeZoneFormat(@IS_UTC, @CURRENT_TIME_ZONE, @TIME_ZONE_FORMAT, C.FechaModificacion)		 AS [FechaModificacion]


						, D.Id							 AS [Divisa.Id]
						, D.Nombre						 AS [Divisa.Nombre]
						, D.Nomenclatura				 AS [Divisa.Nomenclatura]
						, D.Simbolo						 AS [Divisa.Simbolo]
						, D.Descripcion					 AS [Divisa.Descripcion]
						, D.Activo						 AS [Divisa.Activo]
						, dbo.FN_CastTimeZoneFormat(@IS_UTC, @CURRENT_TIME_ZONE, @TIME_ZONE_FORMAT, D.FechaCreacion)			 AS [Divisa.FechaCreacion]
						, dbo.FN_CastTimeZoneFormat(@IS_UTC, @CURRENT_TIME_ZONE, @TIME_ZONE_FORMAT, D.FechaModificacion)		 AS [Divisa.FechaModificacion]
						, CA.Id                          AS [tblCuentaInterna_x_Agencia_Id]
						, CA.FkIdAgencia                 AS [tblCuentaInterna_x_Agencia_FkIdAgencia]
						, CA.FkIdCuentaInterna           AS [tblCuentaInterna_x_Agencia_FkIdCuentaInterna]
						, CA.Codigo                      AS [tblCuentaInterna_x_Agencia_Codigo]
						, CA.Activo                      AS [tblCuentaInterna_x_Agencia_Activo]
						, A.CodigoBranch                 AS [tblAgenciaBancaria_CodigoBranch]
            INTO #tblFullData
			FROM tblCuentaInterna_x_Agencia CA
			INNER JOIN tblAgenciaBancaria A
			ON CA.FkIdAgencia = A.Id
			INNER JOIN tblCuentaInterna C
			ON CA.FkIdCuentaInterna = C.Id
			INNER JOIN tblDivisa D
			ON C.FkIdDivisa = D.Id
				
	------------------------------------------
		-- DATA INDEXADA & FILTRADA --
	------------------------------------------
	
	;WITH DATA_INDEXED AS (				
								SELECT	  *
										, CASE 
													WHEN @ORDEN = -1 THEN ROW_NUMBER() OVER(ORDER BY [Id] DESC)
													WHEN @ORDEN =  1 THEN ROW_NUMBER() OVER(ORDER BY [Id] ASC)

													WHEN @ORDEN = -2 THEN ROW_NUMBER() OVER(ORDER BY [NumeroCuenta] DESC)
													WHEN @ORDEN =  2 THEN ROW_NUMBER() OVER(ORDER BY [NumeroCuenta] ASC)

													WHEN @ORDEN = -3 THEN ROW_NUMBER() OVER(ORDER BY [Divisa.Nomenclatura] DESC)
													WHEN @ORDEN =  3 THEN ROW_NUMBER() OVER(ORDER BY [Divisa.Nomenclatura] ASC)														

													WHEN @ORDEN = -4 THEN ROW_NUMBER() OVER(ORDER BY [tblCuentaInterna_x_Agencia_Activo] DESC)
													WHEN @ORDEN =  4 THEN ROW_NUMBER() OVER(ORDER BY [tblCuentaInterna_x_Agencia_Activo] ASC)

													WHEN @ORDEN = -5 THEN ROW_NUMBER() OVER(ORDER BY [tblCuentaInterna_x_Agencia_Activo] DESC)
													WHEN @ORDEN =  5 THEN ROW_NUMBER() OVER(ORDER BY [tblCuentaInterna_x_Agencia_Activo] ASC)

													ELSE ROW_NUMBER() OVER(ORDER BY [Id] ASC)

												END
											AS [INDEX]
										FROM #tblFullData AS D	
										WHERE 
												      D.[tblCuentaInterna_x_Agencia_Id] LIKE CONCAT('%', ISNULL(@ID, [tblCuentaInterna_x_Agencia_Id]), '%') 
												  AND D.[tblCuentaInterna_x_Agencia_FkIdAgencia] LIKE CONCAT('%', ISNULL(@FK_ID_AGENCIA, [tblCuentaInterna_x_Agencia_FkIdAgencia]), '%') 
												  AND D.[tblCuentaInterna_x_Agencia_FkIdCuentaInterna] LIKE CONCAT('%', ISNULL(@FK_ID_CUENTA, [tblCuentaInterna_x_Agencia_FkIdCuentaInterna]), '%') 
												  AND D.[tblCuentaInterna_x_Agencia_Codigo] LIKE CONCAT('%', ISNULL(@CODIGO_AGENCIA_CUENTA, [tblCuentaInterna_x_Agencia_Codigo]), '%') 
												  AND D.[tblCuentaInterna_x_Agencia_Activo] LIKE CONCAT('%', ISNULL(@ACTIVO, [tblCuentaInterna_x_Agencia_Activo]), '%') 
												  AND D.[Codigo] LIKE CONCAT('%', ISNULL(@CODIGO_CUENTA, [Codigo]), '%') 
												  AND D.[tblAgenciaBancaria_CodigoBranch] LIKE CONCAT('%', ISNULL(@BRANCH_AGENCIA, [tblAgenciaBancaria_CodigoBranch]), '%') 

						)

	--SE PASA LA DATA INDEXADA A UNA TABLA TEMPORAL
	SELECT * INTO #tmpTblData FROM DATA_INDEXED ORDER BY [INDEX];

	--- OBTIENE EL TOTAL DE FILAS PAGINADAS
	SET @TOTAL_RECORDS = (SELECT COUNT(*) FROM #tmpTblData)
										---
	SET @JSON_RESULT_2 = (SELECT Id, NumeroCuenta, Codigo, Activo, FechaCreacion, FechaModificacion, [Divisa.Id], [Divisa.Nombre],
	                      [Divisa.Nomenclatura], [Divisa.Simbolo], [Divisa.Descripcion], [Divisa.Activo], [Divisa.FechaCreacion], [Divisa.FechaModificacion]
	FROM #tmpTblData WHERE [INDEX] BETWEEN  (@PAGE)  AND   ((@PAGE)+(@SIZE-1)) ORDER BY [INDEX] FOR JSON PATH)
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