# agents connection
New-NetFirewallRule -DisplayName "ChangeAuditor Coordinator" -Direction Inbound -LocalPort 49352 -Protocol TCP -Action Allow

# sql agents
New-NetFirewallRule -DisplayName "SQL Server" -Direction Inbound -LocalPort 1433 -Protocol TCP -Action Allow
# Opening ports for management and agent installation (445, 135)
# Run on the target servers (Domain Controllers and file servers):
#  445 (SMB)
New-NetFirewallRule -DisplayName "Allow SMB for Agent Deployment" -Direction Inbound -LocalPort 445 -Protocol TCP -Action Allow

#  135 (RPC)
New-NetFirewallRule -DisplayName "Allow RPC for Agent Deployment" -Direction Inbound -LocalPort 135 -Protocol TCP -Action Allow

# How to verify that it worked?
# After running the commands, you can verify that the rules were created successfully using the
Get-NetFirewallRule -DisplayName "ChangeAuditor*"
