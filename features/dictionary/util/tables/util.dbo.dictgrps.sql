USE util
go
SETUSER 'dbo'
go

IF EXISTS (SELECT 1 
             FROM dbo.sysobjects 
            WHERE id = OBJECT_ID('dbo.dictgrps')
              AND type = 'U') BEGIN
    EXECUTE util.dbo.msg 'DROP TABLE dbo.dictgrps'
    EXECUTE ('DROP TABLE dbo.dictgrps')
END
go

EXECUTE util.dbo.msg 'CREATE TABLE dbo.dictgrps'
go

CREATE TABLE dbo.dictgrps (
     id   UNSIGNED SMALLINT NOT NULL
    ,name VARCHAR(50)       NOT NULL
    ,CONSTRAINT dictgrp_pk_id   PRIMARY KEY CLUSTERED (id)
    ,CONSTRAINT dictgrp_uq_name UNIQUE (name)
)
LOCK allpages
go

SETUSER
go