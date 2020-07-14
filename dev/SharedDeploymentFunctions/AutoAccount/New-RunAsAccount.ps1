function New-RunAsAccount {

    [CmdletBinding(SupportsShouldProcess = $true)]
    [OutputType('Microsoft.Azure.Commands.Automation.Model.Connection')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingConvertToSecureStringWithPlainText", "", Justification = "The secret retrieved from the keyvault can't be decrypted by PS, so it has to be retrieved as plain text and then reconverted in secure string")]
    param (
        [Parameter(Mandatory = $true)]
        [string] $AutomationAccountName,

        [Parameter(Mandatory = $true)]
        [string] $ApplicationDisplayName,

        [Parameter(Mandatory = $true)]
        [string] $KeyVaultName,

        [Parameter(Mandatory = $true)]
        [string] $SelfSignedCertSecretName,

        [Parameter(Mandatory = $false)]
        [int] $AutoAccountRunAsCertExpiryInMonths = 12,

        [Parameter(Mandatory = $true)]
        [string] $tempPath
    )

    begin {
        Write-Debug ("[{0} entered]" -f $MyInvocation.MyCommand)   
        . "$PSScriptRoot/New-ConnectionServicePrincipal.ps1"
        . "$PSScriptRoot/New-CustomSelfSignedCertificate.ps1"
        . "$PSScriptRoot/New-AutomationCertificateAsset.ps1"
        . "$PSScriptRoot/New-AutomationConnectionAsset.ps1"
        . "$PSScriptRoot/Get-PasswordCredential.ps1"
    }

    process {
        Write-Verbose "Check requirement: Automation Account exists"
        $autoAccountResource = Get-AzResource -Name $AutomationAccountName -ResourceType 'Microsoft.Automation/automationAccounts' -ErrorAction 'SilentlyContinue'
        if (-not $autoAccountResource) {
            throw "Automation account '$AutomationAccountName' is not deployed"
        }
        $AutomationAccountRGName = $autoAccountResource.ResourceGroupName
        Write-Verbose "Checked requirements"

        $CertifcateAssetName = "AzureRunAsCertificate"
        $ConnectionTypeName = "AzureServicePrincipal"

        Write-Verbose "========================"
        Write-Verbose "== HANDLE CERTIFICATE =="

        $CertificateName = "{0}{1}" -f $AutomationAccountName, $CertifcateAssetName
        $PfxCertPathForRunAsAccount = Join-Path $tempPath ($CertificateName + ".pfx")
        $CerCertPathForRunAsAccount = Join-Path $tempPath ($CertificateName + ".cer")
    
        Write-Verbose "Gather cert information"
        $SelfSignedCertSecret = Get-AzKeyVaultSecret -VaultName $KeyVaultName -Name $SelfSignedCertSecretName -ErrorAction 'SilentlyContinue'
        if (-not $SelfSignedCertSecret) {
            Write-Verbose ("No cert secret '{0}' found in key vault '{1}'. Generating new." -f $SelfSignedCertSecretName, $KeyVaultName)
            $generatedCredential = Get-PasswordCredential
            $selfSignedCertPlainPassword = $generatedCredential.Password
            $selfSignedCertPassword = ConvertTo-SecureString $selfSignedCertPlainPassword -AsPlainText -Force
            Set-AzKeyVaultSecret -VaultName $KeyVaultName -Name $SelfSignedCertSecretName -SecretValue $selfSignedCertPassword
        }
        else {
            Write-Verbose ("Cert secret '{0}' found in key vault '{1}'." -f $SelfSignedCertSecretName, $KeyVaultName)
            $selfSignedCertPassword = $SelfSignedCertSecret.SecretValue
            $selfSignedCertPlainPassword = $SelfSignedCertSecret.SecretValueText
        }

        $selfSignedCertIntputObject = @{
            certificateName                    = $CertificateName 
            selfSignedCertPassword             = $selfSignedCertPassword 
            certPath                           = $PfxCertPathForRunAsAccount 
            certPathCer                        = $CerCertPathForRunAsAccount 
            AutoAccountRunAsCertExpiryInMonths = $AutoAccountRunAsCertExpiryInMonths
        }
        New-CustomSelfSignedCertificate @selfSignedCertIntputObject
    
        Write-Verbose "==============================="
        Write-Verbose "== HANDLE SERVICE PRINCIPAL  =="
        $PfxCert = New-Object -TypeName System.Security.Cryptography.X509Certificates.X509Certificate2 -ArgumentList @($PfxCertPathForRunAsAccount, $selfSignedCertPlainPassword)
        $ApplicationId = New-ConnectionServicePrincipal -PfxCert $PfxCert -applicationDisplayName $ApplicationDisplayName

        Write-Verbose "=================================="
        Write-Verbose "== RENEW AUTOMATION CERTIFICATE =="
        Write-Verbose "Create the Automation certificate asset"
    
        $certInputObject = @{
            resourceGroup         = $AutomationAccountRGName 
            automationAccountName = $AutomationAccountName 
            certifcateAssetName   = $CertifcateAssetName 
            certPath              = $PfxCertPathForRunAsAccount 
            CertPassword          = $selfSignedCertPassword
            Exportable            = $true
        }
        $null = New-AutomationCertificateAsset @certInputObject

        Write-Verbose "======================="
        Write-Verbose "== SET RUNAS ACCOUNT =="
        Write-Verbose "Create an Automation connection asset named AzureRunAsConnection in the Automation account. This connection uses the service principal."
        $ctx = Get-AzContext  

        $ConnectionFieldValues = @{
            ApplicationId         = $ApplicationId
            TenantId              = $ctx.Tenant.Id
            CertificateThumbprint = $PfxCert.Thumbprint
            SubscriptionId        = $ctx.Subscription.Id 
        }

        $connectInputObject = @{
            resourceGroup         = $AutomationAccountRGName 
            automationAccountName = $AutomationAccountName 
            connectionAssetName   = 'AzureRunAsConnection' # DO NOT CHANGE
            connectionTypeName    = $ConnectionTypeName 
            connectionFieldValues = $ConnectionFieldValues
        }
        New-AutomationConnectionAsset @connectInputObject
    }

    end {
        Write-Debug ("[{0} existed]" -f $MyInvocation.MyCommand)
    }
}