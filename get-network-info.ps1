<#
.SYNOPSIS
    Collects and displays basic network configuration details.

.DESCRIPTION
    This script gathers and prints information about the local system's
    network interfaces, IP configuration, DNS settings, routing table,
    and active TCP connections. Useful for initial recon or documentation
    in cyber ops and system administration.

.NOTES
    Author: Zach Lorenz
    Date: 2025-07-16
#>

Clear-Host
Write-Host "Gathering network information..." -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor DarkGray

# Hostname and Domain
Write-Host "`n[+] Host Information" -ForegroundColor Yellow
Write-Host "Hostname:        " $env:COMPUTERNAME
Write-Host "Domain:          " (Get-WmiObject Win32_ComputerSystem).Domain

# IP Configuration
Write-Host "`n[+] IP Configuration" -ForegroundColor Yellow
Get-NetIPConfiguration | Format-Table -AutoSize

# Interface List
Write-Host "`n[+] Network Interfaces" -ForegroundColor Yellow
Get-NetAdapter | Select-Object Name, Status, MACAddress, LinkSpeed | Format-Table -AutoSize

# DNS Servers
Write-Host "`n[+] DNS Servers" -ForegroundColor Yellow
Get-DnsClientServerAddress | Where-Object { $_.ServerAddresses } | Format-Table InterfaceAlias, ServerAddresses -AutoSize

# Routing Table
Write-Host "`n[+] Routing Table" -ForegroundColor Yellow
Get-NetRoute | Where-Object { $_.NextHop -ne '::' } | Format-Table DestinationPrefix, NextHop, InterfaceAlias -AutoSize

# Active TCP Connections
Write-Host "`n[+] Active TCP Connections" -ForegroundColor Yellow
Get-NetTCPConnection | Where-Object { $_.State -eq "Established" } | Format-Table LocalAddress, LocalPort, RemoteAddress, RemotePort, State -AutoSize

Write-Host "`n[+] Done." -ForegroundColor Green
