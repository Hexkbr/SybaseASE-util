msg - logging stored procedure, with some additional functionality.

################################################################################
# Features                                                                     #
################################################################################

- Appends timestamp at the beginning of the each message
- Appends error number and rowcount to the end of each message
- Supports debug levels to control talkative of the logging procedure
- Incrementation functionality
- Validation of expected row count
- Logging to table (transaction safe)
- Rollback transaction, or rollback transaction on error
- Interupt session, or interupt session on error

################################################################################
# Example of usage                                                             #
################################################################################

-- Simple message
execute util.dbo.msg 'Hello world!'

-- append module/procedure name
execute util.dbo.msg 'Hello world!', 'sp_myproc'

-- specify debug level
execute util.dbo.msg 'Hello world!', 'sp_myproc', 'DEBG'

-- specify debug level for message and session (message not printed)
execute util.dbo.msg 'msg body', @lvl = 'DEBG', @dbglvl = 'EROR'

-- specify last error number and rowcount
execute util.dbo.msg 'msg body', @rowcount = @@rowcount, @error = @@error

-- store message to table
execute util.dbo.msg 'msg body', @totable = 1

-- do not print the mssage
execute util.dbo.msg 'msg body', @totable = 1, @print = 0

-- use arguments
execute util.dbo.msg 'string:%1!, int:%2!, date:%3!, float:%4!'
,@s1 = 'this is a string'
,@i2 = 43242
,@d3 = '20140101'
,@f4 = 7.77

################################################################################
# List of objects                                                              #
################################################################################

msg    - logging stored procedure
msgs   - table for messages
vmsgs  - view for user-friendly reviewing of the messages
msglvl - function which converts character representation of the debug level of 
         the message to integer (comparable) representation