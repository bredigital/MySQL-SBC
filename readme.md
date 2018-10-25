# MySQL Sheduled Backup Creator
Simple Powershell script that - combined with Windows Task Sheduler - will
generate `.sql` dump files on a specified interval rate with minimal
configuration and no manual intervention.

## Configuration
The `deconf.ini` file is used by MySQL dump to login to your MySQL server. This
user needs backup privileges to all databases desired to be backed up.

In the `sbc.ps1` file is a small section entitled Options. Here you can change
the settings to suit your preferences.

## Running
Once configured, simply call `sbc.ps1` from a Powershell prompt in the installed
directory, and the SBC will begin exporting databases instantly. 

The script will generate folders based on YYYYMMDD with a dump file for each
database on the connected server. Once the maximum limit has been reached, the
system will prune the oldest folder in order to continue.