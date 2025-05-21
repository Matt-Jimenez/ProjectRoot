<#
.SYNOPSIS
    Performs basic network connectivity tests and displays network configuration.
.DESCRIPTION
    This script:
    - Pings common public DNS servers and a well-known website.
    - Displays detailed IP configuration for active adapters.
    - Shows active TCP connections.
    - Attempts to resolve a common hostname.
.PARAMETER Targets
    An array of hostnames or IP addresses to ping. Defaults to "8.8.8.8", "1.1.1.1", "www.google.com".
.OUTPUTS
    Outputs test results and network information to the console.
.NOTES
    Author: Trae AI
    Version: 1.0
#>
param (
    [string[]]$TargetsToPing = @("8.8.8.8", "1.1.1.1", "www.google.com")
)

Write-Host "--- Testing Network Connectivity ---" -ForegroundColor Yellow

foreach ($target in $TargetsToPing) {
    Write-Host "`nPinging $target..."
    Test-NetConnection -ComputerName $target -WarningAction SilentlyContinue | Select-Object ComputerName, RemoteAddress, InterfaceAlias, SourceAddress, PingSucceeded, PingReplyDetails*
}

Write-Host "`n--- IP Configuration (Active Adapters) ---" -ForegroundColor Yellow
Get-NetIPConfiguration | Where-Object {$_.IPv4DefaultGateway -ne $null -and $_.NetAdapter.Status -eq 'Up'} | Format-List *

Write-Host "`n--- Active TCP Connections ---" -ForegroundColor Yellow
Get-NetTCPConnection | Select-Object LocalAddress, LocalPort, RemoteAddress, RemotePort, State, OwningProcess | Format-Table -AutoSize

Write-Host "`n--- DNS Resolution Test (google.com) ---" -ForegroundColor Yellow
Resolve-DnsName -Name "google.com" -Type A -ErrorAction SilentlyContinue

Write-Host "`n--- Network Troubleshooting Script Finished ---" -ForegroundColor Green