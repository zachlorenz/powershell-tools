# ===============================
# ADRecon.ps1
# Red Team Oriented AD Enumeration Tool
# ===============================

# Import AD Module
if (-not (Get-Module -ListAvailable -Name ActiveDirectory)) {
    Write-Error "ActiveDirectory module not found. Install RSAT: Active Directory Tools."
    exit
}
Import-Module ActiveDirectory

# Output folder with timestamp
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$outDir = ".\ADRecon_$timestamp"
New-Item -ItemType Directory -Path $outDir | Out-Null

# 1. Domain Info
$domainInfo = Get-ADDomain
$domainInfo | Format-List | Tee-Object -FilePath "$outDir\DomainInfo.txt"

# 2. Domain Controllers
Write-Host "[*] Enumerating Domain Controllers..." -ForegroundColor Cyan
Get-ADDomainController -Filter * |
    Select HostName, Site, IPv4Address |
    Tee-Object -FilePath "$outDir\DomainControllers.csv" -Append

# 3. Domain Admins / Privileged Groups
$privGroups = @("Domain Admins", "Enterprise Admins", "Schema Admins", "Administrators")

foreach ($group in $privGroups) {
    Write-Host "[*] Members of $group" -ForegroundColor Yellow
    try {
        Get-ADGroupMember -Identity $group -Recursive |
            Select-Object Name, SamAccountName, ObjectClass |
            Export-Csv "$outDir\$group.csv" -NoTypeInformation
    } catch {
        Write-Warning "Could not enumerate $group"
    }
}

# 4. Kerberoastable Users (users with SPNs)
Write-Host "[*] Finding Kerberoastable users (SPNs set)..." -ForegroundColor Yellow
Get-ADUser -Filter {ServicePrincipalName -like "*"} -Properties ServicePrincipalName |
    Select Name, SamAccountName, ServicePrincipalName |
    Export-Csv "$outDir\KerberoastableUsers.csv" -NoTypeInformation

# 5. Users with PasswordNeverExpires
Write-Host "[*] Users with PasswordNeverExpires..." -ForegroundColor Yellow
Get-ADUser -Filter {PasswordNeverExpires -eq $true} -Properties PasswordNeverExpires |
    Select Name, SamAccountName |
    Export-Csv "$outDir\PasswordNeverExpires.csv" -NoTypeInformation

# 6. Recently Created Users (last 30 days)
Write-Host "[*] Users created in the last 30 days..." -ForegroundColor Yellow
$cutoff = (Get-Date).AddDays(-30)
Get-ADUser -Filter * -Properties WhenCreated |
    Where-Object { $_.WhenCreated -gt $cutoff } |
    Select Name, SamAccountName, WhenCreated |
    Export-Csv "$outDir\RecentUsers.csv" -NoTypeInformation

# 7. Unconstrained Delegation
Write-Host "[*] Computers with Unconstrained Delegation..." -ForegroundColor Yellow
Get-ADComputer -Filter {TrustedForDelegation -eq $true} -Properties TrustedForDelegation |
    Select Name, DNSHostName, OperatingSystem |
    Export-Csv "$outDir\UnconstrainedDelegation.csv" -NoTypeInformation

# 8. Disabled Accounts
Write-Host "[*] Disabled User Accounts..." -ForegroundColor Yellow
Get-ADUser -Filter {Enabled -eq $false} |
    Select Name, SamAccountName |
    Export-Csv "$outDir\DisabledUsers.csv" -NoTypeInformation

# 9. High-Privileged Users (memberships across common groups)
Write-Host "[*] Cross-checking high-privileged group memberships..." -ForegroundColor Yellow
$groupsToCheck = @("Remote Desktop Users", "Print Operators", "Server Operators", "Backup Operators", "Power Users")

foreach ($grp in $groupsToCheck) {
    try {
        Get-ADGroupMember -Identity $grp -Recursive |
            Select Name, SamAccountName, ObjectClass |
            Export-Csv "$outDir\$grp.csv" -NoTypeInformation
    } catch {
        Write-Warning "Could not enumerate $grp"
    }
}

# Wrap-up
Write-Host "`n[+] AD Recon Complete. Results saved to $outDir" -ForegroundColor Green
