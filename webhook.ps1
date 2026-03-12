# 1. Load Module
$modulePath = "C:\Program Files\Quest\ChangeAuditor\Client\ChangeAuditor.PowerShell.dll"
if (!(Get-Module -Name Quest.ChangeAuditor.PowerShell)) { Import-Module $modulePath }

# 2. Connect (Using a Retry logic or ensuring it's fresh)
$connection = Connect-CAClient -ComputerName "192.168.1.10" -Port 61023

# 3. Cleanup existing ones
Write-Host "Cleaning up old subscriptions..." -ForegroundColor Cyan
Get-CAEventWebhookSubscriptions -Connection $connection | Remove-CAEventWebhookSubscription -Connection $connection

# 4. Target Variables
$notificationUrl = "https://1ea59b9b-7376-4ac0-a120-03c5378c0f29.mock.pstmn.io/webhook"
$myToken = "Bearer TEST_TOKEN_123"

# 5. Select Subsystems (FIXED SYNTAX: Using -in instead of -eq for multiple values)
$subsystemNames = @("Active Directory", "Change Auditor")
$selectedSubsystems = Get-CAEventExportSubsystems -Connection $connection | Where-Object DisplayName -in $subsystemNames

# Check if we actually found the subsystems before continuing
if ($null -eq $selectedSubsystems) {
    Write-Error "Could not find subsystems! Check your connection to the Coordinator."
    return
}

# 6. Create Subscription
Write-Host "Creating new subscription for: $($subsystemNames -join ', ')" -ForegroundColor Green
$newSub = New-CAEventWebhookSubscription -Connection $connection `
    -NotificationUrl $notificationUrl `
    -Subsystems $selectedSubsystems `
    -BatchSize 1

# 7. Apply Authorization
if ($newSub) {
    Write-Host "Injecting Authorization Token..." -ForegroundColor Green
    Set-CAEventWebhookSubscription -Connection $connection `
        -SubscriptionId $newSub.Id `
        -AuthorizationId $myToken
}

# 8. Final Verification
Write-Host "Final Configuration Summary:" -ForegroundColor Yellow
Get-CAEventWebhookSubscriptions -Connection $connection | Format-List Id, NotificationUrl, Enabled, EventsSent, AuthorizationId

Get-CAEventWebhookSubscriptions -Connection $connection | Where-Object Id -eq "0b341fcf-9f6b-4b06-901c-e275153fc862" | Select-Object Id, AuthorizationId
