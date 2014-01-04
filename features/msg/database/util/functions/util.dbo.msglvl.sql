USE util
go
SETUSER 'dbo'
go

IF EXISTS (SELECT 1
             FROM dbo.sysobjects 
            WHERE id = OBJECT_ID('dbo.msglvl')
              AND type = 'SF') BEGIN
    PRINT 'DROP FUNCTION dbo.msglvl'
    EXECUTE ('DROP FUNCTION dbo.msglvl')
END
go

PRINT 'CREATE FUNCTION dbo.msglvl'
go
/*
** Purpose: Determine integer equivalent of string value of debug level  
** Clients: dbo.msg
** DB     : util
** Args   : @lvl char(4) - debug level, on of the following
**        : 'TRCE' - 0   - trace
**        : 'DEBG' - 1   - debug
**        : 'INFO' - 2   - information
**        : 'WARN' - 3   - warning
**        : 'EROR' - 4   - error
**        : 'CRIT' - 5   - critical error
**        : other  - 255 - all
** Returns: TINYINT - integer, comparable, equivalent
** Note   : 
*/
CREATE FUNCTION dbo.msglvl (@lvl CHAR(4))
RETURNS TINYINT
AS
BEGIN
    DECLARE @intlvl TINYINT
    SET @lvl = UPPER(@lvl)
    SET @intlvl = CASE
                    WHEN @lvl = 'CRIT' THEN 5
                    WHEN @lvl = 'EROR' THEN 4
                    WHEN @lvl = 'WARN' THEN 3
                    WHEN @lvl = 'INFO' THEN 2
                    WHEN @lvl = 'DEBG' THEN 1
                    WHEN @lvl = 'TRCE' THEN 0
                    ELSE 255 -- 'ALL'
                  END
   RETURN @intlvl
END
go

SETUSER
go