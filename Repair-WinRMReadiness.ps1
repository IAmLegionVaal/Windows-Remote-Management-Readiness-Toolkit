#requires -Version 5.1
<# Created by Dewald Pretorius. Guarded WinRM service recovery without changing listeners or firewall rules. #>
[CmdletBinding(SupportsShouldProcess=$true)]
param([ValidateSet('Diagnose','StartService')][string]$Action='Diagnose',[string]$OutputPath=(Join-Path ([Environment]::GetFolderPath('Desktop')) 'WinRM_Readiness_Repair'))
$ErrorActionPreference='Stop';New-Item -ItemType Directory $OutputPath -Force|Out-Null;$s=Get-Date -Format yyyyMMdd_HHmmss
$before=[ordered]@{Service=(Get-Service WinRM|Select-Object Name,Status,StartType);Listeners=((& winrm.exe enumerate winrm/config/listener 2>&1)|Out-String);TrustedHosts=(Get-Item WSMan:\localhost\Client\TrustedHosts -ErrorAction SilentlyContinue).Value};$before|ConvertTo-Json -Depth 5|Set-Content (Join-Path $OutputPath "before_$s.json")
if($Action-eq'Diagnose'){exit 0}
try{if($PSCmdlet.ShouldProcess('WinRM service','Start if stopped')){$svc=Get-Service WinRM;if($svc.Status-eq'Stopped'){Start-Service WinRM}}}catch{Write-Error $_;exit 5}
Start-Sleep 2;if((Get-Service WinRM).Status-ne'Running'){exit 6};exit 0
