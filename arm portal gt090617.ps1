## ad admin
#region setup ps Module
# C:\Users\stgeorgi\AppData\Roaming\npm\node_modules\@cspotcode\pwsh-cache\powershell-6.1.0-win32-x64\pwsh.exe

# poit to dowload folder
cd C:\users\stgeorgi\downloads
# register c: as ocal reprository
Register-PSRepository -Name LocalRepository -SourceLocation "C:\Users\stgeorgi\Downloads\" -PackageManagementProvider NuGet -InstallationPolicy Trusted
# if repositroy exist clean up 
Unregister-PSRepository -Name LocalRepository
Get-PSRepository
# Reregister

## This should be ontime or upon change of Az.Account
# Install-Module -Name Az.Accounts -RequiredVersion 1.6.3
# Install-Module -Name Az.Accounts -RequiredVersion 1.6.3 -SkipPublisherCheck
Install-Module -Name Az

Install-Module -Name Az.DesktopVirtualization -Repository LocalRepository -RequiredVersion 0.1.0
Import-Module -Name Az.DesktopVirtualization -RequiredVersion 0.1.0
Remove-Module -Name Az.DesktopVirtualization -Force
#endrregion

# Run PowerShell core: C:[Path\to\pwsh.exe]\pwsh-cache\powershell-6.1.0-win32-x64\pwsh.exe
# 1
"C:\Program Files\PowerShell\7-preview\pwsh.exe"

#PS
Connect-AzAccount
# https://microsoft.com/devicelogin
$(Get-AzSubscription).SubscriptionId
$subid = "25e8c5f2-1e4e-4b1e-bbef-00d911724630" 
Get-AzWvdHostPool -SubscriptionId $subid 

Get-AzWvdWorkspace | Where-Object { $_.Name -like "*clark-ws*" }
Get-AzWvdWorkspace -Name 0917clark-ws | fl
Get-AzWvdApplication -GroupName testShowInFeed -ResourceGroupName 0917clark-rg -Name "Disk Cleanup"
Update-AzWvdApplication -GroupName testShowInFeed -ResourceGroupName 0917clark-rg -Name "Disk Cleanup" -ShowInPortal 

Update-AzWvdApplication

#MSIX app attach alpha
$wokrspace = "msixaa"
$rg = "msixaa-stress-test-rg"

Get-AzWvdWorkspace | ?{$_.Name -eq $wokrspace}
Update-AzWvdWorkspace -Name $wokrspace -FriendlyName "MSIX app attach" -ResourceGroupName $rg -Description "MSIX app attach"

$des = "MSIX app attach alpha"
$appgroup = "msixaa-stress-test-hp-DAG"

Get-AzWvdApplicationGroup
Update-AzWvdApplicationGroup -Name $appgroup -ResourceGroupName $rg -Description $des -FriendlyName $des 

$hp = "msixaa-stress-test-v1-rg"

Get-AzWvdSessionHost -HostPoolName $hp -ResourceGroupName $rg | fl
Remove-AzWvdSessionHost -HostpoolName $hp -ResourceGroupName $rg -Name msixaa-0.GT090617.onmicrosoft.com -Force

Get-AzWvdUserSession -HostPoolName $hp -ResourceGroupName $rg | fl

#region REST API test for SAM
$sub = "25e8c5f2-1e4e-4b1e-bbef-00d911724630"
$rg = "0630"
$accountName = "test0701samtest"

$currentAzureContext = Get-AzContext
$azureRmProfile = [Microsoft.Azure.Commands.Common.Authentication.Abstractions.AzureRmProfileProvider]::Instance.Profile
$profileClient = New-Object Microsoft.Azure.Commands.ResourceManager.Common.RMProfileClient($azureRmProfile)
$pat = $profileClient.AcquireAccessToken($currentAzureContext.Subscription.TenantId).AccessToken
Write-Output $pat

$headers = @{
    Authorization="Bearer $pat"
}

Invoke-RestMethod -Uri $("https://management.azure.com/subscriptions/" + $sub +"/resourceGroups/" + $rg + "/providers/Microsoft.Storage/storageAccounts/" + $accountName + "?api-version=2018-02-01") -Headers $headers
#endregion

### OLD ###



$appgroup = "ptest-4-11-ag"
$rg = "portaluitest-4-09-rg"
New-AzWvdApplicationGroup -Name $appgroup -ResourceGroupName $rg -ApplicationGroupType "RemoteApp" -HostPoolArmPath '/subscriptions/5c14a947-e099-4b3f-932e-6e836da92be6/resourcegroups/portaluitest-4-09-rg/providers/Microsoft.DesktopVirtualization/hostPools/portaluitest-4-09-hp'-Location eastus -SubscriptionId $subid

Get-AzWvdApplicationGroup -Name $appgroup -ResourceGroupName $rg -Subscriptionid $subid
#Regiin Applications
Get-AzWvdStartMenuItem -ApplicationGroupName $appgroup -ResourceGroupName $rg -Subscriptionid $subid 
Get-AzWvdApplication -ResourceGroupName $rg -ApplicationGroupName $appgroup 

New-AzWvdApplication -AppAlias "ptest-4-11-ag/dfrgui" -GroupName $appgroup -Name "Mydfrgui" -ResourceGroupName $rg -Subscriptionid $subid -CommandLineSetting "-"
New-AzWvdApplication -GroupName $appgroup -Name "Mydfrgui" -ResourceGroupName $rg -Subscriptionid $subid -FilePath "C:\Windows\system32\SnippingTool.exe" -IconPath "C:\Windows\system32\SnippingTool.exe" -IconIndex 0 -CommandLineSetting Require -ShowInPortal 
Set-AzWvdApplication -GroupName $appgroup -Name "SnippingTool" -ResourceGroupName $rg -Subscriptionid $subid -FilePath "C:\Windows\system32\SnippingTool.exe" -IconPath "C:\Windows\system32\SnippingTool.exe" -IconIndex 0 -CommandLineSetting Require -ShowInPortal 

Get-AzWvdApplication -GroupName $appgroup -ResourceGroupName $rg -Subscriptionid $subid 
New-AzRoleAssignment -SignInName "user001@gt1101.onmicrosoft.com" -RoleDefinitionName "Desktop Virtualization User" -ResourceGroupName $rg

Update-AzWvdApplication -ResourceGroupName $rg -ApplicationGroupName $appgroup -ApplicationName "Mydfrgui" -FriendlyName "TEST" -ShowInPortal $true -IconIndex 0 -FilePath ""
#endregion

Get-AzWvdHostPool -ResourceGroupName $rg -SubscriptionId $subid
Update-AzWvdHostPool -ResourceGroupName $rg -Name portaluitest-4-09-hp -ValidationEnvironment:$true  -SubscriptionId $subid

Update-AzWvdHostPool -ResourceGroupName $rg -Name portaluitest-4-09-hp -CustomRdpProperty "audiocapturemode:i:1;" -SubscriptionId $subid
Update-AzWvdHostPool -ResourceGroupName $rg -Name portaluitest-4-09-hp -CustomRdpProperty "" -SubscriptionId $subid -FriendlyName "Runnign with wild"

Update-AzWvdHostPool -ResourceGroupName $rg -Name portaluitest-4-09-hp -LoadBalancerType 'BreadthFirst' -SubscriptionId $subid -MaxSessionLimit 30

Get-AzWvdDesktop -ResourceGroupName $rg -ApplicationGroupName portaluitest-4-11-hp-DAG -SubscriptionId $subid 
( $obj = Get-AzWvdDesktop -ResourceGroupName $rg -ApplicationGroupName portaluitest-4-11-hp-DAG -SubscriptionId $subid ).FriendlyName

Update-AzWvdDesktop -ResourceGroupName $rg -ApplicationGroupName portaluitest-4-11-hp-DAG -SubscriptionId $subid -FriendlyName "TESTDESKTOP" -Name "portaluitest-4-11-hp-DAG"

#role assignment
New-AzRoleAssignment -SignInName "user001@gt1101.onmicrosoft.com" -RoleDefinitionName "Desktop Virtualization User" -ResourceGroupName $rg
#troubleshooting
Get-AzRoleAssignment -SignInName "user001@gt1101.onmicrosoft.com"
Get-AzWvdSessionHost -HostPoolName portaluitest-4-09-hp -ResourceGroupName $rg -SubscriptionId $subid | Format-List 



# Get your User Id
$userId = (Get-AzContext).Account.Id

$resourceGroupName = "19013vb-image-rg-v2"
$storageAccountName = "19013vbimagesav2"
$keyVaultName = "testKeyVault413"
$keyVaultSpAppId = "cfa8b339-82a2-471a-a3c9-0fc0be7a4093"
$storageAccountKey = ""

# Get your User Id
$userId = (Get-AzContext).Account.Id

# Get a reference to your Azure storage account
$storageAccount = Get-AzStorageAccount -ResourceGroupName $resourceGroupName -StorageAccountName $storageAccountName

# Assign RBAC role "Storage Account Key Operator Service Role" to Key Vault, limiting the access scope to your storage account. For a classic storage account, use "Classic Storage Account Key Operator Service Role." 
New-AzRoleAssignment -ApplicationId $keyVaultSpAppId -RoleDefinitionName 'Storage Account Key Operator Service Role' -Scope $storageAccount.Id

# Give your user principal access to all storage account permissions, on your Key Vault instance
Set-AzKeyVaultAccessPolicy -VaultName $keyVaultName -UserPrincipalName $userId -PermissionsToStorage get, list, delete, set, update, regeneratekey, getsas, listsas, deletesas, setsas, recover, backup, restore, purge

# Add your storage account to your Key Vault's managed storage accounts
Add-AzKeyVaultManagedStorageAccount -VaultName $keyVaultName -AccountName $storageAccountName -AccountResourceId $storageAccount.Id -ActiveKeyName $storageAccountKey -DisableAutoRegenerateKey

$storageAccountName = "19013vbimagesav2"

$storageContext = New-AzStorageContext -StorageAccountName $storageAccountName -Protocol Https -StorageAccountKey Key1

get-AzWvdWorkspace
$obj = get-AzWvdWorkspace
$obj.ToJson()

Get-Command -Module Az.DesktopVirtualization

Get-AzLocation | Where { $_.Displayname –match 'east' } | Format-Table

$locName="eastus"
Get-AzVMImagePublisher -Location $locName | Select microsoftvisualstudio


$publisher = "MicrosoftWindowsDesktop"
Get-AzVMImageOffer -Location $locName -PublisherName $publisher 
$offer = "Windows-10"
Get-AzVMImageSku -Location $locName -PublisherName $publisher -Offer $offer 
$sku = "20h1-evd"
Get-AzVMImage -Location $locName -PublisherName $publisher -Offer $offer -Skus $sku

