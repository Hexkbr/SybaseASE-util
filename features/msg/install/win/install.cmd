call ISQL %* -i ..\..\database\util\tables\util.dbo.msgs.sql -o .\out\util.dbo.msgs.sql.out -w 5000 -D util
call ISQL %* -i ..\..\database\util\views\util.dbo.vmsgs.sql -o .\out\util.dbo.vmsgs.sql.out -w 5000 -D util
call ISQL %* -i ..\..\database\util\functions\util.dbo.msglvl.sql -o .\out\util.dbo.msglvl.sql.out -w 5000 -D util
call ISQL %* -i ..\..\database\util\procedures\util.dbo.msg.sql  -o .\out\util.dbo.msg.sql.out -w 5000 -D util

