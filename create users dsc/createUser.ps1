param(
      [string]$userName,
      [string]$domainName,  
      [string]$passWord
)

#Extract FSlogix agent 
write-host "Create user..."

# Import-Module ActiveDirectory -Force

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


