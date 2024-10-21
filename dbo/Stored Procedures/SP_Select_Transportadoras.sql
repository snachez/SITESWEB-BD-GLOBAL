CREATE   PROCEDURE usp_Select_Transportadoras (	 																
														  @SEARCH			NVARCHAR(MAX)  =	NULL
														, @PAGE				INT			   =	1
														, @SIZE				INT			   =	10
														, @ORDEN            INT			   =    1
														, @USUARIO_ID INT = NULL
													)
AS
BEGIN


	SET @PAGE = ISNULL(@PAGE, 1)
	SET @SIZE = ISNULL(@SIZE, 10)
	
	DECLARE @TOTAL_RECORDS INT = 0

	DECLARE @JSON_RESULT_1 NVARCHAR(MAX) --NO ELIMINAR, NO SE ESTA UTILIZANDO PERO SIVER PARA DEBBUGEAR
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
				  T.Id								AS	[Id]
				, T.Nombre							AS	[Nombre]
				, T.Codigo							AS	[Codigo]													
				, T.Activo							AS	[Activo]
				, dbo.FN_CastTimeZoneFormat(@IS_UTC, @CURRENT_TIME_ZONE, @TIME_ZONE_FORMAT, T.Fecha_Creacion)		AS	[Fecha_Creacion]
				, dbo.FN_CastTimeZoneFormat(@IS_UTC, @CURRENT_TIME_ZONE, @TIME_ZONE_FORMAT, T.Fecha_Modificacion)	AS	[Fecha_Modificacion]

				,(
					SELECT	
					
						 P.Id
						,CONCAT(P.Nombre,'(', P.Codigo,')' ) AS Nombre
						,P.Codigo						
						,P.Activo
						, dbo.FN_CastTimeZoneFormat(@IS_UTC, @CURRENT_TIME_ZONE, @TIME_ZONE_FORMAT, P.FechaCreacion)		AS	FechaCreacion
						, dbo.FN_CastTimeZoneFormat(@IS_UTC, @CURRENT_TIME_ZONE, @TIME_ZONE_FORMAT, P.FechaModificacion)	AS	FechaModificacion
						FROM tblPais P
						INNER JOIN tblTransportadoras_x_Pais Trans_X_Pais on P.Id = Trans_X_Pais.Fk_Id_Pais
						AND Trans_X_Pais.Fk_Id_Transportadora = T.Id						
						FOR JSON PATH, INCLUDE_NULL_VALUES

				) AS Pais
				,(
					SELECT	
					
						 M.Id
						,M.Nombre											
						,M.Activo
						, dbo.FN_CastTimeZoneFormat(@IS_UTC, @CURRENT_TIME_ZONE, @TIME_ZONE_FORMAT, M.FechaCreacion)		AS	FechaCreacion
						, dbo.FN_CastTimeZoneFormat(@IS_UTC, @CURRENT_TIME_ZONE, @TIME_ZONE_FORMAT, M.FechaModificacion)	AS	FechaModificacion
						FROM tblModulo M
						INNER JOIN tblTransportadoras_x_Modulo Trans_X_Modulo on M.Id = Trans_X_Modulo.Fk_Id_Modulo
						AND Trans_X_Modulo.Fk_Id_Transportadora = T.Id						
						FOR JSON PATH, INCLUDE_NULL_VALUES

				) AS Modulo
				, STUFF(
							(
							    SELECT ', ' + P.Nombre + '-' + P.Codigo
								FROM tblTransportadoras_x_Pais Trans_X_Pais
								INNER JOIN tblPais P
								ON Trans_X_Pais.Fk_Id_Pais = P.Id
								AND Trans_X_Pais.Fk_Id_Transportadora = T.Id	
								FOR XML PATH ('')
							 ), 1, 2, ''
				) AS Nombres_Paises_Concatenados
				, STUFF(
							(
							    SELECT ', ' + M.Nombre 
								FROM tblTransportadoras_x_Modulo Trans_X_Modulo
								INNER JOIN tblModulo M
								ON Trans_X_Modulo.Fk_Id_Modulo = M.Id
								AND Trans_X_Modulo.Fk_Id_Transportadora = T.Id	
								FOR XML PATH ('')
							 ), 1, 2, ''
				) AS Nombres_Modulos_Concatenados
				INTO #tblFullData
				FROM tblTransportadoras T
	

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

													WHEN @ORDEN = -4 THEN ROW_NUMBER() OVER(ORDER BY [Codigo] DESC)
													WHEN @ORDEN =  4 THEN ROW_NUMBER() OVER(ORDER BY [Codigo] ASC)

													ELSE ROW_NUMBER() OVER(ORDER BY Id ASC)
												END
											AS [INDEX]
										FROM #tblFullData AS T	
										WHERE 	
										    T.Activo = (
											  CASE 
											  WHEN @SEARCH  = 'Activo' THEN 1
											  WHEN @SEARCH = 'Inactivo' THEN 0 END
											  )
										  OR T.Id LIKE CONCAT('%', ISNULL(@SEARCH, Id), '%') 
										  OR T.Nombre LIKE CONCAT('%', ISNULL(@SEARCH, Nombre), '%') 
										  OR T.Codigo LIKE CONCAT('%', ISNULL(@SEARCH, Codigo), '%')
										  OR T.Nombres_Paises_Concatenados LIKE CONCAT('%', ISNULL(@SEARCH, Nombres_Paises_Concatenados), '%') 
										  OR T.Nombres_Modulos_Concatenados LIKE CONCAT('%', ISNULL(@SEARCH, Nombres_Modulos_Concatenados), '%') 

						)
	--SE PASA LA DATA INDEXADA A UNA TABLA TEMPORAL
	SELECT * INTO #tmpTblDataIndexed FROM DATA_INDEXED ORDER BY [INDEX] 

	DROP TABLE #tblFullData 


	--- OBTIENE EL TOTAL DE FILAS PAGINADAS
	SET @TOTAL_RECORDS = (SELECT COUNT(*) FROM #tmpTblDataIndexed)
		
	--- SE PASA LA DATA INDEXADA A UNA VARIABLE, YA EN FORMATO JSON
	SET @JSON_RESULT_2 = (SELECT * FROM #tmpTblDataIndexed WHERE [INDEX] BETWEEN (@PAGE) AND ((@PAGE)+(@SIZE-1)) ORDER BY [INDEX] FOR JSON PATH, INCLUDE_NULL_VALUES)

	
	--A LA RESPUESTA DEL FORMADO JSON HAY QUE QUITARLES LOS SIGUIENTES CARACTERES PARA PODER QUE LA APP LA RESIVA EN LA ESTRUCTURA PERSONALIZADA QUE SE DECEE
	SET @resp_JSON_Consolidada =  REPLACE( @JSON_RESULT_2,':"[{\',':[{\')						    --- INICIO DE LA CADENA DE CADA ARRAY		       :"[{\			->    :[{\									
	SET @resp_JSON_Consolidada =  REPLACE( @resp_JSON_Consolidada,'\"}]"','\"}]')				    --- FINAL DE LA CADENA CADA ARRAY HIJO             \"}]"			->    \"}]
	SET @resp_JSON_Consolidada =  REPLACE( @resp_JSON_Consolidada,'null}]","','null}],"')		    --- FINAL DE LA CADENA CADA ARRAY HIJO				null}]","		->   null}],"	
	SET @resp_JSON_Consolidada =  REPLACE( @resp_JSON_Consolidada,':\"\"}]","',':\"\"}],"')		    --- FINAL DE LA CADENA CADA ARRAY HIJO				:\"\"}]","		->   :\"\"}],"

	SET @resp_JSON_Consolidada =  REPLACE( @resp_JSON_Consolidada,'\','')							--- SUSTITUIR TODAS LAS BARRAS						\				->    ''VACIO''

	------------------------------------------
		-- RESPUESTA ENVIADA A LA APP --
	------------------------------------------
	SELECT @TOTAL_RECORDS AS TotalRecords, @PAGE AS Page, @SIZE AS SizePage 

	SELECT @resp_JSON_Consolidada AS JSON_RESULT_2;
END