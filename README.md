# Windows Remote Management Readiness Toolkit

A read-only PowerShell toolkit for Windows Remote Management readiness reporting.

## Features

- WinRM service status
- Listener and firewall-rule visibility
- WSMan connectivity check
- Domain and network profile context
- CSV, JSON, TXT, and HTML reports

## Run

```powershell
powershell.exe -ExecutionPolicy Bypass -File .\Windows_Remote_Management_Readiness_Toolkit.ps1
```

## Safety

Read-only reporting only. No WinRM or firewall settings are changed.
