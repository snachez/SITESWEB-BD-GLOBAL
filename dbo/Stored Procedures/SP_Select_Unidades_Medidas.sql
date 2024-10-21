CREATE   PROCEDURE SP_Select_Unidades_Medidas(	 																
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
				  U.Id								AS	[Id]
				, U.Nombre							AS	[Nombre]
				, U.Simbolo							AS	[Simbolo]										
				, U.Cantidad_Unidades				AS	[Cantidad_Unidades]	
				, U.Activo							AS	[Activo]
				, dbo.FN_CastTimeZoneFormat(@IS_UTC, @CURRENT_TIME_ZONE, @TIME_ZONE_FORMAT, U.Fecha_Creacion)			AS	[Fecha_Creacion]
				, dbo.FN_CastTimeZoneFormat(@IS_UTC, @CURRENT_TIME_ZONE, @TIME_ZONE_FORMAT, U.Fecha_Modificacion)		AS	[Fecha_Modificacion]

				,(
					SELECT	
					
						 Div.Id
						,Div.Nombre	
						,Div.Nomenclatura
						,Div.Simbolo
						,Div.Descripcion
						,Div.Activo
						, dbo.FN_CastTimeZoneFormat(@IS_UTC, @CURRENT_TIME_ZONE, @TIME_ZONE_FORMAT, Div.FechaCreacion)			AS	FechaCreacion
						, dbo.FN_CastTimeZoneFormat(@IS_UTC, @CURRENT_TIME_ZONE, @TIME_ZONE_FORMAT, Div.FechaModificacion)		AS	FechaModificacion

						,(
							SELECT	

								 TEF.Id
								,TEF.Nombre								
								,TEF.Activo
								, dbo.FN_CastTimeZoneFormat(@IS_UTC, @CURRENT_TIME_ZONE, @TIME_ZONE_FORMAT, TEF.FechaCreacion)			AS	FechaCreacion
								, dbo.FN_CastTimeZoneFormat(@IS_UTC, @CURRENT_TIME_ZONE, @TIME_ZONE_FORMAT, TEF.FechaModificacion)		AS	FechaModificacion

								FROM tblTipoEfectivo TEF	
								INNER JOIN tblUnidadMedida_x_TipoEfectivo Uni_X_Tef on TEF.Id = Uni_X_Tef.Fk_Id_Tipo_Efectivo
								AND Uni_X_Tef.Fk_Id_Unidad_Medida = U.Id	
								FOR JSON PATH, INCLUDE_NULL_VALUES

						) AS Presentaciones_Habilitadas		

						FROM tblDivisa Div
						INNER JOIN tblUnidadMedida_x_Divisa Uni_X_Div on Div.Id = Uni_X_Div.Fk_Id_Divisa
						AND Uni_X_Div.Fk_Id_Unidad_Medida = U.Id											
						FOR JSON PATH, INCLUDE_NULL_VALUES

				) AS Divisa	
				, STUFF(
							(
							    SELECT ', ' + Div.Nombre
								FROM tblUnidadMedida_x_Divisa Uni_X_Div
								INNER JOIN tblDivisa Div
								ON Uni_X_Div.Fk_Id_Divisa = Div.Id
								AND Uni_X_Div.Fk_Id_Unidad_Medida = U.Id	
								FOR XML PATH ('')
							 ), 1, 2, ''
				) AS Nombres_Divisas_Concatenados
				, STUFF(
							(
							    SELECT ', ' + T.Nombre
								FROM tblUnidadMedida_x_TipoEfectivo Uni_X_Tef 
								INNER JOIN tblTipoEfectivo T 
								ON Uni_X_Tef.Fk_Id_Tipo_Efectivo = T.Id
								AND Uni_X_Tef.Fk_Id_Unidad_Medida = U.Id	
								FOR XML PATH ('')
							 ), 1, 2, ''
				) AS Nombres_Tipo_Efectivos_Concatenados
				INTO #tblFullData
				FROM tblUnidadMedida U
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

													WHEN @ORDEN = -5 THEN ROW_NUMBER() OVER(ORDER BY [Nombres_Divisas_Concatenados] DESC)
													WHEN @ORDEN =  5 THEN ROW_NUMBER() OVER(ORDER BY [Nombres_Divisas_Concatenados] ASC)

													WHEN @ORDEN = -6 THEN ROW_NUMBER() OVER(ORDER BY [Cantidad_Unidades] DESC)
													WHEN @ORDEN =  6 THEN ROW_NUMBER() OVER(ORDER BY [Cantidad_Unidades] ASC)

													WHEN @ORDEN = -7 THEN ROW_NUMBER() OVER(ORDER BY [Nombres_Tipo_Efectivos_Concatenados] DESC)
													WHEN @ORDEN =  7 THEN ROW_NUMBER() OVER(ORDER BY [Nombres_Tipo_Efectivos_Concatenados] ASC)

													ELSE ROW_NUMBER() OVER(ORDER BY Id ASC)
												END
											AS [INDEX]
										FROM #tblFullData AS U	
										WHERE 	
										    U.Activo = (
											  CASE 
											  WHEN @SEARCH  = 'Activo' THEN 1
											  WHEN @SEARCH = 'Inactivo' THEN 0 END
											  )
										  OR U.Id LIKE CONCAT('%', ISNULL(@SEARCH, Id), '%') 
										  OR U.Nombre LIKE CONCAT('%', ISNULL(@SEARCH, Nombre), '%') 
										  OR U.Simbolo LIKE CONCAT('%', ISNULL(@SEARCH, Simbolo), '%') 
										  OR U.Cantidad_Unidades  LIKE CONCAT('%', ISNULL(@SEARCH, Cantidad_Unidades), '%') 
										  OR U.Nombres_Divisas_Concatenados LIKE CONCAT('%', ISNULL(@SEARCH, Nombres_Divisas_Concatenados), '%') 
										  OR U.Nombres_Tipo_Efectivos_Concatenados LIKE CONCAT('%', ISNULL(@SEARCH, Nombres_Tipo_Efectivos_Concatenados), '%') 

						)
	--SE PASA LA DATA INDEXADA A UNA TABLA TEMPORAL
	SELECT * INTO #tmpTblDataIndexed FROM DATA_INDEXED ORDER BY [INDEX] 

	DROP TABLE #tblFullData 


	--- OBTIENE EL TOTAL DE FILAS PAGINADAS
	SET @TOTAL_RECORDS = (SELECT COUNT(*) FROM #tmpTblDataIndexed)
		
	--- SE PASA LA DATA INDEXADA A UNA VARIABLE, YA EN FORMATO JSON
	SET @JSON_RESULT_2 = (SELECT * FROM #tmpTblDataIndexed WHERE [INDEX] BETWEEN (@PAGE) AND ((@PAGE)+(@SIZE-1)) ORDER BY [INDEX] FOR JSON PATH, INCLUDE_NULL_VALUES)
	
	--SELECT @JSON_RESULT_2 AS JSON_RESULT_2 --PARA DEBBUGUEAR

	
	--A LA RESPUESTA DEL FORMADO JSON HAY QUE QUITARLES LOS SIGUIENTES CARACTERES PARA PODER QUE LA APP LA RESIVA EN LA ESTRUCTURA PERSONALIZADA QUE SE DECEE
	SET @resp_JSON_Consolidada =  REPLACE( @JSON_RESULT_2,':"[{\',':[{\')						    --- INICIO DE LA CADENA DE CADA ARRAY		       :"[{\			->    :[{\									
	SET @resp_JSON_Consolidada =  REPLACE( @resp_JSON_Consolidada,'\"}]"','\"}]')				    --- FINAL DE LA CADENA CADA ARRAY HIJO             \"}]"			->    \"}]
	SET @resp_JSON_Consolidada =  REPLACE( @resp_JSON_Consolidada,'null}]","','null}],"')		    --- FINAL DE LA CADENA CADA ARRAY HIJO				null}]","		->   null}],"	
	SET @resp_JSON_Consolidada =  REPLACE( @resp_JSON_Consolidada,':\"\"}]","',':\"\"}],"')		    --- FINAL DE LA CADENA CADA ARRAY HIJO				:\"\"}]","		->   :\"\"}],"
	
	SET @resp_JSON_Consolidada =  REPLACE( @resp_JSON_Consolidada,'\"}]}]"','\"}]}]')			    --- FINAL DE LA CADENA CADA ARRAY NIETO				\"}]}]"			->   \"}]}]
	SET @resp_JSON_Consolidada =  REPLACE( @resp_JSON_Consolidada,'null}]}]","','null}]}],"')       --- FINAL DE LA CADENA CADA ARRAY NIETO				null}]}]","		->   null}]}],"
	SET @resp_JSON_Consolidada =  REPLACE( @resp_JSON_Consolidada,':\"\"}]}]","',':\"\"}]}],"')     --- FINAL DE LA CADENA CADA ARRAY NIETO				:\"\"}]}]","	->   :\"\"}]}],"

	SET @resp_JSON_Consolidada =  REPLACE( @resp_JSON_Consolidada,'\','')							--- SUSTITUIR TODAS LAS BARRAS						\				->    ''VACIO''

	------------------------------------------
		-- RESPUESTA ENVIADA A LA APP --
	------------------------------------------

	SELECT @TOTAL_RECORDS AS TotalRecords, @PAGE AS Page, @SIZE AS SizePage 

	SELECT @resp_JSON_Consolidada AS JSON_RESULT_2;
	
END