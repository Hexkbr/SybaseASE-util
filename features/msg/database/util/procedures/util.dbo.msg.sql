USE util                       	
go
SETUSER 'dbo'
go

IF EXISTS (SELECT 1 
             FROM dbo.sysobjects 
            WHERE id = OBJECT_ID('dbo.msg')
              AND type = 'P') BEGIN
    PRINT 'DROP PROCEDURE dbo.msg'
    EXECUTE ('DROP PROCEDURE dbo.msg')
END
go

PRINT 'CREATE PROCEDURE dbo.msg'
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
,@raiserror        BIT            = 1           -- RAISERROR when message level
                                                -- greather or equal to EROR

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

    DECLARE @level        TINYINT 
           ,@dbglevel     TINYINT           
           ,@errlevel     TINYINT
           ,@originalmsg  VARCHAR(16384)

    SELECT @originalmsg  = @msg
          ,@errlevel     = dbo.msglvl('EROR')
    
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
        
    IF @error != 0 AND @level < @errlevel AND @promotelvlonerr = 1
        SET @level = @errlevel

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

    IF @level >= @errlevel AND @raiserror = 1 BEGIN
        SET @msg = str_replace(str_replace(str_replace(str_replace(str_replace(
          str_replace(str_replace(str_replace(str_replace(@originalmsg
         ,'%9!',COALESCE(@s9,CONVERT(VARCHAR(20),@i9),CONVERT(VARCHAR(20),@d9,9)
                  ,CONVERT(VARCHAR(20),@f9)))         
         ,'%8!',COALESCE(@s8,CONVERT(VARCHAR(20),@i8),CONVERT(VARCHAR(20),@d8,9)
                  ,CONVERT(VARCHAR(20),@f8)))
         ,'%7!',COALESCE(@s7,CONVERT(VARCHAR(20),@i7),CONVERT(VARCHAR(20),@d7,9)
                  ,CONVERT(VARCHAR(20),@f7))) 
         ,'%6!',COALESCE(@s6,CONVERT(VARCHAR(20),@i6),CONVERT(VARCHAR(20),@d6,9)
                  ,CONVERT(VARCHAR(20),@f6)))
         ,'%5!',COALESCE(@s5,CONVERT(VARCHAR(20),@i5),CONVERT(VARCHAR(20),@d5,9)
                  ,CONVERT(VARCHAR(20),@f5)))
         ,'%4!',COALESCE(@s4,CONVERT(VARCHAR(20),@i4),CONVERT(VARCHAR(20),@d4,9)
                  ,CONVERT(VARCHAR(20),@f4)))
         ,'%3!',COALESCE(@s3,CONVERT(VARCHAR(20),@i3),CONVERT(VARCHAR(20),@d3,9)
                  ,CONVERT(VARCHAR(20),@f3)))
         ,'%2!',COALESCE(@s2,CONVERT(VARCHAR(20),@i2),CONVERT(VARCHAR(20),@d2,9)
                  ,CONVERT(VARCHAR(20),@f2)))
         ,'%1!',COALESCE(@s1,CONVERT(VARCHAR(20),@i1),CONVERT(VARCHAR(20),@d1,9)
                  ,CONVERT(VARCHAR(20),@f1)))
    
        RAISERROR 55555, @msg
    END

    RETURN @error
END
go

SETUSER
go