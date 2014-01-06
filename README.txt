################################################################################
# LIST OF FEATURES                                                             #
################################################################################

msg        - logging stored procedure
dictionary - dictionary (key-value) table
ddl        - stored procedures to simplify common ddl commands
ngram      - implementataion of n-gram algorithm 
             for approximate matching of strings

################################################################################
# DIRICTORIES STRUCTURE                                                        #
################################################################################

---------
SQL files
---------

./features/<feature name>/database/<database name>
/<object type>/<database name>.<user name>.<object name>.sql

feature name - name of the separate feature, like msg.
database name - name of the database where object should be placed
object type - object type, like table, procedure view etc.
user name - object's owner name (dbo in most cases)
object name - name of the table/procedure/etc.

---------------
Install scripts
---------------

./features/<feature name>/install/<OS>/install.<extension>
feature name - name of the separate feature, like msg.
OS - type of the operation system where script is executed
     win - windows
	 nix - unix like
extension - extension of the shell script (cmd for win, sh for nix)

################################################################################
# INSTALL                                                                      #
################################################################################

1. Create 'util' database on you ASE.

you may use following temlate:

use master
go
disk init name = 'util_data', physname = '/data/util_data.dat', size = '200M'
go
disk init name = 'util_log', physname = '/data/util_log.dat', size = '50M'
go
create database util ON util_data = '200M' LOG ON util_log = '50M'
go
use master
go
exec sp_dboption util, 'select into/bulkcopy/pllsort', true
go
exec sp_dboption util, 'trunc log on chkpt', true
go
use util
go
checkpoint
go

2.