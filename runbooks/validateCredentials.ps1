param(
	[string] [Parameter(Mandatory=$true)] $username = "admin@gt1101.onmicrosoft.com",
	[string] [Parameter(Mandatory=$true)] $password = ""
)

#region PS modules download
# Download files required for this script from github ARMRunbookScripts/static folder
$fileURI = "https://raw.githubusercontent.com/samvdjagt/wvdquickstart/master"
$FileNames = "msft-wvd-saas-api.zip,msft-wvd-saas-web.zip,AzureModules.zip"
$SplitFilenames = $FileNames.split(",")
foreach($Filename in $SplitFilenames){
Invoke-WebRequest -Uri "$fileURI/ARMRunbookScripts/static/$Filename" -OutFile "C:\$Filename"
}

#New-Item -Path "C:\msft-wvd-saas-offering" -ItemType directory -Force -ErrorAction SilentlyContinue
Expand-Archive "C:\AzureModules.zip" -DestinationPath 'C:\Modules\Global' -ErrorAction SilentlyContinue

# Install required Az modules and AzureAD
Import-Module Az.Accounts -Global
Import-Module Az.Resources -Global
Import-Module Az.Websites -Global
Import-Module Az.Automation -Global
Import-Module Az.Managedserviceidentity -Global
Import-Module Az.Keyvault -Global
Import-Module AzureAD -Global

Set-ExecutionPolicy -ExecutionPolicy Undefined -Scope Process -Force -Confirm:$false
Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope LocalMachine -Force -Confirm:$false
Get-ExecutionPolicy -List
#endregion

Write-Output "Prep credential"
$securePassword = ConvertTo-SecureString $password -AsPlainText -Force
$pscredential = New-Object System.Management.Automation.PSCredential($username, $securePassword)
Write-Output "Done credential"

Write-Output "Try to connect AAD"
Connect-AzAccount -Environment 'AzureCloud' -Credential $pscredential
Connect-AzureAD -AzureEnvironmentName 'AzureCloud' -Credential $pscredential
Write-Output "Connected to AAD"

Write-Output "Select"
Select-AzSubscription -SubscriptionId "5c14a947-e099-4b3f-932e-6e836da92be6"

Write-Output "Throwing..."
throw  "Please authenticate to Azure & Azure AD using Login-AzAccount and Connect-AzureAD cmdlets and then run this script"
Write-Output "Catching..."

Write-Output "Create RG"
New-AzResourceGroup -Name RG01 -Location "South Central US"