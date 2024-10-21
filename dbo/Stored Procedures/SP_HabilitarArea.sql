CREATE   PROCEDURE [dbo].[SP_HabilitarArea](@ID INT, @ACTIVO BIT)
AS
BEGIN
	---Declaracion Variables
    DECLARE @MetodoTemporal VARCHAR(MAX) = 'SP_HabilitarArea';
	DECLARE @IdDato INT = -1;
	
	BEGIN TRY
		---
		UPDATE tblArea SET Activo = @ACTIVO, FechaModificacion = CURRENT_TIMESTAMP WHERE Id = @ID
		---
		DECLARE @ROW VARCHAR(MAX) = (SELECT     A.Id							AS [Id]
											  , A.Nombre						AS [Nombre]
												 --, A.Fk_Id_Departamento			AS [Fk_Id_Departamento]
											  , CONVERT(VARCHAR(36),NEWID())	AS [Codigo]
											  , A.Activo						AS [Activo]
											  , A.FechaCreacion				    AS [FechaCreacion]
											  , A.FechaModificacion			    AS [FechaModificacion]

											  , D.Id							AS [Departamento.Id]
											  , D.Nombre						AS [Departamento.Nombre]
											  , D.Activo						AS [Departamento.Activo]
											  , D.FechaCreacion				    AS [Departamento.FechaCreacion]
											  , D.FechaModificacion			    AS [Departamento.FechaModificacion]

										FROM tblArea A
										INNER JOIN tblDepartamento D
										ON A.Fk_Id_Departamento = D.Id WHERE A.Id = @ID FOR JSON PATH)

		SET @IdDato = CONVERT(INT, ISNULL(SCOPE_IDENTITY(), -1));
		---
		
		EXEC SP_Select_Mensajes_Emergentes_Para_SP 
		@ROWS_AFFECTED = @@ROWCOUNT,
		@SUCCESS = 1,
		@ERROR_NUMBER_SP = NULL,
		@CONSTRAINT_TRIGGER_NAME = NULL,
		@ID = @IdDato,
		@ROW = @ROW,
		@Metodo = @MetodoTemporal, 
		@TipoMensaje = 'Exitoso', 
		@ErrorMensaje = NULL,
		@ModeJson = 0;

		---
	END TRY    
	BEGIN CATCH
		--
		SET @ROW =						(SELECT    A.Id							AS [Id]
												 , A.Nombre						AS [Nombre]
												 --, A.Fk_Id_Departamento			AS [Fk_Id_Departamento]
												 , CONVERT(VARCHAR(36),NEWID())	AS [Codigo]
												 , A.Activo						AS [Activo]
												 , A.FechaCreacion				AS [FechaCreacion]
												 , A.FechaModificacion			AS [FechaModificacion]

												 , D.Id							AS [Departamento.Id]
												 , D.Nombre						AS [Departamento.Nombre]
												 , D.Activo						AS [Departamento.Activo]
												 , D.FechaCreacion				AS [Departamento.FechaCreacion]
												 , D.FechaModificacion			AS [Departamento.FechaModificacion]

										FROM tblArea A
										INNER JOIN tblDepartamento D
										ON A.Fk_Id_Departamento = D.Id WHERE A.Id = @ID FOR JSON PATH)
		--

		DECLARE @ERROR VARCHAR(MAX) = ERROR_MESSAGE();
		DECLARE @ERROR_NUMBER VARCHAR(MAX) = ERROR_NUMBER();

		EXEC SP_Select_Mensajes_Emergentes_Para_SP 
		@ROWS_AFFECTED = 0,
		@SUCCESS = 0,
		@ERROR_NUMBER_SP = @ERROR_NUMBER,
		@CONSTRAINT_TRIGGER_NAME = @ERROR,
		@ID = @IdDato,
		@ROW = NULL,
		@Metodo = @MetodoTemporal, 
		@TipoMensaje = 'Error', 
		@ErrorMensaje = @ERROR,
		@ModeJson = 0;

		--   
	END CATCH
	---
END
---