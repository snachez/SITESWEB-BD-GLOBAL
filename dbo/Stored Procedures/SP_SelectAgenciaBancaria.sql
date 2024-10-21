CREATE   PROCEDURE SP_SelectAgenciaBancaria (	  @ID			INT  =	NULL
														, @ACTIVO       BIT  =    NULL
														, @USUARIO_ID	INT = NULL
												   )
AS
BEGIN

	--DECLARACION DE VARIABLES 
	DECLARE @sql NVARCHAR(max);
	----------------------------------------------------------------------------------------
	--- V A R I A B L E S		F O R M A T E O		F E C H A . . .
	----------------------------------------------------------------------------------------
	DECLARE @TIME_ZONE_FORMAT VARCHAR(90) = dbo.FN_GET_USER_ZONE_REGION_FORMAT(@USUARIO_ID)
	DECLARE @IS_UTC BIT = dbo.FN_IS_DB_UTC_ZONE_FORMAT()
	DECLARE @CURRENT_TIME_ZONE VARCHAR(100) = dbo.FN_DB_UTC_ZONE_FORMAT_NAME()
	----------------------------------------------------------------------------------------
    --------------------------------- DATOS DE LA TABLA  -----------------------------------------------
   ;WITH DATA_INDEXED AS (SELECT TOP 1  A.Id					  AS	[Id]
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
								         SELECT ', ' + CONVERT(varchar, D.Nomenclatura +' '+ CI.NumeroCuenta)
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
											T.Id								AS	[Id]
										, T.Nombre							AS	[Nombre]
										, T.Codigo							AS	[Codigo]													
										, T.Activo							AS	[Activo]
										, dbo.FN_CastTimeZoneFormat(@IS_UTC, @CURRENT_TIME_ZONE, @TIME_ZONE_FORMAT, T.Fecha_Creacion)			AS	[Fecha_Creacion]
										, dbo.FN_CastTimeZoneFormat(@IS_UTC, @CURRENT_TIME_ZONE, @TIME_ZONE_FORMAT, T.Fecha_Modificacion)		AS	[Fecha_Modificacion]
									FROM tblTransportadoras T
									WHERE A.Fk_Transportadora_Envio = T.Id
									FOR JSON PATH
								) AS Transportadora_Envio
								, (
									SELECT DISTINCT
											T.Id								AS	[Id]
										, T.Nombre							AS	[Nombre]
										, T.Codigo							AS	[Codigo]													
										, T.Activo							AS	[Activo]
										, dbo.FN_CastTimeZoneFormat(@IS_UTC, @CURRENT_TIME_ZONE, @TIME_ZONE_FORMAT, T.Fecha_Creacion)			AS	[Fecha_Creacion]
										, dbo.FN_CastTimeZoneFormat(@IS_UTC, @CURRENT_TIME_ZONE, @TIME_ZONE_FORMAT, T.Fecha_Modificacion)		AS	[Fecha_Modificacion]
									FROM tblTransportadoras T
									WHERE A.Fk_Transportadora_Solicitud = T.Id
									FOR JSON PATH
								) AS Transportadora_Solicitud
						, (
									SELECT DISTINCT
										CI.Id,
										CI.NumeroCuenta,
										CI.Codigo,
										CI.Activo
										, dbo.FN_CastTimeZoneFormat(@IS_UTC, @CURRENT_TIME_ZONE, @TIME_ZONE_FORMAT, CI.FechaCreacion)			AS	[FechaCreacion]
										, dbo.FN_CastTimeZoneFormat(@IS_UTC, @CURRENT_TIME_ZONE, @TIME_ZONE_FORMAT, CI.FechaModificacion)		AS	[FechaModificacion]

										, D.Id                  [Divisa.Id],
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
						WHERE A.Activo = ISNULL(@ACTIVO, A.Activo)
						AND A.Id = ISNULL(@ID, A.Id))
						SELECT * INTO #tmpTblDataResult FROM DATA_INDEXED
										---
	DECLARE @JSON_RESULT NVARCHAR(MAX) = (SELECT * FROM #tmpTblDataResult FOR JSON PATH)
	---
    SET @JSON_RESULT = REPLACE( @JSON_RESULT,'\','') --COMO EL JSON SE SERIALIZA EN 3 OCACIONES A CAUSA DE LA CLAUSULA: FOR JSON PATH, HAY QUE ELIMINARLES LOS \\\ A LAS TABLAS HIJOS
	SET @JSON_RESULT = REPLACE( @JSON_RESULT,':"[{',':[{') --HAY QUE ELIMINAR LOS CARACTERES  \" CUANDO SE HABRE LAS LLAVES EN EL INICIO DE LAS CADENAS DE ARRAYS DE LAS TABLAS HIJOS
	SET @JSON_RESULT = REPLACE( @JSON_RESULT,'}]"','}]') --Y TAMBIEN HAY QUE ELIMINAR LOS CARACTERES  \"  CUANDO SE CIERRA LAS LLAVES EN LAS CADENAS DE ARRAYS DE LAS TABLAS HIJOS

	DROP TABLE #tmpTblDataResult
	---
	SELECT @JSON_RESULT AS AGENCIA_BANCARIA_JSONRESULT;

END