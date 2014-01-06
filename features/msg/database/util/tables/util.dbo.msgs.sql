USE util
go
SETUSER 'dbo'
go

IF EXISTS (SELECT 1 
             FROM dbo.sysobjects 
            WHERE id = OBJECT_ID('dbo.msgs')
              AND type = 'U') BEGIN
    PRINT 'DROP TABLE dbo.msgs'
    EXECUTE ('DROP TABLE dbo.msgs')
END
go

PRINT 'CREATE TABLE dbo.msgs'	
go

/*
** Purpose: Store print messages
** EachRow: Message
** Clients: util.dbo.msg
** DB     : util
** Keys   : id - unique identifier
*/
CREATE TABLE dbo.msgs (
     id   UNSIGNED INT   IDENTITY            -- message unique id
    ,date DATETIME       DEFAULT GETDATE()   -- message time
    ,msg  VARCHAR(16384) NULL                -- message
    ,mod  VARCHAR(16384) NULL                -- preocedure/module name
    ,rc   BIGINT         NULL                -- row count
    ,err  INT            NULL                -- error number
    ,spid SMALLINT       DEFAULT @@spid      -- process id from sysprocesses
    ,suid INT            DEFAULT suser_id()  -- login id from syslogins
    ,lvl  TINYINT        DEFAULT 2           -- debug level
    ,s1   VARCHAR(16384) NULL                -- string argument 1
    ,s2   VARCHAR(16384) NULL                -- string argument 2
    ,s3   VARCHAR(16384) NULL                -- string argument 3
    ,s4   VARCHAR(16384) NULL                -- string argument 4
    ,s5   VARCHAR(16384) NULL                -- string argument 5
    ,s6   VARCHAR(16384) NULL                -- string argument 6
    ,s7   VARCHAR(16384) NULL                -- string argument 7
    ,s8   VARCHAR(16384) NULL                -- string argument 8
    ,s9   VARCHAR(16384) NULL                -- string argument 9
    ,i1   BIGINT         NULL                -- integer argument 1
    ,i2   BIGINT         NULL                -- integer argument 2
    ,i3   BIGINT         NULL                -- integer argument 3
    ,i4   BIGINT         NULL                -- integer argument 4
    ,i5   BIGINT         NULL                -- integer argument 5
    ,i6   BIGINT         NULL                -- integer argument 6
    ,i7   BIGINT         NULL                -- integer argument 7
    ,i8   BIGINT         NULL                -- integer argument 8              
    ,i9   BIGINT         NULL                -- integer argument 9
    ,d1   DATETIME       NULL                -- datetime argument 1
    ,d2   DATETIME       NULL                -- datetime argument 2
    ,d3   DATETIME       NULL                -- datetime argument 3
    ,d4   DATETIME       NULL                -- datetime argument 4
    ,d5   DATETIME       NULL                -- datetime argument 5
    ,d6   DATETIME       NULL                -- datetime argument 6
    ,d7   DATETIME       NULL                -- datetime argument 7
    ,d8   DATETIME       NULL                -- datetime argument 8
    ,d9   DATETIME       NULL                -- datetime argument 9
    ,f1   FLOAT          NULL                -- float argument 1
    ,f2   FLOAT          NULL                -- float argument 2
    ,f3   FLOAT          NULL                -- float argument 3
    ,f4   FLOAT          NULL                -- float argument 4
    ,f5   FLOAT          NULL                -- float argument 5
    ,f6   FLOAT          NULL                -- float argument 6
    ,f7   FLOAT          NULL                -- float argument 7
    ,f8   FLOAT          NULL                -- float argument 8
    ,f9   FLOAT          NULL                -- float argument 9
)
LOCK datarows
go

SETUSER
go
