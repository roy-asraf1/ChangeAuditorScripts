# 1. Stop the SQL Server service to prepare for Single-User mode
Stop-Service MSSQLSERVER -Force

# 2. Find the SQL Server executable path and start it in Single-User mode (-m)
$sqlBin = (Get-ChildItem "C:\Program Files\Microsoft SQL Server" -Recurse -Filter "sqlservr.exe" -ErrorAction SilentlyContinue | Select-Object -First 1).FullName
Write-Host "Starting SQL in Single-User mode: $sqlBin -m"
Start-Process -FilePath $sqlBin -ArgumentList "-m" -WindowStyle Minimized

# Wait for the service to initialize
Start-Sleep -Seconds 10

# 3. Create the Login and grant sysadmin role to your user
# This command connects locally and adds your Windows user to the sysadmin group
Write-Host "Granting sysadmin permissions..."
sqlcmd -E -S . -Q "CREATE LOGIN [LAB\Administrator] FROM WINDOWS; ALTER SERVER ROLE sysadmin ADD MEMBER [LAB\Administrator];"
#---------------------------------------------------------------------------------------
# 4. Terminate the Single-User process and restart the service normally
Write-Host "Restarting SQL Server service..."
Get-Process sqlservr -ErrorAction SilentlyContinue | Stop-Process -Force
Start-Sleep -Seconds 5
Start-Service MSSQLSERVER

# 5. Finished
Write-Host "Process complete. You should now be able to log in to SSMS with sysadmin rights."


