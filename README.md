# Windows Remote Management Readiness Toolkit

PowerShell tools for WinRM readiness reporting and guarded remoting repair.

## Report

```powershell
powershell.exe -ExecutionPolicy Bypass -File .\Windows_Remote_Management_Readiness_Toolkit.ps1
```

## Repair

```powershell
powershell.exe -ExecutionPolicy Bypass -File .\Windows_Remote_Management_Repair_Toolkit.ps1 -EnableRemoting -DryRun
```

Examples:

```powershell
.\Windows_Remote_Management_Repair_Toolkit.ps1 -EnableRemoting
.\Windows_Remote_Management_Repair_Toolkit.ps1 -RepairListener
.\Windows_Remote_Management_Repair_Toolkit.ps1 -EnableFirewallRules
.\Windows_Remote_Management_Repair_Toolkit.ps1 -RestartWinRM
```

The repair workflow captures service, listener, firewall and WSMan state before and after repair. It supports `-DryRun`, confirmation, logs and clear exit codes. Enabling remoting changes local listener and firewall configuration; use it only on authorised systems and approved network profiles.

## Author

Dewald Pretorius — L2 IT Support Engineer
