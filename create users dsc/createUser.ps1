param(
      [string]$userName,
      [string]$domainName,  
      [string]$passWord
)

#Extract FSlogix agent 
Expand-Archive -path .\FSLogix_Apps.zip 
cd .\FSLogix_Apps\x64\Release\

$execarg = @(
    "/passive | /quite /log log.txt"
)

write-host "Create user..."
Start-Process FSLogixAppsSetup.exe -Wait -ArgumentList $execarg

New-ADUser `
-SamAccountName $userName `
-UserPrincipalName $userName + "@" + $domainName `
-Name "$userName" `
-GivenName $userName `
-Surname $userName `
-Enabled $True `
-ChangePasswordAtLogon $True `
-DisplayName "$userName" `
-AccountPassword (convertto-securestring $passWord -AsPlainText -Force)

write-host "Create user completed."


