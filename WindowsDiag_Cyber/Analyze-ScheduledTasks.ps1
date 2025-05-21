<#
.SYNOPSIS
    Retrieves and analyzes scheduled tasks for potential anomalies.
.DESCRIPTION
    This script lists scheduled tasks and flags tasks that might be suspicious, such as:
    - Tasks with no Author.
    - Tasks running executables from temporary or unusual user profile locations.
    - Tasks with suspicious action arguments (e.g., PowerShell encoded commands).
.OUTPUTS
    Outputs a list of scheduled tasks, highlighting potentially suspicious ones.
.NOTES
    Author: Trae AI
    Version: 1.0
    Requires Administrator privileges to see all tasks.
#>

Write-Host "--- Analyzing Scheduled Tasks ---" -ForegroundColor Yellow

# Get all scheduled tasks
$tasks = Get-ScheduledTask -ErrorAction SilentlyContinue

if (-not $tasks) {
    Write-Warning "No scheduled tasks found or unable to retrieve tasks. Try running as Administrator."
    exit
}

$suspiciousTasks = @()

foreach ($task in $tasks) {
    $taskInfo = Get-ScheduledTaskInfo -TaskName $task.TaskName -TaskPath $task.TaskPath -ErrorAction SilentlyContinue
    $actions = $task.Actions
    $isSuspicious = $false
    $suspicionReason = @()

    # Check 1: No Author or SYSTEM author for user-created tasks
    if ([string]::IsNullOrWhiteSpace($taskInfo.Author) ) {
        $isSuspicious = $true
        $suspicionReason += "No Author"
    }

    # Check 2: Actions executing from unusual paths
    if ($actions) {
        foreach ($action in $actions) {
            if ($action -is [Microsoft.PowerShell.ScheduledTask.CimSTActionExecutable]) {
                $executablePath = $action.Execute
                if ($executablePath -match "\\AppData\\Local\\Temp\\" -or `
                    $executablePath -match "\\Windows\\Temp\\" -or `
                    $executablePath -match "$env:USERPROFILE\\Downloads\\" -or `
                    $executablePath -match "$env:USERPROFILE\\AppData\\(Roaming|Local)\\" -and $executablePath -notmatch "Microsoft\\WindowsApps") {
                    $isSuspicious = $true
                    $suspicionReason += "Executes from unusual path: $executablePath"
                }
                if ($action.Arguments -match "powershell.*-enc|-e |-ec |-en |-encod |-encode |-encodedcommand" ){
                    $isSuspicious = $true
                    $suspicionReason += "Potentially obfuscated PowerShell in arguments."
                }
                 if ($executablePath -match "rundll32.exe" -and $action.Arguments -match "javascript") {
                    $isSuspicious = $true
                    $suspicionReason += "Rundll32 executing JavaScript (potential Squiblydoo/Squiblytwo)."
                }
            }
        }
    }

    # Check 3: Task runs with highest privileges
    if ($task.Settings.RunOnlyIfNetworkAvailable -eq $false -and $task.Principal.RunLevel -eq 'HighestAvailable') {
        # This is common, but good to note in combination with other factors
        # $suspicionReason += "Runs with highest privileges"
    }


    if ($isSuspicious) {
        $suspiciousTasks += [PSCustomObject]@{
            TaskPath        = $task.TaskPath
            TaskName        = $task.TaskName
            State           = $task.State
            Author          = $taskInfo.Author
            LastRunTime     = $taskInfo.LastRunTime
            NextRunTime     = $taskInfo.NextRunTime
            Actions         = ($actions | ForEach-Object { $_.ToString() }) -join "; "
            Triggers        = ($task.Triggers | ForEach-Object { $_.ToString() }) -join "; "
            SuspicionReason = $suspicionReason -join ", "
        }
    }
}

if ($suspiciousTasks.Count -gt 0) {
    Write-Host "`n--- Potentially Suspicious Scheduled Tasks ---" -ForegroundColor Red
    $suspiciousTasks | Format-Table -AutoSize -Wrap
} else {
    Write-Host "`n--- No obviously suspicious scheduled tasks found based on current criteria. ---" -ForegroundColor Green
}

Write-Host "`n--- All Scheduled Tasks (Summary) ---" -ForegroundColor Cyan
Get-ScheduledTask | Select-Object TaskPath, TaskName, State, Actions, Triggers | Format-Table -AutoSize -Wrap


Write-Host "`n--- Scheduled Task Analysis Finished ---" -ForegroundColor Green