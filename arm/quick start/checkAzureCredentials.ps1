param(
	[string] [Parameter(Mandatory=$true)] $username,
	[string] [Parameter(Mandatory=$true)] $password
)

Write-Output "Enter"

Write-Output "Install Modules"
Install-Module AzureAD
Import-Module AzureAD

$ErrorActionPreference = 'Stop'

Write-Output "Creds"
$Credential = New-Object System.Management.Automation.PsCredential($username, (ConvertTo-SecureString $password -AsPlainText -Force))
Connect-AzureAD -AzureEnvironmentName 'AzureCloud' -Credential $Credential
