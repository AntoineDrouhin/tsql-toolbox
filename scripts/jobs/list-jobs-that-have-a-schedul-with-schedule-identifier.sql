-- jobs that have a schedule with schedule identifiers
select
sysjobs.job_id
,sysjobs.name job_name
,sysjobs.enabled job_enabled
,sysschedules.name schedule_name
,sysschedules.schedule_id
,sysschedules.schedule_uid
,sysschedules.enabled schedule_enabled
from msdb.dbo.sysjobs
inner join msdb.dbo.sysjobschedules on sysjobs.job_id = sysjobschedules.job_id
inner join msdb.dbo.sysschedules on sysjobschedules.schedule_id = sysschedules.schedule_id
order by sysjobs.enabled desc