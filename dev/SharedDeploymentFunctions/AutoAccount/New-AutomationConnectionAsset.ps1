function New-AutomationConnectionAsset {

    param(
        [Parameter(Mandatory = $true)]
        [string] $resourceGroup, 
        
        [Parameter(Mandatory = $true)]
        [string] $automationAccountName,
        
        [Parameter(Mandatory = $true)]
        [string] $connectionAssetName, 

        [Parameter(Mandatory = $true)]
        [string] $connectionTypeName, 

        [Parameter(Mandatory = $true)]
        [System.Collections.Hashtable] $connectionFieldValues 
    )
        

    begin {
        Write-Debug ("[{0} entered]" -f $MyInvocation.MyCommand)
    }

    process {
        Write-Verbose "Remove current run as connection"
        $removeConnectionInputObject = @{
            ResourceGroupName     = $resourceGroup 
            AutomationAccountName = $automationAccountName 
            Name                  = $connectionAssetName 
            Force                 = $true 
            ErrorAction           = 'SilentlyContinue'
        }
        Remove-AzAutomationConnection @removeConnectionInputObject
        
        Write-Verbose "Add new run as connection"
        $newConnectionInputObject = @{
            ResourceGroupName     = $ResourceGroup 
            AutomationAccountName = $automationAccountName 
            Name                  = $connectionAssetName 
            ConnectionTypeName    = $connectionTypeName 
            ConnectionFieldValues = $connectionFieldValues
        }
        New-AzAutomationConnection @newConnectionInputObject
    }

    end {
        Write-Debug ("[{0} existed]" -f $MyInvocation.MyCommand)
    }
}