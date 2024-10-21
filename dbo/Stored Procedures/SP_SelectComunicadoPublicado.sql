CREATE PROCEDURE [dbo].[SP_SelectComunicadoPublicado]
AS
BEGIN
	SELECT C.Id , C.Mensaje
	FROM [tblComunicado] AS C
	INNER JOIN [tblTipoComunicado] AS T ON C.FkTipoComunicado = T.Id
	WHERE  C.Activo = 1 and T.Activo = 1
	ORDER BY C.Id ASC
END