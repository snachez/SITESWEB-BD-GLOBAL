CREATE   FUNCTION [dbo].[FN_VALIDACION_CONTRAINT_REACTIVAR_tblDenominaciones](@REACTIVAR BIT, @Fk_Id_Denominacion INT)
RETURNS BIT
AS
BEGIN
	--
	-- VALIDA SI EXISTEN RELACIONES ACTIVAS PARA REACTIVAR UNA DENOMINACIONES
	DECLARE @RESULT BIT = 1
	DECLARE @CANT INT 
	DECLARE @RELACION_TE INT
	DECLARE @RELACION_D INT
	--
	IF @REACTIVAR = 1
	BEGIN
	    SET @RELACION_D = (select Count(*) from tblDivisa Dv
							inner join tblDenominaciones D on Dv.Id = D.IdDivisa
							where Dv.Activo = 0 and D.Id = @Fk_Id_Denominacion ) 
		SET @RELACION_TE = (select Count(*) from tblTipoEfectivo TE
							inner join tblDenominaciones D on TE.Id = D.BMO
							where TE.Activo = 0 and D.Id = @Fk_Id_Denominacion)

		SET @CANT = @RELACION_D + @RELACION_TE

		SET @RESULT = IIF(@CANT > 0, 0, 1) 
		
	END	

	--
    RETURN(@RESULT)
	--
END