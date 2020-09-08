<#.SYNOPSIS
Enables Azure Files for a native AD environment, executing the domain join of the storage account using the AzFilesHybrid module.
Parameter names have been abbreviated to shorten the 'PSExec' command, which has a limited number of allowed characters.

.PARAMETER RG
Resource group of the profiles storage account

.PARAMETER S
Name of the profiles storage account

.PARAMETER U
Azure admin UPN

.PARAMETER P
Azure admin password

.PARAMETER 

#>

param(    
    [Parameter(Mandatory = $true)]
    [string] $resourceGroup,

    [Parameter(Mandatory = $true)]
    [string] $storageAccount,

    [Parameter(Mandatory = $true)]
    [string] $dcAdminUserName,

    [Parameter(Mandatory = $true)]
    [string] $dcAdminPassword,

    [Parameter(Mandatory = $true)]
    [string] $subscriptionGUID,

    [Parameter(Mandatory = $true)]
    [string] $domainName
)

#Extract FSlogix agent 
Expand-Archive -path .\Artefacts.zip 
Set-Location $PSScriptroo

# Set execution policy    
Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope CurrentUser -Force

# Import required modules
cd .\Artefacts
.\CopyToPSPath.ps1
Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
Install-Module -Name PowershellGet -MinimumVersion 2.2.4.1 -Force

Install-Module -Name Az -Force -Verbose -AllowClobber

Import-Module -Name AzFilesHybrid -Force -Verbose
Import-Module -Name activedirectory -Force -Verbose

# Find existing OU or create new one. Get path for OU from domain by splitting the domain name, to format DC=fabrikam,DC=com
$DC = $domainName.split('.')
foreach($name in $DC) {
    $path = $path + ',DC=' + $name
}
$path = $path.substring(1)
$ou = Get-ADOrganizationalUnit -Filter 'Name -like "Profiles Storage"'
if ($ou -eq $null) {
    New-ADOrganizationalUnit -name 'Profiles Storage' -path $path
}

# Connect to Azure
$Credential = New-Object System.Management.Automation.PsCredential($dcAdminUserName, (ConvertTo-SecureString $dcAdminPassword -AsPlainText -Force))
Connect-AzAccount -Credential $Credential
Select-AzSubscription -SubscriptionId $subscriptionGUID

Join-AzStorageAccountForAuth -ResourceGroupName $resourceGroup -StorageAccountName $storageAccount -DomainAccountType 'ComputerAccount' -OrganizationalUnitName 'Profiles Storage' -OverwriteExistingADObject