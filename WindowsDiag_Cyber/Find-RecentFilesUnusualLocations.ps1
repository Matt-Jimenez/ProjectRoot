<#
.SYNOPSIS
    Finds recently modified or created files in specified (often unusual) locations.
.DESCRIPTION
    This script searches through a list of base paths for files that have been
    written to or created within a specified number of days. This can help
    identify malware drop locations or recently changed configuration files.
.PARAMETER BasePaths
    An array of strings specifying the base directories to search within.
    Defaults to common user AppData, Windows Temp, and root Temp locations.
.PARAMETER DaysOld
    Integer specifying the maximum age (in days) of files to find based on LastWriteTime.
    Defaults to 7 days.
.PARAMETER ExtensionsToFocus
    An array of strings for file extensions to specifically look for (e.g., ".exe", ".dll", ".ps1").
    If not specified, all file types are considered. Include the dot (e.g., ".exe").
.OUTPUTS
    Outputs objects containing FullName, LastWriteTime, CreationTime, Length, and Owner of found files.
.EXAMPLE
    .\Find-RecentFilesUnusualLocations.ps1
    Searches default locations for files modified/created in the last 7 days.

.EXAMPLE
    .\Find-RecentFilesUnusualLocations.ps1 -DaysOld 3
    Searches default locations for files modified/created in the last 3 days.

.EXAMPLE
    .\Find-RecentFilesUnusualLocations.ps1 -BasePaths "C:\ProgramData", "C:\Users\Public\Downloads" -DaysOld 1 -ExtensionsToFocus ".exe", ".zip"
    Searches C:\ProgramData and C:\Users\Public\Downloads for .exe or .zip files modified/created in the last 24 hours.
.NOTES
    Author: Trae AI
    Version: 1.0
    Accessing some user profile paths might be restricted if not running as that user or Administrator.
#>
param (
    [string[]]$BasePaths = @(
        "$env:SystemDrive\Users\*\AppData\Local\Temp",
        "$env:SystemDrive\Users\*\AppData\Local",
        "$env:SystemDrive\Users\*\AppData\Roaming",
        "$env:SystemDrive\Windows\Temp",
        "$env:SystemDrive\Temp",
        "$env:PUBLIC\Downloads",
        "$env:USERPROFILE\Downloads" # Current user's downloads
    ),
    [int]$DaysOld = 7,
    [string[]]$ExtensionsToFocus
)

Write-Host "--- Searching for Recent Files in Specified Locations (Last $DaysOld days) ---" -ForegroundColor Yellow
if ($ExtensionsToFocus) {
    Write-Host "Focusing on extensions: $($ExtensionsToFocus -join ', ')" -ForegroundColor Cyan
}

$thresholdDate = (Get-Date).AddDays(-$DaysOld)
$foundFiles = @()

foreach ($basePathItem in $BasePaths) {
    # Expand wildcard paths like C:\Users\*
    $expandedPaths = Resolve-Path -Path $basePathItem -ErrorAction SilentlyContinue
    if (-not $expandedPaths) {
        Write-Verbose "Base path not found or not accessible: $basePathItem"
        continue
    }

    foreach ($resolvedPath in $expandedPaths) {
        if (Test-Path -Path $resolvedPath.ProviderPath -PathType Container) {
            Write-Host "`nSearching in: $($resolvedPath.ProviderPath)" -ForegroundColor Cyan
            $files = Get-ChildItem -Path $resolvedPath.ProviderPath -Recurse -File -Force -ErrorAction SilentlyContinue
            
            foreach ($file in $files) {
                if ($file.LastWriteTime -gt $thresholdDate -or $file.CreationTime -gt $thresholdDate) {
                    if ($ExtensionsToFocus) {
                        if ($ExtensionsToFocus -contains $file.Extension) {
                            $foundFiles += $file
                        }
                    } else {
                        $foundFiles += $file
                    }
                }
            }
        } else {
             Write-Verbose "Skipping non-container path: $($resolvedPath.ProviderPath)"
        }
    }
}

if ($foundFiles.Count -gt 0) {
    Write-Host "`n--- Found $($foundFiles.Count) Recent File(s) ---" -ForegroundColor Green
    $foundFiles | Sort-Object LastWriteTime -Descending | Select-Object FullName, @{N="Owner";E={(Get-Acl $_.FullName).Owner}}, LastWriteTime, CreationTime, Length | Format-Table -AutoSize -Wrap
} else {
    Write-Host "`n--- No recent files found matching criteria in the specified locations. ---" -ForegroundColor Green
}

Write-Host "`n--- Recent File Search Finished ---" -ForegroundColor Green