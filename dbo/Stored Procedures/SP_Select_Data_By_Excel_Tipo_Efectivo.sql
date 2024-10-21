CREATE   PROCEDURE SP_Select_Data_By_Excel_Tipo_Efectivo(
																	  @JSON_IN VARCHAR(MAX),
																	  @JSON_OUT VARCHAR(MAX) OUTPUT 
																	, @USUARIO_ID INT = NULL
															   )
AS
BEGIN

  IF(@JSON_IN IS NOT NULL AND @JSON_IN != '') BEGIN

	  SET @JSON_IN = REPLACE( @JSON_IN,'\','')

	  --DECLARACION DE VARIABLES PARA ACCEER A LAS PROPIEDADES Y VALORES QUE VIENEN DENTRO DEL JSON
	 
	  DECLARE @p_search			 VARCHAR(500)
	  DECLARE @p_activo			 INT  =	1
	  DECLARE @p_page			 INT  =	1
	  DECLARE @p_size			 INT  =	10
	  DECLARE @p_orden			 INT  = 1
	  DECLARE @p_Nombre_Archivo  VARCHAR(500)

	  --AUN NO ESTAN EN USO
	  DECLARE @p_user_id INT 
	  DECLARE @Action VARCHAR(1)

	  --SETEANDO LOS VALORES DEL JSON 
	  SELECT @p_search = SEARCH FROM OPENJSON( @JSON_IN) WITH (  SEARCH VARCHAR(500) )
	  SELECT @p_activo = ACTIVO FROM OPENJSON( @JSON_IN) WITH (  ACTIVO INT )
	  SELECT @p_page = PAGE FROM OPENJSON( @JSON_IN) WITH ( PAGE INT )
	  SELECT @p_size = SIZE  FROM OPENJSON( @JSON_IN) WITH (  SIZE INT )
	  SELECT @p_orden = ORDEN FROM OPENJSON( @JSON_IN) WITH (  ORDEN INT )
	  SELECT @p_Nombre_Archivo = NOMBRE_ARCHIVO FROM OPENJSON( @JSON_IN) WITH ( NOMBRE_ARCHIVO VARCHAR(500) )
	
	  SET @p_page  = ISNULL( @p_size, 1)
	  SET @p_size = ISNULL( @p_size, 10)
	  SET @p_orden = ISNULL( @p_orden, 1)

	  DECLARE @TOTAL_RECORDS INT = 0

	  DECLARE @JSON_RESULT_1 NVARCHAR(MAX) --NO ELIMINAR, NO SE ESTA UTILIZANDO PERO SIVER PARA DEBBUGEAR
	  DECLARE @JSON_RESULT_2 NVARCHAR(MAX)
	  DECLARE @resp_JSON_Consolidada NVARCHAR(MAX)	

	  BEGIN TRY	
	 		
			--ACA SE PONEN LAS VALIDACIONES 
		 IF NOT EXISTS(SELECT 1 FROM tblReportes WHERE Nombre = @p_Nombre_Archivo and Estado = 1)        
		 BEGIN   
				------------------------------ RESPUESTA A LA APP  ------------------------------------
				SELECT @resp_JSON_Consolidada = 
						(
							  SELECT	  @@ROWCOUNT												      AS ROWS_AFFECTED
							, CAST(0 AS BIT)														      AS SUCCESS
							, CONCAT(ERROR_MESSAGE() ,'Error, El nombre deL reporte no existe !')	      AS ERROR_MESSAGE_SP
							, ERROR_NUMBER()													          AS ERROR_NUMBER_SP
							, NULL																	      AS ID
							, NULL																	      AS ROW 
							FOR JSON PATH, INCLUDE_NULL_VALUES
						)			
						
				SET @JSON_OUT = ( SELECT @resp_JSON_Consolidada  )	
				---------------------------------------------------------------------------------------
			RETURN
		 END  

		 BEGIN TRANSACTION OBTENER
						
				----------------------------------------------------------------------------------------
				--- V A R I A B L E S		F O R M A T E O		F E C H A . . .
				----------------------------------------------------------------------------------------
				DECLARE @TIME_ZONE_FORMAT VARCHAR(90) = dbo.FN_GET_USER_ZONE_REGION_FORMAT(@USUARIO_ID)
				DECLARE @IS_UTC BIT = dbo.FN_IS_DB_UTC_ZONE_FORMAT()
				DECLARE @CURRENT_TIME_ZONE VARCHAR(100) = dbo.FN_DB_UTC_ZONE_FORMAT_NAME()
				----------------------------------------------------------------------------------------
				-----------------------------------------------------------------------------------------
													--FULL DATA--
				-----------------------------------------------------------------------------------------
						SELECT  --NO PONER UN TOP AQUI UNICAMENTE DE PRUEBA
								 T.Id					
								,T.Activo
								,T.Nombre
								, dbo.FN_CastTimeZoneFormat(@IS_UTC, @CURRENT_TIME_ZONE, @TIME_ZONE_FORMAT, T.FechaCreacion)			AS FechaCreacion
								, dbo.FN_CastTimeZoneFormat(@IS_UTC, @CURRENT_TIME_ZONE, @TIME_ZONE_FORMAT, T.FechaModificacion)		AS FechaModificacion
						INTO #tblFullData
						FROM tblTipoEfectivo T

				-----------------------------------------------------------------------------------------
													-- DATA INDEXADA & FILTRADA --
				-----------------------------------------------------------------------------------------
	
				;WITH DATA_INDEXED AS (				
								SELECT	  *
										, CASE 
													WHEN @p_orden = -1 THEN ROW_NUMBER() OVER(ORDER BY Id DESC)
													WHEN @p_orden =  1 THEN ROW_NUMBER() OVER(ORDER BY Id ASC)

													WHEN @p_orden = -2 THEN ROW_NUMBER() OVER(ORDER BY Activo DESC)
													WHEN @p_orden =  2 THEN ROW_NUMBER() OVER(ORDER BY Activo ASC)

													WHEN @p_orden = -3 THEN ROW_NUMBER() OVER(ORDER BY Nombre DESC)
													WHEN @p_orden =  3 THEN ROW_NUMBER() OVER(ORDER BY Nombre ASC)
												
													ELSE ROW_NUMBER() OVER(ORDER BY Id ASC)

												END
											AS [INDEX]
										FROM #tblFullData AS T	
										WHERE 	
										    T.Activo = (
											  CASE 
											  WHEN @p_search  = 'Activo' THEN 1
											  WHEN @p_search = 'Inactivo' THEN 0 END
											  )
										  OR T.Id LIKE CONCAT('%', ISNULL(@p_search, Id), '%') 
										  OR T.Nombre LIKE CONCAT('%', ISNULL(@p_search, Nombre), '%') 
										

						)

						--SE PASA LA DATA INDEXADA A UNA TABLA TEMPORAL
						SELECT * INTO #tmpTblDataIndexed FROM DATA_INDEXED ORDER BY [INDEX] 

						DROP TABLE #tblFullData 

						--- OBTIENE EL TOTAL DE FILAS PAGINADAS
					    SET @TOTAL_RECORDS = (SELECT COUNT(*) FROM #tmpTblDataIndexed)
		
						--- SE PASA LA DATA INDEXADA A UNA VARIABLE, YA EN FORMATO JSON														((@p_page * @p_size)-(@p_size-1)) AND  (@p_page * @p_size)
						SET @JSON_RESULT_2 = (SELECT T.Id, T.Activo, T.Nombre, T.FechaCreacion, T.FechaModificacion FROM #tmpTblDataIndexed AS T WHERE [INDEX] BETWEEN (1) AND (@TOTAL_RECORDS) ORDER BY [INDEX] FOR JSON PATH, INCLUDE_NULL_VALUES)						


						SELECT @TOTAL_RECORDS AS TotalRecords, @p_page AS Page,  @p_size AS SizePage 
	
						-----------------------------------------------------------------------------------------
													-- RESPUESTA A LA APP --
						-----------------------------------------------------------------------------------------
						
							SELECT @resp_JSON_Consolidada = 
								(
									  SELECT	  @@ROWCOUNT									AS ROWS_AFFECTED
									, CAST(1 AS BIT)											AS SUCCESS
									, 'Data del reporte obtenida con exito!'					AS ERROR_MESSAGE_SP
									, NULL														AS ERROR_NUMBER_SP
									, NULL														AS ID
									, @JSON_RESULT_2											AS ROW 
									FOR JSON PATH, INCLUDE_NULL_VALUES
								)											
					
							SET @JSON_OUT = ( SELECT @resp_JSON_Consolidada  )	
							--------------------------------------------------------------------------------------------
				

				  --FINAL
				 IF @@TRANCOUNT > 0
				 BEGIN
				   COMMIT TRANSACTION OBTENER
				 END		

	   END TRY BEGIN CATCH

					
				   ------------------------------ RESPUESTA A LA APP  ------------------------------------
						SELECT @resp_JSON_Consolidada = 
						(
							  SELECT	  @@ROWCOUNT														AS ROWS_AFFECTED
							, CAST(0 AS BIT)																AS SUCCESS
							, CONCAT(ERROR_MESSAGE() ,'Error, al intentar obtener la data del reporte')		AS ERROR_MESSAGE_SP
							, ERROR_NUMBER()																AS ERROR_NUMBER_SP
							, NULL																			AS ID
							, NULL																			AS ROW 
							FOR JSON PATH, INCLUDE_NULL_VALUES
						)						
						
						SET @JSON_OUT = ( SELECT @resp_JSON_Consolidada  )	
				   ---------------------------------------------------------------------------------------


			   IF @@TRANCOUNT > 0
			   BEGIN
				  ROLLBACK TRANSACTION OBTENER								
			   END	

	   END CATCH
	---
   END ELSE BEGIN 
				------------------------------ RESPUESTA A LA APP  ------------------------------------
						SELECT @resp_JSON_Consolidada = 
						(
							  SELECT	  @@ROWCOUNT												    AS ROWS_AFFECTED
							, CAST(0 AS BIT)														    AS SUCCESS
							, CONCAT(ERROR_MESSAGE() ,'Error, se resivio el JSON Vacio')                AS ERROR_MESSAGE_SP
							, ERROR_NUMBER()													        AS ERROR_NUMBER_SP
							, NULL																	    AS ID
							, NULL																	    AS ROW 
							FOR JSON PATH, INCLUDE_NULL_VALUES
						)
						
						SET @JSON_OUT = ( SELECT @resp_JSON_Consolidada  )
				---------------------------------------------------------------------------------------
   END
END