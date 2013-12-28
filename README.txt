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