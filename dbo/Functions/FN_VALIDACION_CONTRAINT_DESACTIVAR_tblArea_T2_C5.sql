CREATE   FUNCTION [dbo].[FN_VALIDACION_CONTRAINT_DESACTIVAR_tblArea_T2_C5](@REACTIVAR BIT, @ID INT )
RETURNS BIT
AS
BEGIN
	--
	-- askdfljalksdjflkajsd
	DECLARE @RESULT BIT = 1
	DECLARE @CANT INT 
	DECLARE @RELACION_ROL INT
	DECLARE @RELACION_USUARIO INT
	--
		IF @REACTIVAR = 0 BEGIN
		--

			SET @RELACION_ROL = (Select count(*) From tblRol R
							 where R.Activo = 1 AND R.Fk_Id_Area = @ID)

			SET @RELACION_USUARIO = (Select count(*) From tblUsuario U
							                  Inner Join  tblRol R on U.Fk_Id_Rol = R.Id
						                                  where U.Activo = 1 AND R.Fk_Id_Area = @ID)
			

		SET @CANT = @RELACION_ROL + @RELACION_USUARIO

		SET @RESULT = IIF(@CANT > 0, 0, 1) 
	
		--
	END
	--
    RETURN(@RESULT)
	--
END