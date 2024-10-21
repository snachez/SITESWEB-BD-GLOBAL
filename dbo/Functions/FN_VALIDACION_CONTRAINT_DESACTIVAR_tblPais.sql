CREATE   FUNCTION [dbo].[FN_VALIDACION_CONTRAINT_DESACTIVAR_tblPais](@REACTIVAR BIT, @Id_Pais INT )
RETURNS BIT
AS
BEGIN
	--
	-- VALIDA SI UN CEDIS TIENE RELACION Y ESTA ACTIVO PARA NO DESACTIVAR UN PAIS
	DECLARE @RESULT BIT = 1
	DECLARE @CANT INT 
	DECLARE @RELACION_CEDIS INT
	DECLARE @RELACION_AGENCIAS INT
	DECLARE @RELACION_TRANSPORTADORAS INT
	DECLARE @RELACION_USUARIOS INT
	--
	IF @REACTIVAR = 0 

	BEGIN
	 
		SET @RELACION_CEDIS = (Select count(*) from tblCedis where Fk_Id_Pais = @Id_Pais and Activo = 1) 
		SET @RELACION_AGENCIAS = (Select count(*) from tblAgenciaBancaria where FkIdPais = @Id_Pais and Activo = 1) 

		SET @RELACION_TRANSPORTADORAS = (Select count(*) from tblTransportadoras T 
		                                 LEFT JOIN tblTransportadoras_x_Pais TP ON T.Id = TP.Fk_Id_Transportadora
		                                 where TP.Fk_Id_Pais = @Id_Pais and T.Activo = 1) 

		SET @RELACION_USUARIOS = (Select count(*) from tblUsuario U LEFT JOIN tblAccesoInformacionAgenciasUsuario AI
									ON AI.Fk_Id_Usuario = U.Id
									LEFT JOIN tblAgenciaBancaria A
									ON AI.Fk_Id_Agencia = A.Id
									LEFT JOIN tblCedis CEDI
									ON A.FkIdCedi = CEDI.Id_Cedis
									LEFT JOIN tblPais PAIS
									ON PAIS.Id = CEDI.Fk_Id_Pais where Fk_Id_Pais = @Id_Pais and U.Activo = 1) 

		SET @CANT = @RELACION_CEDIS + @RELACION_AGENCIAS + @RELACION_TRANSPORTADORAS + @RELACION_USUARIOS
		
		SET @RESULT = IIF(@CANT > 0, 0, 1) 
	
	END
	--
    RETURN(@RESULT)
	--
END