<#
.SYNOPSIS
    Lists running processes and services, with options to sort and filter.
.DESCRIPTION
    This script:
    - Lists all running processes, optionally sorted by CPU or Memory usage.
    - Lists all services and their status.
    - Can filter services by status (e.g., Running, Stopped).
.PARAMETER SortProcessesBy
    Sorts processes by 'CPU' or 'WS' (WorkingSet/Memory). Default is by Name.
.PARAMETER ServiceStatusFilter
    Filters services by status (e.g., 'Running', 'Stopped'). Default is 'All'.
.OUTPUTS
    Outputs process and service information to the console.
.NOTES
    Author: Trae AI
    Version: 1.0
#>
param(
    [ValidateSet('CPU', 'WS', 'Name')]
    [string]$SortProcessesBy = 'Name',

    [string]$ServiceStatusFilter = 'All'
)

Write-Host "--- Running Processes ---" -ForegroundColor Yellow
$processQuery = Get-Process
switch ($SortProcessesBy) {
    'CPU' { $processQuery = $processQuery | Sort-Object CPU -Descending }
    'WS'  { $processQuery = $processQuery | Sort-Object WS -Descending }
    default { $processQuery = $processQuery | Sort-Object Name }
}
$processQuery | Select-Object Name, Id, CPU, WS, Path | Format-Table -AutoSize -Wrap
Write-Host "To see full path for all processes, you might need to run PowerShell as Administrator."

Write-Host "`n--- Services Information ---" -ForegroundColor Yellow
$serviceQuery = Get-Service
if ($ServiceStatusFilter -ne 'All') {
    $serviceQuery = $serviceQuery | Where-Object {$_.Status -eq $ServiceStatusFilter}
}
$serviceQuery | Select-Object Name, DisplayName, Status, StartType | Format-Table -AutoSize -Wrap

Write-Host "`n--- Process and Service Analysis Finished ---" -ForegroundColor Green