CREATE OR ALTER PROCEDURE usp_DescribeTable
    @TableName NVARCHAR(2000)
AS
SELECT t.name 'table', c.name 'column', TYPES.name as 'type', c.max_length, c.precision, c.collation_name, c.is_nullable, c.is_computed, is_identity from sys.columns c
INNER JOIN sys.tables t on c.object_id = t.object_id
INNER JOIN sys.types TYPES on c.system_type_id = TYPES.system_type_id
where t.name like ('%'+@TableName+'%')
AND TYPES.name <> 'sysname'
ORDER BY t.name,c.name
