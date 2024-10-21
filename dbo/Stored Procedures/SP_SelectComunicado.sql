CREATE PROCEDURE [dbo].[SP_SelectComunicado] 
AS
BEGIN
	---
	SELECT C.Mensaje, T.Imagen, C.Activo
	FROM [tblComunicado] AS C
	INNER JOIN [tblTipoComunicado] AS T ON C.FkTipoComunicado = T.Id
	INNER JOIN [tblHabilitarBanner] AS H ON C.FkHabilitarBanner = H.Id
	WHERE  C.Activo = 1 AND T.Activo = 1 AND H.Activo = 1;
	---
END