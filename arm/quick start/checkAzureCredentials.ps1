param(
	[string] [Parameter(Mandatory=$true)] $username,
	[string] [Parameter(Mandatory=$true)] $password
)

#region body
Write-Output "Enter"

$ErrorActionPreference = 'Stop'

#region find role
foreach ($x in $assignment) { 
    if ($x.RoleDefinitionName -eq "Owner") 
        { $found = 1; break} 
    Else
        {$found = 0} }

    Write-Output $found
    Write-Output $password
#endregion



#region test creds
#Write-Output "Creds"

#$Credential = New-Object System.Management.Automation.PsCredential($username, (ConvertTo-SecureString $password -AsPlainText -Force))
#Connect-AzureAD -AzureEnvironmentName 'AzureCloud' -Credential $Credential
#endregion

#region assignment
#Get-AzUserAssignedIdentity -ResourceGroupName $ResourceGroupName -Name "$username"
#endregion

#endregion 