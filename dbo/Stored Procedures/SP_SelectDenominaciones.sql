
CREATE   PROCEDURE [dbo].[SP_SelectDenominaciones] (               @SEARCH					VARCHAR(MAX)  =	NULL
																		  , @PAGE					INT			   =	1
																		  , @SIZE					INT			   =	10
																		  , @ORDEN                  INT			   =    1
															)
AS
BEGIN
   
    SET @PAGE = ISNULL(@PAGE, 1)
	SET @SIZE = ISNULL(@SIZE, 10)
	
	DECLARE @TOTAL_RECORDS INT = 0

	DECLARE @JSON_RESULT_2 VARCHAR(MAX)
	DECLARE @resp_JSON_Consolidada VARCHAR(MAX)	

	------------------------------------------
				--FULL DATA--
	------------------------------------------
		SELECT 
																							--ORDEN DE COLUMNAS EN LA VISTA
			 D.Id																			-- 1
	        ,D.Activo																		-- 2
			,CONVERT(varchar, D.ValorNominal) + '<br/>'+ D.Nombre  AS ValorNominalFormat	-- 3
			,D.ValorNominal																	-- 4
			,D.Nombre                                               AS NombreDenominacion	-- 5
			,DI.Nomenclatura																-- 6
			,D.IdDivisa																		-- 7
			,TI.Nombre                                              AS NombreTipoEfectivo	-- 8
			,D.BMO																			-- 9			 																	            
			-------------------------------------- CAMPO MODULO ---------------------------------------------------------
			,STUFF(
					REPLACE(
								(
								   SELECT '<br/>' + CONVERT(varchar, MO.Id) +'-'+ MO.Nombre
								   FROM tblDenominaciones_x_Modulo DMO 
								   LEFT JOIN tblModulo MO 
								   ON DMO.FkIdModulo = MO.Id
								   WHERE DMO.Activo = 1
								   AND D.Id = DMO.FkIdDenominaciones
								   FOR XML PATH ('')
								),
							      '&lt;br/&gt;', '<br/>'
							), 
				    1, 5, ''
			     ) AS Modulo
			--------------------------------------- CAMPO MODULO_ID ------------------------------------------------------
			,STUFF(
					(
						SELECT ', ' + convert(varchar(max), MO.Id, 120)
                        FROM tblDenominaciones_x_Modulo DMO 
                        LEFT JOIN tblModulo MO 
			            ON DMO.FkIdModulo = MO.Id
						WHERE DMO.Activo = 1
						AND D.Id = DMO.FkIdDenominaciones
						FOR XML PATH ('')
					), 1, 2, ''
			     ) AS Modulo_Id
			,D.Imagen	
			------------------------------------------------------------------------------------------------
		INTO #tblFullData	
		FROM tblDenominaciones D
		INNER JOIN tblDivisa DI ON D.IdDivisa = DI.Id
		INNER JOIN tblTipoEfectivo TI ON D.BMO = TI.Id
		--WHERE
		--D.Activo = 1

	--PARA DEBBGUEAR EL PRIMER SELECT
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

													WHEN @ORDEN = -3 THEN ROW_NUMBER() OVER(ORDER BY ValorNominalFormat DESC)
													WHEN @ORDEN =  3 THEN ROW_NUMBER() OVER(ORDER BY ValorNominalFormat ASC)														

													WHEN @ORDEN = -4 THEN ROW_NUMBER() OVER(ORDER BY [Nomenclatura] DESC)
													WHEN @ORDEN =  4 THEN ROW_NUMBER() OVER(ORDER BY [Nomenclatura] ASC)

													WHEN @ORDEN = -5 THEN ROW_NUMBER() OVER(ORDER BY [NombreTipoEfectivo] DESC)
													WHEN @ORDEN =  5 THEN ROW_NUMBER() OVER(ORDER BY [NombreTipoEfectivo] ASC)

													WHEN @ORDEN = -6 THEN ROW_NUMBER() OVER(ORDER BY [Modulo] DESC)
													WHEN @ORDEN =  6 THEN ROW_NUMBER() OVER(ORDER BY [Modulo] ASC)

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
										  OR D.ValorNominalFormat LIKE CONCAT('%', ISNULL(@SEARCH, ValorNominalFormat), '%') 
										  OR D.Nomenclatura LIKE CONCAT('%', ISNULL(@SEARCH, Nomenclatura), '%') 
										  OR D.NombreTipoEfectivo LIKE CONCAT('%', ISNULL(@SEARCH, NombreTipoEfectivo), '%') 										  
										  OR D.Modulo LIKE CONCAT('%', ISNULL(@SEARCH, Modulo), '%') 

						)
	--SE PASA LA DATA INDEXADA A UNA TABLA TEMPORAL
	SELECT * INTO #tmpTblDataIndexed FROM DATA_INDEXED ORDER BY [INDEX] 

	DROP TABLE #tblFullData 

	--- OBTIENE EL TOTAL DE FILAS PAGINADAS
	SET @TOTAL_RECORDS = (SELECT COUNT(*) FROM #tmpTblDataIndexed)
		
	--- SE PASA LA DATA INDEXADA A UNA VARIABLE, YA EN FORMATO JSON
	SET @JSON_RESULT_2 = (SELECT * FROM #tmpTblDataIndexed WHERE [INDEX] BETWEEN (@PAGE) AND ((@PAGE)+(@SIZE-1)) ORDER BY [INDEX] FOR JSON PATH, INCLUDE_NULL_VALUES)
	
	--A LA RESPUESTA DEL FORMADO JSON HAY QUE QUITARLES LOS SIGUIENTES CARACTERES PARA PODER QUE LA APP LA RESIVA EN LA ESTRUCTURA PERSONALIZADA QUE SE DECEE

	--SEGUNDO NIVEL DEL JSON
	SET @resp_JSON_Consolidada =  REPLACE( @JSON_RESULT_2,':"[{\',':[{\')						    --- INICIO DE LA CADENA DE CADA ARRAY		       :"[{\			->    :[{\									
	SET @resp_JSON_Consolidada =  REPLACE( @resp_JSON_Consolidada,'\"}]"','\"}]')				    --- FINAL DE LA CADENA CADA ARRAY HIJO             \"}]"			->    \"}]
	SET @resp_JSON_Consolidada =  REPLACE( @resp_JSON_Consolidada,'null}]","','null}],"')		    --- FINAL DE LA CADENA CADA ARRAY HIJO				null}]","		->   null}],"	
	SET @resp_JSON_Consolidada =  REPLACE( @resp_JSON_Consolidada,':\"\"}]","',':\"\"}],"')		    --- FINAL DE LA CADENA CADA ARRAY HIJO				:\"\"}]","		->   :\"\"}],"

	------------------------------------------
		-- RESPUESTA ENVIADA A LA APP --
	------------------------------------------

	SELECT @TOTAL_RECORDS AS TotalRecords, @PAGE AS Page, @SIZE AS SizePage 

	SELECT @resp_JSON_Consolidada AS JSON_RESULT_2;

END