<#
.SYNOPSIS
Function to check if the module is imported

.DESCRIPTION
Function to check if the module is imported

.PARAMETER ResourceGroupName
Parameter description

.PARAMETER AutomationAccountName
Parameter description

.PARAMETER ModuleName
Parameter description

.EXAMPLE
An example

.NOTES
General notes
#>
function Test-IsAutoAccountModuleImported {
    param(
        [Parameter(mandatory = $true)]
        [string] $ResourceGroupName,

        [Parameter(mandatory = $true)]
        [string] $AutomationAccountName,

        [Parameter(mandatory = $true)]
        [string] $ModuleName
    )

    begin {
        Write-Debug ("[{0} entered]" -f $MyInvocation.MyCommand)
    }

    process {
        $IsModuleImported = $false
        $tryCount = 1
        $maxTries = 15 
        while (-not $IsModuleImported -and $tryCount -lt $maxTries) { 
    
            $moduleCheckInputObject = @{
                ResourceGroupName     = $ResourceGroupName 
                AutomationAccountName = $AutomationAccountName
                Name                  = $ModuleName 
                ErrorAction           = 'SilentlyContinue'
            }
            $IsModule = Get-AzAutomationModule @moduleCheckInputObject

            if ($IsModule.ProvisioningState -eq "Succeeded") {
                $IsModuleImported = $true
                Write-Verbose "Successfully $ModuleName module imported into Automation Account Modules..."
            }
            else {
                Write-Verbose ("Waiting 10 seconds for module import of '{0}' into automation account [{1}|{2}]" -f $ModuleName, $tryCount, $maxTries)
                $tryCount++;
                Start-Sleep 10 
            }
        }
    }
    
    end {
        Write-Debug ("[{0} existed]" -f $MyInvocation.MyCommand)
    }
}