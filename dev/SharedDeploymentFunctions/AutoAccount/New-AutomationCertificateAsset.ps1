function New-AutomationCertificateAsset {

    param(
        [Parameter(Mandatory = $true)]
        [string] $resourceGroup, 
    
        [Parameter(Mandatory = $true)]
        [string] $automationAccountName,
    
        [Parameter(Mandatory = $true)]
        [string] $certifcateAssetName,
    
        [Parameter(Mandatory = $true)]
        [string] $certPath, 

        [Parameter(Mandatory = $true)]
        [SecureString] $CertPassword, 

        [Parameter(Mandatory = $true)]
        [Boolean] $Exportable
    )

    begin {
        Write-Debug ("[{0} entered]" -f $MyInvocation.MyCommand)
    }

    process {
        Remove-AzAutomationCertificate -ResourceGroupName $resourceGroup -AutomationAccountName $automationAccountName -Name $certifcateAssetName -ErrorAction SilentlyContinue
        New-AzAutomationCertificate -ResourceGroupName $resourceGroup -AutomationAccountName $automationAccountName -Path $certPath -Name $certifcateAssetName -Password $CertPassword -Exportable:$Exportable | write-verbose
    }

    end {
        Write-Debug ("[{0} existed]" -f $MyInvocation.MyCommand)
    }
}
