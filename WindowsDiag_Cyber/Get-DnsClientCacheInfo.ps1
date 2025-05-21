<#
.SYNOPSIS
    Retrieves and displays the DNS client cache.
.DESCRIPTION
    This script uses the Get-DnsClientCache cmdlet to show the names and IP addresses
    that the local DNS client has recently resolved and cached. This can help identify
    connections to known or unknown domains.
.OUTPUTS
    Outputs a formatted table of DNS cache entries.
.EXAMPLE
    .\Get-DnsClientCacheInfo.ps1
    Displays the current DNS client cache.
.NOTES
    Author: Trae AI
    Version: 1.0
#>

Write-Host "--- Retrieving DNS Client Cache ---" -ForegroundColor Yellow

try {
    $dnsCache = Get-DnsClientCache -ErrorAction Stop
    if ($dnsCache) {
        $dnsCache | Sort-Object Entry -Unique | Select-Object Entry, Type, Status, Data, Section, TimeToLive | Format-Table -AutoSize -Wrap
    } else {
        Write-Host "DNS client cache is empty or could not be retrieved." -ForegroundColor Yellow
    }
}
catch {
    Write-Warning "Could not retrieve DNS client cache. Error: $($_.Exception.Message)"
    Write-Warning "The 'Get-DnsClientCache' cmdlet might require the DNS Client service to be running."
}

Write-Host "`n--- DNS Cache Retrieval Finished ---" -ForegroundColor Green