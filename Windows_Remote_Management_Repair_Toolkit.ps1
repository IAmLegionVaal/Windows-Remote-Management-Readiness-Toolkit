[CmdletBinding(SupportsShouldProcess=$true,ConfirmImpact='High')]
param(
 [switch]$EnableRemoting,
 [switch]$RestartWinRM,
 [switch]$RepairListener,
 [switch]$EnableFirewallRules,
 [switch]$DryRun,
 [switch]$Yes,
 [string]$OutputPath=(Join-Path $env:ProgramData 'WinRMRepair')
)
$ErrorActionPreference='Stop';$script:Failures=0;$script:Actions=0
$run=Join-Path $OutputPath (Get-Date -Format yyyyMMdd_HHmmss);New-Item -ItemType Directory $run -Force|Out-Null
$log=Join-Path $run 'repair.log';$before=Join-Path $run 'before.txt';$after=Join-Path $run 'after.txt'
function Log($m){"$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') $m"|Tee-Object -FilePath $log -Append}
function Admin{$p=[Security.Principal.WindowsPrincipal]::new([Security.Principal.WindowsIdentity]::GetCurrent());$p.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)}
function State($path){@("Collected: $(Get-Date -Format o)",(Get-Service WinRM|Format-List|Out-String),(& winrm.exe enumerate winrm/config/listener 2>&1|Out-String),(Get-NetFirewallRule -DisplayGroup 'Windows Remote Management' -ErrorAction SilentlyContinue|Select-Object DisplayName,Enabled,Profile,Direction,Action|Format-Table -Auto|Out-String),(Test-WSMan localhost -ErrorAction SilentlyContinue|Format-List|Out-String))|Set-Content $path -Encoding UTF8}
function Act($d,[scriptblock]$a){$script:Actions++;Log $d;if($DryRun){Log "DRY-RUN: $d";return};try{&$a;Log "SUCCESS: $d"}catch{$script:Failures++;Log "FAILED: $d - $($_.Exception.Message)"}}
if(-not($EnableRemoting -or $RestartWinRM -or $RepairListener -or $EnableFirewallRules)){Write-Error 'Choose at least one repair action.';exit 2}
if(-not $DryRun -and -not(Admin)){Write-Error 'Run from elevated PowerShell.';exit 4}
State $before
if(-not $Yes -and -not $DryRun){if((Read-Host 'Enable or repair Windows Remote Management? Type YES') -ne 'YES'){Log 'Cancelled.';exit 10}}
if($EnableRemoting){Act 'Enabling PowerShell remoting' {Enable-PSRemoting -Force -SkipNetworkProfileCheck}}
if($RepairListener){Act 'Running WinRM quick configuration' {& winrm.exe quickconfig -quiet|Out-File (Join-Path $run 'winrm-quickconfig.txt');if($LASTEXITCODE){throw "winrm exited $LASTEXITCODE"}}}
if($EnableFirewallRules){Act 'Enabling Windows Remote Management firewall rules' {Get-NetFirewallRule -DisplayGroup 'Windows Remote Management' -ErrorAction Stop|Enable-NetFirewallRule}}
if($RestartWinRM){Act 'Restarting WinRM service' {Set-Service WinRM -StartupType Automatic;Restart-Service WinRM -Force}}
Start-Sleep 2;State $after
if($script:Failures){exit 20};Log "Repair completed. Actions: $script:Actions";exit 0
