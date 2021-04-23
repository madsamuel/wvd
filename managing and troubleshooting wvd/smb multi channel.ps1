# SMB multi channel enable for Azure Files 
# 


$SubscriptionId = "25e8c5f2-1e4e-4b1e-bbef-00d911724630"
$ResourceGroupName = "smbmc-1208-rg"
$StorageAccountName = "smbmc1208rg"

$context = Get-AzSubscription -SubscriptionId $SubscriptionId 
Set-AzContext $context



Register-AzProviderFeature -FeatureName AllowSMBMultichannel -ProviderNamespace Microsoft.Storage 
Register-AzResourceProvider -ProviderNamespace Microsoft.Storage 