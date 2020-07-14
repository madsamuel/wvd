<#
    .SYNOPSIS
    This is a sample script for to deploy the required resources to execute scaling script in Microsoft Azure Automation Account.

    .DESCRIPTION
    This sample script will create the scale script execution required resources in Microsoft Azure. Resources are resourcegroup,automation account,automation account runbook, 
    automation account webhook, log analytic workspace and with customtables.
    Run this PowerShell script in adminstrator mode
    This script depends  Az PowerShell module. To install Az module execute the following commands. Use "-AllowClobber" parameter if you have more than one version of PowerShell modules installed.

    PS C:\>Install-Module Az  -AllowClobber

    .PARAMETER AutomationAccountName
    Optional. Provide the name of the automation account name do you want create.

    .PARAMETER WorkspaceName
    Optional. Provide name of the log analytic workspace.

    .PARAMETER KeyVaultName
    Optional. The key vault to store the webhook uri data in. Required if other resources should use it.

    .EXAMPLE
    Set-AutomationAccountConfiguration -AutomationAccountName "WVDScalingAutoAcc"

    Set the automation account WVDScalingAutoAcc up.
#>
function Set-AutomationAccountConfiguration {
    param(
        [Parameter(mandatory = $true)]
        [string] $AutomationAccountName,

        [Parameter(mandatory = $true)]
        [string] $ScalingRunbookName,

        [Parameter(mandatory = $true)]
        [string] $WebhookName,

        [Parameter(mandatory = $False)]
        [pscustomobject[]] $RequiredAutoAccountModules = @(
            [pscustomobject]@{ ModuleName = 'Az.Accounts' }
            [pscustomobject]@{ ModuleName = 'Az.DesktopVirtualization' }
            [pscustomobject]@{ ModuleName = 'OMSIngestionAPI' }
            [pscustomobject]@{ ModuleName = 'Az.Compute' }
            [pscustomobject]@{ ModuleName = 'Az.Resources' }
            [pscustomobject]@{ ModuleName = 'Az.Automation' }
        ),

        [Parameter(mandatory = $false)]
        [string] $KeyVaultName
    )

    begin {
        Write-Debug ("[{0} entered]" -f $MyInvocation.MyCommand)    
        
        . "$PSScriptRoot/Test-IsAutoAccountModuleImported.ps1"
        . "$PSScriptRoot/Add-ModulesToAutomationAccount.ps1"
        . "$PSScriptRoot/Send-LogAnalyticsData.ps1"
    }

    process {
        Write-Verbose "==========================#"
        Write-Verbose "== VALIDATE REQUIREMENTS =="

        Write-Verbose "Check requirement: Required role assignments"
        # Get the Role Assignment of the authenticated user
        $ctx = Get-AzContext
        if ($ctx.Account.Type -eq 'ServicePrincipal') {
            $sp = Get-AzADServicePrincipal -ApplicationId $ctx.Account.Id
            $RoleAssignment = (Get-AzRoleAssignment -ObjectId $sp.Id)
        }
        else {
            $RoleAssignment = (Get-AzRoleAssignment -SignInName $ctx.Account)
        }
        if (-not ($RoleAssignment.RoleDefinitionName -eq "Owner" -or $RoleAssignment.RoleDefinitionName -eq "Contributor")) {
            throw "Deplyoment principal should have the Owner/Contributor permissions"
        }
        Write-Verbose "Checked requirement"

        Write-Verbose "Check requirement: Automation Account exists"
        $autoAccountResource = Get-AzResource -Name $AutomationAccountName -ResourceType 'Microsoft.Automation/automationAccounts' -ErrorAction 'SilentlyContinue'
        if (-not $autoAccountResource) {
            throw "Automation account '$AutomationAccountName' is not deployed"
        }
        $AutomationAccountRGName = $autoAccountResource.ResourceGroupName
        Write-Verbose "Checked requirement"
    
        Write-Verbose "Check requirement: All Requirement checks passed"

        Write-Verbose "Disabled runbook configuration"
    
        Write-Verbose "==========================#"
        Write-Verbose "== RUNBOOK CONFIGURATION =="
        #Check if the Webhook URI exists in automation variable
        $getWebhookAutomationVariableInputObject = @{
            Name                  = "WebhookURI_$ScalingRunbookName" 
            ResourceGroupName     = $AutomationAccountRGName 
            AutomationAccountName = $AutomationAccountName 
            ErrorAction           = 'SilentlyContinue'
        }
        $WebhookURIVar = Get-AzAutomationVariable @getWebhookAutomationVariableInputObject
        if (-not $WebhookURIVar) {
            Write-Verbose "Create Webhook '$WebhookName'"
            $createWebhookInputObject = @{
                Name                  = $WebhookName 
                RunbookName           = $ScalingRunbookName 
                IsEnabled             = $true 
                ExpiryTime            = (Get-Date).AddYears(5) 
                ResourceGroupName     = $AutomationAccountRGName 
                AutomationAccountName = $AutomationAccountName 
                Force                 = $true
            }
            $Webhook = New-AzAutomationWebhook @createWebhookInputObject
            Write-Verbose "Automation Account Webhook is created with name '$WebhookName' and expiry date in 5 years" 

            $WebhookUri = $Webhook.WebhookURI

            Write-Verbose "Create automation variable with webhook uri"
            $AutomationVariableInputObject = @{
                Name                  = "WebhookURI_$ScalingRunbookName" 
                Encrypted             = $false 
                ResourceGroupName     = $AutomationAccountRGName 
                AutomationAccountName = $AutomationAccountName 
                Value                 = $WebhookUri
            }
            $null = New-AzAutomationVariable @AutomationVariableInputObject
            Write-Verbose "Webhook URI stored in Azure Automation Acccount variables" 
        }
        else {
            Write-Verbose "Webhook '$WebhookName' already existing for automation account '$AutomationAccountName'"
            $WebhookUri = $WebhookURIVar.Value
        }

        if ($KeyVaultName) {
            if (-not (Get-AzKeyVaultSecret -VaultName $KeyVaultName -Name "$WebhookName-Uri") -or -not((Get-AzKeyVaultSecret -VaultName $KeyVaultName -Name "$WebhookName-Uri").SecretValueText -eq $WebhookUri)) {
                Write-Verbose ("Store WebhookUri in keyvault '{0}' in secret '{1}'" -f $KeyVaultName, "$WebhookName-Uri")
                $null = Set-AzKeyVaultSecret -VaultName $KeyVaultName -Name "$WebhookName-Uri" -SecretValue (ConvertTo-SecureString $WebhookUri -AsPlainText -Force)
            }
            else {
                Write-Verbose "WebUri already stored in key vault"
            }
        }
    
        Write-Verbose "========================#"
        Write-Verbose "== MODULE INSTALLATION =="
        foreach ($RequiredModule in $RequiredAutoAccountModules) {
            # Check if the required modules are imported 
            $ImportedModule = Get-AzAutomationModule -ResourceGroupName $AutomationAccountRGName -AutomationAccountName $AutomationAccountName -Name $RequiredModule.ModuleName -ErrorAction SilentlyContinue
            if ($null -eq $ImportedModule) {
                Write-Verbose ("Module '{0}' not in AutomationAccount. Adding it..." -f $RequiredModule.ModuleName)
                Add-ModulesToAutomationAccount -ResourceGroupName $AutomationAccountRGName -AutomationAccountName $AutomationAccountName -ModuleName $RequiredModule.ModuleName
                Test-IsAutoAccountModuleImported -ModuleName $RequiredModule.ModuleName -ResourceGroupName $AutomationAccountRGName -AutomationAccountName $AutomationAccountName
            }
            else {
                Write-Verbose ("Module '{0}' already uploaded to AutomationAccount." -f $RequiredModule.ModuleName)
            }
        }
    }
    
    end {
        Write-Debug ("[{0} existed]" -f $MyInvocation.MyCommand)
    }
}