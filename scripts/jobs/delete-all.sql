use dsc

DECLARE @jobs TABLE ([name] varchar(max));

INSERT INTO @jobs SELECT [name] FROM msdb.dbo.sysjobs;

DECLARE @job NVARCHAR(max)

WHILE ((select count(*) from @jobs) > 0)
BEGIN
select @job = (SELECT TOP(1) * FROM @jobs order by name)
EXEC  msdb.dbo.sp_delete_job  
    @job_name = @job ;

DELETE FROM @jobs where name = @job
END