USE util
go
SETUSER 'dbo'
go

/*
execute sp_addmessage 55555, '%1!'
go
execute sp_addmessage 50000, 'Unexpected row count. Expected %1!, actual %2!'
go
*/

IF EXISTS (SELECT 1 
             FROM dbo.sysobjects 
            WHERE id = OBJECT_ID('dbo.msg')
              AND type = 'P') BEGIN
    PRINT 'DROP PROCEDURE dbo.msg'
    EXECUTE ('DROP PROCEDURE dbo.msg')
END
go

CREATE PROCEDURE dbo.msg
 @msg              VARCHAR(16384) = NULL        -- message
,@mod              VARCHAR(255)   = NULL        -- procedure/module
/*
** Debug levels:
** 0 - TRCE
** 1 - DEBG
** 2 - INFO
** 3 - WARN
** 4 - EROR
** 5 - CRIT
*/
,@lvl              CHAR(4)        = 'ALL'       -- debug level for message
,@dbglvl           CHAR(4)        = NULL        -- debug level for session
,@rowcount         BIGINT         = NULL        -- number of processed rows
,@expectedrowcount BIGINT         = NULL        -- number of processed rows
,@error            INT            = NULL        -- error number
,@promotelvlonerr  BIT            = 1           -- promote debug level on error
,@dateformat       TINYINT        = 9           -- timestamp format
,@logseparator     VARCHAR(20)    = ' : '       -- separator 
,@rollbackonerror  BIT            = 0           -- rollback transaction
                                                -- when @error != 0 and not null
,@rollback         BIT            = 0           -- rollback tran on end
,@quitonerror      BIT            = 0           -- interupt session 
                                                -- when @error != 0 and not null
,@quit             BIT            = 0           -- interupt session on end
,@print            BIT            = 1           -- prints message when enabled
,@increment        INT            = NULL OUTPUT -- increments on each call
,@iteratorstep     INT            = 1           -- increment size
,@totable          BIT            = 0           -- prints to msgs when enabled
,@transafe         BIT            = 1           -- no DML when tran is open

/* String arguments */
,@s1 VARCHAR(16384) = NULL
,@s2 VARCHAR(16384) = NULL
,@s3 VARCHAR(16384) = NULL
,@s4 VARCHAR(16384) = NULL
,@s5 VARCHAR(16384) = NULL
,@s6 VARCHAR(16384) = NULL
,@s7 VARCHAR(16384) = NULL
,@s8 VARCHAR(16384) = NULL
,@s9 VARCHAR(16384) = NULL

/* Ineger arguments */
,@i1 BIGINT = NULL
,@i2 BIGINT = NULL
,@i3 BIGINT = NULL
,@i4 BIGINT = NULL
,@i5 BIGINT = NULL
,@i6 BIGINT = NULL
,@i7 BIGINT = NULL
,@i8 BIGINT = NULL
,@i9 BIGINT = NULL

/* Datetime arguments */
,@d1 DATETIME = NULL                              
,@d2 DATETIME = NULL                              
,@d3 DATETIME = NULL                              
,@d4 DATETIME = NULL                              
,@d5 DATETIME = NULL                              
,@d6 DATETIME = NULL                              
,@d7 DATETIME = NULL                              
,@d8 DATETIME = NULL                              
,@d9 DATETIME = NULL                              

/* Float arguments */
,@f1 FLOAT = NULL                              
,@f2 FLOAT = NULL                              
,@f3 FLOAT = NULL                              
,@f4 FLOAT = NULL                              
,@f5 FLOAT = NULL                              
,@f6 FLOAT = NULL                              
,@f7 FLOAT = NULL                              
,@f8 FLOAT = NULL                              
,@f9 FLOAT = NULL                              

AS
BEGIN
    SELECT @rowcount = ISNULL(@rowcount, @@rowcount) 
          ,@error    = ISNULL(@error   , @@error   )

    DECLARE @level    TINYINT 
           ,@dbglevel TINYINT           
    
    IF @increment IS NOT NULL BEGIN
        SET @increment = @increment + @iteratorstep
        SET @msg = str_replace(@msg,'{@i}',CONVERT(VARCHAR(20),@increment))
    END
    
    IF  @expectedrowcount IS NOT NULL 
    AND @expectedrowcount != @rowcount BEGIN
        IF @error = 0
            SET @error = 50000 /* Unexpected row count. */
    END
    
    SELECT @level    = dbo.msglvl (@lvl)
          ,@dbglevel = dbo.msglvl (ISNULL(@dbglvl,@lvl))
        
    IF @error != 0 AND @level < 4 AND @promotelvlonerr = 1
        SET @level = 4

    -- Display message when
    IF @level >= @dbglevel BEGIN
        -- Convert arguments to varchar
        SELECT 
             @s1 = COALESCE(@s1,CONVERT(VARCHAR(20),@i1            )
                               ,CONVERT(VARCHAR(20),@d1,@dateformat)
                               ,CONVERT(VARCHAR(20),@f1            )
                           )
            ,@s2 = COALESCE(@s2,CONVERT(VARCHAR(20),@i2            )
                               ,CONVERT(VARCHAR(20),@d2,@dateformat)
                               ,CONVERT(VARCHAR(20),@f2            )
                           )
            ,@s3 = COALESCE(@s3,CONVERT(VARCHAR(20),@i3            )
                               ,CONVERT(VARCHAR(20),@d3,@dateformat)
                               ,CONVERT(VARCHAR(20),@f3            )
                           )
            ,@s4 = COALESCE(@s4,CONVERT(VARCHAR(20),@i4            )
                               ,CONVERT(VARCHAR(20),@d4,@dateformat)
                               ,CONVERT(VARCHAR(20),@f4            )
                           )
            ,@s5 = COALESCE(@s5,CONVERT(VARCHAR(20),@i5            )
                               ,CONVERT(VARCHAR(20),@d5,@dateformat)
                               ,CONVERT(VARCHAR(20),@f5            )
                           )
            ,@s6 = COALESCE(@s6,CONVERT(VARCHAR(20),@i6            )
                               ,CONVERT(VARCHAR(20),@d6,@dateformat)
                               ,CONVERT(VARCHAR(20),@f6            )
                           )
            ,@s7 = COALESCE(@s7,CONVERT(VARCHAR(20),@i7            )
                               ,CONVERT(VARCHAR(20),@d7,@dateformat)
                               ,CONVERT(VARCHAR(20),@f7            )
                           )
            ,@s8 = COALESCE(@s8,CONVERT(VARCHAR(20),@i8            )
                               ,CONVERT(VARCHAR(20),@d8,@dateformat)
                               ,CONVERT(VARCHAR(20),@f8            )
                           )
            ,@s9 = COALESCE(@s9,CONVERT(VARCHAR(20),@i9            )
                               ,CONVERT(VARCHAR(20),@d9,@dateformat)
                               ,CONVERT(VARCHAR(20),@f9            )
                           )
                           
         -- Insert into msgs table
         IF  @totable = 1
         AND (     @transafe  = 0 
               OR @@trancount = 0 )
            INSERT INTO dbo.msgs (msg,mod,rc,err,lvl
            ,s1,s2,s3,s4,s5,s6,s7,s8,s9
            ,i1,i2,i3,i4,i5,i6,i7,i8,i9
            ,d1,d2,d3,d4,d5,d6,d7,d8,d9
            ,f1,f2,f3,f4,f5,f6,f7,f8,f9)
            VALUES (@msg, @mod, @rowcount, @error, @level
            ,@s1,@s2,@s3,@s4,@s5,@s6,@s7,@s8,@s9
            ,@i1,@i2,@i3,@i4,@i5,@i6,@i7,@i8,@i9   
            ,@d1,@d2,@d3,@d4,@d5,@d6,@d7,@d8,@d9
            ,@f1,@f2,@f3,@f4,@f5,@f6,@f7,@f8,@f9)
        
        -- Prepare message
        SET @msg = CONVERT(VARCHAR,getdate(),@dateformat) + @logseparator
            + @lvl + @logseparator
            + @mod + @logseparator + @msg
            + ' (err=' + CONVERT(VARCHAR,@error)
            + ',cnt='+CONVERT(VARCHAR,@rowcount) + ')'
        
        -- Print message
        IF @print = 1
            PRINT @msg, @s1, @s2, @s3, @s4, @s5, @s6, @s7, @s8, @s9
    END

    -- Log error message when unexpected rowcount
    IF @error = 50000 BEGIN
        IF @level >= @dbglevel BEGIN
            SET @msg = CONVERT(VARCHAR,getdate(),@dateformat) + @logseparator
                     + @lvl + @logseparator
                     + @mod + @logseparator 
                     + 'Unexpected row count. '
                     + 'Expected ' + CONVERT(VARCHAR(20), @expectedrowcount)
                     + ', actual ' + CONVERT(VARCHAR(20), @rowcount        )
            IF @print = 1
                PRINT @msg
            IF @totable = 1 AND (@transafe = 0 OR @@trancount = 0)
                INSERT INTO dbo.msgs ( msg,  mod,  lvl  ) 
                             VALUES  (@msg, @mod, @level)
        END
    END
    
    -- If open transaction and either rollback options enabled 
    -- or error and rollback on error is enabled
    -- rollback the transaction
    IF ((@error != 0 AND @rollbackonerror = 1) OR @rollback = 1) 
       AND @@trancount > 0 BEGIN
        IF @level >= @dbglevel BEGIN
            SET @msg = CONVERT(VARCHAR,getdate(),@dateformat) + @logseparator
                     + @lvl + @logseparator
                     + @mod + @logseparator 
                     + 'Rollback transaction'
            IF @print = 1
                PRINT @msg
            IF @totable = 1 AND (@transafe = 0 OR @@trancount = 0)
                INSERT INTO dbo.msgs ( msg,  mod,  lvl  ) 
                             VALUES  (@msg, @mod, @level)
        END
        ROLLBACK
    END
    
    -- When quit option is on or error and quit on error is on
    -- interupt session with syb_quit()
    IF (@error != 0 AND @quitonerror = 1) OR @quit = 1 BEGIN
        IF @level >= @dbglevel BEGIN
            SET @msg = CONVERT(VARCHAR,getdate(),@dateformat) + @logseparator
                     + @lvl + @logseparator        
                     + @mod + @logseparator 
                     + 'syb_quit()'
            IF @print = 1
                PRINT @msg
            IF @totable = 1 AND (@transafe = 0 OR @@trancount = 0)
                INSERT INTO dbo.msgs ( msg,  mod,  lvl  ) 
                             VALUES  (@msg, @mod, @level)
        END
        SELECT syb_quit()
    END
    RETURN @error
END
go

SETUSER
go

/*
-- TEST
execute msg
go
execute msg 'My message'
go
execute msg 'My message', @mod = 'PROC1'
go
execute msg 'My message', @mod = 'PROC1',  @rowcount = 345
go
execute msg 'My message', @rowcount = 345, @expectedrowcount = 3
go
declare @retval int
execute @retval = msg 'My message', @rowcount = 345, @expectedrowcount = 3
print '%1!', @retval
go
execute msg 'My message', @error = 234
go
execute msg 'My message', @lvl = 'DEBG'
go
execute msg 'My message', @lvl = 'DEBG', @dbglvl = 'INFO'
go
begin tran
execute msg 'My message'
print 'trancount=%1!', @@trancount
rollback
go
begin tran
execute msg 'My message', @rollback=1
print 'trancount=%1!', @@trancount
rollback
go
begin tran
execute msg 'My message', @rollbackonerror=1
print 'trancount=%1!', @@trancount
rollback
go
begin tran
execute msg 'My message', @rollbackonerror=1, @error=2
print 'trancount=%1!', @@trancount
rollback
go
execute msg 'My message', @quitonerror=1, @error=2
go
execute msg 'My message', @quit=1
go
execute msg 'My message', @totable = 1
go
declare @i tinyint
set @i=convert(tinyint,'300')
execute msg 'My message', @quitonerror=1
go
execute msg 'My message', @print=0
go
begin tran
execute msg 'My message', @print=0, @rollback=1
print 'trancount=%1!', @@trancount
rollback
go
begin tran
execute msg 'My message (12534)', @totable = 1
commit
select * from msgs
go
begin tran
execute msg 'My message (1535)', @totable = 1, @transafe = 0
commit
select * from msgs
go
declare @i int
set @i = 0
execute msg 'My message {@i}', @increment=@i output
execute msg 'My message {@i}', @increment=@i output
execute msg 'My message {@i}', @increment=@i output, @iteratorstep = 10
go
execute msg 'My message %1! - %2! ', @s1='aa', @s2 = 'bb'
go
execute msg 'My message %1! - %2! ', @i1=123, @i2 = 777
go
execute msg 'My message %1! - %2! ', @d1='20010101'
           , @d2 = '2013-12-28 22:23:51.49'
go
execute msg 'My message %1! - %2! ', @f1=123.44, @f2 = -77.0
go
execute msg 'My message %1! - %2! ', @d1='20010101'
           , @d2 = '2013-12-28 22:23:51.49', @dateformat =4
go
execute msg 'My message', @lvl = 'DEBG', @dbglvl = 'INFO', @error = 1
go
execute msg 'My message', @lvl = 'DEBG', @dbglvl = 'INFO'
           , @error = 1, @promotelvlonerr = 0
go
*/