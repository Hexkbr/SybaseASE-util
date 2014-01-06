EXECUTE util.dbo.dict_set @group = 'DDL_TYPES'
                         ,@key   = 'P'
                         ,@value = 'PROCEDURE'
go
EXECUTE util.dbo.dict_set @group = 'DDL_TYPES'
                         ,@key   = 'U'
                         ,@value = 'TABLE'
go
EXECUTE util.dbo.dict_set @group = 'DDL_TYPES'
                         ,@key   = 'V'
                         ,@value = 'VIEW'
go
EXECUTE util.dbo.dict_set @group = 'DDL_TYPES'
                         ,@key   = 'SF'
                         ,@value = 'FUNCTION'
go