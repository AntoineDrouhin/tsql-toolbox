/*

FROM https://blog.sqlauthority.com/2020/01/31/sql-server-details-about-sql-jobs-and-job-schedules/
====================================================================
Author:           Dominic Wirth
Date created:     2019-10-04
Date last change: 2019-12-21
Script-Version:   1.1
Tested with:      SQL Server 2012 and above
Description: This script shows important information regarding
SQL Jobs and Job Schedules. Please feel free to change the
translated values from English to your desired language.
====================================================================
*/
WITH JobSchedules AS (
  SELECT
    schedule_id, [name], [enabled]
    ,CASE freq_type
        WHEN 1 THEN 'One time only' WHEN 4 THEN 'Daily' WHEN 8 THEN 'Weekly' WHEN 16 THEN 'Monthly' WHEN 32 THEN 'Monthly' WHEN 64 THEN 'When SQL Server Agent starts' WHEN 128 THEN 'When computer is idle'
      END AS Frequency
    ,IIF(freq_type = 32 AND freq_relative_interval <> 0
          ,CASE freq_relative_interval WHEN 1 THEN 'First ' WHEN 2 THEN 'Second ' WHEN 4 THEN 'Third ' WHEN 8 THEN 'Fourth ' WHEN 16 THEN 'Last ' END
          ,'')
      + CASE freq_type
        WHEN 1 THEN ''
        WHEN 4 THEN IIF(freq_interval = 1, 'Every day', 'Every ' + CAST(freq_interval AS VARCHAR(3)) + ' day(s)')
        WHEN 8 THEN
            IIF(freq_interval &  2 =  2, 'Mon ', '')
          + IIF(freq_interval &  4 =  4, 'Tue ', '')
          + IIF(freq_interval &  8 =  8, 'Wed ', '')
          + IIF(freq_interval & 16 = 16, 'Thu ', '')
          + IIF(freq_interval & 32 = 32, 'Fri ', '')
          + IIF(freq_interval & 64 = 64, 'Sat ', '')
          + IIF(freq_interval &  1 =  1, 'Sun ', '')
        WHEN 16 THEN 'On the ' + CAST(freq_interval AS VARCHAR(3)) + ' day of the month.'
        WHEN 32 THEN
          CASE freq_interval
            WHEN 1 THEN 'Sunday' WHEN 2 THEN 'Monday' WHEN 3 THEN 'Tuesday' WHEN 4 THEN 'Wednesday' WHEN 5 THEN 'Thursday' WHEN 6 THEN 'Friday'
            WHEN 7 THEN 'Saturday' WHEN 8 THEN 'Day' WHEN 9 THEN 'Weekday' WHEN 10 THEN 'Weekend day'
          END
        WHEN 64 THEN ''
        WHEN 128 THEN ''
      END AS DayInterval
    ,IIF(freq_subday_interval <> 0
          ,CASE freq_subday_type
            WHEN 1 THEN 'At ' + STUFF(STUFF(RIGHT('00000' + CAST(active_start_time AS VARCHAR(6)), 6), 3,0,':'), 6,0,':')
            WHEN 2 THEN 'Repeat every ' + CAST(freq_subday_interval  AS VARCHAR(3)) + ' seconds'
            WHEN 4 THEN 'Repeat every ' + CAST(freq_subday_interval  AS VARCHAR(3)) + ' minutes'
            WHEN 8 THEN 'Repeat every ' + CAST(freq_subday_interval  AS VARCHAR(3)) + ' hours'
          END
          ,'') AS DailyFrequency
    ,CASE
        WHEN freq_type = 8 THEN 'Repeat every ' + CAST(freq_recurrence_factor AS VARCHAR(3)) + ' week(s).'
        WHEN freq_type IN (16, 32) THEN 'Repeat every ' + CAST(freq_recurrence_factor AS VARCHAR(3)) + ' month(s).'
        ELSE ''
      END AS Recurrence
    ,STUFF(STUFF(RIGHT('00000' + CAST(active_start_time AS VARCHAR(6)), 6), 3,0,':'), 6,0,':') AS StartTime
    ,STUFF(STUFF(RIGHT('00000' + CAST(active_end_time AS VARCHAR(6)), 6), 3,0,':'), 6,0,':') AS EndTime
  FROM msdb.dbo.sysschedules
)
SELECT
  J.[name] AS JobName, J.[enabled] AS JobIsEnabled, ISNULL(SP.[name], 'Unknown') AS JobOwner, ISNULL(JS.[enabled], 0) AS ScheduleIsEnabled
  ,ISNULL(JS.[Frequency], '') AS Frequency, ISNULL(JS.[DayInterval], '') AS DayInterval
  ,ISNULL(JS.[DailyFrequency], '') AS [DailyFrequency], ISNULL(JS.[Recurrence], '') AS [Recurrence]
  ,ISNULL(JS.[StartTime], '') AS [StartTime], ISNULL(JS.[EndTime], '') AS [EndTime]
FROM msdb.dbo.sysjobs AS J
  LEFT JOIN sys.server_principals AS SP ON J.owner_sid = SP.[sid]
  LEFT JOIN msdb.dbo.sysjobschedules AS JJS ON J.job_id = JJS.job_id
  LEFT JOIN JobSchedules AS JS ON JJS.schedule_id = JS.schedule_id
ORDER BY
  J.[name] ASC;