USE util
go
SETUSER 'dbo'
go

IF EXISTS (SELECT 1 
             FROM dbo.sysobjects 
            WHERE id = OBJECT_ID('dbo.dict_addgroup')
              AND type = 'P') BEGIN
    EXECUTE util.dbo.msg 'DROP PROCEDURE dbo.dict_addgroup'
    EXECUTE ('DROP PROCEDURE dbo.dict_addgroup')
END
go

EXECUTE util.dbo.msg 'CREATE PROCEDURE dbo.dict_addgroup'
go

CREATE PROCEDURE dbo.dict_addgroup
 @name   VARCHAR(50)
,@id     UNSIGNED SMALLINT = NULL OUTPUT
,@dbglvl CHAR(4) = 'ALL'
AS
BEGIN
    DECLARE @mod VARCHAR(255)
    SELECT @mod = OBJECT_NAME(@@procid)
    
    -- Check group name is valid string
    IF LEN(@name) < 1 BEGIN
        EXECUTE util.dbo.msg 'Invalid group name %1!'
                            ,@mod = @mod, @dbglvl = @dbglvl
                            ,@lvl = 'EROR'
                            ,@s1  = @name
        RETURN 50100
    END
    
    -- Check given id and name already exists
    IF EXISTS (
    SELECT 1 
    FROM   util.dbo.dictgrps
    WHERE  id   = ISNULL(@id, id)
    AND    name = @name
    ) BEGIN
        EXECUTE util.dbo.msg 'Group %1! with id %2! already exists'
                            ,@mod = @mod, @dbglvl = @dbglvl
                            ,@lvl = 'INFO'
                            ,@s1  = @name
                            ,@i2  = @id
                            
        -- resolve existing group id (for OUTPUT)
        IF @id IS NULL BEGIN
            SELECT @id = id
            FROM   util.dbo.dictgrps
            WHERE  name = @name
        END
        RETURN 50101
    END
    
    -- Check if given id already in use
    IF EXISTS (
    SELECT 1 
    FROM   util.dbo.dictgrps
    WHERE  id = @id
    ) BEGIN
        EXECUTE util.dbo.msg 'Group id %1! already in use'
                            ,@mod = @mod, @dbglvl = @dbglvl
                            ,@lvl = 'EROR'
                            ,@i1  = @id
        RETURN 50102
    END

    -- Check if group name already exists
    IF EXISTS (
    SELECT 1 
    FROM   util.dbo.dictgrps
    WHERE  name = @name
    ) BEGIN
        EXECUTE util.dbo.msg 'Group %1! aleady exists'
                            ,@mod = @mod, @dbglvl = @dbglvl
                            ,@lvl = 'EROR'
                            ,@s1  = @name
        RETURN 50103
    END
    
    -- find avaliable id if not given
    IF @id IS NULL BEGIN
        -- Find first smallest avaliable id
        SELECT    @id = ISNULL(MIN(dg1.id + 1),0)
        FROM      util.dbo.dictgrps dg1
        LEFT JOIN util.dbo.dictgrps dg2
        ON        dg2.id = dg1.id + 1
        WHERE     dg2.id IS NULL
    END
    
    INSERT INTO util.dbo.dictgrps (id, name)
    VALUES      (@id, @name)
    
    EXECUTE util.dbo.msg 'New group %1! with group id %2! is created'
                        ,@mod = @mod, @dbglvl = @dbglvl
                        ,@lvl = 'INFO'
                        ,@s1  = @name
                        ,@i2  = @id
    RETURN 0
END
go

SETUSER
go