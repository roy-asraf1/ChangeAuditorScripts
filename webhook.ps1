#connection to the system
Import-Module "C:\Program Files\Quest\ChangeAuditor\Client\ChangeAuditor.PowerShell.dll"
$connection = Connect-CAClient

#configuration
$notificationUrl = "https:/domain/api/webhook"
#$heartbeatUrl = ""
#$authId = ""



#what systems
#$selectedSubsystems = Get-CAEventExportSubsystems -Connection $connection
$selectedSubsystems = Get-CAEventExportSubsystems -Connection $connection | Where-Object DisplayName -In -Value "Active Directory", "Registry", "File System", "Change Auditor", "Exchange", "Group Policy", "Service", "Computer", "Local Account", "SQL", "ADAM (AD LDS)", "AD Query", "VMware", "SharePoint", "Logon Activity", "Microsoft 365", "Microsoft Entra", "Threat Detection", "Active Directory Federation Services", "SQL Extended Events"
New-CAEventWebhookSubscription -Connection $connection -NotificationUrl $notificationUrl -Subsystems $selectedSubsystems -BatchSize 10000



#Get-CAEventWebhookSubscriptions -Connection $connection | Format-List
New-CAEventWebhookSubscription -Connection $connection `
                               -NotificationUrl $notificationUrl `
                               -Subsystems $selectedSubsystems `
                               -HeartbeatUrl $heartbeatUrl `
                               -AuthorizationId $authId `
                               -BatchSize 10000

Get-CAEventExportSubsystems -Connection $connection | Select-Object DisplayName

#Test
#Get-CAEventWebhookSubscriptions -Connection $connection | Format-List
