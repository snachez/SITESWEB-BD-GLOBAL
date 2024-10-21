CREATE FUNCTION [dbo].[FN_VALIDACION_CONTRAINT_DESACTIVAR_tblAgenciaBancaria](@REACTIVAR BIT, @Id_AgenciaBancaria INT )
RETURNS BIT
AS
BEGIN
	--
	-- VALIDA SI TIENE RELACION Y ESTA ACTIVA PARA NO DESACTIVAR UNA AGENCIA
	DECLARE @RESULT BIT = 1
	DECLARE @CANT INT 
	DECLARE @RELACION_USUARIO INT
	--
	IF @REACTIVAR = 0 

	BEGIN

		SET @RELACION_USUARIO = (Select count(*) from [tblUsuario] U 
		                                    LEFT JOIN [tblAccesoInformacionAgenciasUsuario] AI
												   ON AI.Fk_Id_Usuario = U.Id 
												   where AI.Fk_Id_Agencia = @Id_AgenciaBancaria and U.Activo = 1) 

		SET @CANT = @RELACION_USUARIO

		SET @RESULT = IIF(@CANT > 0, 0, 1) 
	
	END
	--
    RETURN(@RESULT)
	--
END