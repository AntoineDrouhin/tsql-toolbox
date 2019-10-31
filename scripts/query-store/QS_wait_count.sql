 SELECT TOP 50
	qt.query_text_id,
	q.query_id,
	p.plan_id,
	sum(total_query_wait_time_ms) AS sum_total_wait_ms,
	qt.*
FROM sys.query_store_wait_stats ws
JOIN sys.query_store_plan p ON ws.plan_id = p.plan_id
JOIN sys.query_store_query q ON p.query_id = q.query_id
JOIN sys.query_store_query_text qt ON q.query_text_id = qt.query_text_id
GROUP BY qt.query_text_id, q.query_id, p.plan_id
ORDER BY sum_total_wait_ms DESC