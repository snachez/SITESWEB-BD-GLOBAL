CREATE   PROCEDURE [dbo].[SP_UpdateArea] (@ID INT, @NOMBRE VARCHAR(MAX) = NULL, @FK_ID_DEPARTAMENTO INT = NULL, @ACTIVO BIT = NULL)
AS
BEGIN
	---Declaracion Variables
    DECLARE @MetodoTemporal VARCHAR(MAX) = 'SP_UpdateArea';
	DECLARE @IdDato INT = -1;
	
	BEGIN TRY
		---
		UPDATE tblArea SET Nombre = ISNULL(@NOMBRE, Nombre), Fk_Id_Departamento = ISNULL(@FK_ID_DEPARTAMENTO, Fk_Id_Departamento), Activo = ISNULL(@ACTIVO, Activo) WHERE Id = @ID
		---

		-- PARA UPDATE DE ROL CUANDO SE ACTUALIZA AREA
				-- Definir la consulta que se ejecutará en la base de datos remota
				DECLARE @remote_sql2 NVARCHAR(MAX);
				DECLARE @NombreBaseDatos NVARCHAR(50);

				SET @remote_sql2 = N'UPDATE tblRol 
				     SET Fk_Id_Departamento = ISNULL(@FK_ID_DEPARTAMENTO, Fk_Id_Departamento) WHERE Fk_Id_Area = @ID';

                IF (DB_NAME() = 'sitesw-Global') BEGIN
                    SET @NombreBaseDatos = N'sitesw-Identity';
                END
                ELSE BEGIN
                    SET @NombreBaseDatos = N'sitesw-Identitystg';
                END

                -- Ejecutar la consulta en la base de datos remota Sites.Pedidos a través del servidor vinculado
                EXEC sp_execute_remote 
                @data_source = @NombreBaseDatos, -- Nombre del servidor vinculado
                @stmt = @remote_sql2, 
                @params = N'@FK_ID_DEPARTAMENTO INT, @ID INT', 
                @FK_ID_DEPARTAMENTO = @FK_ID_DEPARTAMENTO, -- Reemplaza con el valor correspondiente
                @ID = @ID; -- Reemplaza con el JSON correspondiente

		DECLARE @ROW VARCHAR(MAX) = (SELECT       A.Id							AS [Id]
												 , A.Nombre						AS [Nombre]
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