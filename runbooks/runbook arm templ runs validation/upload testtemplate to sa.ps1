# Log into Azure
Connect-AzAccount

#region one time creation of storage 
$rgName = "runARMfromRunbook"
New-AzResourceGroup -Name "runARMfromRunbook" -Location "East US"

$saName = "runarmfromrunbooksa"
New-AzStorageAccount -ResourceGroupName $rgName -Name $saName -Location "East US" -SkuName Standard_LRS
#endregion

#region uploadt ARM tempalte to storage
# Creating the storage account is one time operation
# Get the access key for your storage account
$key = Get-AzStorageAccountKey -ResourceGroupName $rgName -Name $saName

# Create an Azure Storage context using the first access key
$context = New-AzStorageContext -StorageAccountName $saName -StorageAccountKey $key[0].value

# Create a file share named 'resource-templates' in your Azure Storage account
$fileShare = New-AzStorageShare -Name 'resource-templates' -Context $context
# $fileShare = Get-AzStorageShare -Name 'resource-templates' -Context $context

# by default # Add the ValidateCred.json file to the new file share
# now modified to C:\code repo\madsamuel\wvd\runbooks\runbook arm templ runs validation\new-arm-template-to-replace-what-runbook-calls.json
# "TemplatePath" is the path where you saved the ValidateCred.json file
$templateFile = "C:\code repo\madsamuel\wvd\runbooks\runbook arm templ runs validation\new-arm-template-to-replace-what-runbook-calls.json"
Set-AzStorageFileContent -ShareName $fileShare.Name -Context $context -Source $templateFile
#endregion

#region upload runbook 
# MyPath is the path where you saved DeployTemplate.ps1
# MyResourceGroup is the name of the Azure ResourceGroup that contains your Azure Automation account
# MyAutomationAccount is the name of your Automation account
$aaName = "aadcredcheck"
$aargName = "0709-rg"

$importParams = @{
    Path = 'C:\code repo\madsamuel\wvd\runbooks\runbook arm templ runs validation\DeployTemplateCustomArm.ps1'
    ResourceGroupName = "0709-rg"
    AutomationAccountName = $aaName
    Type = 'PowerShell'
    Name = "runARMTemplValidateCredsCustomArm"
}
Import-AzAutomationRunbook @importParams

# Publish the runbook
$publishParams = @{
    ResourceGroupName = $aargName
    AutomationAccountName = $aaName
    Name = 'runARMTemplValidateCredsCustomArm'
}
Publish-AzAutomationRunbook @publishParams
#endregion

#region run Runbook
# Set up the parameters for the runbook
$runbookParams = @{
    ResourceGroupName = $rgName
    StorageAccountName =  'runarmfromrunbooksa'
    StorageAccountKey = $key[0].Value # We got this key earlier
    StorageFileName = 'new-arm-template-to-replace-what-runbook-calls.json'
    identity = "WVDServicePrincipal"
    name = "STEFAN" + " GEORGIEV"
    
    utcValue = [System.DateTime]::UtcNow.ToString()
}

# Set up parameters for the Start-AzAutomationRunbook cmdlet
$startParams = @{
    ResourceGroupName = '0709-rg'
    AutomationAccountName = 'aadcredcheck'
    Name = 'runARMTemplValidateCredsCustomArm'
    Parameters = $runbookParams
}

# Start the runbook
$job = Start-AzAutomationRunbook @startParams
$job.Status
#endregion

#region check status of a job

#endregion

#Note: prior to runnign the arm template make sure to import the Az module at at account level or use sams workaround to include programatically
# Connect-AzAccount : The term 'Connect-AzAccount' is not recognized as the name of a cmdlet, function, script file, 
# or operable program. Check the spelling of the name, or if a path was included, verify that the path is correct and
# try again. At line:21 char:1 + Connect-AzAccount ` + ~~~~~~~~~~~~~~~~~ + CategoryInfo : ObjectNotFound: (Connect-AzAccount:String) [],
# CommandNotFoundException + FullyQualifiedErrorId : CommandNotFoundException