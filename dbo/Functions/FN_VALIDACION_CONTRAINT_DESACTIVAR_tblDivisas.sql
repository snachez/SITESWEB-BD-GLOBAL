CREATE   FUNCTION [dbo].[FN_VALIDACION_CONTRAINT_DESACTIVAR_tblDivisas](@REACTIVAR BIT, @Fk_Id_Divisa INT)
RETURNS BIT
AS
BEGIN
	--
	-- VALIDA SI EXISTEN RELACIONES ACTIVAS PARA DESACTIVAR UNA DIVISA
	DECLARE @RESULT BIT = 1
    DECLARE @CANT INT 

	DECLARE @RELACION_UM INT
	DECLARE @RELACION_D INT
	DECLARE @RELACION_MA INT
	DECLARE @RELACION_CA INT
	DECLARE @RELACION_TC INT
	DECLARE @RELACION_CGA INT
	--
	IF @REACTIVAR = 0 
	BEGIN

	    SET @RELACION_D = (Select count(*) from tblDenominaciones where IdDivisa = @Fk_Id_Divisa and Activo = 1) 
		SET @RELACION_UM = (Select count(*) from tblUnidadMedida UM
							INNER JOIN tblUnidadMedida_x_Divisa UMTE ON UMTE.Fk_Id_Unidad_Medida = UM.Id AND UMTE.Fk_Id_Divisa = @Fk_Id_Divisa
							WHERE UM.Activo = 1)
		SET @RELACION_MA = (SELECT count(*) from tblMatrizAtribucion MA
							INNER JOIN tblDivisa Dv on MA.Fk_Id_Divisa = Dv.Id and Dv.Id = @Fk_Id_Divisa							
							where MA.Activo = 1)
		SET @RELACION_CA = (SELECT count(*) from tblCuentaInterna CI
							INNER JOIN tblDivisa Dv on CI.FkIdDivisa = Dv.Id and Dv.Id = @Fk_Id_Divisa
							INNER JOIN tblCuentaInterna_x_Agencia CIA ON CIA.FkIdCuentaInterna = CI.Id
							where CIA.Activo = 1)
	SET @RELACION_CGA = (SELECT count(*) from tblCuentaInterna CI
							INNER JOIN tblDivisa Dv on CI.FkIdDivisa = Dv.Id and Dv.Id = @Fk_Id_Divisa
							INNER JOIN tblCuentaInterna_x_GrupoAgencias CIGA ON CIGA.FkIdCuentaInterna = CI.Id
							where CIGA.Activo = 1)
	   SET @RELACION_TC = (SELECT count(*) from tblTipoCambio TC
							INNER JOIN tblDivisa Dv on TC.fk_Id_DivisaCotizada = Dv.Id and Dv.Id = @Fk_Id_Divisa
							where TC.Activo = 1)

		SET @CANT = @RELACION_D + @RELACION_UM + @RELACION_MA + @RELACION_CA + @RELACION_CGA + @RELACION_TC

		SET @RESULT = IIF(@CANT > 0, 0, 1) 
		
	END	
	--
    RETURN(@RESULT)
	--
END