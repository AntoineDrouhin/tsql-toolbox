SELECT DISTINCT
  s.name,
  t.name,
  i.name,
  i.type as index_type_code,
  CASE
    WHEN i.type = 0 then 'heap' 
    WHEN i.type = 1 then 'clustered' 
    WHEN i.type = 2 then 'non-clustered' 
  END as index_type_label,
  i.index_id,
  p.partition_number,
  p.rows
FROM sys.tables t
  LEFT JOIN sys.indexes i
  ON t.object_id = i.object_id
  JOIN sys.schemas s
  ON t.schema_id = s.schema_id
  LEFT JOIN sys.partitions p
  ON i.index_id = p.index_id
    AND t.object_id = p.object_id
WHERE t.type = 'U'
  AND p.data_compression_desc = 'NONE'

ORDER BY p.rows desc