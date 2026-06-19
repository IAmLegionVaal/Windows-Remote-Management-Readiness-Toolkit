#requires -Version 5.1
[CmdletBinding()]
param([string]$OutputPath)
$stamp=Get-Date -Format 'yyyyMMdd_HHmmss'
if([string]::IsNullOrWhiteSpace($OutputPath)){$OutputPath=Join-Path ([Environment]::GetFolderPath('Desktop')) 'WinRM_Readiness_Reports'}
New-Item -ItemType Directory -Path $OutputPath -Force|Out-Null
$service=Get-Service WinRM -ErrorAction SilentlyContinue|Select-Object Name,DisplayName,Status,StartType
$profile=Get-NetConnectionProfile -ErrorAction SilentlyContinue|Select-Object Name,InterfaceAlias,NetworkCategory,IPv4Connectivity,IPv6Connectivity
$rules=Get-NetFirewallRule -DisplayGroup 'Windows Remote Management' -ErrorAction SilentlyContinue|Select-Object DisplayName,Enabled,Direction,Action,Profile
$listeners=winrm.exe enumerate winrm/config/listener 2>$null
$listeners|Out-File (Join-Path $OutputPath "winrm_listeners_$stamp.txt") -Encoding UTF8
$wsmanOk=$false;try{Test-WSMan localhost -ErrorAction Stop|Out-Null;$wsmanOk=$true}catch{}
$summary=[PSCustomObject]@{Computer=$env:COMPUTERNAME;ServiceStatus=$service.Status;ServiceStartType=$service.StartType;WSManLocalhost=$wsmanOk;Generated=Get-Date}
$service|Export-Csv (Join-Path $OutputPath "winrm_service_$stamp.csv") -NoTypeInformation -Encoding UTF8
$profile|Export-Csv (Join-Path $OutputPath "network_profiles_$stamp.csv") -NoTypeInformation -Encoding UTF8
$rules|Export-Csv (Join-Path $OutputPath "winrm_firewall_rules_$stamp.csv") -NoTypeInformation -Encoding UTF8
@{Summary=$summary;Service=$service;Profiles=$profile;FirewallRules=$rules}|ConvertTo-Json -Depth 6|Set-Content (Join-Path $OutputPath "winrm_readiness_$stamp.json") -Encoding UTF8
$html="<h1>WinRM Readiness - $env:COMPUTERNAME</h1><p>Generated $(Get-Date)</p><h2>Summary</h2>$(@($summary)|ConvertTo-Html -Fragment)<h2>Network Profiles</h2>$($profile|ConvertTo-Html -Fragment)<h2>Firewall Rules</h2>$($rules|ConvertTo-Html -Fragment)"
$html|ConvertTo-Html -Title 'WinRM Readiness'|Set-Content (Join-Path $OutputPath "winrm_readiness_$stamp.html") -Encoding UTF8
$summary|Format-List
Write-Host "Reports saved to: $OutputPath" -ForegroundColor Green
