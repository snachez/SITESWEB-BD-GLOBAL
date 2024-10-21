PRINT N'Inicio de reversiones en [Sites-Global]';

GO

PRINT N'Inicio de eliminar SP, FUNCIONES, VIEW, TABLAS, SEQUENCES';

GO

DECLARE @ObjectName NVARCHAR(500)

DECLARE objectCursor CURSOR FOR SELECT [name]

FROM sys.objects

WHERE type IN ('U', 'P', 'FN', 'IF', 'SO')

ORDER BY 

    CASE 

        WHEN type = 'U' THEN 1 -- Tablas de usuario primero

        ELSE 2 -- Otros tipos de objetos después

    END;

OPEN objectCursor

FETCH NEXT FROM objectCursor INTO @ObjectName

WHILE @@FETCH_STATUS = 0

BEGIN

IF OBJECTPROPERTY(OBJECT_ID(@ObjectName), 'IsTable') = 1

BEGIN

  -- Eliminar tabla y restricciones de clave externa

  DECLARE @DropForeignKeySQL NVARCHAR(MAX)

  DECLARE @DropTableSQL NVARCHAR(MAX)

  SET @DropForeignKeySQL = ''

  SET @DropTableSQL = ''

  -- Generar el SQL para eliminar las restricciones de clave externa de la tabla actual

  SELECT

    @DropForeignKeySQL = @DropForeignKeySQL +

    'ALTER TABLE ' + OBJECT_SCHEMA_NAME(parent_object_id) + '.' + OBJECT_NAME(parent_object_id) +

    ' DROP CONSTRAINT ' + name + ';'

  FROM sys.foreign_keys

  WHERE referenced_object_id = OBJECT_ID(@ObjectName)

  -- Generar el SQL para eliminar la tabla actual

  SET @DropTableSQL = 'DROP TABLE ' + @ObjectName + ';'

  -- Ejecutar el SQL generado para eliminar las restricciones de clave externa

  EXEC sp_executesql @DropForeignKeySQL

  -- Ejecutar el SQL generado para eliminar la tabla

  EXEC sp_executesql @DropTableSQL

END

ELSE

BEGIN

  -- Eliminar procedimiento almacenado, función o vista

  DECLARE @ObjectType INT = 0;

  -- Obtener el tipo de objeto utilizando OBJECTPROPERTY

  SET @ObjectType = OBJECTPROPERTY(OBJECT_ID(@ObjectName), 'IsProcedure')

  -- Verificar el tipo de objeto y construir el comando DROP correspondiente

  IF @ObjectType = 1

  BEGIN

    EXEC ('DROP PROCEDURE ' + @ObjectName)

  END

  ELSE

  BEGIN

    SET @ObjectType = OBJECTPROPERTY(OBJECT_ID(@ObjectName), 'IsScalarFunction')

    IF @ObjectType = 1

    BEGIN

      EXEC ('DROP FUNCTION ' + @ObjectName)

    END

    ELSE

    BEGIN

      SET @ObjectType = OBJECTPROPERTY(OBJECT_ID(@ObjectName), 'IsView')

      IF @ObjectType = 1

      BEGIN

        EXEC ('DROP VIEW ' + @ObjectName)

      END

      ELSE

      BEGIN

        SET @ObjectType = OBJECTPROPERTY(OBJECT_ID(@ObjectName), 'IsSequence')

        IF @ObjectType = 1

        BEGIN

          EXEC ('DROP SEQUENCE ' + @ObjectName)

        END

        ELSE

        BEGIN

          SET @ObjectType = OBJECTPROPERTY(OBJECT_ID(@ObjectName), 'IsFunction')

          IF @ObjectType = 1

          BEGIN

            EXEC ('DROP FUNCTION ' + @ObjectName)

          END

        END

      END

    END

  END

END

FETCH NEXT FROM objectCursor INTO @ObjectName

END

CLOSE objectCursor

DEALLOCATE objectCursor

GO

PRINT N'Fin de eliminar SP, FUNCIONES, VIEW, TABLAS, SEQUENCES';

GO