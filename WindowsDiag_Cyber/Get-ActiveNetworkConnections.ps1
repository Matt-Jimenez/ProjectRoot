<#
.SYNOPSIS
    Lists active TCP and UDP network connections and associates them with their owning processes.
.DESCRIPTION
    This script uses Get-NetTCPConnection and Get-NetUDPEndpoint to retrieve network connection
    information and then attempts to find the owning process details using Get-Process.
.OUTPUTS
    Outputs a table of active network connections with process ID, name, and path.
.NOTES
    Author: Trae AI
    Version: 1.0
    Running as Administrator provides more process information (like path for system processes).
#>

Write-Host "--- Listing Active Network Connections with Process Info ---" -ForegroundColor Yellow

# Get TCP Connections
Write-Host "`n--- Active TCP Connections ---" -ForegroundColor Cyan
$tcpConnections = Get-NetTCPConnection -ErrorAction SilentlyContinue | Select-Object LocalAddress, LocalPort, RemoteAddress, RemotePort, State, OwningProcess

$tcpOutput = @()
foreach ($conn in $tcpConnections) {
    $processInfo = Get-Process -Id $conn.OwningProcess -ErrorAction SilentlyContinue
    $tcpOutput += [PSCustomObject]@{
        Protocol      = "TCP"
        LocalAddress  = $conn.LocalAddress
        LocalPort     = $conn.LocalPort
        RemoteAddress = $conn.RemoteAddress
        RemotePort    = $conn.RemotePort
        State         = $conn.State
        PID           = $conn.OwningProcess
        ProcessName   = if ($processInfo) { $processInfo.ProcessName } else { "N/A" }
        ProcessPath   = if ($processInfo) { $processInfo.Path } else { "N/A" }
    }
}
$tcpOutput | Format-Table -AutoSize -Wrap

# Get UDP Endpoints (Listening Ports)
Write-Host "`n--- Active UDP Listeners ---" -ForegroundColor Cyan
$udpEndpoints = Get-NetUDPEndpoint -ErrorAction SilentlyContinue | Select-Object LocalAddress, LocalPort, OwningProcess

$udpOutput = @()
foreach ($ep in $udpEndpoints) {
    $processInfo = Get-Process -Id $ep.OwningProcess -ErrorAction SilentlyContinue
    $udpOutput += [PSCustomObject]@{
        Protocol      = "UDP"
        LocalAddress  = $ep.LocalAddress
        LocalPort     = $ep.LocalPort
        PID           = $ep.OwningProcess
        ProcessName   = if ($processInfo) { $processInfo.ProcessName } else { "N/A" }
        ProcessPath   = if ($processInfo) { $processInfo.Path } else { "N/A" }
    }
}
$udpOutput | Format-Table -AutoSize -Wrap

Write-Host "`n--- Network Connection Scan Finished ---" -ForegroundColor Green