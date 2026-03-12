# 1. Load the Change Auditor module
Import-Module "C:\Program Files\Quest\ChangeAuditor\Client\ChangeAuditor.PowerShell.dll"

# 2. Connect to the system
$connection = Connect-CAClient 

$search = Get-CASearches $connection | Where-Object { $_.Name -eq "All Events" }
if ($null -eq $search) {
    Write-Error "Search query '$searchName' was not found in Change Auditor."
    return
}
$events = Invoke-CASearch -Connection $connection -Search $search -Limit 10

$apiUrl = "https://maccabident-itom-dev.onbmc.com/events-service/api/v1.0/events"
$headers = @{
    "Authorization" = "apiKey 779383581::TU1098DLNYI37FD6EHF25CR7E17JXK::sdFfOcDtzNzJZEwiEZnqSz64mqhSDbFfpAwwrvxUTWATXyQj7M"
    "Content-Type"  = "application/json"
}


[System.Net.WebRequest]::DefaultWebProxy.Credentials = [System.Net.CredentialCache]::DefaultNetworkCredentials

# 3. Loop through each of the returned events
foreach ($event in $events) {
    $payloadObjects = @{
		    class		   = "MX_EVENT"
            object         = "Change Auditor"
            msg            = "testtttt"
            severity       = "CRITICAL"
            mx_var1    	   = $event.TimeDetected
            mx_var2        = $event.User
            mx_var3        = $event.Workstation
            source_identifier="questtest"
        } | ConvertTo-Json 
    $payload = "[$payloadObjects]"
    $payload

    try {
        # Send the POST request to BMC (Removed the problematic flag from the end of this line)
        $response = Invoke-RestMethod -Uri $apiUrl -Method Post -Headers $headers -Body $payload
        Write-Host "Successfully sent event: $($event.EventMessage)"
    }
    catch {
        if ($_.Exception.Response) {
            $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
            $reader.BaseStream.Position = 0
            $responseBody = $reader.ReadToEnd()
            Write-Host "BMC API Error Details: $responseBody" -ForegroundColor Red
        } else {
            Write-Host "Error: $_" -ForegroundColor Red
        }
    }
}

# 4. Safely disconnect from the system
#Disconnect-CAClient $connection
