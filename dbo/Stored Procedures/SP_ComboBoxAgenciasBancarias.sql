
CREATE PROCEDURE [dbo].[SP_ComboBoxAgenciasBancarias] (
                                                     @IDPAISES				VARCHAR(MAX)  =	NULL
													, @IDCEDIS				VARCHAR(MAX)  =	NULL
													, @IDGRUPOAGENCIAS		VARCHAR(MAX)  =	NULL
													, @ACTIVO				BIT			   =    NULL     
													)
AS
BEGIN
	 ---

	   --------------------------------- DATOS DE LA TABLA  -----------------------------------------------
   ;WITH DATA_INDEXED AS (SELECT  A.Id					  AS	[Id]
								, A.Nombre				  AS	[Nombre]
								, A.FkIdGrupoAgencia	  AS	[FkIdGrupoAgencia]
								, A.UsaCuentasGrupo		  AS	[UsaCuentasGrupo]
								, A.EnviaRemesas		  AS	[EnviaRemesas]
								, A.SolicitaRemesas		  AS	[SolicitaRemesas]
								, A.CodigoBranch		  AS	[CodigoBranch]
								, P.Nombre		          AS	[CodigoProvincia]
								, C.Nombre		          AS	[CodigoCanton]
								, D.Nombre		          AS	[CodigoDistrito]
								, A.Direccion			  AS	[Direccion]
								, A.Codigo_Agencia        AS    [Codigo_Agencia]
								, CE.Nombre               AS    [Nombre_Cedis]
								, CE.Codigo_Cedis         AS    [Codigo_Cedis]
								, PA.Nombre               AS    [Nombre_Pais]
								, PA.Codigo               AS    [Codigo]
								, G.Nombre                AS    [Nombre_Grupo]
								, A.Activo				  AS	[Activo]
						        , STUFF((
								         SELECT ',' + CONVERT(varchar, D.Nomenclatura +' '+ CI.NumeroCuenta)
										 FROM tblCuentaInterna_x_Agencia CA
										 LEFT JOIN tblCuentaInterna CI
											ON CI.Id = CA.FkIdCuentaInterna
										 INNER JOIN tblDivisa D
											ON D.Id = CI.FkIdDivisa
										 WHERE CA.FkIdAgencia = A.Id
											AND CA.Activo = 1
										 FOR XML PATH ('')
										), 1, 2, ''
										)                 AS Cuentas
								, (
									SELECT DISTINCT
										CI.Id,
										CI.NumeroCuenta,
										CI.Codigo,
										CI.Activo,
										CI.FechaCreacion,
									    CI.FechaModificacion,
										D.Id                    [Divisa.Id],
									    D.Activo                [Divisa.Activo],
										D.Nombre                [Divisa.Nombre],
										D.Nomenclatura          [Divisa.Nomenclatura],
										D.Descripcion           [Divisa.Descripcion]
								   FROM tblCuentaInterna_x_Agencia CA
								   LEFT JOIN tblCuentaInterna CI
									ON CI.Id = CA.FkIdCuentaInterna
								   INNER JOIN tblDivisa D
			                        ON D.Id = CI.FkIdDivisa
								   WHERE CA.FkIdAgencia = A.Id
								   AND CA.Activo = 1
								   FOR JSON PATH
								) AS CuentaInterna
						FROM tblAgenciaBancaria A
						INNER JOIN tblGrupoAgencia G
						ON A.FkIdGrupoAgencia = G.Id
						INNER JOIN tblProvincia P
						ON A.CodigoProvincia = P.Id
						INNER JOIN tblCanton C
						ON A.CodigoCanton = C.Id
						INNER JOIN tblDistrito D
						ON A.CodigoDistrito = D.Id
						INNER JOIN tblCedis CE
						ON A.FkIdCedi = CE.Id_Cedis
						INNER JOIN tblPais PA
						ON A.FkIdPais = PA.Id
						WHERE (
						 --@IDPAISES = '' OR 
						 
						 PA.Id IN (SELECT value FROM STRING_SPLIT(@IDPAISES, ','))
						 AND
						 --@IDCEDIS = '' OR
						 CE.Id_Cedis IN (SELECT value FROM STRING_SPLIT(@IDCEDIS, ','))
						 AND
						 --@IDGRUPOAGENCIAS = '' OR 
						 G.Id IN (SELECT value FROM STRING_SPLIT(@IDGRUPOAGENCIAS, ','))
						))
	
	SELECT * INTO #tmpTblDataResult FROM DATA_INDEXED where Activo = ISNULL(@ACTIVO, Activo)
										---
	DECLARE @JSON_RESULT VARCHAR(MAX) = (SELECT * FROM #tmpTblDataResult FOR JSON PATH)
	---
    SET @JSON_RESULT = REPLACE( @JSON_RESULT,'\','') --COMO EL JSON SE SERIALIZA EN 3 OCACIONES A CAUSA DE LA CLAUSULA: FOR JSON PATH, HAY QUE ELIMINARLES LOS \\\ A LAS TABLAS HIJOS
	SET @JSON_RESULT = REPLACE( @JSON_RESULT,':"[{',':[{') --HAY QUE ELIMINAR LOS CARACTERES  \" CUANDO SE HABRE LAS LLAVES EN EL INICIO DE LAS CADENAS DE ARRAYS DE LAS TABLAS HIJOS
	SET @JSON_RESULT = REPLACE( @JSON_RESULT,'}]"','}]') --Y TAMBIEN HAY QUE ELIMINAR LOS CARACTERES  \"  CUANDO SE CIERRA LAS LLAVES EN LAS CADENAS DE ARRAYS DE LAS TABLAS HIJOS

	DROP TABLE #tmpTblDataResult
	---
	SELECT @JSON_RESULT AS AGENCIA_BANCARIA_JSONRESULT;

END