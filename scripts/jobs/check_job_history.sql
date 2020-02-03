-- https://blog.sqlauthority.com/2018/12/22/sql-server-t-sql-script-to-check-sql-server-job-history/

SELECT jobs.name AS 'JobName',
msdb.dbo.agent_datetime(run_date, run_time) AS 'Run Date Time',
history.run_duration AS 'Duration in Second'
FROM msdb.dbo.sysjobs jobs
INNER JOIN msdb.dbo.sysjobhistory history
ON jobs.job_id = history.job_id
WHERE jobs.enabled = 1