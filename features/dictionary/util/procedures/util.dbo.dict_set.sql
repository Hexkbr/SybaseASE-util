USE util
go
SETUSER 'dbo'
go

IF EXISTS (SELECT 1 
             FROM dbo.sysobjects 
            WHERE id = OBJECT_ID('dbo.dict_set')
              AND type = 'P') BEGIN
    EXECUTE util.dbo.msg 'DROP PROCEDURE dbo.dict_set'
    EXECUTE ('DROP PROCEDURE dbo.dict_set')
END
go

EXECUTE util.dbo.msg 'CREATE PROCEDURE dbo.dict_set'
go

CREATE PROCEDURE dbo.dict_set
 @key    VARCHAR(255)
,@value  VARCHAR(1024)
,@group VARCHAR(50)    = 'default'
,@dbglvl CHAR(4)       = 'ALL'
AS
BEGIN
    DECLARE @mod   VARCHAR(255)
           ,@grpid UNSIGNED SMALLINT
           
    SELECT @mod = OBJECT_NAME(@@procid)
    
    -- Check group name is valid string
    IF LEN(@key) < 1 BEGIN
        EXECUTE util.dbo.msg 'Invalid key value %1!'
                            ,@mod = @mod, @dbglvl = @dbglvl
                            ,@lvl = 'EROR'
                            ,@s1  = @key
        RETURN 50110
    END
    
    -- Create group if not exists or get id of existing group
    EXECUTE util.dbo.dict_addgroup @name = @group
                             ,@id   = @grpid OUTPUT
                           
    -- Update or insert key                           
    IF EXISTS (SELECT 1
               FROM   util.dbo.dict
               WHERE  grpid = @grpid
               AND    k     = @key) BEGIN
               
        UPDATE util.dbo.dict
        SET    v     = @value
        WHERE  grpid = @grpid
        AND    k     = @key
        
        EXECUTE util.dbo.msg 'Key %1! is updated to %2!'
                            ,@mod = @mod, @dbglvl = @dbglvl
                            ,@lvl = 'INFO'
                            ,@s1  = @key
                            ,@s2  = @value
    END ELSE BEGIN
        INSERT INTO util.dbo.dict (grpid, k, v) 
        VALUES      (@grpid, @key, @value)
        
        EXECUTE util.dbo.msg 'Key %1! is inserted with value %2!'
                            ,@mod = @mod, @dbglvl = @dbglvl
                            ,@lvl = 'INFO'
                            ,@s1  = @key
                            ,@s2  = @value
    END
    
    RETURN 0
END

SETUSER
go