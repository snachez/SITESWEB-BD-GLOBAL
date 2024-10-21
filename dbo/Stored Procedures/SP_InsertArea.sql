CREATE   PROCEDURE [dbo].[SP_InsertArea] (@NOMBRE NVARCHAR(MAX), @FK_ID_DEPARTAMENTO INT, @ACTIVO BIT, @USUARIO_ID INT = NULL)
AS
BEGIN
	---Declaracion Variables
    DECLARE @MetodoTemporal NVARCHAR(MAX) = 'SP_InsertArea';
	DECLARE @IdDato INT = -1;
	
	BEGIN TRY
		---
		INSERT INTO tblArea(Nombre, Fk_Id_Departamento, Activo) VALUES(@NOMBRE, @FK_ID_DEPARTAMENTO, @ACTIVO)
		---
		----------------------------------------------------------------------------------------
		--- V A R I A B L E S		F O R M A T E O		F E C H A . . .
		----------------------------------------------------------------------------------------
		DECLARE @TIME_ZONE_FORMAT VARCHAR(90) = dbo.FN_GET_USER_ZONE_REGION_FORMAT(@USUARIO_ID)
		DECLARE @IS_UTC BIT = dbo.FN_IS_DB_UTC_ZONE_FORMAT()
		DECLARE @CURRENT_TIME_ZONE VARCHAR(100) = dbo.FN_DB_UTC_ZONE_FORMAT_NAME()
		----------------------------------------------------------------------------------------
		DECLARE @ROW NVARCHAR(MAX) = (SELECT	   A.Id							AS [Id]
												 , A.Nombre						AS [Nombre]
												 , CONVERT(VARCHAR(36),NEWID())	AS [Codigo]
												 , A.Activo						AS [Activo]
												 , dbo.FN_CastTimeZoneFormat(@IS_UTC, @CURRENT_TIME_ZONE, @TIME_ZONE_FORMAT, A.FechaCreacion)		AS [FechaCreacion]
												 , dbo.FN_CastTimeZoneFormat(@IS_UTC, @CURRENT_TIME_ZONE, @TIME_ZONE_FORMAT, A.FechaModificacion)	AS [FechaModificacion]

												 , D.Id							AS [Departamento.Id]
												 , D.Nombre						AS [Departamento.Nombre]
												 , D.Activo						AS [Departamento.Activo]
												 , dbo.FN_CastTimeZoneFormat(@IS_UTC, @CURRENT_TIME_ZONE, @TIME_ZONE_FORMAT, D.FechaCreacion)		AS [Departamento.FechaCreacion]
												 , dbo.FN_CastTimeZoneFormat(@IS_UTC, @CURRENT_TIME_ZONE, @TIME_ZONE_FORMAT, D.FechaModificacion)	AS [Departamento.FechaModificacion]


												, ROW_NUMBER() OVER(ORDER BY A.Nombre) AS [INDEX]

										FROM tblArea A
										INNER JOIN tblDepartamento D
										ON A.Fk_Id_Departamento = D.Id WHERE A.Id = ISNULL(SCOPE_IDENTITY(), -1) FOR JSON PATH)

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
		DECLARE @ERROR NVARCHAR(MAX) = ERROR_MESSAGE();
		DECLARE @ERROR_NUMBER NVARCHAR(MAX) = ERROR_NUMBER();

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
GO

