# PowerShell Scripts — JCAC Cyber Toolkit

This folder contains PowerShell scripts developed during and after the Joint Cyber Analysis Course (JCAC). These tools demonstrate basic system enumeration, password cracking, and other common cyber operations.

---

Scripts

| Script               | Description                                 |
|----------------------|---------------------------------------------|
| `ciphercrack.ps1`    | Manual Caesar cipher cracking assistant     |
| `get_network_info.ps1` | Gathers basic Windows network info       |
| `ADRecon.ps1`        | Queries common Active Directory objects     |
| `password_audit.ps1` | Tests weak passwords against local accounts |

---

## Uses
All scripts are compatible with:
- PowerShell 5+ on Windows
- PowerShell Core on Linux/macOS (unless Windows-specific cmdlets are used)

Run with:
```powershell
.\scriptname.ps1
