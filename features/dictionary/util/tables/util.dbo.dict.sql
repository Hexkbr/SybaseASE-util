USE util
go
SETUSER 'dbo'
go

IF EXISTS (SELECT 1 
             FROM dbo.sysobjects 
            WHERE id = OBJECT_ID('dbo.dict')
              AND type = 'U') BEGIN
    EXECUTE util.dbo.msg 'DROP TABLE dbo.dict'
    EXECUTE ('DROP TABLE dbo.dict')
END
go

EXECUTE util.dbo.msg 'CREATE TABLE dbo.dict'
go

CREATE TABLE dbo.dict (
     id    UNSIGNED INT      IDENTITY
    ,grpid UNSIGNED SMALLINT NOT NULL
    ,k     VARCHAR(255)      NOT NULL -- key
    ,v     VARCHAR(1024)     NULL     -- value
    ,CONSTRAINT dict_pk_grpid_key PRIMARY KEY CLUSTERED (grpid, k)
    ,CONSTRAINT dict_fk_dict_dictgrps FOREIGN KEY (grpid)
                                      REFERENCES dbo.dictgrps (id)
)
LOCK allpages
go

SETUSER
go