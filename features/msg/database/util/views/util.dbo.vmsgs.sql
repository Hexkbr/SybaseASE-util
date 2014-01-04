USE util
go
SETUSER 'dbo'
go

IF EXISTS (SELECT 1 
             FROM dbo.sysobjects 
            WHERE id = OBJECT_ID('dbo.vmsgs')
              AND type = 'V') BEGIN
    PRINT 'DROP VIEW dbo.vmsgs'
    EXECUTE ('DROP VIEW dbo.vmsgs')
END
go

PRINT 'CREATE VIEW dbo.vmsgs'	
go

/*
** Purpose: Report print messages in readable format
** EachRow: Message
** Clients: users
** DB     : util
** Keys   : id - unique identifier
** Note   : Trims login and mod fields to 20 characters
*/
CREATE VIEW dbo.vmsgs
AS
SELECT 
    id
   ,date
   ,spid
   ,login = CONVERT(VARCHAR(20), suser_name(suid))  
   ,mod = CONVERT(VARCHAR(20), mod)
   ,msg = str_replace(str_replace(str_replace(str_replace(str_replace(
          str_replace(str_replace(str_replace(str_replace(msg
,'%9!',COALESCE(s9,CONVERT(VARCHAR(20),i9),CONVERT(VARCHAR(20),d9,9)
                  ,CONVERT(VARCHAR(20),f9)))         
,'%8!',COALESCE(s8,CONVERT(VARCHAR(20),i8),CONVERT(VARCHAR(20),d8,9)
                  ,CONVERT(VARCHAR(20),f8)))                                                                                        
,'%7!',COALESCE(s7,CONVERT(VARCHAR(20),i7),CONVERT(VARCHAR(20),d7,9)
                  ,CONVERT(VARCHAR(20),f7))) 
,'%6!',COALESCE(s6,CONVERT(VARCHAR(20),i6),CONVERT(VARCHAR(20),d6,9)
                  ,CONVERT(VARCHAR(20),f6)))
,'%5!',COALESCE(s5,CONVERT(VARCHAR(20),i5),CONVERT(VARCHAR(20),d5,9)
                  ,CONVERT(VARCHAR(20),f5)))
,'%4!',COALESCE(s4,CONVERT(VARCHAR(20),i4),CONVERT(VARCHAR(20),d4,9)
                  ,CONVERT(VARCHAR(20),f4)))
,'%3!',COALESCE(s3,CONVERT(VARCHAR(20),i3),CONVERT(VARCHAR(20),d3,9)
                  ,CONVERT(VARCHAR(20),f3)))
,'%2!',COALESCE(s2,CONVERT(VARCHAR(20),i2),CONVERT(VARCHAR(20),d2,9)
                  ,CONVERT(VARCHAR(20),f2)))
,'%1!',COALESCE(s1,CONVERT(VARCHAR(20),i1),CONVERT(VARCHAR(20),d1,9)
                  ,CONVERT(VARCHAR(20),f1)))
   ,rc 
   ,err                  
FROM dbo.msgs
go

SETUSER
go