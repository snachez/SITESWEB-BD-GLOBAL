CREATE FUNCTION [dbo].[FN_VALIDACION_CONTRAINT_REACTIVAR_tblAgenciaBancaria_C3_4_5](@REACTIVAR BIT, @FkIdPais INT, @FkIdCedi INT, @FkIdGrupoAgencia INT, 
@Fk_Transportadora_Envio INT, @Fk_Transportadora_Solicitud INT)
RETURNS BIT
AS
BEGIN
	--
	-- VALIDA SI EL PAIS,CEDIS,GRUPO AGENCIA ESTA ACTIVO Y LA RELACION ENTRE CEDIS Y PAIS PARA REACTIVAR UNA AGENCIA BANCARIA
	DECLARE @RESULT BIT = 1
	DECLARE @CANT INT 
	DECLARE @RELACION_CP INT
	DECLARE @RELACION_C INT
	DECLARE @RELACION_P INT
	DECLARE @RELACION_G INT
	DECLARE @RELACION_TE INT
	DECLARE @RELACION_TS INT
	--
	IF @REACTIVAR = 1 BEGIN
		--
		SET @RELACION_CP = (Select count(*) from tblCedis where Id_Cedis = @FkIdCedi and Fk_Id_Pais = @FkIdPais and Activo = 0)
		SET @RELACION_C = (Select count(*) from tblCedis where Id_Cedis = @FkIdCedi and Activo = 0) 
		SET @RELACION_P = (Select count(*) from tblPais where Id = @FkIdPais and Activo = 0)
		SET @RELACION_G = (Select count(*) from tblGrupoAgencia where Id = @FkIdGrupoAgencia and Activo = 0)
		SET @RELACION_TE = (Select count(*) from tblTransportadoras where Id = @Fk_Transportadora_Envio and Activo = 0)
		SET @RELACION_TS = (Select count(*) from tblTransportadoras where Id = @Fk_Transportadora_Solicitud and Activo = 0)

		SET @CANT = @RELACION_CP + @RELACION_P + @RELACION_G + @RELACION_C + @RELACION_TE + @RELACION_TS

		SET @RESULT = IIF(@CANT > 0, 0, 1) 

		--
	END
	--
    RETURN(@RESULT)
	--
END