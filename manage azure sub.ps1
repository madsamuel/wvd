Connect-AzAccount

# CSE for creating users
$vmss = "advm"
$rg = "GT090717a"
$extensionName = "customscript"
Remove-AzVMExtension -ResourceGroupName $rg -VMName $vmss -Name $extensionName 
Get-AzVMExtension -ResourceGroupName $rg -VMName $vmss -Name $extensionName 