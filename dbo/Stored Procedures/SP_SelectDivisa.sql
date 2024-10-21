--
CREATE   PROCEDURE usp_SelectDivisa (		  @SEARCH			NVARCHAR(MAX)  =	NULL
												, @PAGE				INT			   =	1
												, @SIZE				INT			   =	10
												, @ORDEN            INT			   =    1
												, @USUARIO_ID		INT			   =	NULL
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
	SET @PAGE = ISNULL(@PAGE, 1)
	SET @SIZE = ISNULL(@SIZE, 10)
	
	DECLARE @TOTAL_RECORDS INT = 0

	DECLARE @JSON_RESULT_1 NVARCHAR(MAX) --NO ELIMINAR, NO SE ESTA UTILIZANDO PERO SIVER PARA DEBBUGEAR
	DECLARE @JSON_RESULT_2 NVARCHAR(MAX)
	DECLARE @resp_JSON_Consolidada NVARCHAR(MAX)	

	------------------------------------------
				--FULL DATA--
	------------------------------------------
						SELECT	
						
						 Div.Id
						,Div.Nombre	
						,Div.Nomenclatura
						,Div.Simbolo
						,Div.Descripcion
						,Div.Activo
						, dbo.FN_CastTimeZoneFormat(@IS_UTC, @CURRENT_TIME_ZONE, @TIME_ZONE_FORMAT, Div.FechaCreacion)			AS FechaCreacion
						, dbo.FN_CastTimeZoneFormat(@IS_UTC, @CURRENT_TIME_ZONE, @TIME_ZONE_FORMAT, Div.FechaModificacion)		AS FechaModificacion
						,(							
								SELECT									
								T.Id,
								T.Nombre,								
								T.Activo
								, dbo.FN_CastTimeZoneFormat(@IS_UTC, @CURRENT_TIME_ZONE, @TIME_ZONE_FORMAT, T.FechaCreacion)			AS FechaCreacion
								, dbo.FN_CastTimeZoneFormat(@IS_UTC, @CURRENT_TIME_ZONE, @TIME_ZONE_FORMAT, T.FechaModificacion)		AS FechaModificacion

								FROM tblDivisa_x_TipoEfectivo
								INNER JOIN tblTipoEfectivo T on tblDivisa_x_TipoEfectivo.FkIdTipoEfectivo = T.Id	 
								WHERE tblDivisa_x_TipoEfectivo.Activo = 1
								AND Div.Id = tblDivisa_x_TipoEfectivo.FkIdDivisa
								FOR JSON PATH, INCLUDE_NULL_VALUES

						) AS Presentaciones_Habilitadas
						, STUFF(
							(
							    SELECT ', ' + T.Nombre
								FROM tblDivisa_x_TipoEfectivo
								INNER JOIN tblTipoEfectivo T on tblDivisa_x_TipoEfectivo.FkIdTipoEfectivo = T.Id	 
								AND Div.Id = tblDivisa_x_TipoEfectivo.FkIdDivisa
								FOR XML PATH ('')
							 ), 1, 2, ''
						) AS Nombres_Tipo_Efectivos_Concatenados
						INTO #tblFullData
						FROM tblDivisa Div

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

													WHEN @ORDEN = -4 THEN ROW_NUMBER() OVER(ORDER BY [Simbolo] DESC)
													WHEN @ORDEN =  4 THEN ROW_NUMBER() OVER(ORDER BY [Simbolo] ASC)

													WHEN @ORDEN = -5 THEN ROW_NUMBER() OVER(ORDER BY [Descripcion] DESC)
													WHEN @ORDEN =  5 THEN ROW_NUMBER() OVER(ORDER BY [Descripcion] ASC)

													WHEN @ORDEN = -6 THEN ROW_NUMBER() OVER(ORDER BY [Nombres_Tipo_Efectivos_Concatenados] DESC)
													WHEN @ORDEN =  6 THEN ROW_NUMBER() OVER(ORDER BY [Nombres_Tipo_Efectivos_Concatenados] ASC)

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
										  OR D.Nomenclatura LIKE CONCAT('%', ISNULL(@SEARCH, Nomenclatura), '%') 
										  OR D.Descripcion LIKE CONCAT('%', ISNULL(@SEARCH, Descripcion), '%') 
										  OR D.Nombres_Tipo_Efectivos_Concatenados LIKE CONCAT('%', ISNULL(@SEARCH, Nombres_Tipo_Efectivos_Concatenados), '%') 

						)
	--SE PASA LA DATA INDEXADA A UNA TABLA TEMPORAL
	SELECT * INTO #tmpTblDataIndexed FROM DATA_INDEXED ORDER BY [INDEX] 

	DROP TABLE #tblFullData 

	--- OBTIENE EL TOTAL DE FILAS PAGINADAS
	SET @TOTAL_RECORDS = (SELECT COUNT(*) FROM #tmpTblDataIndexed)
		
	--- SE PASA LA DATA INDEXADA A UNA VARIABLE, YA EN FORMATO JSON
	SET @JSON_RESULT_2 = (SELECT * FROM #tmpTblDataIndexed WHERE [INDEX] BETWEEN ((@PAGE * @SIZE)-(@SIZE-1)) AND (@PAGE * @SIZE) ORDER BY [INDEX] FOR JSON PATH, INCLUDE_NULL_VALUES)

	--A LA RESPUESTA DEL FORMADO JSON HAY QUE QUITARLES LOS SIGUIENTES CARACTERES PARA PODER QUE LA APP LA RESIVA EN LA ESTRUCTURA PERSONALIZADA QUE SE DECEE

	--SEGUNDO NIVEL DEL JSON
	SET @resp_JSON_Consolidada =  REPLACE( @JSON_RESULT_2,':"[{\',':[{\')						    --- INICIO DE LA CADENA DE CADA ARRAY		       :"[{\			->    :[{\									
	SET @resp_JSON_Consolidada =  REPLACE( @resp_JSON_Consolidada,'\"}]"','\"}]')				    --- FINAL DE LA CADENA CADA ARRAY HIJO             \"}]"			->    \"}]
	SET @resp_JSON_Consolidada =  REPLACE( @resp_JSON_Consolidada,'null}]","','null}],"')		    --- FINAL DE LA CADENA CADA ARRAY HIJO				null}]","		->   null}],"	
	SET @resp_JSON_Consolidada =  REPLACE( @resp_JSON_Consolidada,':\"\"}]","',':\"\"}],"')		    --- FINAL DE LA CADENA CADA ARRAY HIJO				:\"\"}]","		->   :\"\"}],"
	
	--NO OLVIDAR APLICAR ESTA PARA ESPACIOS EN BLANCO
	SET @resp_JSON_Consolidada =  REPLACE( @resp_JSON_Consolidada,'\','')							--- SUSTITUIR TODAS LAS BARRAS						\				->    ''VACIO''

	------------------------------------------
		-- RESPUESTA ENVIADA A LA APP --
	------------------------------------------

	SELECT @TOTAL_RECORDS AS TotalRecords, @PAGE AS Page, @SIZE AS SizePage 

	SELECT @resp_JSON_Consolidada AS JSON_RESULT_2;

END