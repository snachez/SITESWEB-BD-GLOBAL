CREATE PROCEDURE [dbo].[SP_ValidarFirmaRelaciones](
	@JSON_IN VARCHAR(MAX) = NULL,
	@JSON_OUT  VARCHAR(MAX) OUTPUT 
)
AS
BEGIN

  IF(@JSON_IN IS NOT NULL AND @JSON_IN != '')
  BEGIN

	  SET @JSON_IN = REPLACE( @JSON_IN,'\','');

	  --DECLARACION DE VARIABLES PARA ACCEER A LAS PROPIEDADES Y VALORES QUE VIENEN DENTRO DEL JSON
	  DECLARE @p_Id_Insert_Matriz_Atribucion INT ;

	  --------------------------- DECLARACION DE TABLA PARA INSERTAR LOS REGISTROS DE FIRMAS (TABLA HIJO) ----------------------------------------
	  DECLARE @p_Tbl_Temp_Firmas_Insert TABLE   
	  (  
		  ID INT IDENTITY(1,1)
		 ,Firma VARCHAR(MAX)
		 ,MontoDesde DECIMAL(38,2)	
		 ,MontoHasta DECIMAL(38,2)	
	  );  

	  --INSERTA CADA UNO DE LOS ITEMS DE LAS FIRMAS
		INSERT INTO @p_Tbl_Temp_Firmas_Insert	 
		SELECT 
		       Firma
		      ,MontoDesde
		      ,MontoHasta
		FROM OPENJSON (@JSON_IN)
		WITH (firmas_DTO NVARCHAR(MAX) AS JSON)
	    CROSS APPLY OPENJSON (firmas_DTO) 
		WITH 
		(
		   Firma      VARCHAR(MAX)
          ,MontoDesde DECIMAL(38,2)
		  ,MontoHasta DECIMAL(38,2)
		)

	  --DECLARACION DE VARIABLES PARA RECORRER LA TABLA TEMPORAL FIRMAS
	  DECLARE @p_Firma_Firma_Iterador VARCHAR(MAX);
	  DECLARE @p_MontoDesde_Firma_Iterador DECIMAL(38,2);
	  DECLARE @p_MontoHasta_Firma_Iterador DECIMAL(38,2);

	  --VARIABLES PARA DAR RESPUESTA
	  DECLARE @Id_Matriz_Por_Firma_Insertada INT;

	  DECLARE @Resp_1 VARCHAR(MAX);
	  DECLARE @Resp_2 VARCHAR(MAX);
	  DECLARE @ROW VARCHAR(MAX);

	  BEGIN TRY	
	 
		 BEGIN TRANSACTION INSERTAR
						
					BEGIN   

						------------------------------ INICIO DEL RECORRIDO Y SETEO DE DATA DE LA TABLA TEMPORAL FIRMAS  ------------------------------------

						DECLARE @iter INT = 1;
						DECLARE @Suma_Firmas_Relaciones INT = 0;
						DECLARE @Contador_Firmas_Relaciones INT = 0;
						DECLARE @Conta INT = (SELECT COUNT(1) FROM  @p_Tbl_Temp_Firmas_Insert	 )

						IF @Conta > 0 WHILE (@iter <= (SELECT MAX(ID) FROM @p_Tbl_Temp_Firmas_Insert	 ))
						BEGIN

							--OBTIENE UN ITEM
							SELECT 								
							 @p_Firma_Firma_Iterador = Firma
							,@p_MontoDesde_Firma_Iterador = MontoDesde
							,@p_MontoHasta_Firma_Iterador = MontoHasta
							FROM @p_Tbl_Temp_Firmas_Insert 
							WHERE ID = @iter
						
						    SELECT @Contador_Firmas_Relaciones = COUNT(*) FROM tblFirmas F
							INNER JOIN [tblFirmasUsuario] FU
							ON F.Id = FU.FK_Id_Firma
							WHERE F.Firma = @p_Firma_Firma_Iterador 
							AND F.MontoDesde = @p_MontoDesde_Firma_Iterador 
							AND F.MontoHasta = @p_MontoHasta_Firma_Iterador
			    			
							SET @Suma_Firmas_Relaciones = @Contador_Firmas_Relaciones + @Suma_Firmas_Relaciones;
							SET @iter = @iter + 1
						END --FIN DEL CICLO

					END

					IF(@Suma_Firmas_Relaciones != 0)
					BEGIN
					------------------------------ RESPUESTA A LA APP  ------------------------------------
						SELECT @Resp_1 = 
						(
							  SELECT	  @@ROWCOUNT									AS ROWS_AFFECTED
							, CAST(1 AS BIT)											AS SUCCESS
							, 'La firma que desea eliminar presenta usuarios activos o inactivos ligados, debe desligar esos usuarios para poder efectuar esta acción'					AS ERROR_MESSAGE_SP
							, NULL														AS ERROR_NUMBER_SP
							, NULL						                                AS ID
							, NULL														AS ROW 
							FOR JSON PATH, INCLUDE_NULL_VALUES
						)

						SELECT @Resp_2 = 
						( 
							SELECT CAST(@Resp_1 AS VARCHAR(MAX)) 
						)
						
						SET @JSON_OUT = ( SELECT @Resp_2  )	
				    ---------------------------------------------------------------------------------------
					END
					ELSE
					BEGIN
					------------------------------ RESPUESTA A LA APP  ------------------------------------
						SELECT @Resp_1 = 
						(
							  SELECT	  @@ROWCOUNT									AS ROWS_AFFECTED
							, CAST(1 AS BIT)											AS SUCCESS
							, ''					                                    AS ERROR_MESSAGE_SP
							, NULL														AS ERROR_NUMBER_SP
							, NULL								                        AS ID
							, NULL														AS ROW 
							FOR JSON PATH, INCLUDE_NULL_VALUES
						)

						SELECT @Resp_2 = 
						( 
							SELECT CAST(@Resp_1 AS VARCHAR(MAX)) 
						)
						
						SET @JSON_OUT = ( SELECT @Resp_2  )	
				    ---------------------------------------------------------------------------------------
                   END
				  --FINAL
				 IF @@TRANCOUNT > 0
				 BEGIN
				   COMMIT TRANSACTION INSERTAR
				 END		

	  END TRY    
	  BEGIN CATCH
		--
					
				   ------------------------------ RESPUESTA A LA APP  ------------------------------------
						SELECT @Resp_1 = 
						(
							  SELECT	  @@ROWCOUNT												    AS ROWS_AFFECTED
							, CAST(0 AS BIT)														    AS SUCCESS
							, CONCAT(ERROR_MESSAGE(), 'Error, no se pudo validar la firma')             AS ERROR_MESSAGE_SP
							, ERROR_NUMBER()													        AS ERROR_NUMBER_SP
							, NULL																	    AS ID
							, NULL																	    AS ROW 
							FOR JSON PATH, INCLUDE_NULL_VALUES
						)

						SELECT @Resp_2 = 
						( 
							SELECT CAST(@Resp_1 AS VARCHAR(MAX)) 
						)
						
						SET @JSON_OUT = ( SELECT @Resp_2  )	
				   -----------------------------------------------------------------------------------------


			   IF @@TRANCOUNT > 0
			   BEGIN
				  ROLLBACK TRANSACTION INSERTAR								
			   END	

	  END CATCH
	  GOTO FINALIZAR 
	---
  END
  ELSE
  BEGIN 
				 ------------------------------ RESPUESTA A LA APP  ------------------------------------
						SELECT @Resp_1 = 
						(
							  SELECT	  @@ROWCOUNT												    AS ROWS_AFFECTED
							, CAST(0 AS BIT)														    AS SUCCESS
							, CONCAT(ERROR_MESSAGE() ,'Error, se obtuvo el JSON Vacio')                 AS ERROR_MESSAGE_SP
							, ERROR_NUMBER()													        AS ERROR_NUMBER_SP
							, NULL																	    AS ID
							, NULL																	    AS ROW 
							FOR JSON PATH, INCLUDE_NULL_VALUES
						)

						SELECT @Resp_2 = 
						( 
							SELECT CAST(@Resp_1 AS VARCHAR(MAX)) 
						)
						
						SET @JSON_OUT = ( SELECT @Resp_2  )	
				----------------------------------------------------------------------------------------
	  
	  GOTO FINALIZAR 	 				
  END

  FINALIZAR:RETURN
END