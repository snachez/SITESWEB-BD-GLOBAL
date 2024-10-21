---
CREATE   PROCEDURE SP_Select_Transportadora(
														  @JSON_IN VARCHAR(MAX),
														  @JSON_OUT  VARCHAR(MAX) OUTPUT
														, @USUARIO_ID INT = NULL
												  )
AS
BEGIN

  IF(@JSON_IN IS NOT NULL AND @JSON_IN != '') BEGIN

	  SET @JSON_IN = REPLACE( @JSON_IN,'\','')

	  --DECLARACION DE VARIABLES PARA ACCEER A LAS PROPIEDADES Y VALORES QUE VIENEN DENTRO DEL JSON
	  DECLARE @p_Id_Transportadora INT
	  DECLARE @p_Activo_Transportadora BIT

	  --AUN NO ESTAN EN USO
	  DECLARE @p_user_id INT 
	  DECLARE @Action VARCHAR(1)

	  --SETEANDO LOS VALORES DEL JSON (TABLA PADRE DIVISAS)
	  SELECT @p_Id_Transportadora = Id FROM OPENJSON( @JSON_IN) WITH ( Id INT )
	  SELECT @p_Activo_Transportadora = Activo FROM OPENJSON( @JSON_IN) WITH ( Activo BIT )

	  DECLARE @Resp_JSON_Tbl_Pais NVARCHAR(MAX)
	  DECLARE @Resp_JSON_Tbl_Modulo NVARCHAR(MAX)

	  DECLARE @resp_JSON_Consolidada NVARCHAR(MAX)		
	  DECLARE @ROW NVARCHAR(MAX)

	  BEGIN TRY	
	 		
			--ACA SE PONEN LAS VALIDACIONES 
		 IF NOT EXISTS(SELECT 1 FROM tblTransportadoras WHERE Id = @p_Id_Transportadora)        
		 BEGIN   
				------------------------------ RESPUESTA A LA APP  ------------------------------------
				SELECT @resp_JSON_Consolidada = 
						(
							  SELECT	  @@ROWCOUNT														AS ROWS_AFFECTED
							, CAST(0 AS BIT)																AS SUCCESS
							, CONCAT(ERROR_MESSAGE() ,'Error, El nombre de la transportadora no existe !')  AS ERROR_MESSAGE_SP
							, ERROR_NUMBER()																AS ERROR_NUMBER_SP
							, NULL																			AS ID
							, NULL																			AS ROW 
							FOR JSON PATH, INCLUDE_NULL_VALUES
						)			
						
				SET @JSON_OUT = ( SELECT @resp_JSON_Consolidada  )	
				---------------------------------------------------------------------------------------\
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
				SELECT @Resp_JSON_Tbl_Pais = 
				(
					SELECT
					
						tblPais.Id,
						tblPais.Nombre,
						tblPais.Codigo,		
						tblPais.Activo
						, dbo.FN_CastTimeZoneFormat(@IS_UTC, @CURRENT_TIME_ZONE, @TIME_ZONE_FORMAT, tblPais.FechaCreacion)			AS FechaCreacion
						, dbo.FN_CastTimeZoneFormat(@IS_UTC, @CURRENT_TIME_ZONE, @TIME_ZONE_FORMAT, tblPais.FechaModificacion)		AS FechaModificacion
					
					FROM tblTransportadoras_x_Pais
					INNER JOIN tblPais on tblTransportadoras_x_Pais.Fk_Id_Pais = tblPais.Id	 
					WHERE tblTransportadoras_x_Pais.Fk_Id_Transportadora = @p_Id_Transportadora

					FOR JSON PATH, INCLUDE_NULL_VALUES
				)

				SELECT @Resp_JSON_Tbl_Modulo = 
				(
					SELECT
					
						tblModulo.Id,
						tblModulo.Nombre,						
						tblModulo.Activo,
						tblModulo.FechaCreacion,
						tblModulo.FechaModificacion
					
					FROM tblTransportadoras_x_Modulo
					INNER JOIN tblModulo on tblTransportadoras_x_Modulo.Fk_Id_Modulo = tblModulo.Id	 
					WHERE tblTransportadoras_x_Modulo.Fk_Id_Transportadora = @p_Id_Transportadora

					FOR JSON PATH, INCLUDE_NULL_VALUES
				)
			
				DECLARE @p_Tbl_Temp_Transportadora TABLE   
				(  
					 Id INT
					,Nombre VARCHAR(MAX)
					,Codigo VARCHAR(MAX)					
					,Activo BIT
					,Pais NVARCHAR(MAX)	
					,Modulo NVARCHAR(MAX)	
				) 

				INSERT INTO @p_Tbl_Temp_Transportadora	 

					SELECT
						 tblTransportadoras.Id
						,tblTransportadoras.Nombre
						,tblTransportadoras.Codigo						
						,tblTransportadoras.Activo
						,(SELECT @Resp_JSON_Tbl_Pais)	
						,(SELECT @Resp_JSON_Tbl_Modulo)	
					FROM tblTransportadoras					
					WHERE tblTransportadoras.Id = @p_Id_Transportadora


				SELECT @ROW = (SELECT * FROM @p_Tbl_Temp_Transportadora FOR JSON PATH, INCLUDE_NULL_VALUES)
					
				------------------------------ RESPUESTA A LA APP  ------------------------------------
					SELECT @resp_JSON_Consolidada = 
						(
							  SELECT	  @@ROWCOUNT									AS ROWS_AFFECTED
							, CAST(1 AS BIT)											AS SUCCESS
							, 'Transportadora obtenida con exito!'					    AS ERROR_MESSAGE_SP
							, NULL														AS ERROR_NUMBER_SP
							, NULL														AS ID
							, @ROW														AS ROW 
							FOR JSON PATH, INCLUDE_NULL_VALUES
						)
					
					SET @resp_JSON_Consolidada = REPLACE( @resp_JSON_Consolidada,'\\\','\') --COMO EL JSON SE SERIALIZA EN 3 OCACIONES A CAUSA DE LA CLAUSULA: FOR JSON PATH, HAY QUE ELIMINARLES LOS \\\ A LAS TABLAS HIJOS
					SET @resp_JSON_Consolidada = REPLACE( @resp_JSON_Consolidada,':\"[{\',':[{\') --HAY QUE ELIMINAR LOS CARACTERES  \" CUANDO SE HABRE LAS LLAVES EN EL INICIO DE LAS CADENAS DE ARRAYS DE LAS TABLAS HIJOS
					SET @resp_JSON_Consolidada = REPLACE( @resp_JSON_Consolidada,'}]\"','}]') --Y TAMBIEN HAY QUE ELIMINAR LOS CARACTERES  \"  CUANDO SE CIERRA LAS LLAVES EN LAS CADENAS DE ARRAYS DE LAS TABLAS HIJOS
					
					SET @JSON_OUT = ( SELECT @resp_JSON_Consolidada  )	
				--------------------------------------------------------------------------------------------

				  --FINAL
				 IF @@TRANCOUNT > 0
				 BEGIN
				   COMMIT TRANSACTION OBTENER
				 END		

	   END TRY    
	   BEGIN CATCH

					
				   ------------------------------ RESPUESTA A LA APP  ------------------------------------
						SELECT @resp_JSON_Consolidada = 
						(
							  SELECT	  @@ROWCOUNT												    AS ROWS_AFFECTED
							, CAST(0 AS BIT)														    AS SUCCESS
							, CONCAT(ERROR_MESSAGE() ,'Error, al intentar obtener la transportadora')	AS ERROR_MESSAGE_SP
							, ERROR_NUMBER()													        AS ERROR_NUMBER_SP
							, NULL																	    AS ID
							, NULL																	    AS ROW 
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
   END
   ELSE
   BEGIN 
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