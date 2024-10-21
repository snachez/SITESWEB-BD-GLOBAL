CREATE FUNCTION [dbo].[FN_VALIDACION_CONTRAINT_DESACTIVAR_tblDepartamento](@REACTIVAR BIT, @Id_Departamento INT )
RETURNS BIT
AS
BEGIN
	--
	-- VALIDA SI UN ROL, USUARIO, AREA TIENE RELACION Y ESTA ACTIVO PARA NO DESACTIVAR UN DEPARTAMENTO
	DECLARE @RESULT BIT = 1
	DECLARE @CANT INT 
	DECLARE @RELACION_AREA INT
	DECLARE @RELACION_ROL INT
	DECLARE @RELACION_USUARIO INT
	--
	IF @REACTIVAR = 0 

	BEGIN
	 
		SET @RELACION_AREA = (Select count(*) from tblArea where Fk_Id_Departamento = @Id_Departamento and Activo = 1) 
		SET @RELACION_ROL = (Select count(*) from tblRol where Fk_Id_Departamento = @Id_Departamento and Activo = 1) 
		SET @RELACION_USUARIO = (Select count(*) from tblUsuario U INNER JOIN tblRol R ON U.Fk_Id_Rol = R.Id where R.Fk_Id_Departamento = @Id_Departamento and U.Activo = 1) 

		SET @CANT = @RELACION_AREA + @RELACION_ROL + @RELACION_USUARIO

		SET @RESULT = IIF(@CANT > 0, 0, 1) 
	
	END
	--
    RETURN(@RESULT)
	--
END