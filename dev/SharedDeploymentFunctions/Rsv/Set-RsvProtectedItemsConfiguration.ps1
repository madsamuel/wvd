<#
.SYNOPSIS
Set files shares as protection items in the given RSV

.DESCRIPTION
Set files shares as protection items in the given RSV

.PARAMETER RecoveryServicesVaultName
Name of the RSV to backup the items in

.PARAMETER RecoveryServicesVaultResourceGroup
Resource group name of the RSV to backup the items in 

.PARAMETER fileSharePolicyMaps
A an array of items to backup. Each item needs the 'policyName' specified and a list of backup 'items' specified.
Each of those backup items needs a 'StorageAccountName' specified an optionally 'FileShareNames' as a comma separated list.

E.g.
```Json
$fileSharePolicyMaps = $(
    @{
        policyName = 'filesharepolicy'
        items = $(
            @{
                StorageAccountName = 'wvdprofilesstorageacc01'
            },
            @{
                StorageAccountName = 'wvdprofilesstorageacc01' 
                FileShareNames = 'wvdprofiles' 
            },
            @{
                StorageAccountName = 'wvdprofilesstorageacc02' 
                FileShareNames = 'wvdprofiles1' 
            }
            @{
                StorageAccountName = 'wvdprofilesstorageacc02' 
                FileShareNames = 'wvdprofiles1,wvdprofiles2' 
            }
        )
    }
)
```

.EXAMPLE
Set-RsvProtectedItemsConfiguration -RecoveryServicesVaultName 'ProfilesBackupVault' -RecoveryServicesVaultResourceGroup 'WVD-Mgmt-Rg' -fileSharePolicyMaps $fileSharePolicyMaps

Add the items specified in the 'fileSharePolicyMaps' objects as backup items to the RSV 'ProfilesBackupVault' in resource group 'WVD-Mgmt-Rg'
#>
function Set-RsvProtectedItemsConfiguration {

    [CmdletBinding(SupportsShouldProcess = $true)]
    param(
        [Parameter(Mandatory = $true)]
        [string] $RecoveryServicesVaultName,

        [Parameter(Mandatory = $true)]
        [string] $RecoveryServicesVaultResourceGroup,

        [Parameter(Mandatory = $false)]
        [Hashtable[]] $fileSharePolicyMaps = @()
    )

    begin {
        Write-Debug ("[{0} entered]" -f $MyInvocation.MyCommand)
    }

    process {
        Write-Verbose ("Fetch recovery services vault [{0}]" -f $RecoveryServicesVaultName)
        $vault = Get-AzRecoveryServicesVault -Name $RecoveryServicesVaultName -ResourceGroupName $RecoveryServicesVaultResourceGroup

        foreach ($fileSharePolicyMap in $fileSharePolicyMaps) {
            Write-Verbose ("Handle policy [{0}]" -f $fileSharePolicyMap.policyName)
            $filesharePolicy = Get-AzRecoveryServicesBackupProtectionPolicy -Name $fileSharePolicyMap.policyName -VaultId $vault.ID

            foreach ($item in $fileSharePolicyMap.items) {

                Write-Verbose ("Search protection container [{0}]" -f $item.StorageAccountName )
                $containerInputObject = @{
                    VaultId       = $vault.Id 
                    ContainerType = 'AzureStorage' 
                    FriendlyName  = $item.StorageAccountName 
                }
                $backupContainer = Get-AzRecoveryServicesBackupContainer @containerInputObject

                $relevantFileShareNames = @()
                if (-not $item.FileShareNames) {
                    Write-Verbose ("No file share specified for storage account [{0}]. Fetching all." -f $item.StorageAccountName)
                    $storageAccountResource = Get-AzResource -Name $item.StorageAccountName -ResourceType 'Microsoft.Storage/storageAccounts'
                    $storageAccount = Get-AzStorageAccount -Name $item.StorageAccountName -ResourceGroupName $storageAccountResource.ResourceGroupName
                    if ($fileShares = Get-AzStorageShare -Context $storageAccount.Context) {
                        $relevantFileShareNames += $fileShares.Name
                    }
                }
                else {
                    Write-Verbose ("One or multiple file shares specified for storage account [{0}]." -f $item.StorageAccountName)
                    $relevantFileShareNames += $item.FileShareNames.Split(',')
                }

                foreach ($fileShareName in $relevantFileShareNames) {
                
                    $getProtectedItemInputObject = @{
                        VaultId      = $vault.ID 
                        WorkloadType = 'AzureFiles' 
                        Container    = $backupContainer 
                        FriendlyName = $fileShareName 
                    }
                    if (Get-AzRecoveryServicesBackupItem @getProtectedItemInputObject -ErrorAction 'SilentlyContinue') {
                        Write-Verbose ("Storage account [{0}] file share [{1}] already is protected item" -f $item.StorageAccountName, $fileShareName)
                        continue
                    }

                    $newProtectedItemInputObject = @{
                        StorageAccountName = $item.StorageAccountName 
                        Name               = $fileShareName 
                        Policy             = $filesharePolicy
                        VaultId            = $vault.ID
                    }
                    if ($PSCmdlet.ShouldProcess(("Add storage account [{0}] file share [{1}] as protected item" -f $item.StorageAccountName, $fileShareName), "Set")) {
                        try {
                            Enable-AzRecoveryServicesBackupProtection @newProtectedItemInputObject
                        }
                        catch {
                            Write-Warning ("Setting backup item failed. Error: {0}" -f $_.Exception.Message)
                        }
                    }
                }
            }
        }  
    }
    
    end {
        Write-Debug ("[{0} existed]" -f $MyInvocation.MyCommand)
    }
}