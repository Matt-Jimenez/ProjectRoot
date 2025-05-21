<#
.SYNOPSIS
    Gathers comprehensive system information including OS, hardware, network, and recent updates.
.DESCRIPTION
    This script collects and displays:
    - Operating System details
    - BIOS information
    - Processor information
    - Memory (RAM) details
    - Disk drive information
    - Network adapter configurations
    - Installed hotfixes (Windows Updates)
    - Basic computer information (domain, manufacturer, model)
.OUTPUTS
    Outputs formatted information to the console.
.NOTES
    Author: Trae AI
    Version: 1.0
#>

Write-Host "--- Operating System Information ---" -ForegroundColor Yellow
Get-CimInstance Win32_OperatingSystem | Select-Object Caption, Version, OSArchitecture, InstallDate, LastBootUpTime, Manufacturer, SystemDirectory, WindowsDirectory | Format-List

Write-Host "`n--- BIOS Information ---" -ForegroundColor Yellow
Get-CimInstance Win32_BIOS | Select-Object Manufacturer, Name, Version, ReleaseDate | Format-List

Write-Host "`n--- Processor Information ---" -ForegroundColor Yellow
Get-CimInstance Win32_Processor | Select-Object Name, Manufacturer, MaxClockSpeed, NumberOfCores, NumberOfLogicalProcessors, SocketDesignation | Format-List

Write-Host "`n--- Memory (RAM) Information ---" -ForegroundColor Yellow
Get-CimInstance Win32_PhysicalMemory | Select-Object BankLabel, Capacity, Manufacturer, PartNumber, Speed, DeviceLocator | Format-Table -AutoSize
Write-Host "Total Physical Memory: $((Get-CimInstance Win32_ComputerSystem).TotalPhysicalMemory / 1GB -as [int]) GB"

Write-Host "`n--- Disk Drive Information ---" -ForegroundColor Yellow
Get-CimInstance Win32_DiskDrive | Select-Object Model, InterfaceType, MediaType, Partitions, Size, Status | Format-Table -AutoSize
Get-CimInstance Win32_LogicalDisk | Where-Object {$_.DriveType -eq 3} | Select-Object DeviceID, VolumeName, FileSystem, Size, FreeSpace | Format-Table -AutoSize

Write-Host "`n--- Network Adapter Configuration ---" -ForegroundColor Yellow
Get-CimInstance Win32_NetworkAdapterConfiguration | Where-Object {$_.IPEnabled} | Select-Object Description, IPAddress, IPSubnet, DefaultIPGateway, DNSServerSearchOrder, MACAddress | Format-List

Write-Host "`n--- Installed Hotfixes (Windows Updates) ---" -ForegroundColor Yellow
Get-HotFix | Sort-Object InstalledOn -Descending | Select-Object HotFixID, Description, InstalledOn, InstalledBy | Format-Table -AutoSize -Wrap

Write-Host "`n--- Basic Computer Information ---" -ForegroundColor Yellow
Get-ComputerInfo | Select-Object CsManufacturer, CsModel, CsName, CsDomain, WindowsProductName, WindowsVersion, OsHardwareAbstractionLayer | Format-List

Write-Host "`n--- Script Execution Finished ---" -ForegroundColor Green