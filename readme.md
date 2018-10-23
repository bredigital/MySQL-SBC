# MySQL Sheduled Backup Creator
When combined with cron, this tool automatically generates daily .sql backups,
up to a specified interval limit.

## Running
At the top of the script are configurable options, primarily paths and 
intervals. The script looks for `deconf.ini` which will contain [Client] info
for logging in to MySQL. 

The script will automatically store YYYYMMDD folders of backups in the enclosed
directory. You may edit the path to change this to being elsewhere, so long as
the executing user has access to said directory.