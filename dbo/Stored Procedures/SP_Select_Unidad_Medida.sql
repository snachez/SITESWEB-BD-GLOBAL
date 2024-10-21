CREATE   PROCEDURE SP_Select_Unidad_Medida(
														  @JSON_IN VARCHAR(MAX),
														  @JSON_OUT  VARCHAR(MAX) OUTPUT
														, @USUARIO_ID INT = NULL
												 )
AS
BEGIN

  IF(@JSON_IN IS NOT NULL AND @JSON_IN <> '')
  BEGIN

	  SET @JSON_IN = REPLACE( @JSON_IN,'\','')

	  --DECLARACION DE VARIABLES PARA ACCEER A LAS PROPIEDADES Y VALORES QUE VIENEN DENTRO DEL JSON
	  DECLARE @p_Id_Unidad_Medida INT
	  DECLARE @p_Activo_Unidad_Medida BIT

	  --AUN NO ESTAN EN USO
	   
	  

	  --SETEANDO LOS VALORES DEL JSON (TABLA PADRE UNIDADES DE MEDIDAS)
	  SELECT @p_Id_Unidad_Medida = Id FROM OPENJSON( @JSON_IN) WITH ( Id INT )
	  SELECT @p_Activo_Unidad_Medida = Activo FROM OPENJSON( @JSON_IN) WITH ( Activo BIT )

	  DECLARE @resp_JSON_Tbl_Divisa NVARCHAR(MAX)
	  DECLARE @Resp_JSON_Tbl_Tipo_Efectivo NVARCHAR(MAX)
	  DECLARE @resp_JSON_Consolidada NVARCHAR(MAX)		
	  DECLARE @ROW NVARCHAR(MAX)

	  BEGIN TRY	
	 		
			--ACA SE PONEN LAS VALIDACIONES 
		 IF NOT EXISTS(SELECT 1 FROM tblUnidadMedida WHERE Id = @p_Id_Unidad_Medida)        
		 BEGIN   
				------------------------------ RESPUESTA A LA APP  ------------------------------------
				SELECT @resp_JSON_Consolidada = 
						(
							  SELECT	  @@ROWCOUNT												      AS ROWS_AFFECTED
							, CAST(0 AS BIT)														      AS SUCCESS
							, CONCAT(ERROR_MESSAGE() ,'Error, El nombre de la unidad no existe !')        AS ERROR_MESSAGE_SP
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
								   

				SELECT @resp_JSON_Tbl_Divisa = 
				(
					SELECT
								
					tblDivisa.Id,
					tblDivisa.Nombre,
					tblDivisa.Nomenclatura,
					tblDivisa.Simbolo,		
					tblDivisa.Descripcion,
					tblDivisa.Activo
					, dbo.FN_CastTimeZoneFormat(@IS_UTC, @CURRENT_TIME_ZONE, @TIME_ZONE_FORMAT, tblDivisa.FechaCreacion)			AS FechaCreacion
					, dbo.FN_CastTimeZoneFormat(@IS_UTC, @CURRENT_TIME_ZONE, @TIME_ZONE_FORMAT, tblDivisa.FechaModificacion)		AS FechaModificacion

					FROM tblUnidadMedida_x_Divisa
					INNER JOIN tblDivisa on tblUnidadMedida_x_Divisa.Fk_Id_Divisa = tblDivisa.Id	 
					WHERE tblUnidadMedida_x_Divisa.Fk_Id_Unidad_Medida = @p_Id_Unidad_Medida

					FOR JSON PATH, INCLUDE_NULL_VALUES
				)
				
				SELECT @Resp_JSON_Tbl_Tipo_Efectivo = 
				(
					SELECT
					
					tblTipoEfectivo.Id,
					tblTipoEfectivo.Nombre,								
					tblTipoEfectivo.Activo
					, dbo.FN_CastTimeZoneFormat(@IS_UTC, @CURRENT_TIME_ZONE, @TIME_ZONE_FORMAT, tblTipoEfectivo.FechaCreacion)			AS FechaCreacion
					, dbo.FN_CastTimeZoneFormat(@IS_UTC, @CURRENT_TIME_ZONE, @TIME_ZONE_FORMAT, tblTipoEfectivo.FechaModificacion)		AS FechaModificacion

					FROM tblUnidadMedida_x_TipoEfectivo
					INNER JOIN tblTipoEfectivo on tblUnidadMedida_x_TipoEfectivo.Fk_Id_Tipo_Efectivo = tblTipoEfectivo.Id	 
					WHERE tblUnidadMedida_x_TipoEfectivo.Fk_Id_Unidad_Medida = @p_Id_Unidad_Medida

					FOR JSON PATH, INCLUDE_NULL_VALUES
				)
			
				DECLARE @p_Tbl_Temp_Unidad_Medida TABLE   
				(  
					 Id INT
					,Nombre VARCHAR(MAX)
					,Simbolo VARCHAR(MAX)
					,Cantidad_Unidades INT
					,Activo BIT
					,Fecha_Creacion DATETIME
					,Fecha_Modificacion DATETIME
					,Divisa NVARCHAR(MAX)
					,Presentaciones_Habilitadas NVARCHAR(MAX)
				) 

				INSERT INTO @p_Tbl_Temp_Unidad_Medida	 
					SELECT
						tblUnidadMedida.Id,
						tblUnidadMedida.Nombre,		
						tblUnidadMedida.Simbolo,							
						tblUnidadMedida.Cantidad_Unidades,
						tblUnidadMedida.Activo
						, dbo.FN_CastTimeZoneFormat(@IS_UTC, @CURRENT_TIME_ZONE, @TIME_ZONE_FORMAT, tblUnidadMedida.Fecha_Creacion)			AS Fecha_Creacion
						, dbo.FN_CastTimeZoneFormat(@IS_UTC, @CURRENT_TIME_ZONE, @TIME_ZONE_FORMAT, tblUnidadMedida.Fecha_Modificacion)		AS Fecha_Modificacion

						, (SELECT @resp_JSON_Tbl_Divisa),--tblUnidadMedida.Divisa
						(SELECT @Resp_JSON_Tbl_Tipo_Efectivo)			--tblUnidadMedida.Presentaciones_Habilitadas										
					FROM tblUnidadMedida						
					WHERE tblUnidadMedida.Id = @p_Id_Unidad_Medida


				SELECT @ROW = (SELECT * FROM @p_Tbl_Temp_Unidad_Medida FOR JSON PATH, INCLUDE_NULL_VALUES)
					
				------------------------------ RESPUESTA A LA APP  ------------------------------------
					SELECT @resp_JSON_Consolidada = 
						(
							  SELECT	  @@ROWCOUNT									AS ROWS_AFFECTED
							, CAST(1 AS BIT)											AS SUCCESS
							, 'Unidad de medida obtenida con exito!'					AS ERROR_MESSAGE_SP
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
							, CONCAT(ERROR_MESSAGE() ,'Error, al intentar obtener la unidad de medida') AS ERROR_MESSAGE_SP
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