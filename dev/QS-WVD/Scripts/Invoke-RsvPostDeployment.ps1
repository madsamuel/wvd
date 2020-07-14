<#
.SYNOPSIS
Run the Post-Deployment for the recovery services vault deployment

.DESCRIPTION
Run the Post-Deployment for the recovery services vault deployment
- Set protection items up

.PARAMETER orchestrationFunctionsPath
Path to the required functions

.PARAMETER recoveryServicesVaultName
Mandatory. Name of the RSV to backup the items in

.PARAMETER RecoveryServicesVaultResourceGroup
Mandatory. Resource group name of the RSV to backup the items in 

.PARAMETER fileSharePolicyMaps
Mandatory. A an array of items to backup. Each item needs the 'policyName' specified and a list of backup 'items' specified.
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

.PARAMETER Confirm
Will promt user to confirm the action to create invasible commands

.PARAMETER WhatIf
Dry run of the script

.EXAMPLE
Invoke-RsvPostDeployment -orchestrationFunctionsPath $currentDir  -RecoveryServicesVaultName 'ProfilesBackupVault' -RecoveryServicesVaultResourceGroup 'WVD-Mgmt-Rg' -fileSharePolicyMaps $fileSharePolicyMaps

Add the items specified in the 'fileSharePolicyMaps' objects as backup items to the RSV 'ProfilesBackupVault' in resource group 'WVD-Mgmt-Rg'
#>
function Invoke-RsvPostDeployment {

    [CmdletBinding(SupportsShouldProcess = $true)]
    param(
        [Parameter(Mandatory = $true)]
        [string] $orchestrationFunctionsPath,

        [Parameter(Mandatory = $true)]
        [string] $recoveryServicesVaultName,

        [Parameter(Mandatory = $true)]
        [string] $RecoveryServicesVaultResourceGroup,

        [Parameter(Mandatory = $true)]
        [Hashtable[]] $fileSharePolicyMaps
    )

    begin {
        Write-Verbose ("[{0} entered]" -f $MyInvocation.MyCommand)
        . "$orchestrationFunctionsPath\Rsv\Set-RsvProtectedItemsConfiguration.ps1"

    }

    process {
        Write-Verbose "################################"
        Write-Verbose "## 1 - Set protected items up ##"
        Write-Verbose "################################"

        $InputObject = @{
            recoveryServicesVaultName          = $RecoveryServicesVaultName
            RecoveryServicesVaultResourceGroup = $RecoveryServicesVaultResourceGroup
            fileSharePolicyMaps                = $fileSharePolicyMaps 
        }
        if ($PSCmdlet.ShouldProcess("Protected items up for RSV '$recoveryServicesVaultName'", "Set")) {
            Set-RsvProtectedItemsConfiguration @InputObject
        }
    }
    end {
        Write-Verbose ("[{0} existed]" -f $MyInvocation.MyCommand)
    }
}