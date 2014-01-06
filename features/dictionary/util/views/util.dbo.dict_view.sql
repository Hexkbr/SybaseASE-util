USE util
go
SETUSER 'dbo'
go

IF EXISTS (SELECT 1 
             FROM dbo.sysobjects 
            WHERE id = OBJECT_ID('dbo.dict_view')
              AND type = 'V') BEGIN
    EXECUTE util.dbo.msg 'DROP VIEW dbo.dict_view'
    EXECUTE ('DROP VIEW dbo.dict_view')
END
go

EXECUTE util.dbo.msg 'CREATE PROCEDURE dbo.dict_view'
go

CREATE VIEW dbo.dict_view
AS
SELECT
 grp = dg.name
,k   = d.k
,v   = d.v
FROM dict d 
JOIN dictgrps dg
ON   d.grpid = dg.id
go

SETUSER
go