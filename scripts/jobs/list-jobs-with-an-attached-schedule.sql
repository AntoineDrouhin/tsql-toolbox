-- list jobs with an attached schedule
select
 name
,enabled
,description
from msdb.dbo.sysjobs
inner join msdb.dbo.sysjobschedules on sysjobs.job_id = sysjobschedules.job_id
order by enabled desc