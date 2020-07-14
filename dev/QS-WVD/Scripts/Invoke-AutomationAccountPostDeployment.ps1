<#
.SYNOPSIS
Run the Post-Deployment for the automation account deployment

.DESCRIPTION
Run the Post-Deployment for the automation account deployment
- Configure StorageAccount
- Create RunAs service principal 

.PARAMETER orchestrationFunctionsPath
Path to the required functions

.PARAMETER AutomationAccountName
Mandatory. Name of the automation account

.PARAMETER ScalingRunbookName
Mandatory. Name of the scaling runbook

.PARAMETER WebhookName
Mandatory. Name of the runbook webhook to create

.PARAMETER RunAsConnectionSPName
Mandatory. Name of the service principal to create that acts as the RunAs service principal for the automation account

.PARAMETER KeyVaultName
Mandatory. Name of the key vault to use for required secrets

.PARAMETER RunAsSelfSignedCertSecretName
Mandatory. Name of the secret for the cert password

.PARAMETER AutoAccountRunAsCertExpiryInMonths
Mandatory. Amount of months the certificate for the run as account should remain valid

.PARAMETER tempPath
Mandatory. A path to store files in that are created during execution

.PARAMETER Confirm
Optional. Will promt user to confirm the action to create invasible commands

.PARAMETER WhatIf
Optional.  Dry run of the script

.EXAMPLE
Invoke-AutomationAccountPostDeployment -orchestrationFunctionsPath $currentDir -AutomationAccountName 'myAccount' -ScalingRunbookName 'scalingRunbook' -WebhookName 'scalingWebhook' -RunAsConnectionSPName 'scalingServicePrincipal' -KeyVaultName 'wvd-kvlt' -RunAsSelfSignedCertSecretName 'mycert-Password' -AutoAccountRunAsCertExpiryInMonths 12

Configure the automation account 'myAccount' with the given parameters
#>
function Invoke-AutomationAccountPostDeployment {

    [CmdletBinding(SupportsShouldProcess = $true)]
    param(
        [Parameter(Mandatory = $true)]
        [string] $orchestrationFunctionsPath,

        [Parameter(Mandatory = $true)]
        [string] $AutomationAccountName,

        [Parameter(Mandatory = $true)]
        [string] $ScalingRunbookName,

        [Parameter(Mandatory = $true)]
        [string] $WebhookName,

        [Parameter(Mandatory = $true)]
        [string] $RunAsConnectionSPName,

        [Parameter(Mandatory = $true)]
        [string] $KeyVaultName,

        [Parameter(Mandatory = $true)]
        [string] $RunAsSelfSignedCertSecretName,

        [Parameter(Mandatory = $true)]
        [int] $AutoAccountRunAsCertExpiryInMonths,

        [Parameter(Mandatory = $true)]
        [string] $tempPath
    )

    begin {
        Write-Verbose ("[{0} entered]" -f $MyInvocation.MyCommand)

        . "$orchestrationFunctionsPath\AutoAccount\Set-AutomationAccountConfiguration.ps1"
        . "$orchestrationFunctionsPath\AutoAccount\New-RunAsAccount.ps1"
    }

    process {

        Write-Verbose "######################################"
        Write-Verbose "## 1 - CONFIGURE AUTOMATION ACCOUNT ##"
        Write-Verbose "######################################"

        if ($PSCmdlet.ShouldProcess("AutomationAccount '$AutomationAccountName' configuration up.", "Set")) {        
            $autoAccInputObject = @{
                AutomationAccountName = $AutomationAccountName
                ScalingRunbookName    = $ScalingRunbookName
                WebhookName           = $WebhookName
                KeyVaultName          = $KeyVaultName
            }
            Set-AutomationAccountConfiguration @autoAccInputObject -Verbose
        }
        Write-Verbose "Automation account configured"

        Write-Verbose "##############################"
        Write-Verbose "## 2 - HANDLE RUNAS ACCOUNT ##"
        Write-Verbose "##############################"
        if ($PSCmdlet.ShouldProcess("RunAs account up", "Set")) {
            $runAsInputObject = @{
                AutomationAccountName              = $AutomationAccountName
                ApplicationDisplayName             = $RunAsConnectionSPName
                KeyVaultName                       = $KeyVaultName
                SelfSignedCertSecretName           = $RunAsSelfSignedCertSecretName
                AutoAccountRunAsCertExpiryInMonths = $AutoAccountRunAsCertExpiryInMonths
                tempPath                           = $tempPath
            }
            New-RunAsAccount @runAsInputObject -Verbose
        }
    }
    end {
        Write-Verbose ("[{0} existed]" -f $MyInvocation.MyCommand)
    }
}