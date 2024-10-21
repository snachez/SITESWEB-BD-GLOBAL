CREATE FUNCTION [dbo].[FN_VALIDACION_CONTRAINT_DESACTIVAR_tblCedis](@REACTIVAR BIT, @Id_Cedis INT )
RETURNS BIT
AS
BEGIN
	--
	-- VALIDA SI LAS RELACIONES ESTAN INACTIVAS PARA DESACTIVAR UNA CEDIS
	DECLARE @RESULT BIT = 1
	DECLARE @CANT INT 
	DECLARE @RELACION_AGENCIA INT
	DECLARE @RELACION_USUARIO INT
	--
	IF @REACTIVAR = 0 

	BEGIN
	 
		SET @RELACION_AGENCIA = (Select count(*) from tblAgenciaBancaria where FkIdCedi = @Id_Cedis and Activo = 1) 

		SET @RELACION_USUARIO = (Select count(*) from [tblUsuario] U 
		                                            LEFT JOIN [tblAccesoInformacionAgenciasUsuario] AI
													ON AI.Fk_Id_Usuario = U.Id
													LEFT JOIN tblAgenciaBancaria A
													ON AI.Fk_Id_Agencia = A.Id
													LEFT JOIN tblCedis CEDI
													ON A.FkIdCedi = CEDI.Id_Cedis 
													where CEDI.Id_Cedis = @Id_Cedis and U.Activo = 1) 


		SET @CANT = @RELACION_AGENCIA + @RELACION_USUARIO

		SET @RESULT = IIF(@CANT > 0, 0, 1) 
	
	END
	--
    RETURN(@RESULT)
	--
END