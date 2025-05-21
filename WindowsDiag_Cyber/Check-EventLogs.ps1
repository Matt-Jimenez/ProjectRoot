<#
.SYNOPSIS
    Retrieves recent Error and Critical events from System, Application, and Security event logs.
.DESCRIPTION
    This script queries the System, Application, and Security event logs for the most recent
    Error and Critical level events.
.PARAMETER MaxEventsPerLog
    The maximum number of events to retrieve from each log. Default is 10.
.OUTPUTS
    Outputs event log entries to the console.
.NOTES
    Author: Trae AI
    Version: 1.0
    Security log access might require Administrator privileges.
#>
param (
    [int]$MaxEventsPerLog = 10
)

$LogNames = @("System", "Application", "Security")

Write-Host "--- Checking Event Logs for Errors and Critical Events ---" -ForegroundColor Yellow
Write-Host "Displaying last $MaxEventsPerLog Error/Critical events per log (if available)."

foreach ($LogName in $LogNames) {
    Write-Host "`n--- Log: $LogName ---" -ForegroundColor Cyan
    try {
        Get-WinEvent -LogName $LogName -MaxEvents $MaxEventsPerLog -FilterXPath "*[System[Level=1 or Level=2]]" -ErrorAction Stop |
            Select-Object TimeCreated, Id, LevelDisplayName, ProviderName, Message | Format-Table -AutoSize -Wrap
    }
    catch {
        Write-Warning "Could not access or query log '$LogName'. $_.Exception.Message"
        if ($LogName -eq "Security" -and -not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
            Write-Warning "Accessing the Security log often requires Administrator privileges."
        }
    }
}

Write-Host "`n--- Event Log Check Finished ---" -ForegroundColor Green