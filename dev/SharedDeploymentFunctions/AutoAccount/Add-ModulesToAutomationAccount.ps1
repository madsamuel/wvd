<#
.SYNOPSIS
Function to add required modules to Azure Automation account

.DESCRIPTION
Function to add required modules to Azure Automation account

.PARAMETER ResourceGroupName
Parameter description

.PARAMETER AutomationAccountName
Parameter description

.PARAMETER ModuleName
Parameter description

.PARAMETER ModuleVersion
Version of the module to upload. If not specified latest version will be imported.

.EXAMPLE
An example

#>
function Add-ModulesToAutomationAccount {
    param(
        [Parameter(mandatory = $true)]
        [string]$ResourceGroupName,

        [Parameter(mandatory = $true)]
        [string]$AutomationAccountName,

        [Parameter(mandatory = $true)]
        [string]$ModuleName,

        [Parameter(mandatory = $false)]
        [string]$ModuleVersion
    )

    begin {
        Write-Debug ("[{0} entered]" -f $MyInvocation.MyCommand)
    }

    process {

        $searchUrl = 'https://www.powershellgallery.com/api/v2/Search()'
        $FullUrl = "{0}?`$filter=IsLatestVersion&searchTerm=%27{1} {2}%27&targetFramework=%27%27&includePrerelease=false&`$skip=0&`$top=40" -f $searchUrl, $ModuleName, $ModuleVersion

        [array]$SearchResult = Invoke-RestMethod -Method Get -Uri $FullUrl
        if ($SearchResult.Count -ne 1) {
            $SearchResult = $SearchResult[0]
        }

        if (!$SearchResult) {
            Write-Error "Could not find module '$ModuleName' on PowerShell Gallery."
        }
        elseif ($SearchResult.Count -and $SearchResult.Length -gt 1) {
            Write-Error "Module name '$ModuleName' returned multiple results. Please specify an exact module name."
        }
        else {
            $PackageDetails = Invoke-RestMethod -Method Get -Uri $SearchResult.Id

            if (-not $ModuleVersion) {
                $ModuleVersion = $PackageDetails.entry.properties.version
            }

            $ModuleContentUrl = "https://www.powershellgallery.com/api/v2/package/$ModuleName/$ModuleVersion"

            try {
                # Test if the module/version combination exists
                Invoke-RestMethod $ModuleContentUrl -ErrorAction Stop | Out-Null
                $Stop = $False
            }
            catch {
                Write-Error "Module with name '$ModuleName' of version '$ModuleVersion' does not exist. Are you sure the version specified is correct?"
                $Stop = $True
            }

            if (-not $Stop) {
                # Find the actual blob storage location of the module
                do {
                    $ActualUrl = $ModuleContentUrl
                    $ModuleContentUrl = (Invoke-WebRequest -Uri $ModuleContentUrl -MaximumRedirection 1 -UseBasicParsing -ErrorAction Ignore).Headers.Location
                } while ($Null -ne $ModuleContentUrl)

                $newModuleInput = @{
                    ResourceGroupName     = $ResourceGroupName
                    AutomationAccountName = $AutomationAccountName
                    Name                  = $ModuleName
                    ContentLink           = $ActualUrl
                }
                New-AzAutomationModule @newModuleInput
            }
        }
    }

    end {
        Write-Debug ("[{0} existed]" -f $MyInvocation.MyCommand)
    }
}