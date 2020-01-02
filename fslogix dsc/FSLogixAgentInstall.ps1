param(
      [string]$vhdPath
)

#Extract FSlogix agent 
Expand-Archive -path .\FSLogix_Apps.zip 
cd .\FSLogix_Apps\x64\Release\

$execarg = @(
    "/passive | /quite /log log.txt"
)

write-host "Installing FSLogix agent..."
Start-Process FSLogixAppsSetup.exe -Wait -ArgumentList $execarg
write-host "FSlogix agent status:$((Get-Service frxsvc).Status)"

#Configuring FSLogix agent 
New-Item -Path HKLM:\Software\FSLogix -Name Profiles
New-ItemProperty -Path HKLM:\Software\FSLogix\Profiles -Name Enabled -Value 1 -PropertyType DWORD
New-ItemProperty -Path HKLM:\Software\FSLogix\Profiles -Name VHDLocations -Value $vhdPath -PropertyType MultiString

#Validating FSLogix agent installation
write-host "Verifiying FSLogix agent registry keys"
if ((Test-Path -Path "HKLM:\SOFTWARE\Microsoft\Profiles") -eq $false) {(Start-Sleep -s 60)} ELSE {write-host "FSLogix agent registry entry found"}
Get-ItemProperty -Path "HKLM:\SOFTWARE\FSLogix\Profiles"

write-host "Installation completed"


