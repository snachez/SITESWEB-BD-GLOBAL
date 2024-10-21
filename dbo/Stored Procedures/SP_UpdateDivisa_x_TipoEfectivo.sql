CREATE PROCEDURE [dbo].[SP_UpdateDivisa_x_TipoEfectivo] 
(
@FK_ID_DIVISA    INT,
@FK_ID_TIPOEFECTIVO INT, 
@ACTIVO	BIT
)
AS
BEGIN
	---
	BEGIN TRY
		---
		UPDATE tblDivisa_x_TipoEfectivo SET 
	    Activo = @ACTIVO, FechaModificacion = CURRENT_TIMESTAMP 
		WHERE FkIdDivisa  = @FK_ID_DIVISA AND FkIdTipoEfectivo = @FK_ID_TIPOEFECTIVO
		---
		DECLARE @ROW VARCHAR(MAX) = (SELECT        DxT.Id						AS [Id]											
												  , DxT.Activo					AS [Activo]
												  , DxT.FechaCreacion			AS [FechaCreacion]
												  , DxT.FechaModificacion		AS [FechaModificacion]

												  , DI.Id						AS [Divisa.Id]
												  , DI.Nombre					AS [Divisa.Nombre]
												  , DI.Nomenclatura			    AS [Divisa.Nomenclatura]
												  , DI.Simbolo					AS [Divisa.Simbolo]
												  , DI.Descripcion				AS [Divisa.Descripcion]
												  , DI.Activo					AS [Divisa.Activo]
												  , DI.FechaCreacion			AS [Divisa.FechaCreacion]
												  , DI.FechaModificacion		AS [Divisa.FechaModificacion]

												  ,TE.[Id]					        AS [TipoEfectivo.Id]
												  ,TE.[Nombre]                     AS [TipoEfectivo.Nombre]
												  ,TE.[Activo]                     AS [TipoEfectivo.Activo]
												  ,TE.[FechaCreacion]              AS [TipoEfectivo.FechaCreacion]
												  ,TE.[FechaModificacion]          AS [TipoEfectivo.FechaModificacion]
								
										FROM tblDivisa_x_TipoEfectivo DxT
										INNER JOIN tblDivisa DI
										ON DxT.FkIdDivisa = DI.Id
										INNER JOIN tblTipoEfectivo TE
										ON DxT.FkIdTipoEfectivo = TE.Id
										WHERE DxT.FkIdDivisa = @FK_ID_DIVISA
										AND DxT.FkIdTipoEfectivo = @FK_ID_TIPOEFECTIVO FOR JSON PATH)
		---
		SELECT	  @@ROWCOUNT												  AS ROWS_AFFECTED
				, CAST(1 AS BIT)											  AS SUCCESS
				, 'Se modifico satisfactoriamente la Divisa_x_TipoEfectivo!'  AS ERROR_MESSAGE_SP
				, NULL														  AS ERROR_NUMBER_SP
				, CONVERT(INT, ISNULL(SCOPE_IDENTITY(), -1))				  AS ID
				, @ROW														  AS ROW
		---
	END TRY    
	BEGIN CATCH
		--
		SELECT	  0															AS ROWS_AFFECTED
		        , CAST(0 AS BIT)											AS SUCCESS
				, ERROR_MESSAGE()											AS ERROR_MESSAGE_SP
				, ERROR_NUMBER()											AS ERROR_NUMBER_SP
				, -1														AS ID
				, NULL														AS ROW

		--   
	END CATCH
	---
END
---