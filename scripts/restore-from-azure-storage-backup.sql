--- ============================================================================= ---
-- Restore from URL (using SAS Token) :
--- ============================================================================= ---

DECLARE @Date AS NVARCHAR(25)
   ,@TSQL AS NVARCHAR(MAX)
   ,@ContainerName AS NVARCHAR(MAX)
   ,@StorageAccountName AS VARCHAR(MAX)
   ,@SASKey AS VARCHAR(MAX)
   ,@DatabaseName AS SYSNAME
   ,@BakFileName as VARCHAR(MAX);
SELECT @Date = REPLACE(REPLACE(REPLACE(REPLACE(CONVERT(VARCHAR, GETDATE(), 100), '  ', '_'), ' ', '_'), '-', '_'), ':', '_');
SELECT @StorageAccountName = ''; --- Find this from Azure Portal
SELECT @ContainerName = ''; --- Find this from Azure Portal
SELECT @SASKey = ''; --- Find this from Azure Portal
SELECT @DatabaseName = '';
SELECT @BakFileName =  '';
IF EXISTS (
       SELECT *
        FROM sys.credentials
        WHERE name = 'https://' + @StorageAccountName + '.blob.core.windows.net/' + @ContainerName 
)
BEGIN
    SELECT @TSQL = 'DROP CREDENTIAL [https://' + @StorageAccountName + '.blob.core.windows.net/' + @ContainerName + ']'
    EXEC (@TSQL)
END
SELECT @TSQL = 'CREATE CREDENTIAL [https://' + @StorageAccountName + '.blob.core.windows.net/' + @ContainerName + '] WITH IDENTITY = ''SHARED ACCESS SIGNATURE'', SECRET = ''' + REPLACE(@SASKey, '?sv=', 'sv=') + ''';'
EXEC (@TSQL)
SELECT @TSQL = 'RESTORE DATABASE [' + @DatabaseName + '] FROM URL = ''https://' + @StorageAccountName + '.blob.core.windows.net/' + @ContainerName+ '/'+ @BakFileName + ''''
EXEC (@TSQL)