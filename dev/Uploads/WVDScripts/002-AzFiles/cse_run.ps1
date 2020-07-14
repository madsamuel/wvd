[CmdletBinding(SupportsShouldProcess = $true)]
param (
    # [Parameter(Mandatory = $true)]
    # [ValidateNotNullOrEmpty()]
    # [string] $storageAccountKey,

    [Parameter(Mandatory = $false)]
    [Hashtable] $DynParameters,

    [Parameter(Mandatory = $true)]
    [string] $username,

    [Parameter(Mandatory = $true)]
    [string] $password,
    
    [Parameter(Mandatory = $false)]
    [ValidateNotNullOrEmpty()]
    [string] $ConfigurationFileName = "azfiles.parameters.json"
)

#####################################

##########
# Helper #
##########
#region Functions
function LogInfo($message) {
    Log "Info" $message
}

function LogError($message) {
    Log "Error" $message
}

function LogSkip($message) {
    Log "Skip" $message
}

function LogWarning($message) {
    Log "Warning" $message
}

function Log {

    <#
    .SYNOPSIS
   Creates a log file and stores logs based on categories with tab seperation

    .PARAMETER category
    Category to put into the trace

    .PARAMETER message
    Message to be loged

    .EXAMPLE
    Log 'Info' 'Message'

    #>

    Param (
        $category = 'Info',
        [Parameter(Mandatory = $true)]
        $message
    )

    $date = get-date
    $content = "[$date]`t$category`t`t$message`n"
    Write-Verbose "$content" -verbose

    if (! $script:Log) {
        $File = Join-Path $env:TEMP "log.log"
        Write-Error "Log file not found, create new $File"
        $script:Log = $File
    }
    else {
        $File = $script:Log
    }
    Add-Content $File $content -ErrorAction Stop
}

function Set-Logger {
    <#
    .SYNOPSIS
    Sets default log file and stores in a script accessible variable $script:Log
    Log File name "executionCustomScriptExtension_$date.log"

    .PARAMETER Path
    Path to the log file

    .EXAMPLE
    Set-Logger
    Create a logger in
    #>

    Param (
        [Parameter(Mandatory = $true)]
        $Path
    )

    # Create central log file with given date

    $date = Get-Date -UFormat "%Y-%m-%d %H-%M-%S"

    $scriptName = (Get-Item $PSCommandPath ).Basename
    $scriptName = $scriptName -replace "-", ""

    Set-Variable logFile -Scope Script
    $script:logFile = "executionCustomScriptExtension_" + $scriptName + "_" + $date + ".log"

    if ((Test-Path $path ) -eq $false) {
        $null = New-Item -Path $path -type directory
    }

    $script:Log = Join-Path $path $logfile

    Add-Content $script:Log "Date`t`t`tCategory`t`tDetails"
}
#endregion


## MAIN
#Set-Logger "C:\WindowsAzure\CustomScriptExtension\Log" # inside "executionCustomScriptExtension_$date.log"
Set-Logger "C:\WindowsAzure\Logs\Plugins\Microsoft.Compute.CustomScriptExtension\executionLog\azfilesconfig" # inside "executionCustomScriptExtension_$scriptName_$date.log"

LogInfo("###################")
LogInfo("## 0 - LOAD DATA ##")
LogInfo("###################")
#$storageaccountkey = $DynParameters.storageaccountkey

$PsParam = Get-ChildItem -path "_deploy" -Filter $ConfigurationFileName -Recurse | sort -Property FullName
$ConfigurationFilePath=$PsParam.FullName
#$ConfigurationFilePath= Join-Path $PSScriptRoot $ConfigurationFileName

$ConfigurationJson = Get-Content -Path $ConfigurationFilePath -Raw -ErrorAction 'Stop'

try { $azfilesconfig = $ConfigurationJson | ConvertFrom-Json -ErrorAction 'Stop' }
catch {
    Write-Error "Configuration JSON content could not be converted to a PowerShell object" -ErrorAction 'Stop'
}

LogInfo("##################")
LogInfo("## 0 - EVALUATE ##")
LogInfo("##################")
foreach ($config in $azfilesconfig.azfilesconfig) {
    
    if ($config.enableAzureFiles) {
        LogInfo("############################")
        LogInfo("## 1 - Enable Azure Files ##")
        LogInfo("############################")
        LogInfo("Trigger user group creation")

        LogInfo("Set execution policy...")
        
        #Change the execution policy to unblock importing AzFilesHybrid.psm1 module
        Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope CurrentUser

        # Navigate to where AzFilesHybrid is unzipped and stored and run to copy the files into your path
        .\CopyToPSPath.ps1 

        LogInfo("Import Az...")
        Install-Module -Name Az
        Import-Module -Name Az

        LogInfo("Import AzFilesHybrid module...")
        Import-Module -Name AzFilesHybrid

        LogInfo("Login with an Azure AD credential")
        $Credential = New-Object System.Management.Automation.PsCredential($username, (ConvertTo-SecureString $password -AsPlainText -Force))
        Connect-AzAccount -Credential $Credential

        #Define parameters
        $SubscriptionId = $config.SubscriptionId
        $ResourceGroupName = $config.ResourceGroupName
        $StorageAccountName = $config.StorageAccountName

        LogInfo("Select the target subscription for the current session")
        Select-AzSubscription -SubscriptionId $SubscriptionId 

        # Register the target storage account with your active directory environment under the target OU (for example: specify the OU with Name as "UserAccounts" or DistinguishedName as "OU=UserAccounts,DC=CONTOSO,DC=COM"). 
        # You can use to this PowerShell cmdlet: Get-ADOrganizationalUnit to find the Name and DistinguishedName of your target OU. If you are using the OU Name, specify it with -OrganizationalUnitName as shown below. If you are using the OU DistinguishedName, you can set it with -OrganizationalUnitDistinguishedName. You can choose to provide one of the two names to specify the target OU.
        # You can choose to create the identity that represents the storage account as either a Service Logon Account or Computer Account (default parameter value), depends on the AD permission you have and preference. 
        # Run Get-Help Join-AzStorageAccountForAuth for more details on this cmdlet.

        LogInfo("Join-AzStorageAccountForAuth...")

        Join-AzStorageAccountForAuth `
                -ResourceGroupName $ResourceGroupName `
                -StorageAccountName $StorageAccountName `
                -DomainAccountType "ComputerAccount" `
                -OrganizationalUnitName "Domain Controllers"
    
        LogInfo("Az files enabled!")
    }
}
