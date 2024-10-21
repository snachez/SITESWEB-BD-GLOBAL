CREATE PROCEDURE [dbo].[usp_Select_Mensajes_Emergentes]
(
    @Modulo VARCHAR(MAX) = NULL,
    @Metodo VARCHAR(MAX) = NULL,
	@TipoMensaje VARCHAR(MAX) = NULL,
	@Titulo VARCHAR(MAX) = NULL,
	@Mensaje VARCHAR(MAX) = NULL,
	@ErrorMensaje VARCHAR(MAX) = NULL,
    @TituloSalida VARCHAR(MAX) OUTPUT,
    @MensajeSalida VARCHAR(MAX) OUTPUT
)
AS
BEGIN

	SELECT
	  @TituloSalida = T.Titulo,
	  @MensajeSalida = ME.Mensaje
	FROM tblMensajes_Emergentes ME
	INNER JOIN tblMensajes_Emergentes_Metodo MET
	  ON ME.Fk_Metodo = MET.Id
	INNER JOIN tblMensajes_Emergentes_Modulo MO
	  ON ME.Fk_Modulo = MO.Id
	INNER JOIN tblMensajes_Emergentes_Tipo_Mensaje TM
	  ON ME.Fk_TipoMensaje = TM.Id
	INNER JOIN tblMensajes_Emergentes_Titulo T
	  ON ME.Fk_Titulo = T.Id
	WHERE 
	(
		MET.Metodo = ISNULL(@Metodo, MET.Metodo)
		AND TM.TipoMensaje = ISNULL(@TipoMensaje, TM.TipoMensaje)
		AND T.Titulo = ISNULL(@Titulo, T.Titulo)
		AND ME.Mensaje = ISNULL(@Mensaje, ME.Mensaje)
		AND MO.Modulo = ISNULL(@Modulo, MO.Modulo)
	)
	AND 
	(
		ME.ErrorMensaje = ISNULL(@ErrorMensaje, ME.ErrorMensaje)
		OR ME.ErrorMensaje IS NULL
	);

END;