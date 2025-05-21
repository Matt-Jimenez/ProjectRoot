<#
.SYNOPSIS
    Lists programs configured to run at Windows startup from common locations.
.DESCRIPTION
    This script queries:
    - Win32_StartupCommand WMI class
    - Registry Run keys (HKCU and HKLM)
    - Startup folders for the current user and all users.
.OUTPUTS
    Outputs a list of startup programs and their locations to the console.
.NOTES
    Author: Trae AI
    Version: 1.0
    Some locations might require administrator privileges for full access.
#>

Write-Host "--- Querying Startup Programs ---" -ForegroundColor Yellow

# 1. Using WMI (Win32_StartupCommand)
Write-Host "`n--- Startup Programs (WMI: Win32_StartupCommand) ---" -ForegroundColor Cyan
Get-CimInstance Win32_StartupCommand | Select-Object Name, Command, User, Location | Format-Table -AutoSize -Wrap

# 2. Registry Run Keys (Current User)
Write-Host "`n--- Startup Programs (Registry: HKCU\Software\Microsoft\Windows\CurrentVersion\Run) ---" -ForegroundColor Cyan
Get-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run" | Get-Member -MemberType NoteProperty | ForEach-Object {
    $keyName = $_.Name
    [PSCustomObject]@{
        Name    = $keyName
        Command = (Get-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run").$keyName
        Source  = "HKCU Run"
    }
} | Format-Table -AutoSize -Wrap

# 3. Registry Run Keys (Local Machine)
Write-Host "`n--- Startup Programs (Registry: HKLM\Software\Microsoft\Windows\CurrentVersion\Run) ---" -ForegroundColor Cyan
Get-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Run" | Get-Member -MemberType NoteProperty | ForEach-Object {
    $keyName = $_.Name
    [PSCustomObject]@{
        Name    = $keyName
        Command = (Get-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Run").$keyName
        Source  = "HKLM Run"
    }
} | Format-Table -AutoSize -Wrap

# 4. Registry RunOnce Keys (Current User) - These run once and are then deleted.
Write-Host "`n--- Startup Programs (Registry: HKCU\Software\Microsoft\Windows\CurrentVersion\RunOnce) ---" -ForegroundColor Cyan
Get-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\RunOnce" -ErrorAction SilentlyContinue | Get-Member -MemberType NoteProperty | ForEach-Object {
    $keyName = $_.Name
    [PSCustomObject]@{
        Name    = $keyName
        Command = (Get-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\RunOnce").$keyName
        Source  = "HKCU RunOnce"
    }
} | Format-Table -AutoSize -Wrap

# 5. Registry RunOnce Keys (Local Machine)
Write-Host "`n--- Startup Programs (Registry: HKLM\Software\Microsoft\Windows\CurrentVersion\RunOnce) ---" -ForegroundColor Cyan
Get-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\RunOnce" -ErrorAction SilentlyContinue | Get-Member -MemberType NoteProperty | ForEach-Object {
    $keyName = $_.Name
    [PSCustomObject]@{
        Name    = $keyName
        Command = (Get-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\RunOnce").$keyName
        Source  = "HKLM RunOnce"
    }
} | Format-Table -AutoSize -Wrap

# 6. Current User Startup Folder
Write-Host "`n--- Startup Programs (Current User Startup Folder) ---" -ForegroundColor Cyan
$userStartupPath = [System.Environment]::GetFolderPath('Startup')
if (Test-Path $userStartupPath) {
    Get-ChildItem -Path $userStartupPath | Select-Object Name, FullName, Target | Format-Table -AutoSize -Wrap
} else {
    Write-Host "Current User Startup folder not found or is empty: $userStartupPath"
}

# 7. All Users Startup Folder
Write-Host "`n--- Startup Programs (All Users Startup Folder) ---" -ForegroundColor Cyan
$allUsersStartupPath = [System.Environment]::GetFolderPath('CommonStartup')
if (Test-Path $allUsersStartupPath) {
    Get-ChildItem -Path $allUsersStartupPath | Select-Object Name, FullName, Target | Format-Table -AutoSize -Wrap
} else {
    Write-Host "All Users Startup folder not found or is empty: $allUsersStartupPath"
}

Write-Host "`n--- Startup Program Scan Finished ---" -ForegroundColor Green