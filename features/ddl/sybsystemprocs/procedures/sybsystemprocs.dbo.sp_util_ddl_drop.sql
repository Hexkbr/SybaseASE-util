USE sybsystemprocs
go
SETUSER 'dbo'
go

IF EXISTS (SELECT 1 
             FROM dbo.sysobjects 
            WHERE id = OBJECT_ID('dbo.sp_util_ddl_drop')
              AND type = 'P') BEGIN
    EXECUTE util.dbo.msg 'DROP PROCEDURE dbo.sp_util_ddl_drop'
    EXECUTE ('DROP PROCEDURE dbo.sp_util_ddl_drop')
END
go

EXECUTE util.dbo.msg 'CREATE PROCEDURE dbo.sp_util_ddl_drop'
go

CREATE PROCEDURE dbo.sp_util_ddl_drop
 @name     LONGSYSNAME = NULL 
,@id       INT         = NULL
,@dbglvl   CHAR(4)     = 'ALL'
,@ifexists BIT         = 1
AS
BEGIN
    DECLARE @cnt  INT
           ,@type CHAR(2)
           ,@sql  VARCHAR(16384)
           ,@mod  VARCHAR(255)
    
    SET @mod = 'sp_util_ddl_drop'
    
    -- At least one of @name or @id should be specified
    IF @name IS NULL AND @id IS NULL BEGIN
        EXECUTE util.dbo.msg 
                'At least one parameter @name or @id should be specified'
               ,@mod = @mod, @dbglvl = @dbglvl
               ,@lvl = 'EROR'
        RETURN 50200
    END
    
    -- Get count of matched objects, type and id/name
    SELECT @cnt  = COUNT(1) 
          ,@id   = ISNULL(@id, id)
          ,@name = ISNULL(@name, name)
          ,@type = type
    FROM   dbo.sysobjects
    WHERE  id   = ISNULL(@id, id)
    AND    name = ISNULL(@name, name)
    GROUP BY name
    
    -- Check that we have only one object with given name
    IF ISNULL(@cnt,0) = 0 BEGIN
        IF @ifexists = 0 BEGIN
            EXECUTE util.dbo.msg 
                    'No one object found with name %1! (id=%2!)'
                   ,@mod = @mod, @dbglvl = @dbglvl
                   ,@lvl = 'EROR'
                   ,@s1  = @name
                   ,@i2  = @id
        END ELSE BEGIN
            EXECUTE util.dbo.msg 
                    'No one object found with name %1! (id=%2!)'
                   ,@mod = @mod, @dbglvl = @dbglvl
                   ,@lvl = 'INFO'
                   ,@s1  = @name
                   ,@i2  = @id        
        END
            RETURN 50201
    END ELSE IF @cnt > 1 BEGIN
        EXECUTE util.dbo.msg 
                'More then one (%1!) objects where found with name %2! (id=%3!)'
               ,@mod = @mod, @dbglvl = @dbglvl
               ,@lvl = 'EROR'
               ,@i1  = @cnt
               ,@s2  = @name
               ,@i3  = @id
        RETURN 50202
    END
    
    -- Check that object type is one from supported list
    IF NOT EXISTS (
    SELECT 1 
    FROM util.dbo.dict_view
    WHERE grp = 'DDL_TYPES'
    AND   k   = @type) BEGIN
        EXECUTE util.dbo.msg 
                'Object type %1! is not supported'
               ,@mod = @mod, @dbglvl = @dbglvl
               ,@lvl = 'EROR'
               ,@s1  = @type
        RETURN 50203
    END
    
    SELECT @sql = 'DROP ' + v + ' ' + @name
    FROM   util.dbo.dict_view
    WHERE  grp = 'DDL_TYPES'
    AND    k   = @type
    
    EXECUTE util.dbo.msg 'Execute command %1! ...'
               ,@mod = @mod, @dbglvl = @dbglvl
               ,@lvl = 'INFO'
               ,@s1  = @sql
    
    EXECUTE (@sql)

    EXECUTE util.dbo.msg 'Done'
               ,@mod = @mod, @dbglvl = @dbglvl
               ,@lvl = 'INFO'
    
END
go


SETUSER
go