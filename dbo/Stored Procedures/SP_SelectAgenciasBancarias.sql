---
CREATE   PROCEDURE SP_SelectAgenciasBancarias(	  @SEARCH		NVARCHAR(MAX)		=		NULL
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
					  SELECT  
						  A.Id					  AS	[Id]
						, A.Nombre				  AS	[Nombre]
						, A.FkIdGrupoAgencia	  AS	[FkIdGrupoAgencia]
						, A.UsaCuentasGrupo		  AS	[UsaCuentasGrupo]
						, A.EnviaRemesas		  AS	[EnviaRemesas]
						, A.SolicitaRemesas		  AS	[SolicitaRemesas]
						, A.CodigoBranch		  AS	[CodigoBranch]
						, P.Nombre		          AS	[CodigoProvincia]
						, C.Nombre		          AS	[CodigoCanton]
						, D.Nombre		          AS	[CodigoDistrito]
						, A.Direccion			  AS	[Direccion]
						, A.Codigo_Agencia        AS    [Codigo_Agencia]
						, CE.Nombre               AS    [Nombre_Cedis]
						, CE.Codigo_Cedis         AS    [Codigo_Cedis]
						, PA.Nombre               AS    [Nombre_Pais]
						, PA.Codigo               AS    [Codigo]
						, G.Nombre                AS    [Nombre_Grupo]
						, A.Activo				  AS	[Activo]
						, STUFF((
									SELECT ', ' + CONVERT(varchar, D.Nomenclatura +' '+ CI.NumeroCuenta)
									FROM tblCuentaInterna_x_Agencia CA
									LEFT JOIN tblCuentaInterna CI
									ON CI.Id = CA.FkIdCuentaInterna
									INNER JOIN tblDivisa D
									ON D.Id = CI.FkIdDivisa
									WHERE CA.FkIdAgencia = A.Id
									AND CA.Activo = 1
									FOR XML PATH ('')
								), 1, 2, ''
								)                 AS Cuentas
						, (
							SELECT DISTINCT
								  T.Id								AS	[Id]
								, T.Nombre							AS	[Nombre]
								, T.Codigo							AS	[Codigo]													
								, T.Activo							AS	[Activo]
								, dbo.FN_CastTimeZoneFormat(@IS_UTC, @CURRENT_TIME_ZONE, @TIME_ZONE_FORMAT, T.Fecha_Creacion)			 AS	[Fecha_Creacion]
								, dbo.FN_CastTimeZoneFormat(@IS_UTC, @CURRENT_TIME_ZONE, @TIME_ZONE_FORMAT, T.Fecha_Modificacion)		 AS	[Fecha_Modificacion]

							FROM tblTransportadoras T
							WHERE A.Fk_Transportadora_Envio = T.Id
							FOR JSON PATH
						) AS Transportadora_Envio
						, (
							SELECT DISTINCT
								  T.Id								AS	[Id]
								, T.Nombre							AS	[Nombre]
								, T.Codigo							AS	[Codigo]													
								, T.Activo							AS	[Activo]
								, dbo.FN_CastTimeZoneFormat(@IS_UTC, @CURRENT_TIME_ZONE, @TIME_ZONE_FORMAT, T.Fecha_Creacion)			 AS	[Fecha_Creacion]
								, dbo.FN_CastTimeZoneFormat(@IS_UTC, @CURRENT_TIME_ZONE, @TIME_ZONE_FORMAT, T.Fecha_Modificacion)		 AS	[Fecha_Modificacion]
							FROM tblTransportadoras T
							WHERE A.Fk_Transportadora_Solicitud = T.Id
							FOR JSON PATH
						) AS Transportadora_Solicitud
						, (
							SELECT DISTINCT
								CI.Id,
								CI.NumeroCuenta,
								CI.Codigo,
								CI.Activo
								, dbo.FN_CastTimeZoneFormat(@IS_UTC, @CURRENT_TIME_ZONE, @TIME_ZONE_FORMAT, CI.FechaCreacion)			 AS	[FechaCreacion]
								, dbo.FN_CastTimeZoneFormat(@IS_UTC, @CURRENT_TIME_ZONE, @TIME_ZONE_FORMAT, CI.FechaModificacion)		 AS	[FechaModificacion]
								, D.Id                    [Divisa.Id],
								D.Activo                [Divisa.Activo],
								D.Nombre                [Divisa.Nombre],
								D.Nomenclatura          [Divisa.Nomenclatura],
								D.Descripcion           [Divisa.Descripcion]
							FROM tblCuentaInterna_x_Agencia CA
							LEFT JOIN tblCuentaInterna CI
							ON CI.Id = CA.FkIdCuentaInterna
							INNER JOIN tblDivisa D
							ON D.Id = CI.FkIdDivisa
							WHERE CA.FkIdAgencia = A.Id
							AND CA.Activo = 1
							FOR JSON PATH
						) AS CuentaInterna
                INTO #tblFullData
				FROM tblAgenciaBancaria A
				INNER JOIN tblGrupoAgencia G
				ON A.FkIdGrupoAgencia = G.Id
				INNER JOIN tblProvincia P
				ON A.CodigoProvincia = P.Id
				INNER JOIN tblCanton C
				ON A.CodigoCanton = C.Id
				INNER JOIN tblDistrito D
				ON A.CodigoDistrito = D.Id
				INNER JOIN tblCedis CE
				ON A.FkIdCedi = CE.Id_Cedis
				INNER JOIN tblPais PA
				ON A.FkIdPais = PA.Id
				
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

													WHEN @ORDEN = -4 THEN ROW_NUMBER() OVER(ORDER BY CodigoBranch DESC)
													WHEN @ORDEN =  4 THEN ROW_NUMBER() OVER(ORDER BY CodigoBranch ASC)

													WHEN @ORDEN = -5 THEN ROW_NUMBER() OVER(ORDER BY CodigoProvincia DESC)
													WHEN @ORDEN =  5 THEN ROW_NUMBER() OVER(ORDER BY CodigoProvincia ASC)

													WHEN @ORDEN = -6 THEN ROW_NUMBER() OVER(ORDER BY CodigoCanton DESC)
													WHEN @ORDEN =  6 THEN ROW_NUMBER() OVER(ORDER BY CodigoCanton ASC)
													
													WHEN @ORDEN = -7 THEN ROW_NUMBER() OVER(ORDER BY CodigoDistrito DESC)
													WHEN @ORDEN =  7 THEN ROW_NUMBER() OVER(ORDER BY CodigoDistrito ASC)

													WHEN @ORDEN = -9 THEN ROW_NUMBER() OVER(ORDER BY Codigo_Agencia DESC)
													WHEN @ORDEN =  9 THEN ROW_NUMBER() OVER(ORDER BY Codigo_Agencia ASC)

													WHEN @ORDEN = -10 THEN ROW_NUMBER() OVER(ORDER BY Nombre_Cedis DESC)
													WHEN @ORDEN =  10 THEN ROW_NUMBER() OVER(ORDER BY Nombre_Cedis ASC)

													WHEN @ORDEN = -11 THEN ROW_NUMBER() OVER(ORDER BY Codigo_Cedis DESC)
													WHEN @ORDEN =  11 THEN ROW_NUMBER() OVER(ORDER BY Codigo_Cedis ASC)

													WHEN @ORDEN = -12 THEN ROW_NUMBER() OVER(ORDER BY Nombre_Pais DESC)
													WHEN @ORDEN =  12 THEN ROW_NUMBER() OVER(ORDER BY Nombre_Pais ASC)

													WHEN @ORDEN = -13 THEN ROW_NUMBER() OVER(ORDER BY Codigo DESC)
													WHEN @ORDEN =  13 THEN ROW_NUMBER() OVER(ORDER BY Codigo ASC)

													WHEN @ORDEN = -14 THEN ROW_NUMBER() OVER(ORDER BY Nombre_Grupo DESC)
													WHEN @ORDEN =  14 THEN ROW_NUMBER() OVER(ORDER BY Nombre_Grupo ASC)

													WHEN @ORDEN = -15 THEN ROW_NUMBER() OVER(ORDER BY SolicitaRemesas DESC)
													WHEN @ORDEN =  15 THEN ROW_NUMBER() OVER(ORDER BY SolicitaRemesas ASC)

													WHEN @ORDEN = -16 THEN ROW_NUMBER() OVER(ORDER BY Transportadora_Solicitud DESC)
													WHEN @ORDEN =  16 THEN ROW_NUMBER() OVER(ORDER BY Transportadora_Solicitud ASC)

													WHEN @ORDEN = -17 THEN ROW_NUMBER() OVER(ORDER BY EnviaRemesas DESC)
													WHEN @ORDEN =  17 THEN ROW_NUMBER() OVER(ORDER BY EnviaRemesas ASC)

													WHEN @ORDEN = -18 THEN ROW_NUMBER() OVER(ORDER BY Transportadora_Envio DESC)
													WHEN @ORDEN =  18 THEN ROW_NUMBER() OVER(ORDER BY Transportadora_Envio ASC)

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
										  OR D.CodigoBranch LIKE CONCAT('%', ISNULL(@SEARCH, CodigoBranch), '%') 
										  OR D.Id LIKE CONCAT('%', ISNULL(@SEARCH, Id), '%') 
										  OR D.Nombre LIKE CONCAT('%', ISNULL(@SEARCH, Nombre), '%') 
										  OR D.CodigoProvincia LIKE CONCAT('%', ISNULL(@SEARCH, CodigoProvincia), '%') 
										  OR D.CodigoCanton LIKE CONCAT('%', ISNULL(@SEARCH, CodigoCanton), '%') 
										  OR D.CodigoDistrito LIKE CONCAT('%', ISNULL(@SEARCH, CodigoDistrito), '%') 
										  OR D.Codigo_Agencia LIKE CONCAT('%', ISNULL(@SEARCH, Codigo_Agencia), '%') 
										  OR D.Nombre_Cedis LIKE CONCAT('%', ISNULL(@SEARCH, Nombre_Cedis), '%') 
										  OR D.Codigo_Cedis LIKE CONCAT('%', ISNULL(@SEARCH, Codigo_Cedis), '%') 
										  OR D.Nombre_Pais LIKE CONCAT('%', ISNULL(@SEARCH, Nombre_Pais), '%') 
										  OR D.Codigo LIKE CONCAT('%', ISNULL(@SEARCH, Codigo), '%') 
										  OR D.Nombre_Grupo LIKE CONCAT('%', ISNULL(@SEARCH, Nombre_Grupo), '%') 
										  OR D.Cuentas LIKE CONCAT('%', ISNULL(@SEARCH, Cuentas), '%') 
										  OR D.Transportadora_Solicitud LIKE CONCAT('%', ISNULL(@SEARCH, Transportadora_Solicitud), '%') 
										  OR D.Transportadora_Envio LIKE CONCAT('%', ISNULL(@SEARCH, Transportadora_Envio), '%') 
										  OR  D.SolicitaRemesas = (
											  CASE 
											  WHEN @SEARCH  = 'Activo' THEN 1
											  WHEN @SEARCH = 'Inactivo' THEN 0 END
											  )
										  OR  D.EnviaRemesas = (
											  CASE 
											  WHEN @SEARCH  = 'Activo' THEN 1
											  WHEN @SEARCH = 'Inactivo' THEN 0 END
											  )

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