-- list all jobs without a schedule
select
 name
,enabled
,description
from msdb.dbo.sysjobs where job_id in
(
-- job_ids without a schedule
select job_id from msdb.dbo.sysjobs

except

select job_id from msdb.dbo.sysjobschedules
)