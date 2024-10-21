CREATE   PROCEDURE [dbo].[SP_Select_All_Messages_By_Modulo](
	@JSON_IN VARCHAR(MAX) = NULL,
	@JSON_OUT VARCHAR(MAX) OUTPUT 
)
AS
BEGIN

  DECLARE @resp_JSON_Consolidada VARCHAR(MAX)		
  DECLARE @Resp_1 VARCHAR(MAX)

  IF(@JSON_IN IS NOT NULL AND @JSON_IN <> '' AND ISJSON(@JSON_IN) = 1)
  BEGIN

	  SET @JSON_IN = REPLACE( @JSON_IN,'\','')

	  --DECLARACION DE VARIABLES PARA ACCEER A LAS PROPIEDADES Y VALORES QUE VIENEN DENTRO DEL JSON
	  DECLARE @p_Nombre_Modulo VARCHAR(MAX) 
	  DECLARE @ROWS VARCHAR(MAX)

	  SELECT @p_Nombre_Modulo = Nombre FROM OPENJSON( @JSON_IN) WITH ( Nombre VARCHAR(MAX) )

	  --SE VALIDA QUE EXISTA EL MODULO 
	  IF NOT EXISTS(SELECT 1 FROM tblMensajes_Emergentes_Modulo WHERE Modulo = @p_Nombre_Modulo)        
	  BEGIN   
			------------------------------ RESPUESTA A LA APP  ------------------------------------
				SELECT @resp_JSON_Consolidada = 
						(
								  SELECT	  @@ROWCOUNT																				AS ROWS_AFFECTED
								, CAST(0 AS BIT)																						AS SUCCESS
								, 'Ocurrió un problema!'																				AS ERROR_TITLE_SP
								, CONCAT(ERROR_MESSAGE() ,'El nombre del modulo no existe, por lo que no se pudieron obtener todos los mensajes del modulo solicitado para poder insertar, modificar e eliminar registros!')	AS ERROR_MESSAGE_SP
								, ERROR_NUMBER()																						AS ERROR_NUMBER_SP
								, NULL																									AS ID
								, NULL																									AS ROW 
								FOR JSON PATH, INCLUDE_NULL_VALUES
						)			
					
				SET @JSON_OUT = ( SELECT @resp_JSON_Consolidada  )	
			---------------------------------------------------------------------------------------

	           
	  END  

	  BEGIN TRY	
	 
		 BEGIN TRANSACTION OBTENER
				
				SELECT @ROWS = (

						SELECT
						   TM.Id AS Id_Tipo_Mensaje
						 , TM.TipoMensaje
						 , MET.Id AS Id_Metodo
						 , MET.Metodo
						 , T.Id AS Id_Titulo
						 , T.Titulo
						 , ME.Id AS Id_Mensaje
						 , ME.Mensaje
						 , ME.ErrorMensaje
						FROM tblMensajes_Emergentes ME
						INNER JOIN tblMensajes_Emergentes_Metodo MET
						  ON ME.Fk_Metodo = MET.Id
						INNER JOIN tblMensajes_Emergentes_Modulo MO
						  ON ME.Fk_Modulo = MO.Id
						INNER JOIN tblMensajes_Emergentes_Tipo_Mensaje TM
						  ON ME.Fk_TipoMensaje = TM.Id
						INNER JOIN tblMensajes_Emergentes_Titulo T
						  ON ME.Fk_Titulo = T.Id
						WHERE 
						(
							 MO.Modulo = ISNULL(@p_Nombre_Modulo, MO.Modulo)
						)
						FOR JSON PATH, INCLUDE_NULL_VALUES
				)

				------------------------------ RESPUESTA A LA APP  ------------------------------------
					SELECT @Resp_1 = 
						(
							  SELECT	  @@ROWCOUNT									AS ROWS_AFFECTED
							, CAST(1 AS BIT)											AS SUCCESS
						    , 'Exitoso'													AS ERROR_TITLE_SP
							, 'Mensajes obtenidos con exito!'							AS ERROR_MESSAGE_SP
							, NULL														AS ERROR_NUMBER_SP
							, NULL														AS ID
							, @ROWS														AS ROW 
							FOR JSON PATH, INCLUDE_NULL_VALUES
						)
				
					SET @resp_JSON_Consolidada =  REPLACE( @Resp_1,':"[{\',':[{\')									--- INICIO DE LA CADENA DE CADA ARRAY		       :"[{\			->    :[{\									
					SET @resp_JSON_Consolidada =  REPLACE( @resp_JSON_Consolidada,'\"}]"','\"}]')				    --- FINAL DE LA CADENA CADA ARRAY HIJO             \"}]"			->    \"}]
					SET @resp_JSON_Consolidada =  REPLACE( @resp_JSON_Consolidada,'null}]","','null}],"')		    --- FINAL DE LA CADENA CADA ARRAY HIJO				null}]","		->   null}],"	
					SET @resp_JSON_Consolidada =  REPLACE( @resp_JSON_Consolidada,':\"\"}]","',':\"\"}],"')		    --- FINAL DE LA CADENA CADA ARRAY HIJO				:\"\"}]","		->   :\"\"}],"
					SET @resp_JSON_Consolidada =  REPLACE( @resp_JSON_Consolidada,'null}]"}]','null}]}]')		    --- FINAL DE LA CADENA CADA ARRAY HIJO				null}]"}]		->   null}]}]

				    SET @resp_JSON_Consolidada =  REPLACE( @resp_JSON_Consolidada,'\','')							--- SUSTITUIR TODAS LAS BARRAS						\				->    ''VACIO''

					SET @JSON_OUT = ( SELECT @resp_JSON_Consolidada  )	
				--------------------------------------------------------------------------------------------

		    --FINAL
			IF @@TRANCOUNT > 0
			BEGIN
			  COMMIT TRANSACTION OBTENER
			END		

	  END TRY    
	  BEGIN CATCH				

				------------------------------ RESPUESTA A LA APP ------------------------------------
					SELECT @resp_JSON_Consolidada = 
							(
								  SELECT	  @@ROWCOUNT																				AS ROWS_AFFECTED
								, CAST(0 AS BIT)																						AS SUCCESS
								, 'Ocurrió un problema!'																				AS ERROR_TITLE_SP
								, CONCAT(ERROR_MESSAGE() ,'No se pudieron obtener todos los mensajes del modulo solicitado, para poder insertar, modificar e eliminar registros!')    AS ERROR_MESSAGE_SP
								, ERROR_NUMBER()																						AS ERROR_NUMBER_SP
								, NULL																									AS ID
								, NULL																									AS ROW 
								FOR JSON PATH, INCLUDE_NULL_VALUES
							)					
				
					SET @JSON_OUT = ( SELECT @resp_JSON_Consolidada  )	
				-------------------------------------------------------------------------------------	   

			   IF @@TRANCOUNT > 0
			   BEGIN			   
					ROLLBACK TRANSACTION OBTENER							 																					
			   END	

	  END CATCH
	   
	---
  END
  ELSE
  BEGIN 
				------------------------------ RESPUESTA A LA APP O A LA BD  ---------------------------
						SELECT @resp_JSON_Consolidada = 
						(
							  SELECT	  @@ROWCOUNT												    AS ROWS_AFFECTED
							, CAST(0 AS BIT)														    AS SUCCESS
							, 'Error'																	AS ERROR_TITLE_SP
							, CONCAT(ERROR_MESSAGE() ,'Error, se resivio el JSON Vacio')                AS ERROR_MESSAGE_SP
							, ERROR_NUMBER()													        AS ERROR_NUMBER_SP
							, NULL																	    AS ID
							, NULL																	    AS ROW 
							FOR JSON PATH, INCLUDE_NULL_VALUES
						)				
						
						SET @JSON_OUT = ( SELECT @resp_JSON_Consolidada  )	
				----------------------------------------------------------------------------------------	  
	   	 				
  END

  
END