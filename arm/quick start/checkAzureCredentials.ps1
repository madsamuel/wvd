param(
	[string] [Parameter(Mandatory=$true)] $username,
	[string] [Parameter(Mandatory=$true)] $password
)

#region body
Write-Output "Enter"

#region install modules
Write-Output "Install Modules"
Import-Module AzureAD -Global
#endregion

$ErrorActionPreference = 'Stop'

#region test creds
Write-Output "Creds"

$Credential = New-Object System.Management.Automation.PsCredential($username, (ConvertTo-SecureString $password -AsPlainText -Force))
Connect-AzureAD -AzureEnvironmentName 'AzureCloud' -Credential $Credential
#endregion

#endregion 