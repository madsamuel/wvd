param(
      [string]$registrationToken
)

#Extract MSIs
Expand-Archive -path .\AgentsAndKB2592687Update.zip 
# install update 
cd .\AgentsAndKB2592687Update

write-host "Installing KB2592687..."
$execarg = @(
    "/quiet"
    "/norestart"
)
Start-Process Windows6.1-KB2592687-x64.msu -Wait -ArgumentList $execarg
# enable RDP8
New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services\" -Name fServerEnableRDP8 -Value 1 -PropertyType DWord 

# agents
# wvd agent
$msiFile =  Get-Item 'Microsoft.RDInfra.WVDAgent.Installer*'
write-host $msiFile

$execarg = @(
    "/i"
    "$msiFile"
    "/passive"
    "REGISTRATIONTOKEN=$registrationToken"
)
write-host "Installing WVD Agent..."
Start-Process msiexec.exe -Wait -ArgumentList $execarg

# wvd agent manager
write-host "Installing WVD Agent Manager..."
$msiFile =  Get-Item 'Microsoft.RDInfra.WVDAgentManager*'
$execarg = @(
    "/i"
    "$msiFile" 
    "/passive"
)
Start-Process msiexec.exe -Wait -ArgumentList $execarg

# checks 
write-host "Agent Status:$((Get-Service WVDAgent).Status)"

write-host "Verifiying WVD Agent registry keys"
if ((Test-Path -Path "HKLM:\SOFTWARE\Microsoft\WVDAgentManager") -eq $false) {(Start-Sleep -s 60)} ELSE {write-host "WVD Agent Registry entry found"}
Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\WVDAgentManager"


if ((Test-Path -Path "HKLM:\SOFTWARE\Microsoft\RDAgentBootLoader") -eq $false) {(Start-Sleep -s 60)} ELSE {write-host "WVD Agent Manager Registry entry found"}
Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\RDAgentBootLoader"

write-host "Installation completed"

