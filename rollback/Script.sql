PRINT N'Inicio de reversiones en [Sites-Global]';
GO

PRINT N'Inicio de eliminar SP, FUNCIONES, VIEW, TABLAS, SEQUENCES';
GO

DECLARE @ObjectNameProd NVARCHAR(500)
DECLARE @ObjectSchema NVARCHAR(500)
DECLARE @DropCommand NVARCHAR(MAX)

DECLARE objectCursorProd CURSOR FOR 
SELECT s.name AS SchemaName, o.name AS ObjectName
FROM sys.objects o
INNER JOIN sys.schemas s ON o.schema_id = s.schema_id
WHERE TYPE IN ('U', 'P', 'FN', 'IF', 'SO', 'V') AND 
s.name IN ('dbo')
ORDER BY 
    CASE 
        WHEN o.type = 'U' THEN 1 -- Tablas de usuario primero
        ELSE 2 -- Otros tipos de objetos después
    END;

OPEN objectCursorProd
FETCH NEXT FROM objectCursorProd INTO @ObjectSchema, @ObjectNameProd

WHILE @@FETCH_STATUS = 0
BEGIN
    IF OBJECTPROPERTY(OBJECT_ID(@ObjectSchema + '.' + @ObjectNameProd), 'IsTable') = 1 BEGIN
        -- Eliminar tabla y restricciones de clave externa
        DECLARE @DropForeignKeySQLProd NVARCHAR(MAX) = ''
        DECLARE @DropTableSQLProd NVARCHAR(MAX) = 'DROP TABLE ' + @ObjectSchema + '.' + @ObjectNameProd + ';'

        -- Generar el SQL para eliminar las restricciones de clave externa de la tabla actual
        SELECT @DropForeignKeySQLProd +=
            'ALTER TABLE ' + OBJECT_SCHEMA_NAME(parent_object_id) + '.' + OBJECT_NAME(parent_object_id) +
            ' DROP CONSTRAINT ' + fk.name + ';'
        FROM sys.foreign_keys fk
        WHERE fk.referenced_object_id = OBJECT_ID(@ObjectSchema + '.' + @ObjectNameProd)

        -- Ejecutar el SQL generado para eliminar las restricciones de clave externa
        IF @DropForeignKeySQLProd <> '' BEGIN
            EXEC sp_executesql @DropForeignKeySQLProd
        END

        -- Ejecutar el SQL generado para eliminar la tabla
        EXEC sp_executesql @DropTableSQLProd
    END ELSE BEGIN
        -- Eliminar procedimiento almacenado, función, vista o secuencia
        SET @DropCommand = NULL

        SET @DropCommand = CASE WHEN OBJECTPROPERTY(OBJECT_ID(@ObjectSchema + '.' + @ObjectNameProd), 'IsProcedure') = 1
                                  THEN CONCAT('DROP PROCEDURE ', @ObjectSchema, '.', @ObjectNameProd)
                                WHEN OBJECTPROPERTY(OBJECT_ID(@ObjectSchema + '.' + @ObjectNameProd), 'IsScalarFunction') = 1 
                                  OR OBJECTPROPERTY(OBJECT_ID(@ObjectSchema + '.' + @ObjectNameProd), 'IsFunction') = 1
                                  OR OBJECTPROPERTY(OBJECT_ID(@ObjectSchema + '.' + @ObjectNameProd), 'IsInlineFunction') = 1
                                    THEN CONCAT('DROP FUNCTION ', @ObjectSchema, '.', @ObjectNameProd)
                                WHEN OBJECTPROPERTY(OBJECT_ID(@ObjectSchema + '.' + @ObjectNameProd), 'IsView') = 1
                                  THEN CONCAT('DROP VIEW ', @ObjectSchema, '.', @ObjectNameProd)
                                WHEN OBJECTPROPERTY(OBJECT_ID(@ObjectSchema + '.' + @ObjectNameProd), 'IsSequence') = 1
                                  THEN CONCAT('DROP SEQUENCE ', @ObjectSchema, '.', @ObjectNameProd)
                                END
             
        -- Ejecutar el comando DROP si se encontró el tipo de objeto
        IF @DropCommand IS NOT NULL BEGIN
            EXEC sp_executesql @DropCommand
        END
    END

    FETCH NEXT FROM objectCursorProd INTO @ObjectSchema, @ObjectNameProd
END

CLOSE objectCursorProd
DEALLOCATE objectCursorProd
GO

PRINT N'Fin de eliminar SP, FUNCIONES, VIEW, TABLAS, SEQUENCES';
GO