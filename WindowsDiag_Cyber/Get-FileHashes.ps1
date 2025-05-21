<#
.SYNOPSIS
    Calculates and displays file hashes for specified files or directories.
.DESCRIPTION
    This script calculates cryptographic hashes (e.g., SHA256, MD5) for one or more files.
    If a directory is specified, it can recursively hash all files within that directory.
    This is useful for integrity checking and identifying tampered files.
.PARAMETER Path
    An array of strings specifying the full path(s) to the file(s) or director(y/ies) to hash.
    This parameter is mandatory.
.PARAMETER Algorithm
    Specifies the hash algorithm to use. Defaults to SHA256.
    Common values: SHA1, SHA256, SHA384, SHA512, MD5.
.PARAMETER Recurse
    If specified and a path is a directory, the script will recursively process all files
    within that directory and its subdirectories.
.OUTPUTS
    Outputs custom objects containing the Algorithm, Hash, and Path for each file.
.EXAMPLE
    .\Get-FileHashes.ps1 -Path "C:\Windows\System32\kernel32.dll"
    Calculates the SHA256 hash for kernel32.dll.

.EXAMPLE
    .\Get-FileHashes.ps1 -Path "C:\Windows\System32\drivers\etc\hosts", "C:\Windows\notepad.exe" -Algorithm MD5
    Calculates the MD5 hash for the hosts file and notepad.exe.

.EXAMPLE
    .\Get-FileHashes.ps1 -Path "C:\Program Files\MyApplication" -Recurse
    Calculates SHA256 hashes for all files within C:\Program Files\MyApplication and its subfolders.
.NOTES
    Author: Trae AI
    Version: 1.0
#>
param (
    [Parameter(Mandatory=$true)]
    [string[]]$Path,

    [ValidateSet('SHA1', 'SHA256', 'SHA384', 'SHA512', 'MD5')]
    [string]$Algorithm = 'SHA256',

    [switch]$Recurse
)

Write-Host "--- Calculating File Hashes (Algorithm: $Algorithm) ---" -ForegroundColor Yellow

foreach ($itemPath in $Path) {
    if (Test-Path -Path $itemPath) {
        if (Get-Item $itemPath | Select-Object -ExpandProperty PSIsContainer) {
            # It's a directory
            Write-Host "`nProcessing directory: $itemPath" -ForegroundColor Cyan
            $filesToHash = Get-ChildItem -Path $itemPath -File -Recurse:$Recurse.IsPresent -ErrorAction SilentlyContinue
            if ($filesToHash.Count -eq 0) {
                Write-Host "No files found in directory $itemPath (Recurse: $($Recurse.IsPresent))."
                continue
            }
        } else {
            # It's a file
            $filesToHash = Get-Item -Path $itemPath -ErrorAction SilentlyContinue
        }

        foreach ($file in $filesToHash) {
            try {
                Write-Verbose "Hashing file: $($file.FullName)"
                $hash = Get-FileHash -Path $file.FullName -Algorithm $Algorithm -ErrorAction Stop
                [PSCustomObject]@{
                    Algorithm = $hash.Algorithm
                    Hash      = $hash.Hash
                    Path      = $hash.Path
                }
            }
            catch {
                Write-Warning "Could not calculate hash for $($file.FullName). Error: $($_.Exception.Message)"
            }
        }
    } else {
        Write-Warning "Path not found: $itemPath"
    }
} | Format-Table -AutoSize -Wrap

Write-Host "`n--- File Hashing Finished ---" -ForegroundColor Green