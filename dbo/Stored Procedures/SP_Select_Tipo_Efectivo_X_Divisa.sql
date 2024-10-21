---
CREATE   PROCEDURE usp_Select_Tipo_Efectivo_X_Divisa(	 
																  @JSON_IN VARCHAR(MAX),
																  @JSON_OUT  VARCHAR(MAX) OUTPUT
																, @USUARIO_ID INT = NULL
														  )
AS
BEGIN
	
 IF(@JSON_IN IS NOT NULL AND @JSON_IN != '')
  BEGIN

    SET @JSON_IN = REPLACE( @JSON_IN,'\','')

	 --DECLARACION DE VARIABLES PARA ACCEER A LAS PROPIEDADES Y VALORES QUE VIENEN DENTRO DEL JSON
    DECLARE @p_Id_Divisa INT
    DECLARE @p_Activo BIT

	--AUN NO ESTAN EN USO
	DECLARE @p_user_id INT 
	DECLARE @Action VARCHAR(1)

    --SETEANDO LOS VALORES DEL JSON
	SELECT @p_Id_Divisa = FK_ID_DIVISA FROM OPENJSON( @JSON_IN) WITH ( FK_ID_DIVISA INT )
	SELECT @p_Activo = ACTIVO FROM OPENJSON( @JSON_IN) WITH ( ACTIVO BIT )

	DECLARE @resp_JSON_Consolidada NVARCHAR(MAX)		
	DECLARE @ROW NVARCHAR(MAX)

	BEGIN TRY	

		--ACA SE PONEN LAS VALIDACIONES 
		 IF NOT EXISTS(SELECT 1 FROM tblDivisa_x_TipoEfectivo WHERE tblDivisa_x_TipoEfectivo.FkIdDivisa = @p_Id_Divisa ) BEGIN
				------------------------------ RESPUESTA A LA APP  ------------------------------------
				SELECT @resp_JSON_Consolidada = 
						(
							  SELECT	  @@ROWCOUNT																																AS ROWS_AFFECTED
							, CAST(0 AS BIT)																																		AS SUCCESS
							, CONCAT(ERROR_MESSAGE() ,'Error, El nombre de la divisa no existe, no se pudo obtener las presentaciones de efectivo, vinculadas a esta divisa !')     AS ERROR_MESSAGE_SP
							, ERROR_NUMBER()																																		AS ERROR_NUMBER_SP
							, NULL																																					AS ID
							, NULL																																					AS ROW 
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

				DECLARE @tbl_Temp_Divisa_X_Tipo_Efectivo TABLE   
				(  
				   --ID INT IDENTITY(1,1)
					 Id INT
					,Nombre VARCHAR(MAX)										
					,Activo BIT
					,FechaCreacion DATETIME
					,FechaModificacion DATETIME					
				) 

				INSERT INTO @tbl_Temp_Divisa_X_Tipo_Efectivo	 
					SELECT		
					 TE.Id                 
					,TE.Nombre								
					,TE.Activo
					, dbo.FN_CastTimeZoneFormat(@IS_UTC, @CURRENT_TIME_ZONE, @TIME_ZONE_FORMAT, TE.FechaCreacion)			AS FechaCreacion
					, dbo.FN_CastTimeZoneFormat(@IS_UTC, @CURRENT_TIME_ZONE, @TIME_ZONE_FORMAT, TE.FechaModificacion)		AS FechaModificacion
			
					FROM tblDivisa_x_TipoEfectivo DXT
					INNER JOIN tblTipoEfectivo TE on DXT.FkIdTipoEfectivo = TE.Id	 
					WHERE DXT.FkIdDivisa = ISNULL( @p_Id_Divisa, DxT.FkIdDivisa)
					AND DXT.Activo = ISNULL( @p_Activo, DxT.Activo)

				SELECT @ROW = (SELECT * FROM @tbl_Temp_Divisa_X_Tipo_Efectivo FOR JSON PATH, INCLUDE_NULL_VALUES)

				------------------------------ RESPUESTA A LA APP  ------------------------------------
					SELECT @resp_JSON_Consolidada = 
						(
							  SELECT	  @@ROWCOUNT									AS ROWS_AFFECTED
							, CAST(1 AS BIT)											AS SUCCESS
							, 'Presentaciones del efectivo obtenidas con exito!'		AS ERROR_MESSAGE_SP
							, NULL														AS ERROR_NUMBER_SP
							, NULL														AS ID
							, @ROW														AS ROW 
							FOR JSON PATH, INCLUDE_NULL_VALUES
						)
									
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
							  SELECT	  @@ROWCOUNT																AS ROWS_AFFECTED
							, CAST(0 AS BIT)																		AS SUCCESS
							, CONCAT(ERROR_MESSAGE() ,'Error, al intentar obtener las presentaciones del efectivo') AS ERROR_MESSAGE_SP
							, ERROR_NUMBER()																		AS ERROR_NUMBER_SP
							, NULL																					AS ID
							, NULL																					AS ROW 
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