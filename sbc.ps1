# MySQL Sheduled Backup Creator.
# By Casey Lambie for BRE Digital.
# Release version 23/3/2018. Requires Powershell greater than 4.

# -- Options --
#$username = "localbackup";
#$password = "password";

$mysqlpath = "C:\Program Files\MySQL\MySQL Server 5.7\bin";
$exportpath = "Backups"; # Fullpath preferable for non-original storage.

$maxbackups = 5;
$overwrite = 1; # 1 is true, 0 is false.
$compress = 1; # 1 is true, 0 is false. Requires Powershell 5+
# -------------

# Terminate if the user is running old Powershell, or in compatibility mode.
If ($PSVersionTable.PSVersion.Major -le 2) {
    Write-Host "This tool requires Powershell version 4 or above.";
    exit;
}

# Gets a list of all databases pending backup, including undesirable ones.
$databases = & "$mysqlpath\mysql.exe" --defaults-extra-file=deconf.ini -e "SHOW DATABASES" -N -B;
$dirCount = (Get-ChildItem -Path $exportpath -Directory -Recurse -Force).Count;

Write-Host "Starting MySQL backup Procedure.";

# Grabs date for folder name.
$oDate = Get-Date -format "yyyyMMdd";
$date = '{0:yyyyMMdd}' -f $oDate;
$dir = "$exportpath\$date";

# Remove oldest folder of backups.
if ($dirCount -ge $maxbackups) {
    $itemtbd = Get-ChildItem -Path $exportpath | Sort CreationTime | select -First 1;
    Remove-Item $exportpath\$itemtbd -Force -Recurse;
}

# Detects wether we will be terminating, or overwriting if an existing folder is present.
if ( Test-Path $dir ) { 
    if ($overwrite -eq 1) {
        Write-Host "Directory already exists. Overwriting.`n";
        Remove-Item $dir -Force -Recurse
    } else {
        Write-Host "Directory already exists. Exiting.`n";
        exit;
    }
}

# Creates path for new SQL dumps.
New-Item -ItemType Directory -Path $dir | Out-Null;
$counter = 0;

foreach ($databaseWT in $databases) {
    $database = $databaseWT.Split("`t"); # Remove unwanted tab breaks.

    # Remove undesirable system tables.
    if ($database -Match "information_schema|performance_schema|mysql|sys") { continue; }
    
    Write-Host "[" -NoNewline;Write-Host "Dumping" -ForegroundColor Green -NoNewline;Write-Host "] " -NoNewline;
    Write-Host "$database";
    
    # Grabs the SQL dump from mysqldump tool.
    & "$mysqlpath\mysqldump.exe" --defaults-extra-file=deconf.ini "$database" --result-file="$dir\$database.sql";

    $counter++;

    if ($compress -eq 1) {
        If ($PSVersionTable.PSVersion.Major -ge 5) {
            # Single-file compression, makes the zip file importable to phpMyAdmin.
            Write-Host "[" -NoNewline;Write-Host "Archive" -ForegroundColor Yellow -NoNewline;Write-Host "] " -NoNewline;
            Write-Host "$database";
            Compress-Archive -LiteralPath "$dir\$database.sql" -DestinationPath "$dir\$database.sql.zip";
            Remove-Item "$dir\$database.sql";
        } else {
            Write-Host "[" -NoNewline;Write-Host "Archive" -ForegroundColor Red -NoNewline;Write-Host "] " -NoNewline;
            Write-Host "Powershell v5 is not installed. Skipping compression.";
        }
    }
}

Write-Host "`nBackup complete. Backed up $counter databases.";
exit;