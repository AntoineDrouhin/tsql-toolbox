--- ============================================================================= ---
-- Restore from URL (using SAS Token) :


-- For this script to work, bak files are supposed to end by _0.bak , _1.bak etc...
--- ============================================================================= ---

DECLARE @Date AS NVARCHAR(25)
   ,@TSQL AS NVARCHAR(MAX)
   ,@ContainerName AS NVARCHAR(MAX)
   ,@StorageAccountName AS VARCHAR(MAX)
   ,@SASKey AS VARCHAR(MAX)
   ,@DatabaseName AS SYSNAME
   ,@BakFileName AS VARCHAR(MAX)
   ,@NumberOfBakFiles AS INTEGER
   ,@DestinationFolderData AS VARCHAR(MAX)
   ,@DestinationFolderLog AS VARCHAR(MAX);
SELECT @Date = REPLACE(REPLACE(REPLACE(REPLACE(CONVERT(VARCHAR, GETDATE(), 100), '  ', '_'), ' ', '_'), '-', '_'), ':', '_');

--- Find this from Azure Portal
SELECT @StorageAccountName = '';
--- Find this from Azure Portal
SELECT @ContainerName = '';
--- Find this from Azure Portal
SELECT @SASKey = '';

SELECT @DatabaseName = '';

--- Bak file name prefix, without the file end or the extension. (real filename must finish by _[0-9] )
--- Ex myfile_0.bak => myfile
SELECT @BakFileName = '';

SELECT @NumberOfBakFiles = 1;

-- Optional -- conclude by file separator (/ or \ depending on the os)
-- Required when restoring a backup made on windows on linux or the other way around
SELECT @DestinationFolderData = 'F:\data\';
SELECT @DestinationFolderLog = 'F:\log\'
-- SELECT @DestinationFolderData = '/var/opt/mssql/data/';
-- SELECT @DestinationFolderLog = '/var/opt/mssql/data/';


--------------------------------- SCRIPT --------------------------------------

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


SELECT @TSQL = 'RESTORE DATABASE [' + @DatabaseName + '] FROM URL = ''https://' + @StorageAccountName + '.blob.core.windows.net/' + @ContainerName+ '/'+ @BakFileName + '_0.bak'''

DECLARE @fileCounter integer = 1;

WHILE (@fileCounter < @NumberOfBakFiles)
BEGIN
    SELECT @TSQL += ' , URL = ''https://' + @StorageAccountName + '.blob.core.windows.net/' + @ContainerName+ '/'+ @BakFileName + '_'+ CAST(@fileCounter as varchar(10)) + '.bak'''
    SET @fileCounter = @fileCounter + 1
END



IF(@DestinationFolderData != '')
BEGIN
    SELECT @TSQL = @TSQL + ' WITH MOVE ''' + @DatabaseName + ''' TO ''' + @DestinationFolderData + @databaseName + '.mdf'''

    IF(@DestinationFolderLog != '')
    SELECT @TSQL = @TSQL + ' ,MOVE ''' + @DatabaseName + '_log'' TO ''' + @DestinationFolderLog + @databaseName + '_log.ldf'''

END
EXEC (@TSQL)

