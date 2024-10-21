CREATE   FUNCTION [dbo].[FN_VALIDACION_CONTRAINT_DESACTIVAR_tblTipoEfectivo](@REACTIVAR BIT, @Fk_Id_TipoEfectivo INT)
RETURNS BIT
AS
BEGIN
	--
	-- VALIDA SI EXISTEN RELACIONES ACTIVAS PARA DESACTIVAR UN TIPO EFECTIVO
	DECLARE @RESULT BIT = 0

	DECLARE @RELACION_UM INT
	DECLARE @RELACION_DV INT
	DECLARE @RELACION_D INT
	--
	IF @REACTIVAR = 0 BEGIN

	    SET @RELACION_D = (Select count(*) from tblDenominaciones where BMO = @Fk_Id_TipoEfectivo and Activo = 1)

		SET @RELACION_DV = (Select count(*) from tblDivisa D
		INNER JOIN tblDivisa_x_TipoEfectivo DTE on DTE.FkIdTipoEfectivo = @Fk_Id_TipoEfectivo and D.Id = DTE.FkIdDivisa
		where D.Activo = 1)
 
		SET @RELACION_UM = (Select count(*) from tblUnidadMedida UM
		INNER JOIN tblUnidadMedida_x_TipoEfectivo UMTE ON UMTE.Fk_Id_Unidad_Medida = UM.Id AND UMTE.Fk_Id_Tipo_Efectivo = @Fk_Id_TipoEfectivo
		WHERE UM.Activo = 1)

		IF(@RELACION_D > 0 OR @RELACION_DV > 0 OR @RELACION_UM > 0)
			BEGIN
				SET @RESULT = 1
			END
			ELSE
			BEGIN 
				SET @RESULT = 0
			END
		--
	END
	--
    RETURN(@RESULT)
	--
END