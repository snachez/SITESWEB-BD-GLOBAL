---
CREATE   PROCEDURE [dbo].[SP_InsertDenominaciones_x_Modulo] (	  
																  @FK_ID_DENOMINACIONES	INT,
																  @FK_ID_Modulo			INT,
																  @ACTIVO BIT
																, @USUARIO_ID INT = NULL
														  )
AS
BEGIN
	---
	BEGIN TRY
		---
		INSERT INTO tblDenominaciones_x_Modulo(FkIdDenominaciones, FkIdModulo, Activo) VALUES (@FK_ID_DENOMINACIONES, @FK_ID_Modulo,@ACTIVO)
		---
		----------------------------------------------------------------------------------------
		--- V A R I A B L E S		F O R M A T E O		F E C H A . . .
		----------------------------------------------------------------------------------------
		DECLARE @TIME_ZONE_FORMAT VARCHAR(90) = dbo.FN_GET_USER_ZONE_REGION_FORMAT(@USUARIO_ID)
		DECLARE @IS_UTC BIT = dbo.FN_IS_DB_UTC_ZONE_FORMAT()
		DECLARE @CURRENT_TIME_ZONE VARCHAR(100) = dbo.FN_DB_UTC_ZONE_FORMAT_NAME()
		----------------------------------------------------------------------------------------
		DECLARE @ROW NVARCHAR(MAX) = (SELECT   DxA.Id AS [Id]												
											
												, dbo.FN_CastTimeZoneFormat(@IS_UTC, @CURRENT_TIME_ZONE, @TIME_ZONE_FORMAT, DxA.FechaCreacion)			AS [FechaCreacion]
												, dbo.FN_CastTimeZoneFormat(@IS_UTC, @CURRENT_TIME_ZONE, @TIME_ZONE_FORMAT, DxA.FechaModificacion)		AS [FechaModificacion]

												, DxA.Activo					 AS [Activo]

												, D.Id							 AS [Denominaciones.Id]
												, D.Nombre						 AS [Denominaciones.Nombre]
												, D.ValorNominal				 AS [Denominaciones.ValorNominal]
												, D.IdDivisa					 AS [Denominaciones.IdDivisa]												
												, D.BMO							 AS [Denominaciones.BMO]
												, D.Imagen						 AS [Denominaciones.Imagen]
												, D.Activo						 AS [Denominaciones.Activo]
												, dbo.FN_CastTimeZoneFormat(@IS_UTC, @CURRENT_TIME_ZONE, @TIME_ZONE_FORMAT, D.FechaCreacion)			AS [Denominaciones.FechaCreacion]
												, dbo.FN_CastTimeZoneFormat(@IS_UTC, @CURRENT_TIME_ZONE, @TIME_ZONE_FORMAT, D.FechaModificacion)		AS [Denominaciones.FechaModificacion]

												, A.Id							 AS [Modulo.Id]
												, A.Nombre						 AS [Modulo.Nombre]
												, dbo.FN_CastTimeZoneFormat(@IS_UTC, @CURRENT_TIME_ZONE, @TIME_ZONE_FORMAT, A.FechaCreacion)			AS [Modulo.FechaCreacion]
												, dbo.FN_CastTimeZoneFormat(@IS_UTC, @CURRENT_TIME_ZONE, @TIME_ZONE_FORMAT, A.FechaModificacion)		AS [Modulo.FechaModificacion]

										FROM tblDenominaciones_x_Modulo DxA
										INNER JOIN tblDenominaciones D
										ON DxA.FkIdDenominaciones = D.Id
										INNER JOIN tblModulo A
										ON DxA.FkIdModulo = A.Id								
										WHERE DxA.Id = ISNULL(SCOPE_IDENTITY(), -1)
										FOR JSON PATH)
		---
		SELECT	  @@ROWCOUNT												AS ROWS_AFFECTED
				, CAST(1 AS BIT)											AS SUCCESS
				, ''														AS ERROR_MESSAGE_SP
				, NULL														AS ERROR_NUMBER_SP
				, CONVERT(INT, ISNULL(SCOPE_IDENTITY(), -1))				AS ID
				, @ROW														AS ROW
		---
	END TRY    
	BEGIN CATCH
	    --
		DECLARE @ERROR_MESSAGE NVARCHAR(MAX) = ERROR_MESSAGE();
		DECLARE @ERROR_MESSAGE1 NVARCHAR(MAX) = '%Unique_denominacion_x_area%';
		--
		IF @ERROR_MESSAGE LIKE @ERROR_MESSAGE1 BEGIN 
			---
			SET @ERROR_MESSAGE = 'La combinacion de denominacion y area ya esta registrada'
			---
		END
		--
		SELECT	  CAST(0 AS BIT)											AS SUCCESS
				, @ERROR_MESSAGE											AS ERROR_MESSAGE_SP
				, ERROR_NUMBER()											AS ERROR_NUMBER_SP
				, 0															AS ROWS_AFFECTED
				, -1														AS ID
				, NULL														AS ROW

		--   
	END CATCH
	---
END
---
GO

